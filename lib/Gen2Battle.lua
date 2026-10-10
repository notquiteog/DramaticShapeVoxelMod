-- Gen 2 staged battle composition. Game2 draws World behind its native battle
-- screen rather than using Gen 1's renderer override. The finished arena goes
-- through the existing world pipeline (even with the overworld rung OFF), while
-- the native panel/animation fills are suppressed. Only actors actually drawn
-- by Gen2Staged suppress their flat sprite; unavailable actors retain native art.
-- All battle mechanics and non-staged UI remain owned by the engine.

local V = ...
local Generation = V.require("Generation")
local OverworldBattle = V.require("OverworldBattle")

local Gen2Battle = {}

-- Gen 2 only; Gen 1 uses OverworldBattle's renderer override.
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

  -- The stage must also reach Game2 when the ordinary overworld rung is OFF.
  -- Keep the choice scoped to World.draw so Options and other games retain
  -- the user's pipeline value, including on renderer failures.
  local okWorld, World = pcall(require, "src.world.gen2.World")
  local okPipelines, Pipelines = pcall(require, "src.render.Pipelines")
  if okWorld and okPipelines then
    V.require("Gen2BattlePipeline").install(World, Pipelines, function()
      if not Gen2Battle.enabled() then return false end
      local shot = OverworldBattle.shot()
      return shot and shot.canvas ~= nil
    end)
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
        -- The native screen may still retain WHITE (fresh profiles or a
        -- setting changed without opening Options). Claim the actual draw
        -- route; merely suppressing its panel would hide the whole arena.
        return "world"
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
        local laidOut=false
        if type(self.drawNativeDoublesBackplates)=='function' then
          local Chrome=require('src.ui.gen2.Chrome')
          laidOut=self:drawNativeDoublesBackplates(function(x,y,w,h)
            Chrome.paletteFill(x*8,y*8,w*8,h*8)
          end)
        end
        if not laidOut then
        local UI=V.require('Gen2BattleUI')
        if not UI.backplate(self,0,0,12,4)then BoxFont.drawBox(0, 0, 12, 4)end
        if not UI.backplate(self,9,6,11,7)then BoxFont.drawBox(9, 6, 11, 7)end
        end
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
