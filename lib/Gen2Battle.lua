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
-- Suppress that one fill and the diorama is behind the fight as well. So this
-- replaces `drawPanel` with its own body minus the clear, and every other path
-- through the scene -- the slide-in, the animation view, the lifted rows, the
-- exp burst, `battle.overlay` -- is still the engine's own.
--
-- `drawPanel` and NOT the `drawSceneBody(panelFn)` seam, which is the tidier
-- looking route and was the first attempt. The engine builds the panel as
-- `panelFn or function() self:drawPanel() end`, so passing a panel works --
-- right up until another mod wraps `drawSceneBody` with a signature that
-- drops the argument:
--
--     function BattleState2:drawSceneBody()      -- no panelFn
--       ...
--       innerDrawSceneBody(self)                 -- and none forwarded
--     end
--
-- crystal_animated_sprites_with_shiny_visuals 2.0.3 does exactly that, and
-- the result is silent: our panel is swallowed, the engine falls back to its
-- own `drawPanel`, and the fight draws on a white slab with no error anywhere.
-- Replacing `drawPanel` itself needs no argument to survive a chain, so it
-- cannot be broken by a link that forgets to forward one.
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

-- Is this mon already standing on the arena as a billboard this frame?
--
-- Asked per drawPic call rather than once per frame because a side can be
-- declined mid-battle (a faint, a send-out, a Transform mid-animation) and
-- the flat slot has to come back for it the moment it is.
function Gen2Battle.stagedMon(mon)
  if mon == nil then return false end
  local OverworldBattle = V.require("OverworldBattle")
  if not OverworldBattle.available() then return false end
  local shot = OverworldBattle.shot()
  if not (shot and shot.canvas) then return false end
  local drawn = V.require("Gen2Staged").drawn
  if type(drawn) ~= "table" then return false end
  for _, staged in pairs(drawn) do
    if staged == mon then return true end
  end
  return false
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
  local inner = BattleState.drawPanel
  if type(inner) ~= "function" then
    Gen2Battle.skipped = "this engine's Gen 2 battle screen has no drawPanel"
    return
  end

  -- Game2.paintBattleSurround shades the margins even in WORLD mode.
  -- Suppress its explicit dim value while the diorama owns the background;
  -- changing battleFit cannot remove these side strips and rescales the HUD.
  if type(BattleState.bgMode) == "function" then
    local innerBg = BattleState.bgMode
    local savedDim = setmetatable({}, { __mode = "k" })
    function BattleState:bgMode()
      if sceneOverrideOn() then
        if not savedDim[self] then
          savedDim[self] = { value = rawget(self, "BG_WORLD_DIM") }
        end
        self.BG_WORLD_DIM = 0
      elseif savedDim[self] then
        self.BG_WORLD_DIM = savedDim[self].value
        savedDim[self] = nil
      end
      return innerBg(self)
    end
  end

  function BattleState:drawPanel()
    if not sceneOverrideOn() then return inner(self) end
    -- The engine's own guard, borrowed rather than guessed: with no battler
    -- pair the panel prints NO BATTLE over a cleared field, and that field
    -- has to stay opaque or the message sits on the map. hasBattleSides is
    -- exported for exactly this kind of reuse.
    local sides = BattleState.hasBattleSides
    if type(sides) == "function" then
      local ok, has = pcall(sides, self)
      if ok and not has then return inner(self) end
    end
    -- HUD backplates: with the white slab gone, the HUDs' name/HP tiles
    -- would sit straight on the diorama.  The engine's own box style under
    -- both blocks keeps them readable and matches the text box that draws
    -- after them.  Enemy block: name/level/gender/bar/frame, tiles (0,0)
    -- through (11,3).  Player block: name/status/bar/numbers/exp, tiles
    -- (9,6) through (19,12).
    do
      local okFont, BoxFont = pcall(require, "src.render.Font")
      local ownsHud=type(self.usesModernDoublesHud)=="function" and self:usesModernDoublesHud()
      if not ownsHud and okFont and BoxFont and type(BoxFont.drawBox) == "function" then
        BoxFont.drawBox(0, 0, 12, 4)
        BoxFont.drawBox(9, 6, 11, 7)
      end
    end
    -- drawPanel's own body, minus the Chrome.clear() that would paint over
    -- the world the engine drew for us a moment ago.
    if type(self.drawHud) == "function" then self:drawHud() end
    if type(self.drawBottom) == "function" then self:drawBottom(0) end
  end

  -- The mons are geometry standing on the arena now, drawn in the 3D pass
  -- before this screen composites at all, so the flat panel must not draw
  -- them a second time in their slots. Exactly the mons a billboard was
  -- built for this frame, and nothing else: a side Gen2Staged declined --
  -- a fainted slot, a missing pic, the send-out before a mon exists -- still
  -- draws flat, which is what keeps the screen honest while the arena is
  -- only half there.
  if type(BattleState.drawPic) == "function"
     and not BattleState.dramaticShapeGen2PicHook then
    local innerPic = BattleState.drawPic
    function BattleState:drawPic(mon, back, ...)
      if Gen2Battle.stagedMon(mon) then return end
      return innerPic(self, mon, back, ...)
    end
    BattleState.dramaticShapeGen2PicHook = true
  end

  -- The animation view has its own opaque fill, independent of drawPanel.
  do
    local okView, BattleAnimView = pcall(require, "src.ui.gen2.BattleAnimView")
    if okView and type(BattleAnimView.fillBackground) == "function"
       and not BattleAnimView.dramaticShapeGen2AnimHook then
      local innerFill = BattleAnimView.fillBackground
      function BattleAnimView:fillBackground(palByte)
        if sceneOverrideOn() then return end
        return innerFill(self, palByte)
      end
      BattleAnimView.dramaticShapeGen2AnimHook = true
    end
  end

  BattleState.dramaticShapeGen2SceneHook = true
  Gen2Battle.installed = true
end

return Gen2Battle
