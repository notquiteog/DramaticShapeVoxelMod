# Native free movement — 2026-10-13

`3D MOVE = GRID` remains the default. Opt-in FREE permits continuous camera-relative
walking/swimming in first person and rotating third person. Static views retain
native controls. Gen1 setting/gating is owned by the separate shared-setting batch.

Gen2 and Gen3 keep fractional positions inside cells. Crossing a cell boundary
asks the native walker to validate/start its cardinal transaction; its next normal
tick finalizes that ordinary step and runs native arrival events. This adapter
never calls a private finish-step callback or fabricates encounters, warps, step
counters or world events. Radius collision checks preserve both cardinal routes
around diagonal corners and allow sliding along walls. Native map/cell/position
changes supersede cached positions. Release preserves position; GRID handback
aligns to the native cell. Menus pause fractional position without snapping.

Native gates execute before free intent. Bikes, forced movement, scripted actions,
ledges, Surf hops/dismounts, stairs/warps and connections retain native handling and
special animation timing. These handoffs can briefly use native cardinal movement.
Gen3 reads the current game's actual input, avoiding the incompatible Gen1 Game
singleton. Launcher hooks restore wrapped methods and discard owned position state.

## Verification

Official Linux LÖVE engine **0.3.85**, verified against the official latest release
before this runtime batch. New-game fixtures in disposable QA identities, generated
caches from the user's supplied ROMs; no original saves touched. These are
frame-stepped actual input/runtime captures, not live keyboard Computer Use.

Scratch evidence: `/home/admin/Projects/.scratch/free-move-20261013/`.
`basic.lua` uses native Input source presses and normal core.update, camera level7,
a settled diagonal yaw, FREE, then GRID, actual Start menu, and native dialogue.

- Emerald `emerald-basic-fixed`, FireRed `firered-basic`, LeafGreen `leafgreen-basic`,
  Ruby `ruby-basic`, Sapphire `sapphire-basic`, Crystal `crystal-basic-fixed`:
  simultaneous fractional x/y movement, no release drift, two native
  `world.stepped` arrivals, exact GRID handback, menu and dialogue input locks pass.
- Gold `gold-basic` and Silver `silver-basic` also pass the complete basic matrix,
  including opening native menus from fractional positions. Their fresh085
  clinic caches were linked into separate `gold-free-qa`/`silver-free-qa` identities.
- Final fractional-menu preservation: `emerald-final` and `crystal-final` repeat
  the basic test while opening the menu from a fractional rather than grid pose.
- `special3.lua`, `emerald-special` and `firered-special3`: actual Center exit,
  Route101/Route1 ledge with native 32-tick jump, route-to-town connection,
  native Surf hop, fractional swimming and native dismount all pass. FireRed's
  central exit carpet was selected after the leftmost warp-table entry proved
  not to be its active arrow-warp tile; native source behavior was inspected.
- `special2.lua`, `crystal-special`: actual Center-to-upstairs warp, Route29 ledge
  with untouched 32-tick duration, Route29-to-NewBark connection, fractional Surf
  and native water-to-land exit pass. Surf state was explicitly initialized using
  public `applyPlayerState` for this fixture; this does not verify the Surf menu.
- Rendered captures inspected: FireRed and Sapphire fractional interiors;
  Emerald door/ledge landing/Surf; Crystal ledge/Surf. Some exterior camera views
  are occluded by existing trees/roof geometry, so coordinate and native-state
  assertions establish transition correctness. Gen2 engine debug heading says
  POKEMON GOLD even in the explicitly selected Crystal shell; GameVersion logs
  record the selected edition. Existing companion UI can overlay screenshots.

Focused LuaJIT suites: `native_free_move_test.lua`, `gen2_camera_walk_test.lua`,
`gen3_camera_controls_test.lua`. The new solver suite checks diagonal/release/wall
sliding, exactly-once native boundaries, external relocation, ledge timing,
one-way diagonal permissions, native Gen3 input gate, fractional menu pause,
analog deadzone and normalized digital intent. Syntax and whitespace checked.

Run template:

```sh
bash /home/admin/Projects/.scratch/runtime-0.3.85/run.sh GAME \
  /home/admin/Projects/.scratch/free-move-20261013/basic.lua OUT PROFILES IDENTITY
```

Not exhaustive: every trainer/script, warp/escalator, bike variant, forced-current,
ice, dive and encounter combination; mobile/touch controls; physical controller
input; runtime quit/re-entry. Native guard/delegation code covers these boundaries,
but they are not all independently exercised. No all-special-tiles claim.
