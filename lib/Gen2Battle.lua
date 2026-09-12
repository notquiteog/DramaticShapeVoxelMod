-- 3D-BTL on Gold, Silver and Crystal: the battle drawn over the live diorama.
--
-- This is a different implementation of the same row, not a port of the Gen 1
-- one, because the two engines put the world behind a battle in opposite ways.
--
-- On Gen 1, Battle Art stages the fight itself: it finds clear ground, points
-- an over-the-shoulder camera at it, renders the mons as billboards in that
-- 3D space, and composites the HUD over the result. Every seam that needs --
-- picImage, resolveBattleScale, frontPlacement, backPlacement, newWild,
-- newTrainer, pushBattle -- is absent on Gen 2, which is why
-- OverworldBattle.available() is false there and stays false.
--
-- On Gen 2 the engine already does the hard part. `Game2:drawScene` has a
-- branch for it (src/core/Game2.lua:1848):
--
--     if battleSurround(self.stack) == "world" then
--       self.frameWorldActive = true
--       self:letterbox(w, h, true)
--       self.world:draw()          -- <- the LIVE world, every frame
--       Chrome.worldSurround = true
--     end
--     wide:drawWidescreen(w, h)
--
-- `World:draw` is the very function that asks `Pipelines.worldPipeline()` and
-- calls `World:drawPipeline` (src/world/gen2/World.lua:11643), so under
-- BATTLE BG = world the thing drawn behind a Gen 2 battle IS this mod's
-- diorama, live, at whatever rung is selected. `Chrome.worldSurround` then
-- suppresses the letterbox fill that would have covered it.
--
-- One thing is left over, and it is the whole of this file: the 160x144 panel
-- still clears itself opaque. `BattleState:drawPanel` opens with
-- `Chrome.clear()`, which is a full-panel `paletteFill` -- and unlike
-- `Chrome.letterbox` it does not consult `worldSurround`, because on the cart
-- the battle background genuinely is a white field. So the native WORLD mode
-- shows the world in the MARGINS and a white slab where the fight is.
--
-- Suppress that one fill and the diorama is behind the fight as well. The
-- engine hands us the two injection points to do it without patching a
-- drawing helper: `drawScene(bodyFn)` takes the whole body, and
-- `drawSceneBody(panelFn)` takes the panel -- so the panel is rebuilt as its
-- own two calls minus the clear, and every other path through the scene (the
-- slide-in, the animation view, the lifted rows, the exp burst,
-- `battle.overlay`) is still the engine's own.
--
-- What this deliberately does NOT do, and what separates it from the Gen 1
-- rung: there is no arena search and no over-the-shoulder camera. The world
-- behind the fight is the player's own view of the map they are standing on,
-- because that is what `World:draw` draws. The mons, their placement, their
-- scale, the HUD and the text box all stay Gold's. So this is "the fight
-- happens on the diorama", not "the fight is staged and shot".

local V = ...
local Generation = V.require("Generation")
local OverworldBattle = V.require("OverworldBattle")

local Gen2Battle = {}

-- Gen 2 only. The Gen 1 rung is OverworldBattle's and the two never both run:
-- OverworldBattle.available() is the Gen 1 test and is false here.
function Gen2Battle.available()
  return Generation.isGen2()
end

-- The row is shared with the Gen 1 rung, so a player who turns 3D-BTL off
-- gets Gold's own white battle field back and the BATTLE BG row with it.
function Gen2Battle.enabled()
  if not Gen2Battle.available() then return false end
  return OverworldBattle.setting:get() and true or false
end

-- Diagnostic seam: nil means "follow enabled()", false isolates the panel
-- override from the BATTLE BG hold so the two can be told apart in a shot.
Gen2Battle.sceneOverrideEnabled = nil

local function sceneOverrideOn()
  if Gen2Battle.sceneOverrideEnabled ~= nil then
    return Gen2Battle.sceneOverrideEnabled
  end
  return Gen2Battle.enabled()
end

-- BATTLE BG has to be `world` for any of this to happen -- it is what puts
-- the engine into the branch that draws the world at all. Held while the row
-- is on, the same way the Gen 1 rung holds BATTLE LAYOUT at OG, and the row
-- is taken off the menu for the same reason: a row that cannot decide
-- anything is worse than no row. Switching 3D-BTL off gives both back.
--
-- Returns true when it changed something, so the caller can persist once
-- rather than writing the options file every frame.
function Gen2Battle.holdWorldBg(options)
  if not (options and Gen2Battle.enabled()) then return false end
  if options.battleBg == "world" then return false end
  options.battleBg = "world"
  return true
end

Gen2Battle.installed = false

function Gen2Battle.install()
  if Gen2Battle.installed then return end
  if not Gen2Battle.available() then
    Gen2Battle.skipped = "gen1 stages its own battle (OverworldBattle)"
    return
  end

  local BattleState = require("src.battle.BattleState")
  -- The four UI facades are write-through, so this lands on the class Gold
  -- actually pushes (src/ui/gen2/BattleState.lua), and reads back as ours --
  -- which is what makes the captured `inner` safe rather than re-entrant.
  if BattleState.dramaticShapeGen2SceneHook then
    Gen2Battle.installed = true
    return
  end
  local inner = BattleState.drawScene
  if type(inner) ~= "function" then
    Gen2Battle.skipped = "this engine's Gen 2 battle screen has no drawScene"
    return
  end

  function BattleState:drawScene(bodyFn)
    -- A caller that brought its own body owns the whole scene; leave it be.
    if bodyFn or not sceneOverrideOn() then
      return inner(self, bodyFn)
    end
    return inner(self, function()
      self:drawSceneBody(function()
        -- drawPanel's own body, minus the Chrome.clear() that would paint
        -- over the world the engine drew for us a moment ago.
        if type(self.drawHud) == "function" then self:drawHud() end
        if type(self.drawBottom) == "function" then self:drawBottom(0) end
      end)
    end)
  end

  BattleState.dramaticShapeGen2SceneHook = true
  Gen2Battle.installed = true
end

return Gen2Battle
