## 1.28.7 — Full-depth starter table and power-plant machinery

Restores the full depth of Oak’s starter table in FireRed/LeafGreen, keeping all three Poké Balls centered and the native approach clear. Adds component models for Crystal’s Power Plant machinery and both FireRed/LeafGreen turbine drawings, using their native artwork and colors. Mesh revision 79 refreshes stored models.

Checked on Gen1Recomp 0.3.20 and the latest 0.3.22 with native first-person/rotating/static captures and focused geometry/cache regressions. Full-area scenery coverage and five-mod feature parity remain unfinished.

## 1.28.6 — Specialty interiors and shared tower mist

Added closed component models for Crystal tower timber columns, the Olivine lighthouse apparatus, Fast Ship dining tables and the FireRed/LeafGreen museum space exhibit. The lighthouse model is restricted to its map because ship tables reuse the same artwork. Mesh revision 78 refreshes stored geometry.

Gen2/Gen3 towers now draw Gen1's rolling mist banks with shared visibility, speed and thickness controls; thickness preserves raised floor heights. Refreshed the native tile ledger: 388 Crystal and 426 FireRed maps. Classification is not visual approval: 24,754 Crystal wall cells and 74,506 FireRed unreviewed cells remain in the review queue, alongside 297 unmatched FireRed building cells.

Validated on Gen1Recomp 0.3.20 with native specialty/lab captures in Yellow, Crystal, FireRed and LeafGreen, 144 complete-object geometry checks, atmosphere/cache tests and 399 option-consumer checks. Full-area quality and five-mod parity remain unfinished. See docs/SPECIALTY_QA_2026-09-26.md.

## 1.28.5 — Raised floors and enclosed caves

Raised Crystal and FireRed/LeafGreen floors now follow native stair connections and reviewed platform artwork. Cave shelves, mountain terraces, piers, theater stages, gym walkways and train platforms carry actors, scenery and cameras at their actual floor height. Water reflection planes follow the drawn water level. Native collision, warps and gameplay are unchanged.

Caves in all three generations receive closed outer walls and ceilings in ground-level views, with camera-side cutaways from outside, clearance above raised platforms, and openings for native boundary exits and descending stairs. Outdoors retain open scenery.

Validated on Gen1Recomp 0.3.20 using isolated native map inventories, representative rendered views and stair walking checks. This is an incremental release; exhaustive all-area visual coverage and companion parity remain unfinished. See docs/ELEVATION_QA_2026-09-26.md. Mesh revision 77 refreshes stored terrain.

## 1.28.4 — Cooperative scenery streaming and higher first-person view

FireRed/LeafGreen builds moving scenery windows cooperatively while continuing to draw the last complete window. Reversals, warps and invalidation cancel unfinished work and release its GPU resources. Model generation and shared uploads gain budget checkpoints; Crystal/FRLG reuse tree source pixels and Gen3 furniture matching skips unrelated recipes.

Raised first-person framing in all three generations: native GB height 12 world pixels, FRLG 13.5, retaining sprite foot anchors and authored provider overrides.

In one isolated 2560×1440 LeafGreen forest benchmark on Gen1Recomp 0.3.20 / RTX 5060 Ti, maximum traversal frame time fell from 53.28 ms to 10.57 ms. Mean was similar (4.56 → 4.61 ms); p95 increased (5.20 → 7.03 ms) as work was spread across frames. Both replacement windows completed. This is a targeted hitch reduction, not an all-game FPS claim. Cold map loads and individual GPU calls remain synchronous.

Native Yellow, Crystal, FireRed and LeafGreen checks covered forest/lab rendering, first-person height, and house exits. Focused scheduler, resource, geometry and furniture regressions pass. Full all-map quality and companion feature parity remain unfinished. Evidence: docs/STREAMING_QA_2026-09-26.md.

## 1.28.3 — House stairs, seating and first-person placement

Fixes FireRed/LeafGreen losing the selected 3D camera when leaving the player’s house with FAR/FULL render distance: connected tilesets with no ground triangles are valid empty batches. Genuine upload failures retain actionable diagnostics and bounded recovery.

Rebuilds complete FireRed/LeafGreen house staircases with separate treads, risers, stringers, handrails and recessed descending flights. Restores the bedroom dresser with two drawers and handles. Mom sits at the dining chair’s cushion, with the chair backs facing away from the table; scripted movement remains native.

Crystal house stairs retain their native four-step footprint. Stair warps are protected from door folding; north wall framing and wallpaper recess behind the flights, and shared Gen 1/2 room foundations leave descending stairwells open.

First-person eyes now follow native sprite eye rows and visible-foot anchors across all three generations. FireRed/LeafGreen first person also disables world curvature and uses the shared close-wall focus distance. Mesh revision 76 refreshes stored geometry.

Checked on Gen1Recomp 0.3.20 with isolated native fixtures and focused regressions. See docs/HOUSE_CAMERA_QA_2026-09-26.md for evidence and limits. Full all-map scenery and cross-generation feature parity remain unfinished.

## 1.28.2 — Native trees and forest performance

Native modeled trees retain distinct source families: pointed conifers, Viridian layered crowns, wide Ilex/Park trees, compact Crystal Kanto crowns and Cut saplings. Colors follow the original artwork around closed 3D crowns. Separate border trees and single wide trees retain their footprints; original 2.5D choices remain available. Shared source images no longer overwrite bush/tree model metadata. Mesh revision 75 refreshes stored models.

Crystal and FireRed/LeafGreen reuse GPU tree models and uploads only placement coordinates when the scenery window moves. Unsupported devices keep merged geometry. All generations reuse unchanged scalar draw state and set shadow camera uniforms once per pass. Gen 1 retains its authored procedural trees and existing map/chunk reuse. Shadows OFF now prevents shadow rendering, including direct native-adapter calls. A 2560×1440 LeafGreen forest traversal on RTX 5060 Ti reduced the largest sampled rebuild frame from about 1,300 ms to 64 ms; steady frames remained similar. This is a targeted short benchmark, not an all-game FPS claim. [Evidence and limits](docs/TREE_PERFORMANCE_QA_2026-09-26.md).

All-map scenery, cross-generation feature parity and completely hitch-free streaming remain unfinished.

Previous 1.28.1: complete shared interior furniture, native floor routing and wall-row fixes. [Validation and remaining coverage](docs/SHARED_INTERIORS_QA_2026-09-26.md).

House and office plants use curved solid leaves, a raised midrib, closed undersides, and a tapered pot with a rim and inset soil; the native 2.5D alternative remains selectable. LeafGreen ship room styling now resolves edition-specific tileset aliases.

Trees use normal round crowns: separate narrow border rows, one broad tree for a 2x2 drawing. Native TREE ART retains model/card choices. ROCKS & BUSHES adds solid/native-cutout choices in Gen2/3; default models leave people, Pokemon, grass and flowers as sprites. Mesh revision 73 invalidates older geometry. Adds Voxel Ascendant's MIT-licensed optional weather across all three engines (CLEAR/AUTO/RAIN/SNOW/FOG/STORM), with source attribution. Native battle mechanics are unchanged.

## 1.28.0 — 2026-09-26

Replaces flat-looking source-column tree/rock extrusion with intersecting 3D canopy/stone masses using each game's native palette. Tree cards remain optional. Shelves now have individually projecting contents, while terminal/rack recipes get separate CRTs, keyboards and equipment modules. Six FireRed/LeafGreen Pokémon Tower grave drawings gain closed plinths and upright headstones, scoped to their original tileset.

Adds closed native-art Crystal sculptures, monuments and thin bicycle displays, plus timber-house side/back siding. Thirty-one more FireRed/LeafGreen cabinet recipes receive closed frames, recessed source facades, kickboards and separate storage bays. Existing authored consoles, appliances and lab models retain priority. Cache revision 72 refreshes stored scenery.

Connects native forest, cave and tower atmosphere controls to both later generations, including fog visibility/thickness, separate subtle/full particle levels and speed. Fixes the full-particle pass calling a nonexistent renderer API. FireRed/LeafGreen SCENERY TEXTURES now controls optional world-stable grain on scenery without affecting actor or UI art.

Verified focused geometry/settings tests, LuaJIT compilation and representative rendered scenes on Gen1Recomp 0.3.20. The native options menu changes, persists and restores the new controls. See [evidence and limits](docs/NATIVE_SCENERY_QA_2026-09-26.md). This is an incremental release: full city/route/interior coverage, specialty scenery settings and Gen3 world-space battle actors remain unfinished. Tower speed currently affects particles, not animated ground mist.

## 1.27.2 — 2026-09-26

Crystal shared scenery pass: 36 existing complete-object recipes now use component furniture—recessed shelving and machine displays, keyboard trays, legged tables, chairs and horizontal beds. Covers facilities, stations, Radio Tower, Game Corners, gates, mansions, ship cabins and Battle Tower. Six native rock drawings use closed source-colored voxel volumes, covering 2,048 placements in the imported map census. No collision, scripts or encounter behavior changes. Cache revision71 refreshes previous geometry.

Inventoried all388 Crystal maps and inspected ten representative maps in overview/first-person captures on Gen1Recomp0.3.20. Some fixture dialogue obscures lower screen regions; this is not exhaustive visual certification. Generic walls and specialist scenery still require review. Lower grass and starting-area fixes from1.27.1 are included.

## 1.27.1 — 2026-09-26

Makes grass lower across all three generations while retaining sprite artwork. Crystal and FireRed/LeafGreen also retain the native grass pattern on the ground, so low tufts form complete patches instead of thin separated stripes. Flowers retain their upright native sprite presentation. Refreshes stored geometry to discard taller cached grass.

Prioritizes complete room-specific furniture models over generic matches: the FireRed/LeafGreen bedroom console no longer becomes a cabinet column. The rival's house gains the existing authored CRT, cupboard/telephone, shelving and plant models, a recessed framed wall picture, and matching wall backing. Crystal's common-house TV, radio, bookcase and table use authored components. Shared neighboring-house room enclosures align with their native north walls.

Surveyed Pallet plus both player-house floors, the rival's house and Oak's lab in both native editions; New Bark plus both player-house floors, Elm's lab, Elm's house and the neighboring house in Crystal. Captures cover overview, reverse and first-person views. Targeted model/grass regressions pass; the reported 1.27.0 HUD and camera fixes remain included. This is a further starting-area pass; exhaustive scenery/settings and Gen3 world-space battle-camera parity remain unfinished.

## 1.27.0

Crystal battle UI ownership and FireRed/LeafGreen camera recovery fixes; native-art voxel trees with card alternatives and three detail levels; closed cave boulders; clean house-side texture sampling. Tested with Gen1Recomp 0.3.20. Full scenery/settings parity remains in progress. See [validation and limits](docs/SCENE_RECOVERY_QA_2026-09-26.md).

## 1.26.0 — 2026-09-23

Restores overlapping native Viridian Forest tree rows in FireRed/LeafGreen, lowers tall grass to seven world pixels, and reuses unchanged terrain geometry without rebuilding tile records every frame. Live metatile overrides, palette/provider replacement, map boundaries and battle/replay changes still invalidate appropriately.

Adds optional AMD FSR 1 EASU + RCAS upscaling across all three generations (OFF, Ultra Quality, Quality, Balanced, Performance). Scene resolution changes independently of crisp native-resolution UI. OFF remains the default; FSR takes priority over supersampling AA. Shader failure preserves native rendering. Includes AMD's MIT reference kernels and GLSL 330 integration.

Corrects shadow receiver-plane sampling on steep foliage/walls, adds stable depth ordering for coplanar foliage, and gives ordinary Pallet and matched native house side/back walls modeled siding courses. This is a focused improvement, not complete building/setting parity. DLSS, DLSS 5 neural rendering and temporal frame generation are not implemented: they require native engine/backend integration.

Checked with isolated official Gen1Recomp 0.3.2 profiles on an RTX 5060 Ti, including 1440p FireRed/LeafGreen scenes and Yellow/Crystal FSR quality controls. See `docs/FOREST_PERFORMANCE_QA_2026-09-23.md` for evidence and limits.

## 1.25.0 — 2026-09-23

Rebuilds the reviewed Crystal and FireRed/LeafGreen player houses, labs, Centers and Marts with native-art furniture components: recessed CRT screens, keyboards, console/controllers, legged desks and chairs, horizontal beds, kitchen fittings, shelf frames, stock trays and shallow cushions. Adds complete runtime Crystal bedroom decorations and link-room control panels. Native back walls continue behind furniture; Crystal carpet borders stay on the floor. Retains low reception counters, native collision, interaction cells and item supports.

FireRed/LeafGreen ledge jumps and their landing dust now remain in the selected 3D camera; player and first-person eye height follow the native hop arc. Sand/grass path transitions retain their original cap artwork and continuous ledge height instead of tapering into false ends. Adjacent Mart checkout sections meet without inset seams.

Checked in official Gen1Recomp 0.3.2 in static, rotating, reverse and first-person views. This is a targeted interior pass; exhaustive all-map/all-option parity remains unfinished. See `docs/INTERIOR_QA_2026-09-23.md`.

## 1.24.0

Pokémon Centers in FireRed and LeafGreen now have complete up/down escalators, recessed stairwells, joined native back walls, a horizontal healing tray, low seats, reception counters, upstairs terminals and gates. Counters leave room for Nurse Joy and the upstairs workers, including rotating views. Healing balls and the monitor align with the modeled equipment. Escalator travel retains the chosen camera between animation phases.

Crystal gains a complete kitchen and bedroom workstation, with separate monitor, keyboard and console. Pewter Museum gains its full L-shaped counter and fossil displays. Roof eaves close their exposed corners across the shared Gen 2/3 builders. Includes the earlier tested upright foliage, actor grounding, stairs and recap-camera changes.

Verified on official Gen1Recomp 0.3.2 using isolated imported profiles. This is a focused scenery release, not exhaustive all-tile visual parity. See docs/SCENERY_QA_2026-09-23.md for checks and remaining limits.

## 1.23.0 — 2026-09-22

Includes the verified FireRed/LeafGreen actor grounding, shadow contact, animated BW battle fronts, lab table/item fixes, rock silhouettes and museum counter correction. Generation-specific settings and scenery coverage remain incomplete.

Numbered release of the tested 1.23.0-test.11 build. Runtime and assets are unchanged except version metadata; packaging and cart pins are refreshed. Validation from the prior exact releases remains applicable: official Gen1Recomp 0.3.1, isolated profiles, targeted native rendering/integration checks. This release does not claim complete cross-generation feature or visual parity.

## Museum counter classification — 1.23.0-test.11

Stops one museum counter bend from rising into a room-height slab. The native counter artwork remains in place; a complete counter model is still a coverage gap. Native collision and scripts are unchanged.

Exact published test.10 captures on official native0.3.1 were inspected: noon/low-moon player and HGSS follower grounding, explicit raised-actor height, eight Oak lab approach views, three Pewter rock views, and fifteen cave views across five palettes. The large actor shadow gap and detached Pewter rock caps are resolved in those fixtures. Full native option/scenery parity and exhaustive movement/companion coverage remain unfinished.

**TEST PRERELEASE — museum correction visually verified in the exact published archive.** Its classification/column regression, the 15-object furniture checks and LuaJIT compilation pass. The earlier complete map censuses remain classification evidence, not a full visual pass.

Exact test.11 FireRed/LeafGreen single and double captures confirm animated enemy sprites, distinct normal/shiny art and four visible battlers. All final carts passed pin/default/settings checks. [Verification and limits](docs/RELEASE_QA_2026-09-22.md).

## Animated BW fronts, actor contact and rock silhouettes — 1.23.0-test.10

Aligns native FireRed actors and provider sprites to one visible baseline across their animation frames, including Canvas-backed followers and furniture-supported items. Authored provider baselines, jump/hop differences and explicit ride/flight heights remain intact. Native actor shadows now use the existing shared contact correction and matching light lookup; terrain shadow bias is unchanged. Rock geometry uses the largest connected foreground silhouette, preventing disconnected floor stripes and grit from forming floating caps in Pewter gym.

Bundles real timed BW front animation for normal and shiny dex1–386:772 atlases, with no missing/static-only entries in that range. Installed custom atlases remain first priority; Gen1/Gen2 Crystal defaults are preserved. Source, timing and asset-audit details: [BW fronts](docs/BW_FRONT_ANIMATION.md).

**TEST PRERELEASE — visual verification follows publication.** Focused anchor, disconnected-rock-silhouette and cave-profile regressions plus LuaJIT compilation pass. All772 BW front atlas hashes/dimensions/timings and782 decoder contracts pass; rendered native enemy animation still awaits packaged verification. Test.9 rendered inspection confirms the reported player/rival table clipping is fixed in all eight approach views; the actor-contact and rock-silhouette follow-ups still need their exact packaged captures. Full native option and scenery parity remains unfinished; see the support inventory and test.9 notes below.

## Native option consumers and reviewed depth scenery — 1.23.0-test.9

Adds native Gen2/Gen3 renderer, battle HUD, trainer, selected-art interface, lighting and arena-background consumers. Expands reviewed Crystal furniture and FireRed gyms, caves and interiors, including 15 complete furniture recipes matching 137 native objects. Fixes the reported Oak lab table overlap by keeping its solid geometry out of the walkable approach row. Native mon identity preserves same-species shiny variants.

All 89 controls remain visible with an explicit support inventory. Full parity is **not complete**: the source audit records 13 missing Gen2 controls and 53 missing Gen3 controls, plus partial/provider-dependent features. Missing optional artwork retains native presentation.

**TEST PRERELEASE — published before gameplay verification as requested.** LuaJIT compilation, focused source/mock tests and official0.3.1 SDK checks pass; exact packaged visual/gameplay checks and the lab screenshot regression follow publication. See [implementation and limitations](docs/NATIVE_PARITY_2026-09-22.md) and [complete option inventory](docs/option-support.json).

## Four-battler framing and complete animated backs — 1.23.0-test.8

Four Gen 1 double-battle cards follow the actual composed sprite heads, and the camera widens to keep both near-side Pokemon in view. FireRed/LeafGreen modern commands preserve full-body sprite pixels beneath the old command window; status anchors use the selected artwork. Fixes the packaged animated BW back atlas path (dex 1–251). Includes the shared modern UI toggle and functional Gen 3 shadow/world-curve/wireframe controls from test.7.

Verified using isolated scripted profiles on latest official Gen1Recomp 0.3.1: four-card Yellow online doubles, normal battle completion with matching state hashes and intact owned parties; Crystal integrated sprite/settings checks; FireRed 1440p UI toggle, native directional input, animated back frame changes, damage, attack-stage lifetime and field return. Inspected native rendered captures, including complete FireRed back sprites and all four Yellow battlers. Final archive checks follow publication.

These remain test releases. Full cross-generation feature parity, complete animation coverage, Gen 3 shiny-context handling and exhaustive multiplayer move/disconnect scenarios are unfinished. User saves and live profiles were not touched.

## Shared modern battle HUD and bundled animated backs — 1.23.0-test.7

Gen 1 staged battles now have separate projected status cards for all four double battlers and compact commands drawn after attack effects. MODERN BATTLE UI is a live shared setting across all three generations; OFF retains native UI. Gen 3 exposes the existing shadow, world-curve and wireframe controls. The selected-art renderer can reuse the bundled animated BW back atlases for dex 1–251; missing species retain static fallback. Custom installed atlases remain first priority. Crystal remains the default Gen 1/2 sprite pack.

TEST PRERELEASE: published before gameplay testing as requested. Full cross-generation parity, Gen 3 shiny-context handling, animated front coverage and advanced multiplayer scenarios remain unfinished.

## Crystal interface ownership — 1.23.0-test.6

Fixes the inherited Gen 1 summary/dex/title ownership conflict: the selected-art interface renderer no longer restores its cached first image over Crystal animation. Gen 1 evolution also retains the mon’s shiny variant. Includes the integrated Crystal sprite pack (Gen 1/2 default), shared manager/in-game controls, full-body staged backs and removal of the separate cart dependency.

Verified on official Gen1Recomp 0.3.1 with isolated scripted profiles: Yellow/Crystal packaged test.5 sprite/settings checks; shiny reveal lifecycle; full-body frame changes and shiny variants; option opt-out; no duplicate sprites in inspected battle captures. A native two-client Gen 1 double battle rendered four animated battlers, completed with matching state hashes/results, preserved the owned parties and kept both players connected. FireRed test.5 exact cart boot/lab/field checks passed. The corrected Gen 1 summary animation passed a local regression fixture. Broader visual/mechanical parity remains unfinished (including Gen 1 partner HUD layout and unsupported generation adapters).

TEST PRERELEASE; final packaged follow-up checks follow publication. Select SPRITE PACK (RESTART) > SELECTED ART and restart to use the other Battle Art collections. HGSS remains overworld-only. Crystal’s optional full-body staged backs are Gen 5 artwork, distinct from its Crystal front/menu art.

## Crystal settings integration — 1.23.0-test.5

Crystal presentation controls now share the Battle Art mod settings and inherited in-game submenu, with migration of existing preferences. Avoids requiring Gen 1 OptionRows on Gen 2. Includes the integrated Crystal sprite pack, default in Gen 1/2, and optional animated full-body staged backs.

Test.4 packaged Yellow/Crystal fixtures passed single-owner selection, animated full-body frames, shiny variants, animated fronts, in-game controls and opt-out. Both battle captures inspected: one sprite per Pokemon. FireRed cart boot/lab/field checks passed. Prior static camera exit regression passed all three generations. This update receives its own follow-up checks after publication. Menus/evolution, shiny reveal timing and advanced battle scenarios still need visual coverage; full all-mod cross-generation parity remains unfinished.

## Integrated Crystal sprite pack — 1.23.0-test.4

Battle Art integrates Crystal Animated Sprites with Shiny Visuals 2.1.0: Crystal normal/shiny frames, sparkles and reveal audio, cry timing, trainer portraits, overworld skins, menus, evolution and move-effect presentation. Crystal is the default sprite pack for Gen 1/2; Gen 3 retains its selected Battle Art collection. Optional animated Gen 5 full-body staged backs are included and enabled. The separate Crystal sprite mod is no longer required.

SPRITE PACK (RESTART) switches between CRYSTAL and SELECTED ART; restart after changing it because the pack installs native menu and battle adapters. Existing Crystal preferences are preserved in the save options. CRYSTAL SPRITES retains its five presentation controls; FULL-BODY BATTLE BACKS is now a Battle Art option. Gen 1 doubles animate both enemy slots and can use both full-body player backs. One renderer owns species and trainer art.

TEST PRERELEASE, published before gameplay verification as requested. Prior camera regression fixture reproduced the old failure, then passed with test.3 in Yellow, Crystal and FireRed (lab-to-town transition and movement). Full feature/visual parity across generations remains unfinished; adapter-pending settings are not claimed functional.

## Unified Battle Art test release — 1.23.0-test.2

Battle Art now uses its existing ownership settings and animated-atlas decoder across Gen 1, Crystal and native FireRed/LeafGreen. Working shared controls: BATTLE ART, ANIM FRONT GEN, BACK ART SET, PLAYER and DUPLICATE FIX. Gen 5 animation uses user-installed atlases; the supplied BW images are STATIC full-body fallbacks, never decoded as animation sheets. All four double battlers use the selected art. HGSS remains overworld-only. No separate BW sprite mod is needed.

**TEST PRERELEASE — published before gameplay testing at the user’s request.** Includes the preceding right-stick, door/healing projection, settings inventory and Gen 1 online-double work. Unsupported generation-specific settings are read-only, explicitly marked ADAPTER PENDING. Native gameplay and advanced doubles verification remain pending.

> Test build 1.23.0-test.1: Complete in-game settings inventory across generations; options without a generation adapter are explicitly read-only. FireRed/LeafGreen right-stick look and world-space door/healing effect presentation preserve the 2.5D view. Gameplay verification pending.

**1.22.0: Original-art scenery and Oak lab models.** Original tree artwork is now the default in Crystal and FireRed/LeafGreen, with optional illustrated trees and flat or modeled trunks. Adds closed roof eaves, LeafGreen tileset aliases, modeled Oak lab furniture, supported starter balls and Pokédex items, and native in-game settings. Keeps native battle cards separated.

Specialty interiors, forest gates and broader visual coverage remain unfinished.

**FireRed preview (1.21.0-beta.3):** install this mod separately in FireRed
on Gen1Recomp **0.2.73+**. Outdoor 2.5D rendering and camera controls are now
available at display resolution, with complete gym exteriors, shared city buildings, outdoor props and initial home/lab
furniture profiles. Specialty interiors and battles retain native presentation. This is an early
port, not full Crystal/Gamma Emerald parity. [Scope and controls](docs/FIRERED_SUPPORT.md).
The sealed Johto cart remains Crystal-only on its stable release.

**Unreleased interior pass:** shared cutaway room framing, warm lighting and
compact-room camera fitting across Gen 1, Crystal and FireRed. FireRed Marts
and Centers now have native-art furniture depth. [Coverage and remaining work](docs/INTERIOR_DIORAMAS.md).

**Upstream 1.11.0 integration:** includes capture-contact recoil, scoped battle
fire lighting/effects and optional trainer-shadow provider support. Existing
Crystal and FireRed features are retained.

# Battle Art Voxel Fork

**Crystal 1.20.3:** Japanese-inspired ceramic pitched roofs with curved tile
channels, capped ridges and shaded eaves. Static-view foliage stays fixed;
first-person, rotating-third-person and battle foliage faces the camera.
[Visual coverage and remaining work](docs/CRYSTAL_VISUAL_COVERAGE.md) records
what has actually been checked; all-map visual perfection is not claimed.

**1.17.2 — Layered Crystal 2.5D:** illustrated curved tree canopies, low shrubs with separate cuttable saplings, small flowers, irregular reef stones, softened wet-sand shores, expanded furniture and floors, and optional lighting/Depth of Field. 2.5D is the default Crystal style; the previous style selector is removed. [Settings, coverage and verification](docs/CRYSTAL_1_17.md).

**TEST137 Tower master and wall finishes:** adds a true **TOWER VISUALS** A/B switch as the first row in **LEGENDARY VISUALS → POKEMON TOWER**. `BATTLE ART` restores the original Tower atlas, wall height, floor, counter, graves and stairs and disables the added fog/details; `LEGENDARY VISUALS` restores the complete Tower conversion. A new **TOWER WALL** row selects the existing dark `SMOKE BLACK` granite or the new 2048px `STORM WHITE` and `PEARL WHITE` reference-matched slabs. TEST137 also closes claimed grave-floor gaps in staged battles so the blue scene void cannot show between monuments. Keep **Grass and Flowers TEST4** and **Battle Cinematics TEST5** as the companion mods. See [TEST137 notes](docs/TEST137.md).

Battle Art Voxel Fork turns the overworld of the [Pokémon Gen 1 Recompilation Project](https://github.com/bryanthaboi/pokemon-gen1-recomp-project) into a 3D voxel diorama and stages battles inside that world. It also provides configurable static and animated battle sprites, arena backdrops, trainer art, first-person exploration, water reflections, lighting, and compatibility hooks for other presentation mods.

The stable line supports **Pokémon Red, Blue, Yellow, Gold, Silver and Crystal**; the native path also supports **FireRed and LeafGreen**. Current native verification uses Gen1Recomp 0.3.20. Gen 2 supports the diorama, staged battles and 1ST/3RD camera-relative native grid walking. Gen 1 keeps its existing free-movement path. The [Gen 2 support notes](docs/GEN1_GEN2_DIFFERENCES.md) distinguish current support from historical limitations.

## Provenance

This is a fork. The lineage is
[TeJota1337/DramaticShapeVoxelMod](https://github.com/TeJota1337/DramaticShapeVoxelMod)
→ [absol89/DramaticShapeVoxelMod](https://github.com/absol89/DramaticShapeVoxelMod)
→ this repository, which adds Gen 2 support. All credit for the mod itself
belongs upstream; the tile and sprite data the geometry is derived from is
[pret/pokered](https://github.com/pret/pokered) and
[pret/pokecrystal](https://github.com/pret/pokecrystal).

Two additional input fixes are adapted from [artyrambles/DRAMALESS_SHAPE](https://github.com/artyrambles/DRAMALESS_SHAPE); its [MIT notice](docs/licenses/DRAMALESS_SHAPE.txt) is retained.

**No licence is declared for the rest of that chain**, so no redistribution terms
are granted and none are claimed here. This fork exists under GitHub's own
forking terms. If you are the upstream author and want it taken down or
licensed differently, open an issue.

## Highlights

- Extruded terrain, buildings, foliage, figures, depth-buffered occlusion, cast shadows, and optional tilt-shift and world curvature.
- Cavern walls and ledge risers use amplified continuous geology—deep warped strata, recessed fissures, eroded crags, and a heavy broken wall-to-floor transition—while both low ground and raised walkable corridors use dark, flat-shaded compacted dirt packed with dense, irregular soil speckles. FULL cave detail adds restrained irregular torch falloff, rock-blended water sources, animated 3D droplets, organic multi-lobed pools and ripples, drifting mineral motes, solid stalactites, and a high-vaulted continuous faceted ceiling with refined naturally fused hanging clusters and a battle-safe arena opening.
- Voxel water with waves and sky reflections; FULL reflections also include visible shoreline, trees, buildings, and characters.
- First-person free look and analog movement while retaining the engine's collision, encounter, warp, ledge, and script behavior.
- Battles staged over the current map with an over-the-shoulder camera, parallax, depth of field, configurable HUDs, and optional Gen 6-style backdrops.
- Static or animated Pokémon art from Gen 1 through Gen 5 collections, trainer portraits, player intro art, native shiny detection, and safe ROM fallback.
- Compatibility with [Stadium Battle FX](https://github.com/anxiousintrovert/StadiumBattleFX) attack effects, Gen 3 Battle UI, the [Stadium 2 Importer](https://github.com/Deftones565/gen1recomp-mod-stadium2-importer), and Kanto First Person.
- Two performance paths: persistent disk precaching on legacy engines and sandbox-safe bounded mesh streaming on current engines.

## Engine compatibility

| Gen1Recomp version | Support | Mesh behavior | Persistent precache |
| --- | --- | --- | --- |
| `0.1.69–0.1.83` | Supported | Legacy filesystem/FFI mesh path | Available from the title and pause menus |
| `0.1.84+` | Supported | Packed `ByteData` meshes held in session memory | Unavailable; the sandbox blocks the required raw filesystem and FFI access |
| Earlier than `0.1.69` | Unsupported | Missing APIs used by Battle Art 1.9.0 | Not a supported configuration |

The `0.1.83` boundary is inclusive: persistent BAVC precaching works through `0.1.83`. Starting with `0.1.84`, the mod hides the `PRECACHE` and `CACHE` actions and uses the newer sandbox-compatible path automatically. This is expected behavior, not an incomplete installation.

Some older engine builds exposed enough filesystem functionality for the cache backend itself, but Battle Art 1.9.0 as a whole requires APIs introduced in `0.1.69`. Those older builds are therefore not advertised as supported merely because they can write a cache file.

On recent engines, `R.DIST: MEDIUM` is the default. It bounds connected-map work to 32 Gen 1 cells (512 world pixels) while the current map remains complete. `SHORT`, `FAR`, and `FULL` are available for lower-end hardware, wider views, or comparison.

The manifest accepts the development build identifier and stable versions in the range `>=0.2.73 <3.0.0`.

## Installation

1. Install a supported Gen1Recomp build and import Pokémon Red, Blue, or Yellow.
2. Download a package from [Releases](https://github.com/absol89/DramaticShapeVoxelMod/releases), or clone this repository.
3. Put the mod folder in the game's `mods` directory. A normal Windows installation uses `%APPDATA%\pokemon-love2d\mods\BATTLE_ART_VOXEL_FORK`.
4. Enable **BATTLE ART VOXEL FORK** in the Mod Manager or in a profile.
5. Optionally import or add battle-art PNGs as described below. Missing art always falls back to the ROM.

The mod conflicts with the original Dramatic Shape, Dramaless Shape, and Potato Voxel renderers because they compete for the same world presentation.

## Feature sets

### Voxel overworld

The renderer turns map blocks into a perspective diorama instead of flattening them into a single plane. Terrain, water, structures, grass, flowers, authored figures, NPCs, and overworld Pokémon retain their normal game state while the mod changes how they are presented.

Key visual controls include:

| Option | Choices | Purpose |
| --- | --- | --- |
| `VOXEL` | `OFF`, `FULL`, `15`, `35`, `50`, `75`, `1ST`, `3RD (EXPERIMENTAL)` | Flat view, complete diorama preset, pitched orbit cameras, first person, or experimental third person |
| `V-GRID` | `OFF`, `ON` | One-pixel voxel wireframe |
| `T-SHIFT` | `OFF`, `1`, `2`, `3` | Miniature depth blur |
| `V-CURVE` | `OFF`, `1`, `2`, `3` | Curves the distant world toward the horizon |
| `SHADOWS` | `ON`, `OFF` | Cast or fallback sprite shadows |
| `AA` | `OFF`, `2X`, `4X` | Supersampled edge smoothing; the most expensive visual option |
| `R.DIST` | `SHORT`, `MEDIUM`, `FAR`, `FULL` | Limits adjacent-map rendering work |
| `DAYTIME` | `SYNC`, `DAY`, `NIGHT`, `DUSK`, `DAWN`, `CYCLE` | Controls outdoor lighting and sky time |
| `LEGENDARY VISUALS` | `OFF`, `CUSTOM`, `AUTO`, `FULL` | Master world-visual profile: protected Battle Art, remembered individual choices, balanced complete Legendary presentation, or maximum supported Legendary detail |
| `LEGENDARY PILLARS` | `BATTLE ART`, `SEPARATE`, `BOTTOM LINK`, `TOP INTERLOCK` | Selects the original or community granite pillar layout |
| `WALL & LEDGE COLOR` | `GRANITE`, `RED BRICK`, `SANDSTONE`, `SLATE` | Selects Legendary masonry material |
| `CAVES` | `BATTLE ART`, `LEGENDARY VISUALS` | Selects the original cave or the natural rock walls and dark granular dirt path |
| `CAVE DETAILS` | `OFF`, `SUBTLE`, `FULL` | Adds animated 3D wall torches on dark forged-charcoal hardware with layered iron tones and a heat-warmed burner rim, plus sampled-height amber floor falloff, compact patch-sourced teardrop droplets, layered wet landings, faceted rubble, stalagmites and drifting low-poly moisture motes; FULL adds tiny embers, denser solid upper-wall stalactite clusters, rare fused columns, Waterworks-inspired irregular pools with defined shores, animated shimmer and ripples, brighter droplet splashes, low damp haze, and a high-vaulted welded low-poly roof visible from first- and third-person cameras. Refined asymmetrical stalactites descend directly from that roof into the black overhead void with no floating caps. Exploration draws the complete seamless canopy, battles retain its surrounding sections while opening the arena itself, and orbit views hide both the roof and its attached clusters together. Torch-near formations and motes receive warm highlights, and walls remain solid with no transparent ghosting overlays. |
| `CAVE SOUND` | `OFF`, `LOW`, `MID` | Adds optional cave ambience plus an audible rock footstep on each 8-pixel Gen 1 tile step, loaded directly from packaged or unpacked installs independently of cave geometry |
| `TOWER VISUALS` | `BATTLE ART`, `LEGENDARY VISUALS` | Selects the stock Lavender/Tower presentation or the Gothic Lavender exterior plus added Tower materials, taller walls, modeled counter/stairs/graves, fog, and detail passes |
| `TOWER WALL` | `SMOKE BLACK`, `STORM WHITE`, `PEARL WHITE` | Selects one of three continuous 2048px luxury-granite wall slabs while Tower Visuals is enabled |
| `TOWER DETAILS` | `OFF`, `SUBTLE`, `FULL` | Controls high Tower sconces, living wall light, embers, and the reception counter's brass accent independently of fog |
| `TOWER FOG` | `OFF`, `ON` | Toggles the connected white-grey rolling fog on Pokemon Tower grave floors; reception remains clear |
| `FOG THICKNESS` | `LIGHT`, `NORMAL`, `THICK`, `HEAVY` | Changes Tower fog opacity and vertical body without widening its grave-zone footprint |
| `FOG SPEED` | `SLOW`, `NORMAL`, `FAST` | Changes Tower drift, breathing, and evaporation speed without jumping animation phase |
| `TREES` | `BATTLE ART`, `LEGENDARY VISUALS` | Selects the original or community S/M/L/XL tree family |
| `SIGNS` | `BATTLE ART`, `LEGENDARY VISUALS` | Selects stock sign art or the low horizontal Kanto wayfinders with clipped timber, enamel faces, Poké Ball badges and live route/town/facility labels, now including Viridian Forest; Cerulean Gym receives dedicated wall clearance |
| `SKY & BACKGROUND` | `BATTLE ART`, `LEGENDARY VISUALS` | Adds the seamless sky, deep Legendary night, animated stars, painted mountains, and distant Kanto terrain |
| `VIRIDIAN FOREST` | `BATTLE ART`, `LEGENDARY VISUALS` | Adds the authored taller tree layout, stitched canopy, layered haze, animated leaves, varied moss-and-litter floor, camera-stable crossed grass and deterministic mossy boulders in Viridian Forest |
| `FOREST FX` | `LOW`, `OFF` | Enables or disables the approved Viridian haze and guarded depth-aware light shafts |

`WORLD FILL` controls empty space below and outside the world:

- `CYAN` is the default classic underlay.
- `BLACK` uses the dark `#181818` underlay.
- `OFF/KFP` draws no underlay, allowing Kanto First Person to own that space.
- `NATURE` uses the cyan underlay and adds biome-aware trees or rocks; selected
  forest, Safari-house and Seafoam void maps use black and stay clear.

With `NATURE`, transparent nature billboards populate 16×16 world cells beyond
the loaded map and its connected neighbors where the map's fill profile allows
them. Towns, forests,
and leafy routes continue with trees; Safari/open-field routes use broadleaf
trees; rocky routes (including Route 23) and cavern maps use rock pillars.
Their variant and 100%/150%/200% size are randomized deterministically, so they do not
flicker when the camera moves. Authored ROM cells always remain unobstructed.

### Water and sky

The sky keeps the active `DAYTIME` palette but blends its colors continuously
from zenith to horizon, including twilight glow and the shader fallback.

`WATER` has three levels:

- `OFF` disables the voxel water pass.
- `SKY` draws pixel-height waves reflecting the current sky, sun or moon, and staged battlers.
- `FULL` adds screen-space reflections of visible shoreline, trees, and buildings.

The outdoor sky, shadows, flat-world tint, and water share the same clock. Gen 6 battle backdrops snapshot the current dawn/day/dusk/night period when a battle starts, so a time change cannot abruptly replace the backdrop during that battle.

### First- and third-person modes

Choose `VOXEL: 1ST` to enter the player's viewpoint. Look with the mouse, right stick, or a touch drag; move with WASD, the left stick, or the touch D-pad. Mouse left click acts as A and right click as B while pointer capture is active.

`VOXEL: 3RD (EXPERIMENTAL)` uses the same free-look and free-movement rig with the camera pulled back behind the player. Moving between `1ST` and `3RD` slides the eye along that camera boom instead of cutting between unrelated views.

Both free-camera modes still ask the Gen 1 engine about collision and run its landing pipeline for every crossed cell. Warps, encounters, ledges, gates, and scripts therefore remain engine-owned. Selecting an orbit or flat `VOXEL` mode restores ordinary grid movement.

### Staged battles and arenas

`3D-BTL` stages battles on nearby clear ground in the current map. It is enabled by default and does not require the free-roam `VOXEL` camera to be pitched.

Presentation controls include:

| Option | Choices | Purpose |
| --- | --- | --- |
| `STANDING TRAINER` | `STOCK`, `LEGENDARY` | Lets a compatible 3D-player provider keep the trainer in the staged arena |
| `ARENA FILL` | `OFF`, `WHITE`, `GEN6`, `PNG`, `BLUE` | Voxel level, flat Battle Art arena, or Stadium's blue arena |
| `STADIUM CIRCLE` | `ON`, `OFF`, `HALF` | Independently selects full, hidden, or two-thirds-radius Stadium ground circles when supported |
| `BG Y-OFFSET` | `0` to `400` (default `100`) | Vertically crops a selected backdrop |
| `BOSS BG` | `ON`, `OFF` | Allows special boss backdrops |
| `SPRITE LIGHT` | `SHADED`, `UNLIT` | Lets battle cards receive world lighting or preserve source colors |
| `HUD COLOR` | `COLOR`, `INVERTED` | Dark or light HUD glyph treatment while retaining HP colors |
| `TEXTBOX FILL` | `WHITE`, `HALF`, `BLACK`, `OFF` | Controls the native text and menu paper independently of the arena |

`ARENA FILL: GEN6` selects backgrounds using map location, encounter type, surfing/fishing state, boss state, and the time captured at battle entry.

### Battle art

`BATTLE ART` controls Pokémon sprite ownership:

- `STATIC` reads ordinary species PNGs.
- `ANIMATED` reads the selected animated front set and compatible animated/static back set.
- `ROM` bypasses imported Pokémon art.

Front collections can be selected from Gen 1 through Gen 5. Gen 1 animated-mode fronts are single-frame compatibility PNGs; Gen 2–5 fronts are atlases. Back collections also expose Gen 1 through Gen 5: Gen 3 and Gen 5 can animate, while Gen 1, Gen 2, and Gen 4 use static PNGs.

Additional controls choose player front/back presentation, player-card mirroring, automatic/world/original-UI back placement, opponent trainer generations, and static or five-pose player trainer introductions.

`DUPLICATE FIX` separates sprite ownership from other mods:

- `BATTLE ART` makes this mod own normal and shiny battle sprites. It evaluates the Gen 2 DV shiny formula itself and routes qualifying Pokémon to matching shiny assets without relying on Crystal or another shiny mod's API.
- `MODDED` yields Pokémon battler-picture ownership to another Pokémon sprite provider or the ROM while retaining Battle Art's arena and camera features. It does not control move or attack-effect sprites.

Ditto Transform is tracked independently, so transformed art follows the species currently being presented. Missing, malformed, or unreadable assets fail open to the original ROM sprite instead of aborting the battle.

### UI and mod compatibility

- Gen 3 Battle UI automatically receives the HUD, text/menu, and panel surfaces when its revamped battle UI option is enabled. Unsupported scripted phases retain the native presentation.
- The older Gen 1 Modern UI adapter is recognized when its experimental battle UI option is enabled.
- [Stadium Battle FX](https://github.com/anxiousintrovert/StadiumBattleFX) can retain its Stadium move effects and announcer while Battle Art owns the staged arena, cards, and camera. Keep `3D-BTL: ON`; no `DUPLICATE FIX` setting is required because its attack-effect sprites are not Pokémon battler pictures.
- The [Stadium 2 Importer](https://github.com/Deftones565/gen1recomp-mod-stadium2-importer) can provide Stadium 3D models through the staged-battle compatibility interface. This is the supported Stadium model path; it is separate from [Stadium Battle FX](https://github.com/anxiousintrovert/StadiumBattleFX), which supplies attack-effect sprites.
- Effects mods can inspect the same read-only staged-battle descriptor rather than importing Battle Art internals.
- `OFF/KFP` leaves the world underlay to Kanto First Person.
- `MODDED` leaves Pokémon battler-picture drawing to another Pokémon sprite provider or the ROM.

## Persistent precache on `0.1.69–0.1.83`

On legacy engines, the title menu's `PRECACHE` action opens a cancellable **GENERATE PRECACHE** task. It creates reusable terrain, water, connected-map body, and auxiliary geometry after content mods have patched maps and tilesets. Running it again resumes from valid records instead of rebuilding them.

The files are written only below:

```text
mod-derived/BATTLE_ART_VOXEL_FORK/static-mesh-cache-v2
```

The cache does not store runtime NPCs, spawned overworld Pokémon, or temporary script changes. Live map changes are meshed in RAM; returning to the canonical layout reuses the disk record. A human-readable `static-cache-exclusions.tsv` records intentionally excluded runtime objects and noncanonical geometry.

If generation ends as `INCOMPLETE`, inspect
`mod-derived/BATTLE_ART_VOXEL_FORK/precache-failures.tsv`. It is regenerated
for each run and lists the failing map and slot, the logical cache key, the
actual legacy `.bavc` path, the failure stage, and the storage/encoder error.

BAVC is a versioned, fingerprinted, LZ4-compressed geometry container. Corrupt or truncated records safely fall back to cooperative mesh generation. Cache size depends on the imported ROM and installed content and can reach hundreds of MiB. The directory is disposable: deleting it only makes the mod regenerate those meshes. The pause-menu `CACHE` action can save or drop accumulated legacy-engine RAM cache work.

## Sandboxed mesh streaming on `0.1.84+`

Current engines do not grant content mods the raw filesystem and FFI access used by the persistent cache. Battle Art instead packs mesh vertices into bounded `ByteData` buffers, uploads them through the supported API, keeps only the current session's useful meshes in memory, and releases map meshes as they become unnecessary.

There is no precache button in this mode. Use `R.DIST` to trade connected-world breadth for loading time and memory use; `MEDIUM` is the recommended default. All supported voxel, camera, battle, battle-art, backdrop, and compatibility features remain available.

## Controls

The hotkeys work in free roam and mirror rows in the Options menu:

| Key | Option |
| --- | --- |
| `3` | Cycle `OFF`, `15`, `35`, `50`, `75`, `1ST`, and experimental `3RD` (`FULL` remains an Options-menu preset) |
| `5` | Toggle `V-GRID` |
| `6` | Cycle `T-SHIFT` |
| `7` | Cycle `V-CURVE` |
| `8` | Toggle `3D-BTL` |
| `9` | Cycle `WATER` |

The `Y-CONTROL INVERT` option reverses vertical look input in 1ST/3RD only;
it is OFF by default and does not affect overhead camera controls.

Battle Art suppresses the engine's flat `TILT` and full-screen `GBC FX` while installed because those passes conflict with the 3D renderer. Uninstalling the mod restores their normal rows and saved values.

## Bring your own battle art

Local battle PNGs are ignored by Git. The repository supplies folder contracts and importer tools, while a missing file always falls back to ROM art.

| Purpose | Folder |
| --- | --- |
| Static species fronts | `assets/battle/front-static/` |
| Gen 1 single-frame and Gen 2–5 animated fronts | `assets/battle/front-animated/gen1/` through `gen5/` |
| Static species backs | `assets/battle/back-static/gen1/` through `gen5/` |
| Animated Emerald and Black/White backs | `assets/battle/back-animated/gen3/` and `gen5/` |

Use lowercase species filenames such as `pikachu.png`, `caterpie.png`, `farfetchd.png`, and `mr-mime.png`. The Nidoran files are `nidoran-f.png` and `nidoran-m.png`. Place shiny variants in the corresponding documented `shiny` folder. Each battle-art directory contains a README describing its exact file and atlas contract.

Static PNGs are used at native resolution. Existing alpha is preserved. For an opaque source image, the border-connected corner color is keyed transparent while enclosed matching pixels remain intact. Enemy fronts face left; player fronts can be mirrored by the mod; authored back art should face right.

The `tools` directory includes importers for Crystal, Emerald, Platinum, Black/White, extended Gen 2–5 species sets, shiny collections, static illustrations, and animated atlases. These scripts prepare local art without committing it.

- `tools/package_mod.ps1` creates a local test package including your ignored battle PNGs.
- `tools/package_clean_mod.ps1` creates a shareable package that preserves the folder contracts and tools but excludes local battle PNGs.

## Integration API for mod authors

Replacement UIs can wrap `battle.presentation.suppress_native.v1`. A consumer receives the API version, source ID, requested `hud`, `text`, or `panels` surface, and the current battle when available. Return exactly `true` only when the consumer draws the complete requested surface; absent, failing, or false consumers leave Battle Art's native surface enabled.

The exported descriptor is available at:

```lua
mod.find("BATTLE_ART_VOXEL_FORK").exports.battlePresentation
```

Effects and presentation mods can inspect staged battle placement through:

```lua
local stage = mod.find("BATTLE_ART_VOXEL_FORK").exports.battleStage
local state = stage and stage.state(battle)
```

API version 1 is observational and read-only. A staged session reports `staged = true`; `ready` becomes true when the first projected shot exists. Ready state includes copied player/enemy anchors, sprite placement, animation scale, layer transform, and ownership declarations for the arena, battlers, trainers, camera, HUD, transitions, and animation projection. Consumers can align effects or yield competing presentation without retaining live internal tables.

### Optional Stadium 2 models

When `STADIUM2_IMPORTER` exposes its scene-neutral model API v2, its two
provider toggles select the Pokemon art automatically. With both `STADIUM 2
MODELS` and `STADIUM 2 BATTLE` on, Battle Art replaces Pokemon cards in the
staged voxel arena with independently owned model instances. Turning either
importer option off releases those instances and restores Battle Art sprites.
Battle Art reads these options but does not rewrite them.

Models use Battle Art's camera, depth target, placement, day tint, timing and
shadow map. Battle Art continues to own terrain, trainers, HUD, menus, attack
overlays and battle logic. Trainer portraits always remain cards. If the
provider is absent or disabled, a model cannot load, or a side fails to update,
draw or cast a shadow, that side retains its Battle Art card fallback.

When the importer owns its complete Stadium battle scene, Battle Art registers
`exports.scene` environment and background providers. `ARENA FILL: OFF` uses
the captured voxel battle level through Stadium's live camera, so zoom, orbit,
models and attack anchors remain one composition. `WHITE`, `GEN6`, and `PNG`
replace the arena, while `BLUE` selects the importer's native blue background.
`STADIUM CIRCLE` independently draws the imported ground platform at full or
two-thirds radius, or hides it. The row is absent and inert without a compatible
Stadium scene. Stadium models cast into the voxel terrain shadow map whether
or not the circle is visible. With a flat WHITE, GEN6, PNG, or BLUE plate and
the circle hidden or reduced, an invisible ground plane receives only the
model-shadow pixels beyond the visible platform so the models remain planted
without a clipped shadow or an additional platform. Missing
optional artwork safely falls through to Stadium.

`INTERFACE SPRITES: BATTLE ART` uses the selected regular-form front outside
battles independently of `DUPLICATE FIX`. The title and Gen 1 summary screen
play supported animated generations with their authored frame timing and
true-color palette, including compatible atlases returned by another sprite
provider in clean builds. The summary's HP gauge remains the engine's native
shaped, palette-aware tile bar. Interfaces that accept only a static path retain
ROM art for atlas-based generations rather than drawing an undecoded sheet.

For Stadium 3D models, use the [Stadium 2 Importer](https://github.com/Deftones565/gen1recomp-mod-stadium2-importer), which integrates through this staged-battle interface. [Stadium Battle FX](https://github.com/anxiousintrovert/StadiumBattleFX) replaces attack effects instead of Pokémon battler pictures, so it does not require `DUPLICATE FIX: MODDED`.

## Gen 2 status

Battle Art 1.9.0 is Gen 1 only. The renderer, shaders, asset resolvers, shiny predicate, battle-art formats, and presentation API are reusable, but the current boot sequence directly wraps Gen 1 world, map, battle, UI, script, and input modules. Gold exposes separate stacks that must be mapped and tested deliberately.

The [Gen 1 and Gen 2 differences and porting guide](docs/GEN1_GEN2_DIFFERENCES.md) lists the confirmed blockers, reusable portions, and a staged porting plan for anyone working on Gen 2 support.

## Optional Legendary media

Place the separately supplied Legendary PNG/MP3 files in `assets/legendary/`
inside this mod, retaining their filenames. This supplies Tower materials,
the outdoor backdrop and cave audio. The folder is ignored by Git; source
checkouts need the separate media overlay. Optional missing media retain
the existing fallback behavior.
