# Bounded trees, original hedges and route gates — 2026-10-17

Version1.49.0, mesh106. Official Gen1Recomp0.3.89 was rechecked before this
batch (published2026-10-15). Native source inspection and disposable edition
profiles accompany presentation-only changes. No ROM/cache/capture/save data
ships. Actors, Pokémon and flowers remain HD-2D; every companion stays optional.

## Tree ground ownership

`Gen3TreeFootprints` separates portrait rows from physical ground. General
crowns own the blocked two-row area above/at their source root; Viridian Forest
crowns own two-row ribbons plus a proven terminal base. Cropped blocked corners
receive bounded same-family fragments. Walking crown projections cannot gain
trunks, including encounter grass permission24. Unknown editions, foreign
families, authored regional trees and claimed buildings/props stand down.
Native source IDs, collision, elevation, actors and scripts are unchanged.

Read-only native census covers six early outdoor maps per edition (30 total):
13,855 recognized blocked tree cells. Before:1,515 crown/walking-cell overlap
pairs across1,241 distinct walking cells,796 entirely uncovered blocked tree
cells. After:zero overlap pairs,zero uncovered and zero below25% canopy coverage.
Every source/permission/elevation digest matches. Kanto minimum canopy coverage
is50%; Hoenn75%. This measures modeled crowns, not an approximation using trunk
positions. Optional real replacement geometry also passes representative
Kanto/Hoenn maps (3,291 blocked tree cells); billboard alternatives have their
own yaw-radius regression instead of a misleading static-volume census.

Native/illustrated flat cards retain height/art but their horizontal radius
fits the same blocked rectangle for every yaw. Actual native-model reviews
cover Route1/Forest in FR/LG and Routes102/103 in EM/RU/SA:10 normal native
edge walks,10 tree bumps,50 orbit/eye views,10 OFF and30 actual1ST captures.
Before views reproduce walking-lane canopy occlusion; after views clear those
lanes and keep blocked forest boundaries filled.

## Original Petalburg hedges

The user's review rejected both the initial box and the subsequent tile-crop
polish. The released hedge is a purpose-built closed rounded mesh with small
continuous leaf-cluster undulations and a separate original leaf material.
Connected sections share their exposed perimeter and exact top-grid joins;
internal side walls are omitted. Top, sides and underside close within the
native blocked bounds. A five-cell L-shaped manifold regression checks every
mesh edge has exactly two owners, with finite heights and bounded UVs.

The new material follows the GBA hedge's greens, without stretching native
outlines/shadows into broad bands. Generation provenance and the final built-in
imagegen prompt are recorded in `assets/environment/README.md`. The packaged
asset loads through the public mod asset API and has no external dependency.
The source shape/permission guards retain all nine reviewed hedge drawings.

## Kanto route gates and rooms

Three complete Route2 exterior drawings per FR/LG edition: reverse blue forest
gate, forward blue gate, red east checkpoint. Closed textured roofs/sides,
native gray porch trim and real portal apertures respect the blocked footprint;
the reverse drawing includes its native apron context. Forest's partial off-map
roof remains the prior renderer and is not claimed as complete coverage.

Four interiors per edition: Route2 East Building, Route2 House, Forest North
Entrance and Forest South Entrance. Eight new verified regional placements
bring the queue to84/125, with41 still queued. Source headers, first blocked
rows, whole footer and exact fixture permissions protect custom walking lanes.
Flat continuous native wallpaper stays behind separate windows, tables and
furnishings; walkable stools remain low pads. Native plants stay HD-2D.
Source census:63 fixtures and19 low pads per edition,zero ordinary-solid walking
overlaps. Candidate native input:16 aisles,8 table bumps,14 exits total,16 OFF/
actual1ST captures. Candidate interior review:40 orbit/eye views, with separate
exterior/recess/porch checks after correcting materials and hidden joins.

## Hoenn field props

See `GEN3_EARLY_HOENN_PROPS_2026-10-17.md`:30 fixture placements and24 shoreline
corners across EM/RU/SA. Notices, timber troughs and shallow berry soil preserve
native interaction scripts and flat foliage/flowers. Complete sea-rock groups
retain their existing owner. Native input checks cover nine blocked approaches
and six normal dialogues, with24 OFF/actual1ST/dialogue captures.

## Verification and limits

Source suite:327 passed,zero failed,58 explicit unavailable-fixture skips.
Tests include source/permission standdown, closed bounded hedge topology,
per-yaw card radius, actual emitted tree crown coverage, route openings and
unchanged native field interactions. Candidate rendered captures were inspected;
QA camera overrides inspect geometry and do not prove manual keyboard play.
Final archive checks are recorded below after packaging.

This is a coherent incremental batch. Outdoor maps remain queued: Petalburg
composite canopy drawings1F2/1F3/1FC/1FD/24D/24E/255/256 are not included in the
recognized-tree census; other distinct outdoor families, gyms and Pewter Museum
interiors remain to be polished. No whole-region, ORAS-equivalence, Android,
networking or every berry-growth-state claim is made.
