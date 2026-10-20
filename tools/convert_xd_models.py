#!/usr/bin/env python3
"""Convert an XD source pack to portable geometry/animation data.

Uses an external, pinned GPLv3 StarsMmd parser installation (not bundled).
No Blender runtime is needed; install standalone mathutils for its matrix math.
This is a conversion tool, not a claim of runtime/rendering completeness.
"""
import argparse
import bisect
import dataclasses
from enum import Enum
import hashlib
import importlib
import json
import math
from pathlib import Path
import struct
import sys
import types
import zlib

PARSER_REVISION = "dc71de837978a6a2fe8c5082f2840cfafb135235"


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


def convert_record(source, output, pipeline):
    extract, route, parse, describe, animation = pipeline
    from mathutils import Matrix
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
        for frame in range(count):
            srts = {}
            for track in clip.tracks:
                if track.spline_path:
                    raise ValueError("Spline-driven Pokemon needs a dedicated bake")
                values = []
                for channels, rest in ((track.scale, track.rest_scale),
                                       (track.rotation, track.rest_rotation),
                                       (track.location, track.rest_position)):
                    values.append(tuple(sample(channels[i], frame, rest[i]) for i in range(3)))
                srts[track.bone_index] = tuple(values)
            targets = animation.bake_frame(skeleton, srts, range(len(model.bones)))
            for bone in range(len(model.bones)):
                skin = Matrix(targets[bone]) @ inverses[bone]
                numbers = [v for row in list(skin)[:3] for v in row]
                if not all(math.isfinite(v) for v in numbers):
                    raise ValueError("Non-finite skin matrix")
                packed.extend(struct.pack("<12f", *numbers))
        filename = f"clip-{clip_index}.bin.z"
        (output / filename).write_bytes(zlib.compress(packed, 6))
        clips.append({"name": clip.name, "frames": count, "fps": 30,
                      "bones": len(model.bones), "path": filename})
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
    args = parser.parse_args()
    if args.output.exists():
        parser.error("Output exists; choose a new directory")
    manifest = json.loads((args.source / "manifest.json").read_text())
    pipeline = parser_modules(args.parser)
    args.output.mkdir(parents=True)
    converted, failures = {}, {}
    records = [r for r in manifest["models"] if args.dex is None or r["dex"] == args.dex]
    for row in records:
        digest = row["sha256"]
        if digest in converted or digest in failures:
            continue
        try:
            source = args.source / row["path"]
            if hashlib.sha256(source.read_bytes()).hexdigest() != digest:
                raise ValueError("Source hash mismatch")
            converted[digest] = convert_record(source, args.output / digest, pipeline)
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
