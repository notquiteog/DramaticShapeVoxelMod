-- Gen 2 support: the mod loads on Gold, Silver and Crystal, the features that
-- cross are installed there, and the Gen 1-only patches are genuinely absent.
--
-- Three things this case is careful about, because each of them is a way a
-- port like this reports success while doing nothing:
--
-- 1. It asserts mod.state, not just the error count. A gate skip is
--    deliberately NOT an error -- Loader:_skip sets state and skipReason and
--    stays off loader.errors -- so `#errors == 0` passes for a mod that never
--    ran a line, which is the one outcome this file exists to rule out.
--    (docs/preparing-your-mod-for-gen2.md, "Testing".)
--
-- 2. It reads the ENGINE tables to decide whether a patch landed, not the
--    mod's own bookkeeping flags. A test that asks MomHealFlash whether
--    MomHealFlash installed itself would pass with the whole gate deleted.
--    The engine-side sentinels (OverworldController.dramaticShapePoisonFlashHook
--    and friends) are written by the install paths themselves, so their
--    absence on a Gen 2 boot is evidence rather than a claim.
--
-- 3. It sets GameVersion the way a boot does, per cart, instead of relying on
--    the harness's `generation` option alone. The option reaches Loader.new
--    and drives the gate and the require shim, but it does not touch
--    GameVersion, which is what lib/Generation.lua reads -- so a case that set
--    only the option would test the loader's half and none of the mod's.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local GameVersion = require("src.core.GameVersion")

-- The real Gen 1 module tables, captured HERE -- before the first loadMod --
-- for two reasons that both bite later.
--
-- The loader replaces _G.require for the life of the process, and on a Gen 2
-- load a require whose caller is not the engine tree is answered by
-- Gen2Compat. This file lives under mods/, so its own requires can be read as
-- a mod's and come back as the facade rather than the module: the sentinels
-- below would then be missing because we were looking at the wrong table, and
-- the case would pass for the wrong reason. Requiring once, up front, while no
-- load is in flight, settles which tables these names mean.
--
-- The tables are also process-wide and `require` caches them, so a patch a
-- Gen 1 load lands stays landed for every later load in this process. That is
-- what the cart ORDER below is about.
local ENGINE = {
  ["src.world.OverworldController"] = require("src.world.OverworldController"),
  ["src.battle.BattleState"] = require("src.battle.BattleState"),
}

local MOD_PATH = os.getenv("DS_MOD_PATH") or "mods/DramaticShapeVoxelMod"
local MOD_ID = "BATTLE_ART_VOXEL_FORK"

-- Every Gen 2 cart the engine knows, then one Gen 1 cart as the control.
--
-- Driven off GameVersion.ORDER rather than a list of our own: a cart added to
-- the engine later joins this case automatically instead of silently escaping
-- it, which is the same reason ModTargets derives its tokens from ORDER.
--
-- The Gen 2 carts run FIRST, and that ordering is load-bearing. The engine
-- module tables live for the whole process, so once a Gen 1 load has installed
-- the patches it cannot be un-installed for the next iteration -- "the Gen 2
-- boot left this unpatched" would then be unprovable. Running Gen 2 while the
-- tables are still pristine makes a missing sentinel mean exactly one thing.
-- The Gen 1 control comes last and proves the sentinels are reachable at all,
-- which is what stops the Gen 2 half from passing vacuously.
local carts = {}
for _, id in ipairs(GameVersion.ORDER) do
  if GameVersion.generation(id) == 2 then
    carts[#carts + 1] = { id = id, generation = 2 }
  end
end
carts[#carts + 1] = { id = "red", generation = 1 }

T.check(#carts == 4, "the engine has three Gen 2 carts plus the control: got "
  .. tostring(#carts))

-- The engine sentinels each Gen 1-only install path writes on success. Name
-- and owner, so a failure says which install leaked.
local ENGINE_PATCHES = {
  { module = "src.world.OverworldController",
    key = "dramaticShapePoisonFlashHook", owner = "PoisonFlash" },
  { module = "src.world.OverworldController",
    key = "dramaticShapeBattleHook", owner = "OverworldBattle (staged battle)" },
  { module = "src.world.OverworldController",
    key = "dramaticShapeFreeMoveHook", owner = "FreeMove (1ST walk)" },
  { module = "src.battle.BattleState",
    key = "dramaticShapeTrainerPartyHook", owner = "OverworldBattle newTrainer" },
  { module = "src.battle.BattleState",
    key = "dramaticShapeEncounterKindHook", owner = "OverworldBattle newWild" },
}

local previousVersion = GameVersion.get()

for _, cart in ipairs(carts) do
  local label = ("%s (gen %d)"):format(cart.id, cart.generation)

  GameVersion.set(cart.id)
  local run = T.sdk.loadMod(MOD_PATH,
    { data = T.fixtures.fresh(), generation = cart.generation })
  local mod = run.mod

  -- ------- it runs at all
  T.eq(mod and mod.state, "loaded",
    label .. ": the entry chunk runs -- " .. tostring(mod and mod.skipReason))
  T.eq(#run.errors, 0,
    label .. ": loads with no boot errors -- " .. table.concat(run.errors, "; "))

  local exports = run.loader.exports[MOD_ID]
  T.check(exports and exports.lib and exports.lib.require,
    label .. ": the mod published its lib namespace")
  local lib = exports.lib.require

  -- ------- the discriminator agrees with the cart
  local Generation = lib("Generation")
  Generation.reset() -- this process has already booted another cart
  T.eq(Generation.number(), cart.generation,
    label .. ": Generation.number follows the cart")
  T.eq(Generation.version(), cart.id,
    label .. ": Generation.version names the cart")
  T.eq(Generation.lineage(), GameVersion.engine(cart.id),
    label .. ": Generation.lineage matches the engine's own lineage")
  T.check(Generation.number() == 1 or Generation.lineage() ~= "gen1",
    label .. ": a Gen 2 cart never reports the Gen 1 lineage")

  -- ------- what crosses, and what does not
  local Voxel = lib("VoxelState")
  local OverworldBattle = lib("OverworldBattle")

  if cart.generation == 1 then
    T.eq(Generation.screenId("StartMenu"), "StartMenu",
      label .. ": the start menu keeps its Gen 1 id")
    T.eq(#Voxel.availableLevelLabels(), #Voxel.ANGLE_LABELS,
      label .. ": every voxel rung is on the ladder")
    T.check(Voxel.freeCamAvailable(), label .. ": the free-cam rungs are offered")
    T.check(OverworldBattle.available(), label .. ": battles can be staged")
  else
    T.eq(Generation.screenId("StartMenu"), "Gen2StartMenu",
      label .. ": the start menu resolves to Gold's screen id")
    -- Gen 1's BoxMenu pairs with Gen2PcMenu, not with Gen2BoxMenu
    T.eq(Generation.screenId("BoxMenu"), "Gen2PcMenu",
      label .. ": Bill's PC top menu pairs with PcMenu, not BoxMenu")

    T.eq(#Voxel.availableLevelLabels(), Voxel.ORBIT_LEVEL_COUNT,
      label .. ": the ladder ends at the last orbit rung")
    T.check(not Voxel.freeCamAvailable(),
      label .. ": the free-cam rungs are not offered")
    -- The engine clamps a stored level to #labels - 1 in both setLevel and
    -- applyOptions, so a level saved by a Gen 1 session cannot select a rung
    -- that is no longer there. Assert the ladder's last rung is an orbit one.
    local labels = Voxel.availableLevelLabels()
    T.eq(labels[#labels], "75",
      label .. ": the highest selectable rung is the 75 degree orbit")

    T.check(not OverworldBattle.available(),
      label .. ": battles are not staged on this cart")
    T.eq(OverworldBattle.enabled(), false,
      label .. ": and the staged-battle switch reads off whatever is stored")

    -- the reasons are published rather than inferred from a false flag
    T.check(lib("MomHealFlash").skipped,
      label .. ": MomHealFlash says why it stood down")
    T.check(lib("PoisonFlash").skipped,
      label .. ": PoisonFlash says why it stood down")
    T.check(lib("InterfaceSprites").screenPatchesSkipped,
      label .. ": InterfaceSprites says why its screen patches stood down")
    T.eq(lib("MomHealFlash").installed, false,
      label .. ": MomHealFlash did not take the script.command hook")
  end

  -- ------- the guard that cannot lie: did the patch reach the engine?
  for _, patch in ipairs(ENGINE_PATCHES) do
    local engineModule = ENGINE[patch.module]
    T.check(engineModule ~= nil,
      label .. ": " .. patch.module .. " was captured up front")
    local landed = engineModule[patch.key] ~= nil
    if cart.generation == 1 then
      T.check(landed,
        label .. ": " .. patch.owner .. " patched " .. patch.module)
    else
      T.check(not landed,
        label .. ": " .. patch.owner .. " left " .. patch.module
          .. " unpatched (" .. patch.key .. ")")
    end
  end

  -- ------- the cross-generation features really are registered
  --
  -- The render pipelines and the sprite seam are the half of this mod that
  -- works on Gold, so a port that quietly dropped them would be as wrong as
  -- one that kept the Gen 1 patches.
  -- render_pipelines is one of the registries that is NOT on Schemas' Gen 2
  -- "no home here" list: it merges to data.render_pipelines on both
  -- generations and src/core/Game2.lua:load calls Pipelines.install after the
  -- merge, which is exactly why the diorama is the half of this mod that
  -- crosses (src/mods/Schemas.lua:579-591).
  local pipelines = run.data.render_pipelines or {}
  T.check(pipelines.voxel ~= nil,
    label .. ": the voxel pipeline is registered")
  T.check(pipelines.tiltshift ~= nil,
    label .. ": the tiltshift pipeline is registered")

  local chains = run.loader.hooks and run.loader.hooks.chains or {}
  T.check(chains["pokemon.sprite"] ~= nil,
    label .. ": the pokemon.sprite seam is claimed, so BATTLE ART's own "
      .. "sprites reach this cart")

  run.release()
end

GameVersion.set(previousVersion)

T.finish("gen 2 support")
