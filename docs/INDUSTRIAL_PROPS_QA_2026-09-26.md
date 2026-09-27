# Industrial props — 1.28.8

The Power Plant drum drawings previously entered the room-wall classification. Complete columns now own their caps, repeated middle pieces and final base before wall folding. Six exact recipe forms cover the native layout: 39 columns contain 66 individual closed drums in both FireRed and LeafGreen. Unsupported partial drawings retain source art instead of becoming walls. Each drum has a stepped round body, rim, lid, bung and original emblem.

The same room's 117 rubble tiles receive three unequal, closed faceted fragments per pile. They remain low (maximum four world pixels), occupy the original footprint and have no square pedestal. The existing ROCKS & PLANTS row switches them to native sprite art and back. This uses the shared rock-card path and preserves upright camera-facing behavior.

Crystal's Power Plant has 14 exact equipment-rack drawings and 12 floor cable-tray drawings. Racks now have a closed case, recessed panels, projecting controls and side vents; cables and clips stay below one world pixel. Colors and panel details come from the original atlas. Generic shelf recipes retain lower match priority. No ROM art, player data or captures are bundled.

## Validation

Engine: official Gen1Recomp 0.3.22 (latest release checked during this batch), Linux LÖVE runtime, imported Crystal/FireRed/LeafGreen/Yellow in isolated `ascendant-*-qa` profiles. Companions enabled. Player saves and normal installed carts were not changed.

Evidence root: `/home/admin/Projects/.scratch/ascendant-20260926`.

- Original map grids/art: `results/*-industrial-source/` and source crops `cr-rack`, `cr-tray`, `drum-source`, `rubble-source`.
- `plant-props-before.lua`: Power Plant `(40,8)` in FireRed and `(15,4)` in Crystal, reproducing drum walls and generic equipment shelves.
- `plant-props-after.lua` and `plant-props-final.lua`: first-person, static, side and rear captures plus Elm/Oak lab regression views. The final driver changes the actual setting-row descriptor to verify sprite/model switching; direct `setIndex` in the preliminary fixture did not request a scenery rebuild.
- `plant-props-release.lua`: packaged runtime checks in all four games, verifies selected game identity, compares native map grids before/after, and asserts 39 drum columns, 66 drums and 117 rubble piles in both FRLG editions. Uses the same views and restores modeled scenery in the disposable profiles.
- Tests: industrial full/partial/pair matching, separate drum feet/lids, bounded source sampling, low rubble and sprite fallback; 157 designed-object checks; 62 Crystal crop recipes / 36 shared furniture assemblies; lab support regression; 19 additional Gen3 drawings; cache format/storage tests; LuaJIT production compilation and whitespace checks.

These are rendered fixtures and structural checks. They are not an all-area visual certification or multiplayer gameplay test. General factory wall sections, other unreviewed equipment families, Gen3 world-space battle actors and full five-mod parity still require work. The historical coverage CSVs were not regenerated for this focused update. Mesh revision 80 invalidates older geometry.
