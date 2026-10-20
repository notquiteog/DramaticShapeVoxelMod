# Native GSC paired release particles

The original send-out smoke and shiny stars now compose into the exact paired
actor's world card. Ownership comes from Doubles' public `nativeAnimationSlot`
and the native `afterSendOut` event, not guesses from species or screen position.
The original object painter supplies its images, palettes and animation clock.
Partner palette lookup uses a detached identity view; the live battle is unchanged.

The flat particle layer is suppressed only while that same runner/event owns
a successfully published actor. Failed pair composition, missing artwork,
stale events, unavailable providers and disabled staging retain native drawing.
Canvas padding preserves particles below the visible foot without moving actors.
Single-actor Legendary release ownership is unchanged.

Official engine **0.3.91** was checked through GitHub's latest-release API before
verification. Its unmodified `.love` source ran with the existing native Linux
NVIDIA LÖVE shell; only QA support and seven independent mod symlinks were added.
Isolated Gold, Silver and Crystal QA profiles replayed original send-out scripts
on Route 29 at (10,6), facing down, with ROM art, world back sprites, paired native
HUD, voxel battle enabled, LOW distance and shadows/Legendary balls disabled.

Each edition passed:

- All four slots: original normal release **39/39** OFF/ON frames.
- Shiny enemy partner: original combined release **108/108** frames.
- Exact actor identity, unchanged HP, correct independent reveal and restoration.
- Original particle painter invoked on the owning actor canvas.

Thirty final captures were inspected. The first Crystal run exposed a duplicate
flat layer: world textures publish before the native runner advances. Suppression
now follows the published actor/event instead of requiring identical frame numbers.
Final captures show smoke/stars at their actor and no duplicated flat HUD overlay.
Evidence is in the dedicated `particles-verified-0391` scratch batch.

Four focused suites cover exact palette ownership, OFF, stale/replaced runner,
failed composition, native shiny arm, graphics restoration and canvas padding.
The option inventory remains current; no setting or default changed.

This closes original paired **release particle alignment**, not arbitrary move
animation ownership or paired Legendary Q57 deformation. GSC move scripts still
need an explicit attacker/target map. GBA's anonymous particle pool and optional
provider/asset contracts remain separate limitations. No full parity claim.
