# Original-art presentation (unreleased)

Gen 2 and Gen 3 default to ORIGINAL GAME tree art. ILLUSTRATED selects the
previous replacement family. TREE TRUNKS offers flat 2.5D or modeled stems.
Cards retain their static angle in fixed views and face free/battle cameras.
Native fruit trees retain their original actor art with the original setting.
Boundary trees use the same source provider, palette and material as map trees.

Crystal complete-building roofs now retain the actual cap/edge source tiles
and project beyond walls. Pitched roofs, FireRed/LeafGreen column roofs, and
reviewed civic buildings receive closed eave undersides and fascia. Flat roofs
remain flat; towers retain their separate silhouette. No gameplay cells change.

Gen 3 recipes resolve edition-specific tileset names through public map
identities. This enables LeafGreen to reuse reviewed FRLG building families
without treating ROM addresses as interchangeable. Runtime assets always come
from the selected game. LeafGreen and FireRed were booted on 0.3.0 using the user’s local imports.
Original trees assemble complete canopy/crown/root drawings, not the cropped
border-overlap tiles. Ground speckles and baked shadow ovals are excluded;
the lowest opaque trunk pixel rests on the ground. No generated replacement
image or imported game pixels are distributed.

The test baseline is the upstream 0.3.0 release. This is not a claim that every
map or object is finished: unreviewed specialty interiors, caves, and drawings
still retain their native fallback. Exhaustive coverage remains open alongside
the five-mod multiplayer and Ride port matrix.

Oak’s lab now has a round machine with a native-art red platen, blue drum,
silver rim, control panel and feet. The Pokédex desk has a separate tabletop,
frame, four legs and drawer. Stationary Pokédex/Poké Ball objects receive
presentation-only furniture support; NPC positions and interactions stay native.
A continuous back wall, mounted displays, full bookshelf claims and masked pot
plants remove floor artwork from upright geometry.

The native Gen 3 OPTIONS menu exposes Battle Art’s own page. Wilds and Double
Battles ship their own independent adapters. Gen 1/2 keep their existing menus;
Double Battles and Ride now register their previously absent in-game rows.
All persistent keys are unchanged. Tested native page changes/reopening on
Yellow, Crystal, FireRed and LeafGreen, with settings events reaching the renderer.
