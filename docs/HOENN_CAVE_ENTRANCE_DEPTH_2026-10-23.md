# Hoenn outdoor cave entrance depth — 2026-10-23

The common two-row native cave drawing (09f/064 above0a7) previously remained a
dark horizontal floor ramp. First-person Route116 showed no standing opening.
A local rock hood now encloses an arched ceiling, side reveals and a recessed
rear. Native terrain pixels own its paint; the dark field belongs exclusively
to the rear. One threshold-colored floor replaces the dark floor projection.

This is a native-art geometry repair, **not an imported ORAS model family**.
Original ORAS Route116 GR0035/Verdanturf GR0054 source profiles were inspected
in scratch (local28.125-high entrance over18-unit surrounding terrace); actual
source-mesh/texture intake remains separate. No whole-game/model completion is
claimed.

## Contract and bounds

`Gen3HoennCaveEntrances.prepare(cells,regions)` runs after Elevation.bind and
region assignment, before Terrain.sampler. It claims exact reviewed map/cell,
pair, destination, MID/header, permissions and native neighboring blocked cells.
Unknown art, changed destinations, missing headers, mixed foundations, columns,
props, buildings and sealed native caves retain their native presentation.
Only Emerald/Ruby/Sapphire dispatch; optional companions are unnecessary.

`append(c,emit,uvFor)` follows the shared Gen3CaveEntrances callback contract:
absolute X/Z, local Y, four independent vertices/UVs per quad. Both header and
warp cells share one owner; only that owner emits. The shared dispatcher calls
`profile.append` when present. Its Terrain support flag prevents the two flat
mouth cells from pulling the neighboring rock cap down through the passage.

The repair stays inside the entrance's16x32 two-row footprint. Local front
opening21, hood25 and22 depth preserve a standing mouth above Hoenn's compact
8px surrounding masses. Perimeter samples use the existing neighboring cliff
profile. No global wall-height setting, collision, native elevation, map layout,
warp destination, passage coordinate or player movement changes. There is one
floor owner, three ceiling segments, three recessed-back segments and both side
reveals; adjacent terrain owns the outside mass seam. No overlapping boxes or
front facade card is added. Existing HD2D actor/Pokemon/flower defaults remain.

Shared Scene/Gen3Terrain hook ownership belongs to the root/Kanto worker. This
commit contains only the Hoenn adapter/test/census/QA/audit/docs. It requires the
separate shared hook integration; alone, it leaves existing behavior unchanged.

## Exact native acceptance

Official latest release checked before the batch: Gen1Recomp0.3.96, engine commit
0e92b587468c2db7c386f055fc272e6505b0f401. Isolated source engine/profiles, no
companions and fresh disposable game context; central seeds/player saves are
untouched. Exact adapter SHA-256:
`26ef0f0c32e103b2ae5d26e31afe2686f15e43bff6d72a1407e250e978380c16`.

The owned checkout's Scene was not edited. Native tests used a scratch-only
Scene/Terrain overlay implementing the agreed prepare/append/support hooks.
This proves that exact integration contract, not a released artifact.

| Edition | Actual native owners | Normal Rusturf entry+return | Map grids | Recovery |
| --- | ---: | --- | --- | ---: |
| Emerald |14/14|2D+3D PASS|unchanged|0|
| Ruby |12/12|2D+3D PASS|unchanged|0|
| Sapphire |12/12|2D+3D PASS|unchanged|0|

Common locations: Ever Grande two entrances; Routes105,106,110,111,116(two),
120,125; Sky Pillar Outside; Verdanturf. Emerald adds both Artisan Cave exteriors.
The actual on-load Regi script initially replaces its cached open art with
blocked091. The QA verifies no owner/no native-grid changes in that sealed
context, then sets the legitimate FLAG_REGI_DOORS_OPENED in memory only and
reloads for opened-state review. Production never changes story flags or opens
these entrances. Other native on-load changes settle before hash comparison.

Native/front/first/side/rear captures exist for every owner in all editions.
Inspected first/front Route116, Route106 side, opened Island Cave, Verdanturf
rotated views and neighboring source buildings/terrain. The standing arch and
visible tunnel floor/reveals replace the former dark floor ramp. Native entry
uses ordinary held input from the walkable approach, reaches Rusturf and walks
back; no destination teleport substitutes for that acceptance.

Actual emitted geometry audit passes every owner:92 triangles/mouth, zero
positive-area coplanar overlap, exactly one ground plane, three rear planes,
three sloped ceiling segments and22px recess. Focused LuaJIT cave eligibility/
geometry test and existing cave-profile regression pass; both QA drivers compile
in LuaJIT and diff whitespace passes.

Scratch evidence, excluded from Git:
`.scratch/hoenn-world-096-20261023/cave-before/hoenn-cave-before/emerald/`
contains native defect captures. `cave-after/hoenn-cave-entrances/{edition}/`
contains hoenn-cave-entrances.json (exact SHA, real owners, native hashes,
geometry and entry results), logs and all views. `cave-after/*-geometry-audit.json`
contains independent coplanar audits. Player saves were not written.

## Remaining distinct entrance families

The broader native-warp/art census reviewed29 Emerald outdoor maps and19 each
RS. This is a candidate inventory: it includes closed event-only cave warps,
underwater openings, named building false positives and Sky Pillar architecture.
It is not a count of accepted entrances. Native atlas boards remain scratch.

Still pending: Lavaridge red256/25e (Fiery Path and Emerald Magma Hideout),
Fallarbor khaki259/261 (Meteor Falls), white Sootopolis25b/221, water-facing
Scorched Slab2a7/2af, Emerald Altering Cave's shorter header, temporary Terra/
Marine cave states and underwater entrances. These must preserve their own
native thresholds, openings and water behavior. Cave interiors belong to the
interior worker; Kanto exterior mouths are a separate adapter. The next active
batch continues these distinct Hoenn entrance families.
