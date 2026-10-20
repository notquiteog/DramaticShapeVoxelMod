# Camera controls and third-person framing — 2026-10-17

Runtime: latest official Gen1Recomp **0.3.89**, native Linux/NVIDIA, isolated
`native-options-*-qa` identities. No normal saves or engine callbacks changed.

## Implemented

- Gen3 first-person/rotating third-person now use the Gen1 look response,
  sensitivity and vertical range. The orbit pitches around the actor instead of
  leaving a fixed-height eye behind while only tilting its aim. Eye height uses
  the sprite's existing foot/eye metadata; terrain and riding lift are retained.
- Gen3 boom checks native occupancy in the current and connected maps, retracts
  immediately and recovers gradually. It retains 48px of third-person framing
  when a nearby wall/crown would otherwise collapse the view into the actor.
  Existing continuous scenery cutaway clears foreground geometry while retaining
  supporting ground and drawing actors/UI outside that scope. No per-frame mesh
  rebuild or shader change was introduced.
- Right-stick state clears when its controller disconnects or the window loses
  focus across all three generations. A stalled update cannot rotate a full
  frame's unbounded delta. Native menus retain their input; dialogue retains look.
- Gen3 gains touch drag/pinch through public LOVE touch polling (0.3.89 does not
  dispatch `input.pointer` for native touch). Native touch buttons retain their
  contacts; pinch does not simultaneously rotate, and mode/menu changes reseat
  contacts. Battle look pauses over menus; battle stick pitch matches Gen1.

## Evidence

Initial native mode sweep passed Red/Blue/Yellow, Gold/Silver/Crystal,
FireRed/LeafGreen/Ruby/Sapphire/Emerald: 35°,15°,50°,75°,1ST,rotating3RD,OFF;
right stick, dialogue look, focus loss and controller disconnect. Gen3 public
synthetic touch drag/pinch also passed. Thirty-three representative captures were
inspected. Additional FULL→OFF checks passed all11 editions; all11 FULL captures
were inspected (`full-*`, `full-review.png`). The reusable public-driver fixture
is `tools/qa/native-camera-modes.lua`.

Actual running connections and battle entry/menu/return passed all five GBA
editions: Route1→Viridian in FR/LG; Route104→Rustboro in R/S; Route104→Petalburg
in Emerald. Fifteen after/battle/return captures inspected. The Emerald boundary
initially collapsed the boom to19.75px and hid the actor behind a canopy-filled
view; the framing/cutaway fix visibly retains the actor and city. Battle tests
use deterministic foreground focus and synthetic public gamepad events.

Artifacts: `../.scratch/camera-polish-20261017/` (`final-*`, `connection-*`,
`connection-review.png`, generation contact sheets; driver scripts beside them).
Native command uses `../.scratch/gpu-perf-20261015/run-desktop.sh` with edition,
absolute driver/output/profile paths and isolated QA identity.

Ten focused suites pass: shared look/touch, Gen3 rig/controls, first-person stick
claim/inversion, eye anchor, Gen2 walk, transition gate, Gen3 field effects and
Gen3 adapter. The shared broad suite was329 pass/0 fail/58 fixture skips after
the new headless graphics guard was corrected and its adapter rerun passed.

## Limits

This is desktop native integration evidence, not physical Android touch/gamepad
certification or an exhaustive visual audit of every camera angle in every map.
Native HUDs can still overlap large battle sprites during some orbits; this
batch preserves native UI ownership. Source models and their map placement are
unchanged. Performance timing was not benchmarked during these camera checks.

## Native GSC doubles follow-up

The generic modern/pair lens widening compressed both teams into the middle,
behind the stacked native doubles HUD. Doubles now optionally advertises its
native scene layout through a public method; the staged texture descriptor carries
that identifier. A camera preset solved for that layout places the pair foot
centres at(40,88)/(120,40) in the native160x144 frame, with36/32px per-actor
spans. The nearer cards stay above the native command panel at y96. Source
world scale and native UI are unchanged. Modern/other provider layouts and
external cinematic cameras retain their existing framing; user orbit/zoom remain
available and can intentionally move cards beneath the fixed native HUD.

Native0.3.89 all-seven-mod Gold/Silver/Crystal fixtures each pass four actor
identities and queued replacement identity. The six native/shown-partner captures
were inspected: Cyndaquil, Totodile, Sentret and Pidgey are all visible. Evidence:
`native-pair-{gold,silver,crystal}` under the scratch directory above. The exact
projection regression, staged pair suite and1173-check SDK suite pass. Companion
public seam: Doubles f4aad50; voxel adapter653d4d1. This fixes the default native
pair composition, not every possible user-directed orbit/HUD intersection.

## Native GBA doubles follow-up

Native FireRed/LeafGreen/Ruby/Sapphire/Emerald doubles also hid one actor per
team under the original fixed HUD. The native-only camera now uses a solved
240x160 composition with compact teammate spacing and five tiles between teams.
Actor artwork, world scale, support height, native UI and gameplay remain
unchanged. The paired placement adapter lives in Gen3BattleActors; modern HUDs,
other claimed HUD providers, singles and hidden native HUDs keep their existing
layout. No scene rebuild is introduced.

All five editions passed native four-owner release timing36/36 frames, four
concurrent owners,44 subject draws, identity/HP and OFF cleanup. Ten final/peak
captures inspected, all four battlers clear of native UI. Evidence:
`gba-pair-{firered,leafgreen,ruby,sapphire,emerald}` and `gba-pair-review.png` in
the same scratch directory. FireRed's first frame-count-only fixture expired
before its real-time intro completed; the QA driver now uses a30-second real-time
deadline, without changing native timing. The rerun passed. Combined suite with
the parity worker:335 pass/0 fail/58 explicit external-fixture skips; the new
native-pair projection regression also passes. As with GSC, user orbit/zoom can
move actors under a fixed native HUD; this fixes the default composition.
