#!/usr/bin/env python3
"""Convert an XD source pack to portable geometry/animation data.

Uses an external, pinned GPLv3 StarsMmd parser installation (not bundled).
No Blender runtime is needed; install standalone mathutils for its matrix math.
This is a conversion tool, not a claim of runtime/rendering completeness.
"""
import argparse
import bisect
from concurrent.futures import ProcessPoolExecutor, as_completed
import dataclasses
from enum import Enum
import hashlib
import importlib
import json
import math
import re
import shutil
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import types
import zlib

PARSER_REVISION = "dc71de837978a6a2fe8c5082f2840cfafb135235"

def spline_point(path, parameter):
    """Evaluate a decoded path in its own coordinate system."""
    points, kind = path.control_points, path.curve_type
    segments = path.num_control_points - 1
    if segments < 1 or kind not in (0, 1, 2, 3):
        raise ValueError("Invalid XD spline")
    t = max(0., min(1., parameter)) * segments
    segment = min(segments - 1, int(t))
    t -= segment
    if kind == 0:
        p = points[segment:segment+2]
        weights = (1-t, t)
    elif kind == 1:
        p = points[3*segment:3*segment+4]
        weights = ((1-t)**3, 3*(1-t)**2*t, 3*(1-t)*t*t, t**3)
    elif kind == 2:
        p = points[segment:segment+4]
        weights = ((1-t)**3/6, (3*t**3-6*t*t+4)/6,
                   (-3*t**3+3*t*t+3*t+1)/6, t**3/6)
    else:
        p = points[segment:segment+4]
        s = path.tension
        h1, h2 = t**3-2*t*t+t, t**3-t*t
        weights = (-s*h1, 2*t**3-3*t*t+1-s*h2,
                   -2*t**3+3*t*t+s*h1, s*h2)
    if len(p) != len(weights):
        raise ValueError("Truncated XD spline")
    return tuple(sum(point[axis]*weight for point, weight in zip(p, weights))
                 for axis in range(3))

def sample(keys, frame, default):
    """Evaluate source channels, including authored cubic tangent handles."""
    if not keys:
        return default
    i = bisect.bisect_right([k.frame for k in keys], frame) - 1
    if i < 0:
        return keys[0].value
    a = keys[i]
    if i + 1 == len(keys) or a.interpolation.value == "CONSTANT":
        return a.value
    b = keys[i + 1]
    span = b.frame - a.frame
    if span <= 0:
        return b.value
    t = (frame - a.frame) / span
    if a.interpolation.value == "LINEAR":
        return a.value + (b.value - a.value) * t
    if a.handle_right and b.handle_left:
        def bez(p, q, r, s, u):
            v = 1 - u
            return v*v*v*p + 3*v*v*u*q + 3*v*u*u*r + u*u*u*s
        lo, hi = 0., 1.
        for _ in range(28):
            u = (lo + hi) / 2
            x = bez(a.frame, a.handle_right[0], b.handle_left[0], b.frame, u)
            if x < frame:
                lo = u
            else:
                hi = u
        return bez(a.value, a.handle_right[1], b.handle_left[1], b.value, (lo+hi)/2)
    # Source slopes are derivatives in value/frame.
    m0 = a.slope_out if a.slope_out is not None else 0.
    m1 = b.slope_in if b.slope_in is not None else 0.
    return ((2*t**3-3*t*t+1)*a.value + (t**3-2*t*t+t)*span*m0
            + (-2*t**3+3*t*t)*b.value + (t**3-t*t)*span*m1)


def png_rgba(width, height, pixels):
    if width <= 0 or height <= 0 or len(pixels) != width * height * 4:
        raise ValueError("Invalid decoded texture")
    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(
            ">I", zlib.crc32(kind + data))
    # Parser pixels are bottom-to-top; PNG scanlines are top-to-bottom.
    rows = b"".join(b"\0" + pixels[y*width*4:(y+1)*width*4]
                    for y in range(height-1, -1, -1))
    return (b"\x89PNG\r\n\x1a\n" +
            chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)) +
            chunk(b"IDAT", zlib.compress(rows)) + chunk(b"IEND", b""))


def parser_modules(root):
    root = Path(root).resolve()
    revision = subprocess.check_output(
        ["git", "-C", str(root), "rev-parse", "HEAD"], text=True).strip()
    if revision != PARSER_REVISION:
        raise ValueError("Use the documented XD parser revision")
    import mathutils  # fail early; do not use parser's incomplete test math shim
    sys.path.insert(0, str(root))
    # Import pure pipeline phases without importer/__init__ importing bpy.
    package = types.ModuleType("importer")
    package.__path__ = [str(root / "importer")]
    sys.modules["importer"] = package
    def load(name):
        return importlib.import_module("importer.phases." + name)
    return (load("extract.extract").extract_dat,
            load("route.route").route_sections,
            load("parse.parse").parse_sections,
            load("describe.describe").describe_scene,
            load("plan.helpers.animations"))


_worker_pipeline = None


def start_worker(root):
    global _worker_pipeline
    _worker_pipeline = parser_modules(root)


def convert_job(source, output, digest):
    source = Path(source)
    if hashlib.sha256(source.read_bytes()).hexdigest() != digest:
        raise ValueError("Source hash mismatch")
    output = Path(output)
    with tempfile.TemporaryDirectory(prefix=".xd-", dir=output.parent) as staging:
        staged = Path(staging) / digest
        result = convert_record(source, staged, _worker_pipeline)
        if output.exists():
            # Only the exact content-addressed record may be replaced on resume.
            if output.name != digest or output.is_symlink():
                raise ValueError("Unsafe XD output record")
            shutil.rmtree(output)
        staged.rename(output)
        return result


def convert_record(source, output, pipeline):
    extract, route, parse, describe, animation = pipeline
    from mathutils import Matrix, Vector
    blob = source.read_bytes()
    entries = extract(blob, source.name, {"include_shiny": True})
    if len(entries) != 1:
        raise ValueError("Expected one PKX model")
    data, meta = entries[0]
    options = {"filepath": meta.filename, "pkx_header": meta.pkx_header,
               "ik_hack": True, "max_frame": 1000000000, "section_names": []}
    scene = describe(parse(data, route(data), options), options)
    if len(scene.models) != 1:
        raise ValueError("Expected one skeleton per PKX")
    model = scene.models[0]
    mesh_ids = {}
    digits = len(str(max(0, len(model.meshes) - 1)))
    for i, mesh in enumerate(model.meshes):
        mesh.id = f"mesh_{i:0{digits}d}_{model.bones[mesh.parent_bone_index].name}"
        mesh_ids[mesh.id] = mesh
    output.mkdir(parents=True)
    textures = {}

    def serial(value):
        if type(value).__name__ == "IRImage":
            encoded = png_rgba(value.width, value.height, value.pixels)
            digest = hashlib.sha256(encoded).hexdigest()
            name = digest + ".png"
            if name not in textures:
                (output / name).write_bytes(encoded)
                textures[name] = True
            return {"path": name, "width": value.width, "height": value.height}
        if dataclasses.is_dataclass(value):
            return {f.name: serial(getattr(value, f.name)) for f in dataclasses.fields(value)}
        if isinstance(value, Enum):
            return value.value
        if isinstance(value, bytes):
            return list(value)
        if isinstance(value, (tuple, list)):
            return [serial(v) for v in value]
        if isinstance(value, dict):
            return {str(k): serial(v) for k, v in value.items()}
        return value

    skeleton = animation.build_bake_skeleton(model.bones, model.bone_animations)
    inverses = [Matrix(b.normalized_world_matrix).inverted_safe() for b in model.bones]
    clips = []
    for clip_index, clip in enumerate(model.bone_animations):
        duration = max((t.end_frame for t in clip.tracks), default=0)
        if not math.isfinite(duration) or not 0 <= duration <= 36000:
            raise ValueError("Unreasonable animation duration")
        count = math.ceil(duration) + 1
        packed = bytearray()
        material_frames = []
        for frame in range(count):
            srts = {}
            for track in clip.tracks:
                values = []
                for channels, rest in ((track.scale, track.rest_scale),
                                       (track.rotation, track.rest_rotation),
                                       (track.location, track.rest_position)):
                    values.append(tuple(sample(channels[i], frame, rest[i]) for i in range(3)))
                if track.spline_path:
                    path = track.spline_path
                    p = Vector(spline_point(path, sample(path.parameter_keyframes, frame, 0)))
                    if path.world_matrix:
                        p = Matrix(path.world_matrix) @ p
                    parent = model.bones[track.bone_index].parent_index
                    if parent is not None:
                        p = Matrix(model.bones[parent].world_matrix).inverted_safe() @ p
                    values[2] = tuple(p)
                srts[track.bone_index] = tuple(values)
            targets = animation.bake_frame(skeleton, srts, range(len(model.bones)))
            for bone in range(len(model.bones)):
                skin = Matrix(targets[bone]) @ inverses[bone]
                numbers = [v for row in list(skin)[:3] for v in row]
                if not all(math.isfinite(v) for v in numbers):
                    raise ValueError("Non-finite skin matrix")
                packed.extend(struct.pack("<12f", *numbers))
            materials = {}
            for track in clip.material_tracks:
                mesh = mesh_ids.get(track.material_mesh_name)
                if mesh is None or mesh.material is None:
                    raise ValueError("Material animation has no owning mesh")
                base = mesh.material
                values = {"diffuse": [
                    sample(track.diffuse_r, frame, base.diffuse_color[0]),
                    sample(track.diffuse_g, frame, base.diffuse_color[1]),
                    sample(track.diffuse_b, frame, base.diffuse_color[2])],
                    "alpha": sample(track.alpha, frame, base.alpha), "layers": {}}
                for uv in track.texture_uv_tracks:
                    layer = base.texture_layers[uv.texture_index]
                    values["layers"][str(uv.texture_index)] = {
                        "translation": [sample(uv.translation_u, frame, layer.translation[0]),
                                        sample(uv.translation_v, frame, layer.translation[1]), 0],
                        "scale": [sample(uv.scale_u, frame, layer.scale[0]),
                                  sample(uv.scale_v, frame, layer.scale[1]), layer.scale[2]],
                        "rotation": [sample(uv.rotation_x, frame, layer.rotation[0]),
                                     sample(uv.rotation_y, frame, layer.rotation[1]),
                                     sample(uv.rotation_z, frame, layer.rotation[2])]}
                materials[track.material_mesh_name] = values
            material_frames.append(materials)
        filename = f"clip-{clip_index}.bin.z"
        (output / filename).write_bytes(zlib.compress(packed, 6))
        clips.append({"name": clip.name, "frames": count, "fps": 30,
                      "bones": len(model.bones), "path": filename,
                      "materials": material_frames if clip.material_tracks else []})
    result = {"version": 1, "model": serial(model), "clips": clips,
              "header": serial(meta.pkx_header), "shiny": serial(meta.shiny_params),
              "particlesPresent": bool(meta.gpt1_data),
              "particleBytes": len(meta.gpt1_data)}
    if meta.gpt1_data:
        (output / "particles.gpt1").write_bytes(meta.gpt1_data)
    (output / "model.json.z").write_bytes(zlib.compress(
        json.dumps(result, separators=(",", ":"), allow_nan=False).encode(), 6))
    return {"meshes": len(model.meshes), "bones": len(model.bones),
            "clips": len(clips), "textures": len(textures),
            "particles": bool(meta.gpt1_data)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--parser", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--dex", type=int, help="Diagnostic subset only, not a full pack")
    parser.add_argument("--workers", type=int, default=2)
    parser.add_argument("--resume", action="store_true",
                        help="Reuse successful records from a matching interrupted conversion")
    args = parser.parse_args()
    if args.output.exists() and not args.resume:
        parser.error("Output exists; choose a new directory")
    manifest = json.loads((args.source / "manifest.json").read_text())
    args.output.mkdir(parents=True, exist_ok=args.resume)
    converted, failures = {}, {}
    previous = args.output / "manifest.json"
    if args.resume and previous.exists():
        old = json.loads(previous.read_text())
        if old.get("parserRevision") != PARSER_REVISION or old.get("format") != "xd-converted-pack":
            parser.error("Resume requires a matching converter manifest")
        converted = old.get("converted", {})
    records = [r for r in manifest["models"] if args.dex is None or r["dex"] == args.dex]
    unique = {}
    for row in records:
        digest = row["sha256"]
        if not isinstance(digest, str) or not re.fullmatch("[0-9a-f]{64}", digest):
            raise ValueError("Invalid source hash/path")
        if row["path"] != "pkx/" + digest + ".pkx":
            raise ValueError("Invalid source record path")
        unique[digest] = row
    for digest in list(converted):
        if digest not in unique or not (args.output / digest / "model.json.z").is_file():
            del converted[digest]
    # Failed records live in a separate temporary directory until complete.
    with ProcessPoolExecutor(max_workers=max(1, min(8, args.workers)),
                             initializer=start_worker, initargs=(args.parser,)) as pool:
        pending = {pool.submit(convert_job, args.source / row["path"], args.output / digest,
                               digest): digest for digest, row in unique.items()
                   if digest not in converted}
        for future in as_completed(pending):
            digest = pending[future]
            row = unique[digest]
            try:
                converted[digest] = future.result()
                print(f"{row['dex']:03d} {row['variant']} {row['form']}: {converted[digest]}", flush=True)
            except Exception as error:
                failures[digest] = str(error)
                print(f"FAILED {row['dex']}: {error}", flush=True)
    report = {"format": "xd-converted-pack", "version": 1, "renderReady": False,
              "targetGames": manifest["targetGames"], "models": records,
              "converted": converted, "failures": failures,
              "parserRevision": PARSER_REVISION,
              "note": "Conversion evidence only; runtime/material/particle validation pending."}
    (args.output / "manifest.json").write_text(json.dumps(report, indent=2) + "\n")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
