# Native starting truck cargo

## Confirmed defect

The native RSE opening calls `truck_sequence.execute`, closes exit cells
`(4,1)..(4,3)` with metatiles `20D/215/21D`, and locks player walking. After
driving, braking and unloading, it opens those cells with `208/210/218` and
unlocks walking. All timing, object offsets, audio and collision remain native.

The previous 5×5 `hoenn_truck_cargo` recipe required only the final open exit.
Its single mismatch discarded every static cargo volume during the opening;
the truck-specific fallback shapes are flat. Ruby/Sapphire additionally omitted
this recipe from their checked-family whitelist. In-memory extraction on the
unmodified consolidated snapshot reproduced Emerald open=1/closed=0 and
Ruby/Sapphire open=0/closed=0 complete cargo matches.

## Changes and renderer seam

`Gen3TruckCargo.matches` admits only those three native closed drawings as
aliases inside the exact reviewed truck recipe. The complete source context
must still match. Static cargo claims only the 15 blocked cells in this native
footprint; the ten walking/exit cells keep their actual metatile and source art:

```
11111
10000
10000
11100
11111
```

When native permissions are present, every claimed static cell must remain
blocked (`7`). No script, metatile, collision, warp or native object is changed.
The RS whitelist admits this single complete cargo family.

Native moving boxes are separate graphics113 event objects. They are props,
independent of character/Pokemon styles. `Gen3TruckCargo.draw` builds a closed,
world-facing box using the live native sprite's top/front UV regions, with
separate top, sides, rear and underside. It omits the sprite's outer background
border. Meshes are cached by the live source image and frame, and only their
translation changes as native `raiseX/raiseY` updates. Shadows/reflections use
the same closed geometry. HD2D prop style or missing/unreviewed source/failed
mesh upload returns `false` for the existing sprite fallback.

The existing scene actor routine needs this hook after computing `height` and
before drawing the sprite card:

```lua
if V.require('Gen3TruckCargo').draw(gid,x,z+(opts.depthOffset or 0),height,
 spr,frame,draw,reflectPlane)then return end
```

The actor caller already adds native `raiseX` to `x` and subtracts native
`raiseY` from `height`. Do not apply either offset twice. Call `clear()` alongside
other scene-owned prop mesh cleanup. This worker commit does not edit the
parent-owned scene/integration hook.

These are native-source 3D cargo repairs. An authentic imported ORAS truck/crate
has not been accepted; this change makes no ORAS model-coverage claim.

## Evidence and remaining native QA

The live-source 16×16, single-frame graphics113 RGBA was inspected. Current
R/S/E native caches are identical after decoding (SHA256
`446c097a35d7f9e17041cf43632023b6fc25632647588f2d32dbf380d43f1bec`).
No native pixels, game archives or captures are committed.

Focused LuaJIT tests pass for both door states plus partial updates in all RSE
editions, exact claim/permission isolation, untouched live exits, closed
six-face geometry, per-frame translation without mesh rebuilding,
shadow/reflection placement, HD2D selection, edition isolation and missing
source/upload fallback. Existing Hoenn, RS dispatch, Center furniture and
interior walking-footprint suites also pass.

Parent-owned official0.3.95 native QA remains required before visual acceptance.
Fresh opening fixture: call `_handleBootAction` with `action='new_game'` and
`fieldCallback='truck'`, without a `start` override. Keep the real frame loop
and callback intact. Existing outdoor teleport/new-game fixtures skip this
opening. Log the native sequence state, all 5×5 cells/permissions, camera
look/yaw/pitch, `Scene.nativeRequired`, active renderer and recovery errors;
inspect moving, braking, unloading and final-open views in all three editions.
The static audit found no truck-specific camera-look lock; native walking and
engine zoom remain intentionally locked. A separate live reproduction must
identify the reported camera-control failure before changing that behavior.

## Official0.3.95 native follow-up

Fresh native truck callbacks were run in isolated copied R/S/E profiles using
the matching official Linux shell. Moving, braking, stopped-closed, unloading
and open captures were inspected; the cargo recipe remained present throughout
all three editions with no renderer quarantine or native fallback. The native
door opens/unlocks at frame865, including its original exit permissions changing
from0 to114. The native 15-cell blocked footprint matches the tested mask.

Rendered inspection found the three moving box objects hidden inside duplicate
static volumes at `(0,0)`, `(0,3)` and `(2,3)`. The native atlas already depicts
those same boxes. `dynamicCargo` removes only those static placeholders, so the
live moving objects own their source geometry instead of being occluded by a
second body. Other cargo and the native floor/exit remain intact.

Focused X11 input checks exercised public native gamepad, mouse and key methods:
right-stick rotation changed yaw by1.167rad during the locked animation and the
same angle after unlocking; mouse changed yaw/pitch and key3 cycled camera modes
while locked. No camera-lock production change is justified by this reproduction.
First/third-person and35-degree captures were inspected. Evidence is under the
scratch `truck-camera-20261022/{emerald,ruby,sapphire}-unmasked` runs.

Two fixture limitations were corrected before accepting camera evidence: the
sandboxed Wayland test window lacked focus even after unlocking, and the official
frame-driver branch calls `Game:update` directly, bypassing `core.update` hooks.
The focused scratch driver dispatches the public `core.update` hook with a no-op
vanilla step once per test frame; the engine still executes its original native
update exactly once per frame. No protected callback or truck timing is replaced.
