# Shared interior coverage checkpoint — 2026-09-26

Engine: official Gen1Recomp 0.3.20. Isolated profiles and imported user-owned ROMs in `.scratch/ascendant-20260926`; no user save/profile writes. Imported pixels and map layouts remain outside the repositories and releases.

## Changes and evidence

- All 426 FireRed and 426 LeafGreen maps inventoried: 60 tileset pairs each. Complete furniture matches increased from 1,811 objects in 98 maps to 2,087 in 146 maps. This measures source-pattern coverage, not appearance certification.
- Census now recognizes the existing complete staircase assemblies (494 placed cells) before counting unreviewed scenery. No new staircase completeness claim.
- Both editions still have 74,522 unreviewed cells and 297 unmatched building cells. Many unreviewed cells are ordinary floors; they have not been relabeled as reviewed without inspection.
- Crystal inventory spans 388 maps. Added complete common-house drawings cover 109 plants, 54 tall bookcases, 52 pictures and 63 clocks. Traditional-house models additionally cover low tables, cushions and cabinetry.
- Rendered native/orbit/first-person fixtures: S.S. Anne cabin and captain's office, Silph Co. 11F, Route 15 west gate; Crystal Bill's family's house and Violet nickname house, with neighboring player-house/lab/Center wall checks. Screenshots were inspected. Initial captures exposed ship wall gaps, wider Silph furniture layouts, a misplaced Crystal wall-row guard and original-floor slots pointing at ungenerated material pixels; those specific paths were corrected.
- Focused suites: 136 designed models; 62 Crystal source-crop recipes and 36 shared assemblies; 16 floor families; 19 prior native object recipes; 55 staircase assemblies; room bounds; 399 native option consumer checks. Changed Lua modules compile.

- Plant feedback follow-up replaces the flat diamond leaves with nine curved, closed blades and a rimmed pot. The shared model serves both later generations and keeps the optional source-art card. LeafGreen ship framing uses canonical tileset identity so it receives the ship theme, not invented house windows.

## Remaining work

Full visual sign-off for every map/tile, variable-width and specialty furniture, ship hull/deck corners, interior side-wall artwork and custom scenery consumers remain unfinished. Gen3 world-space battle actors and full Gen1 camera/effect parity remain unfinished. Gen1 is a reference, not an automatically verified flawless baseline. Five-mod multiplayer parity is not established by these scenery tests.

The Online startup asset notice was a separate companion dialogue. It now logs its diagnostic instead of obstructing the scene. Actual location banners and game dialogue remain native.

Plant option follow-up: inspected first-person front/side models and the optional native cards. Row-aware border-connected masks remove wallpaper/checkered floors, and card anchors remain at the pot. Pot body samples exclude the upper soil band. Exact archive and repinned-cart checks are recorded in the release scratch audit.
