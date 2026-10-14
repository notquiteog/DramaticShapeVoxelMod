# Gen3 terrain, sea rocks and Ruby/Sapphire parity — 2026-10-14

Runtime: official Gen1Recomp **0.3.86** (released 2026-10-14; Linux AppImage and
`.love` SHA-256 verified against the release `sha256sums.txt`), bundled LÖVE
shell, Xvfb, NVIDIA RTX 5060 Ti. Fresh public `POKEPORT_IMPORT_ONLY` imports of
the user's FireRed, LeafGreen, Emerald, Ruby and Sapphire ROMs into private
`gen3-{edition}-qa` identities under `.scratch/gen3-20261014/profiles`. No
player save, ROM, cache or imported image is committed. Most runs used an
engine copy whose `mods/` holds only this mod (`engine-solo`), proving the
work standalone and keeping partner HUDs out of captures; one Ruby run with
every partner mod loaded (`ru-allmods`) also passed without errors.

## New QA tooling (identifiers only)

| Tool | Purpose |
| --- | --- |
| `tools/qa/gen3-gap-census.lua` | Mirrors Gen3Scene preparation; lists native **non-walkable** cells (Gen2 permission codes, so 0x18 tall grass is walkable) that no model claims, grouped by drawing family and by metatile. |
| `tools/qa/gen3-metatile-hashes.lua` | Hashes each composited 16x16 under+over metatile; exports layouts (mids, collision) and optional scratch atlases. |
| `tools/qa/gen3_source_view.py` | Composites native source regions/strips from those exports, with collision outlines and IDs. |
| `tools/qa/gen3-rs-parity-candidates.lua`, `gen3_rs_parity_table.py` | Lists RS cells Emerald's vocabulary would classify; regenerates `data/gen3_rs_parity.lua` from hash identity plus recorded visual review. |
| `tools/qa/gen3-scene-review.lua` | Production-renderer orbit (4) + eye-level captures at arbitrary cells, parking the player on a native walkable cell. |

Correction found while building the tools: Gen3 `collAt` values are Gen2
permission codes (0x07 solid, 0x29 water, 0x18 grass, 0xA0+ ledges...).
Treating every non-zero code as solid overstated earlier gaps; the census
now uses `Permissions.isWalkable`. New geometry here requires 0x07.

## Outdoor gap census (same tool, before = e3ebfc0, after = this batch)

| Edition | Unclaimed non-walkable cells before | After | Change |
| --- | ---: | ---: | ---: |
| Emerald | 27,548 | 12,271 | −55% |
| Ruby / Sapphire | 49,109 | 11,081 | −77% |
| FireRed / LeafGreen | 11,527 | 8,815 | −24% |

Ruby and Sapphire produce identical hashes and candidates; FR and LG are also
hash-identical. Recognized Civic assemblies with zero low-face/central-8x8
walkable-cell intersections (`building-footprint-census.lua`): Emerald 79/0,
FR 126/0, LG 126/0, Ruby 57/0, Sapphire 57/0 (RS previously 13 each).

## What changed

1. **Ruby/Sapphire terrain parity.** `Gen3Hoenn.emeraldShape` is now callable
   separately; RS reuses an Emerald classification only when
   `data/gen3_rs_parity.lua` lists that `pair:mid` and kind. 315 cliff IDs and
   all steps/rock/roomWall/flat entries are hash-identical; RS trees, ledges and
   some cliffs/fences/grass are redrawn, and their side-by-side RS/Emerald
   sheets were inspected (same object). Rejected: 03E/03F white rails (Emerald
   classifies them as conifers; they are not trees) and Meteor Falls 202 treads.
2. **RS buildings.** 40 more Emerald exterior recipes enabled for RS (all 22
   remaining Centers/Marts, five gyms, Lilycove/Dewford/Lavaridge/Fallarbor
   homes, Dewford hall, both harbors, Lilycove Contest Hall). Every one has a
   complete identical-ID layout in RS; source sheets show the same form with
   RS roof textures. Slateport harbor uses rectangular RS windows. Held back:
   Rustboro urban/Devon (different window vocabulary), Mossdeep and
   Verdanturf homes (different roof deck/windows), and Lilycove's gold
   residence — the footprint audit showed RS leaves its lower-tier corners
   walkable (36,21)/(41,21), so it stays native.
3. **Walkable conifer crowns.** Hoenn narrow conifer / Dewford palm cells with
   walkable collision no longer plant a second tree volume (it trapped the
   player in foliage); they keep native ground and the blocked tree below owns
   the model. Applies to Emerald too.
4. **Hoenn sea rocks** (`lib/Gen3SeaRocks.lua`). Complete solid 2x2 boulder
   (150/151/158/159) and sea-stack (175/176/17D/17E) drawings become one closed
   hull carved from the rock pixels (water palette, saturated blue and 1px
   foam lines excluded); the stack keeps a pointed row-hull silhouette and drops
   its blue-grey waterline ink. Hull stays inside the blocked 2x2; partial or
   partly walkable groups stay native. Island rim corners 17A/17C/182/184 join
   the cliff band. Art is hash-identical in all three Hoenn editions.
5. **Hoenn regional rock bands** (solid 0x07 only): Lavaridge/Jagged Pass/
   Mt. Chimney volcanic rock (lava 2BD excluded), Route 113/114 khaki
   mountain faces, Sootopolis crater and Mossdeep limestone (water edge 2E8
   excluded), primary 0xA9 rock, and one-cell round forest trees 0x16/0x17.
6. **FR/LG Mt. Ember / Kindle Road** grey mountain band (`sevii_islands_123`);
   cave mouth 0x346 and loose boulders remain native.

## Visual evidence (inspected)

All under `.scratch/gen3-20261014/`:
`rs-parity-review`, `rs-bld-review-{0,1,2}` (43 RS building placements, four
orbit views each; sheets `views/rsb-*.png`), `em-tree-edge2`/`ru-terrain2`
(conifer crown fix, Emerald vs Ruby), `em-searocks{,2,3}`, `em-cliffs`,
`sa-terrain` (Sapphire Fortree, Jagged Pass, Lilycove, Mt. Pyre, Pacifidlog,
Route 114/131, Sootopolis), `fr-ember`. Source sheets: `views/par-*.png`,
`views/b-*.png`, `views/em-gaps2.png`, `views/fr-gaps2.png`.

Early RS building eye captures were filled by the player billboard; the review
driver now steps the eye ahead of the player. Early source sheets used a
broken collision export (multi-digit codes concatenated); it was fixed and the
affected conclusions re-derived from in-engine collision.

## Limits and next targets

Single-height cliff masses do not reproduce the drawn terraces of Route 114 or
Jagged Pass; Sootopolis houses carved into the crater remain flat. Remaining
largest gaps: FR/LG Three Island Berry Forest crowns, Safari Zone broad-crown
variants (cols 0–2), Route 23 Victory Road gate building, Indigo Plateau walls,
Viridian Forest canopy 04D; Hoenn ash-covered trees (lavaridge 2C0–2CD),
Fallarbor 26D/26E canopies, Lilycove department store, Mossdeep/Verdanturf
RS homes, Rustboro RS urban set, Battle Frontier, Sky Pillar. Interiors were not
re-censused in this batch. This is representative rendered verification, not
an every-map visual sign-off or input-driven traversal test.
