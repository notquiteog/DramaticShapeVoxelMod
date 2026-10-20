# Camera continuity and small-screen review — 2026-10-20

Official Gen1Recomp **0.3.91**, rechecked before the native batch; Linux/NVIDIA,
isolated `native-options-*-qa` profiles, all seven companions. The native LOVE
shell is the existing Linux AppImage shell; engine source is the unmodified
official 0.3.91 runtime plus QA support. No normal saves or model assets changed.

## Changes

- Gen1/2 upward third-person orbits remain above their supporting floor, matching
  Gen3. Pitch is preserved. This is a floor-plane bound, not scenery collision.
- Gen1/2 zoom uses exponential smoothing, matching the same glide at 30, 60 and
  165 updates per second.
- Gen3 fixed angle changes ease for 0.25 seconds. Switching between first and
  rotating third person slides the existing boom instead of snapping between
  two viewpoints. User yaw/pitch and native movement remain authoritative.
- Recorded Gen3 scenes retain the live camera's zoom, angle and boom transition.
  Native OFF and renderer cleanup are unchanged.

The later deliberate removal of boom/scenery collision and free-third-person
foreground cutaway remains intact. Some user-directed third-person angles are
therefore visibly obscured by trees or buildings. The obstruction behavior in
the October17 evidence was subsequently superseded; this pass does not restore
it or claim unobstructed views.

## Native evidence

All eleven editions passed the desktop camera driver at 2560×1440: OFF, FULL,
15°,35°,50°,75°, first person and rotating third person; synthetic public
right-stick input, dialogue look, focus loss, disconnected-controller cleanup,
touch drag, Gen3 pinch and upward orbit floor clearance. Fifty-five mode
captures were inspected. These exercise native rendering with synthetic input,
not physical controller hardware.

Red/Blue/Yellow and Gold/Silver/Crystal each passed actual walking across a
connected-map boundary and out of the starting house in 35°, first and third
person. The fixture seats the player near the approach, then uses native
movement through the boundary/warp. Follow offset and selected angle remain
stable. Eighteen connection captures were inspected; door exits have runtime
assertions, not separate visual captures.
The initial R/B/Y fixed-view captures were native fallback during cold terrain
generation. A repeat waiting for terrain readiness and the settled35° angle
passes all three editions, with proper3D captures inspected. This was a fixture
readiness issue, not loss of selected camera ownership; cold-build fallback
remains the streaming system's policy.

All five GBA editions passed running connections (Route1→Viridian for FR/LG,
Route104→Rustboro for R/S, Route104→Petalburg for Emerald), original dust and
exclamation effects with camera input, native battle entry, battle look, menu
input ownership and field return. Fifteen settled connection/battle/return
captures were inspected. FR/LG required a shorter two-cell fixture approach:
the original twelve-cell straight walkable lane does not exist at that exit.
No production movement or collision changed.

Yellow, Crystal and Emerald also pass at540×960 portrait and960×540 landscape,
with simulated20px side/24px vertical safe-area insets. The native touch artwork
is explicitly loaded through its public preview helper on desktop. All six
checks verify movement-pad contacts do not rotate the camera; free touch look,
Gen3 pinch, input cleanup and OFF restoration pass. Twenty-four mode/overlay
captures were inspected. Touch controls fit the simulated insets, but existing
scenery can still obscure rotating views and companion HUDs occupy substantial
portrait space. This verifies desktop aspect/input integration, not phone
performance or physical Android/iOS behavior.

## Automated checks

The shared suite passes **349 tests, zero failures, 58 explicit external-fixture
skips**, including this production camera batch. The SDK suite passed1171
assertions. Focused floor/pitch/frame-rate, touch/input lifetime, Gen3 controls,
rig interpolation, recap state, adapter fallback and escalator ownership checks
also pass. The floor regression was reproduced before its fix.

Scratch evidence: `../.scratch/camera-polish-20261020/`, including `modes-*`,
`transition-*`, `phone-*`, contact sheets and fixture logs. The reusable mode
driver is `tools/qa/native-camera-modes.lua`; connection drivers remain in scratch.

## Limits

This is not exhaustive certification of every cutscene, ride, ledge, puddle or
map. Recorded-scene state preservation is unit-tested, not a complete native
quest replay. Actual Android/iOS devices and physical controllers were not
available. These camera checks are not performance benchmarks or model review.
