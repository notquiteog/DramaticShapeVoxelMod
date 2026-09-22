# Working checkpoint — illustrated tree cards / 0.2.73 — 2026-09-21

User's FINAL tree direction supersedes the anchored multi-layer prototype:
use flat illustrated foliage. One card per tree; NO 3D cap/cheeks/stacked crowns.
Billboard in yaw AND pitch for overhead, 1ST, 3RD and battle views. Original trunks/boughs use negative anchor Y to keep upper wood behind its own foliage plane; grounded bases stay unchanged. Same art/recipe for border fill. Three tree families plus
low shrubs and cut saplings remain. VertexCanopy stores anchor X/Z/Y now; negative Y marks upper-wood
occlusion and zero means ordinary solid geometry. Cache55. Each tree
uses six streamed foliage vertices (two triangles), down from up to216.
Native shadow pass includes the foliage card for its existing nearest section.

User pushed the previous batch: BA1.20.0, Sky Ride0.2.23, Double Battles0.9.4,
cart1.12.1. Crystal full-body provider was still uncommitted/unpinned. Current
batch prepares BA1.20.1, sprites2.1.0 and cart1.13.0. Earlier local 1.20.1 zip
and 26a4149 crown prototype are superseded and MUST NOT be shipped.

Native QA uses the actual 0.2.73 AppImage payload/binary from the user's Apps
folder, extracted at /tmp/johto-hd/squashfs-root. QA main.lua alone is patched:
script boot honors --cart; driver updates call PlatformHooks.update(Game,1/60).
Runtime/cart scope asserted. System LOVE uses ~/.local/share/love; AppImage
uses ~/.local/share. Only disposable johto-appimage-qa modified; no live user
profile/input. Old /tmp files disappeared between sessions: historical logs
are not current evidence.

Evidence before the final archive verification:
- tree-depth-0273.log runs GPU four-heading + overhead/local-anchor/unaffected
  solid geometry plus upper-wood depth checks,18 world views at2560x1440 across New Bark/Route29,
  then five staged species entered with 1ST selected.
- heal-mount-0273.log PASS: six native healing balls in Center/Elm machine,
  horizontal bed alignment and animation completion; follower-backed Raikou,
  cropped rider in diorama/3RD, no rider in1ST, dismount restores native player.
- Pure style/geometry, Legendary trees141, mesh cache40, support181,
  Gen1 heal63 and battle-occlusion group/depth/floor tests pass.
- Installed modkit reports SIX MK301 ROM-cache findings. Every reported file
  was byte-identical to pre-change HEAD. Do not call validation clean.

Crystal sprites2.1.0 finishes last session's stagedPokemonSprite provider:
502 normal/shiny BW back atlases for251 species,36,469 nonempty frames checked
for dimensions/timing. Generated art is release-only; URLs/hashes and credits
accompany it. Cart enables full_body_backs; standalone default stays off.
Native 0.2.73 checks: animated/shiny Cyndaquil, Totodile, Chikorita, Raikou,
Ho-Oh and option-off fallback. Native menus retain Crystal art.

Limits: paired allied commands and multiplayer doubles remain unfinished;
no Internet test. Exact Gamma parity, all maps and hardware performance remain
unverified. Wilds still emits occasional existing pose-fallback warnings.
Release hashes and exact packaged-cart verification go in the follow-up.

# Working checkpoint — target input, encounter ownership, dialogue look — 2026-09-14

Published BA1.19.1, Double Battles0.9.3, cart1.12.0.
BA runtime ae0c0fc71825609fb157de54686f7dd94e019f5f; ZIP SHA256
5705c92215d0dc3b0a6167626f5b9d5cafe80027d273ea7b52c06e237204baec.
Double Battles9ec5d57f3762d1f74aa6ae358cebce08c3438820; ZIP SHA256
f2f9f12acf0f79b46f860761811c34431e79010e99a6ab35ebef3cbde69e81fc.
Cart77a8f7f15220bf39a8f376cd1f064358b75535c4; cart SHA256
07c86143d1e26e50a328aae1523a243456b1ce128fbe44e4e4f137ebf239e17b.
Latest user asked whether general doubles logic and multiplayer were fully
finished/verified. Answered NO explicitly. Crystal normal UI still commands
one player-side active; paired ally command collection and full spread-move/
doubles mechanics parity remain unfinished. Online+ pvp/session exchanges one
action per player; no doubles network protocol exists. Do not claim online
2v2 support or a two-computer Internet playtest.

Double Battles: new gen2_target.lua wraps native submit/update. A move enters
opponent selection only while two living enemies exist; directional aim, A
confirm, B cancel, no PP/turn consumption until confirm. Modern HUD renders
choices and highlights selected foe. Core already honors action.target.
Automatic wild partners now require the scoped World.tryWildEncounter ->
rollEncounter(kind=wild,terrain=grass/water) -> startBattle origin. Scope restored
on errors/return; direct mod, visible spawn, fishing and special calls remain
singles. Partners use matching terrain table; SOMETIMES now rolls its30% chance.
Trainer auto-decoration also requires current World.startBattle scope: Online+
and native link set pvp/link flags AFTER Battle.new emits battle.started, so a
flag-only guard is too late. No runtime reads of another mod's private files.

BA: FirstPerson.looking separate from driving. Crystal world scripts and only
text-box stacks allow look; movement retains original busy/stack gates. Menus,
battles and text over another screen do not grant world-camera ownership.
Public input.gamepad and input.pointer carry Gen2 stick/touch alongside mouse.

Validation (disposable AppImage QA profile, 0.2.60 update, core.update enabled):
- /tmp/johto-hd/target-093.log PASS: supplied spawn/fish mon identity/HP retained;
  native random doubles; choose either target via native input, cancel no PP;
  selected damage only; next mod spawn cannot inherit random origin. Screenshot
  target-093/target_second.png reviewed at2560x1440.
- /tmp/johto-hd/dialogue-1191.log PASS: modes6/7 mouse/stick/touch yaw while text
  stays up, no walking, script VM gate permits look, start menu blocks look.
- /tmp/johto-hd/pvp-guard-093.log PASS: two LOCAL Online+ engine/session peers,
  trainer_doubles=true, no auto-decoration,3 mirrored singles rounds match HP/PP.
  Transport is an in-memory test adapter; Internet transport is NOT tested.
- Pure target/cancel/fainted fallback/link tests + HUD DPI/animation capture;
  native engine core39; BA support181 and camera/inversion/movement guards PASS.
- Old native-actions regression uses an explicit pair fixture now; direct mod
  encounter doubling is deliberately removed. It is not a new native-run claim.

Only johto-appimage-qa updated; user profile/live save untouched. All13 source
and index pins match and online packing passes. Exact released archives installed
in QA; cart-1.12.0-final.log asserts real cart scope, Crystal/sealed+/1.12.0,
BA1.19.1,13 companions, hidden HUD, and repeats the full dialogue-camera PASS.
Native log confirms Double Battles0.9.3 loaded. Runtime ZIP predates this
handoff-only follow-up. Previous published checkpoint follows.

# Working checkpoint — scenery + reproduced glitchmon — 2026-09-14

Published BA1.19.0, Online+0.5.5 and cart1.11.0.
Cart source bc51249d04b1e8f49c661a01a1ec6b32e2d5e03b, release v1.11.0.
BA runtime b3d16b195062c175e6ec83631b121457622329db; ZIP SHA256
342e552d1c1287ba4e8d0503a8d1c4a7e406a067bdefd15008d3f2fd096c7b35.
Online+ eb06b95d9124ae691622fde3a390592c8e5a5405; ZIP SHA256
ad5c22f4a848ba074fca75a8e37132beb8e84209b88a7e742b0e7a7d92844074.
0.5.5 normalizes numeric Crystal time-of-day IDs for standalone offline
encounters (0/1/2/3 -> morning/day/night/night); pure roster tests pass.
The cart delegates offline encounters to Wilds. No BA runtime change after1.19.0.
BA: actual crystal_center_healer now horizontal (Elm's earlier separate recipe
was already fixed); PokéCom healer uses bed recipe. Native sign components share
their ground baseline and a shallow backing joins the cap. Capped roof courses,
subtler roof materials, curved side foliage for rotating views, and a free-camera
only upper room enclosure for INDOOR maps. Cache48. Native40-view review passed:
/tmp/johto-hd/camera-scenery-shell.log and image folder; Center placement checks
in center-sign-roof-final.log. Pure geometry/roof/bed/style/material/furniture and
support181 pass. Scenery driver skips story/encounter triggers for visual QA.

ROOT CAUSE REPRODUCED: user confirmed the brown sprite in live X11 window capture
(/tmp/johto-hd/user-game-window; read-only capture, no user inputs injected).
Online+'s core.update job rerolled its offline roster every frame; towns with
empty grass lists randomly inserted/removed rare slots. Eight corrupt rare
entries (New Bark/Cherrygrove + aliases) spell species T/M/C/S with letter-valued
levels and fell back to SPRITE_PIKACHU, whose Wilds placeholder is Charmander.
Native old-code log live-hook-motion.log records repeated NEW_BARK_TOWN_obj_301/
302 with species T/M. It was spawning fresh actors, so per-object displacement
probes could not detect it. Online+ candidate validates species/levels, keeps a
per-visit roster, consumes claimed local entries, removes corrupted database
rows and yields offline wild/follower ownership to Wilds via exported capability
API. Server encounters remain when connected, removed on disconnect with Wilds.
Native copied-save900 frames PASS in live-hook-fixed.log; ambient stays and
adding Cyndaquil leaves exactly one follower. No live server test.

CRITICAL QA CORRECTIONS:
- Actual AppImage profile is /home/admin/.local/share/pokemon-love2d, NOT its
  sibling love/pokemon-love2d. User files untouched. Copied to johto-appimage-qa.
- AppImage filename is0.2.59 but profile chainloads updates/gen1recomp-0.2.60.love.
  Thus patching ONLY AppImage main.lua did nothing! Copied update payload's main
  is patched for QA, no real user engine changed. Source and native059/060 World,
  Npc, Gen2Compat, SpriteRenderer are byte-identical; Game2 changed shader origin.
- POKEPORT_DRIVER skips core.update by calling Game:update directly. For motion
  verification the disposable driver's update branch MUST call
  PlatformHooks.update(Game,1/60). This runs Online+'s actual Jobs.step.
- Script shortcut also ignores --cart. In disposable launcher only, change
  `if scripted then` to `if scripted and not resolvedLaunch.cartSpecified then`.
  Assert SaveData.getCart()==johto_diorama. scope5.log proves it. Earlier cart-path
  checks that asserted only version/HUD did not prove scope in an updated fused
  profile; retain their geometry/input results, not claims about that scope.
- Run source LOVE from /tmp/johto-hd/engine. A repo containing main.lua can shadow
  the intended game even when the LOVE argument points at the engine.
- Support: from engine cwd, DS_MOD_PATH=mods/BATTLE_ART_VOXEL_FORK luajit
  /home/admin/Projects/DramaticShapeVoxelMod/tests/gen2_support_test.lua.

Final 13-pin source/index equality and online cart pack pass; cart SHA256
a0f271d699f43878d1bcad901163f74a3e85c2bce0e12ec416bb37186edbde82.
Packaged native camera-key test with core.update enabled passes all angle
levels, first-person activation, saved choice and menu blocking in
/tmp/johto-hd/cart-camera-diag.log. An earlier failure was a queued text/menu
screen in the copied profile, correctly blocking the hotkey. QA drivers now
clear initial mod greeting/UI after settling before entering free roam; their
explicit menu gating assertion remains. No camera runtime regression found.

Final exact packaged 13-mod cart + normal update hooks: 40 views PASS in
/tmp/johto-hd/cart-camera-scenery-final.log; screenshots in matching directory,
reviewed outdoor/indoor contact sheets. Driver reached final PASS; the launcher
was ended by its timeout during shutdown (not a clean-exit claim). Initial
visual fixture failure was a queued text screen; clearing it after scene settle
fixes the fixture, without changing production menu behavior.
All three towns PASS with Online+0.5.5 in cart-1.11.0-final-055.log: no duplicate
Online actors, one follower, ambient retained. Exact pinned archives installed
ONLY in johto-appimage-qa; user profile and live game untouched.
The camera fixture updates after runtime1.19.0 are QA-only and are not in that ZIP.

Remaining: exact Gamma parity, broader
map/texture polish and hardware performance are not claimed complete.

# Published checkpoint — cart1.10.0 / camera3 restored — 2026-09-14

Released/pushed:
- BA1.18.0 runtime79f0d9a131871f946f601e89ffd4c81bac4146f6;
  ZIP SHA4641547e91f285fcc6d702c196294cb122540f6f97e20e458218d91ead5c5f98.
- Online+0.5.3 e1f4b69b29e16c0fea1c67c9249f80f0fa8aa520.
- Wild Skies1.12.2 c65703c992149d62dd1419a0f3d7cc7f0becf190;
  fork notquiteog/wild_skies, local wild-skies-gen2.
- Cart1.10.0 cb0e39a, Crystal sealed+,13mods,CG3 unchanged.
  SHA346358ac8f8e142d535c052914c94d89160995e1e0e8893ea63454493b590d2b.

Actual packaged cart-path camera test PASS:
/tmp/johto-hd/cart-1.10.0-camera.log. Asserts BA1.18.0 and cart HUD option0,
then real love.keypressed3 reaches first/thirdperson, persists choice and
refuses menu presses. Log confirms all three new companion versions loaded.
Exact bundle/source equality and online pin/hash validation pass. Index meta
pins/load order synchronized. QA cart copied ONLY to johto-parity-qa profile.

Source 1440p doubles attack/KO/escape/animation/party regression PASS:
/tmp/johto-hd/gaps-battle.log. Packaged keyboard test also passes independently
in packaged-camera-1.10.0.log. Five-map/cache/crown evidence and open issues
below remain accurate. Runtime release zip was built before this handoff-only
commit. Do not claim the bouncing actor or exact Gamma parity is fixed.

# Working candidate — camera key and known-gap fixes — 2026-09-14

Latest user request: 3 no longer changes camera including first person.
FIXED: live Game2 has no game.overworld. main.lua now uses pipelineGate and
public input.key before native TILT claims 3. Native keyboard regression passes
levels 4,5,6,7,0,2,3,4 from FULL, first-person activation, persistence and menu
gating: /tmp/johto-hd/gaps-camera-2.log. Gen1 wrapper retained.

BA1.18.0 candidate: native static snapshot/cache rules; open Park bench/bin,
actual radio-desk placement, Center counter-ball crop; shallow illustrated crown
caps; Dark Cave fractured wall surface and floor material. Cache rev47. Pure
support181, furniture47, HD60, geometry and new known-gap tests pass. Final
native five-map test /tmp/johto-hd/gaps-visual-4.log passes 164 RAM records with
encode/decode/warm reload. Screenshots reviewed. Not persistent disk proof.

Online+0.5.3 candidate omits unsupported Gen1 map_scripts registry on Gen2;
Casino Lounge map remains unported. Wild Skies fork1.12.2 candidate imports MIT
upstream release1.12.1, corrects (def,tileset,x,y) collision calls for neighbouring
maps; native seam11 tests pass. Local repo wild-skies-gen2 / origin
notquiteog/wild_skies. Original MIT LICENSE retained.

Bouncing Charmander remains OPEN despite user confirming New Bark/cart1.9.0.
New 900-frame x3city depth/flat probe /tmp/johto-hd/gaps-motion.log found no jumps.
Wilds uses a Charmander placeholder for SPRITE_PIKACHU, but a leaked actor is
only a lead. No speculative clamp or follower hiding. User gameplay save is
not present in the disposable QA profiles. Broader Gamma parity and hardware
performance remain open. Cart1.10.0 packaging/publication is next.

# Published checkpoint — Crystal HD-2D / cart 1.9.0 — 2026-09-14

Latest user request is completed for Crystal: removed the scenery-style
selector and voxel/source alternatives; always use layered HD-2D scenery.
Gen 2's camera row is HD-2D CAMERA. Keep its stable internal pipeline ID for
saved-camera and companion compatibility. Fresh profiles activate FULL on the
initial boot; explicit camera settings including OFF are retained. Optional
HD-2D LIGHT and Depth of Field remain separate. Gen 1 retains its rendering.

Published runtime commits / versions:
- Battle Art 1.17.2: 585ed1b72328a4decacffb8dd5717daa035c5b0b.
  ZIP SHA256 88afb747e2e30435595af70fdf6a52c7c4c7162635b648880d000e3871483417.
- Double Battles 0.9.2: 7620f92b3bbf13485318b48e6b454f0607c5e774.
  Source HEAD dbf5484 is a later QA-driver-only update for removed style API.
- Sky Ride 0.2.22: 669a27fe12b3a1cf92b96b9a04929e6b813b6bc9.
- Cart 1.9.0: 2ff63883f743689f766a2979b0792979f52f7f2d.
  Cart SHA256 2a048bd7d53785e6d40888430d12dba3cefea0063214249f250904c0d03b0577.
  Crystal sealed+, CG3 cover, all thirteen pins retained. Wilds HUD option0.
  No obsolete crystalStyle pin. Online pack validates all release pins;
  exact bundle/source bytes and index metadata match.

Final packaged cart test PASS:
/tmp/johto-hd/cart-1.9.0-hd2d-verified.log and corresponding screenshot folder.
Fresh disposable profile, actual cart launch path, 2560x1440: camera level1
and saved options asserted BEFORE driver camera changes; hidden HUD asserted
from cart options, no manual override; removed style API, legacy values,
scene rebuild, source collision preservation, optional light and DOF pass.
The one-line disposable launcher adjustment below is necessary because the
engine's script shortcut discards --cart; no engine source was modified.
Packaged 16-map/19-view scenery PASS: packaged-scenery-1.9.0.log; packaged
1440p battle attacks/paired Sentret/KO/escape/party PASS: packaged-battle-1.9.0.log.
Those two run BA1.17.1; 1.17.2 changes only camera label and fresh-save pipeline
activation. Final source support181 passes. No Android/hardware GPU testing.
Only johto-parity-qa and johto-hd2d-fresh-qa profiles were used/updated.

The 1.17.2 fix uses the EXISTING Voxel.seedOptions FULL preset in save.created
and immediately applies it when newly seeded, matching save.loaded behavior.
No extra game.ready callback remains. Previous temporary 35-degree/level3
assertions below describe investigation, not shipped code.

Remaining: exact Gamma Emerald parity, generic architecture/props (including
Park benches), high-angle foliage and hardware performance. Fast bouncing
Charmander remains un-reproduced. Known Online+ Gen1 map-script and Wild Skies
defCellTile warnings remain. Do not claim every object perfected.

# Final default-camera check — 2026-09-14

1.17.2 changes the Gen 2 camera label to HD-2D CAMERA and applies the newly
seeded camera in save.created. Game2 restores pipelines BEFORE emitting its
boot save.created event, so the existing FULL default was recorded but not
activated for that boot. The seed helper still preserves an explicit OFF.
Fresh imported profile johto-hd2d-fresh-qa now passes pre-driver camera-level
and options assertions, then fixed-style migration/1440p/shader checks:
/tmp/johto-hd/fresh-hd2d-default-6.log. Support181 passes. Earlier attempts
incorrectly expected level3; the existing default is FULL (level1, 35 degrees).

The strict cart-HUD check originally failed because engine scripted boot
ignores --cart and passes nil into bootGame. A disposable main.lua copy in
/tmp/johto-hd/release-engine changes only its scripted-branch condition to
`if scripted and not resolvedLaunch.cartSpecified then`; this routes --cart
through the normal validated startLaunchRequest path while retaining the
frame driver. Engine source and user profile untouched. Actual cart-path
1.17.1 boot passes /tmp/johto-hd/cart-1.9.0-final-cart-path.log. Re-run with
packaged 1.17.2 and publish cart1.9.0 after updating pin/hash.

# HD-2D-only Crystal presentation — 2026-09-14

Latest user steering removes the voxel style and its selector. 1.17.1 makes
crystalHD/crystalDepth unconditional for native Gen 2 maps, removes the
crystalStyle row/registration and selectable opaque-canopy path, and ignores
legacy saved style values. Gen 1 keeps its established rendering path. Optional
HD-2D LIGHT / Depth of Field remain. Cart should carry no obsolete crystalStyle
pin option. Gen2 depth_style_driver now checks the fixed default, ignored old
saved values and optional shaders instead of cycling the removed row.

Packaging audit caught main.lua was accidentally omitted from 410b452's
staging list: published 1.17.0 lacks optional-light pipeline registration and
the battle-ended hook despite having their modules. Both entry-point changes
must be INCLUDED in 1.17.1. Do not claim 1.17.0 alone fixes these two features.
Doubles runtime0.9.2 is correct; its QA driver was adjusted in the source repo
for the now-removed style API (no runtime change / no new pin needed).
Native tree role QA now inspects S.roundStamps instead of sandbox-invisible
_G registries, so cut/bush counts become meaningful.

# Lower ledges follow-up — 2026-09-14

User judged the six-pixel mound crest too tall. 1.17.1 lowers it to 2.5 pixels,
retains its three-pixel footprint and smooth profile, and scales all six source
dirt rows over the shorter unjumpable face. Cache revision46. Collision and
jump permissions unchanged. Cart 1.9.0 is not yet published; update its Battle
Art pin from the just-published 1.17.0 to 1.17.1 before publishing it.

# Working release candidate — 1.17.0 / cart 1.9.0 — 2026-09-14

Current working tree adds layered HD-2D foliage, low shrubs / retained Cut
saplings, essential-crown LOD protection, matching twelve-tile forest fill,
44 furniture recipes, 16 floor finishes, small flowers / low Park rims,
unequal reef clusters, native rock-ground selection, soft wet-sand shores,
and rounded mound ledges with the outward dirt face preserved. Optional
SceneFinish world lighting + existing DOF leave UI outside the composite.
Battle stage persists until its native screen is popped. Cache revision 45.
Generated original crown PNG / prompt: assets/crystal/depth-crowns-v2.*.
See docs/CRYSTAL_1_17.md for coverage and explicit remaining work.

Companions: Double Battles 0.9.2 defers HUD during animation BG bakes and draws
it once after FX. Sky Ride 0.2.22 restores main_55_gen2_test_gift.lua in parts.txt
at the user's request. Scientist (9,10), New Bark: grants missing owned-species
level-50 Ho-Oh/Fly, Suicune/Surf, Raikou and Gyarados/Surf only on interaction.
No boot gifts or save deletion. Cart source selects crystalStyle=depth and
Wilds catch_hud_size=0; publication/pin synchronization still pending here.

Actual evidence this checkout: /tmp/johto-hd/tree-npc-final.log (16 maps/19 views,
NPC presence/no auto-gift, trees/roofs/furniture/live fruit/rock ownership),
scenery-final.log (8 views, 255 flowers, native shallow Park rims, varied reefs),
depth-final-2k.log (style switching and optional shaders), battle-final-2k.log
(native damage, both Sentret, survivor/party ownership, animation HUD, KO/escape
stage lifetime). Latest mound-only rerun: ledge-mounds.log. All-map inventory
and screenshots: all-maps-depth + all-maps-tail (373+15=388). The first run hit
its time bound; tail rerendered from map374. No unavailable walkable cameras.
Inventory 79 recipes, 77 placed, 1,447 placements. All-map sweep predates final
foliage/shore/Park fixes; focused native checks cover those final changes.
Pure support181, doubles39, trees110, HD60, furniture44, floor16, flower/shore/
rock/mound/roof/staged-pair/HUD tests pass. No Android/hardware GPU validation.

Still open: fast bouncing Charmander un-reproduced (stationary three-city
probe in charmander-probe.log had no species/jumps); exact Gamma Emerald
parity, remaining generic props/architecture (notably Park benches), high-angle
foliage, and hardware performance. Known Online+ registry warning and Wild
Skies Gen 2 defCellTile mismatch remain; optional cache writes reject but GPU
owners survive. Do not claim complete visual coverage from map smoke tests.

# Release checkpoint — cart 1.8.0 — 2026-09-13

Cart source 8a947c9 pins Battle Art 1.16.0 (eb332ca); the other twelve pins,
Crystal sealed+ and CG3 are unchanged. Pack SHA256:
fc470d8e8b165b2330a307d4e32474d8327c96d2eba70a3a1bad71eceb887b67.
Online validation and exact source/pack byte equality pass. Packaged full-cart
boot loads 1.16.0, reaches game.ready and submits first frame:
/tmp/johto-hd/cart-1.8.0-boot.log. QA release-engine now uses extracted 1.16.0
under packaged-1.8.0 for Battle Art; companions still packaged-1.7.0. Only the
johto-parity-qa cart was updated; no real user profile touched.

# Scenery and roof-shell pass — 2026-09-13

Battle Art 1.16.0 (eb332ca), published: original RGBA foliage-sprays-v2.png with prompt and
built-in generation provenance beside it. Larger outer sprays, smaller inner
crowns and hashed species choice; sparse bounded meadow cover. Crystal HD
sunlight uses a nine-tap tent filter and cool shadow fill, with Gen 1/source
lighting branch preserved. Corrected plaster tile 50 ->27 after native New Bark
map inspection; tile50 is terrain. Blue-gray windows and warm timber retain
source silhouettes. User reported roof holes: pitched tops had no side closure
above run.h. Gen2RoofShell now shares corner profiles with the mesher, closes
exposed gables and differing adjacent heights; shared interior faces omitted.
Johto roofed flanks/rears now use wall art instead of folded roof rows.
Mesh cache revision43. Geometry, collision and native map data remain separate.

Actual software-GPU checks: 16-map/19-view scenery pass at
/tmp/johto-hd/roof-final.log, including east/west/rear roof views;
previous art pass /tmp/johto-hd/parity-final.
Native 1440p doubles damage, paired rendering, survivor promotion and party
ownership PASS at /tmp/johto-hd/parity-battle-2k.log (before roof-only change).
Pure roof/ground bounds and exclusions, scenery9, HD60, tree108, support181,
item balls, bin/bed, staged pair and Lua syntax pass. Known Online+ map_scripts
incompatibility remains recorded; not a zero-warning boot. No Android hardware
verification. Complete prop coverage, better encounter-grass art, architecture
geometry, caves and exact Gamma Emerald parity remain open. Do not claim full
parity based on this incremental scenery release.

# Release checkpoint — cart 1.7.0 — 2026-09-13

Final pushed pins: Battle Art 1.15.3 (35c7fad), Double Battles 0.9.1
(c391673), Sky Ride 0.2.21 (6349c56). Cart source 0488bf3, Crystal sealed+,
CG3 unchanged, thirteen mods. Packed SHA256:
67bcc0dd8475521b3b4f109f2b4e6c243edc0e551c64b9dc3952ffabe40436c1.
Online validation passes. Pack bytes equal cartkit.bundle_bytes(source).
Extracted release ZIPs passed native BattleState.submit, damage, two same-
species rendered actors, survivor promotion and owned-party checks at
/tmp/johto-hd/doubles-cart-1.7.0.log. 1440p source build evidence is
/tmp/johto-hd/doubles-2k2. Current packaged QA engine is release-engine,
mods point to /tmp/johto-hd/packaged-1.7.0. No user profile was installed or
modified; only johto-parity-qa cart was replaced. Do not use unreleased
1.6.1 artifacts; those were intermediate builds before UI/facing feedback.

# 1440p framing and facing correction — 2026-09-13

User caught mirrored player back art and requested a more expansive 2K view.
Gen2Staged now returns noMirror for the native back slot; BattleScene expands
its own Crystal lens by 1.25 + widescreen delta (about 1.45 at 16:9). External
camera ownership is preserved. Double Battles 0.9.1 renders its compact HUD
at full-window edges with scale capped at4, outside the old handheld scissor;
font DPI follows that display scale. First 2K attempt clipped the edge cards:
fixed with scoped setScissor reset. Latest complete 2560x1440 native battle
passes at /tmp/johto-hd/doubles-2k2.log, screenshots in doubles-2k2. Both
Sentret and the corrected Cyndaquil facing are visually verified. Scenery and
lighting still fall short of Gamma Emerald; do not claim exact parity.

# Modern doubles UI follow-up — 2026-09-13

User requested a modern battle UI, then correctly pointed out incomplete
Sentret sprites and blurry text in the first comparison. Doubles 0.9.0
owns its native-panel HUD/menu/move/dialogue renderer in lib/gen2_hud.lua;
Battle Art 1.15.2 honors usesModernDoublesHud() to omit legacy backplates.
Fonts use the actual panel transform scale as glyph DPI (7px logical,
35px raster at scale5), fixing magnified antialiasing. Missing iw2/ih2 in
Gen2Staged caused paired textures to fail: now reads each image size.
Two-Sentret real screen check passes, both staged.drawn entries asserted,
image /tmp/johto-hd/doubles-sharp/doubles_menu.png. Labels/HP and move PP,
survivor promotion, native damage and party ownership verified. Original
special prompts remain native. Explicit enemy aim and player pair command
collection remain future work; don't imply full modern doubles mechanics.

# 1.15.1 scenery / gameplay hotfix follow-up — 2026-09-13

Scenery changes: Gen2Trees stable crown rotation/height/width and exposed
boughs; smaller leaf sprays, mipmapped original foliage; Gen2GroundEdges
bounded 0.35–1.5px turf fringes over Johto dirt tiles; roof courses and lab
wood in the HD atlas. Source/collision untouched; mesh cache revision 39.
Full 16-map/19-view comparison passes at /tmp/johto-hd/polish2; pictures
reviewed for New Bark and Elm. Pure geometry/material/ownership suites pass.
Buildings and vegetation still need substantial work for Gamma Emerald parity.

User interrupted with opponents immune to damage and an unowned level-50
Ho-Oh after fainting. Doubles 0.8.0 was ignoring the native {kind=move}
action shape. Fixed in its own repo 0.8.1 with survivor promotion and owned
party loss/replacement tests (39/39). Real native BattleState.submit damages
foes and promotes the survivor: /tmp/johto-hd/doubles-fix.log. Sky Ride's
temporary test giver grants level-50 Ho-Oh on interaction; removed from its
production entry list in 0.2.21, no existing save mons deleted. This is an
identified source, not proof the user interacted with it. Fast overworld
motion remains un-reproduced/open. No Android verification.

# Release checkpoint — 2026-09-13

Published and pushed: Battle Art v1.15.0 (031e26d), Sky Ride v0.2.20
(c70b36f), and JohtoDioramaCart v1.6.0 (0359aba). Cart SHA256:
255626a4f9012f50533541f6335a4ce85e706d300743e209124b7b4768cf4ccf.
Mod archive SHA256: bd34b99f643d803fe31b6d8052933b15cd17445b9edb72bfc49e2a6320349945.
Sky Ride archive SHA256: e75d1d16c49f11198ae0b208180926281677097b70e199ec7c0b26519466f94e.

Online cart validation checked all thirteen published pins. The actual cart
launch (--game=crystal --cart=johto_diorama, no driver) loaded the thirteen
packaged versions in pinned order and reached game.ready. A separate driver
against the extracted release packages passed real rendered water/camera
checks, both rungs moving east from (7,5) to (9,5). Art/CG3 bytes preserved.
Logs: /tmp/johto-hd/packaged-cart.log, packaged-camera-water.log and
cart-validation.log. Full scenery screenshots: /tmp/johto-hd/review2.
The separate Sky Ride owner-delegation regression passes; its older generic
load test could not run against this import because it tries Gen 1 Data.load
and requests text_pointers.lua. Do not claim that fixture passed.

Fast ground/water Pokémon report remains open and broad scenery coverage
remains iterative. Neither was represented as fully fixed in release notes.

# Crystal 1.15.0 follow-up — 2026-09-13

Prepared after 1.14.2: smaller item balls, horizontal Elm healing bed, open
lab bin, original foliage atlas and distinct family UVs, irregular grass,
native imported animation frames and native camera-relative Gen 2 grid walk.
Sky Ride companion 0.2.20 delegates its older onTop bridge to providers that
advertise supportsGen2World; this fixed the observed mid-step camera drop.
See docs/CRYSTAL_1_15.md and CRYSTAL_FOLIAGE_ART.md for scope/provenance.

Fresh checks: full 16-map/19-view driver passes (/tmp/johto-hd/review2),
camera/water GPU driver passes (/tmp/johto-hd/camera-water6), SDK 181 support
and 95 shapes, pure geometry/ownership checks. Current 13-companion QA engine
is /tmp/johto-hd/engine. Online+ still records its exact unsupported map_scripts
registration; do not claim zero loader errors for the whole stack.

User's cart-1.5.0 fast ground/water Pokémon report remains un-reproduced in
two instrumented current boots; /tmp/johto-hd/spawns*.log records water and
ambient guests. No Wilds movement patch made. No Android claim. Every prop
family is not yet bespoke: continue the 35-tileset coverage audit.

# 1.14.1 - Gen 2 doubles on the staged battle — 2026-09-13

Additive, released on Legendary-Additions (tag v1.14.1): when a battle
carries the double-battles fork's second slots (battle.player2 /
battle.enemy2), Gen2Staged composes BOTH mons into each side's staged
billboard card (lead left, partner right, same ground line) and
Gen2Battle's flat-panel skip covers both through the drawn table. Verified
in-engine: a wild double on Route 29 (Sentret joining Geodude, rolled
from the map's own table) stages both mons on the diorama while the
engine's text runs the round. Cart repinned as JohtoDioramaCart 1.3.3. The doubles follow-up shipped
the same day: Battle Art 1.14.1 + double-battles-gen2 0.8.0 (second HP
plate, doubles default on) are ON the cart — JohtoDioramaCart 1.5.0
swapped Free Fly out for the dramatic-sky-ride fork (0.2.19: the Crystal
rider crop is verified through the engine's asset reader; Gen 1
untouched) and repinned gen1online-plus 0.5.2 (server connect-address
banner). Thirteen pins, boot-verified from the packaged files, stack
audit clean: no hard dependencies between mods, no cart-member conflicts,
all thirteen claim Gen 2, and the priority order is the pinned load
order (Crystal Animated Sprites outermost on pokemon.sprite). Remaining
in the double-battles fork: the player-side partner and aim menu; in
gen1online-plus: PVP 2v2 over the doubles2 contract.

# Crystal 1.13.0 / cart 1.2.0 released — 2026-09-13

The original interim corrections below have now been superseded. Branch remains
Legendary-Additions. Applicable DRAMALESS commits are cherry-picked; license
notice retained. Whole furniture recipes in data/gen2_furniture.lua replace
Mom's kitchen and lab furniture, with CPU-only support heights for warm-cache
boots. Gen2Ledges makes three-pixel lips/corners; Gen2Rocks models coastal,
ocean and live rock actors. See docs/CRYSTAL_1_13.md for scope and evidence.

Eleven-mod compatibility driver passed with all five requested additions.
Modern UI has been forked to notquiteog/gen2recomp and its unmodified upstream
archive published as v1.0.15 for an installable checksum pin. Modern Johto stays
optional/off by default. CG3 label copy prepared at JohtoDioramaCart/art/CG3.png
(512×512; original Pictures image unchanged). Cart base remains crystal and
seal remains sealed+. RELEASED 2026-09-13: branch Legendary-Additions pushed,
tagged `v1.13.0` and released on notquiteog/DramaticShapeVoxelMod with
`BATTLE_ART_VOXEL_FORK-1.13.0.zip` + `sha256sums.txt` (sha256
`70dce2c9…` — matches the cart pin). JohtoDioramaCart 1.2.0 committed
(df540b3), tagged `v1.2.0` and released with `johto_diorama-1.2.0.g1rcart` +
`cart_sums.txt`; index entry validates clean against the
gen1recomp-mod-index checker (tags trimmed to the 8-tag cap). Boot verified
from the packaged files: release g1rcart in a clean save's carts/ with the
pinned 1.13.0 zip as the installed mod — all eleven pinned versions load in
the pinned order and the game reaches ready (kanto_gear has no priority, so
loading ahead of Wilds proves the cart's load_order applied; driver boots
drop the cart by design — scripted boots call bootGame(version, nil), so the
in-engine cart-context asserts cannot run under POKEPORT_DRIVER; the
launcher-request boot `love . --game=crystal --cart=johto_diorama` is the
cart path). QA scripts/artifacts are /tmp/johto-parity and
tests/*cart_driver.lua; every pin's sha256 was checked against its published
release asset.

# Gen 2 parity in progress — 2026-09-13

Local branch `Legendary-Additions`, no new release yet. Battle background dim
and attack-animation clears are now gated by 3D-BTL (the earlier battleFit=fill
attempt was wrong: Game2.paintBattleSurround explicitly dims the margins).
Round border trees use the complete two-cell drawing; interactive bushes and
isolated cave rocks use one-cell hulls. Route 29's grass-capped lip classification
and fence post/rail routing are present. Gen 2 cache token refreshed.

Fresh checks: gen2 shapes 92, gen2 support 181, budget 35, storage 7; 158 Lua
production files compile. Disposable six-mod engine boots (source 2cc86d5,
llvmpipe/Xvfb, Free Fly published 1.8.2) captured a real Cyndaquil/Sentret battle
including 30 attack frames without white fill and without dark side strips.
Seven map driver checks show no unclaimed round scenery. These are desktop
checks, not Android. Some companion warnings still occur (Wild Skies Map API,
Wilds nil-sprite fallback); not claimed as a zero-warning gameplay session.

USER CORRECTION: furniture still too tall; Mom's appliances still laid out in
depth; fence/ledge corners remain boxes; ledges must be thin bars rather than
cell-wide raised shelves; rocks/boulders and low ocean barrier rocks need actual
models. Elm's Lab camera must stand on clear floor. Do not publish this interim
geometry. Fetch and integrate applicable upstream artyrambles/DRAMALESS_SHAPE
main commits (fetched through 97ca3e1); preserve Battle Art ownership/identity.
Their history has no common ancestor with this checkout, so do not overwrite the
fork with their renderer. Latest sprite-size and GBCFX fixes already exist here.

QA artifacts/drivers: /tmp/johto-parity; isolated engine there links local mod
and published companions. Base engine /home/admin/Apps/Gen1Recomp/source.
Save identity johto-parity-qa; imported test data in johto-shots/crystal.
Cart remains 1.1.2 with Battle Art 1.12.2 and Free Fly 1.8.1. Release/re-pin is
still pending after the corrected geometry is verified.

# Johto diorama: one-cell trees, outdoor-only volumes, per-map roof bake - 2026-09-12

Three faults reported on the JohtoDioramaCart after 1.12.1: bushes two
storeys tall, tree borders reading as growing into the walking path (New
Bark), and interior furniture -- especially tables -- way too tall. All
three were 1.12.1's two overcorrections (the 32px tree, the everywhere
volume reading) and all three are fixed in `lib/Gen2TileShape.lua`:

- `tree` is back at the class default 16px, one cell. The 32px box leaned
  two cells of screen space over the ground at the 35-degree camera, which
  read as a treeline growing INTO the path, and every bush -- bushes are
  the same class, wall collision over PAL_BG_GREEN -- stood two storeys.
- The volume reading is gated OUTDOORS (`TOWN`/`ROUTE`,
  `Palettes.ROOF_ENVIRONMENTS`). Indoors every solid answers `wall`, so
  furniture and the room's back wall were one region and ELM'S LAB's
  tables read their height off the room's depth -- 48px towers. The same
  gate covers `thin`, whose fence/sign reading had already made 68 fences
  out of DARK CAVE's rock when ungated.

A fourth fault was found while verifying and is fixed in
`lib/TerrainAtlas.lua`: the Gen 2 atlas bake keyed its cache on
`tileset.id # daytime # mode`, but `Palettes.bgSet` loads the BG palettes
per map group and rewrites the roof slot from that group's roof colours.
GSC's towns share TILESET_JOHTO, so the first town visited decided every
later town's roofs -- New Bark came up in Cherrygrove's pink after one
visit there. The key now carries the map id.

## Evidence, in this checkout

- `tests/gen2_tile_shape_test.lua`: 80/80. The two assertions that pinned
  the old behaviour were updated (`tree.h` 32 -> 16, `groundAt` 32 -> 16)
  and a new indoor block pins the volume gate (`wall.volume == nil` on an
  INDOOR map, `Structures.volumeClaims` false, isolated solids stay
  `wall` rather than fences/signposts).
- `tests/gen2_support_test.lua`: 163/163.
- LuaJIT 2.1 compile sweep: 141 production files, 0 failures.
- Real Crystal boots (engine source at HEAD, shipped-equivalent harness,
  Xvfb + llvmpipe, sandboxed POKEPORT_IDENTITY), screenshots at the FULL,
  35 and 75 rungs:
  - NEW_BARK_TOWN: green gabled roofs with doors in facades, one-cell
    treelines and bushes off the path, town signs low, NPCs on the ground.
  - ELM'S LAB: tables at furniture height, starter balls sitting ON the
    ball table, bookshelf racks proper, the healing machine ON its table.
  - PLAYERS_HOUSE_1F: the dining table low with the seated pair beside it,
    kitchen counters low.
  - CHERRYGROVE_POKECENTER_1F: the counter an 8px band with the machine on
    top, nurse behind it.
  - ROUTE_29: ledges 6px with their lip, tall grass as tufts on flat
    ground, the fence one cell wide and low, tree borders off the path.
  - VIOLET_CITY: gym's plank roof and facades correct, one-cell tree mass
    (174 cells) with no plateau and no gable.
  - Roof regression order: CHERRYGROVE -> NEW_BARK -> VIOLET in one
    session keeps each town its own roof colour (this was the pink-roof
    reproduction; it stays green now).
- Known gaps unchanged: animated tiles (water, flowers) are coloured but
  still; Cherrygrove's water-edge wall boxes carry their own art and are
  read at the volume depth their drawing gives -- not part of the report.

## Release

Bumped `manifest.json` to 1.12.2 (`mod.exports.version` follows the
manifest). Tagged and released as `v1.12.2` on notquiteog/
DramaticShapeVoxelMod; JohtoDioramaCart re-pinned.

# Lavender Battle Art parity + exact bald-square fix - 2026-09-10

The previous follow-up targeted the wrong rectangle. The large 12x12
`pokemon_tower_top` claim on ROUTE_10 is the already-approved flower square and
must remain exactly as it is. The screenshot's grey/bald square is instead on
LAVENDER_TOWN: it is the synthesized floor beneath the Silph Scope sign at
engine cell `(9,3)` (source tiles `tx18..19`, `ty6..7`). The sign art stands up
as a billboard and claims those four source tiles, so the mesher has to choose
their replacement floor explicitly.

Battle Art Lavender now snapshots the CURRENT Legendary Lavender city treatment:
non-path ground uses the same vivid Route 10 green lawn geometry/material,
authored `$23/$39` path cells use the same lavender-grey path palette, and the
existing Tower flower landscaping is unchanged. That makes the claimed sign
floor at `(9,3)` plain non-checkered grass in both modes while preserving the
checker/path network beside it. The CITY GROUND modes remain separately keyed so
a future Legendary revision can diverge without taking this approved Battle Art
baseline away. Fuchsia is unchanged.

The earlier unsolicited `1.10.7` version bump was reverted: `manifest.json` and
`mod.exports.version` remain `1.10.6`. No tags are moved or created by this work.
No source map tiles, collision, walkability, warps, encounters, or Tower
flowerbed density/placement are changed.

# Lavender Tower lawn + Battle Art flowerbed - 2026-09-10

Historical note: `43d7922` made the existing Route 10 Tower flower landscaping
available in Battle Art too. That change is retained because the user wants the
large flower square exactly as it is, but it was NOT the grey-square fix. The
grey square is the Lavender Town sign-floor claim described above.

# Lavender approach ground + Tower flowerbed - 2026-09-10

The previously pending screenshot request is now implemented. On ROUTE_10 the
final eleven authored block rows (tile rows 100..143, Rock Tunnel's lower mouth
through the Lavender seam) are one continuous ground treatment: BATTLE ART
routes every flat ground donor through the existing sandy Kanto-road material,
while LEGENDARY GRASS routes the same coverage through the approved bright
Route 10 lawn. ROADS & BRIDGES can still retain its authored path material when
enabled, and CITY GROUND still has no ownership over Route 10.

This section describes the earlier `5e1d267` state. The current parity patch at
the top of this file supersedes Lavender's mode split: Battle Art now keeps the
same current bright lawn and lavender-grey `$23/$39` path palette as Legendary.
Fuchsia remains unchanged.

The flowerbed does not use guessed camera coordinates. `pokemon_tower_top` is
already the claim-only 12x12 tile rectangle on Route 10 that contains the upper
half of Pokemon Tower's source drawing; Buildings now records that exact matched
footprint. The follow-up Tower-lawn patch makes those animated flower standees
a Battle Art baseline too, while preserving the exact checkerboard/density in
Legendary. No source map tile, collision, warp, encounter or walkability data is
changed.

Persistent cache identities now use `route10-lavender-approach-v2-tower-lawn`,
`route10-tower-flowerbed-v2-baseline` (AUX), and `lavender-battle-parity-v5`. Static and
animated atlas map isolation remains unchanged. Headless validation: CITY
GROUND/Route 10 suite 50 checks, dedicated Lavender approach/flowerbed suite
216 checks, grass east-edge 15 checks, build-budget 35 checks, and voxel-storage
6 checks. All 114 production Lua files compile under Lupa's LuaJIT 2.1 backend.
Actual in-engine visual comparison is still required before release.

# LuaJIT TerrainAtlas compile-limit fix - 2026-09-10

The pushed `26845c9` Lavender build reproduced the Mod Manager failure under
Lupa's LuaJIT 2.1 backend: `lib/TerrainAtlas.lua:996: function at line 704 has
more than 60 upvalues`. This is a production LuaJIT 5.1 compiler limit, not a
Kanto First Person dependency failure; Fengari had accepted the same file and
therefore missed it. Cave-material and Lavender-material painting were lifted
out of `communityAtlas`'s large protected-build closure, reducing its captured
locals without changing atlas output. `tools/check_luajit_compile.py` now
provides a reusable pre-package compile sweep using Lupa's `luajit21` backend.
All 114 production Lua files compile under that backend after the refactor.

# Lavender authored path-network correction - 2026-09-10

Historical pre-parity state: Lavender CITY GROUND first preserved the original
`$23/$39` path network instead of flattening every walkable cell to one
material, but Battle Art still used a sandy family while Legendary used its
lavender-grey/green treatment. The current top-of-file parity patch supersedes
that material split while keeping the authored topology. Route 10 remains
outside CITY GROUND ownership; Fuchsia, map data, collision, buildings and
non-ground geometry remain unchanged.
# Release 1.10.6 - performance profiler producer API

Tag `1.10.6` is the published producer-API baseline. The branch continues to
advertise `1.10.6`; do not move/create a tag or bump the version unless the user
explicitly requests it.

# Performance monitor producer API - 2026-09-10

Branch `feature/performance-profiler-v2` exposes a stable read-only diagnostics
provider at `mod.exports.performance` for the separate `performance-monitor`
project. The monitor owns capture cadence, aggregation, reports and UI; Battle
Art only publishes domain-specific telemetry. No dependency on performance-monitor
was added.

API/schema v1 returns detached snapshots of LoadTimings buckets, RAM/cache state,
structured bounded cache events, ChunkMesher queue/cache pressure, Legendary tree
cache stats, shadow target state and sapling edit counters. Persistent cache
inventory is intentionally separate behind `storageSnapshot()` because it may call
storage.list and should not contaminate high-rate performance samples. See `docs/PERFORMANCE_API.md`.

CacheTrace now records a platform-neutral 64-event structured ring plus monotonic
counters while retaining its existing desktop text log. ChunkMesher exposes only
lightweight scalar/job descriptors; no map, mesh or coroutine ownership escapes.
Focused standalone Fengari validation: `tests/performance_export_test.lua` passes
16 checks; changed Lua files parse and `git diff --check` passes. Native engine
integration with the separate monitor is still required before merging.
# Issue #54 CITY GROUND option - 2026-09-10

Branch `fix/issues54` starts from clean local/remote master `04b8643` (1.10.5).
Issue #54 separates Lavender/Fuchsia city turf from the broad Legendary GRASS
choice. New `CITY GROUND` defaults to `BATTLE ART`; `LEGENDARY VISUALS` keeps
the existing custom city treatment. Lavender's previously unconditional custom
ground now follows this row, while Fuchsia's existing tiled Legendary turf is
selected by CITY GROUND instead of GRASS. Other Overworld maps continue to use
GRASS unchanged. The new row lives under Legendary Visuals > GRASS & TREES and
uses the existing CommunityVisuals live invalidation/persistence path.

City-specific static and animated atlases are map-scoped so Lavender and
Fuchsia cannot reuse one another's baked OVERWORLD animation entry by visit
order. Persistent city terrain fingerprints now include a city-ground contract
token and the CITY GROUND value while ignoring unrelated GRASS changes; other
maps do not gain a CITY GROUND fingerprint dependency. Cache record format is
unchanged, so cache revision remains 37.

Focused standalone validation used the temporary Fengari Lua CLI because this
Windows PATH has no native Lua/LuaJIT executable: `city_ground_option_test.lua`
passes 21 checks (default/ownership matrix, geometry selection, persistent
fingerprints and animated-atlas isolation), `grass_east_edge_test.lua` passes
15, `voxel_build_budget_test.lua` passes 35, and
`voxel_mesh_disk_storage_test.lua` passes 6. All changed Lua files parse and
`git diff --check` passes. `ram_precache_setting_test.lua` cannot run from this
standalone checkout because its engine-side `tests.modkit` fixture is absent.
Native LuaJIT/engine gameplay and actual Lavender/Fuchsia visual comparison are
still required before release. Draft branch is prepared for desktop QA; no deployment or cache-revision bump.

# Local PR #52/#53 integration — 2026-09-09

Branch `codex/legendary-pr52-pr53-integration` starts from the user's local
master `b435d467b55b1c743a13193e794e3dcce5e8b1a2`. Integrated PR #52
`936b23a` and PR #53 `b94eaf3`. Resolved overlapping handoff notes and ignore
rules; production changes merged automatically.

Tower textures, backdrop and mounted-mod/physical-folder ambient audio reads
now use `assets/legendary/`. All 12 supplied PNG/MP3 files are present,
nonempty, ignored and untracked. No media added to source history. The donor's
`lib/` install notes below are historical; use the new path and retain filenames.
`backdrop4.png` is supplied alternate art; the runtime selects `backdrop.png`.
Manifest/mod identity stays at 1.10.5. Cache revision stays 37, with both the
Safari-specific refresh token and v5 auxiliary grass token retained.

Fresh validation: all 128 production Lua files compile under LuaJIT 2.1.
Thirteen existing suites pass (318 counted checks plus Safari wall/stair/foliage
assertions): Legendary cache/UV/settings, grass edges, build budget, disk
storage, Safari, ladders, Cut drop/mesh refresh, restored world hooks, OFF
storage/live hooks, heal overlays and reflections. The Windows harness's
rename-self directory probe prevented mod discovery; reran the two affected
suites with only that probe replaced in memory by a read-only host directory
check. No production or test files changed for this. Asset paths, exclusions,
cache tokens and unchanged manifest (normalizing line endings) verified.
These are headless/mocked checks; Android gameplay, GPU visuals, Tower memory
cost and frame time still require device validation. Earlier reports below
are historical. This integration is local; no remote push or master merge.

# Safari ground coverage and cache refresh — 2026-09-08

Complete olive treatment for flat grass tile94 and hedge/edge variants13,79,84–93.
Only four outdoor Safari atlases change; non-green detail/alpha retained on edges.
Native engine0.2.27 captured all four maps: 567 changed atlas pixels, all outside
new coverage unchanged; tile94 matches tile0 exactly. No Quest validation.
Map-scoped cache token prevents pre-PR51 shrub vertices from surviving the upgrade;
non-Safari fingerprints unchanged. No global cache revision bump.

# TEST138 grass-only integration — 2026-09-09

Applied only the post-TEST137 grass delta from Legendary grass update onto
`Legendary-Updates` at `bcb2f11`. The earlier cave merge is now committed there;
its prior uncommitted status below is historical. Grass changes remain local
and uncommitted, with no push or deployment.

Structures suppresses only exposed east tile-boundary grass caps. VoxelMeshDisk
advances the auxiliary grass fingerprint to v5; combined cache revision 37,
release identity, all other runtime files and assets remain unchanged.

15 focused synthetic geometry/cache checks, 19 existing cave/cache checks,
6 disk-storage checks and the Safari/stair regression pass under LuaJIT.
No Android visual/gameplay check. See
[the grass merge report](docs/LEGENDARY_GRASS_MERGE.md) for scope and evidence.

# Legendary Cave Update integration — 2026-09-09

Merged the supplied Legendary Cave Update into the clean `Legendary-Updates`
checkout at `335bef0`, using verified upstream tag 1.10.3 (`278862b`) as the
three-way base. Changes remain uncommitted; no push or game deployment.
See [the merge report](docs/LEGENDARY_CAVE_MERGE.md) for the file inventory,
conflict decisions, exact validation scope, local media and remaining checks.

Retained newer interface/title, museum/Safari, companion atmosphere, reflection,
heal and Cut integrations. Combined cache streams use revision 37 (new derived
cache build required). Tower defaults to Battle Art; saved Legendary trees keep
full detail and FAST is separate. Supplied PNG/MP3 files remain local in lib/,
excluded from Git; assets/ was not changed. The source input is untouched.

All 128 production Lua files compile. Eighteen standalone/mocked regression
commands pass, including 19 new cache/OFF/UV/setting merge checks. Existing
engine-dependent and real-map cave tests remain unavailable without their
engine/fixtures; Android gameplay and GPU visuals have not been verified here.
Donor TEST102–137 notes and all earlier handoff results remain historical.

# PR #51 merge verification — 2026-09-08

Merged PR head `1e07e7f` into current master `22f5b03` in an isolated worktree.
The merge is conflict-free. Only SafariFoliage.lua, TerrainAtlas.lua and this
handoff change; all other tracked files match the target branch, retaining
restored ladders, heal overlays, water reflections, immediate cut removal,
interface fixes and PR #50 companion atmosphere support.

Fresh Lua 5.1/LuaJIT headless checks passed: cave ladders, heal overlays, water
cast reflection, cut drop/mesh refresh, restored pipeline hooks, precache OFF
policy/integration, Safari walls/stairs/foliage bounds, museum fossils, NATURE
underlay, build budgets, disk storage, interface install/playback (3174 checks
plus 5 modern title checks), atlas decoding, native anchors, companion atmosphere
integration and camera/projection facts. Syntax and whitespace checks pass.
Initial harness working-directory/arg errors were corrected and those suites
rerun successfully. These checks are mocked/headless, not device visual tests.
The PR author's 3.2x shrub geometry cost remains a mobile/Quest performance
limitation; their desktop capture claims above were not repeated in this audit.

# Safari canopy palette and pixel shading — 2026-09-07

Safari shrubs now use fixed one-world-unit surface pixels, connected edge/lower
shadow patches and checkerboard transitions. Color assignment precedes greedy
face merging, preventing stretched texture marks. Voxel occupancy, placements,
collision and draw-call count are unchanged; solid swatches remain 6x1.

The shared FOREST tree canopy receives the existing olive mapping only inside
the four outdoor Safari maps. Bark, alpha and other maps retain their original
colors. Native atlas comparison found 578 changed leaf pixels and no other
pixel changes.

Validation: native desktop engine 0.2.27 paired captures passed without stderr.
The representative Center scene contains 86 shrubs: 266,996 vertices versus
83,564 in the previous material/geometry (about 3.2x). This is the approved visual
prototype, not a Quest performance clearance. Texture-chart optimization should
preserve the approved appearance before a Quest release; Quest/GLES and exact
0.2.53 gameplay have not been tested. No live installation or cache schema change.

# Companion atmosphere extension — 2026-09-07

Optional draft effects API: owner-scoped resources, per-eye queues, bounded
atmosphere state, desktop camera facts and native celestial fallback.
See docs/COMPANION_ATMOSPHERE.md for contract and validation limits.
The official 1.10.4 tree-lift flag no longer falsely blocks registration.
No manifest/cache bump, companion art/runtime, or gameplay changes.

# Requested world-feature restoration — 2026-09-06

Audited the active `DramaticShapeVoxelMod` checkout on local `master` at
`278862b`, loaded by `mods/BATTLE_ART_VOXEL_FORK` through its directory link.
Changes below are local working-tree changes; no commit, push or release made.

## Findings and changes

- PR #41 (`dfc177c`): newer `ladder_up`/`ladder_down` pins bypassed its
  standee geometry. Restored the original `ladder` pins and two-voxel prop
  depth. The newer shaft builder remains available but is not selected by
  the shipped cave ladder pins. This restores the requested source-art
  ladders without changing the game's warp or collision data.
- Heal alignment (`c083147`): `HealOverlay.lua` survived, but main.lua no
  longer called it and Voxel3D no longer exposed the required depth value
  and texture. Restored all three connections, including animation-state
  restoration when field FX throw.
- Player water reflection (`55e195d`): restored the planar cast canvas,
  reflected billboard transform, water-shader compositing and cleanup.
  The existing water setting and readable-depth/canvas fallbacks still apply.
- Immediate cut-tree removal (`7991ccee`): restored prop ownership spans,
  cached span serialization, targeted mesh uploads and the block-edit hook's
  coordinates/map/old-block arguments. Adapted span declarations to the
  current sink order and kept enlarged Legendary tree ownership on its
  authored cell. Unowned border geometry cannot extend a preceding prop run.
  Mesh cache revision is now 32 so pre-restoration records cannot be reused.

The cut fix retains the current terrain and neighbouring map caches and
removes the changed prop immediately. It still marks the edited map for a
budgeted background rebuild, just like the linked commit. This is not a
claim that all rebuild work or every possible frame-time spike is eliminated.
The format/ladder change requires caches to be rebuilt once after upgrading.

## Verification

Run from the engine root with `DS_MOD_PATH=dev/DramaticShapeVoxelMod`:

- `cave_ladder_test.lua`: 38 checks; updated its dead-pin check to recognize
  the newer explicit `sapling_tiles` detector metadata.
- `heal_overlay_test.lua`: 63 checks.
- `water_cast_reflection_test.lua`: 47 checks.
- `cut_drop_test.lua`: 22 checks.
- `restored_world_features_test.lua`: 22 checks covering actual registered
  pipeline calls, heal error recovery, the real Map:setBlock hook, the water
  pass/player transform connection and reflection error recovery.
- `cut_mesh_refresh_test.lua`: 10 checks covering table-sink spans, zeroed
  vertex uploads, retained drawable terrain and unaffected neighbour cache.

Run from the mod root:

- `voxel_build_budget_test.lua`: 35 checks.
- `voxel_mesh_disk_storage_test.lua`: 6 checks.

These are headless/mocked checks using the local LuaJIT/Lua 5.1 runtime, not
in-game visual, GPU-shader or Android performance validation. Lua syntax and
Git whitespace checks also pass.

Broader suites attempted but not passing: `battle_art_voxel_fork_test.lua`
exceeds Lua's 200-local limit; `voxel_visual_object_filter_test.lua` lacks a
CommunityVisuals fixture; `companion_main_uninstall_integration_test.lua`
has a platform fixture without `metalRenderer`. Those suites need separate
harness maintenance. Historical shaft-specific Astra ladder tests describe
the superseded ladder design, rather than this requested PR #41 restoration.

## Follow-up: platform-independent OFF and crash audit

Removed the unsuccessful iOS OFF-to-FULL override. OFF now skips all automatic
voxel cache storage probes/reads, preload planning, and speculative destination
work on every platform. Live geometry still builds cooperatively and its records
remain in session RAM, even without a persistent storage backend. Manual cache
generation/saving remain explicit actions. Added cancellation that preserves jobs
promoted to live terrain, and guarded the remaining direct GC call.

71 cache-policy checks pass, alongside the 243 earlier targeted checks. The map
audit completed Pallet, Route 1 and Celadon geometry against local Yellow data;
Celadon and Route 1 have materially larger geometry footprints than Pallet.
No iOS crash log was available, so memory pressure is a lead, not a confirmed
diagnosis. See `docs/OFF_MODE_CRASH_AUDIT.md` for exact semantics, measurements,
test coverage and the limits of these checks.

## Master integration — 2026-09-07

Fast-forwarded local master from `278862b` to `7743de9`, including PR #47
(museum fossils/cave corners) and PR #48 (Safari scenery/interior textures).
The remote advanced from two to four commits ahead during the fetch.

Reapplied all pending local edits and untracked documentation/tests, including
the user's manifest version `1.10.4`. The sole textual conflict was the cache
revision: upstream used 33 and the local span restoration used 32. The combined
geometry and record format now use revision 34. Local edits remain unstaged and
uncommitted; no push was made. A named safety stash retains the pre-integration
working tree.

The 314 targeted local checks pass on the combined code. Upstream museum,
Safari wall/stair, NATURE underlay, and real-map retaining cave/corner tests
also pass. The real-map test used local Yellow data. Syntax/whitespace and
unmerged-path checks pass; mobile gameplay remains unverified.

## Gen 4 tight atlas migration (2026-09-07)

Inspected `dev/gen4_front_tight-1.10.3` (770 regular/shiny PNG atlases).
Compared every frame against installed originals after a constant per-animation
translation: no altered visible pixels, clipped pixels, or empty frames. All
sheet dimensions match supplied metadata. Species, paths, timings and frame
counts are unchanged. No Unown PNG is supplied (existing metadata also refers
to an absent unown.png).

Merged only frame dimensions into both Gen 4 data tables, retaining original
sizes as legacyLayout. AnimatedBattleArt selects tight or legacy cells by exact
sheet dimensions, so incremental asset overlays remain compatible. No assets
were copied; the owner will overlay supplied assets onto the mod assets folder,
retaining files absent from the pack, then restart. Do not overwrite the merged
data tables with the supplied ones: that removes legacy compatibility.

Keep Summary BATTLE ART fitting: 580/770 opaque animation bounds exceed 56x56;
removing it overlaps name/HP/number UI. Existing fitting already uses scale <=1
and does not downscale artwork whose opaque bounds fit. Cropping preserves the
visible art size, so it cannot eliminate required fitting. Dex uses native
frames and benefits from reduced padding. Runtime/device visual QA remains
outstanding. Decoder and interface playback: 55 checks pass; metadata-only
comparison and Lua syntax checks pass.

## Interface scaling and Android title banding (2026-09-07)

Added INTERFACE SCALING: FIT/FULL (default FIT) beside INTERFACE SPRITES in
POKEMON ART. It applies to BATTLE ART Summary and Dex Image adapters. FIT uses
56x56 opaque-union fitting; FULL uses complete native prepared frames. Switching
is live and retains animation progress. FULL may overlap the stock screen UI.
Title rendering is independent. This supersedes the previous decision to keep
status fitting mandatory; the user explicitly requested FULL as a test option.

Android screenshot (user reports engine 0.2.56) shows horizontal bands on Ditto.
A suspected contributor is fractional display scaling of the title alpha-mask
true-color replay, previously one scissored pass per horizontal pixel run.
Coalesced identical consecutive runs into taller rectangles without changing
covered pixels or trainer exclusion. This reduces internal scissor boundaries
and draw calls, but is a mitigation, not a confirmed Android fix. Engine renderer
also has DPI-aware scissor rounding; device scaling and GPU behavior still need
verification. Ask tester to compare integer display scaling if bands persist.

Mocked interface/title tests: 3169 checks passed, including pixel-by-pixel mask
coverage, trainer occlusion, FIT/FULL live changes, and animation. Lua syntax and
git diff whitespace checks passed. No actual Android/device visual test performed.

## FULL interface anchor correction (2026-09-07)

User screenshots show padded Dewgong/Croconaw frames positioned too low. FULL
now removes shared animation-wide transparent margins and top-aligns visible
art at native resolution in a canvas at least 56x56. Oversized art retains all
pixels and can overlap UI. FIT is unchanged. Shared bounds preserve authored
animation motion. Native and fitted results use separate caches. Synthetic
production-fitter tests verify pixel preservation, top alignment, motion and
cache separation; device visual verification remains outstanding.

## Status centering and installed deployment (2026-09-07)

FULL Summary portraits now center within x=0..71; wider canvases start at x=0
to preserve the left edge. Only the sprite draw and matching true-color mark
move; scoped wrappers restore on errors. FIT remains unchanged. Kanto-Reforged
installed ui/summary_ui.lua labels now use ATK, DEF, SPEED, SPATK, SPDEF to
fit before three-digit values. Companion patch staged separately at
D:/gen1recomp/.codex-temp/interface-deploy/summary_ui.lua.
Compared tracked Battle Art runtime/data/shaders/main/manifest to installed
BATTLE_ART_VOXEL_FORK and copied only differences (2 files); also deployed
1 companion UI file. All copied hashes verified. Backups retained at
D:/gen1recomp/.codex-temp/interface-deploy/backup-20260907-030042.
No asset copying or deletion. Local playback/centering tests passed; in-game
visual verification requires restart.

## FULL Dex vertical centering (2026-09-07)

FULL Dex sprites now center vertically in the 72-pixel portrait area including
the number row, clamped at y=0 for oversized art instead of stock 64-h which
clips the top. Number remains drawn over the sprite as authorized. Matching
true-color marks move with the sprite; FIT is unchanged. 3173 mocked interface
checks and syntax/whitespace checks pass. Deployed InterfaceSprites.lua to the
installed BATTLE_ART_VOXEL_FORK with backup and matching SHA256. Device visual
verification remains outstanding.

## First-pose Dex anchor (2026-09-07)

Per user correction, FULL Dex vertical position now uses the first prepared
frame opaque y0/y1, not maximum animation/canvas height. Subtract first y0
from centered placement, keeping placement constant across animation. Shared
canvas still preserves pixels; it does not determine placement. Status remains
unchanged (user approved Charizard). 3173 mock checks and syntax/whitespace pass.
Deployed InterfaceSprites.lua with backup and SHA256 verification. Actual
animation stretching is not established by the screenshot; native pixels are
not rescaled by this anchor change. Device visual confirmation remains pending.

## Summary first-pose anchor and provider reflections (2026-09-07)

User confirms Android single-image title replay fixed banding and Dex FULL/FIT
looks good. FULL Summary now subtracts first frame opaque y0 from placement,
retaining its approved horizontal centering and native size. No Dex changes.

Found drawCast invoked normal provider drawEntity during reflectPlane pass;
provider models bypass billboardMatrix, so their draw was not mirrored. Added
optional drawReflection callback with reflectionPlane/reflectionRaise context.
Unclaimed reflections use existing mirrored engine sprite; provider art needs
the explicit callback to match its custom appearance in the water. Normal
provider rendering unchanged. Original 55e195d canvas/shader path remains.

Regression checks: water cast 47, heal overlay 63, ladders 38, cut drop 22,
cut refresh 10, restored hooks 22 all pass. Original dfc177c ladder geometry,
c083147 heal overlay alignment, 7991cce immediate prop removal retained.
Cut removal still permits background mesh rebuilding as the original commit
did; this is not a claim that every map rebuild has been eliminated.
Interface checks 3174 plus 5 modern replay checks pass; Lua syntax and whitespace
pass. Deployed InterfaceSprites, CharacterRenderers, VoxelScene with backup
and verified hashes. Phone reflection visual verification remains pending.
Uncommitted; published master/tag not moved.
# Exact Lavender north-exit bald-square fix - 2026-09-10

The in-engine screenshot finally identified the remaining bald patch precisely:
it is NOT the Lavender sign floor and NOT the Pokemon Tower flowerbed claim.
It is Route 10's southernmost source block at block coordinate `(4,35)`, block
`$31`, which expands to tiles `x16..19 / y140..143` and is entirely tile `$39`.
Because Route 10 is rendered as Lavender's northern neighbour, Battle Art's
broad sandy cave-to-Lavender approach treatment was painting that 32x32 seam
block as an isolated dirt square inside Lavender's otherwise green lawn.

`ChunkMesher` now treats exactly that one authored Route 10 seam block as plain
grass in BOTH Battle Art and Legendary, before the generic `$39` path branch.
The rest of Route 10's sandy Battle Art approach is unchanged, Lavender's
checker/path network is unchanged, and the large Pokemon Tower flower square is
unchanged. This is visual-only; collision, source tiles, warps and encounters
are untouched. The Route 10 body cache revision is now
`route10-lavender-approach-v3-exit-lawn` so an older sandy seam mesh cannot be
reused.

Release follow-up: after in-engine confirmation that the Route 10 exit lawn fix
worked, the user explicitly approved bumping both version surfaces to `1.10.7`
and tagging that new branch head as `1.10.7`.

## TEST56 merge into 1.10.8 (2026-09-11)

Merged Desktop Test56 non-destructively into the user-requested 1.10.8 branch.
See docs/TEST56_MERGE_1.10.8.md for provenance, scope, menu mapping, exclusions,
and validation. Current Battle Art Lavender/Route 10 fixes and tree-detail
submenu are retained. New casino/prize room and interior toggles default to
Battle Art, with saved selections preserved. Legendary Visuals now groups
Game Corner, Lavender & Cities, and Interiors. Capture options retain the
donor Ember Legacy grouping. Package version remains 1.10.7; no commit/push.

Legendary media now lives exclusively under assets/legendary/, including
ember-legacy/poke_ball audio. All 44 files match Test56 hashes; old lib media
was removed only after verifying identical destination copies. Media stays
ignored and must be distributed separately. Concurrent .gitignore edits kept.

The donor hosted-flight patch was withheld because it replaces companion
methods; existing hosted provider behavior remains. Native Fly changes are
included. Corrected donor capability-query drawing and cleared map-local lamp
state at scene end. LuaJIT compiled 151 Lua files; 18 standalone suites and
91 interior/menu, 55 city-ground, 216 Lavender-approach assertions passed.
These are local static/mocked checks, not Android gameplay/visual validation.

## Gen 2 support: Gold, Silver and Crystal (2026-09-12)

`manifest.json` now declares `"games": ["gen1", "gen2"]` at version `1.11.0`.
`docs/GEN1_GEN2_DIFFERENCES.md` was rewritten from "why this is Gen 1-only"
into the state of the port; `CHANGELOG.md` carries the per-file list. This
section is the evidence and what is left.

### The rule the port is built on

On a Gen 2 boot, `src/mods/Gen2Compat.lua` answers a mod's require for fifteen
Gen 1 names. The `src.world.OverworldController` answer is a facade over the
live `World` that dispatches back through exactly three members -- `update`,
`interact`, `talkTo` (`Gen2Compat.worldTick` / `interactWrapper` /
`talkToWrapper`). A patch on anything else is taken, reads back as our own
function, and is never called.

So every install site that PATCHES rather than CALLS now asks
`lib/Generation.lua` first. Sites that go through a hook, an event or a
registry needed nothing: those names mean the same thing in both engines.

### Checks performed in this checkout

Engine: `gen1recomp` source at HEAD, whose `src/mods/Gen2Compat.lua` is
byte-identical to the shipped `0.2.59` AppImage, so the compat contract under
test is the one the user runs.

- `modkit gen2check`: **38 errors -> 10**. The ten are the
  `lib/OverworldBattle.lua` write sites for the five absent battle members.
  MK404 reports a patch of an absent member separately from the read and there
  is no idiom that silences a write while still patching, so these are the
  static scan's view of code that is gated at runtime by
  `OverworldBattle.available()` plus a per-seam presence test. Not clean, and
  deliberately so.
- `modkit validate`: byte-identical to upstream (the four pre-existing MK301
  ROM-cache findings, unchanged).
- `tests/gen2_support_test.lua`: 118/118 over Gold, Silver, Crystal and a Red
  control. It asserts `mod.state == "loaded"` rather than only `#errors == 0`,
  because a gate skip is not an error and would otherwise pass; and it reads
  the ENGINE tables for the install sentinels, so "the Gen 1 patch did not
  land" is evidence rather than our own bookkeeping.
- Full mod suite: **99 pass / 84 fail**, against pristine upstream's
  **98 / 84** -- a file-by-file diff shows the only difference is the added
  case. The 84 are pre-existing and identical in both copies (cases needing a
  real LOVE context, and cases whose hardcoded `DS_MOD_PATH` default names a
  directory this package is not called). An earlier measurement of this
  reported 183/183 and was wrong: the loop expanded `$?` after a
  `$(basename ...)` substitution, so it recorded basename's exit code rather
  than the test's. The regression conclusion is unchanged -- it rests on the
  upstream-vs-fork diff, which was measured correctly -- but the absolute
  pass counts were not real. Three unit tests
  needed their stub `V` taught about the new `Generation` module
  (`interface_sprites_install_test`, `legendary_cave_merge_test`,
  `atmosphere_companion_integration_test`) -- those stubs assert on unknown
  module names by design, so a new dependency has to be declared.
- **Real Crystal boot**, shipped `0.2.59` AppImage under Xvfb with a sandboxed
  save identity (`POKEPORT_IDENTITY`) so the user's own profile was untouched:
  `state=loaded`, zero boot errors, `GameVersion` reported
  `crystal / generation 2 / lineage crystal`, ladder `OFF/FULL/15/35/50/75`,
  rung 7 clamped to 5, world reached (`PLAYERS_HOUSE_2F`), and the diorama
  drawn at both FULL and 75 degrees with real geometry, cast shadows and the
  player billboard. Software GL (llvmpipe) was needed for the 3D pass;
  without it the engine correctly keeps the 2D path.

Three crashes were found only by that real boot, not by any static check --
`doorTiles`, `Player:pose` and `map.renderer`. Each one left the world flat
while the mod reported itself loaded, which is the failure mode this whole
port is about.

### Not verified

One interior map on one cart. No outdoor, cave, water or connected-map
playtest; no Gold or Silver boot (headless only); no battle fought on Gen 2;
no save/reload cycle. The terrain is greyscale by construction, not by
accident -- see the known limitation in the doc.

### Remaining work, in the order it would pay off

1. DONE (2026-09-12): Gen 2 terrain colour, by baking the tileset atlas per
   PalMap slot against the eight BG palettes. Verified on Crystal in
   PLAYERS_HOUSE_2F -- tan floor, brown panelling, blue console screens, all
   matching the flat 2D render. Remaining in this area: ANIMATED tiles, which
   Gold drives by frame rewrite (`tileset.anim` / `animFrames` /
   `flowerFrames`) where the Gen 1 path in TerrainAtlas keys off
   `TileRenderer.animFrame` and the Gen 1 renderer -- so Gen 2 water is
   coloured but still.
2. PARTLY DONE (2026-09-12): `3D-BTL` runs on Gen 2 via `lib/Gen2Battle.lua`,
   which is a different implementation rather than a port. The engine already
   draws `world:draw()` behind a battle under BATTLE BG = world -- and that is
   the call that asks for our pipeline -- so the work was suppressing the
   panel's own opaque `Chrome.clear` through `drawScene(bodyFn)` /
   `drawSceneBody(panelFn)`, and holding BATTLE BG there. Verified on Crystal:
   CYNDAQUIL vs RATTATA fought over the 3D bedroom, HUD and menu over the top.
   What remains is the STAGED half: an arena search, the over-the-shoulder
   camera, the mons as billboards standing in the scene instead of in Gold's
   flat panel over it, and backplates under Gold's HUD (which is authored for
   a white field and can land a name box on busy geometry).

   Trap recorded: a Gen 2 battle shot during its ENTRANCE looks greyscale --
   `drawScene` opens with `GbcPalette.setBgp(self:exitFadeBgp() or ...)` and
   the fade ramp greys the panel deliberately. Wait for `phase == "menu"`.
   Reproducing it with the mod disabled is what proved it was not ours.
3. The walk through Gold's own step machinery for `1ST` / `3RD`:
   `movement.collision`, `input.step` / `input.key`, and `world.stepped` in
   place of Gen 1's `onStepComplete`.
4. Johto/Kanto-Gen2 mappings for the GEN6 arena router and map atmosphere,
   which still carry Kanto map ids and currently fall back safely.
5. Gen 2 equivalents for the `game.data.field` features that answer nil there:
   CAVE DARKNESS (`darkMaps`), the heal-machine sheet (`overworldFx`) and the
   cut-tree swaps.
