# Kanto First Person flora and movement integration audit

Source: permitted release 1.60.0 in `vendor/kanto-first-person`. Reviewed 2026-10-11.
This is an ownership/implementation audit, **not a claim of eleven-game visual
verification**. The donor's broad `Flora.draw` must not run alongside the existing
scene: it generates additional geometry, rain and tree caches over existing ones.

| Donor family | Existing owner / integration | Remaining verification |
| --- | --- | --- |
| Hop boost, crouch, landing, distance bob, door dip/push | `KfpMotion`; explicit first-person adapters; settings default OFF | Actual ledge/door travel on each edition; sampled lift and real Yellow first-person render checked (0.3.52) |
| Ambient cave and cave steps | `NativeCaveAudio` / `CommunityFlora`; newly repaired packaged asset fallback through `KfpAtmosphere.read` | Native per-edition audio traversal |
| Town/route beds, grass/wood steps, threshold sounds | New `KfpAtmosphere` explicit map facts and native core-update hook | Yellow packaged town bed and room render checked; remaining editions |
| Forest/night/water ambient beds | `ForestLifeAudio`, `KantoLifeAudio`, existing CommunityFlora mixer | Existing recordings remain authoritative; donor files retained as fallback, no second loop |
| Rain, storm and lightning | Shared `Weather` owns selection and timing | Existing 41-check parity suite passed; donor random weather not enabled |
| NPC umbrellas | `KfpRainProps` reuses donor-generated pixel art; explicit human inputs, weather owner, bounded draws | Native Gen1/2 posed and Gen3 public event-graphics adapters wired; Yellow0.3.52 and Emerald0.3.74 rain frames checked |
| Tufts and native grass art | `CommunityVisuals.grass`, native grass meshes and CommunityFlora | Donor hardcoded tile search is not safe for Gen2/3 |
| Grass step seeds | `KfpSurfaceLife` uses donor disc art with a native-scale knee-height launch envelope and shared KantoLife dispatch with independent GRASS SEEDS option; native grass/walkability/elevation, bounded pool, deterministic isolated emitter | Emerald0.3.74 actual grass walking/running verified with insects OFF; other editions retain unit-tested shared adapters, rendered verification pending |
| Drips/fireflies/leaves/dust/foam/smoke/rustle | Existing cave/forest owners plus `KfpAmbientDetails`, `KfpTreeDetails`, and `KfpSurfaceLife.drawRustles`; separate default-OFF shared options | Native source-aware adapters replace the unsafe broad particle dispatcher; see 0.3.75 checkpoint below |
| Darkness/pools/sconces/bats/lights | Existing CommunityFlora code plus `CaveAtmosphere3D`, `CaveSconces`, native Flash handling | Do not assume Gen1 dark-map table applies to other games |
| Forest canopy, vines, shafts | Gen1 `drawCommunityForest` owns the stitched donor canopy; native Gen2/3 authored tree crowns and ForestAtmos own canopy/shafts. `KfpTreeDetails` adds optional tree-local vines. | Native foliage underside sampling skips vines when there is insufficient trunk clearance. No blanket Gen1 roof over native trees or walk lanes. |
| Puddles, additional rain splash/bolts | Donor implementations retained in CommunityFlora but broad pass not active | `KfpWetGround` adds optional bounded hashed puddles/splash rings on callback-approved flat walkable native surfaces; Emerald0.3.74 rendered2 eligible anchors, remaining editions/terrain traversal pending |
| Trunks, boulder trees, shadows | Native tree/model pipeline and settings supersede donor tile-hardcoded generator | Preserve source-faithful models and approved shadow budgets |
| Mountain peaks, backs and apron | Existing CommunityFlora implementations; native horizon/terrain/boundary systems own scene | Legacy peaks intentionally disabled (TEST412: false giant buildings). Do not re-enable without source-aware map adapter |
| Lens FOV and blur | Existing first-person FOV / tilt-shift systems | No forced global FOV/pipeline mutation from donor |

The audio and motion modules neither modify gameplay data nor use the encounter
RNG. No companion is required. Settings use the normal mod option registry.
Original vendored art is retained; narrow host lifetime fixes are documented by
the integration owner. New adapters never invoke the filesystem patcher or
shared-global installation protocol.

## Runtime checkpoint

Emerald on official0.3.74, Petalburg water fixture: imported rain ambience
loads; four known human NPC umbrella props; two eligible native wet-ground
anchors; no effect errors. Native/overview/first-person captures retained in
scratch. First-person camera was too close to the fish for a polished composed
shot; do not call that general visual parity. Yellow0.3.52 town/room views and
real packaged town audio passed earlier; not latest-engine evidence.

Grass seeds checkpoint: `KfpSurfaceLife` defaults OFF and shares existing native
scenery dispatch without depending on KANTO LIFE/insects. Static/mocked checks
cover native elevation, solid/water exclusions, warp/airborne resets, isolated
randomness and the48-particle ceiling. Emerald Route101 on official0.3.74,
actual native walking/running with KANTO LIFE OFF, observed live seeds while
camera stayed active. Close first-person review reduced the donor's airborne
launch scale to small knee-height motes; native artwork and collisions unchanged.
Drivers/captures: `.scratch/kfp-20261011/grass-seeds-close074.lua` and
`grass-seeds-final074/`. Scope remains one particle family, not a full donor or
all-eleven-game visual parity claim. These remaining families now have bounded source-aware adapters described below; this historical seed checkpoint is retained as evidence for its own revision.

## Native particle adapters, 2026-10-11 / official0.3.75

- **SHORE FOAM** samples real water/level walkable-land boundaries, not map-name guesses; cliff shores and solid walls are excluded. Spray stays inside the water cell.
- **ROOM DUST** uses dry native walking cells and actual elevation; caves/forests retain their existing effects.
- **CHIMNEY SMOKE** consumes exact outlets from actual Gen3 chimney geometry (including Oak's lab), never a generic roof/solid-cell guess. `drawChimneys` is also an explicit public seam for added region model providers. Games/buildings with no authored chimney receive no invented plume.
- **LEAF FALL / HANGING VINES** consume modeled tree observations. Original native atlas foliage supplies the underside; vines stay in a blocked cell and skip trees lacking physical clearance. Existing Gen1 custom-forest particle ownership is respected.
- **GRASS RUSTLE** ports the donor's distant five-seed burst, using confirmed native grass, actual elevation, a bounded pool and deterministic isolated timing. It is independent of insects and footsteps.

All six options default OFF. There are no collision, encounter, save, or native UI writes. Scans, vertex counts and updates are bounded; art/mesh objects are reused. Source-shaped particles remain optional embellishments rather than replacements for original tree or terrain artwork.

Focused tests cover water/solid/cliff exclusions, finite geometry, elevations, blocked tree-cell containment, expired bursts, cut-tree clearance, no gameplay RNG and native option consumers. Official0.3.75 Emerald Route104/Brendan-room fixtures exercise foam/dust; FireRed Pallet exercises a real chimney outlet. First smoke render looked like solid pellets, so final material uses faint transparent expanding puffs. Captures/logs: `.scratch/kfp-20261011/{ambient-final075,chimney-final075}`. Native Gen1/Gen2 paths share adapters but are not labelled all-edition visual proof.

The intentionally unused donor mountain-peak heuristic remains superseded by native elevation/horizon geometry: enabling false mountains on roofs would violate source fidelity. Native canopy geometry likewise supersedes the Gen1-only stitched canopy on other generations. Bird image ownership lives in `KantoFirstPerson`/`KfpBirdArt`; airborne and ground-flock behavior must be tracked separately.

Additional official0.3.75 checks: Crystal New Bark native tree pass and player-house dust, Emerald native crown/leaf pass and Route101 five-seed rustle. Tree records use native map-definition identity so rebuilt facade instances share their model observations. Native card alpha/palette sampling supplies foliage clearance; a low skirt is not forcibly lifted just to make space for a vine. Captures `.scratch/kfp-20261011/{crystal-final075,tree-rustle-final075}`.

### Ground flocks

`KfpGroundFlock` ports pecking and approach-triggered takeoff as optional **GROUND BIRDS**. Three decorative native-art cards use dry, flat3x3 native ground and exact elevations. Candidate placement also checks the corridor and native NPC/event occupancy. Transparent image foot margins are measured, preventing sprite padding from becoming a levitation gap. Approaching flushes the flock away/up with elapsed-time movement; it expires, resets on maps/OFF, and never creates encounter entities or modifies collision. A public native asset resolver supplies art; no sprite pack or partner is required.

Focused checks cover blocked/water/stair rejection, map/reset/expiry, native elevation, native-art cache ownership, data/edition rebinding and option refresh. Sky payload is recreated before releasing images so its private picture list cannot retain freed textures. Ground birds query the refreshed cache per draw. Bird providers and native assets remain authoritative.

Ground-flock visual checkpoint: official0.3.75 Emerald Oldale, isolated `kfp-emerald-qa` profile. Three native cards visibly stand on the clearing, take off on approach, and disappear when disabled. Driver must exercise `core.update`: the engine's scripted branch bypasses `PlatformHooks.update`, so an unwrapped test can report flock positions without ever binding the native art owner. Corrected fixture `.scratch/kfp-20261011/ground-flock075.lua`; reviewed captures/log in `ground-bound075/`. Assertions passed with no Lua errors; launcher process returned1 during shutdown, recorded separately from visual assertions. Native NPC/prop occupancy and the corridor are excluded, avoiding the early Birch-bag occlusion.
