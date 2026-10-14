#!/usr/bin/env python3
"""Composite native Gen3 source views from QA exports (scratch only).

Inputs come from tools/qa/gen3-metatile-hashes.lua run with QA_HASH_SHEETS=1:
  <dir>/<edition>-metatile-hashes.tsv, <dir>/<edition>-layouts.tsv,
  <dir>/atlas-<canonical>.png

  gen3_source_view.py region DIR EDITION MAP X Y W H OUT.png [--scale 4] [--grid] [--coll]
  gen3_source_view.py mids DIR EDITION PAIR MID[,MID...] OUT.png [--scale 6]

Outputs are imported art and must stay in scratch; never commit them.
"""
import csv, sys
from PIL import Image, ImageDraw

def load(d, ed):
    slots = {}
    for r in csv.DictReader(open(f'{d}/{ed}-metatile-hashes.tsv'), delimiter='\t'):
        slots[(r['canonical'], int(r['mid'], 16))] = (int(r['slot']), int(r['cols']))
    lays = {}
    for r in csv.DictReader(open(f'{d}/{ed}-layouts.tsv'), delimiter='\t'):
        lays[r['map']] = r
    return slots, lays

def tile(d, slots, cache, pair, mid):
    import os
    if pair not in cache:
        o = f'{d}/atlas-over-{pair}.png'
        cache[pair] = (Image.open(f'{d}/atlas-{pair}.png').convert('RGBA'),
                       Image.open(o).convert('RGBA') if os.path.exists(o) else None)
    s = slots.get((pair, mid))
    if not s: return None
    slot, cols = s
    x, y = (slot % cols) * 16, (slot // cols) * 16
    under, over = cache[pair]
    t = under.crop((x, y, x + 16, y + 16))
    if over is not None: t = Image.alpha_composite(t, over.crop((x, y, x + 16, y + 16)))
    return t

def region(d, ed, mp, x, y, w, h, out, scale=4, grid=False, coll=False):
    slots, lays = load(d, ed); r = lays[mp]; cache = {}
    W, H = int(r['w']), int(r['h']); mids = r['mids'].split(' '); col = r['collision'].split(' ')
    img = Image.new('RGBA', (w * 16, h * 16), (0, 0, 0, 255))
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            if 0 <= xx < W and 0 <= yy < H:
                t = tile(d, slots, cache, r['canonical'], int(mids[yy * W + xx], 16))
                if t: img.paste(t, ((xx - x) * 16, (yy - y) * 16))
    img = img.resize((w * 16 * scale, h * 16 * scale), Image.NEAREST)
    dr = ImageDraw.Draw(img, 'RGBA')
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            if not (0 <= xx < W and 0 <= yy < H): continue
            px, py = (xx - x) * 16 * scale, (yy - y) * 16 * scale
            if coll and col[yy * W + xx] != '0':
                dr.rectangle([px, py, px + 16 * scale - 1, py + 16 * scale - 1], outline=(255, 0, 0, 160), width=max(1, scale // 2))
            if grid:
                dr.rectangle([px, py, px + 16 * scale - 1, py + 16 * scale - 1], outline=(255, 255, 255, 50))
                dr.text((px + 2, py + 1), f'{xx},{yy}', fill=(255, 255, 0, 200))
                dr.text((px + 2, py + 11), mids[yy * W + xx], fill=(0, 255, 255, 200))
    img.save(out)

def strip(d, ed, pair, mids, out, scale=6):
    slots, _ = load(d, ed); cache = {}
    img = Image.new('RGBA', (len(mids) * 18 * scale, 26 * scale), (40, 40, 40, 255))
    dr = ImageDraw.Draw(img)
    for i, m in enumerate(mids):
        t = tile(d, slots, cache, pair, m)
        if t: img.paste(t.resize((16 * scale, 16 * scale), Image.NEAREST), (i * 18 * scale, 0))
        dr.text((i * 18 * scale + 2, 17 * scale), f'{m:03X}', fill=(255, 255, 0))
    img.save(out)

if __name__ == '__main__':
    a = sys.argv[1:]
    opt = lambda k, dflt: int(a[a.index(k) + 1]) if k in a else dflt
    if a[0] == 'region':
        region(a[1], a[2], a[3], int(a[4]), int(a[5]), int(a[6]), int(a[7]), a[8], opt('--scale', 4), '--grid' in a, '--coll' in a)
    elif a[0] == 'mids':
        strip(a[1], a[2], a[3], [int(m, 16) for m in a[4].split(',')], a[5], opt('--scale', 6))
