-- Crystal Animated Sprites mod options.
-- Built in a separate module so closures that reference the mod's prefs
-- do not inflate the init function's upvalue count (Lua 5.1 caps 60).
--
-- The three rows live here in the union of the two generations'
-- vocabularies.  Gen 1's OPTION screen draws row.value(g) and steps
-- row.step(g, dir) (src/ui/OptionRows.lua); Gold's OPTION screen answers
-- the same step vocabulary first (src/ui/gen2/OptionsMenu.lua :cycle) and
-- reads row.text(options) for display.  So the same descriptors serve
-- both: the submenu screen below draws them on Gen 1, and Gold's
-- scrolling OPTION list takes them straight (inserted before its CANCEL
-- row by main.lua).  The dedicated screen is Gen 1-only -- it is drawn
-- with Gen 1's OptionRows, which the Gen 2 adapter does not serve.

local okOptionRows, OptionRows = pcall(require, "src.ui.OptionRows")

local CrystalOptions = {}
CrystalOptions.__index = CrystalOptions
CrystalOptions.isOpaque = true

local modCache

local function init(mod)
  modCache = mod
end

-- UI blip; pcall'd so a missing Sound module (e.g. a Gen 2 boot, where
-- the adapter does not serve src.core.Sound) just plays no sound.
local function playPress(game)
  local ok, Sound = pcall(require, "src.core.Sound")
  if ok and Sound and type(Sound.play) == "function" then
    Sound.play(game and game.data, "Press_AB")
  end
end

-- The 3-row options list.  Each step function syncs the save option AND
-- the live pref via the mod's exports.  (Flip-on is automatic: a player
-- portrait named *_flip.png is mirrored, no row needed.)
--
-- `gen2` switches the display shape for Gold's OPTION screen: its label
-- column is narrower than Gen 1's (REPLACE SPRITES reads CUSTOM SPRITES
-- there), its drawPanel prefers `text(options)` over `value(g)`, and its
-- fixed value column takes short, padded strings -- the engine's own rows
-- pad to blank the previous value (options_menu.asm: "MID " over "SLOW").
-- The `step` body is identical on both generations: it writes
-- g.save.options, which on Gold is the same table the OPTION screen
-- edits (Game2 keeps save.options = self.options) and persists through
-- Game2:persistOptions.
local function makeRows(game, gen2)
  local rows = {
    {
      id = "crystalFront",
      label = "FRONT SPRITES",
      value = function(g)
        return (g and g.save and g.save.options
                and g.save.options.crystalFront) and "ON" or "OFF"
      end,
      text = function(options)
        return (options and options.crystalFront) and "ON " or "OFF"
      end,
      step = function(g, _)
        local o = g.save and g.save.options
        if not o then return false end
        o.crystalFront = not o.crystalFront
        if modCache and modCache.exports.applyOption then
          modCache.exports.applyOption("crystalFront", o.crystalFront)
        end
        return true
      end,
    },
    {
      id = "crystalTrainers",
      label = gen2 and "CUSTOM SPRITES" or "REPLACE SPRITES",
      value = function(g)
        local v = g and g.save and g.save.options
          and g.save.options.crystalTrainers
        if v == "player" then return "PLAYER"
        elseif v == "trainers" then return "TRAINER"
        elseif v == "overworld" then return "OVERWORLD"
        elseif v == "all" then return "ALL"
        elseif v == "none" then return "NONE"
        else return "PLAYER + TRAINER" end
      end,
      text = function(options)
        local v = options and options.crystalTrainers
        if v == "player" then return "PLAYER   " end
        if v == "trainers" then return "TRAINER  " end
        if v == "overworld" then return "OVERWORLD" end
        if v == "all" then return "ALL      " end
        if v == "none" then return "NONE     " end
        return "P+TRAINER"
      end,
      step = function(g, dir)
        local o = g.save and g.save.options
        if not o then return false end
        local modes = { "none", "player", "trainers", "both",
                        "overworld", "all" }
        local cur = o.crystalTrainers
        -- a legacy boolean (pre-1.6) or anything unrecognized reads "both"
        if cur ~= "none" and cur ~= "player" and cur ~= "trainers"
            and cur ~= "both" and cur ~= "overworld" and cur ~= "all" then
          cur = "both"
        end
        local i = 1
        for k, m in ipairs(modes) do
          if m == cur then i = k break end
        end
        i = ((i - 1 + (dir or 1)) % #modes) + 1
        o.crystalTrainers = modes[i]
        if modCache and modCache.exports.applyOption then
          modCache.exports.applyOption("crystalTrainers", o.crystalTrainers)
        end
        return true
      end,
    },
    {
      id = "crystalPlayerSprite",
      label = "PLAYER SPRITE",
      value = function(g)
        local v = g and g.save and g.save.options
          and g.save.options.crystalPlayerSprite
        -- strip the .png and the _flip auto-mirror suffix for display:
        -- red_flip.png shows as RED, same as red.png
        local name = (v and v ~= "" and v or "red.png")
          :gsub("%.png$", ""):gsub("_flip$", "")
        return name:upper()
      end,
      text = function(options)
        local v = options and options.crystalPlayerSprite
        local name = (v and v ~= "" and v or "red.png")
          :gsub("%.png$", ""):gsub("_flip$", "")
        local up = name:upper()
        if #up >= 8 then return up end
        return up .. string.rep(" ", 8 - #up)
      end,
      step = function(g, dir)
        local o = g.save and g.save.options
        if not o then return false end
        local list = modCache and modCache.exports.listPlayerSprites
          and modCache.exports.listPlayerSprites() or { "red.png" }
        local cur = o.crystalPlayerSprite or "red.png"
        local i = 1
        for k, m in ipairs(list) do
          if m == cur then i = k break end
        end
        i = ((i - 1 + (dir or 1)) % #list) + 1
        o.crystalPlayerSprite = list[i]
        if modCache and modCache.exports.applyOption then
          modCache.exports.applyOption("crystalPlayerSprite", o.crystalPlayerSprite)
        end
        return true
      end,
    },
    {
      id = "crystalBattlePic",
      label = "BATTLE PIC",
      value = function(g)
        local v = g and g.save and g.save.options
          and g.save.options.crystalBattlePic
        return (v == "back") and "BACK" or "FRONT"
      end,
      text = function(options)
        local v = options and options.crystalBattlePic
        return (v == "back") and "BACK " or "FRONT"
      end,
      step = function(g, _)
        local o = g.save and g.save.options
        if not o then return false end
        o.crystalBattlePic = (o.crystalBattlePic == "back")
          and "front" or "back"
        if modCache and modCache.exports.applyOption then
          modCache.exports.applyOption("crystalBattlePic", o.crystalBattlePic)
        end
        return true
      end,
    },
    {
      id = "crystalAnimations",
      label = "ANIMATIONS",
      value = function(g)
        local v = g and g.save and g.save.options
          and g.save.options.crystalAnimations
        return (v == "once") and "PLAY ONCE" or "LOOP"
      end,
      text = function(options)
        local v = options and options.crystalAnimations
        return (v == "once") and "PLAY ONCE" or "LOOP     "
      end,
      step = function(g, _)
        local o = g.save and g.save.options
        if not o then return false end
        o.crystalAnimations = (o.crystalAnimations == "once")
          and "loop" or "once"
        if modCache and modCache.exports.applyOption then
          modCache.exports.applyOption("crystalAnimations", o.crystalAnimations)
        end
        return true
      end,
    },
  }
  return rows
end

function CrystalOptions:update(dt)
  local inp = self.game.input
  local cancel = #self.rows + 1
  local changed = false
  if inp:wasPressed("up") then
    self.index = self.index > 1 and self.index - 1 or cancel
  elseif inp:wasPressed("down") then
    self.index = self.index < cancel and self.index + 1 or 1
  elseif inp:wasPressed("left") or inp:wasPressed("right")
      or inp:wasPressed("a") then
    local dir = inp:wasPressed("left") and -1 or 1
    local row = self.rows[self.index]
    if row and row.step then
      changed = row.step(self.game, dir) and true or false
    elseif inp:wasPressed("a") then -- CANCEL
      playPress(self.game)
      self.game.stack:pop()
    end
  elseif inp:wasPressed("b") or inp:wasPressed("start") then
    playPress(self.game)
    self.game.stack:pop()
  end
  if changed and self.game.writeOptions then
    self.game:writeOptions()
  end
  self.scroll = OptionRows.clampScroll(self.index, self.scroll or 0,
                                       #self.rows, cancel)
end

function CrystalOptions:draw()
  OptionRows.draw(self.game, self.rows, self.index, self.scroll or 0,
                  "CANCEL", #self.rows + 1)
end

function CrystalOptions.open(game)
  local self = setmetatable({
    game = game,
    rows = makeRows(game, false),
    index = 1,
    scroll = 0,
  }, CrystalOptions)
  self.screenId = "CrystalSpriteOptions"
  game.stack:push(self)
  return self
end

return {
  init = init,
  open = CrystalOptions.open,
  makeRows = makeRows,
}
