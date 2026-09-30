#!/usr/bin/env python3
"""Score a QA sweep directory for the defects the mod is known to cause.

    usage: tools/qa/analyze-sweep.py <results-dir> [--top N]

Reports two independent signals per capture:

  void   Fraction of the upper 35% of the frame that is near-black. A room or
         a cutaway whose top is empty scores ~0.94. This is the signal that
         caught the 39 DUNGEON maps, whose environment census matched the
         flagged set 1:1.

         KNOWN CONFOUND: the sweep captures whatever time of day the game is
         in, and a night sky is genuinely near-black. ROUTE_26 at NIGHT scores
         0.65 against a 0.007 median -- a healthy scene. So a real void is
         ~0.94 and a night sky is ~0.63-0.66; read the number, then open the
         image. Do not threshold on 0.60 and call everything above it broken.

  flat   Dominant-colour share of the middle band of the frame. Sprites,
         title cards and the opening movie score >0.95; a real scene does not.

Both are heuristics, so this reports rather than gates, and neither should be
trusted without opening an image. Two false results from earlier attempts are
the reason:

  * A "failure screen" detector keyed on light text in a dark band matched the
    LOCATION BANNER, invented a 47% black-void defect across FireRed, and
    nearly caused a good engine to be reported broken. Celadon City renders
    correctly.
  * A "flat mid-frame" detector missed real battle splashes entirely.

The only trustworthy gate is the scene graph, which is what sweep.lua's
overworldIs() does in-process.
"""
import argparse
import glob
import os
import statistics
import sys
from collections import Counter

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow is required: pip install pillow")


def void_fraction(path):
    with Image.open(path) as im:
        w, h = im.size
        band = im.convert("L").crop((0, 0, w, int(h * 0.35)))
        px = list(band.getdata())
    return sum(1 for v in px if v < 40) / len(px)


def flat_fraction(path):
    with Image.open(path) as im:
        small = im.convert("RGB").resize((32, 18))
        px = list(small.getdata())
    band = px[6 * 32:11 * 32]
    return Counter(band).most_common(1)[0][1] / len(band)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("directory")
    ap.add_argument("--top", type=int, default=12)
    ap.add_argument("--void", type=float, default=0.60,
                    help="void fraction above which a capture is listed")
    args = ap.parse_args()

    shots = sorted(glob.glob(os.path.join(args.directory, "*.png")))
    if not shots:
        sys.exit(f"no PNGs in {args.directory}")

    rows = []
    for p in shots:
        try:
            rows.append((os.path.basename(p), void_fraction(p), flat_fraction(p)))
        except Exception as exc:                      # truncated/partial write
            print(f"  unreadable {os.path.basename(p)}: {exc}", file=sys.stderr)

    voids = [r[1] for r in rows]
    print(f"{args.directory}: {len(rows)} captures")
    print(f"  void  median {statistics.median(voids):.3f}"
          f"   >{args.void:.2f}: {sum(1 for v in voids if v > args.void)}")

    bad_void = sorted((r for r in rows if r[1] > args.void),
                      key=lambda r: -r[1])[:args.top]
    if bad_void:
        print(f"\n  largest voids:")
        for name, v, _ in bad_void:
            print(f"    {v:6.3f}  {name}")

    flats = sorted((r for r in rows if r[2] > 0.95), key=lambda r: -r[2])
    if flats:
        print(f"\n  flat mid-frame (possible splash/card/title): {len(flats)}")
        for name, _, f in flats[:args.top]:
            print(f"    {f:6.3f}  {name}")


if __name__ == "__main__":
    main()
