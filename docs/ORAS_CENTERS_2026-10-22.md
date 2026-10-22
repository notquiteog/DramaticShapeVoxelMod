# ORAS Centers in Ruby, Sapphire and Emerald — 2026-10-22

Version1.56.0 adds actual native placements for the existing closed ORAS Center
catalog model. This batch covers exteriors only. It does not claim completion of
the eleven-game building/interior queue or the three-mode category settings.

## Source and adaptation

[ORAS Pokémon Center, asset292908](https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/292908/),
Fallenleader/RSRazr, originally Nintendo/Creatures/GAME FREAK. Archive/model/PNG
hashes and the earlier authored rear/underside closures are recorded in
`assets/scenery/catalog/oras_pokemon_center/provenance.json`. No raw archives,
ROMs, captures or caches are distributed in this change.

The native Hoenn drawing spans4×4 cells, with its door in column2. The imported
source has a centered entrance. `Gen3ImportedCenters` derives a separate regional
variant: its arched entrance and badge band translate left together, the right
screen stays rigid and adjoining wall/roof spans change length. X knot pairs:
`-.5→-.5, -.22→-.345, .22→.095, .24→.24, .5→.5`. UVs, materials, topology,
Y/Z and the original catalog definition are retained. Uniform final fitting aligns
the authored door anchor with the original warp cell; it leaves0.25px padding
inside the64×48px body rectangle. No geometry enters the rear drawing row.

Eligibility requires a recognized Hoenn4×4 Center, complete same-owner cells,
known uniform rear permission0/7/41, blocked body permission7 with the original
113 door, equal ground bases and no hidden/boundary cells. Unknown/custom
footprints retain the previous native model. Missing textures or failed mesh
uploads also retain it and unwind only their own partial resources. Existing
Legendary building providers retain priority. All resources use the scene-owned
scenery lifecycle. The native door animation projects inside the imported arch;
metatiles, warps, collision, UI and actors are not rewritten. No companion mod is
required. Existing public scenery registration remains available to third parties.

## Native verification

Latest official engine checked onOctober22: Gen1Recomp0.3.95, published
October21 at02:42:51UTC. Official Linux AppImage and matching `.love` both pass
publisher SHA256 checks. Untouched extracted engine; native LÖVE11.5,
OpenGL3.3/NVIDIA615.71.09 on RTX5060Ti. Only Battle Art enabled. Disposable
per-edition data roots import the user's existing R/S/E archives; no player save
or options changed. Test fixtures start a new game and reposition through public
map/player APIs. Source is the isolated resource-models worktree based on
742f1bf, then fast-forwarded through concurrent3e10a24 (XD tooling only).

| Maps | Ruby | Sapphire | Emerald |
| --- | ---: | ---: | ---: |
| Oldale, Petalburg, Rustboro, Dewford, Slateport, Mauville, Verdanturf, Fallarbor, Lavaridge, Fortree, Lilycove, Mossdeep, Sootopolis, Pacifidlog, Ever Grande |15|15|15|
| Battle Frontier Outside East |—|—|1|

All46 placements pass renderer/stream completion and exact before/after native
metatile/collision/elevation hashes; their front captures were inspected. Oldale
in each edition additionally passes actual blocked-side input and the original
warp into its Pokémon Center. First-person front, both sides, rear, real native
door animation and destination interior were captured and inspected in all3
editions (18 additional final images). Closed sides/rear, original display, entry
alignment and nearby ground remain intact. Emerald also passes inspected missing-
texture native-model fallback and ordinary flat2D rendering. The initial roof-ID
scan missed custom roof patterns; final fixtures match complete native drawings.

Evidence directory: `/home/admin/Projects/.scratch/centers-20261022/`.
`final.lua` plus `run.sh` drive the three editions; final outputs are
`final-ruby`, `final-sapphire`, `final2-emerald` and `fallback-emerald`.
View cells are derived from the matched roof origin `(cx,cy)`: front/first
`(cx+1,cy+6)`, sides `(cx-2,cy+2)/(cx+5,cy+2)`, rear `(cx+2,cy-2)`.
35-degree front, 1ST/8-degree pitch for side/rear/first views, day and16-cell
render distance; QA-only haze disabled. No protected engine callback is replaced.
Drivers reuse the historical0.3.91 test-only helper; the running engine is0.3.95.
All owned QA processes terminate; unrelated user runtime untouched.

Concurrent XD conversion/preparation:12 Python tests pass.

Source suite:374 pass,0 fail,58 explicit external-data skips. The0.3.95 engine
modules use historical test bootstrap helpers from the prior QA harness; the
first run lacked `tests.harness` and those23 missing-helper failures were rerun
with that harness restored. Center guard/fit/immutability/fallback and catalog
resource lifecycle tests pass. Changed Lua files compile with LuaJIT. Native
GPU tests, not the mocked suite, establish0.3.95 rendering evidence. Physical
phones, other companions and every dynamic gameplay state remain unverified.

Remaining work: imported interiors; matching Kanto/Johto building adapters;
Hoenn houses, shops, labs, gyms, landmarks and route props; additional trees and
per-category Modern3D / sprite-accurate / HD2D settings. Native existing scenery
continues to cover these until each imported source is reviewed and fitted.
