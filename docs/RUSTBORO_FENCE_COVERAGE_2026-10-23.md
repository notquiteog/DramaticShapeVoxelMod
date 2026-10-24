# Rustboro exact native fence coverage — 2026-10-23

## Complete used-art review supersedes the initial known-family census

The initial 180-owner check below covered the then-reviewed 29 MIDs; it was
not a complete inventory of drawn Rustboro rails. Inspection of **all used
primary and secondary native art**, without the earlier numeric window, found
`2a7` (26 horizontal cells) and `352` (two right end pieces). Both are blocked
original rail art. These restore the long rows north of the Gym and near Devon.
The classifier now contains **31 ornate MIDs / 208 native Rustboro cells**.
The original 21-MID state omitted43 Emerald /44 Ruby/Sapphire cells.

Standalone official .96 passes in all3 editions: **2400 unique native cells,
208 eligible/208 source-built, unchanged grid and recovery0**. Updated Emerald
Gym and Ruby east-boundary captures inspected: the long navy flat rows now
render as source rails. All-used primary/secondary native boards inspected.
Evidence is `fences-all-art/hoenn-rustboro-fence-census/{edition}/`; original
`fences-after/` captures retain the narrower180-owner checkpoint honestly.

The pixel audit now independently proves every visible non-rail pixel of
`2a7` matches original `2bb` quadrants, and `352` matches `2e0` quadrants0/1/2
plus `2bb` quadrant0. This is visible-terrain reconstruction evidence, **not**
a byte-exact claim for pixels hidden by baked source rails. The historical
`audit_gen3_fence_ground.py`18-family check is not current acceptance evidence.
Root owns UV-preserving joined geometry, coplanar clipping and final multi-angle
acceptance. The isolated classifier evidence uses the original segment adapter.

## Initial known-family checkpoint (superseded totals)

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
