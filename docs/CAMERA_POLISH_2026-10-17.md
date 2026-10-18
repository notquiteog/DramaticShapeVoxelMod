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
