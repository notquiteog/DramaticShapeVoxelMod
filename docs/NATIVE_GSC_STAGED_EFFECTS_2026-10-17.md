# GSC staged sprite state — 2026-10-17

The world cards now read original `picBoxCleared`, `isUnderground` and
`animPicState` state: native hidden/airborne actors disappear, send-out resize and
slide follow the native script, and palette shade bytes use `GbcPalette.remap`.
Native indexed pictures consume species/shiny colors; selected RGBA pictures keep
their own colors in GBC mode. Original Crystal `frontAnimFrame` timing feeds the
world card with a stable animation-wide ground anchor. Independent Crystal
providers retain priority and their supplied ground anchor.

Previously raw indexed images lost their species palette and a full-size body
could remain during native hiding/resizing. The first runtime attempt caught a
second defect: every animation initializes a normal shade byte, so declining
all shaded frames also declined every resized send-out. The final adapter reads
the original shade mapping instead. It never changes the native battle clock,
party, RNG or gameplay state. Supported Legendary capture retains exclusive
ownership of its intake body.

Focused staged-pair, native capture and native audio suites pass. Official
0.3.89 (latest checked2026-10-17), native Linux LÖVE/NVIDIA, passed the isolated
`tools/qa/native-gen2-staged-effects.lua` fixture on all three editions:

| Edition | Hidden observations | Resized world frames | Palette draws | Original animated frame reads |
| --- | ---: | ---: | ---: | ---: |
| Gold | 26 | 28 | 583 | 0 |
| Silver | 54 | 28 | 657 | 0 |
| Crystal | 54 | 28 | 657 | 62 |

Fixture: Route29 cell(10,6), down,480x432, voxel level4, distance16, shadowsOFF,
ROM art/WORLD back, Legendary ballsOFF, original audio. Cyndaquil30 versus
Sentret3; native send-out and FLY scripts, then a scoped public volatile-state
reader check followed by restoration. Native battle/party identity remains
unchanged. This is script/reader verification, not a complete two-turn FLY battle.

All15 captures were inspected: native color, hidden, resize, airborne and return
per edition. The actor is absent while hidden/airborne, small during send-out and
restored afterward; native HUD/menu/message layers remain. Evidence is in session
scratch `gen2-staged-effects-nvidia-0389/<edition>/run.log` and `contact.png`.
Earlier Crystal failed attempts were rerun after correcting shade handling;
they are not counted as successful final checks. No performance claim is made.

Lifted-row composites, substitutes, faint crops and animated doubles still use
the original native painter. Those are preserved fallbacks, not completed
world-space effects. Full Legendary release choreography remains separate.
