# Vermilion and Fuchsia original HGSS Gyms

The original regional Vermilion and Fuchsia models now replace their exact
native FRLG Gyms at (11,21) and (6,28). Complete original metatile/collision
patterns, pair, map and origin guard both placements. Fuchsia retains its
blocked header; Vermilion retains its walkable header. Native lawn1 is proven
from the original corner art, including both walkable front corners. Doors,
warps, collision and native elevation remain unchanged.

Sources are official Models Resource assets592879 (Vermilion) and592836
(Fuchsia). Archive SHA256 respectively:
`4f7e66ae8004146819eaf76ea9c204bc146b6525ea9dda535d6cd37652fcdba7`,
`04b3a7057e50d3fd9ae166bc795971971cb477897a73dcc3c16b271158073680`.
Original DAE hashes:
`9b787a457313b9c847a9c8093db25cbcda47bd9a17166bbac1764b133f5ccad7`,
`2b97cc06c29c0682dcc5f0689aaa22b1465fa317e1ac86ca93302ad6a241a6a9`.
No archive, ROM, generated native cache or capture is committed.

Each model keeps its regional paint, original paired curved doors, proportions
and source positions. Existing reviewed rear-tower UV repair and source-shadow
exclusion apply consistently to all six Gym variants. Original285 triangles
minus11 source shadow triangles plus54 closure triangles gives328 physical
triangles. Uniform native fit is79.76486 by50.53913 pixels inside112 by64,
with original door at native (56,49), measured height0.44428px. Native ground
stays fixed; only the source contact ring recesses0.05px.

The geometry audit also reproduced18 positive-area coplanar wall/skirt
intersections per existing Gym variant. Authored skirt upper endpoints now use
the measured original wall-edge heights instead of a blanket2.4 source units.
Bottom cap, original outline, source upper geometry, door anchors and PNGs
remain unchanged. Regeneration and original-source comparison prove every
original XYZ/UV/PNG unchanged except the previously declared rear UV repair;
all six variants have328 nondegenerate triangles and zero positive-area
coplanar intersections, including closed doors.

Latest official runtime rechecked0.3.96; official Linux LÖVE11.5. Both new
Gyms pass full front/side/rear/first-person/quarter native views, actual entry
and return, and real walking into both native front corners, with blocked
pillar/wall checks. All four placements pass process0. Missing-source fallback
passes Vermilion FireRed and Fuchsia LeafGreen, also entry/return and corner
walking. Existing Pewter, Viridian, Cerulean and both Saffron projections pass
final native regression in both editions (ten placements, including two
blocked no-warp projections). All source doors assert actual helper draw.
Final images and seven source angles per new model inspected. Native trees,
neighboring walls and roofs occlude some first-person side/rear views, notably
Fuchsia and Pewter/Saffron; source galleries provide their exposed geometry
review without claiming those native occlusions show hidden surfaces.

Fourteen focused Lua suites, original-source deterministic/coplanar proof,
actual FRLG native ground-atlas proof and review-history regression pass.
Both complete426-map native ledgers retain all852 native hashes. Canonical
per-edition exterior counts:136 assemblies,84 source eligible,84 rendered
accepted,52 unmatched and6232 unclassified blocked cells. Gyms are9 of11
eligible/accepted; this is not whole-game or whole-map completion.

Reproduce from the checkout (separate identities for each edition):

```sh
python3 .scratch/frlg-exteriors/api3-resume/run.py firered vermilion_gym
python3 .scratch/frlg-exteriors/api3-resume/run.py leafgreen vermilion_gym
python3 .scratch/frlg-exteriors/api3-resume/run.py firered fuchsia_gym
python3 .scratch/frlg-exteriors/api3-resume/run.py leafgreen fuchsia_gym
QA_MISSING_ASSETS=1 python3 .scratch/frlg-exteriors/api3-resume/run.py firered vermilion_gym
QA_MISSING_ASSETS=1 python3 .scratch/frlg-exteriors/api3-resume/run.py leafgreen fuchsia_gym
python3 .scratch/frlg-exteriors/api3-resume/run.py firered gyms_all
python3 .scratch/frlg-exteriors/api3-resume/run.py leafgreen gyms_all
python3 .scratch/frlg-exteriors/api3-resume/run.py firered saffron_gym
python3 .scratch/frlg-exteriors/api3-resume/run.py leafgreen saffron_gym
```

Evidence is under `.scratch/frlg-exteriors/api3-resume/out/` in the matching
family-edition directories; paired fallbacks have `-missing`. Untouched native
results and manually inspected review receipts remain separate. Full ledgers
are in `coastal-gym-ledger-{firered,leafgreen}`; source angles are in
`.scratch/frlg-exteriors/source-intake/coastal-gym-views`. Version/push/release
remain root-owned. Outdoor cave entrances are the next user priority.
