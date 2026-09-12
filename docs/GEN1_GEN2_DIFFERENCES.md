# Battle Art on Gen 2: what runs, what does not, and why

Battle Art 1.11.0 declares `"games": ["gen1", "gen2"]`. It loads and runs on
Gold, Silver and Crystal, and the diorama draws there.

That is a narrower claim than "the mod works on Gen 2", and the difference is
the point of this document. Two of the headline features are Gen 1-only, by
design rather than by omission, and the terrain is greyscale. Everything below
separates what was verified from what is still missing.

The engine developers' companion documents are
[Guide: Preparing Your Mod For Gen 2](https://github.com/bryanthaboi/gen1recomp/wiki/Guide-Preparing-Your-Mod-For-Gen-2)
and `docs/mod-api-gen2-compat.md` in the engine tree.

## The one fact the rest follows from

On a Gen 2 boot a mod's `require` for one of fifteen Gen 1 names is answered by
`src/mods/Gen2Compat.lua`. For `src.world.OverworldController` that answer is a
facade over the live `World`, and it dispatches back through exactly three
members: `update`, `interact` and `talkTo` (`Gen2Compat.worldTick`,
`interactWrapper`, `talkToWrapper`, `src/mods/Gen2Compat.lua:1383`).

A patch on any other member is *taken*, *reads back as your own function*, and
is *never called*. Gold calls its own method. So the failure mode for this
port was never a crash -- it was a feature that installs cleanly and does
nothing, which is why every install site that patches rather than calls now
asks `lib/Generation.lua` first.

## What runs on Gold, Silver and Crystal

- **The voxel diorama.** `render_pipelines` is a registry with the same target
  on both generations, and `src/world/gen2/World.lua:11643` asks
  `Pipelines.worldPipeline()` for the world pass and hands it a full ctx
  through `World:drawPipeline`. The mesher, the camera, the depth buffer, the
  shadow map and the sprite billboards all run on that ctx.
- **BATTLE ART's sprites.** The engine resolves every battle, summary and dex
  pic through the `pokemon.sprite` hook (`src/pokemon/Sprites.lua`), which Gold
  raises under the same name with the same `ctx` keys -- so one subscription
  reskins both generations. A Gen 2 battle is fought with the selected
  generation's art, on Gold's own battle screen. `player.sprite` and
  `pokemon.icon` are the same story.
- **The options rows, the hotkeys and the start-menu rows.** `ui.options.rows`,
  `ui.start_menu.items`, `ui.title_menu.items`, `intro.oak_speech.build`,
  `world.tod`, `core.update`, `render.hud` and `input.pointer` are raised by
  both engine arms.
- **The battle-exit fade.** `BattleState.finish` is backed and the four UI
  facades are write-through, so the shutter closes on Gold too.
- **T-SHIFT, V-GRID, V-CURVE, WATER, the day/night clock.**

## What is Gen 1-only, and why

### 3D-BTL, the staged battle

`OverworldBattle.available()` returns false on Gen 2 and the row comes off the
OPTIONS menu.

Staging a battle means replacing six Gen 1 `BattleState` seams -- `picImage`,
`resolveBattleScale`, `frontPlacement`, `backPlacement`, `newWild`,
`newTrainer` -- plus `OverworldController:pushBattle`. Gen2Compat records all
seven as **absent**, each with its reason. Gold's battle screen is
`src/ui/gen2/BattleState.lua`: it resolves pics through `pic` / `drawPic`,
scales them through `picScale` / `imageScale` / `panelScale`, and
`World:startBattle` constructs and pushes in one call, so there is no unpushed
battle to decorate.

Restoring it is a battle-presentation adapter written against those Gen 2
seams. The arena search, the camera composition, the depth-of-field pass, the
backplates and the imported art are all reusable; the adapter has to supply
battle start/end notification, front/back image ownership and placement,
trainer identity, Transform state, and the HUD/text/animation suppression
seams. Gold's own `bgMode` / `BG_WORLD_DIM` / `extendedHUD` /
`extendedWorldHUD` / `bottomUIVisible` / `statusHUDVisible` are the likely
hooks, and `battle.overlay` plus `render.compose` are the neutral ones.

Note one difference that changes the design rather than the plumbing: on Gen 1
a staged battle works because the battle canvas is transparent and the
StateStack finds the overworld below it. Gold's battle stays **opaque** and its
map is painted by `Game2:drawScene` / `Game2:paintBattleSurround`, so the world
behind a Gen 2 battle has to be composed, not revealed.

### The 1ST and 3RD rungs, and free movement

`Voxel.freeCamAvailable()` returns false on Gen 2 and the ladder ends at the
75-degree rung -- `OFF / FULL / 15 / 35 / 50 / 75`. `Pipelines.maxLevel` is
`#labels - 1` and both `setLevel` and `applyOptions` clamp to it, so a level
stored by a Gen 1 session lands on 75 rather than on a rung that cannot draw.

The camera is not the problem; the walk is. `FreeMove` replaces
`OverworldController:handleInput`, which is not one of the three dispatch
seams, so the wrapper would never be called: the eye would stand in the
player's head with the grid walk still underneath it and the mouse captured for
a look the feet do not follow. A rung that half-works is worse than a rung
that is not offered.

Restoring it is a movement problem. The walk has to run through Gold's own
step and landing machinery -- `movement.collision` and `input.step` / `input.key`
are raised on both generations, and `world.stepped` is the supported
replacement for Gen 1's `onStepComplete` seam.

### The two presentation fixes

- `MomHealFlash` is Gen 1 content: `REDS_HOUSE_1F` is a Kanto map and `fade` is
  a Gen 1 verb. It no longer patches `src.script.Commands` at all -- it takes
  the `script.command` hook, which both runners raise with the same
  `(ctx, name, args)` list -- so the mod no longer requires a Gen 1-only
  engine module. It still installs on Gen 1 only, because wrapping Gold's VM
  to ask a question with a constant answer would put a link in front of every
  command the cart's bytecode runs.
- `PoisonFlash` wraps `applyFieldPoison`, which is backed for *calls* but is
  not a dispatch seam, so the patch would be inert. Gold's field poison stays
  entirely the engine's.

### The two screen-class installers

`InterfaceSprites.installTitle` / `installSummary` / `installDex` reach into
Gen 1 screen classes. Gold's title screen has no cycling starter to reskin --
it is Ho-Oh over the clouds, Suicune on Crystal, with no `currentSprite` at
all -- and Gold's summary pic is a `MonAnimView` on `self.picAnim` where Gen 1
keeps a plain image on `self.sprite`. The static art is already replaced by the
`pokemon.sprite` hook before Gold draws it, so nothing is lost for the art
itself; the animation surgery is what stays behind.

## Known limitation: the terrain is greyscale

This is the most visible gap and it is worth stating plainly.

Gen 1 hangs a `TileRenderer` off the map and that renderer owns the atlas the
mesher samples. Gold has no `map.renderer` -- Gen2Compat records it absent,
because Gold bakes whole-*map* images on the World
(`src/world/gen2/World.lua:bakeMapImage`) and keeps no per-map atlas. Without a
fallback the world pass got no texture at all and drew the diorama in flat
white: correct geometry, no art.

`lib/TerrainAtlas.lua` now falls back to the tileset's own image, which is the
same file Gold's `World:atlasFor` hands its own renderer. That file is the raw
2bpp Game Boy tile data -- 2-bit greyscale, four shades -- because a Gen 2 tile
takes its four colours at *draw* time from its PalMap slot inside the eight BG
palettes loaded for the map's environment, time of day and map group. Gold's
map bake walks those eight slots; an atlas has no single palette to bake into.

So a Gen 2 diorama is textured in greyscale. Porting the per-slot bake is the
next piece of work and the one that would most change how this looks.

## Other Gen 2 shapes worth knowing

These bit during the port and are recorded so they are not rediscovered.

- **`map.doorTiles` does not exist** and `Map:cellTile` answers a `COLL_*`
  byte rather than a tile id -- unrelated number spaces. `doorTiles[cellTile(...)]`
  therefore failed twice over and took the whole mesh build down. The neutral
  question is `Map:isDoorTileCell(cx, cy)`, which on Gen 1 *is* that lookup
  (`src/world/Map.lua:254`) and on Gold is the narrow
  `Permissions.isImmediateWarp` arm.
- **Gold's `Player` has no `pose()`.** Gen 1's Player and NPC both have one and
  so does `src/world/gen2/Npc.lua:542`, but Gold's Player draws itself and
  never needed the accessor -- and since the player is in `state.entities`,
  that nil call took the world pass down. `lib/VoxelScene.lua` composes the
  tuple from the Player's own `walkPhase` / `drawFlip` and fields. Gen 1's hop
  arc, surf bob and spin lift are deliberately not synthesised: they are read
  off Gen 1 Player fields Gold does not keep.
- **`map.warpAt` is a name collision, not a rename.** Gen 1's is a table keyed
  by cell; Gold's is a *method*. `map.warpAt[k]` and `pairs(map.warpAt)` both
  raise. Enumerate `map.warps`, which Gold carries as an ordered array.
- **`game.data.field` is warned and answers nil**, so CAVE DARKNESS
  (`field.darkMaps`), the heal-machine sheet (`field.overworldFx`) and the
  cut-tree swaps (`field.cutTreeSwaps`) are off on Gen 2. Every one of those
  reads was already nil-guarded, so they degrade to "feature off" rather than
  failing; Gold has real equivalents (a DARKNESS palset, `tryCut`) and wiring
  them up is separate work.
- **The `transitions` registry has no Gen 2 home at all**, so the battle-exit
  timing record is registered on Gen 1 only. `BattleExit.frames` falls back to
  `BattleExit.FRAMES`, so the fade still runs at 12 frames on Gold -- only
  retuning it in data is missing.
- **Crystal is a real fork, not a reskin.** `GameVersion.engine()` answers
  `"gs"` for Gold/Silver and `"crystal"` for Crystal, and `lib/Generation.lua`
  exposes that as `Generation.lineage()` / `isCrystal()`. Crystal has animated
  battle front pics, its own intro and splash, and screens Gold never had.

## How this was verified

- `python3 tools/modkit.py gen2check mods/DramaticShapeVoxelMod`: 38 errors
  down to 10. All ten are the `lib/OverworldBattle.lua` write sites above, which
  MK404 reports by design -- it flags a patch of an absent member separately
  from the read, and there is no idiom that silences a write while still
  patching. They sit behind `OverworldBattle.available()` and a per-seam
  presence test, and never execute on a Gen 2 boot.
- `python3 tools/modkit.py validate`: byte-identical to upstream.
- `tests/gen2_support_test.lua`: 118 checks across Gold, Silver, Crystal and a
  Red control. It asserts `mod.state == "loaded"` and zero boot errors on each
  cart, and it reads the **engine** tables to prove the Gen 1-only patches did
  not land -- a test that asked the mod's own flags would pass with the whole
  gate deleted.
- The mod's full suite: 183/183, with the only difference from upstream being
  the added case.
- A real Crystal boot, on the shipped 0.2.59 AppImage under Xvfb with a
  sandboxed save identity: mod `state=loaded`, no boot errors, ladder
  `OFF/FULL/15/35/50/75`, rung 7 clamped to 5, the world reached
  (`PLAYERS_HOUSE_2F`), and the diorama drawn at both the FULL and 75-degree
  rungs with real geometry, cast shadows and the player billboard.

## Definition of ready, restated

Gen 2 is declared because the mod runs there and the diorama draws, not
because every feature crossed. What a supported build still owes:

- coloured terrain (the per-slot palette bake above);
- a Gen 2 battle-presentation adapter, for 3D-BTL;
- the walk through Gold's own step machinery, for 1ST and 3RD;
- Johto/Kanto-Gen2 mappings for the GEN6 arena router and map atmosphere,
  which still carry Kanto map ids and fall back safely on a Johto map;
- Gen 2 equivalents for the `field.*` features listed above;
- outdoor, cave, water and connected-map playtests beyond the one interior
  verified here.
