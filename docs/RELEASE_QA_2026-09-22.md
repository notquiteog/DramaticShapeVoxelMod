# Published cart test.11 verification — 2026-09-22

Official Gen1Recomp 0.3.1, checked against the latest official release. Tests used disposable profiles and exact published archives; no user saves or live profiles were changed. Published GitHub asset digests, local archive hashes, release tags and all cart pins matched.

## Presentation fixes

- FireRed actor contact: inspected matching noon and low-moon captures before/after. HGSS Bulbasaur uses one animation-union foot baseline and actor shadows meet the ground. An explicit raised actor remains raised. This is a stationary provider fixture, not exhaustive follower/ride traversal.
- Oak's lab: eight approach views show the table clear of player/rival bodies; reverse views confirm the starter-ball baseline correction.
- Pewter gym: three views show disconnected floor stripes/grit no longer form floating rock caps.
- Caves: fifteen views across five native palettes inspected with layout/collision integrity checks. This does not certify every map or viewing position.
- Museum: exact test.11 rotating/first-person views confirm counter tile 0x2AC no longer becomes a wall. The counter remains flat native artwork pending a complete model.

## Battle animation and doubles

Exact BAV 1.23.0-test.11 and Double Battles 0.12.0-test.5 passed FireRed and LeafGreen singles/doubles presentation fixtures. Both enemies change actual picture pixels between captured frames; all four battlers remain visible at the command menu and after 180 further frames. Same-species normal/shiny Rattata retain distinct palettes. All eight A/B captures were inspected. Return uses native abort('run'); this fixture is not a full combat or multiplayer-completion test.

A separate FireRed native-authored trainer double, outside the mod-owned wild intro, reached commands with all four visible and returned to the field. Its initial short fixture timeout was extended for normal intro/startfx duration without source changes.

The asset audit covers all 772 BW front atlases (normal/shiny dex 1–386), including hashes, dimensions and timings. Runtime animation fixtures cover representative Rattata art, not every species.

## Carts and integrations

All final carts booted with exact pins and option defaults: Yellow seven mods, Crystal seven, FireRed six. Settings rows and basic field boot passed. Previous exact test.10 carts also passed lab/Mart transitions. Earlier published package checks covered two-endpoint FireRed/Crystal doubles, FireRed trading, FireRed/LeafGreen riding, and host-owned ground/sky encounter flows; those broader flows were not rerun after the museum/intro-only patch.

## Remaining limitations

Full tile and settings parity remains unfinished. The 388 Crystal / 425 FireRed map census is classification evidence, not a visual certification. Museum counters/exhibits and some machine/table/plant drawings still lack complete models. Gen3 public music registration is blocked by the engine's schema; Ride's own local catalog remains available. Exhaustive multiplayer move/disconnect cases and all follower/flight states remain unverified. Crystal still logs a brief spawn-reveal nil-pose warning in the isolated cart fixture.

## Local evidence

- `/tmp/parity-20260922/test10/results/`: actor, lab, gym and cave captures.
- `/tmp/parity-20260922/test11/results/museum/`: counter views and inspection.json.
- `/tmp/full-parity-20260922/qa/native-front-test11-{firered,leafgreen}/`: native single/double captures and logs.
- `/tmp/full-parity-20260922/{crystal,yellow,firered}-cart11-boot.log`: final cart pin/default checks.
- `/tmp/full-parity-20260922/published-audit.json`: published artifact and tag audit.
