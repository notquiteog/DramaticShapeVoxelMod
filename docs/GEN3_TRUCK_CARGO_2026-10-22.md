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
