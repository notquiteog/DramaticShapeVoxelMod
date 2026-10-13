# FRLG service façade correction — 2026-10-13

Reported Viridian Center `(24,22)` and Mart `(34,16)` night captures showed
native projected corner strips bent again in 3D, and MART lettering cut at the
old vestibule boundary. Original LeafGreen map art was exported and inspected
before edits. Native Hoenn Rustboro art was also inspected: its MART label is
already a single right-hand panel in `HoennCivicBuilding`; no equivalent fix
was needed there.

Standard Kanto service façades now crop away the projected outer strips and
meet straight, closed side walls. The Mart lower façade remains on one front
plane, its badge has a separate source crop, and animation uses the same lower
door height. The roof atlas restores paint behind the separate badges. Generic
native paving `0x16E` is preferred beneath these buildings only when found in
nearby walkable cells of the same tileset pair. Special/custom service recipes
retain their existing geometry; they are not covered by this visual sign-off.

Evidence uses official engine `0.3.85` and its extracted Linux LÖVE executable,
private `gen3-leafgreen-qa` / `gen3-firered-qa` profiles under
`.scratch/gen3-20261013/profiles`. Latest-release recheck was attempted but DNS
and web access failed; this report asserts the exact runtime, not latest status.
Player saves, collision, warps, and source map data were not changed.

Scratch root: `/home/admin/Projects/.scratch/building-form-20261013`.

- Native source: `kanto-source/FR_VIRIDIAN_CITY.png`, source driver
  `kanto-source.lua`; Hoenn reference `source/EM_RUSTBORO_CITY.png`.
- Before: `leafgreen-night/FR_VIRIDIAN_CITY_{24_22,34_16}_night.png`.
- Final LeafGreen: `service-final`, driver `kanto-night.lua`.
- Final FireRed: `service-final-fr`, driver `service-fr-review.lua`; eye camera
  moves farther right to expose the complete front and side together.
- Both editions emitted front/right/back/left, eye, day/night and scripted
  door animation frames. Inspected both buildings' day eye views, LeafGreen
  Mart front and Center right, plus FireRed Mart and Center front/right eye.
  These show the coherent word, clean wall sides and paving beneath the shell.
- Focused LuaJIT checks: `gen3_civic_test.lua`,
  `gen3_service_facade_test.lua`, and `gen3_hoenn_test.lua` pass.
- Strict footprint driver: `service-footprint.lua`, low faces checked against
  native full cell interiors, excluding a 0.1px border. LeafGreen: two models,
  zero walkable overlaps. FireRed: two models, zero walkable overlaps,
  recorded in `service-footprint-fr`.

The two render logs reach the explicit two-building/eight-orbit-view PASS,
although the shell returns status 1 during shutdown without a driver error;
this is recorded rather than labeling the process exit clean. UI/player and
wild-sky sprites remain in captures. Existing crosshatching on window pixels
and striped shadows remain separate renderer issues; they are not a service
geometry pass claim. No normal controller-driven door traversal was tested.
