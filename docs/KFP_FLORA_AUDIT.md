# Kanto First Person flora and movement integration audit

Source: permitted release 1.60.0 in `vendor/kanto-first-person`. Reviewed 2026-10-11.
This is an ownership/implementation audit, **not a claim of eleven-game visual
verification**. The donor's broad `Flora.draw` must not run alongside the existing
scene: it generates additional geometry, rain and tree caches over existing ones.

| Donor family | Existing owner / integration | Remaining verification |
| --- | --- | --- |
| Hop boost, crouch, landing, distance bob, door dip/push | `KfpMotion`; explicit first-person adapters; settings default OFF | Actual ledge/door travel on each edition; sampled lift and real Yellow first-person render checked |
| Ambient cave and cave steps | `NativeCaveAudio` / `CommunityFlora`; newly repaired packaged asset fallback through `KfpAtmosphere.read` | Native per-edition audio traversal |
| Town/route beds, grass/wood steps, threshold sounds | New `KfpAtmosphere` explicit map facts and native core-update hook | Yellow packaged town bed and room render checked; remaining editions |
| Forest/night/water ambient beds | `ForestLifeAudio`, `KantoLifeAudio`, existing CommunityFlora mixer | Existing recordings remain authoritative; donor files retained as fallback, no second loop |
| Rain, storm and lightning | Shared `Weather` owns selection and timing | Existing 41-check parity suite passed; donor random weather not enabled |
| NPC umbrellas | `KfpRainProps` reuses donor-generated pixel art; explicit human inputs, weather owner, bounded draws | Live scene actor adapters / rendered placement |
| Tufts and native grass art | `CommunityVisuals.grass`, native grass meshes and CommunityFlora | Donor hardcoded tile search is not safe for Gen2/3 |
| Seeds/drips/fireflies/leaves/dust/foam/smoke/rustle | Donor implementations already present in CommunityFlora; selective `CommunityFlora`, `ForestAtmos`, `KantoLife`, `CaveAtmosphere3D` owners | Broad donor particle dispatch is not enabled; not every particle type yet has an all-edition public toggle |
| Darkness/pools/sconces/bats/lights | Existing CommunityFlora code plus `CaveAtmosphere3D`, `CaveSconces`, native Flash handling | Do not assume Gen1 dark-map table applies to other games |
| Forest canopy, vines, shafts | Existing CommunityFlora/ForestAtmos paths, including cutaway/first-person canopy selection | All-edition canopy/vine coverage still needs native layout review |
| Puddles, additional rain splash/bolts | Donor implementations retained in CommunityFlora but broad pass not active | Needs a dedicated native surface adapter to avoid double rain and flat puddles over raised terrain |
| Trunks, boulder trees, shadows | Native tree/model pipeline and settings supersede donor tile-hardcoded generator | Preserve source-faithful models and approved shadow budgets |
| Mountain peaks, backs and apron | Existing CommunityFlora implementations; native horizon/terrain/boundary systems own scene | Legacy peaks intentionally disabled (TEST412: false giant buildings). Do not re-enable without source-aware map adapter |
| Lens FOV and blur | Existing first-person FOV / tilt-shift systems | No forced global FOV/pipeline mutation from donor |

The audio and motion modules neither modify gameplay data nor use the encounter
RNG. No companion is required. Settings use the normal mod option registry.
Original vendored files remain unmodified; new adapters do not invoke their
filesystem patcher or shared-global installation protocol.
