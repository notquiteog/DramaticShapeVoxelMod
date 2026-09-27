# Starter table and industrial interiors — 1.28.7

## Changes

- Oak's FireRed/LeafGreen starter table was only 14 world pixels deep between its borders. Restore a 24-pixel top with the starter sprites centered at local depth 13. The original front-row collision, item cells and scripts stay unchanged; upright approach-row actors remain clear. The old regression expected the earlier backward-leaning actors and incorrectly enforced the half-depth table.
- Crystal Power Plant: twelve native machinery sections (six each of two drawings) use closed cases, raised cooling ribs, recessed control panels and separate brass conduits. These complete recipes take precedence over the older generic cabinet crops.
- FireRed/LeafGreen Power Plant: both complete turbine drawings use a stepped curved housing, separate feet, cooling ribs, raised vent, recessed front grille and projecting hub. Only the original grated-floor variant has the access platform.
- Mesh revision 79 invalidates older stored geometry. No imported artwork is included; colors and panel details come from each game's atlas.

## Evidence

Engine: official Gen1Recomp 0.3.20 and 0.3.22, LÖVE Linux runtime, isolated `ascendant-*-qa` profiles with existing imported ROM data; live checkout and subsequently packaged release. Companions loaded from their working repositories. No player saves modified.

Local evidence directory: `/home/admin/Projects/.scratch/ascendant-20260926`.

- `industrial-source.lua`: original Crystal/FireRed map drawings and native tile grids, used to identify complete machinery footprints.
- `lab-table-before.lua`, `lab-table-after.lua`: FireRed before/after and LeafGreen after, Oak's lab `(11,5)`, native/static/rotating/first-person views. The rotating side view reproduces the user's narrow-table defect and shows the restored top.
- `lab-table-approach.lua`: FireRed `(9,5)` verifies the upright trainer stays in front of the enlarged table. Native tile and collision grids compare unchanged before/after presentation.
- `industrial-final.lua`: Crystal Power Plant `(15,11)`, FireRed/LeafGreen Power Plant `(5,11)`, plus Elm/Oak lab regression views; overview, side, rear and first person. Initial industrial viewpoints were obstructed; the final fixture moves onto the adjacent aisle.
- `industrial-second.lua`: second LeafGreen turbine variant and lab regression. Yellow Oak lab remains on its existing model path.

Focused checks: 148 complete-object geometry/source-bound tests; Gen3 starter table/support checks; 62 Crystal crop recipes and 36 shared furniture assemblies; 19 additional Gen3 drawings; 40 cache-format and 7 cache-storage checks; LuaJIT production-file compilation and whitespace validation.

Packaged runtime check: verified the official 0.3.22 `.love` SHA-256 against its release digest, extracted it into `runtime-0.3.22/engine`, and pointed its Battle Art mod link at the release ZIP extraction. Gen3 cache version increased from 126 to 127, so the user's ROMs were re-imported into the disposable profiles through the native importer. Yellow/Crystal `industrial-0322`, FireRed `lab-table-0322` and LeafGreen `industrial-0322` all exited successfully. Inspected the latest-engine table and turbine captures. The player's normal install and saves were not modified.

These are native rendered fixtures and geometry tests, not a full starter-selection playthrough, multiplayer test or certification of every area. Industrial drums, rubble, pipes and other generic wall/equipment families still need their own review. Gen3 world-space battle actors and full five-mod parity remain unfinished. The preceding coverage CSVs describe 1.28.6 and were not regenerated for this focused change.
