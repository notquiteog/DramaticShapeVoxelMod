-- Mom's healing script in REDS_HOUSE_1F surrounds the heal jingle with the
-- Game Boy's fade-to-white / fade-from-white pair.  The engine faithfully
-- draws that overlay at 160x144, which only covers part of a modern 3D view.
--
-- Keep the shared fade command intact for transitions and every other map.
-- This wrapper skips only white fades while the player is in Red's house;
-- those are the two commands in Mom's healing script.
--
-- The seam is the engine's own `script.command` hook, raised with the same
-- (ctx, name, args) argument list by both script runners -- Gen 1's row
-- dispatcher (src/script/ScriptRunner.lua:170) and Gold's bytecode VM
-- (src/script/gen2/Vm.lua:1860).  It used to be a monkey-patch of
-- src.script.Commands.fade, which cost this mod the only hard Gen 2 blocker
-- it had: a Gen 2 boot never runs that module, Gen2Compat has no adapter for
-- it, and the require alone lands on the mod manager's error feed
-- (src/mods/Loader.lua:180).  A hook needs no engine module at all, and it
-- leaves an engine gameplay class unpatched, which is the house rule.
--
-- Still installed on Gen 1 only, and that is a content judgement rather than a
-- capability one: REDS_HOUSE_1F is a Kanto map, `fade` is a Gen 1 verb, and
-- the predicate below can never be true on Gold.  Wrapping Gold's VM to ask a
-- question with a constant answer would put a link in front of every command
-- the cart's own bytecode runs, for nothing.  Gold's mom, her healing
-- sequence and her script VM stay untouched.

local V = ...
local Generation = V.require("Generation")

local MomHealFlash = {}

local function mapId(ctx)
  local map = ctx and ctx.overworld and ctx.overworld.map
  return map and (map.id or (map.def and map.def.id))
end

local function fadeColor(framesOrColor, colorOrFrames)
  if type(framesOrColor) == "string" then return framesOrColor end
  if type(colorOrFrames) == "string" then return colorOrFrames end
  return "black"
end

function MomHealFlash.shouldSuppress(ctx, framesOrColor, colorOrFrames)
  return mapId(ctx) == "REDS_HOUSE_1F"
    and fadeColor(framesOrColor, colorOrFrames) == "white"
end

-- Set once install() has taken the hook, so a second call is a no-op the way
-- the old sentinel on the engine table was.  Ours to read: a test asks this
-- rather than reaching into an engine module for a marker we no longer write.
MomHealFlash.installed = false

-- True when this build deliberately left the wrapper out, so the reason is
-- readable rather than inferred from `installed` being false.
MomHealFlash.skipped = nil

function MomHealFlash.install()
  if MomHealFlash.installed then return end
  if not Generation.isGen1() then
    MomHealFlash.skipped = "gen1-only content: REDS_HOUSE_1F and the `fade` verb"
    return
  end

  -- Returning without calling `next` drops the command: both runners read a
  -- non-string, non-number result as "advance one row" (ScriptRunner.lua:176,
  -- Vm.lua:1878), which is precisely what the engine does for a fade it ran.
  V.mod.hooks:wrap("script.command", function(next, ctx, name, args)
    if name == "fade" and type(args) == "table"
        and (args[1] == "out" or args[1] == "in")
        and MomHealFlash.shouldSuppress(ctx, args[2], args[3]) then
      return
    end
    return next(ctx, name, args)
  end)

  MomHealFlash.installed = true
end

return MomHealFlash
