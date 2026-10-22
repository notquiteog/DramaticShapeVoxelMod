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

The fixed policy fills g.grounds before any proximity selection. Nineteen
reviewed clean roof-overhang cells then retain their exact native under-atlas
MID, including Oldale Center's original dark-lawn/light-path split. Existing
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
| Oldale Mart13,3 | 001,1D1,1D2,1DA grass edges | 001 lawn; clean native header retained |
| Oldale Center5,13 | 001,1D0,1D8,1D9,1E0,1E1 grass edges | 001 body lawn; exact mixed native header retained |
| Petalburg Mart24,9 | 001,002,118,11A dirt/edge pieces | 001 lawn |
| Petalburg Center19,13 | 001,119 dirt edge | 001 lawn; clean native header retained |
| Rustboro Center15,35 | 212 lamp,2BB paving | 2BB paving; clean native header retained |
| Rustboro Mart15,42 | 212 lamp,2BB paving,309 pale road | 2BB paving; clean native header retained |
| Rustboro east tan home24,30 | 001 fallback grass | 2BB paving |
| Rustboro Gym24,15 | 001 fallback grass | 2BB paving |
| Devon7,7 | 001 fallback grass plus preserved patio | 2BB plus preserved patio |

The native contexts show lawn around the rural service buildings, and clean
paving around Rustboro's foundations. Nearby path corners, lamps or grass behind
a roof are insufficient evidence to replace those source surfaces.

### Oldale dark-lawn source proof

General0x001 is the dark lawn requested for the first Center north of
Littleroot, not the lighter surrounding path. In each imported R/S/E source,
its bottom four metatile entries are2002,2003,2003,2002 and its top four are
empty. Original Center roof tiles048/049 contain exactly those same bottom
entries beneath their roof art. Lower-left060 retains grass entries2002/2003
in its left quadrants; lower-right063 retains2003/2002 in its right quadrants.
Thus the chosen lawn is proven inside the original building drawing. No vote
from neighboring terrain is needed. Path tiles1D0/1D8/1D9/1E0/1E1 use different
bottom entries and cannot change this source-family choice.

The original right roof overhang282/283 contains a light-path background,
while the foundation/side drawing contains dark lawn. Those exact overhang
backgrounds now survive individually; the building body retains dark001.
Most body tiles already contain building pixels in their bottom entries. They
cannot simply be flattened onto the ground in pursuit of generic preservation.

Native0.3.95 already exposes the under-sprite atlas as ts.image/imageData and
the above-sprite atlas as ts.overImage/overImageData; there is no additional
underImageData field. For NORMAL roof tiles048/049, the under atlas is the clean
native lawn. COVERED tiles merge both source layers there, and wall/body bottoms
are not clean terrain. The reviewed per-family/per-cell map reuses a proven clean
source MID/layer UV, falling back to the explicit native family ground when the
original terrain is occluded. It requires the expected pair/family/lower corners,
the exact source MID at each header column and a public layered atlas. A flat
composite atlas falls back to clean family ground rather than projecting roofs
onto terrain. This adds no atlas/scene API or runtime source decoder.

| Service family | Retained clean native header MIDs | Exclusions |
| --- | --- | --- |
| Oldale Center | 048,049,282,283 | Body wall/window/foundation |
| Oldale Mart | 028,029,029 | Right285 contains tree crown |
| Petalburg Center | 048,049,04A,04B | Body wall/window/foundation |
| Petalburg Mart | None | Header contains ledge and tree foliage |
| Rustboro Center | 256,25E,25F,257 | Body wall/window/foundation |
| Rustboro Mart | 325,267,267,326 | Body wall/window/foundation |

All19 retained header positions have NORMAL source layer attributes in each
edition. Layer-only source images were inspected: these selected lower entries
contain clean lawn/path/paving, and the roof occurs solely in the upper entries.

The read-only tests/gen3_civic_native_ground_source_test.py accepts one or more
user-imported generated/gba roots and checks these exact source identities.
It passed against all three existing edition caches. The Lua regression also
surrounds each edition's Oldale Center entirely with light path-border tiles and
requires exact original header backgrounds plus dark001 under the body. It
rejects an altered body MID in the header and a missing layered-atlas split.

## Corridor and checks

The offline before/after census covers Littleroot, Route101, Oldale, Route102,
Petalburg, both Route104 segments, Petalburg Woods and Rustboro in all three
editions. Route104 is one native map: the northern shop is at3,15 and Briney's
southern house at15,47. Each edition has27 matched Civic placements across these
maps. Nine placements/195 ground MID selections per edition change; the other18
placements retain their previous correct floors. All81 original source grids
match before/after. [Per-building CSV](coverage/hoenn-civic-ground-corridor-2026-10-22.csv)
records the complete comparison. A retained clean header MID may have identical
under pixels to001 or2BB, so changed MID counts are not changed-pixel counts.

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
