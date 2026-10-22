# Designed one-tile Modern woodland trees

The user explicitly requested new one-tile Modern tree designs, including
geometry edits using the authentic ORAS foliage/bark style. These two compact
models replace narrow source-owned tree bodies without reducing a mature tree
to a miniature or leaving half of a blocked rectangle empty.

`ImportedCompactTreeData` derives both models from the existing genuine ORAS
Route104 broadleaf. The original texture PNGs, UVs, vertex RGBA/shade, material
metadata, all360 triangles, authored closed bark caps/backing and radial canopy
completion remain intact. Source prototypes are copied before editing. No game
sprite/ROM cache, new texture artwork or additional extracted PNG is bundled.
Provenance is in assets/scenery/compact-trees/provenance.json.

| Model | Owned footprint | Actual body X/Z | Height | Canopy bottom |
| --- | --- | --- | --- | --- |
| oras_compact_broadleaf |16×16|15.5×15.5|19.83|6.79|
| oras_compact_broadleaf_narrow |16×32|15.5×31|19.83|6.79|

The one-tile crown retains source X/Z and gains25% vertical fullness around its
original lower-foliage anchor. A small source-space lift and25% trunk-height
adjustment join the full crown to a tidy tapered trunk. Relative to a16px NPC,
it is a small tree with a13px-deep full canopy and6.8px visible lower trunk.
The longer owner uses one elongated crown, retaining the compact trunk's X/Z.
It does not add two trees for one existing owner. Quarter-turns are limited to
0/180 degrees for the longer crown. Original wide mature trees are unchanged.

Exact ordinary Hoenn round-art IDs and the existing TreeFootprints ownership
remain authoritative. Only16×16/16×32 complete blocked owners with consistent
levels, matching source family/pair and no civic/prop/custom-palette conflict
receive the new models. Every source vertex remains within that owner. No native
collision, elevation, bounds, owner references, or projected walking cap is
changed. The complete native fallback remains until the entire upload succeeds.
Special ash/sapling/evergreen/trunk sources retain their own adapters.

The reviewed boundary join permits a source owner to contain permission7 native
tree cells and explicitly generated permissionnil/forest cells. They still need
identical owner/pair/level/source family, and every member must pass the blocked
policy. A walking, water-boundary, foreign, missing or hidden cell rejects the
whole owner. This extends the first terrace/border batch's stricter join guard.

## Evidence and remaining work

Official latest0.3.95 checked2026-10-22. Isolated native R/S/E runs start Route115
at(21,76), then walk south through the real connection into Rustboro(21,4).
All three editions now report445 imported placements out of448 tree owners on
Route115 and545/548 after crossing; uploads succeed with no image failures.
The preceding focused batch reported379/471. Thus this batch replaces66/74
additional narrow/boundary owners in the corresponding render windows.

CPU source comparisons were inspected front/rear/side/quarter/under. Native
Emerald overview, first-person, side and rear views were inspected at actual
walkable Rustboro cells(37,15),(39,14),(37,12). Crowns remain volumetric from
below and their closed trunks meet local ground. Native R/S overview/crossing
captures exercise the same source guards. Model bounds, closed outer-bark
manifold edges, unchanged source texture/UV/RGBA/index arrays, native data
immutability and atomic asset failure are tested. No165FPS/mobile or complete
all-map acceptance claim is made.

The subsequent source-vocabulary batch resolves the three complete12px owners
and the actual RSE curved lower halves DE/DF/F2/F3. Source inspection corrected
the preliminary cliff-composite inference for F2/F3: those RSE tiles are pure
tree art; the numbered FRLG Viridian F2 cliff rule is a separate source family.
See HOENN_TREE_VOCABULARY_2026-10-22.md for the subsequent native counts and
remaining source-pixel limits. The445/448 figure above is the historical compact
batch result, not a claim that every source pixel was already handled.
