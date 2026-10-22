# Native Civic ground along Littleroot–Rustboro — 2026-10-22

The previous Civic ground preparation copied the nearest walkable flat tile into
each building cell. Center/Mart recipes accepted every flat tile, including road
edges and decorative graphics. Thus a single building could receive a patchwork
of incompatible ground. In Rustboro, the Center and Mart even selected0x212,
the native street-lamp graphic, as under-building ground.

The correction uses the inspected native drawing's ground identity for the24
Civic families along this corridor. Selection requires the exact tileset pair,
RSE family/name and the actual native lower-left/right corner IDs. Rural lawns
use native0x001; Rustboro buildings use native clean0x2BB paving. These IDs refer
to the active edition's atlas, so RS keeps its own paving/grass pixels.
Route104 shares general__rustboro with Rustboro itself; its two source houses
explicitly keep lawn rather than inheriting urban paving from the pair.

The fixed policy fills g.grounds before any proximity selection. Existing
M.ground priority is unchanged: explicit groundPreserve cells, native lawn,
explicit recipe ground and preserveWalkableFloor still override that field.
In particular, Devon's original walking/front-floor0x2C3/0x2C4 tiles survive.
Unknown labels, foreign pairs/editions and nonmatching corner drawings keep
the previous fallback; the change does not infer a new floor for unknown art.
Stairs continue through their existing earlier render branch. Original native
metatiles, permissions, elevation, source shapes, doors and warps are not edited.

## Inspected source cases

Native primary/secondary tiles and composed map crops were reconstructed from
the existing imported R/S/E cache and inspected. Exact source examples:

| Location / building origin | Previous ground IDs | Correct underlay |
| --- | --- | --- |
| Oldale Mart13,3 | 001,1D1,1D2,1DA grass edges | 001 lawn |
| Oldale Center5,13 | 001,1D0,1D8,1D9,1E0,1E1 grass edges | 001 lawn |
| Petalburg Mart24,9 | 001,002,118,11A dirt/edge pieces | 001 lawn |
| Petalburg Center19,13 | 001,119 dirt edge | 001 lawn |
| Rustboro Center15,35 | 212 lamp,2BB paving | 2BB paving |
| Rustboro Mart15,42 | 212 lamp,2BB paving,309 pale road | 2BB paving |
| Rustboro east tan home24,30 | 001 fallback grass | 2BB paving |
| Rustboro Gym24,15 | 001 fallback grass | 2BB paving |
| Devon7,7 | 001 fallback grass plus preserved patio | 2BB plus preserved patio |

The native contexts show lawn around the rural service buildings, and clean
paving around Rustboro's foundations. Nearby path corners, lamps or grass behind
a roof are insufficient evidence to replace those source surfaces.

## Corridor and checks

The offline before/after census covers Littleroot, Route101, Oldale, Route102,
Petalburg, both Route104 segments, Petalburg Woods and Rustboro in all three
editions. Route104 is one native map: the northern shop is at3,15 and Briney's
southern house at15,47. Each edition has27 matched Civic placements across these
maps. Nine placements/184 under-building cells per edition change; the other18
placements retain their previous correct floors. All81 original source grids
match before/after. [Per-building CSV](coverage/hoenn-civic-ground-corridor-2026-10-22.csv)
records the complete comparison.

Routes101/102 and Petalburg Woods contain no matched Civic building in this
census, so their ground remains native. Standalone signs use a different shape/
scenery path; they are outside this Civic fix. Corridor model coverage still
mixes imported ORAS buildings and existing native-art building kits. Correcting
these floors is independent of finishing every modern model family.

Passed:72 family/edition mocked fixtures, lower-corner source identity guards,
Route104/Rustboro shared-pair separation, original metatile/permission/base/shape
preservation, explicit ground/water and source-floor overrides, unknown-family
fallback, existing Civic material/geometry tests, Rustboro urban variants,
Devon and Cinnabar laboratory regressions. Native R/S/E cache census also ran
against before/after code; this is CPU evidence, with terrain bases set to zero
and without streamed boundaries or GPU rendering. Native0.3.95 rendered
acceptance remains parent QA.

Suggested captures: Oldale Center and Mart at35° and eye level, Petalburg Mart's
dirt approach/nearby water, Rustboro Center/Mart beside their real lamps, east
tan home's grassy rear and paved front, Gym and Devon porch/doors. Include
Route104 grass and an unrelated indoor room. Check native tile/permission hashes
and walking through each original warp. Scratch source crops/census intermediates
stay outside Git; no native pixels or source cache files ship in the commit.
