# Gen3 urban buildings and field props — 2026-10-15

This is an incremental batch, not complete five-game asset coverage. Native
source art was inspected before authoring. Characters, Pokémon and flowers
retain their HD-2D paths. No gameplay, collision, warp, UI or dependency changes.

## Authored coverage

| Edition | Added model placements | New source families |
| --- | ---: | --- |
| FireRed | 58 | Route 23 stone bollard |
| LeafGreen | 58 | Route 23 stone bollard |
| Emerald | 84 | Brown field boulder |
| Ruby | 73 | 65 boulders + 8 urban buildings across 7 families |
| Sapphire | 73 | 65 boulders + 8 urban buildings across 7 families |

Total: 346 model placements, 800 previously unclaimed blocked source cells.
These are placement counts, not 346 individually authored meshes. Source census
includes native-map placements outside the representative rendered scenes.

Rustboro tan small/wide/east/south and white small/tall/thin families match the
complete native drawing in RS. Square recessed glazing preserves the original
horizontal reflection bands; it does not inherit Emerald's arches or mullions.
Facade window counts and door openings retain native placement. Side/rear window
placement is an architectural interpretation using the same native sash and
masonry. Roof decks, parapets, plinths and chimney wells have closed faces.
All RS urban volumes fit inside the native blocked rectangle after its projected
rear row. Altered third-party walking lanes veto the whole assembly; only the
explicit final-row native door ID may retain permission 0x71.

Route 23 bollards use a continuous closed octagonal profile with plinth, shoulder
and pale crown, including the underside; stone is non-emissive. Width/depth14px
within the original 16px solid tile. Nearby reviewed native flat ground votes
select paving or grass beneath the model; source paving is the fallback.

Hoenn primary 0x0E0 is the inspected brown field boulder, independently checked
against RS pixels. Only permission7 copies rise. The existing native-pixel rock
hull excludes the grass palette and closes its sides/back/underside. Embedded
cliff/sand variants 0x0E1/0x0E2 are held for separate contextual treatment.
The existing optional flat-prop presentation remains available. Mesh revision88.

## Runtime and fixtures

Latest official Gen1Recomp release was checked before this batch: 0.3.88,
published 2026-10-14. Used its bundled Linux LÖVE executable and matching official
.love/source helpers under `/home/admin/Projects/.scratch/runtime-0.3.88/`.
NVIDIA RTX5060Ti / Xvfb, 1280x720 rendered scene captures. The five private native
imports from 0.3.86 were reused; these are not fresh 0.3.88 import tests.

Scratch evidence root: `/home/admin/Projects/.scratch/gen3-20261015b/`.
Disposable `gen3-<edition>-qa` identities; no normal player saves used. QA maps
load through public APIs; input-driven door tests enter via native movement.

- Source: `ruby/emerald-urban-windows.png`, each `*-rustboro_*.png`,
  `route23-grid.png`, `firered-posts.png`, `emerald/ruby-boulders.png`.
- Before: `urban-before/`, `fr-posts-before/`, `em-boulder-before/`.
- RS after: `ruby-urban-after/` (7 spots, 35 captures),
  `sapphire-urban-after/` (4 spots, 20 captures). Four cardinal orbit views and
  low eye views inspected; long facades/roofs/rear lanes and neighboring native
  buildings retained. Some eye views contain a native NPC/player foreground.
- FR/LG after: `fr-posts-after/`, `lg-posts-after/` at Route23(10,10), radius7;
  source walkway remains visible between posts in orbit and eye views.
- RSE after: `em-models-after/`, `ru-boulder-after/`, `sa-boulder-after/` at
  Route123(45,9). Initial eye views were obscured by nearby trees; clean close
  eye review uses `em/ru/sa-boulder-eye/` at (44,3), native approach(44,5).
- Emerald urban regression: `em-models-after/EM_RUSTBORO_CITY_11_37_*` retains
  Emerald native arched panes and distinct roof texture.
- Seven-mod Sapphire smoke: `allmods-sapphire/` shows the new urban family and
  field boulders with all six optional partners loaded. At that run the manifests
  still read Battle Art1.35.0 / Online0.11.0; it exercised this batch's runtime
  code before metadata bumps. The other five partner versions match releases.

`tools/qa/gen3-urban-doors.lua`: actual native up input from seven Rustboro
approaches per RS edition, including both white-small placements. All fourteen
reach the expected native interiors, retain camera3, and report no camera
recovery failures. Captures/logs: `ru-doors/`, `sa-doors/`. Restricted renderer
processes reported exit1 after all PASS markers with no Lua error; an unrestricted
Route23 repeat (`fr-final-unrestricted/`) exited0. Final unrestricted door and
exact-package verification are recorded in the release workflow evidence.

## Checks and limits

277 Lua suites pass, 0 fail, 58 external-fixture skips (`suite-final.log`).
New/extended tests cover manifold bollard closure, non-emissive stone, tile bounds,
local ground selection, permission/edition veto, RS square apertures, front pane
counts, roof undersides, native doors and unchanged Emerald geometry.

Native recognized-building footprint census: RS73 assemblies each, zero flags
(`ru-footprint/`, `sa-footprint/`). This audits low face bounding boxes against
the central8x8 of permission0 walking cells; it is not a full collision or warp
proof. Exact recipe permission guards and native door tests add separate evidence.

Outdoor gap census after this batch:

| Edition | Before | After |
| --- | ---: | ---: |
| FireRed / LeafGreen (each) | 6,649 | 6,591 |
| Emerald | 11,770 | 11,686 |
| Ruby / Sapphire (each) | 10,481 | 10,181 |

Gap counts are unclaimed blocked cells, not remaining object counts; they include
composites and decorative/flat surfaces. Every map is not visually signed off.
Next queues include FRLG Route23 architectural wings / Indigo Plateau, Hoenn
Lilycove department store, RS Devon/Space Center, partial sea-stack/rock bands,
regional props and the interior-family census. No WAN, mobile, controller or
complete ecosystem multiplayer certification is claimed by scenery captures.

All companion integrations remain optional public-provider paths. Existing native
UI ownership and extension/fallback behavior remain unchanged. No private art,
ROMs, generated caches or QA captures are committed or packaged.
