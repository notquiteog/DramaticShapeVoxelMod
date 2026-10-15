# Scene construction and desktop GC — 2026-10-15

Official Gen1Recomp 0.3.89, rechecked during this batch, native NVIDIA RTX 5060 Ti
(driver615.71.09), 2560x1440, native render scale, high shadows, AUTO distance.
Isolated QA profiles only; no player saves or installed app altered.

## Changes

- Hoenn sea rocks share exact scene-owned GPU hulls and XYZ placements. Ground
  heights, both native atlas layers, shadows and stage culling remain unchanged.
  Unavailable/failed instancing keeps the original expanded geometry. Cancelled
  builds and completed scenes release prototype/offset/merged GPU resources.
- Native tree families share at most eight compact occupancy masks across source
  palettes. Exact original formulas determine every voxel; colors, UVs, greedy
  face merging and geometry stay per source. Oversized requests bypass the cache.
- Desktop Gen3 raises the public GC ceiling from256 to512MiB while voxel mode is
  selected. Incremental GC budget/steps and engine dynamic thresholds are not
  changed. OFF/launcher restores our own claim; larger or subsequently changed
  policies and handheld defaults are preserved. This is allocation headroom,
  not a memory-usage cap or disabling collection.
- Connected-map prediction prefers a seam in the native player's direction,
  without expanding the original range or ignoring the connection's span.

## Evidence

Repeated controlled coastal comparison before the shared tree-mask change:
Route104 cold952.21 ->852.77ms; Petalburg297.22 ->214.47ms. Route104 hull append
count176 ->4; mesh creation33.32 ->8.25ms. Final cold with both caches:
Route104691.97ms; Petalburg170.31ms. These are bounded individual runs, not
statistically controlled whole-game loading guarantees.

A112.00ms Emerald approach spike contained98.58ms in original Game3.stepGC,
with6.08ms scene drawing. Scoped public headroom removed this forced collection
in the matching fixture; final Emerald crossing max16.90ms. Other final crossing
maxima were FR18.35, LG30.70, Ruby16.98, Sapphire19.09ms. The remaining LeafGreen
spike was24.21ms draw work, not the full-collection problem.

The11-game native sweep passed six GB/GBC forest/lab/first-person fixtures and
five GBA real running connections, including camera retention and comparison to
native connected-map sampling. Hoenn rocks rendered in all three editions;
Emerald/Sapphire first-person and Ruby rotating-third screenshots inspected.
Native silhouettes, water underlay and placement remain unchanged. First-person
fixtures are2560x1296 windowed; performance fixtures are2560x1440 fullscreen.
Emerald battle remains p953.73ms/max4.67ms in the final pre-GC-policy fixture.

Focused tests compare every instanced/fallback rock vertex, UV and shade;
shape-cache tests compare complete output against uncached formulas across
families, detail levels, source UVs and dimensions, including bounded eviction.
GC policy tests cover lifecycle, absent API, handhelds and other-mod ownership.

## Rejected and remaining

Reducing lookahead8/4ms to4/2ms caused72–97ms spikes/late completion and was
reverted. Do not advertise steady165FPS: connected-scene construction still
exceeds6.06ms, and cold/unprepared warps remain synchronous. A preexisting
engine dynamic GC threshold can supersede the public ceiling; it remains
engine-owned. Long-session memory and arbitrary custom-region workloads are
not certified. Source changes here follow1.41.1 and are not in that archive.

Native logs/fixtures are in the task evidence directory
`.scratch/rock-instances-20261015/` outside the repository.
