# Emerald compatibility and modeled architecture — 2026-10-04

Engine: official Gen1Recomp **0.3.51**, release commit
`a729af2364e1677222f22b1d3ba0fc6bce5c4dac`. Official `.love` SHA-256:
`a3040bc6498945933e75a3301e5c3d1cca4a771a8cddefd7dd3bb2135a3a7c00`.
Source: https://github.com/bryanthaboi/gen1recomp/releases/tag/v0.3.51
All tests used isolated Linux LÖVE profiles with freshly imported, user-owned
ROMs. No user save/options, engine production source, or map collision was edited.
Fixture scripts, logs and captures are in `.scratch/emerald-20261004` outside Git.

## Scope

- Separate native Emerald tileset recipes prevent FireRed metatile IDs from
  extruding unrelated Hoenn art. 41 Center/Mart recipes, complete native tree
  groups, and Oldale's house, Mart and Center building profiles are supplied.
- Authored structural geometry now includes recessed glazing, solid jambs,
  sills, door handles, closed roof profiles and overhangs. Oldale houses use a
  pitched roof and its Center uses a barrel profile. Existing flat-roof
  buildings keep their shape. Gen3 civic side/rear window details use closed
  geometry. Original game pixels provide the materials.
- Center healing trays, computers, cupboards and Mart stock have separate
  structural components; products have individual volumes and source crops.
  Shared Crystal and FireRed furniture improvements remain generation-scoped.
- Gen3 staged battle art uses a shared pixel pitch per sprite generation, with
  a smaller far row. Small cropped sprites are no longer independently enlarged
  to fill a 64px slot. Cards follow the actual fitted image. Gen1/2 retain their
  existing world-projected actors; Gen3 still uses native screen-space actors
  over the 3D scene. This is a sizing correction, not full camera parity.
- Wilds uses native Hoenn species IDs, and hides its catch selector during native
  battles and menus. Ride uses native Dex measurements, regional field-move
  gates, and native reverse-ledge collision checks.
- Online preserves party HP/PP on interruption with named native special calls;
  battle setup serializes the mode as the current wire schema requires.
- Doubles preserves native partner, Frontier, Tower, Hill, secret-base and
  tutorial encounter formats. Skies selects native Hoenn bird/rare species and
  avoids underwater maps. Companions remain optional independent mods.

## Evidence

Rendered captures inspected: Emerald Oldale and its Center 1F/2F/Mart in
first-person, rotating side/rear and overview; FireRed Pallet/Viridian exteriors;
LeafGreen Viridian Center 1F/2F/Mart; Crystal Cherrygrove Center/Mart; Yellow
Viridian Center. Gen2 rotating fixture angles need a corrected camera driver;
its overview/first-person captures alone are evidence. Native tile/collision
layouts remain unchanged in the room fixture.

Real Emerald runtime checks passed for ground riding, continuous flight,
dismount, native Surf and shoreline return, follower presence and mounted
suppression, native direct catching/storage, Hoenn sky species, and settings
open/adjust/persist/reopen. Five shared mod option pages were exercised; Online
retains its own connection UI.

Two independent Emerald clients on localhost exercised overworld presence,
chat exchange, remote riding/flight altitude/dismount, native single and double
battle invitations through the command phase (all four double sprites), and
native trade party selection. Disconnect restored original HP/PP. These checks
do **not** establish completed battle outcomes, completed trade exchange,
internet/NAT behavior or every-generation multiplayer parity.

LuaJIT compilation passed all 513 entry/lib/data production files. Targeted
geometry, UV/crop bounds, native species/family isolation, battle sprite identity,
animation and scale, catching, ride/network contracts and settings checks passed.
The old `gen3_intro_unit.lua` targets engine 0.3.1; its standalone mock is missing
0.3.51 ROM-text dependencies and is not claimed as passing. Current native
single/double introductions were exercised in the two-client runtime instead.

The complete engine-free repository suite reports **109 passed, 11 pre-existing
failures, 85 skipped**; the existing failure ceiling was not increased. Comparison
against starting commit `dcaf2fa` identified seven additional failures after the
upstream merge: six stale dependency fixtures and one city-ground cache ownership
regression. Those are fixed. The default Lavender material is checked against
its pre-merge UV/shading snapshot, independently of the new opt-in route paving.
All six extracted release packages also booted in Emerald, FireRed, LeafGreen,
Crystal and Yellow on 0.3.51.

## Upstreams and remaining coverage

Merged absol89/DramaticShapeVoxelMod master `303b522` (1.11.1), preserving this
fork's cross-generation adapters. Wilds upstream `e66e03d` was already present.
Skies/Doubles mirror tips only change documentation; their real source at
`shanehudson-gen1recomp-mods` `2ecf4aa` was compared with the fork. Existing newer
Gold seam fixes were retained. Ride's published upstream 0.2.18 predates this
fork's imported 0.2.19 source. All configured origins were fetched.

Emerald scenery is a **preview**, not every-map coverage. Other Hoenn regions,
full outcomes/trading, remaining settings behavior, native Gen3 actor projection
and broader Crystal/FRLG visual coverage need additional work. No claim is made
that every building, interior or tile is finished. No proprietary upscaling SDK
or frame-generation support is added by this release.
