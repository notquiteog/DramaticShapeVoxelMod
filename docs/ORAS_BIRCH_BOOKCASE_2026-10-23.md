# Original Birch laboratory bookcase

The complete original ORAS case replaces all twelve `birch_books` placements:
one in Birch's lab and three in Lanette's house per RSE edition. Matching
requires the original `building__lab` pair and exact six-cell drawing
`210/211,218/219,220/221`, collision rows `7/7,7/7,7/0`, with uniform renderer
height. The separate freestanding laboratory cases remain pending. Native
floor, blocked cells, walking apron, NPCs and interactions are unchanged.

Source: Alpha Sapphire ZO227 → AD114 → MM168 → GR510,
`t101r0301_00_00`. Submesh0 groups154/158/162/198/202 provide fifteen books;
submesh3 groups48/92/110/114 provide the complete outer case, twin bins and
two shelves. All selected original UV and triangle indices agree with an
independent Nitrogen decode. Original PNGs are 64×64 and 128×128. The source
is unskinned, with no selected room floor, shadow, light or unrelated objects.

The 310 original triangles are retained. Source vertex RGBA lighting is removed
from the opaque materials, including the books' original 0.772 vertex alpha;
their real colored PNG pixels and UV remain unchanged. One three-book group
moves 0.06 source units left within its original shelf. This separates five
actual original coplanar back-plane slivers between adjacent book groups.
All other original positions and source proportions remain intact.

The 102 authored triangles close exact original book rims, the case rear/base,
twin bin fronts/rears/undersides and exposed shelf undersides. Collinear rim
vertices and the original 0.0000098-unit bin underside tilt are retained.
Every book-group, outer-case and bin edge has two owners after closure. Shelf
backs and ends receive no caps: the original case already covers those planes.
Geometric clipping finds no positive-area coplanar intersections in the complete
412-triangle case or any of the fourteen imported furniture models.

Uniform fitting stays within the blocked 32×16 native row at height 32. The
original proportions give a case more than 24 pixels wide and 11 deep. Only
exact source Y0 vertices use the existing 0.025-pixel contact recess. CPU tests
prove upper vertices and X/Z remain unchanged by the recess; source bounds,
material bindings, closed rims, eligibility and atomic fallback also pass.
The importer regenerates model data, original PNGs and provenance byte-for-byte.

Official latest 0.3.95 was checked before the native batch. All twelve final
individual first-person entries and six room overviews were inspected, along
with native before-images and nine final source angles, including undersides.
All twelve placements pass missing-PNG fallback; representative fallback
overviews were inspected. Six focused suites pass. Drivers emitted PASS;
the Linux shell returned 1 at shutdown. No clean-exit or whole-room claim.

The full five-edition census retains all 2161 hashes, furniture-family counts
and earlier source candidates. Only these twelve owners are added: 2041 source
candidates and 1996 accepted components across 261 maps. Complete-map acceptance
remains false. Raw sources, native pixels, caches, profiles and captures remain
outside the repository.
