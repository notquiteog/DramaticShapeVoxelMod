#!/usr/bin/env python3
"""Render a gen1recomp Gen 3 tileset back to PNG so its art can be read by eye.

    usage: tools/qa/tileset-sheet.py <profile-dir> <tileset-id> [-o out.png]

`<profile-dir>` is the game's cache root, e.g.
  profiles/firered/love/iso-firered-qa/firered/data/generated/gba

The importer writes each tileset as raw GBA 4bpp tile graphics plus a 16x16
palette table and a metatile->tile index. That is unreadable on its own, and
guessing what a metatile id depicts is how a model gets seated on a wall --
`0x2ba`/`0x2bb` in building__rom_082d4d4c looked like planters in the room
layout and were in fact the wall band; replacing them opened a hole straight
through Celadon Gym.

So: render the sheet, look at it, and identify the metatile. This prints the
tile strip per palette bank and, when metatiles.bin is readable, the composed
metatile grid with each one's id.

Requires Pillow.
"""
import argparse
import json
import os
import struct
import sys


def load_palettes(path):
    raw = open(path, "rb").read()
    banks = []
    for p in range(len(raw) // 32):
        cols = []
        for i in range(16):
            v = struct.unpack_from("<H", raw, (p * 16 + i) * 2)[0]
            r, g, b = (v & 31) * 8, ((v >> 5) & 31) * 8, ((v >> 10) & 31) * 8
            cols.append((min(255, b), min(255, g), min(255, r)))
        banks.append(cols)
    return banks


def render_tiles(tiles, bank, scale):
    from PIL import Image
    n = len(tiles) // 32
    img = Image.new("RGB", (n * 8, 8), (0, 0, 0))
    for t in range(n):
        for px in range(64):
            byte = tiles[t * 32 + px // 2]
            v = (byte & 0xF) if px % 2 == 0 else (byte >> 4)
            img.putpixel((t * 8 + px % 8, px // 8), bank[v])
    return img.resize((n * 8 * scale, 8 * scale), Image.NEAREST)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("profile")
    ap.add_argument("tileset", help="tileset id, e.g. ts_082d4d4c or 082d4d4c")
    ap.add_argument("-o", "--out", default="tileset-sheet.png")
    ap.add_argument("--scale", type=int, default=4)
    args = ap.parse_args()

    tid = args.tileset if args.tileset.startswith("ts_") else "ts_" + args.tileset
    root = os.path.join(args.profile, "map_tree", "tilesets", tid)
    if not os.path.isdir(root):
        sys.exit(f"no tileset at {root}")

    meta = json.load(open(os.path.join(root, "meta.json")))
    banks = load_palettes(os.path.join(root, "palettes.bin"))
    tiles = open(os.path.join(root, "tiles.4bpp"), "rb").read()

    from PIL import Image
    strips = [render_tiles(tiles, banks[b], args.scale)
              for b in range(0, len(banks), 4)]
    width = max(s.width for s in strips)
    height = sum(s.height + 6 for s in strips)
    sheet = Image.new("RGB", (width, height), (24, 24, 24))
    y = 0
    for s in strips:
        sheet.paste(s, (0, y))
        y += s.height + 6
    sheet.save(args.out)

    print(f"{tid}: {meta.get('mid_count')} metatiles, "
          f"{meta.get('palette_count')} palettes, {len(tiles)//32} tiles")
    print(f"wrote {args.out}  ({sheet.width}x{sheet.height})")
    print("Palette banks are stacked top to bottom in rows of 4. Each 8px cell "
          "is one 4bpp tile, in file order -- the metatile index in "
          "metatiles.bin says which tiles each mid is built from.")


if __name__ == "__main__":
    main()