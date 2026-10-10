# Optional standing trainers

`STANDING TRAINER` retains the upstream `STOCK` / `LEGENDARY` values and stock
default across generations. It never requires a companion. Gen2/3 retain their
native trainer intro; a compatible provider can keep the selected trainer on
the battlefield after that intro. No trainer model is bundled by this adapter.

Register with the existing public `characterRenderers.register` API. Existing
Gen1 providers remain Gen1-only for battle calls unless their exported spec adds
`battleGenerations = { 2, 3 }` (or the supported subset). This avoids passing a
native battle record into a renderer written for Gen1's incompatible fields.
Ordinary overworld callbacks and the Gen1 battle contract are unchanged.

The callbacks remain `drawBattleTrainer(context)` and
`drawBattleTrainerShadow(context)`; return exactly `true` after drawing.
Gen2 contexts contain `generation = 2`, the native battle, world state, shared
arena and groundY. The trainer can stand behind `arena.player`, away from
`arena.enemy`. Gen3 contexts contain `generation = 3`, native battle/state,
arena, groundY, camera, and a grounded three-component `position` behind the
player's Pokémon. Both expose `host.Voxel3D`, `host.Mat4`, `host.ShadowMap` and
the existing hand-position publication contract. Shadow callbacks may omit
hand publication. Providers own their selected asset, scale and native-state
interpretation; they must not alter simulation or native menus.

The handoff resets when disabled, in special/demo battles and on battle teardown.
STOCK, absent/incompatible providers and provider failures leave native trainer
presentation and battle UI intact. No unrelated Pokémon card is suppressed.

Validation fixtures `tools/qa/native-standing-trainer.lua` and
`tools/qa/gen2-standing-trainer.lua` register disposable public test providers
using the game's own trainer picture. These verify dispatch/placement and OFF
fallback; they do not certify a third-party full-body or 3D character asset.
