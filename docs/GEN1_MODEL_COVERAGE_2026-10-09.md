# Gen1 scenery audit — 2026-10-09

This is a reviewed-scene ledger, not a claim of full tile coverage.
Engine: Gen1Recomp0.3.52; isolated QA identities, user's imported ROMs.

| Scene | Evidence | Result |
| --- | --- | --- |
| Yellow Red's room | native/model at3,4 | Furniture present; no new fix in this pass |
| Yellow Celadon Mansion1F | native/model at4,7 | Interior enclosure and cabinets present; no new fix in this pass |
| Celadon Mansion rooftop, Red/Blue/Yellow | native/model at4,6 | Shed formerly a table-height slab with horizontal door; complete original tile pattern now makes a closed shed with upright door/vent and plain rear siding |
| Yellow rooftop front/rear/side | first person and rotating third person at2,8;2,3;4,6 | Closed surfaces inspected; narrow native walkways retained; source parapet retained, artificial room/ceiling removed; sky/daylight use outdoor presentation |

The shed template is map-scoped and source-complete. Partial tile patterns do
not match. Its model remains within48x64 source pixels; adjacent paths are not
claimed. Native collision, warps and movement are not modified. Shared Mansion
furniture remains on its prior models.

Evidence directories (local, not shipped):
`.scratch/coverage-20261004/results/{yellow,red,blue}-gen1-roof-audit/`,
`yellow-gen1-roof-views/`, `yellow-gen1-roof-orbit/`, `blue-gen1-roof-final/`.
Reproduction: `tools/qa/gen1-rooftop-shed.lua`; set `ROOF_ORBIT=1` for orbit.
Geometry test: `tests/gen1_rooftop_shed_test.lua`, including optional real
imported atlas via`ROOF_ATLAS` (rawRGBA fixture, never committed).

Remaining: audit other rooftop/ship-deck shared-tileset exceptions, then
unreviewed Gen1 exterior/interior families and their first-person backs/sides.
No claim is made that all existing Gen1 models are complete or polished.
