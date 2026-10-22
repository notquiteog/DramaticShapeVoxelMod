# Crystal animation while choosing a double-battle target

Gen 1 Doubles paused `BattleState.update` in its target/switch prompts, also
pausing the integrated Crystal sprite update. Battle Art now exports the
optional `updateBattlePresentation(battle, dt)` callback. Doubles calls it only
in those custom phases. It refreshes allied and opponent frames without
running native input, battle turns, move/reveal timing or audio. The native
phase update continues to own ordinary phases; GSC's draw-time provider is
unchanged. Neither mod requires the other.

Official Gen1Recomp 0.3.95 (latest checked October 22), LÖVE 11.5 Linux shell
from the 0.3.89 AppImage, NVIDIA native rendered verification: isolated Yellow
Route 1 fixture with Pikachu/Bulbasaur versus Spearow/Zubat. Disabling the new
callback reproduced all four sprites freezing for 120 ticks. Restoring it
advanced all four sprite identities over 180 ticks while `db_target` stayed
active. The same checks passed in `db_switch_target`. Before/after target and
switch screenshots were inspected: full-body allied backs and Crystal foe
fronts animate. The original report did not identify game/style; this confirms
the target-prompt freeze, not an allied-only defect in every engine or pack.

`tests/crystal_target_driver.lua` is the native fixture. The independent Doubles
presentation test covers phase gating, alias deduplication and absent/failing
providers. The existing GSC paired-picture regression passes unchanged.
Physical mobile platforms have not been verified.
