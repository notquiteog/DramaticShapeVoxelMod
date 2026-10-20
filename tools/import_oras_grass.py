#!/usr/bin/env python3
"""Bake the user-selected public ORAS grass bind pose into static scenery data.

The original ZIP/DAEs stay outside the repository. This deliberately supports
the inspected static triangle/skin subset, and fails on unsupported structures.
No Blender, network access or third-party runtime model provider is required.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path, PurePosixPath
import xml.etree.ElementTree as ET
import zipfile

NS = {"c": "http://www.collada.org/2005/11/COLLADASchema"}
IDENTITY = [[float(i == j) for j in range(4)] for i in range(4)]
SOURCE_URL = "https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/353363/"
DOWNLOAD_URL = "https://models.spriters-resource.com/media/assets/350/353363.zip?updated=1755515450"
SOURCES = {"oras_green": "grass.dae", "oras_dry": "grass02.dae", "oras_tall": "grass04.dae"}


def matrix(values):
    if len(values) != 16:
        raise ValueError("Expected 4x4 transform")
    # COLLADA text stores these inspected Blender-export matrices row by row.
    return [values[i:i+4] for i in range(0, 16, 4)]


def multiply(a, b):
    return [[sum(a[i][k]*b[k][j] for k in range(4)) for j in range(4)] for i in range(4)]


def apply(m, p):
    value = [sum(m[i][k]*list(p[:3] + [1])[k] for k in range(4)) for i in range(4)]
    if abs(value[3]) < 1e-12:
        raise ValueError("Invalid homogeneous position")
    return [value[i]/value[3] for i in range(3)]


def transform(node):
    result = IDENTITY
    for element in node:
        kind = element.tag.rsplit("}", 1)[-1]
        if kind not in ("matrix", "translate", "rotate", "scale", "lookat", "skew"):
            continue
        v = [float(x) for x in (element.text or "").split()]
        if kind == "matrix":
            part = matrix(v)
        elif kind == "translate":
            part = [row[:] for row in IDENTITY]
            for i in range(3):
                part[i][3] = v[i]
        elif kind == "scale":
            part = [row[:] for row in IDENTITY]
            for i in range(3):
                part[i][i] = v[i]
        elif kind == "rotate":
            length = math.sqrt(sum(x*x for x in v[:3]))
            if length <= 0:
                raise ValueError("Invalid rotation axis")
            x, y, z = [a/length for a in v[:3]]
            c, s = math.cos(math.radians(v[3])), math.sin(math.radians(v[3]))
            t = 1-c
            part = [[t*x*x+c,t*x*y-s*z,t*x*z+s*y,0],
                    [t*x*y+s*z,t*y*y+c,t*y*z-s*x,0],
                    [t*x*z-s*y,t*y*z+s*x,t*z*z+c,0],[0,0,0,1]]
        else:
            raise ValueError("Unsupported scene transform: "+kind)
        result = multiply(result, part)
    return result


def sources(parent):
    result = {}
    for source in parent.findall("c:source", NS):
        array = source.find("c:float_array", NS)
        numeric = array is not None
        if array is None:
            array = source.find("c:Name_array", NS)
        if array is None:
            raise ValueError("Unsupported source array")
        values = (array.text or "").split()
        if numeric:
            values = [float(v) for v in values]
        accessor = source.find("c:technique_common/c:accessor", NS)
        stride, offset, count = (int(accessor.get(k, d)) for k, d in
                                 (("stride", "1"), ("offset", "0"), ("count", "0")))
        if count*stride+offset > len(values):
            raise ValueError("Truncated COLLADA source")
        result[source.get("id")] = [values[offset+i*stride:offset+(i+1)*stride] for i in range(count)]
    return result


def inputs(element):
    return {e.get("semantic"): (e.get("source").lstrip("#"), int(e.get("offset", "0")))
            for e in element.findall("c:input", NS)}


def bake_dae(data):
    root = ET.fromstring(data)
    if root.findall(".//c:animation", NS):
        raise ValueError("Animated sources require an explicit pose selection")
    worlds, instances = {}, []
    scene_id = root.find("c:scene/c:instance_visual_scene", NS).get("url").lstrip("#")
    scene = next(n for n in root.findall("c:library_visual_scenes/c:visual_scene", NS) if n.get("id") == scene_id)

    def walk(node, parent):
        world = multiply(parent, transform(node))
        for attr in ("id", "sid", "name"):
            if node.get(attr):
                worlds[node.get(attr)] = world
        for kind in ("instance_controller", "instance_geometry"):
            for inst in node.findall("c:"+kind, NS):
                instances.append((kind, inst, world))
        for child in node.findall("c:node", NS):
            walk(child, world)

    for node in scene.findall("c:node", NS):
        walk(node, IDENTITY)
    geometries = {g.get("id"): g for g in root.findall("c:library_geometries/c:geometry", NS)}
    controllers = {g.get("id"): g for g in root.findall("c:library_controllers/c:controller", NS)}
    effects = {e.get("id"): e for e in root.findall("c:library_effects/c:effect", NS)}
    materials = {m.get("id"): m.find("c:instance_effect", NS).get("url").lstrip("#")
                 for m in root.findall("c:library_materials/c:material", NS)}
    images = {i.get("id"): i.findtext("c:init_from", namespaces=NS)
              for i in root.findall("c:library_images/c:image", NS)}
    up = root.findtext("c:asset/c:up_axis", default="Y_UP", namespaces=NS)
    unit_node = root.find("c:asset/c:unit", NS)
    unit = float(unit_node.get("meter", "1")) if unit_node is not None else 1
    result = []
    for kind, instance, world in instances:
        weights = None
        if kind == "instance_controller":
            skin = controllers[instance.get("url").lstrip("#")].find("c:skin", NS)
            if skin is None:
                raise ValueError("Morph controller not supported")
            geom = geometries[skin.get("source").lstrip("#")]
            src = sources(skin)
            joint_input = inputs(skin.find("c:joints", NS))
            names = src[joint_input["JOINT"][0]]
            inverse = src[joint_input["INV_BIND_MATRIX"][0]]
            bind = matrix([float(v) for v in skin.findtext("c:bind_shape_matrix", namespaces=NS).split()])
            joints = [multiply(multiply(worlds[name[0]], matrix(inv)), bind) for name, inv in zip(names, inverse)]
            vw = skin.find("c:vertex_weights", NS)
            wi = inputs(vw)
            stride = 1+max(i[1] for i in wi.values())
            values = [int(v) for v in vw.findtext("c:v", namespaces=NS).split()]
            counts = [int(v) for v in vw.findtext("c:vcount", namespaces=NS).split()]
            weights, offset = [], 0
            for count in counts:
                row = []
                for _ in range(count):
                    joint = values[offset+wi["JOINT"][1]]
                    weight = src[wi["WEIGHT"][0]][values[offset+wi["WEIGHT"][1]]][0]
                    if joint < 0:
                        raise ValueError("Unbound skin vertex")
                    row.append((joints[joint], weight))
                    offset += stride
                if not row or abs(sum(w for _, w in row)-1) > .002:
                    raise ValueError("Invalid skin weights")
                weights.append(row)
        else:
            geom = geometries[instance.get("url").lstrip("#")]
        mesh = geom.find("c:mesh", NS)
        src = sources(mesh)
        vertex_sources = {v.get("id"): inputs(v) for v in mesh.findall("c:vertices", NS)}
        bindings = {m.get("symbol"): m.get("target").lstrip("#")
                    for m in instance.findall("c:bind_material/c:technique_common/c:instance_material", NS)}
        for primitive in mesh:
            primitive_kind = primitive.tag.rsplit("}", 1)[-1]
            if primitive_kind in ("source", "vertices", "extra"):
                continue
            if primitive_kind != "triangles":
                raise ValueError("Unsupported primitive: "+primitive_kind)
            effect = effects[materials[bindings[primitive.get("material")]]]
            # Resolve the actual diffuse sampler -> surface -> image chain.
            common = effect.find("c:profile_COMMON", NS)
            params = {p.get("sid"): p for p in common.findall("c:newparam", NS)}
            texture = common.find(".//c:diffuse/c:texture", NS)
            sampler = params[texture.get("texture")].findtext("c:sampler2D/c:source", namespaces=NS)
            sampler_node = params[texture.get("texture")].find("c:sampler2D", NS)
            wrap_names = {"WRAP": "repeat", "MIRROR": "mirroredrepeat", "CLAMP": "clamp", "BORDER": "clampzero"}
            wrap_s = wrap_names[sampler_node.findtext("c:wrap_s", default="WRAP", namespaces=NS)]
            wrap_t = wrap_names[sampler_node.findtext("c:wrap_t", default="WRAP", namespaces=NS)]
            image_id = params[sampler].findtext("c:surface/c:init_from", namespaces=NS)
            image_name = images[image_id]
            pin = inputs(primitive)
            stride = 1+max(i[1] for i in pin.values())
            indices = [int(x) for x in primitive.findtext("c:p", namespaces=NS).split()]
            vertices = []
            for start in range(0, len(indices), stride):
                pi = indices[start+pin["VERTEX"][1]]
                pos_source = vertex_sources[pin["VERTEX"][0]]["POSITION"][0]
                p = src[pos_source][pi][:3]
                if weights is not None:
                    transformed = [(apply(m, p), w) for m, w in weights[pi]]
                    p = [sum(q[a]*w for q, w in transformed) for a in range(3)]
                else:
                    p = apply(world, p)
                if up == "Z_UP":
                    p = [p[0], p[2], -p[1]]
                elif up != "Y_UP":
                    raise ValueError("Unsupported asset up-axis")
                p = [v*unit for v in p]
                uv = src[pin["TEXCOORD"][0]][indices[start+pin["TEXCOORD"][1]]][:2]
                vertices.append(p+[uv[0], 1-uv[1], 1.0])
            if len(vertices) != int(primitive.get("count"))*3:
                raise ValueError("Truncated triangle stream")
            result.append({"geometry": geom.get("id"), "texture": image_name, "vertices": vertices,
                           "triangle_count": len(vertices)//3, "skinned_bind_pose": weights is not None,
                           "wrapS": wrap_s, "wrapT": wrap_t})
    return result


def lua(value):
    if isinstance(value, dict):
        return "{"+",".join("["+lua(k)+"]="+lua(v) for k, v in value.items())+"}"
    if isinstance(value, list):
        return "{"+",".join(lua(v) for v in value)+"}"
    if isinstance(value, str):
        return json.dumps(value)
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        if not math.isfinite(value):
            raise ValueError("Nonfinite model data")
        return format(value, ".9g")
    raise TypeError(type(value))


def convert(archive_path, output_root):
    models, provenance = {}, {"title": "Tall Grass", "game": "Pokémon Omega Ruby / Alpha Sapphire (3DS)",
        "section": "Map Objects", "asset_id": 353363, "source_page": SOURCE_URL, "download_url": DOWNLOAD_URL,
        "uploaded_by": "MasterPengo", "uploader_page": "https://models.spriters-resource.com/profile/masterpengo/",
        "submitted": "2024-06-24", "original_game_art": "Nintendo / Creatures / GAME FREAK",
        "archive_sha256": hashlib.sha256(Path(archive_path).read_bytes()).hexdigest(), "models": {}}
    assets = output_root/"assets/scenery/oras-grass"
    assets.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive_path) as archive:
        for name, dae in SOURCES.items():
            raw = archive.read(dae)
            parts = bake_dae(raw)
            standing = [p for p in parts if PurePosixPath(p["texture"]).name.startswith("hureai_grass")]
            if len(standing) != 1:
                raise ValueError("Expected exactly one standing-grass material")
            part = standing[0]
            vertices = part["vertices"]
            low = [min(v[i] for v in vertices) for i in range(3)]
            high = [max(v[i] for v in vertices) for i in range(3)]
            scale = .96/max(high[0]-low[0], high[2]-low[2])
            center = [(high[i]+low[i])/2 for i in range(3)]
            normalized, indices, unique = [], [], {}
            for vertex in vertices:
                v = [(vertex[0]-center[0])*scale, (vertex[1]-low[1])*scale,
                     (vertex[2]-center[2])*scale]+vertex[3:]
                key = tuple(round(x, 10) for x in v)
                if key not in unique:
                    unique[key] = len(normalized)+1
                    normalized.append(v)
                indices.append(unique[key])
            texture = PurePosixPath(part["texture"]).name
            image_bytes = archive.read(texture)
            (assets/texture).write_bytes(image_bytes)
            models[name] = {"texture": "assets/scenery/oras-grass/"+texture, "vertices": normalized,
                            "indices": indices, "triangles": part["triangle_count"], "doubleSided": True,
                            "height": (high[1]-low[1])*scale, "wrapS": part["wrapS"], "wrapT": part["wrapT"]}
            provenance["models"][name] = {"dae": dae, "dae_sha256": hashlib.sha256(raw).hexdigest(),
                "geometry": part["geometry"], "texture": texture, "texture_sha256": hashlib.sha256(image_bytes).hexdigest(),
                "triangles": part["triangle_count"], "source_bind_pose_bounds": {"min": low, "max": high},
                "source_to_unit_scale": scale, "source_unit_center_xz": [center[0],center[2]],
                "grounding_offset_source_y": low[1],
                "excluded_parts": [{"geometry": p["geometry"], "texture": p["texture"], "triangles": p["triangle_count"]}
                                   for p in parts if p is not part]}
    provenance["processing"] = ["Evaluated complete scene hierarchy and weighted bind-pose matrices; applied declared asset units/up-axis.",
        "Selected standing hureai material only; scattered grass_tiru cut-leaf geometry stays out of ordinary grass fields.",
        "Original PNG bytes unchanged. UV V converted from COLLADA to LÖVE convention. Original out-of-range U retained with source sampler wrap.",
        "Uniformly normalized X/Y/Z to 96% square extent; centered X/Z and grounded actual mesh minimum Y. No invented blades or texture pixels."]
    (output_root/"lib/GrassModelData.lua").write_text("-- Generated by tools/import_oras_grass.py; see assets/scenery/oras-grass/provenance.json.\nreturn "+lua(models)+"\n")
    (assets/"provenance.json").write_text(json.dumps(provenance, indent=2, ensure_ascii=False)+"\n")
    return models, provenance


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path)
    parser.add_argument("--output-root", type=Path, required=True)
    args = parser.parse_args()
    models, provenance = convert(args.archive, args.output_root)
    print(json.dumps({k: {"triangles": v["triangles"], "vertices": len(v["vertices"]), "height_per_extent": v["height"]}
                      for k, v in models.items()}, indent=2))
