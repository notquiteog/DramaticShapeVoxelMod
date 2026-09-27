# Specialty model / atmosphere pass — 2026-09-26

Runtime: official Gen1Recomp 0.3.20 Linux runtime at `.scratch/ascendant-20260926/runtime/engine`.
Working tree: Battle Art 1.28.6 / Wilds 2.4.3, with the cart companions loaded.
Fresh disposable identities `ascendant-{yellow,crystal,firered,leafgreen}-qa`,
verified in the drivers; no user progress was saved or modified. Captures and
imported art remain outside git. Test processes exited.

## Geometry / source isolation

- Native census: 388 Crystal maps / 147,500 cells and 426 FireRed maps / 234,366
  cells; each counted exactly once. No claim of full visual certification.
- New whole-pattern matches: 12 tower timber columns; one lighthouse apparatus;
  four ship dining tables; one FireRed museum exhibit. Ship/lighthouse use
  identical tile art but map-specific model ownership. The matching census and
  production geometry/support classifiers use the same map restriction.
- `specialty-review.lua` captures overview, side/rear orbit and first person in
  Sprout Tower 1F/2F, Tin Tower 1F, Olivine Lighthouse 6F, Fast Ship captain's
  cabin, Elm's lab, the FireRed/LeafGreen museum 2F and Pokémon Tower 3F, Oak's
  lab, plus Yellow's tower/lab. Reviewed native captures show solid column
  profiles, a separate lens/cage and shuttle stand/wings/tail, and the correct
  table in the ship. Some orbit and first-person fixtures point away from the
  object or include NPC occlusion; they do not certify every angle.
- Source sampling correction after review: the lighthouse lens uses the source
  gold/yellow rather than its dark outline. No generated/replacement art added.

## Atmosphere / options

`NativeAtmosphere` supplies native cell dimensions, grave/pillar anchors,
walkable bounds and raised floor heights to the shared rolling-bank renderer.
OFF does not allocate mist geometry. Live speed/thickness changes reuse cached
meshes. An extra vertex floor attribute keeps height scaling relative to each
floor. Gen1 remains on its original tower detection/placement path.

144 complete-object tests, 62 Crystal source-crop recipes, 36 shared furniture
assemblies, interior diorama regression, native atmosphere/mist lifecycle tests,
399 option-consumer checks and production LuaJIT compilation passed. Native
GPU captures include mist in Crystal/FRLG and unchanged Yellow tower geometry.

## Companion identity

Wilds now assigns a uint32 personality and explicit shiny choice on the host.
Both local and off-map rosters carry them without re-rolling on the guest. The
SDK startWildBattle validation remains authoritative. A weak identity registry
keys the exact native encounter descriptor across its asynchronous transition;
the owned battle receives shiny state before battle.started observers run.

Native FireRed and LeafGreen fixtures preserved explicit shiny PID 0xffffffff
through snapshot, delayed battle and field capture/storage. Focused tests cover
non-shiny identity, refused/error starts, unrelated encounters, remote roster
adoption, and existing Gen1/2 capture/storage. Host-grant adapter checks use an
isolated simulated guest; this pass is not a fresh two-client network session.

## Remaining work

The source-consumer inventory still labels unsupported/partial features rather
than presenting them as functional. Specialty scenery, generic wall cells,
unmatched building columns and first-person/material polish remain. Gen3 battle
actors still use the native UI plane over the 3D scenery; the full Gen1 scene
actor/camera director has not been ported. Expanded move, disconnect, trade,
ride/chat and single/double multiplayer matrices are not certified by this pass.
Do not treat Gen1 or either ledger as a guarantee of exhaustive perfection.
