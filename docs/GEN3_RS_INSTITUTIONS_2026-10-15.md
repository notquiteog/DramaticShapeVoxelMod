# Ruby/Sapphire institutions, flat walls and closed joins

## Scope and design

Version 1.42.0 follows the published 1.41.0 tower batch and preserves the merged 1.41.1 fixes. Independently reviewed
Ruby/Sapphire source patterns cover nine interiors per edition:

| Family | Native map suffixes | Changes |
| --- | --- | --- |
| Lilycove Museum | `LILYCOVE_CITY_LILYCOVE_MUSEUM_1F`, `_2F` | Framed pictures, flat gallery walls, closed partitions/returns, hollow reception counter, stone display and low sculpture plinths. Pokémon figures remain two-sided HD-2D artwork. |
| Oceanic Museum | `SLATEPORT_CITY_OCEANIC_MUSEUM_1F`, `_2F` | Reception staff lanes, rounded display vessels, framed wall diagrams, ship/parts islands and closed terminal shells. |
| Devon | `RUSTBORO_CITY_DEVON_CORP_1F`, `_2F`, `_3F` | Reception, research desks/CRTs, plans, instruments, closed display cases, seating and executive/meeting tables. |
| Space Center | `MOSSDEEP_CITY_SPACE_CENTER_1F`, `_2F` | Sloping controls, closed CRTs/desks, plans tables and low native seats. |

The source drawing supplies palette, pictures, lettering and fixture placement.
Closed geometry supplies sides, backs, undersides and recesses. No generated
replacement bitmap, reference screenshot or imported native pixel is shipped.
Complete identifier/permission matches stand down when a third-party mod changes
the source or walking cells. The shared Emerald catalog is not wholesale enabled
for Ruby/Sapphire.

User corrections are part of acceptance: walls are flat, continuous surfaces;
furniture stands separately in front. Native floor plans and walking cells decide
where stairs and partition walls belong. T-junctions close the original six-pixel
joins. Plain room backing no longer adds synthetic cornices/baseboards through
the painted wall. The original back-wall wallpaper and lower trim repeat around
all four outer walls. BG1/BG2 are composited into one runtime-only material so
transparent source pixels cannot expose a second coplanar grey layer. Native
north windows/pictures remain fixtures rather than repeating around the room.
Side veneers have a small outward depth offset; the ceiling is
separate from wall caps. Exterior museum design/elevation/stairs remain intact;
no new museum lettering is added.

Native Oceanic Museum staircases use complete three-by-two source drawings,
exact permissions and the existing closed Hoenn stair implementation. This also
matches Emerald's independently inspected native stair art. No native warp,
collision, script, gameplay, sprite or base UI changes are made.

## Reference inspection

Native source diagrams were inspected for all nine Ruby and Emerald rooms before
modeling. Sapphire is independently checked through its imported runtime maps.
ORAS is used for construction/material guidance; it does not replace GBA layouts:

- [Devon Corporation 3F ORAS](https://archives.bulbagarden.net/wiki/File:Devon_Corporation_3F_ORAS.png): separate desks, benches and exhibit furniture in front of a continuous wall.
- [Oceanic Museum ORAS ship displays](https://oraswiki.com/assets/images/key-items/devon-parts/26-challenging-the-evil-team-grunts-pokemon-oras-screenshot.jpg): raised maritime exhibits and finished cases.
- [Mossdeep Space Center ORAS](https://oraswiki.com/assets/walkthrough/part24/01-pokemon-oras-back-at-mossdeep-space-center.jpg): separate computer banks, native room lanes and finished equipment.

These references were visually opened in the browser, not merely inferred from
search captions. Their pixels are not included in the mod.

## Verification

Official Gen1Recomp **0.3.89**, confirmed latest before this batch. Tests use
isolated source-run QA shells and copied disposable imports/profiles. Logs,
native source diagrams and rendered captures stay in the dedicated private
`rs-institution-interiors-20261015` scratch batch. No Continue save is overwritten.

- 110 edition fixtures check all 55 component recipes in both Ruby and Sapphire:
  complete patterns, exact permissions, closed shells, atlas UVs, source bounds,
  walking clearance and neighboring-identifier/permission rejection.
- Wall-junction regression checks require both halves of the full-height join.
  Room-shell checks reject trim protruding through the finished wall, oversize
  synthetic cornices and coplanar ceiling/wall caps.
- Ordinary furniture solids are checked at every height against native walking
  cells. Native low seats are explicit exceptions: their occupied cell remains
  walkable as in the source, with original presentation support and no new
  collision. Staff lanes remain empty.
- Broad combined Lua suite (including published 1.41.1): **305 passed, zero failed, 58 explicit missing-fixture skips**.
- Native Ruby and Sapphire census: **140 new component placements per edition**,
  **zero ordinary-solid overlaps with walking cells**, and **32 low native seats**
  per edition, reported separately.
- Front, sides, rear and low-eye renders inspected for all nine rooms in each
  edition (90 captures); native source comparison and reverse views check wall
  continuity, wallpaper, closed backs and grey bleed-through.
- Exact archived build `8b98623`, preserving published main `4bc557a`: all nine
  native aisles and stair warps per Ruby/Sapphire edition pass. OFF fallback and
  actual camera level 6 (1ST) are captured in every room. A nearby NPC obscures
  part of Oceanic 1F's actual first-person view; separate eye-height/orbit review
  covers its fixtures.
- Emerald Oceanic Museum native up/down stair warps pass, with aisle/OFF/1ST
  checks. FireRed `FR_OAKS_LAB` and the older Emerald Devon 1F renders are
  inspected as shared-renderer neighbors.
- Sapphire museum exterior regression: both lanes x11/x12 traverse the original
  12-unit terrace rise in both directions, maximum per-frame support step 1.5;
  actor/camera support agreement and original entrance warp pass.
- Exact archive with all six latest partners: loaded-version assertions,
  museum aisle/1ST/OFF/stair warp and empty mod-error list pass. Partners were
  clean: wild_skies 1.15.2 (`463913e`), sky ride 0.5.5 (`fd425f0`), doubles
  0.14.3 (`5bfc0ef`), online 0.11.2 (`6e838e2`), overworld spawns 2.6.4
  (`b81dc23b`), modern UI 0.4.2 (`bcde575`). This is a combined local smoke
  test, not a new multiplayer-network or complete quest-progression claim.
- Archive integrity and exclusion checks pass: **11,391 files / 485 Lua files**,
  every packaged Lua file compiles, no hard dependencies, imported pixels,
  captures, ROMs, engine binaries or generated caches. Evidence-only final
  repackaging compares every runtime file hash with this tested archive.
  Synthetic source fixtures alone do not establish visual QA.

One early Emerald run used a copied profile with this mod disabled; an Oak lab
review initially requested an invalid map name. Those driver setup failures are
not passes; final archive checks use the enabled profile and native `FR_OAKS_LAB`.

Initial QA message clearing discarded a pending callback; later chained room
fixtures remained script-locked. Those failed input attempts are not passes.
The accepted driver uses normal held B input to finish native messages before
continuing. It never replaces native collision, input handlers or script VMs.

## Optional third-party room metadata

A Gen3 interior may opt into the same flat room finish with
`def.voxelFlatWalls=true`, `def.voxelWallFloor=<native floor MID>`, and
`def.voxelWallpaper={upperMID,lowerMID}`. Both wallpaper IDs must be native integer
metatiles in 0..1023; optional `column=0..15` repeats one plain source column
instead of repeating a window. Missing/invalid artwork stands down. This metadata
requires no other mod and works with additional building/general room tilesets.
Room geometry/caches must be refreshed after changing map metadata or atlas data.
Native walking cells and openings remain authoritative.

## Remaining work

This is a focused institutional batch, not a claim of complete Hoenn/Kanto or
ORAS-equivalent visual coverage. Remaining large interiors and the requested
first-three-settlement scenery/interior pass are tracked separately in
`GEN3_STARTING_REGIONS_2026-10-15.md`. Emerald furniture families predate this batch;
they are not silently relabeled as newly reviewed Ruby/Sapphire rooms.
