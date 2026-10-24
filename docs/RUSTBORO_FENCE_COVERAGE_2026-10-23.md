# Rustboro exact native fence coverage — 2026-10-23

The Emerald native `EM_RUSTBORO_CITY` census contains 2,400 distinct cells.
The previous 21-MID classifier recognized 165 fence cells; eight omitted art
variants account for another 15 blocked cells: `2c6`, `2c7`, `2d7`, `2dc`,
`2de`, `2df`, `2e6`, `2e7`. These are original thin depth rails and grass
endcaps, not adjacent paving, roofs or walkable projected headers. The table
now recognizes 29 exact ornate MIDs, gated by General/Rustboro/collision 7.

The original source stripes also establish the correct side of each tile:
`2c6/2de/315` center X 3.5; `2c7/2dc/2df/2ec/31d` 12.5; `318` 11.5;
`319/31a/321` 4.5; `31b/320/32d` 11.5; `32c` 3.5. Coordinates use pixel
edges around each three-pixel dark/light/dark stripe. Horizontal baseline
remains 14. The repeated grass `2b7` is a full horizontal rail, rather than an
L on every tile. Corner branches now face their actual native side.

All visible non-rail pixels on the newly admitted paving variants match the
selected clean original `2bb` quadrants; `2dc` requires the original mixed
`2bd`/`2bb` quadrants. Grass endcaps/depth rails match native grass MID 1.
The existing native ground/collision/elevation/portal data is unchanged.

## Verification checkpoint

Official release API reports engine `v0.3.96`, source
`0e92b587468c2db7c386f055fc272e6505b0f401`. Standalone isolated native Emerald
census passes: **2,400 exact city cells, 180 eligible, 180 source-built,
unchanged native grid, zero streaming recovery failures**. Actual Gym and
south gate captures inspected: the formerly flat depth rails now render in
3D, and the southern horizontal row no longer grows repeated depth segments.
The focused test passes source failure atomicity, all 29 exact families,
non-fence guards, original ground UVs, closed models and blocked tile bounds.

Scratch evidence for this checkpoint is under
`.scratch/hoenn-world-096-20261023/fences-{before,after}/hoenn-rustboro-fence-census/emerald/`:
`rustboro-fences.json`, original atlas dumps, and native/front/side views.
The census driver deduplicates connected projections into exact native city
coordinates; it asserts each QA viewing cell is walkable and every original
MID/collision/elevation is unchanged. No ROM/cache/capture is committed.

This is classification/axis acceptance, not final corner geometry acceptance.
The original art cheats at some turns (e.g. `337` endpost versus `318` above).
Joined source posts, small turn seams, source foot/contact alignment and
coplanar ownership remain in the separate source geometry integration review.
Ruby and Sapphire now also pass their own native census: each has 2,400 unique
city cells, 180 eligible/180 source-built, unchanged grid and recovery zero.
Their native Gym/south gate captures were inspected. Each has 16 formerly
omitted cells (one additional `2c7` versus Emerald), so old coverage was 164.
`tools/audit_hoenn_fence_pixels.py` independently checks each edition's actual
atlas: all ten reviewed full-depth stripe witnesses, every visible ground
pixel beneath the eight newly admitted families, original blocked guards,
exact city census and successful live owners pass. Hidden terrain pixels
are explicitly not claimed recoverable from an occluding rail sprite.
Evidence adds `fences-after/source-pixel-proof.json` and the `ruby`/`sapphire`
native atlas/census/front/side captures. This confirms original R/S art and
terrain separately rather than inferring parity from Emerald IDs. Full Hoenn map/fence
coverage remains incomplete; no all-map acceptance is claimed.
