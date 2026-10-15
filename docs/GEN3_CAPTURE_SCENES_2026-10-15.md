# Native Gen3 Safari and tutorial capture presentation — 2026-10-15

The shared capture adapter now accepts the existing Safari Ball model and
native old-man, Pokedude and Wally capture sequences. These use the same public
CatchSeq.begin/reset and audio-event seams as ordinary supported balls. A visible
native trainer supplies the throw's world origin; the native trainer wind-up
still determines when the throw starts. No model, catch odds, native actor
transforms, timers, inventory, Safari counters or result callbacks are replaced.

Ghost-dodge sequences explicitly retain native trajectories: those balls never
open, so treating them as ordinary intake would be incorrect. Unsupported ball
art, doubles, nonstandard target slots, headless runs and OFF retain native
presentation. Missing/failed props or optional audio retain native fallback.

The shared BattleScene capture entry points also defer GB terrain dependencies
on Gen3. Previously first capture unnecessarily imported legacy Map consumers
and logged an unsupported facade on Hoenn. Gen1/Gen2 eager initialization remains
unchanged; the native prop/FX path no longer requests those terrain modules.

## Validation

Official engine **0.3.89** and its matching Linux native shell, latest release
rechecked by the parent. Production engine files are unmodified. Public test
support is from 0.3.88 because the official 0.3.89 package omits its test harness.

- Focused capture contracts cover native event ordering, native return/state
  identity, zero-shake breakout, click, trainer origin, Safari/tutorial contexts,
  reset, OFF, ghost/headless/unsupported-target fallback, failed props and
  optional sound success/failure with the native master volume.
- A new dependency guard rejects GB terrain imports during native ball creation
  and checks legacy eager initialization. Existing legacy scene sidecar/model
  shadow checks pass **37** checks.
- Broad final source suite: **296 passed, 0 failed, 58 skipped** for missing
  external datasets/fixtures, including SDK **1173/1173**. Inventory consumer
  checks **549** and generated inventory consistency pass.
- Native Safari capture fixtures pass in **FR/LG/Ru/Sa/E**: native balls30→29,
  exactly one caught Pokemon stored, ordinary bag unchanged, reset clean.
  FireRed OFF passes with zero shared prop draws and identical native results.
- FireRed old-man and Emerald Wally capture paths pass with original trainer
  animation and no stored Pokemon or ordinary bag consumption. Wally is staged
  at his trainer-return command; his original return/throw setup runs, while
  preliminary attacks are outside this fixture.
- FireRed Pokedude capture-only sequence passes using the original ready battle
  scene and public CatchSeq.begin. Its native no-storage result and bag identity
  remain unchanged; the interactive Teachy TV lesson itself is not covered.
- Captures inspected across Kanto and Hoenn show the original trainers, shared
  ball, native messages and results. The OFF capture retains the native ball.
- Ruby Safari rerun and Emerald Wally final runs confirm the deferred-import
  path no longer logs an unsupported legacy Map dependency.

Driver: `tools/qa/native-gen3-capture-scenes.lua`. Evidence in workspace scratch
`.scratch/voxel-parity-20261015/capture-scenes-0389/`, per-game/scenario logs and
`capture-{12,45,110,260}.png`, `result.png`. Isolated imported QA profiles,
480x320, native Pallet/Littleroot cell7,8 down, staged battle, LOW distance,
shadows OFF, no save writes. These are capture checks in disposable outdoor
scenes, not Safari landscape/location verification or full tutorial playthroughs.

Source-suite log: `.scratch/voxel-parity-20261015/suite-capture-scenes-final.log`.
Initial Ruby fixture omitted native playerName, and the initial interactive
Pokedude fixture did not reach capture within its bound; neither is accepted as
final evidence. Image review also rejected fixtures that skipped Wally's
trainer-return setup or left the Pokedude command menu visible; both were
corrected and their final captures inspected. Pokedude capture-only verification is recorded separately from
Teachy TV's full interactive lesson.

## Remaining scope

The ball library has no native Net/Dive/Nest/Repeat/Timer/Luxury/Premier model
variants, so these retain their original artwork rather than silently using a
plain Poke Ball. Doubles/other targets and ghost-dodge preserve native drawing.
Gen2 tutorials and Bug-Catching Contest still have separate native ownership.
Full send-out/recall effects, broader actor material effects and optional audio
coverage remain partial. Audio assets are independently supplied, not bundled.
Regional backdrop/boss artwork/routing, Gen2 indexed Oak reveal/title-specific
art and general terrain cache controls remain separate remaining consumers.
Modern semantic-card palettes belong to the independent UI provider equally
across generations. Model-family work remains separately owned. This batch
makes no full parity claim, model edits, version bump, release or push.
