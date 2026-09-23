local V = ...
local mod = V.crystalContext
local BattleState = require("src.battle.BattleState")

-- Generation gate.  On a Gen 2 boot the require shim answers
-- src.battle.BattleState with the Gen2Compat facade over Gold's battle
-- screen (src/ui/gen2/BattleState.lua).  The facade is write-through:
-- unknown reads fall to Gold's class, and only its deliberately absent
-- members (newWild, newTrainer, ...) warn when touched -- reading them
-- here would log a "has no Gen 2 backing" warning every boot.  Gold's
-- screen class has a `new` constructor; the Gen 1 battle state builds its
-- battles through newWild/newTrainer and has no `new`, so its presence
-- is the mod's generation flag and reads warning-free on both sides.
local isGen2 = BattleState.new ~= nil

-- A require that only happens on a Gen 1 boot.  The Gen 2 adapter serves
-- just the fifteen Gen 1 names in its coverage table; every other Gen 1
-- module is absent or a copy Gold never instantiates, so on Gen 2 the
-- mod does not touch them at all and the features they power are gated
-- out below.
-- Returns the module, or nil when it can't be loaded (Gen 2 boot, or a
-- missing Gen 1 module).  A single-value return keeps every consumer a
-- nil check, which also keeps the install closure under LuaJIT's 60-upvalue
-- ceiling (the old (ok, module) pairs cost one extra upvalue each).
function gen1Require(name)
  if isGen2 then return nil end
  local ok, res = pcall(require, name)
  return ok and res or nil
end

local Sound = gen1Require("src.core.Sound")
local Stats = gen1Require("src.pokemon.Stats")
-- The dex entry page and the status screen both load the mon's front pic
-- once into self.sprite in their constructor and redraw it every frame, so
-- the mod can swap in PNG frames as the animation advances.  pcall'd: a
-- missing module just skips the wiring.
local DexEntryMenu = gen1Require("src.ui.DexEntryMenu")
local SummaryMenu = gen1Require("src.ui.SummaryMenu")
local TitleState = gen1Require("src.ui.TitleState")
local IntroMovie = gen1Require("src.ui.IntroMovie")
local OakSpeech = gen1Require("src.ui.OakSpeech")
local EvolutionState = gen1Require("src.ui.EvolutionState")
local speciesMap = V.require("Crystal/species_map")
local animationData = V.require("Crystal/animation_data")
-- The recolor pipeline (PaletteFX) is Gen 1 renderer internals.  Without
-- it the mod loads raw art and lets the engine's own palette passes
-- handle it, which is what the grayscale set is authored for.
local PaletteFX = gen1Require("src.render.PaletteFX")

local BASE = mod.path .. "/assets/crystal"
local SPRITE_BASE = BASE
local SHINY_BASE = BASE .. "/shiny_visuals"

local originalUpdate = BattleState.update
local originalPlayCry = Sound and Sound.playCry

local imageCache = {}
local sparkleImage = nil
local sparkleQuads = nil

-- OPTIONS > FRONT SPRITES: when on, the player's own Pokémon shows its
-- animated Crystal front sprite in battle instead of the static back art.
-- The pokemon.sprite hook has no game reference, so the mod keeps its own
-- copy, synced from the save on every ready/created/loaded event and by
-- the option row itself.
local frontPref = false

-- OPTIONS > CRYSTAL SPRITES > REPLACE SPRITES: which art the custom folders
-- replace.  "both" loads the player portrait from assets/trainers/player/
-- AND the opponent portraits from assets/trainers/opponents/; "player"
-- only the player portrait; "trainers" only the opponents; "overworld"
-- only the overworld NPC sheets in assets/overworld/trainers/; "all"
-- replaces everything.  Whatever is not custom keeps the shipped art, and
-- a missing custom file always falls back to it.  Defaults to "both";
-- synced from the save like frontPref.  Stored as a STRING so an older
-- engine's options round-trip never has to survive a mod-added boolean.
local trainerMode = "both"

-- OPTIONS > PLAYER SPRITE: which file in assets/trainers/player/ is the
-- player portrait.  Synced from the save like the other options; the row
-- cycles listPlayerSprites().  A new game defaults to the game's own
-- hero -- Red on Gen 1, Gold's trainer (gold_flip.png) on Gen 2 -- so a
-- Gold save no longer starts on the wrong character.
local DEFAULT_PLAYER_SPRITE = isGen2 and "gold_flip.png" or "red.png"
local playerSprite = DEFAULT_PLAYER_SPRITE

-- OPTIONS > BATTLE PIC: which view of the chosen player sprite fills the
-- battle back slot.  "front" uses the portrait from assets/trainers/player/
-- (mirrored per the *_flip suffix); "back" uses a dedicated back sprite
-- from assets/trainers/back/{name}.png, keyed by the portrait stem
-- (gold_flip.png -> gold.png).  A missing back file falls back to the
-- front portrait.  Synced from the save like the other options.
local battlePicPref = "front"

-- OPTIONS > ANIMATIONS: LOOP cycles the Crystal sprites continuously;
-- PLAY ONCE runs each animation through its frames a single time and
-- holds the final frame.  Stored as a STRING ("loop"/"once") so an older
-- engine's options round-trip never has to survive a mod-added boolean.
-- Defaults to "loop"; synced from the save like the other options.
local animMode = "loop"

-- Player portraits named *_flip.png are mirrored automatically for the
-- battle back pic (the old FLIP SPRITE toggle is gone): the suffix
-- marks art that faces the wrong way for the back slot.

function customPlayer()
  return trainerMode == "player" or trainerMode == "both"
      or trainerMode == "all"
end

function customOpponents()
  return trainerMode == "trainers" or trainerMode == "both"
      or trainerMode == "all"
end

function customOverworld()
  return trainerMode == "overworld" or trainerMode == "all"
end

-- Any battle trainer portrait replacement at all (the mod's shipped
-- fallback art included).  "none" and "overworld" both leave the battle
-- portraits alone.
function customTrainerPortraits()
  return trainerMode == "player" or trainerMode == "trainers"
      or trainerMode == "both" or trainerMode == "all"
end

local reveal = {
  battle = nil,
  source = nil,
  frame = 0,
  crySpecies = nil,
  cryMon = nil,
  cryPlayed = false,
}

-- dt arrives from the engine's fixed logic step.  Fast-forward runs more
-- steps per real frame (Game:update feeds FixedStep dt * speed), so a raw
-- step dt would make these animations play N times faster at N times game
-- speed -- and the shiny reveal would race ahead of its real-time audio.
-- Divide by the current speed multiplier so battle animations always play
-- at 1X real time, matching how the engine already runs audio.
function logicToReal(dt, game)
  local speed = 1
  if game and type(game.logicSpeed) == "function" then
    speed = game.logicSpeed(game) or 1
  end
  speed = tonumber(speed) or 1
  if speed <= 0 then speed = 1 end
  return (tonumber(dt) or (1 / 60)) / speed
end

-- Gen 2 shininess is a DV pattern, so the check needs no Gen 1 Stats
-- module: Defense/Speed/Special all 10 and the Attack DV with bit 1 set
-- (2,3,6,7,10,11,14,15).  Gold's mon struct may not carry the same dvs
-- shape, so the fields are read defensively; an unrecognized shape reads
-- as not shiny rather than erroring.
function dvShiny(dvs)
  if type(dvs) ~= "table" then return false end
  local atk = dvs.atk or dvs.attack or dvs[1]
  local def = dvs.def or dvs.defense or dvs[2]
  local spd = dvs.spd or dvs.speed or dvs[3]
  local spc = dvs.spc or dvs.special or dvs[4]
  if type(atk) ~= "number" or type(def) ~= "number"
      or type(spd) ~= "number" or type(spc) ~= "number" then
    return false
  end
  return def == 10 and spd == 10 and spc == 10 and atk % 4 >= 2
end

function isShiny(mon)
  if not mon then return false end
  -- Gold's mon struct carries the resolved shiny flag; trust it when
  -- present (Gen 1 mons have no such field and fall through to DVs).
  if mon.shiny == true then return true end
  if not mon.dvs then return false end
  if Stats and type(Stats.isShiny) == "function" then
    return Stats.isShiny(mon.dvs) or false
  end
  return dvShiny(mon.dvs)
end

function variant(mon)
  return isShiny(mon) and "shiny" or "normal"
end

function dexFor(species)
  if species == nil then return nil end
  -- speciesMap is keyed by NAME strings (e.g. "FARFETCHD"), but Gen 2
  -- sometimes passes numeric species (e.g. 83) or variant spellings
  -- (e.g. "MR__MIME" with double underscores, "FARFETCH_D" with a stray
  -- underscore).  Try the direct lookup first, then fall back to numeric
  -- and fuzzy matches that ignore underscores and case.
  local byName = speciesMap[species]
  if byName then return byName end
  -- numeric species: scan the map for a matching dex number
  if type(species) == "number" then
    for name, dex in pairs(speciesMap) do
      if dex == species then return dex end
    end
  end
  -- fuzzy match: strip all underscores and compare case-insensitively
  if type(species) == "string" then
    local norm = species:upper():gsub("_", "")
    for name, dex in pairs(speciesMap) do
      if name:upper():gsub("_", "") == norm then return dex end
    end
  end
  return nil
end

function colorMode()
  return PaletteFX and PaletteFX.mode == "redpp"
end

function battleMono()
  local m = PaletteFX and PaletteFX.mode
  return m == "og" or m == "og_inv" or m == "classic"
end

local DMG_RAMP = {
  { 255, 255, 255 }, { 170, 170, 170 }, { 85, 85, 85 }, { 0, 0, 0 },
}
local DMG_GREEN = {
  { 155, 188, 15 }, { 139, 172, 15 }, { 48, 98, 48 }, { 15, 56, 15 },
}
function monoDisplayColors()
  local m = PaletteFX and PaletteFX.mode
  local g
  if m == "classic" then
    g = (PaletteFX and PaletteFX.CLASSIC) or DMG_GREEN
  elseif m == "og_inv" then
    local ramp = (PaletteFX and PaletteFX.GRAYS) or DMG_RAMP
    g = { ramp[4], ramp[3], ramp[2], ramp[1] }
  else
    g = (PaletteFX and PaletteFX.GRAYS) or DMG_RAMP
  end
  return { g[1], g[2], g[3], g[4] }
end

-- Gold's COLOR option (GBC / DMG / CLASSIC).  The mod's Gen 2 art is the
-- full-color set and is drawn raw (the GBC palette pass buckets a
-- full-color pic by its red channel), so a non-GBC mode needs that art
-- luminance-baked onto the 4-shade DMG ramp first: DMG shows the ramp
-- directly and CLASSIC's whole-frame present pass maps it to green, the
-- same path the vanilla 2bpp art rides.  GBC keeps the raw full-color art.
-- GbcPalette is a Gen 2 module, so it is required lazily and only on Gold.
local GbcPalette2 = nil
function gen2Mono()
  if not isGen2 then return false end
  if GbcPalette2 == nil then
    local ok, m = pcall(require, "src.render.GbcPalette")
    GbcPalette2 = (ok and m) or false
  end
  if not GbcPalette2 then return false end
  return GbcPalette2.mode ~= "gbc"
end

-- The palette the mod bakes a full-color sprite onto so it matches what
-- the SGB zone pass would show in the current COLORS mode, mirroring
-- PaletteFX.effectiveColors exactly: the zone palette as-is (SGB, OG RED/
-- BLUE/YELLOW via pal()'s short-circuits), plain DMG grays (OG), inverted
-- grays (OG INV), pea greens (CLASSIC) or the inverted zone (SGB INV).
-- nil under ADVANCED, where sprites stay raw true color.
function modePalette(data, baseName, mode)
  mode = mode or (PaletteFX and PaletteFX.mode) or "gbc"
  if mode == "redpp" then return nil end
  local okP, base = pcall(PaletteFX.pal, data, baseName or "MEWMON")
  if not (okP and base) then return nil end
  if mode == "og" then
    return (PaletteFX and PaletteFX.GRAYS) or DMG_RAMP
  elseif mode == "og_inv" then
    local ramp = (PaletteFX and PaletteFX.GRAYS) or DMG_RAMP
    return { ramp[4], ramp[3], ramp[2], ramp[1] }
  elseif mode == "classic" then
    return (PaletteFX and PaletteFX.CLASSIC) or DMG_GREEN
  elseif mode == "gbc_inv" then
    return { base[4], base[3], base[2], base[1] }
  end
  return base
end

local VOXEL_MOD_IDS = { "DRAMATIC_SHAPE", "BATTLE_ART_VOXEL_FORK", "potato_voxel", "DRAMALESS_SHAPE" }

function voxelMod()
  local ok, Game = pcall(require, "src.core.Game")
  if not (ok and Game and Game.mods and Game.mods.exports) then
    return nil
  end
  for i = 1, #VOXEL_MOD_IDS do
    local voxel = Game.mods.exports[VOXEL_MOD_IDS[i]]
    if voxel then return voxel end
  end
  return nil
end

-- The Gen 3 UI overhaul (gen3_battle_ui) draws its own HD party-ball
-- counters for both sides and does NOT suppress the vanilla ball row, so
-- when it is loaded our baked row would stack right on top of its pods.
-- True when that mod is live; the ball-row hook then yields to it.
function gen3BattleUI()
  local ok, Game = pcall(require, "src.core.Game")
  if not (ok and Game and Game.mods and Game.mods.exports) then
    return false
  end
  return Game.mods.exports["gen3_battle_ui"] and true or false
end

function voxelContext(battle)
  if not battle then return false end
  if battle.__crystalVoxel then return true end
  local voxel = voxelMod()
  -- A malformed export (a bare value rather than the { lib = ... } table)
  -- must read as "not a voxel battle": the original wrapped this in a
  -- pcall, so keep that behaviour with a type gate instead.
  local lib = type(voxel) == "table" and voxel.lib
  if not (lib and lib.require) then return false end
  local okOB, OverworldBattle = pcall(lib.require, "OverworldBattle")
  if not (okOB and OverworldBattle and OverworldBattle.battle) then
    return false
  end
  -- Argument-form pcalls (no per-call closure): the forced-mono path
  -- re-checks this every frame, so it must not allocate a closure.
  local okB, cur = pcall(OverworldBattle.battle, OverworldBattle)
  if okB and cur == battle then
    battle.__crystalVoxel = true
    return true
  end
  return false
end

local crystalImages = setmetatable({}, { __mode = "k" })
local voxelPaper = false

function markCrystal(img)
  if img then crystalImages[img] = true end
end

local CRYSTAL_PATH = (mod.path .. "/assets/crystal"):gsub("\\", "/")
local CRYSTAL_FOLDER = (mod.path:gsub("\\", "/")):match("[^/]+$") or ""

function isCrystalImage(img)
  if not img then return false end
  if crystalImages[img] then return true end
  local getFn = img.getFilename
  if not getFn then return false end
  local ok, name = pcall(getFn, img)
  if ok and type(name) == "string" and name ~= "" then
    local p = name:gsub("\\", "/")
    if p:sub(1, #CRYSTAL_PATH) == CRYSTAL_PATH then return true end
    if p:find(CRYSTAL_FOLDER, 1, true)
       and p:find("/assets/crystal/", 1, true) then
      return true
    end
    if p:find(CRYSTAL_FOLDER, 1, true)
       and p:find("/assets/crystal/trainers/", 1, true) then
      return true
    end
  end
  return false
end

function markCrystalBattlers(battle)
  if not battle then return end
  local enemy = battle.enemy
  if enemy and enemy.mon and dexFor(enemy.mon.species) then
    markCrystal(enemy.sprite)
  end
  local player = battle.player
  if player and player.mon and dexFor(player.mon.species) then
    markCrystal(player.sprite)
  end
  -- Trainer sprites too: the opponent's portrait and the player's back
  -- pic are full-color mod art, and the staged-battle paper seal
  -- (BattlePics.filled) re-runs over them every frame.  Mark them like
  -- the mon sprites so their transparency survives instead of being
  -- sealed onto the paper.
  if battle.trainerPic then markCrystal(battle.trainerPic) end
  if battle.playerBackPic then markCrystal(battle.playerBackPic) end
end

function frontPath(dex, which, frame)
  return ("%s/front/%s/%d/%03d.png"):format(
    SPRITE_BASE, which, dex, frame or 1)
end

function backPath(dex, which)
  return ("%s/back/%s/%d.png"):format(
    SPRITE_BASE, which, dex)
end

-- The art folder the mod draws in the current COLORS mode: the full-color
-- variant under ADVANCED, the shipped grayscale set in every other mode.
-- The grayscale art is authored as DMG-style 4-shade art, so the engine's
-- own recolor passes (SGB zones, forced mono) handle it exactly like
-- vanilla art -- where pre-baking a palette onto full-color art flattens
-- the shading.
function artVariantForMode(which)
  return colorMode() and which or "grayscale"
end

function ghostFrontPath()
  -- The tower ghost ships only as full-color art (no grayscale twin), so
  -- point at the normal folder in every mode.  loadImage luminance-bakes
  -- it onto the mode's palette outside ADVANCED, exactly like the regular
  -- front frames -- the old grayscale path named a file that never exists,
  -- so the ghost was never baked (and never showed the mod's art).
  return ("%s/front/normal/ghost.png"):format(SPRITE_BASE)
end

function isGhostBattle(battle)
  return battle and battle.ghost == true
end

-- Outside ADVANCED the shiny variant collapses to the normal one: the
-- grayscale set carries no shiny copy (a grayscaled shiny looks identical
-- to its normal form anyway), so a shiny mon must never pull the
-- full-color shiny art into a non-REDPP mode -- the grayscale art when it
-- exists, the normal full-color art as the last-resort fallback.
function artWhich(which)
  if colorMode() then return which end
  return "normal"
end

function backGrayPath(dex)
  return ("%s/back/grayscale/%d.png"):format(SPRITE_BASE, dex)
end

-- The palette that applies to a pic right now: nil in REDPP (true color
-- loaded as-is), a gray ramp under the mono modes (with the staged-battle
-- ramp where the voxel mod owns the shot), or the species' own palette from
-- PaletteFX otherwise.  Shared by the PNG loader and the frame baker so
-- both remap identically.
function paletteFor(data, species, battle)
  if colorMode() then return nil end
  if battleMono() then
    local modeColors = monoDisplayColors()
    local g = (modeColors and modeColors[1]) and modeColors
           or (PaletteFX and PaletteFX.GRAYS) or DMG_RAMP
    return {
      name = "mono@" .. tostring(PaletteFX and PaletteFX.mode),
      colors = g,
    }
  end
  local ok, colors = pcall(PaletteFX.monPal, data, species)
  if ok and colors then
    return {
      name = tostring(species) .. "@" .. tostring(PaletteFX.mode),
      colors = colors,
    }
  end
  return nil
end

function loadImage(path, data, species, battle)
  local pal = paletteFor(data, species, battle)
  local key = pal and (path .. "#" .. pal.name) or path
  if imageCache[key] then return imageCache[key] end
  local ok, image = pcall(function()
    if not pal then return love.graphics.newImage(path) end
    local id = love.image.newImageData(path)
    local c = pal.colors
    id:mapPixel(function(_, _, r, g, b, a)
      if a == 0 then return r, g, b, a end
      local yy = 0.299 * r + 0.587 * g + 0.114 * b
      local col = yy > 0.83 and c[1] or yy > 0.5 and c[2]
        or yy > 0.17 and c[3] or c[4]
      return col[1] / 255, col[2] / 255, col[3] / 255, a
    end)
    return love.graphics.newImage(id)
  end)
  if not ok or not image then
    if pal then return nil end
    local okRaw, raw = pcall(love.graphics.newImage, path)
    if not (okRaw and raw) then return nil end
    image = raw
  end
  image:setFilter("nearest", "nearest")
  imageCache[key] = image
  markCrystal(image)
  return image
end

-- Load a pic with no palette pass at all -- the grayscale art already
-- carries the DMG-style shades the engine's recolor passes expect.
function loadImageRaw(path)
  local key = path .. "#raw"
  if imageCache[key] then return imageCache[key] end
  local ok, image = pcall(love.graphics.newImage, path)
  if not (ok and image) then return nil end
  image:setFilter("nearest", "nearest")
  imageCache[key] = image
  markCrystal(image)
  return image
end

-- Luminance-bake a PNG file onto a 4-color palette (0-255 RGB triples):
-- each opaque pixel is remapped to the palette entry its luminance falls
-- in, so full-color art carries the DMG-style 4-shade structure the
-- engine's recolor passes expect.  The result is marked crystal.  Shared
-- by the trainer-portrait loader (modTrainerPic) and the player back-pic
-- bake (lumaTrainerBackPic).
function lumaBakeImage(path, colors)
  local okId, id = pcall(love.image.newImageData, path)
  if not (okId and id) then return nil end
  local okMap = pcall(function()
    id:mapPixel(function(_, _, r, g, b, a)
      if a == 0 then return r, g, b, a end
      local yy = 0.299 * r + 0.587 * g + 0.114 * b
      local col = yy > 0.83 and colors[1] or yy > 0.5 and colors[2]
        or yy > 0.17 and colors[3] or colors[4]
      return col[1] / 255, col[2] / 255, col[3] / 255, a
    end)
  end)
  if not okMap then return nil end
  local okNew, baked = pcall(love.graphics.newImage, id)
  if not (okNew and baked) then return nil end
  baked:setFilter("nearest", "nearest")
  markCrystal(baked)
  return baked
end

-- Read an Image's pixels back through a canvas: always a private copy,
-- used when Image:getData is unavailable or would hand back shared data.
function readPixels(img)
  local ok, data = pcall(function()
    local w, h = img:getDimensions()
    if not (w and h and w > 0 and h > 0) then return nil end
    local g = love.graphics
    local prevCanvas = g.getCanvas()
    local prevBlend, prevAlpha = g.getBlendMode()
    local prevR, prevG, prevB, prevA = g.getColor()
    local out = nil
    local okCanvas = pcall(function()
      local canvas = g.newCanvas(w, h, { dpiscale = 1 })
      g.setCanvas(canvas)
      g.clear(0, 0, 0, 0)
      g.setBlendMode("replace", "premultiplied")
      g.setColor(1, 1, 1, 1)
      -- The readback can run mid-draw (the Gen 2 battle flips the player's
      -- back pic inside drawPic), while the widescreen translate/scale is
      -- still on the transform stack.  Drawing through that transform
      -- pushes the pic out of this 1:1 canvas and reads back nothing, which
      -- is what made the player's mon invisible.  Reset to the origin for
      -- the blit so the copy always sees the pic at 1:1.
      g.push()
      g.origin()
      g.draw(img, 0, 0)
      g.pop()
      g.setCanvas()
      out = canvas:newImageData()
      if canvas.release then pcall(canvas.release, canvas) end
    end)
    if prevCanvas then g.setCanvas(prevCanvas) else g.setCanvas() end
    g.setBlendMode(prevBlend or "alpha", prevAlpha)
    g.setColor(prevR or 1, prevG or 1, prevB or 1, prevA or 1)
    if not okCanvas then return nil end
    return out
  end)
  return ok and data or nil
end

-- PNG pixel width from the file's first 24 bytes (signature + IHDR
-- length/type + width).  Pure byte math -- no love -- so the back-pic
-- scaling below can size a portrait from its header without decoding it.
function pngWidth(bytes)
  if type(bytes) ~= "string" or #bytes < 24 then return nil end
  if bytes:sub(1, 8) ~= "\137PNG\r\n\26\n" then return nil end
  if bytes:sub(13, 16) ~= "IHDR" then return nil end
  return bytes:byte(17) * 16777216 + bytes:byte(18) * 65536
       + bytes:byte(19) * 256 + bytes:byte(20)
end

-- A private copy of an Image's pixels for pixel work.  Image:getData may
-- hand back the ImageData the image was built from, so clone it before
-- any mapPixel (ImageData:clone exists across every LÖVE 11 the engine
-- ships) to keep the source sprite untouched.  When the clone is
-- unavailable, fall back to a canvas readback (always a private copy)
-- rather than mapping the shared data in place, which would corrupt the
-- cached raw frames the title/dex screens share.
function imageDataCopy(img)
  local okData, data = pcall(img.getData, img)
  if okData and data then
    local okClone, clone = pcall(data.clone, data)
    if okClone and clone then return clone end
  end
  return readPixels(img)
end

-- Luminance-bake an already-loaded full-color image onto the 4-shade DMG
-- ramp for Gold's DMG/CLASSIC modes.  Cached per source image (weak key --
-- the menu and battle caches hold the full-color frames strongly), so the
-- per-frame path is a table lookup after the first bake.  Alpha survives
-- as-is, so the transparent background stays cut out.
local gen2GrayCache = setmetatable({}, { __mode = "k" })
function gen2GrayImage(img)
  if not img then return nil end
  local hit = gen2GrayCache[img]
  if hit ~= nil then return hit or nil end
  local data = imageDataCopy(img)
  if not data then gen2GrayCache[img] = false return nil end
  local okMap = pcall(function()
    data:mapPixel(function(_, _, r, g, b, a)
      if a == 0 then return r, g, b, a end
      local yy = 0.299 * r + 0.587 * g + 0.114 * b
      local v = yy > 0.83 and 255 or yy > 0.5 and 170
        or yy > 0.17 and 85 or 0
      return v / 255, v / 255, v / 255, a
    end)
  end)
  if not okMap then gen2GrayCache[img] = false return nil end
  local okNew, baked = pcall(love.graphics.newImage, data)
  if not (okNew and baked) then gen2GrayCache[img] = false return nil end
  baked:setFilter("nearest", "nearest")
  markCrystal(baked)
  gen2GrayCache[img] = baked
  return baked
end

-- The engine pins battle pics by their ground padding: every pic it
-- loads is measured for transparent bottom rows (and left columns) and
-- the draw offsets by that so feet land on the slot (backPlacement pins
-- feet at y=96; frontPlacement anchors the pic to the 7x7 slot origin).
-- The mod's own frames skip that measurement -- imagePadBottom/Left have
-- no entry -- so a frame whose art floats above the canvas bottom is
-- drawn noticeably high.  Trim the padding out of a COPY of the frame
-- (fronts: bottom rows only, keeping the authored horizontal placement;
-- backs: bottom rows and left columns, so backPlacement's padL=0 puts
-- the first opaque column where vanilla's padL compensation did).
local trimCache = setmetatable({}, { __mode = "k" })
local function trimGround(img, side, battle)
  if not img then return nil end
  -- Only trim transparent padding for 3D voxel battles, where sprites
  -- float above the platform and need grounding.  In 2D battles the
  -- sprites are positioned by the engine's own layout and trimming
  -- shifts them upward, covering name labels.
  if not battle or not voxelContext(battle) then return img end
  local key = side == "back" and "back" or "front"
  local hit = trimCache[img]
  if hit then
    local got = hit[key]
    if got then return got end
  end
  if not hit then hit = {}; trimCache[img] = hit end
  local data = imageDataCopy(img)
  if not data then
    hit[key] = img
    return img
  end
  local w, h = data:getDimensions()
  local bottom = h - 1
  while bottom >= 0 do
    local opaque = false
    for x = 0, w - 1 do
      local _, _, _, a = data:getPixel(x, bottom)
      if a > 0 then opaque = true break end
    end
    if opaque then break end
    bottom = bottom - 1
  end
  if bottom < 0 then
    hit[key] = img
    return img
  end
  local padL = 0
  if side == "back" then
    while padL < w do
      local opaque = false
      for y = 0, bottom do
        local _, _, _, a = data:getPixel(padL, y)
        if a > 0 then opaque = true break end
      end
      if opaque then break end
      padL = padL + 1
    end
  end
  if bottom == h - 1 and padL == 0 then
    hit[key] = img
    return img
  end
  local nw, nh = w - padL, bottom + 1
  local okC, cropped = pcall(love.image.newImageData, nw, nh)
  if not (okC and cropped) then
    hit[key] = img
    return img
  end
  local okPix = pcall(function()
    for y = 0, bottom do
      for x = padL, w - 1 do
        local r, g, b, a = data:getPixel(x, y)
        cropped:setPixel(x - padL, y, r, g, b, a)
      end
    end
  end)
  if not okPix then
    hit[key] = img
    return img
  end
  local okNew, trimmed = pcall(love.graphics.newImage, cropped)
  if not (okNew and trimmed) then
    hit[key] = img
    return img
  end
  trimmed:setFilter("nearest", "nearest")
  markCrystal(trimmed)
  hit[key] = trimmed
  return trimmed
end

local function trimFrames(images, side, battle)
  local out = {}
  for i = 1, #images do
    out[i] = trimGround(images[i], side, battle)
  end
  return out
end

-- Red's title OAM art is raw DMG grayscale (white / light gray / dark
-- gray / black).  Under REDPP the strip is marked true color so the SGB
-- zone pass cannot smear MEWMON purple over the vivid mon -- but that
-- also leaves Red raw gray.  Bake his four shades to his iconic outfit
-- (white / skin / red / navy) with a luminance map, so the 4 exact DMG
-- grays land bijectively and any other tones bucket sensibly.
local RED_TRAINER_PAL = {
  { 255, 255, 255 }, { 236, 168, 120 }, { 216, 64, 48 }, { 56, 64, 120 },
}

-- Replace the title's trainer image with a luminance-baked recolor.  The
-- strip's true-color re-blit then shows Red in his own colors instead of
-- raw gray; every non-REDPP mode leaves the image alone and keeps the
-- zone pass's authentic palette colors.
local function bakeTitleTrainer(title)
  -- always bake from the untouched raw art, so a re-bake after a mode
  -- switch (raw restored, flag cleared) starts from the same source
  local raw = title.__crystalPlayerRaw or title.player
  if not raw then return false end
  title.__crystalPlayerRaw = raw
  if title.__crystalTrainerBaked then return true end
  local data = imageDataCopy(raw)
  if not data then return false end
  local okMap = pcall(function()
    data:mapPixel(function(_, _, r, g, b, a)
      if a == 0 then return r, g, b, a end
      local yy = 0.299 * r + 0.587 * g + 0.114 * b
      local col = yy > 0.83 and RED_TRAINER_PAL[1]
        or yy > 0.5 and RED_TRAINER_PAL[2]
        or yy > 0.17 and RED_TRAINER_PAL[3] or RED_TRAINER_PAL[4]
      return col[1] / 255, col[2] / 255, col[3] / 255, a
    end)
  end)
  if not okMap then return false end
  local okNew, baked = pcall(love.graphics.newImage, data)
  if not (okNew and baked) then return false end
  baked:setFilter("nearest", "nearest")
  title.player = baked
  title.__crystalTrainerBaked = true
  return true
end

-- love.filesystem is sandboxed away from mods by the launcher; every
-- probe/read of the mod's own assets goes through mod:read instead, which
-- is scoped to this mod's directory.  modReadBytes returns the file's
-- bytes on success, false when the file is absent, or nil when the answer
-- cannot be determined (a path outside the mod, or a filesystem with no
-- read at all) -- the tri-state the headless best-effort paths key off.
local MOD_ASSET_PREFIX = mod.path .. "/"
local function modReadBytes(path)
  if type(path) ~= "string"
      or path:sub(1, #MOD_ASSET_PREFIX) ~= MOD_ASSET_PREFIX then
    return nil
  end
  local ok, contents = pcall(mod.read, mod, path:sub(#MOD_ASSET_PREFIX + 1))
  if not ok then return nil end
  if contents == nil then return false end
  return contents
end

local function fileExists(path)
  local result = modReadBytes(path)
  if result == false then return false end
  if result == nil then return nil end
  return true
end

-- Optimistic file probe: when existence cannot be determined (no readable
-- filesystem) assume the path exists so the hooks still route to the mod's
-- art; in-game a missing file lets callers fall back to the engine's own
-- art for that slot.
local function artExists(path)
  local exists = fileExists(path)
  if exists == nil then return true end
  return exists
end

-- Whether the mod ships any art for a dex in its own asset folders (front
-- and/or back).  Johto mons whose Crystal art hasn't landed here yet are
-- "absent", so the sprite hook passes them through to the engine's own
-- art (a Kanto mod's registration) untouched.  Not memoized: the files
-- could land mid-session via hot reload, and the checks are cheap.
local function hasCrystalArt(dex)
  return artExists(frontPath(dex, "normal", 1))
    or artExists(backPath(dex, "normal"))
end

-- The path handed to the engine.  Follows the COLORS mode: the full-color
-- art under ADVANCED, the grayscale set otherwise (the engine's own palette
-- passes recolor the DMG-style art).  When the mode's variant is missing the
-- normal full-color art is the last resort, preferring files that actually
-- exist.  The front art is always the PNG frame set, with frame 1 served
-- as the static path.
local function frontHookPath(dex, which)
  local w = artVariantForMode(which)
  local png = frontPath(dex, w, 1)
  if fileExists(png) then return png end
  local np = frontPath(dex, "normal", 1)
  if artExists(np) then return np end
  -- no art for this dex at all: callers fall back to the engine's own path
  return nil
end

-- Gen 2 battle animation: Gold's battle screen re-resolves its pics
-- through the pokemon.sprite hook every frame and caches by path, so the
-- hook serves a rotating PNG frame instead of the static frame 1.  The
-- frame count is probed once per species/variant and cached; the clock is
-- wall time so both slots (and both screens, if ever shown) cycle in
-- sync and the animation does not depend on the frame-draw order.
local frontFrameCache = {}
-- PLAY ONCE start times: the wall-clock frame clock is shared across the
-- battle screen and the menu screens, so a per-key start time records
-- when the animation was first seen; after one full pass it clamps to the
-- final frame.  Bounded by the species map (dex + variant), so it never
-- needs pruning the way the GPU-image caches do.
local animStart = {}
-- Which folder actually holds frames (the grayscale variant folders are
-- empty on some installs, so the full-color set stands in) plus the frame
-- count, probed once per species/variant and cached -- the hook runs every
-- battle frame, so this must be a table lookup after the first call, not a
-- per-frame filesystem probe.
local function frontFrameInfo(dex, which)
  local key = tostring(dex) .. "|" .. tostring(which)
  local info = frontFrameCache[key]
  if info then return info.resolved, info.count end
  local base = which
  if not fileExists(frontPath(dex, base, 1)) then
    if not fileExists(frontPath(dex, "normal", 1)) then
      frontFrameCache[key] = { resolved = nil, count = 0 }
      return nil, 0
    end
    base = "normal"
  end
  local n = 1
  while n < 64 and fileExists(frontPath(dex, base, n + 1)) do
    n = n + 1
  end
  frontFrameCache[key] = { resolved = base, count = n }
  return base, n
end

-- Time-indexed frame pick shared by the battle hook (which needs the path)
-- and the menu screens (which need the image).  Crystal anims run at
-- roughly 12 fps.
local function frontFrameIndex(dex, which)
  local base, count = frontFrameInfo(dex, which)
  if not base or count <= 0 then return nil, nil end
  if count <= 1 then return base, 1 end
  local t = (love and love.timer and love.timer.getTime)
    and love.timer.getTime() or 0
  if animMode == "once" then
    local key = tostring(dex) .. "|" .. base
    local start = animStart[key]
    if start == nil then
      start = t
      animStart[key] = start
    end
    local frame = math.floor((t - start) * 12) + 1
    if frame > count then frame = count end
    return base, frame
  end
  return base, math.floor(t * 12) % count + 1
end

local function frontFrameForTime(dex, which)
  local base, frame = frontFrameIndex(dex, which)
  if not base then return nil end
  return frontPath(dex, base, frame)
end

-- Gold's dex entry page and status screen resolve their pic once per draw
-- into a per-path cache and redraw it every frame, so animating means
-- swapping in the time-indexed frame image at resolve time.  Images load
-- lazily and cache by path for the session.  The mod's frames are the
-- full-color set, so they are marked crystal: the Gen 2 screens below wrap
-- their draw methods to skip the GBC palette pass for these images (that
-- pass buckets a full-color pic by its red channel and flattens it).
local menuFrameImages = {}
local menuFrameImageCount = 0
local function menuFrameImageForTime(dex, which)
  local base, frame = frontFrameIndex(dex, which)
  if not base then return nil end
  local path = frontPath(dex, base, frame)
  local img = menuFrameImages[path]
  if img == nil then
    local ok, image = pcall(love.graphics.newImage, path)
    if ok and image then
      image:setFilter("nearest", "nearest")
      markCrystal(image)
    end
    img = (ok and image) or false
    menuFrameImages[path] = img
    menuFrameImageCount = menuFrameImageCount + 1
    if menuFrameImageCount > 300 then
      menuFrameImages = {}
      menuFrameImageCount = 0
    end
  end
  img = img or nil
  if img and gen2Mono() then
    return gen2GrayImage(img)
  end
  return img
end

-- ------- PNG-frame animation
--
-- The front art ships as PNG frame folders (assets/front/<variant>/<dex>/NNN.png)
-- with the per-frame durations in animation_data.  Load a dex's whole frame
-- set as ready images -- raw, or luminance-baked onto a palette -- paired
-- with the durations, in the same { images, durations } shape every animated
-- screen consumes.  Cached per variant + palette (the bake is fixed by the
-- palette, so distinct palettes get distinct entries); the colors-mode reset
-- clears it.
local pngAnimCache = {}

local function pngFrameDurations(which, dex, count)
  local src = (animationData[which] and animationData[which][tostring(dex)])
    or (animationData.normal and animationData.normal[tostring(dex)])
  local out = {}
  for i = 1, count do
    out[i] = (src and src[i]) and src[i] or 100
  end
  return out
end

-- Bake one PNG frame onto a palette by luminance -- the animated analogue
-- of lumaPng: the remap buckets the full-color art's shading into the
-- palette so it survives the engine's recolor passes (which bucket by red
-- channel and flatten full-color art).
local function bakeFrameImage(path, colors)
  local ok, data = pcall(love.image.newImageData, path)
  if not (ok and data) then return nil end
  local okMap = pcall(function()
    data:mapPixel(function(_, _, r, g, b, a)
      if a == 0 then return r, g, b, a end
      local yy = 0.299 * r + 0.587 * g + 0.114 * b
      local col = yy > 0.83 and colors[1] or yy > 0.5 and colors[2]
        or yy > 0.17 and colors[3] or colors[4]
      return col[1] / 255, col[2] / 255, col[3] / 255, a
    end)
  end)
  if not okMap then return nil end
  local okNew, baked = pcall(love.graphics.newImage, data)
  if not (okNew and baked) then return nil end
  baked:setFilter("nearest", "nearest")
  markCrystal(baked)
  return baked
end

-- All frames of a variant (raw when pal is nil, luminance-baked onto the
-- palette otherwise), or nil when the variant has no frames.  The raw path
-- reuses loadImageRaw's cache so the menus and the static sprite hook share
-- the same frame images.
local function pngFrames(dex, which, pal, tag)
  local key = ("png:%s:%s:%s:%s"):format(
    tostring(dex), tostring(which), pal and pal.name or "raw", tag or "")
  local hit = pngAnimCache[key]
  if hit ~= nil then return hit or nil end
  local base, count = frontFrameInfo(dex, which)
  if not base or count <= 0 then
    pngAnimCache[key] = false
    return nil
  end
  local images = {}
  local last
  for i = 1, count do
    local path = frontPath(dex, base, i)
    local img = pal and bakeFrameImage(path, pal.colors)
      or loadImageRaw(path)
    if img then
      images[i] = img
      last = img
    else
      images[i] = last -- hold the previous frame rather than a blank
    end
  end
  if not images[1] then
    pngAnimCache[key] = false
    return nil
  end
  local out = {
    images = images,
    durations = pngFrameDurations(which, dex, count),
  }
  pngAnimCache[key] = out
  return out
end

-- Luminance-bake the NORMAL variant's frames onto a palette.  colours == nil
-- yields the raw normal frames instead.
local function lumaFrames(dex, colors, tag)
  if not (colors and colors[1]) then
    return pngFrames(dex, "normal", nil, tag)
  end
  return pngFrames(dex, "normal",
    { name = "luma:" .. tostring(tag or "mono"), colors = colors }, tag)
end

-- Frames for a menu screen (dex page / status / Hall of Fame / title /
-- Oak speech): the raw variant frames when the variant ships its own folder
-- (REDPP full color), else the full-color frames baked onto the 4-shade DMG
-- ramp.  Baking onto the DMG ramp (not the species' final palette) is what
-- keeps the shading and still lets the screen's own SGB zone recolor the
-- four shades like vanilla 2bpp art: the shade-remap shader keys on the red
-- channel, so 255/170/85/0 -> c0/c1/c2/c3.  Baking the final palette in here
-- and then marking the sprite true-color was the white-box bug: the
-- unshaded re-blit redraws the sprite's white canvas background raw, over
-- the zone's colored background.
local function menuFrames(menu, species, which)
  local dex = dexFor(species)
  if not dex then return nil end
  local art = artVariantForMode(which or "normal")
  local base = frontFrameInfo(dex, art)
  if base and base == art then
    return pngFrames(dex, art, nil)
  end
  return lumaFrames(dex, DMG_RAMP, "menu-gray")
end

-- Dex entry page / status screen: once the screen has loaded its pic,
-- swap in the PNG frames and keep advancing them from update().  The
-- species' shininess decides the variant on the status screen (its mon is
-- right there); the dex page is always normal.
local function installMenuFrames(menu, species, which)
  if not (menu and species) then return end
  local dex = dexFor(species)
  if not dex then return end
  -- Remember what was installed and under which COLORS mode, so the
  -- update driver below can re-bake (and restart the animation) the
  -- moment the mode changes -- the same reset the battle applies to its
  -- battlers.
  menu.__crystalSpecies = species
  menu.__crystalWhich = which or "normal"
  menu.__crystalPaletteMode = PaletteFX and PaletteFX.mode
  local frames = menuFrames(menu, species, which)
  if frames then
    menu.sprite = frames.images[1]
    -- Outside ADVANCED the frames are grayscale (see menuFrames), so they
    -- must ride the screen's own palette zone instead of the true-color
    -- re-blit that left the white box.
    menu.spriteTrueColor = colorMode()
    menu.__crystalAnim = {
      frame = 1,
      elapsed = 0,
      durations = frames.durations,
      images = frames.images,
    }
    return
  end
  -- Last resort: static PNG first frame.
  local data = menu and menu.game and menu.game.data
  local frame = data and loadImage(
    frontPath(dex, artWhich(which or "normal"), 1), data, species, nil)
  if frame then
    menu.sprite = frame
    menu.spriteTrueColor = colorMode()
  end
end

-- Advance one animation's frame counter on the fixed-step logicToReal
-- clock the battle uses, so the loop plays at 1X at any game speed.
-- Shared by the menu driver below and the Hall of Fame's party sweep.
local function advanceAnim(anim, dt, game)
  if not anim or anim.done then return end
  anim.elapsed = anim.elapsed + logicToReal(dt, game) * 1000
  local guard = 0
  while anim.elapsed >= math.max(1, anim.durations[anim.frame] or 100)
      and guard < 50 and not anim.done do
    anim.elapsed = anim.elapsed - math.max(1, anim.durations[anim.frame] or 100)
    anim.frame = anim.frame + 1
    if anim.frame > #anim.durations then
      if animMode == "once" then
        anim.frame = #anim.durations
        anim.done = true
      else
        anim.frame = 1
      end
    end
    guard = guard + 1
  end
end

-- Advance a menu's animation and swap its sprite.  When the COLORS mode
-- changed since the frames were installed, re-bake them onto the new
-- palette and restart the loop -- the battle's own update wrapper does
-- the same reset for its battlers, so the dex/status pages match it.
local function advanceMenuSprite(menu, dt)
  local mode = PaletteFX and PaletteFX.mode
  if menu and menu.__crystalSpecies
      and menu.__crystalPaletteMode ~= mode then
    installMenuFrames(menu, menu.__crystalSpecies, menu.__crystalWhich)
  end
  local anim = menu and menu.__crystalAnim
  if not anim then return end
  local before = anim.frame
  advanceAnim(anim, dt, menu.game)
  if anim.frame ~= before then menu.sprite = anim.images[anim.frame] end
end

-- Transformed Ditto (battle): the copied species' shape, tinted to
-- Ditto's own purple palette (the hardware forces GRAYMON on a
-- transformed mon; the mod keeps the classic purple look instead).
local DITTO_PURPLE = {
  { 236, 208, 244 }, { 172, 124, 200 }, { 104, 64, 136 }, { 44, 28, 64 },
}
local function transformPalette(data)
  if PaletteFX and PaletteFX.monPal then
    local ok, colors = pcall(PaletteFX.monPal, data, "DITTO")
    if ok and colors and colors[1] then
      return { name = "DITTO", colors = colors }
    end
  end
  return { name = "DITTO-fallback", colors = DITTO_PURPLE }
end

local lumaPngCache = {}
-- Luminance-bake a static back pic onto a palette -- the static analogue
-- of lumaFrames, for the player-side transform swap.
local function lumaPng(dex, colors, tag)
  local key = "lumaPng:" .. tostring(dex) .. ":" .. tostring(tag or "-")
  local hit = lumaPngCache[key]
  if hit ~= nil then return hit or nil end
  local path = backPath(dex, "normal")
  if not fileExists(path) then
    lumaPngCache[key] = false
    return nil
  end
  local ok, data = pcall(love.image.newImageData, path)
  if not (ok and data) then
    lumaPngCache[key] = false
    return nil
  end
  local okMap = pcall(function()
    data:mapPixel(function(_, _, r, g, b, a)
      if a == 0 then return r, g, b, a end
      local yy = 0.299 * r + 0.587 * g + 0.114 * b
      local col = yy > 0.83 and colors[1] or yy > 0.5 and colors[2]
        or yy > 0.17 and colors[3] or colors[4]
      return col[1] / 255, col[2] / 255, col[3] / 255, a
    end)
  end)
  if not okMap then
    lumaPngCache[key] = false
    return nil
  end
  local okNew, baked = pcall(love.graphics.newImage, data)
  if not (okNew and baked) then
    lumaPngCache[key] = false
    return nil
  end
  baked:setFilter("nearest", "nearest")
  markCrystal(baked)
  lumaPngCache[key] = baked
  return baked
end

-- Trainer replacement portraits: the mod's own 56x56 art named after the
-- engine's generated pics (assets/trainers/{normal|grayscale}/{name}.png),
-- full color under ADVANCED and grayscale otherwise.
local function trainerPicName(path)
  if type(path) ~= "string" then return nil end
  return path:match("([^/\\]+)%.png$") or path:match("([^/\\]+)$")
end

-- First path that exists on disk (or nil when the filesystem is absent
-- or none match).  Skips nil candidates so the custom-folder lookups can
-- pass their fallback chain in one call.
local function firstExistingPath(...)
  for i = 1, select("#", ...) do
    local p = select(i, ...)
    if p and fileExists(p) then return p end
  end
  return nil
end

-- The custom portrait path for a trainer, or nil to keep the
-- engine's own pic.  REPLACE SPRITES ("both" / "trainers") prefers the
-- user's art in assets/trainers/opponents/ -- named after the engine pic
-- basename (agatha.png) or, failing that, the class id (OPP_AGATHA) --
-- and always falls back to the shipped portrait.  Path resolution only;
-- modTrainerPic loads the result.  Gen 2 reuses this for the battle
-- intro's opponent portrait (enemyTrainerImage/enemyTrainerPath).
local function trainerArtPath(game, trainer, oppClass, partyIndex)
  -- NONE / OVERWORLD: no trainer portrait is replaced at all -- not even
  -- the mod's shipped fallback art -- the engine keeps its own sprites.
  if not customTrainerPortraits() then return nil end
  if not trainer then return nil end
  local path
  if oppClass == "OPP_ROCKET" and (partyIndex or 1) >= 42
      and trainer.picJessieJames then
    path = trainer.picJessieJames
  elseif trainer.pic then
    path = trainer.pic
  elseif trainer.basePic and game and game.data and game.data.trainers
      and game.data.trainers[trainer.basePic] then
    path = game.data.trainers[trainer.basePic].pic
  end
  local name = trainerPicName(path)
  if not name then return nil end
  local modPath = ("%s/trainers/%s.png"):format(BASE, name)
  if customOpponents() then
    -- the docs say "opponents", but several installs created
    -- "opponent" -- accept both, plus the class id (OPP_AGATHA)
    return firstExistingPath(
      ("%s/trainers/opponents/%s.png"):format(BASE, name),
      ("%s/trainers/opponent/%s.png"):format(BASE, name),
      oppClass and ("%s/trainers/opponents/%s.png"):format(BASE, oppClass),
      oppClass and ("%s/trainers/opponent/%s.png"):format(BASE, oppClass),
      modPath)
  end
  return firstExistingPath(modPath)
end

-- The battle opponent portrait image for a trainer, or nil to keep the
-- engine's own pic.  The whole body is pcall'd: a corrupt or unreadable
-- custom file can never crash the battle, it just keeps whatever pic the
-- engine already loaded.
local function modTrainerPic(game, trainer, oppClass, partyIndex)
  if not customTrainerPortraits() then return nil end
  local ok, img = pcall(function()
    local p = trainerArtPath(game, trainer, oppClass, partyIndex)
    if not p then return nil end
    -- Read the save's color mode directly; during newTrainer PaletteFX.mode
    -- may still be "redpp" and hasn't been switched yet.
    local gameMode = game and game.save and game.save.options
      and game.save.options.colors
    -- Full-color portraits carry no DMG shades, so every non-ADVANCED mode
    -- needs a luminance bake onto the mode's MEWMON display colors for the
    -- pic -- otherwise the engine's recolor passes (the red-channel
    -- quantize in the colorized modes, the frame-level mono remap) flatten
    -- the shading.  ADVANCED keeps the raw full-color art.  On Gen 2
    -- modePalette cannot resolve (no PaletteFX), so the bake falls through
    -- to loadImageRaw, which is the Gen 2 behaviour before.
    if gameMode ~= "redpp" then
      local colors = modePalette(game and game.data, "MEWMON", gameMode)
      if colors then
        local baked = lumaBakeImage(p, colors)
        if baked then return baked end
      end
    end
    return loadImageRaw(p)
  end)
  if not ok then
    mod.log:info("custom trainer pic skipped (%s)", tostring(img))
    return nil
  end
  return img
end

-- The player.s own trainer art: with REPLACE SPRITES "both" / "player",
-- assets/trainers/player/red.png replaces the vanilla red pic (trainer
-- card / Hall of Fame) and the battle back pic; a dedicated redb.png in
-- the same folder wins the back slot when present.  The shipped
-- portraits (assets/trainers/red.png / redb.png) are the next fallback.
-- Only paths CONFIRMED on disk are ever returned in-game -- the engine
-- crashes battle construction on a missing pic path, so when nothing
-- exists the function returns nil and the player.sprite hook falls
-- through to the engine's own sprite, exactly like the opponents'
-- fallback.  TRAINERS (player side off) always returns nil.  Headless
-- (no filesystem: fileExists answers nil for every probe) resolves the
-- first candidate as a best effort for tests.
-- The player-portrait files OPTIONS > PLAYER SPRITE cycles through.  The
-- launcher sandbox no longer exposes love.filesystem (or any directory
-- listing) to mods, so the folder cannot be enumerated at runtime; this is
-- the shipped assets/trainers/player/ set, kept in the sorted order the old
-- getDirectoryItems + table.sort produced.  "default" keeps the game's own
-- portrait (and overworld sprite) instead of the mod's art.
local PLAYER_SPRITE_DEFAULT = "default"
local PLAYER_SPRITES = {
  "default",
  "blue_flip.png", "gold_flip.png", "james.png",
  "jessie.png", "kris_flip.png", "leaf.png",
  "red.png", "silver_flip.png",
}
local function listPlayerSprites()
  return PLAYER_SPRITES
end

-- Auto-flip: a player portrait named *_flip.png is mirrored for the
-- battle back pic automatically -- the suffix marks art that faces the
-- wrong way for the back slot, replacing the old FLIP SPRITE toggle.
-- With BATTLE PIC = BACK a dedicated back sprite fills the slot instead,
-- and it is already authored as a back view, so the marker must not
-- mirror it -- only the front portrait (the fallback when no back file
-- ships) still gets mirrored.
local function playerSpriteFlip()
  local sel = playerSprite or DEFAULT_PLAYER_SPRITE
  if sel:sub(-9) ~= "_flip.png" then return false end
  if battlePicPref == "back" then
    local stem = sel:gsub("_flip%.png$", "")
    if fileExists(("%s/trainers/back/%s.png"):format(BASE, stem)) then
      return false
    end
  end
  return true
end

-- The portrait filename without the .png suffix and without the _flip
-- auto-mirror marker: red.png and red_flip.png both read "red".  This is
-- the key for the dedicated battle back sprites (assets/trainers/back/)
-- and for the overworld sheets (red.png / red_bike.png).
local function playerSpriteStem()
  local sel = playerSprite or DEFAULT_PLAYER_SPRITE
  if sel == PLAYER_SPRITE_DEFAULT then return nil end
  if sel:sub(-9) == "_flip.png" then
    sel = sel:sub(1, -10) .. ".png"
  end
  return sel:gsub("%.png$", "")
end

local function playerArtPath(side, kind)
  if not customPlayer() then return nil end
  local sel = playerSprite or DEFAULT_PLAYER_SPRITE
  -- "default" keeps the game's own portrait: no mod path is substituted.
  if sel == PLAYER_SPRITE_DEFAULT then return nil end
  local customSel = ("%s/trainers/player/%s"):format(BASE, sel)
  local customRedb = ("%s/trainers/player/redb.png"):format(BASE)
  local modRedb = ("%s/trainers/redb.png"):format(BASE)
  local modRed = ("%s/trainers/red.png"):format(BASE)
  if side == "back" then
    -- OPTIONS > BATTLE PIC = BACK: a dedicated back sprite from
    -- assets/trainers/back/ wins the battle back slot (kind == "battle";
    -- the Hall of Fame's back pic keeps the front portrait).  A missing
    -- back file falls through to the front portrait below.
    if battlePicPref == "back" and (kind == nil or kind == "battle") then
      local stem = playerSpriteStem()
      if stem then
        local back = ("%s/trainers/back/%s.png"):format(BASE, stem)
        if fileExists(back) then return back end
      end
    end
    -- the selected portrait fills the back slot too; for the default
    -- red.png the dedicated redb.png (custom, then shipped) still wins
    local chain = sel == "red.png"
      and { customRedb, customSel, modRedb, modRed }
      or { customSel, modRed }
    local p = firstExistingPath(unpack(chain))
    if p then return p end
    -- headless best effort: assume the first candidate exists
    local first = sel == "red.png" and customRedb or customSel
    if fileExists(first) == nil then return first end
    return nil
  end
  local p = firstExistingPath(customSel, modRed)
  if p then return p end
  if fileExists(customSel) == nil then return customSel end
  return nil
end

-- Weak-keyed cache of the staged-battle mono bakes, keyed by the source
-- image; resetCaches replaces it on a COLORS-mode hot reload.  Declared
-- here so bakeStagedPic never reads a nil global before that reset.
local monoBaked = setmetatable({}, { __mode = "k" })

local function bakeStagedPic(img)
  if not img or isCrystalImage(img) then return img end
  local mode = PaletteFX and PaletteFX.mode
  local hit = monoBaked[img]
  if hit and hit[1] == mode then return hit[2] end
  local colors = monoDisplayColors()
  if not colors then return img end
  local id = readPixels(img)
  if not id then return img end
  local okM = pcall(function()
    id:mapPixel(function(_, _, r, g, b, a)
      if a == 0 then return r, g, b, a end
      local col = r > 0.83 and colors[1] or r > 0.5 and colors[2]
        or r > 0.17 and colors[3] or colors[4]
      return col[1] / 255, col[2] / 255, col[3] / 255, a
    end)
  end)
  if not okM then return img end
  local okN, baked = pcall(love.graphics.newImage, id)
  if not (okN and baked) then return img end
  baked:setFilter("nearest", "nearest")
  monoBaked[img] = { mode, baked }
  return baked
end

local function ballTile(mon)
  if not mon then return 3 end
  if mon.hp <= 0 then return 2 end
  if mon.status then return 1 end
  return 0
end

local POKEBALL_RED = { 232, 64, 64 }
local POKEBALL_SHINE = { 255, 176, 176 }

-- Classic red/white party ball.  The engine's balls.png is a grayscale
-- sheet whose four 2bpp shades read as white / light gray / dark gray /
-- black; the colorized zone pass would remap those grays onto the HP-bar
-- palette (flattening the ball into white/green blobs), so the row is
-- baked here -- tiles 0/1 (full + status) as red top / white bottom /
-- black band, tiles 2/3 (fainted / empty) as their native grayscale -- and
-- re-drawn in battle.overlay.  Mono modes pass a DMG ramp instead.
local function ballShade(colors, tile, x, y, r, a)
  if colors then
    if a == 0 then return nil end
    return r > 0.83 and colors[1] or r > 0.5 and colors[2]
      or r > 0.17 and colors[3] or colors[4]
  end
  if (tile == 0 or tile == 1) and a ~= 0 and r > 0.17 then
    if x == 3 and y == 3 then return POKEBALL_SHINE end
    return y < 5 and POKEBALL_RED or { 255, 255, 255 }
  end
  return nil
end

local ballSheetData = nil
local ballBaked = {}

-- Bake one 8x8 party-ball tile.  Colorized battles bake the classic
-- red/white ball (the zone pass would otherwise flatten it); mono modes
-- bake the DMG ramp.  Cached per (mode, tile); the shared grayscale
-- source is loaded once.
local function bakeBall(mon)
  local tile = ballTile(mon)
  local mono = battleMono()
  local shades = mono and monoDisplayColors() or nil
  local key = (mono and "mono:" or "classic:") .. tile
  local hit = ballBaked[key]
  if hit then return hit end
  if not ballSheetData then
    local ok, id = pcall(love.image.newImageData,
      "assets/generated/battle/balls.png")
    if not (ok and id) then return nil end
    ballSheetData = id
  end
  local ok, img = pcall(function()
    local id = love.image.newImageData(8, 8)
    for y = 0, 7 do
      for x = 0, 7 do
        local r, g, b, a = ballSheetData:getPixel(tile * 8 + x, y)
        local col = ballShade(shades, tile, x, y, r, a)
        if not col then
          id:setPixel(x, y, r, g, b, a)
        else
          id:setPixel(x, y, col[1] / 255, col[2] / 255, col[3] / 255, a)
        end
      end
    end
    local out = love.graphics.newImage(id)
    out:setFilter("nearest", "nearest")
    return out
  end)
  if not (ok and img) then return nil end
  ballBaked[key] = img
  return img
end

-- Bake all six party balls; nil if any single bake failed (the caller then
-- falls back to the vanilla grayscale row).
local function bakeBallRow(party)
  local imgs = {}
  for i = 1, 6 do
    local img = bakeBall(party and party[i])
    if not img then return nil end
    imgs[i] = img
  end
  return imgs
end

-- The palette for the resting caught ball, as the 3-color ramp
-- AnimPlayer:drawSprites feeds its shade shader ({paper, ink1, ink2} =
-- light / dark / darkest).  nil under a mono COLORS mode (the vanilla
-- grayscale ball is already right there) or when the species palette is
-- unavailable.  Cached on the battle (the caught mon is fixed) and
-- re-resolved when the COLORS mode changes.
local function caughtBallPalette(battle)
  if battleMono() then return nil end
  local mode = PaletteFX and PaletteFX.mode
  local cache = battle.__crystalCaughtBall
  if cache and cache.mode == mode then return cache.pal or nil end
  local mon = battle.enemy and (battle.enemy.mon or battle.enemy)
  local species = mon and mon.species
  local pal = nil
  if PaletteFX and species and battle.data then
    local ok, p = pcall(PaletteFX.monPal, battle.data, species)
    pal = ok and p or nil
  end
  local out = false
  if pal and pal[2] and pal[3] and pal[4] then
    out = {
      { pal[2][1] / 255, pal[2][2] / 255, pal[2][3] / 255 },
      { pal[3][1] / 255, pal[3][2] / 255, pal[3][3] / 255 },
      { pal[4][1] / 255, pal[4][2] / 255, pal[4][3] / 255 },
    }
  end
  battle.__crystalCaughtBall = { mode = mode, pal = out }
  return out or nil
end

-- Colorized battles send every HUD pixel through the zone pass, which remaps
-- by red channel onto the HP-bar palette -- a baked ball would be flattened
-- into green/yellow/white blobs.  Rows drawn this frame are stashed here and
-- re-drawn in battle.overlay, on top of the finished frame, so the classic
-- red/white balls survive untouched.  Cleared by drawOverlayBalls.
local ballOverlayRows = nil

local function recordBallOverlay(imgs, x, y, dx)
  local row = { imgs = imgs, x = x, y = y, dx = dx }
  if ballOverlayRows then
    ballOverlayRows[#ballOverlayRows + 1] = row
  else
    ballOverlayRows = { row }
  end
end

local function drawOverlayBalls()
  local rows = ballOverlayRows
  ballOverlayRows = nil
  if not rows then return end
  local g = love.graphics
  g.setColor(1, 1, 1, 1)
  for _, row in ipairs(rows) do
    for i = 1, 6 do
      g.draw(row.imgs[i], row.x + (i - 1) * row.dx, row.y)
    end
  end
end

local function loadSparkles()
  if sparkleImage then return true end
  local ok, image = pcall(love.graphics.newImage,
    SHINY_BASE .. "/gen2_sparkles.png")
  if not ok or not image then return false end
  image:setFilter("nearest", "nearest")
  sparkleImage = image
  sparkleQuads = {}
  for i = 0, 3 do
    sparkleQuads[i + 1] = love.graphics.newQuad(
      i * 16, 0, 16, 16, 64, 16)
  end
  return true
end

-- Crystal sprite registration.  Every mapped species (all 251 plus the
-- Unown forms live under 201) is patched unconditionally -- the 1.4.0
-- behaviour -- because the asset folders ship a full front AND back set
-- for each of them.  The engine resolves the sprite hook for any dex the
-- mod has no art for by falling back to its own art, so a missing file
-- is never a hard failure.
local crystalDefs = {}
pcall(function()
  for species, dex in pairs(speciesMap) do
    local def = mod.content.pokemon:get(species)
    if def then
      crystalDefs[species] = def
      mod.content.pokemon:patch(species, {
        spriteFront = frontPath(dex, "normal", 1),
        spriteBack = backPath(dex, "normal"),
        battleScaleFront = 1,
        battleScaleBack = 1,
        trueColor = true,
      })
    end
  end
end)

local function syncTrueColor()
  for species in pairs(crystalDefs) do
    crystalDefs[species].trueColor = colorMode()
  end
end
syncTrueColor()

mod.hooks:wrap("pokemon.sprite", function(next, originalPath, ctx)
  if ctx and ctx.species == GHOST_SPECIES then
    local p = ghostFrontPath()
    if artExists(p) then
      ctx.trueColor = colorMode()
      return p
    end
  end

  local dex = ctx and dexFor(ctx.species)
  -- Any species outside the map keeps the engine's own path untouched
  -- (the 1.4.0 gate): everything mapped here has a full art set, so no
  -- file-existence probe is needed before routing.
  if not dex then
    return next(originalPath, ctx)
  end

  -- Gen 2 has no COLORS palette modes and the mod's art there is always
  -- the full-color set (the grayscale folders are empty), so the engine's
  -- GBC palette pass must be told to leave it alone.
  -- Gen 2's back-slot renderer expects the path to resolve through its
  -- normal image loader; trueColor is supplied by the context, not by the
  -- Pokémon definition alone, and the engine reads it AFTER the hook
  -- returns (the palette guard in drawPic is `not (trueColor and
  -- GbcPalette.mode == "gbc")` since v0.2.45, so a false flag sends the
  -- full-color art through the 4-shade GBC remap).  v0.2.45 dropped the
  -- older `not trueColor` form; keep the flag set unconditionally for the
  -- custom paths the hook serves so both slots (enemy front, player back
  -- with FRONT SPRITES) survive the new guard.
  ctx.trueColor = isGen2 and true or colorMode()
  local which = variant(ctx.mon)

  -- Gold's battle screen re-resolves its pics through this hook every
  -- frame, so on Gen 2 the hook itself serves the animated frames
  -- (time-indexed) -- the Gen 1 animation loop is a BattleState patch
  -- Gold does not run.  With FRONT SPRITES on, the player's back slot
  -- serves the animated front art too.  (The player's slot is mirrored
  -- to face the opponent at the BattleState:pic layer, not here -- the
  -- enemy slot must keep the same frame paths.)
  if isGen2 and ctx.kind == "battle" and (ctx.side == "front" or frontPref) then
    local p = frontFrameForTime(dex, which)
    if p then return p end
    return next(originalPath, ctx)
  end

  if ctx.side == "back" then
    -- the player's own mon: front art instead of the back pic when the
    -- option is on (battle only -- summaries and the dex never ask for
    -- the back slot).  On Gen 2 the battle back slot with FRONT SPRITES
    -- was already answered by the branch above (animated front frames);
    -- this branch is the Gen 1 battle path and every non-battle back.
    if frontPref and not isGen2 and ctx.kind == "battle" then
      return frontHookPath(dex, which) or next(originalPath, ctx)
    end
    if colorMode() then
      local p = backPath(dex, which)
      if artExists(p) then return p end
      local np = backPath(dex, "normal")
      if artExists(np) then return np end
      return next(originalPath, ctx)
    end
    local gray = backGrayPath(dex)
    if fileExists(gray) then return gray end
    -- On Gen 2 the shiny variant ships its own full-color back art and is
    -- served true-color, so prefer the mon's own variant; Gen 1 outside
    -- ADVANCED keeps collapsing shiny to normal (a grayscaled shiny reads
    -- like its normal form there).
    local p = backPath(dex, isGen2 and which or "normal")
    if artExists(p) then return p end
    local np = backPath(dex, "normal")
    if artExists(np) then return np end
    return next(originalPath, ctx)
  end

  return frontHookPath(dex, which) or next(originalPath, ctx)
end, 930)

-- The player's own trainer art (the red front pic / redb battle back):
-- the mod's portrait replaces the vanilla pics wherever playerPath
-- resolves them -- the trainer card, the Hall of Fame, and the battle
-- intro's back pic.  The catch tutorial's old man and Yellow's Oak demo
-- keep their own pics.
mod.hooks:wrap("player.sprite", function(next, originalPath, ctx)
  if ctx and not ctx.demo and not ctx.oakDemo then
    local p = playerArtPath(ctx.side, ctx.kind)
    if p then
      -- The portrait is full-color art on both generations, so the engine
      -- must never red-channel-quantize it (that collapses a vivid
      -- portrait into the paper shade).  Serve it trueColor: on Gen 1 the
      -- battle back pic is luminance-baked by the picImage wrap instead
      -- (see installMonoHooks), the trainer card and Hall of Fame ride the
      -- unshaded re-blit, and ADVANCED / Gold show it raw.
      ctx.trueColor = true
      return p
    end
  end
  return next(originalPath, ctx)
end, 930)

-- The trainer card shows the player's front portrait mirrored: the pic
-- art faces the way the battle back pic faces, and the card portrait is
-- traditionally the other way.  The mirror is baked into an in-memory
-- copy (imageDataCopy hands back a private ImageData -- getData when it
-- works, a canvas readback otherwise), so the shipped file can stay
-- oriented for the battle back slot.  The getData path is preferred over
-- the canvas readback: battle construction can run while a scaled or
-- DPI-scaled transform is active, and drawing the pic through that
-- transform into a readback canvas crops the copy.
-- Flip a sprite FILE horizontally by loading its pixels straight from
-- disk (love.image.newImageData) and mirroring them on the ImageData, the
-- same primitives the DMG grayscale bake and the pokeball bake use -- both
-- proven on every engine build.  Cached per path: battle animation cycles
-- a small set of frame files, so each one flips once.  Returns nil (never
-- a blank image) if anything fails, so callers fall back to the original.
local gen2FlipFileCache = {}
function flipFileImage(path)
  if type(path) ~= "string" then return nil end
  local hit = gen2FlipFileCache[path]
  if hit ~= nil then return hit or nil end
  local okId, id = pcall(love.image.newImageData, path)
  if not (okId and id) then
    gen2FlipFileCache[path] = false
    return nil
  end
  local okClone, src = pcall(id.clone, id)
  if not (okClone and src) then
    gen2FlipFileCache[path] = false
    return nil
  end
  local w, h = id:getDimensions()
  local okMap = pcall(function()
    id:mapPixel(function(x, y)
      return src:getPixel(w - 1 - x, y)
    end)
  end)
  if not okMap then
    gen2FlipFileCache[path] = false
    return nil
  end
  local okImg, flipped = pcall(love.graphics.newImage, id)
  if not (okImg and flipped) then
    gen2FlipFileCache[path] = false
    return nil
  end
  flipped:setFilter("nearest", "nearest")
  -- Deliberately NOT marked crystal, matching flipHImage below: the mono
  -- bake keyed on the ORIGINAL image still runs via the path check, and
  -- the full-color art is drawn raw under trueColor anyway.
  gen2FlipFileCache[path] = flipped
  return flipped
end

local function flipHImage(img, srcPath)
  if not img then return img end
  -- CPU data straight off the Image when the engine leaves it readable.
  local okData, data = pcall(img.getData, img)
  if okData and data and type(data.getDimensions) == "function" then
    -- data is a usable ImageData; flip it directly.
  else
    -- getData either failed or returned something that isn't a usable
    -- ImageData (v0.2.45 battle pics have no CPU backing, and some
    -- engine builds return a non-ImageData userdata on success).  Try
    -- the source FILE next, then a canvas readback as last resort.
    if type(srcPath) == "string" then
      local okLoad, loaded = pcall(love.image.newImageData, srcPath)
      if okLoad and loaded and type(loaded.getDimensions) == "function" then
        data = loaded
      end
    end
    if not (data and type(data.getDimensions) == "function") then
      -- Last resort: canvas readback.  Safe here because the player
      -- front flip runs inside resetBattlerAnimation, which is called
      -- from resetPlayerAnimation during the update step (never mid-draw).
      -- drawPic's mid-draw flip is handled separately via flipFileImage.
      local rp = readPixels(img)
      if rp and type(rp.getDimensions) == "function" then
        data = rp
      end
    end
  end
  if not data then return img end
  -- Mirror the pixels into a write copy, reading from the ORIGINAL data
  -- (mapPixel returns normalized colours -- the same convention
  -- lumaBakeImage's palette pass uses, proven on this engine).
  local w, h = data:getDimensions()
  local okClone, out = pcall(data.clone, data)
  if not (okClone and out) then return img end
  local okWrite = pcall(function()
    out:mapPixel(function(x, y)
      return data:getPixel(w - 1 - x, y)
    end)
  end)
  if not okWrite then return img end
  local okImg, newImg = pcall(love.graphics.newImage, out)
  if not (okImg and newImg) then return img end
  newImg:setFilter("nearest", "nearest")
  -- Deliberately NOT marked crystal: the bake paths key off
  -- isCrystalImage, and the source pic here is an engine-loaded portrait
  -- (built from ImageData, so it has no filename and is not crystal).  A
  -- marked copy would dodge bakeStagedPic's luminance remap in the mono
  -- voxel battle and render flat next to the baked original.  The trainer
  -- card / Hall of Fame flip checks run on the ORIGINAL pic before the
  -- mirror, so an unmarked copy changes nothing for them.
  return newImg
end

-- Mirror the player portrait on the trainer card only.  The card loads
-- the pic straight from the hooked path, so the wrap swaps in the flipped
-- copy after TrainerCard.new builds; the Hall of Fame front pic, the
-- battle back pic, and the demos are untouched.  Vanilla cards (no mod
-- portrait shipped) are left alone -- the flip keys off the mod's assets.
local okTC, TrainerCard = pcall(require, "src.ui.TrainerCard")
if okTC and type(TrainerCard.new) == "function"
    and not TrainerCard.__crystalFlipHook then
  TrainerCard.__crystalFlipHook = true
  local innerCardNew = TrainerCard.new
  function TrainerCard.new(game, opts)
    local self = innerCardNew(game, opts)
    if self and self.pic and isCrystalImage(self.pic) then
      self.pic = flipHImage(self.pic)
    end
    return self
  end
end

-- The Hall of Fame entry shows the same front portrait, so it is
-- mirrored to match the trainer card; the back-pic sweep (backs) keeps
-- its own layout and is left alone.
local okHoF, HallOfFame = pcall(require, "src.ui.HallOfFame")
if okHoF and type(HallOfFame.new) == "function"
    and not HallOfFame.__crystalFlipHook then
  HallOfFame.__crystalFlipHook = true
  local innerHoFNew = HallOfFame.new
  function HallOfFame.new(game, onDone)
    local self = innerHoFNew(game, onDone)
    if self and self.playerPic and isCrystalImage(self.playerPic) then
      self.playerPic = flipHImage(self.playerPic)
    end
    return self
  end
end

-- The Hall of Fame's party sweep shows each member's front pic.  Feed it
-- the Crystal PNG frames (the dex-page treatment: raw art under REDPP,
-- luminance-baked otherwise, since the whole screen rides the engine's
-- recolor passes) and animate them from update().  Species without
-- Crystal art keep the engine's own pic.
if okHoF and type(HallOfFame.spriteFor) == "function"
    and type(HallOfFame.update) == "function"
    and not HallOfFame.__crystalAnimHook then
  HallOfFame.__crystalAnimHook = true
  local innerHofSpriteFor = HallOfFame.spriteFor
  function HallOfFame:spriteFor(species)
    local dex = dexFor(species)
    if dex then
      local anims = self.__crystalAnims
      local anim = anims and anims[species]
      if not anim then
        local frames = menuFrames(self, species, "normal")
        if frames then
          anim = {
            dex = dex,
            frame = 1,
            elapsed = 0,
            durations = frames.durations,
            images = frames.images,
          }
          if not self.__crystalAnims then
            self.__crystalAnims = {}
          end
          self.__crystalAnims[species] = anim
          self.sprites[species] = frames.images[1]
          -- Grayscale frames outside ADVANCED ride the mon-palette zone;
          -- only the raw REDPP art opts out of the recolor pass.
          self.spriteTrueColor[species] = colorMode()
        end
      end
      if anim then return anim.images[anim.frame] end
    end
    return innerHofSpriteFor(self, species)
  end
  local innerHofUpdate = HallOfFame.update
  function HallOfFame:update(dt)
    if self.__crystalAnims then
      for _, anim in pairs(self.__crystalAnims) do
        advanceAnim(anim, dt, self.game)
      end
    end
    return innerHofUpdate(self, dt)
  end
end

-- The vanilla Gen 1 battle back pic (redb) is a 32x32 pic drawn at 2x --
-- 64px on screen -- but the mod's 56x56 trainer portrait would otherwise
-- render 112px in 2D battles (the back slot's 2x default).  (The 3D
-- battle sizes its own billboard, so it is unaffected.)  The
-- battle_sprite_scales content registry is the documented handle for the
-- bare player-back pic, but matching the mod's absolute asset path against
-- it has not held up in practice, so the mod wraps the engine's scale
-- resolution directly instead: any trainer art under assets/trainers/ (the
-- player portraits and the dedicated assets/trainers/back/ sprites) is
-- sized to the vanilla on-screen width from its PNG header.  The player's
-- own mon back pic and the enemy slot are not trainer art, so they pass
-- through to the engine untouched.
local TRAINER_ART_PREFIX = BASE .. "/trainers/"

local backScaleCache = {}  -- path -> scale | false
local function playerBackScale(path, target)
  if type(path) ~= "string" or type(target) ~= "number" then return nil end
  if path:sub(1, #TRAINER_ART_PREFIX) ~= TRAINER_ART_PREFIX then
    return nil
  end
  local hit = backScaleCache[path]
  if hit ~= nil then return hit or nil end
  local bytes = modReadBytes(path)
  local w = (type(bytes) == "string") and pngWidth(bytes) or nil
  local scale = (w and w > 0) and (target / w) or nil
  if scale and (scale < 0.25 or scale > 4.0) then scale = nil end
  backScaleCache[path] = scale or false
  return scale
end

-- Gen 1 draws the player's back pic at the side default 2x; size the mod's
-- trainer art to its native Crystal 56px instead of the vanilla 64px so it
-- draws at a clean 1:1 scale.  resolveBattleScale is the one
-- seam every back-pic draw goes through, so wrapping it is deterministic
-- regardless of the content registry.  The _flip mirror rebuilds
-- playerBackPic through love.graphics.newImage, which has no imageMeta
-- entry, so imagePathOf hands back nil and the scale lookup would lose the
-- path -- the trainer back pic is the only back-slot draw that passes no
-- species, so when both are nil the mod's own back-pic resolver recovers
-- the path it handed the engine.  Guarded for hot reload like every other
-- BattleState wrap.
if not isGen2 and type(BattleState.resolveBattleScale) == "function"
    and not BattleState.__crystalBackScaleHook then
  BattleState.__crystalBackScaleHook = true
  local innerResolve = BattleState.resolveBattleScale
  function BattleState.resolveBattleScale(data, side, path, species)
    if side == "back" then
      local p = path
      if not p and species == nil then
        p = playerArtPath("back", "battle")
      end
      local s = playerBackScale(p, 56)
      if s then return s end
    end
    return innerResolve(data, side, path, species)
  end
end

-- Crystal front animation.  The enemy always animates; the player's own
-- mon animates too when FRONT SPRITES is on (its back slot then shows the
-- animated front art).

-- Gen 1 2D battles: with FRONT SPRITES on, the player's back slot shows
-- the animated FRONT art, which faces the same way as the enemy's front
-- art (away from the opponent).  Mirror it horizontally so the player's
-- own mon faces the opponent -- the Gen 1 counterpart of the Gen 2
-- BattleState:pic flip.  Only the player's front art is touched; the
-- enemy slot, the default back art, and 3D voxel battles (whose mod has
-- its own back-sprite handling) pass through untouched.  flipHImage
-- returns a new image, so a frame shared with the enemy slot is flipped
-- once and cached, and the enemy keeps the original orientation.
-- The front art also has to be re-laid-out for the back slot it now
-- fills: Crystal front frames are centred in a 56px square with
-- transparent padding on every side, while the back art the slot
-- normally shows is bottom-aligned.  The engine pins the player pic's
-- canvas bottom on the text box (backPlacement), so the centred front
-- art floats above it in an empty gap.  Crop only the transparent
-- BOTTOM rows so the sprite stands on the text box; the width and the
-- art's horizontal placement are left exactly as authored so the body
-- never shifts side to side as the animation frames swap (cropping the
-- left padding per frame would pull each frame's body to a different x,
-- since the frames' extra left pixels sit in front of a body that stays
-- put).  The art stays at its native 1x size -- the same size as the
-- enemy's front sprite, which draws the same 56px art uncropped in the
-- front slot.  Baked per flipped frame (weak-keyed), with every failure
-- path falling back to the unmodified image.
local frontBackBakeCache = setmetatable({}, { __mode = "k" })
local function bakeFrontBack(image)
  if not image then return nil end
  local hit = frontBackBakeCache[image]
  if hit ~= nil then return hit end
  local data = imageDataCopy(image)
  if not data then
    frontBackBakeCache[image] = image
    return image
  end
  local w, h = data:getDimensions()
  local bottom = h - 1
  while bottom >= 0 do
    local opaque = false
    for x = 0, w - 1 do
      local _, _, _, a = data:getPixel(x, bottom)
      if a > 0 then opaque = true break end
    end
    if opaque then break end
    bottom = bottom - 1
  end
  if bottom < 0 then
    frontBackBakeCache[image] = image
    return image
  end
  if bottom == h - 1 then
    -- nothing to crop: the frame is already grounded edge-to-edge
    frontBackBakeCache[image] = image
    return image
  end
  local cw, ch = w, bottom + 1
  local okC, cropped = pcall(love.image.newImageData, cw, ch)
  if not (okC and cropped) then
    frontBackBakeCache[image] = image
    return image
  end
  local okPix = pcall(function()
    for y = 0, ch - 1 do
      for x = 0, cw - 1 do
        local r, g, b, a = data:getPixel(x, y)
        cropped:setPixel(x, y, r, g, b, a)
      end
    end
  end)
  if not okPix then
    frontBackBakeCache[image] = image
    return image
  end
  local okImg, out = pcall(love.graphics.newImage, cropped)
  if not (okImg and out) then
    frontBackBakeCache[image] = image
    return image
  end
  out:setFilter("nearest", "nearest")
  markCrystal(out)
  frontBackBakeCache[image] = out
  return out
end

local playerFrontFlipCache = setmetatable({}, { __mode = "k" })
local function playerBattleSprite(battle, battler, image)
  if not image or not battle or battler ~= battle.player
      or not frontPref or voxelContext(battle) then
    return image
  end
  local flipped = playerFrontFlipCache[image]
  if flipped == nil then
    flipped = flipHImage(image)
    playerFrontFlipCache[image] = flipped
  end
  return bakeFrontBack(flipped)
end

local function resetBattlerAnimation(battle, battler)
  local mon = battler and battler.mon
  if not mon then return end

  -- A Transformed Ditto keeps its own species in the mon struct but wears
  -- the copied species' shape; animate that shape, tinted Ditto-purple.
  local transformed = battler.__crystalTransformed
  local species = transformed or mon.species
  
  -- Ghost encounter in Pokémon Tower (before Silph Scope):
  -- battle.ghost is true regardless of the hidden species.
  -- Only the enemy shows the ghost sprite; the player's mon
  -- keeps its regular art.
  if isGhostBattle(battle) and not transformed
      and battler == battle.enemy then
    -- Bake the underlying species' palette onto the ghost art so it
    -- renders in the current COLORS mode like any other battler sprite.
    local img = loadImage(ghostFrontPath(), battle.data,
      mon.species, battle)
    if img then battler.sprite = trimGround(img, "front", battle) end
    battler.__crystalAnimation = nil
    return
  end
  
  local dex = dexFor(species)
  if not dex then return end

  if transformed then
    local pal = transformPalette(battle.data)
    local frames = lumaFrames(dex, pal.colors, "transform:" .. pal.name)
    if frames then
      local images = trimFrames(frames.images, "front", battle)
      battler.sprite = playerBattleSprite(battle, battler, images[1])
      battler.__crystalAnimation = {
        dex = dex,
        variant = "normal",
        species = species,
        redpp = colorMode(),
        frame = 1,
        elapsed = 0,
        durations = frames.durations,
        images = images,
      }
    end
    return
  end

  local which = variant(mon)
  -- the variant the animation state stores: shiny collapses to normal
  -- outside ADVANCED so the PNG frames never pull full-color shiny art
  -- into a non-REDPP mode.
  local art = artWhich(which)

  -- 1.4.0-style frame-by-frame animation: probe the frame count once,
  -- take the per-frame durations from animation_data (100ms for any frame
  -- a species' schedule doesn't cover), and load each frame on demand
  -- through the same palette pass as the static art.
  local _, count = frontFrameInfo(dex, art)
  local image = loadImage(frontPath(dex, art, 1),
    battle.data, mon.species, battle)
  if image then
    battler.sprite = playerBattleSprite(battle, battler,
      trimGround(image, "front", battle))
  end

  if not count or count <= 0 then return end

  battler.__crystalAnimation = {
    dex = dex,
    variant = art,
    species = mon.species,
    redpp = colorMode(),
    frame = 1,
    elapsed = 0,
    durations = pngFrameDurations(art, dex, count),
  }
end

local function resetEnemyAnimation(battle)
  if battle then
    resetBattlerAnimation(battle, battle.enemy)
    resetBattlerAnimation(battle, battle.enemy2)
  end
end

local function updateBattlerAnimation(battle, battler, dt)
  local mon = battler and battler.mon

  if not mon then return end

  local transformed = battler.__crystalTransformed
  local species = transformed or mon.species
  local state = battler.__crystalAnimation
  -- the variant the animation state stores: shiny collapses to normal
  -- outside ADVANCED, matching resetBattlerAnimation
  local art = transformed and "normal" or artWhich(variant(mon))

  if not state
      or state.species ~= species
      or state.variant ~= art
      or state.redpp ~= colorMode() then
    resetBattlerAnimation(battle, battler)
    state = battler.__crystalAnimation
  end

  if not state then return end
  if state.done then return end

  state.elapsed = state.elapsed + logicToReal(dt, battle.game) * 1000
  local changed = false
  local guard = 0

  while state.elapsed >= math.max(1, state.durations[state.frame] or 100)
      and guard < 50 and not state.done do
    state.elapsed = state.elapsed - math.max(1, state.durations[state.frame] or 100)
    state.frame = state.frame + 1
    if state.frame > #state.durations then
      if animMode == "once" then
        state.frame = #state.durations
        state.done = true
      else
        state.frame = 1
      end
    end
    changed = true
    guard = guard + 1
  end

  if changed then
    if state.images then
      -- PNG frames are pre-decoded images; just swap the battler's pic.
      battler.sprite = playerBattleSprite(battle, battler,
        state.images[state.frame])
    else
      local image = loadImage(frontPath(
        state.dex, state.variant, state.frame), battle.data, state.species,
        battle)
      if image then
        battler.sprite = playerBattleSprite(battle, battler,
          trimGround(image, "front", battle))
      end
    end
  end
end




local function updateEnemyAnimation(battle, dt)
  local battler = battle and battle.enemy

  if not battler or battle.showEnemyTrainer or battle.enemySendingOut then
    return
  end

  updateBattlerAnimation(battle, battler, dt)
  updateBattlerAnimation(battle, battle.enemy2, dt)
end

local function updatePlayerAnimation(battle, dt)
  if battle and not battle.showPlayerBack and not battle.sendingOut
      and not battle.safari and not battle.demo and voxelContext(battle)
      and not frontPref and mod.exports.fullBodyImage then
    for _, key in ipairs({"player", "player2"}) do
      local battler = battle[key]
      local image = battler and mod.exports.fullBodyImage(battler.mon)
      if image then
        battler.sprite = image
        battler.__crystalFullBodyImage = image
        markCrystal(image)
      elseif battler and battler.__crystalFullBodyImage then
        local mon = battler.mon
        local dex = mon and dexFor(mon.species)
        local back = dex and loadImage(backPath(dex, variant(mon)),
          battle.data, mon.species, battle)
        if back then battler.sprite = trimGround(back, "back", battle) end
        battler.__crystalFullBodyImage = nil
      end
    end
    return
  end
  if not frontPref then return end

  local battler = battle and battle.player

  -- the trainer back pic or the send-out grow takes the slot; safari and
  -- the demo never show the player's own mon
  if not battler
      or battle.safari or battle.demo
      or battle.showPlayerBack or battle.sendingOut then
    return
  end

  updateBattlerAnimation(battle, battler, dt)
  updateBattlerAnimation(battle, battle.player2, dt)
end

-- pref-aware player reset: the sprite hook already resolved the back slot
-- to the front art when the pref is on, so the animation may take it over;
-- when it is off the player keeps the static back pic and gets no state
local function resetPlayerAnimation(battle)
  if not battle or not battle.player then return end
  local mon = battle.player.mon
  battle.player.__crystalAnimation = nil
  if frontPref then
    resetBattlerAnimation(battle, battle.player)
  else
    local dex = mon and dexFor(mon.species)
    if dex then
      local image
      if colorMode() then
        image = loadImage(backPath(dex, variant(mon)),
          battle.data, mon.species, battle)
      else
        image = loadImageRaw(backGrayPath(dex))
          or loadImage(backPath(dex, artWhich(variant(mon))),
            battle.data, mon.species, battle)
      end
      if image then
        battle.player.sprite = trimGround(image, "back", battle)
      end
    end
  end
end

-- Shiny reveal detection.  Gen 1's battle wraps the mon as battle.enemy.mon;
-- on Gen 2 battle.enemy IS the mon (which carries the .shiny flag).
local function enemyIsShiny(battle)
  if not (battle and battle.enemy) then return false end
  local mon = battle.enemy.mon or battle.enemy
  return mon and isShiny(mon)
end

-- Type-colored move animations.  Gen 1's subanimation player draws each
-- move sprite through BattleState:animSpriteColors, which maps the 2bpp
-- tile's three opaque shades onto the battle zone's paper/ink -- a white
-- beam and a black outline, whatever the move.  Instead of swapping in
-- Gold's whole animation runtime (the removed GOLD ANIMATIONS bridge),
-- recolor those shades with a ramp keyed on the current move's type, so
-- Flamethrower reads fire-orange, Water Gun blue, Thunderbolt yellow and
-- so on -- the colored look Gen 2's move palettes give the same moves.
--
-- The ramp is resolved once per animation (cached on the battle, keyed by
-- animName + COLORS mode) and handed back as a shared table, so the hot
-- path -- animSpriteColors runs up to four times per sprite per frame for
-- tiles straddling a palette boundary -- allocates nothing.
local TYPE_RAMPS = {
  NORMAL       = { { 240, 240, 240 }, { 152, 152, 152 }, { 24, 24, 24 } },
  FIGHTING     = { { 240, 144, 120 }, { 200, 72, 48 },   { 120, 40, 32 } },
  FLYING       = { { 200, 168, 248 }, { 128, 96, 208 },  { 72, 56, 128 } },
  POISON       = { { 216, 136, 232 }, { 152, 64, 176 },  { 88, 40, 104 } },
  GROUND       = { { 232, 192, 136 }, { 192, 144, 80 },  { 120, 88, 48 } },
  ROCK         = { { 216, 184, 144 }, { 168, 136, 96 },  { 104, 80, 56 } },
  BUG          = { { 184, 216, 96 },  { 144, 184, 56 },  { 88, 120, 32 } },
  GHOST        = { { 168, 144, 208 }, { 104, 80, 152 },  { 56, 40, 88 } },
  FIRE         = { { 248, 208, 88 },  { 240, 96, 40 },   { 152, 32, 24 } },
  WATER        = { { 120, 200, 248 }, { 40, 112, 232 },  { 24, 48, 128 } },
  GRASS        = { { 136, 224, 120 }, { 56, 168, 80 },   { 24, 104, 40 } },
  ELECTRIC     = { { 248, 248, 120 }, { 240, 200, 40 },  { 176, 136, 24 } },
  PSYCHIC_TYPE = { { 248, 120, 168 }, { 232, 56, 120 },  { 152, 32, 88 } },
  ICE          = { { 168, 240, 240 }, { 96, 200, 224 },  { 48, 128, 160 } },
  DRAGON       = { { 144, 120, 248 }, { 88, 64, 208 },   { 48, 40, 128 } },
  -- Gen 2-only types; the Gen 1 tables never look them up.
  STEEL        = { { 224, 224, 232 }, { 136, 144, 160 }, { 64, 72, 96 } },
  DARK         = { { 168, 152, 168 }, { 104, 88, 104 },  { 40, 40, 48 } },
}

local typeRampCache = {}  -- type id -> { fwd = {3 RGB triples}, rev = {...} }

local function normalizeRamp(raw)
  local fwd = {}
  local rev = {}
  for i = 1, 3 do
    local col = raw[i]
    fwd[i] = { col[1] / 255, col[2] / 255, col[3] / 255 }
    rev[4 - i] = fwd[i]
  end
  return { fwd = fwd, rev = rev }
end

local function typeRamp(typeId)
  local hit = typeRampCache[typeId]
  if hit ~= nil then return hit or nil end
  local raw = typeId and TYPE_RAMPS[typeId]
  local out = raw and normalizeRamp(raw) or false
  typeRampCache[typeId] = out
  return out or nil
end

-- The type ramp for the move this battle is animating, or nil when the
-- current animation is not a typed move (ball toss, send-out, status
-- shakes) or the forced-mono modes are on (their frame-level re-threshold
-- flattens any color anyway, so the vanilla look is kept).
local function crystalAnimRamp(battle, name)
  if battleMono() then return nil end
  local cache = battle.__crystalAnimRamp
  local mode = PaletteFX and PaletteFX.mode
  if cache and cache.name == name and cache.mode == mode then
    return cache.ramp
  end
  local mdef = name and battle.data and battle.data.moves
    and battle.data.moves[name]
  local ramp = mdef and typeRamp(mdef.type)
  battle.__crystalAnimRamp = {
    name = name, mode = mode, ramp = ramp or false,
  }
  return ramp
end

-- The Gen 2 analogue of crystalAnimRamp.  Gold's animation runtime draws
-- every move sprite through BattleAnimView:objPalette with one of the fixed
-- battleObjects palettes -- a move like Flamethrower layers several of them
-- (flame body, highlights, smoke), each carrying its own paper + three
-- opaque shades (0-255 RGB).  Replacing every palette with one type ramp
-- collapsed that multi-palette shading into a single monochrome ramp, so
-- instead each vanilla palette is TINTED toward the move's type: entry 0
-- keeps its paper, and entries 1..3 blend the vanilla shade with the type
-- ramp's light/mid/dark at GEN2_TINT, so the per-palette hue structure
-- survives while the whole move reads as the type's color.  The tinted
-- palette is cached per (type, palette name) -- both inputs are static --
-- so the per-frame draw allocates nothing.  Gold's own mono modes (DMG /
-- CLASSIC) flatten everything downstream in GbcPalette.resolve, so no mono
-- gate is needed here.
local GEN2_TINT = 0.6

local function blendColor(a, b, t)
  return {
    math.floor(a[1] + (b[1] - a[1]) * t + 0.5),
    math.floor(a[2] + (b[2] - a[2]) * t + 0.5),
    math.floor(a[3] + (b[3] - a[3]) * t + 0.5),
  }
end

local function tintPalette(palette, ramp, t)
  return {
    palette[1],
    blendColor(palette[2], ramp[1], t),
    blendColor(palette[3], ramp[2], t),
    blendColor(palette[4], ramp[3], t),
  }
end

local gen2TintCache = {}  -- type id -> { palette name -> 4-color palette }

local function gen2TintedPalette(name, typeId, vanilla)
  local byType = gen2TintCache[typeId]
  if not byType then
    byType = {}
    gen2TintCache[typeId] = byType
  end
  local hit = byType[name]
  if hit ~= nil then return hit or nil end
  local ramp = TYPE_RAMPS[typeId]
  local out = (vanilla and ramp)
    and tintPalette(vanilla, ramp, GEN2_TINT) or false
  byType[name] = out
  return out or nil
end

-- The type of the move Gold's battle is currently drawing, or nil when the
-- animation is not a typed move (send-out, ball toss, status, the
-- after-anim shake) -- the same gate crystalAnimRamp applies on Gen 1.
-- Resolved once per runner (an animation's move id never changes) and
-- cached on it, so the hot draw path is a field read.
local function crystalGen2AnimType(screen)
  local runner = screen and screen.anim
  if not runner then return nil end
  local env = runner.env
  local animId = env and env.animId
  if not animId then return nil end
  local hit = runner.__crystalAnimType
  if hit ~= nil then return hit or nil end
  local moves = screen.game and screen.game.data
    and screen.game.data.moves
  local mdef = moves and moves[animId]
  local typeId = mdef and mdef.type
  runner.__crystalAnimType = typeId or false
  return typeId
end

if not isGen2 and type(BattleState.animSpriteColors) == "function"
    and type(BattleState.sgbBattlePals) == "function"
    and not BattleState.crystalAnimColorHook then
  BattleState.crystalAnimColorHook = true
  local innerAnimSpriteColors = BattleState.animSpriteColors
  function BattleState:animSpriteColors(s, px, py)
    -- The resting ball left on screen through the caught text is the
    -- thrown pokeball; on a successful capture it wears the caught mon's
    -- palette (Yellow-style) instead of the OBJ/zone palette.
    if self.lockedBall and not self.animPlaying then
      local pal = caughtBallPalette(self)
      if pal then return pal end
    end
    local obp = s and s.obp
    if obp == "f0" or obp == "e4" or obp == "obp1" then
      local ramp = crystalAnimRamp(self, self.animName)
      -- Only recolor where the vanilla path would color at all (the
      -- zone-palette probe stands in for inner's zoneColorsAt), so the
      -- no-zone / headless fallback still returns nil and draws raw grays.
      if ramp and self:sgbBattlePals() then
        -- f0/e4 run light->dark; obp1 ($6c) is the hardware-inverted
        -- palette, so it runs dark->light.
        return obp == "obp1" and ramp.rev or ramp.fwd
      end
    end
    return innerAnimSpriteColors(self, s, px, py)
  end
end

-- Enemy-side move animations are authored for the vanilla 160x144 layout,
-- where the field below the foe was empty ground; the engine's classic HUD
-- draws the player's name/HP box right there (top edge at screen y 56), so
-- move sprites that hang below the foe land on the name text (Gen 2's own
-- animation data centered them on the mon instead).  Lift the anim layer
-- just enough that each move's lowest sprite clears that line.  Ball tosses,
-- send-outs, status anims, and the foe's own moves keep vanilla placement.

-- The compiled sprite steps are static for the whole animation, so the
-- side test runs once per animation and is cached on the battle.
local function moveAnimShiftY(battle)
  local player = battle.animPlayer
  local name = battle.animName
  if not (battle.animPlaying and player and name) then return 0 end
  -- the widescreen layout re-anchors animations between its own anchors
  if type(battle.isWideBattleLayout) == "function"
      and battle:isWideBattleLayout() then
    return 0
  end
  local cache = battle.__crystalAnimShift
  if cache and cache.player == player and cache.name == name then
    return cache.y
  end
  local y = 0
  if battle.animAttackerIsPlayer == true then
    local md = battle.data and battle.data.moves and battle.data.moves[name]
    if md then
      local loY, hiY, loX, hiX, n = 256, -1, 256, -1, 0
      for i = 1, #player.steps do
        local sp = player.steps[i].sprites
        if sp then
          for j = 1, #sp do
            local s = sp[j]
            -- sprites parked at the OAM extremes are off-canvas
            if s.y > 0 and s.y < 160 and s.x > 0 and s.x < 168 then
              n = n + 1
              if s.y < loY then loY = s.y end
              if s.y > hiY then hiY = s.y end
              if s.x < loX then loX = s.x end
              if s.x > hiX then hiX = s.x end
            end
          end
        end
      end
      -- enemy-side moves stay in the top two-thirds (OAM y <= 112, screen
      -- y <= 96) anchored right of centre; charge anims that play over the
      -- user (FLY's TELEPORT) live bottom-left and keep vanilla placement
      if n > 0 and hiY <= 112 and (loX + hiX) / 2 >= 72 then
        -- sprite bottom edge is s.y - 8; lift until it clears the HUD top
        -- (56), capped so a full-field effect is not pushed off-screen
        local lift = 56 - hiY
        if lift < -32 then lift = -32 end
        -- A tall effect (SURF, THUNDERBOLT) already reaches the top of the
        -- screen, so the full lift pushes its top sprite off-screen.  Clamp
        -- the lift so the top sprite's top edge (s.y - 16) never crosses
        -- y = 0; the effect settles a few pixels lower instead.  When the
        -- top sprite already hangs above y = 0 on its own, leave the anim
        -- at vanilla placement rather than pushing it further up.
        if lift < 0 then
          local topLift = 16 - loY
          if lift < topLift then lift = topLift end
          if lift < 0 then y = lift end
        end
      end
    end
  end
  battle.__crystalAnimShift = { player = player, name = name, y = y }
  return y
end

if not isGen2 and type(BattleState.drawAnimLayer) == "function"
    and not BattleState.crystalAnimShiftHook then
  BattleState.crystalAnimShiftHook = true
  local innerDrawAnimLayer = BattleState.drawAnimLayer
  function BattleState:drawAnimLayer(colorized)
    local y = moveAnimShiftY(self)
    if y ~= 0 and love.graphics and love.graphics.push then
      love.graphics.push()
      love.graphics.translate(0, y)
      innerDrawAnimLayer(self, colorized)
      love.graphics.pop()
    else
      innerDrawAnimLayer(self, colorized)
    end
  end
end

local function markBattle(battle)
  if battle and enemyIsShiny(battle) then
    battle.__combinedShinyPending = true
  end
  return battle
end

-- Shared by the Gen 1 and Gen 2 reveal clocks: the delayed cry fires once
-- the sparkle audio has finished (or, with no audio, after ~90 frames).
local function revealAudioFinished()
  if not reveal.source then
    return reveal.frame >= 90
  end

  local ok, playing = pcall(reveal.source.isPlaying, reveal.source)
  return not (ok and playing)
end

-- The battle-animation and shiny-reveal system is built on the Gen 1
-- BattleState shape: Gold's battle (src/battle/gen2) constructs and
-- pushes battles in one call (no newWild), resolves its own sprites, and
-- never instantiates the Gen 1 module -- so these patches are Gen 1 only.
-- On Gen 2 the battle.started/ended events below still set the (dead)
-- shiny-pending flag; the reveal itself is gated out.
if not isGen2 then
  -- Capture the Gen 1 factories here, not at module scope: on Gold these
  -- members are absent on the adapter and reading them logs a warning.
  local originalNewWild = BattleState.newWild
  local originalNewTrainer = BattleState.newTrainer

  BattleState.newWild = function(game, species, level, opts)
    return markBattle(originalNewWild(game, species, level, opts))
  end

  BattleState.newTrainer = function(game, oppClass, partyIndex)
    return markBattle(originalNewTrainer(game, oppClass, partyIndex))
  end

  local function currentBattle()
    local ok, Game = pcall(require, "src.core.Game")
    if not ok or not Game or not Game.stack then return nil end
    local top = Game.stack:top()
    if top and top.enemy and top.game then return top end
    return nil
  end

  local function startReveal(battle, species)
    local ok, src = pcall(love.audio.newSource,
      SHINY_BASE .. "/gen2_shiny_sparkle.mp3", "static")

    reveal.battle = battle
    reveal.source = ok and src or nil
    reveal.frame = 0
    reveal.crySpecies = species
    reveal.cryPlayed = false

    battle.__combinedShinyPending = false
    battle.__combinedShinyRunning = true

    if reveal.source then
      reveal.source:setLooping(false)
      reveal.source:play()
    end
  end

  Sound.playCry = function(data, species)
    local battle = currentBattle()

    if battle
        and battle.__combinedShinyPending
        and battle.enemy
        and battle.enemy.mon
        and species == battle.enemy.mon.species
        and enemyIsShiny(battle) then
      startReveal(battle, species)
      return reveal.source
    end

    return originalPlayCry(data, species)
  end

  -- One unified BattleState.update wrapper for both animation and shiny reveal.
  BattleState.update = function(self, dt)
    local result = originalUpdate(self, dt)

    if voxelPaper then markCrystalBattlers(self) end

    -- Reset both battlers when the COLORS mode changes so the
    -- sprites are re-baked with the new mode's palette.
    local mode = PaletteFX and PaletteFX.mode
    if self.__crystalPaletteMode ~= mode then
      self.__crystalPaletteMode = mode
      resetEnemyAnimation(self)
      resetPlayerAnimation(self)
      local ti = self.__crystalTrainerInfo
      if ti then
        local img = modTrainerPic(ti.game, ti.trainer, ti.oppClass, ti.partyIndex)
        if img then self.trainerPic = img end
      end
    end

    updateEnemyAnimation(self, dt)
    updatePlayerAnimation(self, dt)

    if reveal.battle == self then
      reveal.frame = reveal.frame + logicToReal(dt, self.game) * 60

      if not reveal.cryPlayed and revealAudioFinished() then
        reveal.cryPlayed = true
        originalPlayCry(self.data, reveal.crySpecies)
        self.__combinedShinyRunning = false
      end

      if reveal.cryPlayed and reveal.frame > 180 then
        reveal.battle = nil
        reveal.source = nil
        reveal.crySpecies = nil
      end
    end

    return result
  end
end

-- ---- Gen 2: Gold's battle (src/battle/gen2 + src/ui/gen2) --------------
-- Gold's battle screen is a different class from Gen 1's, so none of the
-- BattleState patches above run there, and the battle object is separate
-- from the screen (the screen carries it as `.battle`).  These wraps sit
-- on the native Gen 2 module: the shiny reveal gets its delayed cry and
-- sparkle clock, and CUSTOM SPRITES reaches the opponent's intro
-- portrait.  The per-frame front-sprite animation itself happens inside
-- the pokemon.sprite hook above (Gold re-resolves pics every frame).
if isGen2 then
  local okBS2, BattleState2 = pcall(require, "src.ui.gen2.BattleState")

  -- The __crystalGen2Hook flag keeps hot reload safe: the module-scope
  -- install re-runs on reload, and a persisted engine class must not be
  -- wrapped a second time (the Gen 1 screen hooks use the same pattern).
  if okBS2 and type(BattleState2) == "table"
      and not BattleState2.__crystalGen2Hook then
    BattleState2.__crystalGen2Hook = true
    local originalNew2 = type(BattleState2.new) == "function"
      and BattleState2.new or nil
    local originalPlayCry2 = type(BattleState2.playCry) == "function"
      and BattleState2.playCry or nil
    local originalUpdate2 = type(BattleState2.update) == "function"
      and BattleState2.update or nil

    -- Gold draws the player's back pic at 1x into a 48px box; size the
    -- mod's trainer art to that 48px box (a 56px portrait overflows it by
    -- 8px), the Gen 2 counterpart of the Gen 1 resolveBattleScale wrap.
    if type(BattleState2.imageScale) == "function" then
      local innerImageScale2 = BattleState2.imageScale
      function BattleState2:imageScale(path)
        local s = playerBackScale(path, 48)
        if s then return s end
        return innerImageScale2(self, path)
      end
    end

    -- Type-colored move animations on Gold.  The native runtime draws each
    -- move sprite through BattleAnimView:objPalette with one of the fixed
    -- battleObjects palettes; objPalette is wrapped to tint each palette
    -- toward the current move's type rather than replacing it wholesale, so
    -- the move's own multi-palette shading survives (the battlers'
    -- PAL_BATTLE_OB_* names keep the mon's colors, and a non-move
    -- animation has no type so it stays vanilla).  drawSceneBody stashes
    -- the move's type on the view for the frame -- the move id lives on
    -- the runner, which only the screen reaches -- and clears it after,
    -- mirroring the Gen 1 subanimation coloring above.
    local okBAV, BattleAnimView = pcall(require, "src.ui.gen2.BattleAnimView")
    if okBAV and type(BattleAnimView) == "table"
        and type(BattleAnimView.objPalette) == "function"
        and not BattleAnimView.__crystalGen2AnimColorHook then
      BattleAnimView.__crystalGen2AnimColorHook = true
      local innerObjPalette = BattleAnimView.objPalette
      function BattleAnimView:objPalette(name, battle)
        local typeId = self.__crystalAnimType
        if typeId and name ~= "PAL_BATTLE_OB_ENEMY"
            and name ~= "PAL_BATTLE_OB_PLAYER" then
          local vanilla = innerObjPalette(self, name, battle)
          if vanilla then
            return gen2TintedPalette(name, typeId, vanilla)
          end
          return vanilla
        end
        return innerObjPalette(self, name, battle)
      end
    end

    if type(BattleState2.drawSceneBody) == "function" then
      local innerDrawSceneBody = BattleState2.drawSceneBody
      -- `panelFn` forwarded, not dropped.  The engine's signature is
      -- drawSceneBody(panelFn) and it builds the panel as
      -- `panelFn or function() self:drawPanel() end`, so a wrapper that takes
      -- no argument and passes none silently discards whatever the caller
      -- asked to be drawn: the engine falls back to its own drawPanel and the
      -- caller's panel never runs, with no error anywhere.  That broke
      -- BATTLE_ART_VOXEL_FORK's Gen 2 battle background, which hands a panel
      -- through here to keep the world visible behind the fight, and it would
      -- break any other mod that passes one.  A link must call the next one
      -- with the arguments it was handed.
      function BattleState2:drawSceneBody(panelFn, ...)
        local view = self.animView
        if view then view.__crystalAnimType = crystalGen2AnimType(self) end
        innerDrawSceneBody(self, panelFn, ...)
        if view then view.__crystalAnimType = nil end
      end
    end

    -- Opponent intro portrait: swap the mod's art in wherever one ships
    -- (CUSTOM SPRITES, "both" / "trainers").  The vanilla pic is resolved
    -- during new(); when the cache had none, the intro slide event was
    -- never queued, so queue it here to keep the portrait from covering
    -- the enemy slot for the whole battle.
    if originalNew2 then
      BattleState2.new = function(game, opts)
        local self = originalNew2(game, opts)
        if self and self.battle and self.battle.trainer
            and customOpponents() then
          local trainer = self.battle.trainer
          local oppClass = trainer.classId or trainer.class
          local okP, path = pcall(trainerArtPath, game, trainer, oppClass, nil)
          if okP and path then
            local hadVanilla = self.enemyTrainerImage ~= nil
            local img = modTrainerPic(game, trainer, oppClass, nil)
            if img then
              self.enemyTrainerImage = img
              self.enemyTrainerPath = path
              self.showEnemyTrainer = true
              if not hadVanilla and not self.battle.wild
                  and type(self.push) == "function" then
                local ev = { kind = "trainer-slide" }
                if #self.queue >= 1 then
                  -- after the "wants to battle!" line, like vanilla
                  table.insert(self.queue, 2, ev)
                else
                  self:push(ev)
                end
              end
            end
          end
        end
        -- The _flip convention for the player's own back pic, mirroring
        -- Gen 1's BattleState:enter wrap: a *_flip.png portrait faces the
        -- card way, so flip it for the back slot.  The tutorial's back pic
        -- is the DUDE's (ctx.demo keeps the player.sprite hook from
        -- replacing it), so it is never flipped.  Only flip (and mono-bake)
        -- when the mod's art actually landed in the slot -- with CUSTOM
        -- SPRITES on but the custom file missing, the vanilla back pic
        -- falls back in and must be left untouched.
        if self and self.playerBackImage and customPlayer()
            and playerArtPath("back", "battle") then
          if playerSpriteFlip() and not self.tutorial then
            self.playerBackImage = flipHImage(self.playerBackImage,
              playerArtPath("back", "battle"))
          end
          -- The back pic is served trueColor and drawn raw, so a mono
          -- COLOR mode needs the same DMG-ramp bake the mon sprites get.
          if gen2Mono() then
            local gray = gen2GrayImage(self.playerBackImage)
            if gray then self.playerBackImage = gray end
          end
        end
        return self
      end
    end

    -- Delayed enemy cry: a shiny enemy's send-out cry waits for the
    -- sparkle reveal instead of playing over it.  playCry(mon) is where
    -- the screen funnels every battler cry, so the player's own send-out
    -- still plays immediately (it never matches battle.enemy).
    if originalPlayCry2 then
      BattleState2.playCry = function(self, mon)
        local battle = self and self.battle
        if battle and battle.__combinedShinyPending
            and mon and battle.enemy == mon and mon.shiny then
          battle.__combinedShinyPending = false
          battle.__combinedShinyRunning = true
          reveal.battle = battle
          reveal.cryMon = mon
          reveal.crySpecies = mon.species
          reveal.cryPlayed = false
          reveal.frame = 0
          reveal.source = nil
          local ok, src = pcall(love.audio.newSource,
            SHINY_BASE .. "/gen2_shiny_sparkle.mp3", "static")
          if ok and src then
            src:setLooping(false)
            src:play()
            reveal.source = src
          end
          return
        end
        return originalPlayCry2(self, mon)
      end
    end

    -- Frame seam for the reveal clock: the screen's own update.  The
    -- overlay wrap below draws the sparkles; this advances the state and
    -- fires the deferred cry when the sparkle audio is done.
    if originalUpdate2 then
      BattleState2.update = function(self, dt)
        local result = originalUpdate2(self, dt)
        local battle = self and self.battle
        -- `battle and` guards the nil==nil case: with no reveal active
        -- and a battle-less screen the phantom clock must not spin.
        if battle and reveal.battle == battle then
          reveal.frame = reveal.frame + logicToReal(dt, self.game) * 60
          if not reveal.cryPlayed and revealAudioFinished() then
            reveal.cryPlayed = true
            originalPlayCry2(self, reveal.cryMon or battle.enemy)
            if battle then battle.__combinedShinyRunning = false end
          end
          if reveal.cryPlayed and reveal.frame > 180 then
            reveal.battle = nil
            reveal.source = nil
            reveal.crySpecies = nil
            reveal.cryMon = nil
          end
        end
        return result
      end
    end

    -- With FRONT SPRITES on, the player's back slot serves the animated
    -- FRONT frames -- the same art the enemy slot serves -- so in the
    -- player's slot (bottom left) it faces away from the opponent.  The
    -- engine draws pics unflipped, so mirror the frame image here, once
    -- per frame path: pic re-resolves a rotating path every frame, and
    -- the flipped copy is cached per path (one flip, then a lookup).
    -- The mirror is CPU ImageData work with a guaranteed fallback -- on
    -- any failure it hands back the source image, so the worst case is
    -- the original art, animated and unflipped: never a blank box,
    -- never a frozen pic.  Only the mod's own front-frame paths are
    -- touched; the enemy slot, back art, and non-crystal species pass
    -- straight through.
    local gen2BackFlipCache = {}
    local originalPic2 = type(BattleState2.pic) == "function"
      and BattleState2.pic or nil
    if originalPic2 then
      BattleState2.pic = function(self, mon, back)
        local image, trueColor, path = originalPic2(self, mon, back)
        if back and image and (isCrystalImage(image)
            or (type(path) == "string"
              and path:find(SPRITE_BASE .. "/front/", 1, true))) then
          local flipped = gen2BackFlipCache[path or image]
          if flipped == nil then
            -- Flip the FILE, not the engine's GPU image: v0.2.45 creates
            -- battle pics without CPU-readable data, and canvas readbacks
            -- crop or flicker when they run mid-draw.  If the file flip
            -- fails, flipHImage still has its getData/file fallbacks, and
            -- the last resort is the unflipped engine image -- a mon that
            -- faces the wrong way beats an invisible one.
            flipped = flipFileImage(path) or flipHImage(image, path)
            gen2BackFlipCache[path or image] = flipped or image
          end
          image = flipped or image
        end
        -- DMG/CLASSIC: the mod's battle pics are drawn raw (trueColor), so
        -- a mono mode must bake them onto the DMG ramp here -- the single
        -- seam where front and back battle pics pass as loaded images.
        -- The image returned by the Gen 2 battle state may be the player's
        -- front pic even though its path is the vanilla slot path.  Do not
        -- identify mod art by path alone: markCrystalBattlers records the
        -- actual image and the sprite hook marks every loaded Crystal frame.
        -- This is also important on Android, where path strings can be
        -- normalized differently by the asset loader.
        if image and gen2Mono() then
          if isCrystalImage(image)
              or (type(path) == "string"
                and path:find(SPRITE_BASE, 1, true)) then
            image = gen2GrayImage(image) or image
          end
        end
        -- v0.2.45's drawPic palette guard skips the GBC remap only when
        -- `trueColor and GbcPalette.mode == "gbc"`; the sprite hook set
        -- ctx.trueColor, so keep the engine's answer (don't force it here
        -- -- the mono bake above already produced a grayscale image, and
        -- drawPic must still see trueColor so the DMG/CLASSIC remap handles
        -- it like the other baked art).
        return image, trueColor, path
      end
    end

    -- Gold's dex entry page and status screen resolve their pic once per
    -- draw into a per-path cache and redraw it every frame, so animating
    -- means swapping the image at resolve time.  The entry page animates
    -- (the listing keeps its static box, matching the Gen 1 mod); the
    -- status screen always animates, in the mon's own shiny variant.
    local okDex, PokedexMenu2 = pcall(require, "src.ui.gen2.PokedexMenu")
    if okDex and type(PokedexMenu2) == "table"
        and type(PokedexMenu2.picFor) == "function"
        and not PokedexMenu2.__crystalAnimHook then
      PokedexMenu2.__crystalAnimHook = true
      local innerDexPicFor = PokedexMenu2.picFor
      PokedexMenu2.picFor = function(self, species)
        local image = innerDexPicFor(self, species)
        if image and self and self.view == "entry" then
          local dex = dexFor(species)
          if dex then
            local frame = menuFrameImageForTime(dex, "normal")
            if frame then return frame end
          end
        end
        return image
      end
      -- The mod's full-color frames must skip the GBC palette pass (it
      -- buckets by red channel and flattens them), but PokedexMenu:drawPic
      -- always routes the pic through GbcPalette.with.  Draw a crystal
      -- image raw instead -- same 7x7 box, same padding -- and leave the
      -- question-mark listing to the engine.
      local innerDexDrawPic = PokedexMenu2.drawPic
      if type(innerDexDrawPic) == "function" then
        PokedexMenu2.drawPic = function(self, row, tx, ty, ownColors)
          if row and row.seen then
            local image = self:picFor(row.species)
            if image and isCrystalImage(image) then
              local G = love.graphics
              G.setColor(1, 1, 1, 1)
              G.rectangle("fill", tx * 8, ty * 8, 7 * 8, 7 * 8)
              local tiles = math.floor(image:getWidth() / 8)
              local pad = tiles == 6 and { 1, 1 }
                or tiles == 5 and { 1, 2 } or { 0, 0 }
              G.draw(image, (tx + pad[1]) * 8, (ty + pad[2]) * 8)
              return
            end
          end
          return innerDexDrawPic(self, row, tx, ty, ownColors)
        end
      end
    end

    local okSum, SummaryMenu2 = pcall(require, "src.ui.gen2.SummaryMenu")
    if okSum and type(SummaryMenu2) == "table"
        and type(SummaryMenu2.picFor) == "function"
        and not SummaryMenu2.__crystalAnimHook then
      SummaryMenu2.__crystalAnimHook = true
      local innerSumPicFor = SummaryMenu2.picFor
      SummaryMenu2.picFor = function(self, mon)
        local image = innerSumPicFor(self, mon)
        if image and mon then
          local dex = dexFor(mon.species)
          if dex then
            local frame = menuFrameImageForTime(dex, variant(mon))
            if frame then return frame end
          end
        end
        return image
      end
      -- Same palette-pass problem on the status screen: drawPicBlock has no
      -- true-color escape, so drop the palette for a crystal image -- the
      -- block already draws raw when colors is nil.
      local innerDrawPicBlock = SummaryMenu2.drawPicBlock
      if type(innerDrawPicBlock) == "function" then
        SummaryMenu2.drawPicBlock = function(self, image, colors)
          if isCrystalImage(image) then colors = nil end
          return innerDrawPicBlock(self, image, colors)
        end
      end
    end
  end

  -- Bill's PC box list (src/ui/gen2/BoxMenu) resolves the selected mon's
  -- front pic from the patched spriteFront and colors it through
  -- GbcPalette.with -- the same pass that buckets a full-color pic by its
  -- red channel and flattens it, so the PC pic stayed static and off-color.
  -- Hand it the time-indexed Crystal frames (the dex/status pages already
  -- use the same treatment) and draw them raw by dropping the palette for a
  -- crystal image -- BoxMenu.drawPicBlock already draws raw when colors is
  -- nil, exactly like SummaryMenu.drawPicBlock.
  local okBox, BoxMenu2 = pcall(require, "src.ui.gen2.BoxMenu")
    if okBox and type(BoxMenu2) == "table"
        and type(BoxMenu2.picFor) == "function"
        and type(BoxMenu2.drawPicBlock) == "function"
        and not BoxMenu2.__crystalAnimHook then
      BoxMenu2.__crystalAnimHook = true
      local innerBoxPicFor = BoxMenu2.picFor
      BoxMenu2.picFor = function(self, mon)
        local image = innerBoxPicFor(self, mon)
        if image and mon then
          local dex = dexFor(mon.species)
          if dex then
            local frame = menuFrameImageForTime(dex, variant(mon))
            if frame then return frame end
          end
        end
        return image
      end
    local innerBoxDrawPicBlock = BoxMenu2.drawPicBlock
    if type(innerBoxDrawPicBlock) == "function" then
      BoxMenu2.drawPicBlock = function(self, image, colors)
        if isCrystalImage(image) then colors = nil end
        return innerBoxDrawPicBlock(self, image, colors)
      end
    end
    -- The no-mon left panel is the real orange block: drawPanel clears the
    -- slot with fillPicBlock(panelColors()) and panelColors answers the
    -- Bill's PC orange palette when it is called with no species (the
    -- engine's own drawPicBlock never sees a nil image, so the 2.0.3 guard
    -- here never fired).  Answer nil for that no-mon call and fillPicBlock
    -- paints the vanilla blank white instead; every with-mon caller passes
    -- a species, so the real pic palettes are untouched.
    local innerBoxPanelColors = BoxMenu2.panelColors
    if type(innerBoxPanelColors) == "function" then
      BoxMenu2.panelColors = function(self, speciesId, shiny)
        if not speciesId then return nil end
        return innerBoxPanelColors(self, speciesId, shiny)
      end
    end
  end

  -- Gold's evolution screen (src/ui/gen2/EvolutionAnim) draws the vanilla
  -- 2bpp frontpics through GbcPalette -- colored, but static and not the
  -- mod's art.  Hand it the animated Crystal frames (the dex/status pages
  -- already use the same treatment) and draw them raw, because the GbcPalette
  -- pass buckets a full-color pic by its red channel and flattens it.  The
  -- blackout flash keeps its silhouette by drawing the frame as a dark tint
  -- instead of a palette substitution; the balls of light keep the vanilla
  -- mon palette, exactly like the vanilla screen.
  local okEvo2, EvolutionAnim2 = pcall(require, "src.ui.gen2.EvolutionAnim")    if okEvo2 and type(EvolutionAnim2) == "table"
        and type(EvolutionAnim2.pic) == "function"
        and type(EvolutionAnim2.drawPic) == "function"
        and not EvolutionAnim2.__crystalAnimHook then
      EvolutionAnim2.__crystalAnimHook = true
    local innerEvoPic = EvolutionAnim2.pic
    EvolutionAnim2.pic = function(self, species)
      if species and self then
        local dex = dexFor(species)
        if dex then
          -- Both stages share the record's DVs, so one shininess flag
          -- drives both pics -- the same rule the vanilla picColors uses.
          local frame = menuFrameImageForTime(dex, variant(self.mon))
          if frame then return frame end
        end
      end
      return innerEvoPic(self, species)
    end
    local innerEvoDrawPic = EvolutionAnim2.drawPic
    function EvolutionAnim2:drawPic()
      local species = self.showNew and self.newSpecies or self.oldSpecies
      local image = self:pic(species)
      if not image or not isCrystalImage(image) then
        return innerEvoDrawPic(self)
      end
      -- Same 7x7 box and bottom-first padding as the vanilla drawPic, but
      -- drawn raw so the full-color frame keeps its own colours.
      local G = love.graphics
      local w, h = image:getDimensions()
      local box = 7 * 8
      local px = 7 * 8 + math.floor((box - w) / 2)
      local py = 2 * 8 + (box - h)
      if self.blackout then
        G.setColor(0.06, 0.06, 0.06, 1)
      else
        G.setColor(1, 1, 1, 1)
      end
      G.draw(image, px, py)
      G.setColor(1, 1, 1, 1)
    end
  end

  -- Gold's Oak speech shows the Marill demo (the demo_mon beat) from the
  -- generated frontpic -- static, and not the mod's art.  Animate it with
  -- the mod's Crystal frames and draw them raw (the GbcPalette pass buckets
  -- a full-color pic by its red channel and flattens it, the same reason
  -- the dex/status/evolution screens skip it).
  local okOak2, OakSpeech2 = pcall(require, "src.ui.gen2.OakSpeech")
  if okOak2 and type(OakSpeech2) == "table"
      and type(OakSpeech2.new) == "function"
      and type(OakSpeech2.drawPic) == "function"
      and not OakSpeech2.__crystalOakHook then
    OakSpeech2.__crystalOakHook = true
    local innerOakNew2 = OakSpeech2.new
    function OakSpeech2.new(game, opts)
      local self = innerOakNew2(game, opts)
      if self and self.demoSpecies then
        local dex = dexFor(self.demoSpecies)
        if dex then
          local frames = pngFrames(dex, "normal", nil, "gen2-oak")
          if frames and frames.images and frames.images[1] then
            local images = frames.images
            self.marillPic = images[1]
            local anim = {
              frame = 1,
              elapsed = 0,
              durations = frames.durations,
              images = images,
              byImage = {},
            }
            for i = 1, #images do
              anim.byImage[images[i]] = true
            end
            self.__crystalDemoAnim = anim
          end
        end
      end
      return self
    end
    -- Advance from drawPic: draw runs every rendered frame the speech is
    -- visible (under its text box), while update is gated behind the
    -- reveal/shrink timelines.  A crystal frame must skip GbcPalette.with,
    -- so drop picColors for those frames and let them draw raw.  The DMG /
    -- CLASSIC bake happens HERE, per draw, not in new(): GbcPalette.mode is
    -- not yet the player's COLOR choice when the speech is constructed, so
    -- a new()-time gen2Mono() gate bakes (or not) against the wrong mode.
    local innerOakDrawPic2 = OakSpeech2.drawPic
    function OakSpeech2:drawPic()
      local anim = self.__crystalDemoAnim
      if anim and self.pic and anim.byImage[self.pic] then
        local now = (love.timer and love.timer.getTime
          and love.timer.getTime()) or 0
        local dt = anim.last and (now - anim.last) or 0
        anim.last = now
        if dt > 0 and dt < 2 then
          anim.elapsed = anim.elapsed + dt * 1000
          local changed = false
          local guard = 0
          while anim.elapsed >= math.max(1, anim.durations[anim.frame] or 100)
              and guard < 50 and not anim.done do
            anim.elapsed = anim.elapsed - math.max(1, anim.durations[anim.frame] or 100)
            anim.frame = anim.frame + 1
            if anim.frame > #anim.durations then
              if animMode == "once" then
                anim.frame = #anim.durations
                anim.done = true
              else
                anim.frame = 1
              end
            end
            changed = true
            guard = guard + 1
          end
          if changed then self.pic = anim.images[anim.frame] end
        end
      end
      if self.pic and isCrystalImage(self.pic) then
        local draw = self.pic
        if gen2Mono() then
          draw = gen2GrayImage(draw) or draw
        end
        local saved = self.picColors
        self.picColors = nil
        if draw ~= self.pic then
          local real = self.pic
          self.pic = draw
          innerOakDrawPic2(self)
          self.pic = real
        else
          innerOakDrawPic2(self)
        end
        self.picColors = saved
        return
      end
      return innerOakDrawPic2(self)
    end
  end
end

-- Gen 2's trainer card and Hall of Fame both draw the player portrait as
-- a 5x7 block of tiles out of the ROM's ChrisPicAndTrainerCardGFX sheet --
-- neither path raises player.sprite -- so the mod's chosen portrait never
-- reached them.  Swap the tile draw for the mod's full-color portrait
-- (drawn unflipped, the orientation the art already has) when the player
-- side is being replaced; a missing file falls back to the vanilla tiles.
if isGen2 then
  local okTC2, TrainerCard2 = pcall(require, "src.ui.gen2.TrainerCard")
  if okTC2 and type(TrainerCard2) == "table"
      and type(TrainerCard2.drawPortrait) == "function"
      and not TrainerCard2.__crystalPortraitHook then
    TrainerCard2.__crystalPortraitHook = true
    local innerCardPortrait = TrainerCard2.drawPortrait
    function TrainerCard2:drawPortrait()
      if customPlayer() then
        local p = playerArtPath("front")
        local img = p and loadImageRaw(p)
        if img then
          if gen2Mono() then img = gen2GrayImage(img) or img end
          local w, h = img:getDimensions()
          -- 5x7-tile portrait box at (14,1).  The 56px art read too small
          -- scaled to the 40px box width and too large at native size, so
          -- target ~6 tiles (48px).  Left-align it to the box so it clears
          -- the MONEY column (a few px of the right frame get overlapped
          -- instead -- unavoidable at this width), and lift it a few px off
          -- the ground line.
          local scale = math.min((6 * 8) / w, (7 * 8) / h)
          local G = love.graphics
          G.setColor(1, 1, 1, 1)
          G.draw(img, 14 * 8, 1 * 8 + ((7 * 8) - h * scale) - 4,
            0, scale, scale)
          return
        end
      end
      innerCardPortrait(self)
    end
  end

  -- The Hall of Fame front portrait uses the same tile sheet, so draw the
  -- chosen portrait there too.  Its 7x7 box fits the 56px art natively,
  -- and drawScrolled (which pads by width and wraps the scroll registers)
  -- centres it exactly where the vanilla 5x7 face sat.
  local okHoF2, HallOfFame2 = pcall(require, "src.ui.gen2.HallOfFame")
  if okHoF2 and type(HallOfFame2) == "table"
      and type(HallOfFame2.drawPortrait) == "function"
      and type(HallOfFame2.drawScrolled) == "function"
      and not HallOfFame2.__crystalPortraitHook then
    HallOfFame2.__crystalPortraitHook = true
    local innerHoFPortrait = HallOfFame2.drawPortrait
    function HallOfFame2:drawPortrait(tileX, tileY)
      if customPlayer() then
        local p = playerArtPath("front")
        local img = p and loadImageRaw(p)
        if img then
          if gen2Mono() then img = gen2GrayImage(img) or img end
          self:drawScrolled(img, tileX, tileY, nil)
          return
        end
      end
      innerHoFPortrait(self, tileX, tileY)
    end
  end

  -- The Hall of Fame's mon pic (the party sweep) resolves the static frame
  -- 1 path from the patched def and colors it through GbcPalette.with --
  -- the same pass that buckets a full-color pic by its red channel and
  -- flattens it, so the entry sat static and off-color (the same problem
  -- the PC list had).  Hand it the time-indexed Crystal frames (the
  -- dex/status/PC pages already use the same treatment) and draw them raw
  -- by dropping the palette for a crystal image.
  local okHoFMon, HallOfFameMon = pcall(require, "src.ui.gen2.HallOfFame")
  if okHoFMon and type(HallOfFameMon) == "table"
      and type(HallOfFameMon.monPic) == "function"
      and type(HallOfFameMon.drawScrolled) == "function"
      and not HallOfFameMon.__crystalMonHook then
    HallOfFameMon.__crystalMonHook = true
    local innerHoFMonPic = HallOfFameMon.monPic
    function HallOfFameMon:monPic(mon, back)
      if not back and mon and mon.species then
        local dex = dexFor(mon.species)
        if dex then
          local frame = menuFrameImageForTime(dex, variant(mon))
          if frame then return frame end
        end
      end
      return innerHoFMonPic(self, mon, back)
    end
    local innerHoFDrawScrolled = HallOfFameMon.drawScrolled
    function HallOfFameMon:drawScrolled(image, tileX, tileY, colors)
      if isCrystalImage(image) then
        -- The full-color frames (or the DMG bake of them) must skip the
        -- GbcPalette pass; draw raw so the art keeps its own colours.  The
        -- back-pic sweep's mod art is full-color too, so bake it onto the
        -- ramp here when the mode needs it, exactly like the portrait.
        if gen2Mono() then image = gen2GrayImage(image) or image end
        colors = nil
      end
      return innerHoFDrawScrolled(self, image, tileX, tileY, colors)
    end
  end
end

-- ---- Overworld skin ------------------------------------------------------
-- OPTIONS > PLAYER SPRITE also skins the player's overworld character:
-- when a sheet named after the chosen portrait exists in
-- assets/overworld/player/, the player's on-foot sprite uses it and a
-- matching {name}_bike.png in the same folder skins the bicycle sheet.
-- Surfing keeps its own sheet.  The sheets are full-color PNGs with real
-- alpha, like the mod's battle art: under ADVANCED, OG RED / OG BLUE,
-- and Gen 2 the def clone marks trueColor to skip the engine's DMG-shade
-- palette
-- bakes, while every other COLORS mode luminance-bakes the sheet onto the
-- DMG ramp (see owBakeMode) so the zone shader recolors it like vanilla
-- art.  Every other field (frames, walker, anchors, paletteId) is copied
-- from the record it replaces, so a custom frame size still grounds like
-- the vanilla sheet.
local okSpriteRenderer, SpriteRenderer = pcall(require, "src.render.SpriteRenderer")
-- The overworld skin runtime, bundled into one table so the big install
-- closure below captures a single upvalue for it instead of three (Lua 5.1
-- caps a function at 60 upvalues).
local owSkin = { game = nil }

-- The portrait filename without the .png suffix and without the _flip
-- auto-mirror marker: red.png and red_flip.png both read "red", which is
-- how the walk sheet (red.png) and the bike sheet (red_bike.png) are named.
local function overworldSheetStem()
  return playerSpriteStem()
end

-- The player's own walk sheet is one of the overworld replacements, so it
-- follows REPLACE SPRITES: only OVERWORLD / ALL skin the on-foot sprite
-- (the other modes keep the vanilla character), instead of always swapping
-- the sheet whenever one matched the chosen portrait.
local function overworldSheetPath()
  if not customOverworld() then return nil end
  local stem = overworldSheetStem()
  if not stem then return nil end
  local p = ("%s/overworld/player/%s.png"):format(BASE, stem)
  if fileExists(p) then return p end
  return nil
end

-- The bicycle sheet, named after the walk sheet: brock.png -> brock_bike.png.
local function overworldBikeSheetPath()
  if not customOverworld() then return nil end
  local stem = overworldSheetStem()
  if not stem then return nil end
  local p = ("%s/overworld/player/%s_bike.png"):format(BASE, stem)
  if fileExists(p) then return p end
  return nil
end

-- Whether the current COLORS mode should luminance-bake the full-color
-- overworld sheets onto the engine's 3-shade DMG ramp instead of drawing
-- them raw true color.  ADVANCED keeps the raw full-color sheets.  On Gold
-- the COLOR option decides: GBC stays raw, DMG and CLASSIC bake (DMG shows
-- the ramp, CLASSIC's present pass maps it to green) -- exactly like the
-- mon sprites and trainer art.  OG RED / OG BLUE
-- (ogred on Red/Blue) stay raw too because that mode bakes a boot-ROM object
-- palette and queues a post-zone redraw; OG YELLOW (ogred on Yellow) keeps
-- the map-zone path, so it bakes exactly like SGB.  Every other Gen 1 mode
-- (SGB, OG, OG INV, SGB INV, CLASSIC) bakes too, so the map zone shader
-- recolors the sheets exactly like vanilla art.
local function owBakeMode()
  if isGen2 then return gen2Mono() end
  if not PaletteFX then return false end
  if PaletteFX.mode == "redpp" then return false end
  -- ogred only stays raw when the boot-ROM object-palette path applies
  -- (usesSpriteObp: Red/Blue, not Yellow); OG YELLOW bakes like SGB.
  if PaletteFX.usesSpriteObp and PaletteFX.usesSpriteObp() then return false end
  return true
end

local OW_SHEET_PREFIX = BASE .. "/overworld/"

-- Luminance-bake one full-color overworld sheet onto the 3-shade DMG ramp
-- (170/85/0; the sheet's own alpha is the background).  SpriteRenderer's
-- getObpImage then lifts 170 -> 255 (the OBP0 $D0 lift), 85 -> 170 and
-- 0 -> 0, and the zone shader colors those shades with the map's palette --
-- the same pipeline a vanilla 2bpp sheet rides.
local owSheetBake = {}  -- [path] = ImageData | false

local function owSheetBakeData(path)
  local hit = owSheetBake[path]
  if hit ~= nil then return hit or nil end
  local okS, id = pcall(love.image.newImageData, path)
  if not (okS and id) then
    owSheetBake[path] = false
    return nil
  end
  local okMap = pcall(function()
    id:mapPixel(function(_, _, r, g, b, a)
      if a == 0 then return r, g, b, a end
      local yy = 0.299 * r + 0.587 * g + 0.114 * b
      local v = yy > 0.5 and 170 or yy > 0.17 and 85 or 0
      return v / 255, v / 255, v / 255, a
    end)
  end)
  if not okMap then
    owSheetBake[path] = false
    return nil
  end
  owSheetBake[path] = id
  return id
end

-- getObpImage reads sheet pixels through Assets.imageData, so handing it
-- the baked ramp (a clone -- getObpImage mutates the data in place) makes
-- the engine's own recolor treat the mod's sheets exactly like vanilla 2bpp
-- art on every draw path (draw, resolveImage, drawTile) at once.
local okAssets, Assets = pcall(require, "src.render.Assets")
if okAssets and Assets and type(Assets.imageData) == "function"
    and not Assets.__crystalOwSheetHook then
  Assets.__crystalOwSheetHook = true
  local innerImageData = Assets.imageData
  function Assets.imageData(path)
    if owBakeMode() and type(path) == "string"
        and path:sub(1, #OW_SHEET_PREFIX) == OW_SHEET_PREFIX then
      local baked = owSheetBakeData(path)
      if baked then
        local okC, clone = pcall(baked.clone, baked)
        if not (okC and clone) then
          local w, h = baked:getDimensions()
          clone = love.image.newImageData(w, h)
          local okP = pcall(clone.paste, clone, baked, 0, 0, 0, 0, w, h)
          if not okP then clone = nil end
        end
        if clone then return clone end
      end
    end
    return innerImageData(path)
  end
end

local function skinDef(def, path)
  local out = {}
  for k, v in pairs(def) do out[k] = v end
  out.image = path
  out.trueColor = not owBakeMode()
  out.__crystalOw = true  -- draw-time marker: keeps trueColor synced to the mode
  return out
end

-- ---- Fishing pose ----------------------------------------------------------
-- Gen 1's fishing pose swaps the standing frame's bottom tile row for
-- Red's fishing-hands art (assets/generated/fx/red_fish_{front,back,side}
-- .png, three 16x8 strips), and OverworldState draws the far half of the
-- rod separately (assets/generated/fx/fishing_rod.png, three stacked 8x8
-- tiles).  A custom walk sheet gets that vanilla art too -- it's the only
-- art where the hands actually grip the rod -- recolored from Red's
-- grayscale shades to the character's own palette.  If the vanilla strips
-- are ever unavailable, the mod falls back to GENERATING a pose: the
-- sheet's own bottom tile row with the NEAR half of the rod pasted in
-- from the engine's rod sheet, verbatim so it continues seamlessly into
-- the far half, in every palette mode.
local generatedFishTiles = {}  -- [sheetPath] = { down, up, left = Image }
-- Gen 2's twin cache (its builder lives in the isGen2 block below); kept at
-- chunk level so the COLORS-mode switch can clear both together.
local gen2FishTiles = {}
local fishingRodSheet = nil    -- cached ImageData of the engine's rod sheet

-- Shared by both generations: recolor vanilla fishing-pose strips to a
-- custom character's palette.  sources is a table of ImageData strips
-- keyed by facing (down/up/left, one bottom tile row each); walkSheet is
-- the custom sheet whose palette they adopt, each pixel mapped to the
-- nearest color on it (squared RGB distance).  In the baked modes the
-- result goes onto the same DMG ramp buildFishingTile bakes the generated
-- rows to.  Returns { facing = Image } or nil.  A plain global on purpose:
-- the mod sandbox is isolated, and this keeps it out of the chunk's
-- 200-local budget.
function crystalFishPoseTiles(sources, walkSheet)
  local dst
  local okW, ws = pcall(love.image.newImageData, walkSheet)
  if okW and ws then
    local seen, list = {}, {}
    pcall(function()
      local w, h = ws:getWidth(), ws:getHeight()
      for y = 0, h - 1 do
        for x = 0, w - 1 do
          local r, g, b, a = ws:getPixel(x, y)
          if a > 0 then
            local key = math.floor(r * 255 + 0.5) * 65536
              + math.floor(g * 255 + 0.5) * 256
              + math.floor(b * 255 + 0.5)
            if not seen[key] then
              seen[key] = true
              list[#list + 1] = key
            end
          end
        end
      end
    end)
    if #list > 0 then dst = list end
  end
  if not dst then return nil end
  -- Nearest color in the character's palette.
  local function nearest(r, g, b)
    local br, bg, bb, bd = r, g, b, math.huge
    for i = 1, #dst do
      local key = dst[i]
      local cr = math.floor(key / 65536)
      local cg = math.floor(key / 256) % 256
      local cb = key % 256
      local dr, dg, db = cr - r, cg - g, cb - b
      local d = dr * dr + dg * dg + db * db
      if d < bd then br, bg, bb, bd = cr, cg, cb, d end
    end
    return br / 255, bg / 255, bb / 255
  end
  local function strip(id)
    local w, h = id:getWidth(), id:getHeight()
    local ok, tile = pcall(love.image.newImageData, w, h)
    if not (ok and tile) then return nil end
    local okPix = pcall(function()
      for y = 0, h - 1 do
        for x = 0, w - 1 do
          local r, g, b, a = id:getPixel(x, y)
          if a > 0 then
            local cr, cg, cb = nearest(math.floor(r * 255 + 0.5),
              math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5))
            tile:setPixel(x, y, cr, cg, cb, 1)
          end
        end
      end
    end)
    if not okPix then return nil end
    if owBakeMode() then
      local okBake = pcall(function()
        tile:mapPixel(function(_, _, r, g, b, a)
          if a == 0 then return r, g, b, a end
          local yy = 0.299 * r + 0.587 * g + 0.114 * b
          local v = yy > 0.5 and 255 or yy > 0.17 and 170 or 0
          return v / 255, v / 255, v / 255, a
        end)
      end)
      if not okBake then return nil end
    end
    local okI, img = pcall(love.graphics.newImage, tile)
    if not (okI and img) then return nil end
    img:setFilter("nearest", "nearest")
    return img
  end
  local out = {}
  for k, id in pairs(sources) do
    out[k] = strip(id)
  end
  if not (out.down or out.up or out.left) then return nil end
  return out
end

-- The engine's rod sheet, once.  Headless-safe: a missing file just means
-- no rod is pasted (the pose still shows the character's own row).
local function fishingRodData(gameData)
  if fishingRodSheet then return fishingRodSheet end
  local fx = gameData and gameData.field and gameData.field.overworldFx
  local path = fx and fx.fishingRod and fx.fishingRod.path
  if type(path) ~= "string" or path == "" then return nil end
  local ok, id = pcall(love.image.newImageData, path)
  if not (ok and id) then return nil end
  fishingRodSheet = id
  return id
end

-- One 16x8 tile: the standing frame's bottom 8 rows of the custom sheet,
-- with the rod's near half pasted over them.  rodX/rodY position the paste
-- (the rod sheet's own 8x8 tile coordinate space); rowBlock picks rod tile
-- 0 (rows 0-7, up/down) or tile 1 (rows 8-15, the sides).
local function buildFishingTile(sheetPath, frameY, frameWidth, frameHeight,
                                rod, rodX, rodY, rowBlock)
  local okS, sheet = pcall(love.image.newImageData, sheetPath)
  if not (okS and sheet) then return nil end
  local okT, tile = pcall(love.image.newImageData, 16, 8)
  if not (okT and tile) then return nil end
  local row0 = frameY + frameHeight - 8
  local okPix = pcall(function()
    for y = 0, 7 do
      for x = 0, 15 do
        local px = math.min(x, math.max(0, (frameWidth or 16) - 1))
        local r, g, b, a = sheet:getPixel(px, row0 + y)
        tile:setPixel(x, y, r, g, b, a)
      end
    end
  end)
  if not okPix then return nil end
  -- Outside ADVANCED the sheet is luminance-baked onto the DMG ramp and
  -- recolored by the zone shader, so the pose row must bake the same way or
  -- the bottom tile would sit a shade off the rest of the body.  Bake the
  -- character row to the OBP0-lifted shades (255/170/0) the sheet reaches
  -- after getObpImage; the rod is pasted RAW afterwards so its near half
  -- stays pixel-identical to the far half OverworldState draws raw.
  if owBakeMode() then
    local okBake = pcall(function()
      tile:mapPixel(function(_, _, r, g, b, a)
        if a == 0 then return r, g, b, a end
        local yy = 0.299 * r + 0.587 * g + 0.114 * b
        local v = yy > 0.5 and 255 or yy > 0.17 and 170 or 0
        return v / 255, v / 255, v / 255, a
      end)
    end)
    if not okBake then return nil end
  end
  if rod then
    -- A failed paste just leaves the character's own row (no rod); the
    -- sheet's bottom row must never be discarded for it.
    pcall(function()
      for y = 0, 7 do
        for x = 0, 7 do
          local r, g, b, a = rod:getPixel(x, rowBlock + y)
          if a > 0 then
            local tx, ty = rodX + x, rodY + y
            if tx >= 0 and tx < 16 and ty >= 0 and ty < 8 then
              tile:setPixel(tx, ty, r, g, b, a)
            end
          end
        end
      end
    end)
  end
  local okI, img = pcall(love.graphics.newImage, tile)
  if not (okI and img) then return nil end
  img:setFilter("nearest", "nearest")
  return img
end

-- The generated pose tiles for a custom walk sheet, cached per sheet.
-- The rod near-half is positioned where the far half picks up: straight
-- down for DOWN (rod tile 0, crossing the lower body), up for UP (rod tile
-- 0, at the waist toward the water above -- the vanilla up pose has the
-- rod pass behind the head, so the gap through the torso is authentic),
-- and out the side for LEFT (rod tile 1; RIGHT mirrors via the existing
-- drawTile flip).
local function overworldFishingTiles(sheetPath, gameData, frameWidth, frameHeight)
  local cached = generatedFishTiles[sheetPath]
  if cached ~= nil then return cached or nil end
  local out
  -- Primary: Red's vanilla fishing-hands strips, recolored to the custom
  -- sheet's palette -- the same treatment Gen 2's pose gets, and the only
  -- art where the hands actually grip the rod.
  local fx = gameData and gameData.field and gameData.field.overworldFx
  if fx then
    local ids = {}
    for key, name in pairs({ down = "redFishFront", up = "redFishBack",
                             left = "redFishSide" }) do
      local def = fx[name]
      local path = def and def.path
      if type(path) == "string" and path ~= "" then
        local ok, id = pcall(love.image.newImageData, path)
        if ok and id then ids[key] = id end
      end
    end
    if ids.down or ids.up or ids.left then
      out = crystalFishPoseTiles(ids, sheetPath)
    end
  end
  if not out then
    -- Fallback for missing vanilla strips / unreadable sheets: the
    -- generated pose -- the character's own bottom tile row with the
    -- rod's near half pasted in, continuing seamlessly into the far
    -- half OverworldState draws, in every palette mode.
    local rod = fishingRodData(gameData)
    local frames = { down = 0, up = 1, left = 2 }
    local poses = {
      down = { x = 4, y = 4, block = 0 },  -- near the feet, into the water below
      up   = { x = 4, y = 0, block = 0 },  -- near the waist, toward the water above
      left = { x = 0, y = 0, block = 8 },  -- out the side
    }
    out = {}
    for facing, frame in pairs(frames) do
      local pose = poses[facing]
      local img = buildFishingTile(sheetPath, frame * (frameHeight or 16),
        frameWidth, frameHeight, rod, pose.x, pose.y, pose.block)
      if img then out[facing] = img end
    end
    if not (out.down or out.up or out.left) then
      generatedFishTiles[sheetPath] = false
      return nil
    end
  end
  -- Right-facing reuses the left tile and is X-flipped by drawTile, the
  -- same convention the vanilla fishTiles table uses (so the engine's
  -- `right == left` expectations hold).
  out.right = out.left
  generatedFishTiles[sheetPath] = out
  return out
end

-- SpriteRenderer:drawTile loads its art by PATH (getImage).  The generated
-- fishing tiles are in-memory Images, so drawTile is extended to accept an
-- Image directly -- the vanilla callers keep passing path strings, so the
-- patch only changes what the mod's own tiles do.  Under ADVANCED, OG RED /
-- OG BLUE, and Gen 2 the sheet is true color, so the pose row is marked true
-- color exactly like the sheet; in the baked modes the row is already on
-- the DMG ramp (buildFishingTile), so it draws raw and rides the zone
-- shader just like the sheet does.
if okSpriteRenderer and SpriteRenderer
    and not SpriteRenderer.__crystalOwTileHook then
  SpriteRenderer.__crystalOwTileHook = true
  local innerDrawTile = SpriteRenderer.drawTile
  -- The signature must match vanilla's drawTile(path, x, y, flip, quad):
  -- Gen 2's fishing pose passes a QUAD as the fifth argument (the 16x8 pose
  -- row and the 8x8 rod tile are sub-regions of the fishing sheet), and
  -- dropping it made the whole 16x32 sheet blit over the character.
  function SpriteRenderer:drawTile(tile, x, y, flip, quad)
    if type(tile) ~= "string" then
      local iw, ih = tile:getDimensions()
      -- The in-memory tiles only ever come from the mod's generated fishing
      -- pose.  In the baked modes they are already on the DMG ramp and must
      -- ride the zone shader; only under ADVANCED / OG RED / OG BLUE /
      -- Gen 2 are they
      -- full color and exempt (the def flag can be stale, so the CURRENT
      -- mode decides, not the flag).
      if not owBakeMode() and self.def.trueColor
          and PaletteFX and PaletteFX.markTrueColor then
        PaletteFX.markTrueColor(x, y, iw, ih)
      end
      self.tileQuads = self.tileQuads or {}
      self.tileQuads[tile] = quad or self.tileQuads[tile]
        or love.graphics.newQuad(0, 0, iw, ih, iw, ih)
      local q = self.tileQuads[tile]
      -- A passed quad may be narrower than the image; vanilla mirrors by the
      -- QUAD's viewport width, so the flipped draw lands on the same spot.
      local qw = iw
      if q.getViewport then qw = select(3, q:getViewport()) or iw end
      if flip then
        love.graphics.draw(tile, q, x + qw, y, 0, -1, 1)
      else
        love.graphics.draw(tile, q, x, y)
      end
      return
    end
    return innerDrawTile(self, tile, x, y, flip, quad)
  end
end

-- The overworld skin def's trueColor is fixed at skin time, but the COLORS
-- mode can change under a live sprite (the player object survives a
-- mode-switch map reload, and NPCs can be rebuilt mid-map).  Re-sync the
-- flag at draw time for the mod's sheets -- forcing the baked getObpImage
-- path in every baked mode (never raw full color) and the raw true-color
-- path under ADVANCED / OG RED / OG BLUE / Gen 2 -- then restore it, so a
-- stale flag
-- can never pin a sheet to the wrong rendering.  This is what keeps SGB
-- (and every other baked mode) from falling back to the full-color sheet.
if okSpriteRenderer and SpriteRenderer
    and not SpriteRenderer.__crystalOwDrawHook then
  SpriteRenderer.__crystalOwDrawHook = true
  local innerDraw = SpriteRenderer.draw
  function SpriteRenderer:draw(...)
    local def = self.def
    if def and def.__crystalOw then
      local prev = def.trueColor
      def.trueColor = not owBakeMode()
      local ok, err = pcall(innerDraw, self, ...)
      def.trueColor = prev
      if not ok then error(err, 0) end
      return
    end
    return innerDraw(self, ...)
  end
  if type(SpriteRenderer.resolveImage) == "function" then
    local innerResolve = SpriteRenderer.resolveImage
    function SpriteRenderer:resolveImage()
      local def = self.def
      if def and def.__crystalOw then
        local prev = def.trueColor
        def.trueColor = not owBakeMode()
        local ok, img = pcall(innerResolve, self)
        def.trueColor = prev
        if not ok then error(img, 0) end
        return img
      end
      return innerResolve(self)
    end
  end
end

-- The two Player classes are only ever instantiated for the player
-- character (NPCs use their own class), so swapping the sprite there can
-- never touch an NPC.  Gen 1 builds all of its sprites in the constructor
-- (the walk sheet and the bike sheet are re-skinned); Gen 2 swaps the def
-- by state, so both its constructor and setSprite get the id-gated
-- substitution.
if not isGen2 then
  local Player = gen1Require("src.world.Player")
  if Player and okSpriteRenderer and SpriteRenderer
      and not Player.__crystalOwSkinHook then
    Player.__crystalOwSkinHook = true
    local innerPlayerNew = Player.new
    function Player.new(data, cx, cy, facing)
      local player = innerPlayerNew(data, cx, cy, facing)
      if player and player.sprite and player.sprite.def then
        player.__crystalOwVanilla = player.sprite.def
        local sheet = overworldSheetPath()
        player.__crystalOwWalkSheet = sheet
        if sheet then
          player.sprite = SpriteRenderer.new(
            skinDef(player.sprite.def, sheet), "player")
        end
      end
      if player and player.bikeSprite and player.bikeSprite.def then
        player.__crystalOwBikeVanilla = player.bikeSprite.def
        local bikeSheet = overworldBikeSheetPath()
        if bikeSheet then
          player.bikeSprite = SpriteRenderer.new(
            skinDef(player.bikeSprite.def, bikeSheet), "player")
        end
      end
      -- Fishing (Gen 1) patches the standing frame's bottom tile row with
      -- fishing-hands art and OverworldState draws the rod's far half.  A
      -- custom walk sheet gets Red's vanilla strips, recolored to the
      -- character's own palette (generated from the sheet only if the
      -- vanilla art is unavailable) -- so the vanilla pose machinery works
      -- for any character without separate art.
      player.__crystalOwFishVanilla = player.fishTiles
      if player.__crystalOwWalkSheet and player.sprite and player.sprite.def then
        local def = player.sprite.def
        local tiles = overworldFishingTiles(player.__crystalOwWalkSheet, data,
          def.frameWidth or 16, def.frameHeight or 16)
        if tiles then player.fishTiles = tiles end
      end
      return player
    end
  end
end

if isGen2 then
  local okPlayer2, Player2 = pcall(require, "src.world.gen2.Player")
  if okPlayer2 and Player2 and not Player2.__crystalOwSkinHook then
    Player2.__crystalOwSkinHook = true
    -- The on-foot and bike sheets are skinned: Gold swaps the player's
    -- sprite by state (SPRITE_CHRIS on foot, SPRITE_CHRIS_BIKE on the
    -- bicycle, the surf sheets otherwise), so the substitution is gated on
    -- the record's id.
    local function skinPlayerDef(def)
      if def then
        if def.id == "SPRITE_CHRIS" then
          local sheet = overworldSheetPath()
          if sheet then return skinDef(def, sheet) end
        elseif def.id == "SPRITE_CHRIS_BIKE" then
          local sheet = overworldBikeSheetPath()
          if sheet then return skinDef(def, sheet) end
        end
      end
      return def
    end
    local function stashVanilla(player, def)
      if player and def and not player.__crystalOwVanilla
          and def.id == "SPRITE_CHRIS" then
        player.__crystalOwVanilla = def
      end
      if player and def and not player.__crystalOwBikeVanilla
          and def.id == "SPRITE_CHRIS_BIKE" then
        player.__crystalOwBikeVanilla = def
      end
    end
    local innerPlayerNew = Player2.new
    function Player2.new(cx, cy, facing, spriteDef)
      local player = innerPlayerNew(cx, cy, facing, skinPlayerDef(spriteDef))
      stashVanilla(player, spriteDef)
      return player
    end
    local innerSetSprite = Player2.setSprite
    function Player2:setSprite(spriteDef)
      stashVanilla(self, spriteDef)
      return innerSetSprite(self, skinPlayerDef(spriteDef))
    end
    -- Fishing with a CUSTOM walk sheet: vanilla's pose strip is Chris's own
    -- hands-and-body art.  Serve that vanilla pose for custom characters
    -- too -- it's the only art where the hands actually grip the rod --
    -- but recolor it from Chris's palette to the custom sheet's (nearest
    -- RGB per pixel), so every character fishes with the authentic
    -- hands-together pose in their own colors.  Vanilla sheets keep
    -- vanilla.
    local GEN2_ROD_OAM = {
      down  = { dx =  0, dy = 16, tile = 0 },
      up    = { dx =  0, dy = -8, tile = 0 },
      left  = { dx = -8, dy =  5, tile = 1, flip = true },
      right = { dx = 16, dy =  5, tile = 1 },
    }
    local gen2FishRod = nil   -- ImageData of the vanilla fishing sheet
    local function gen2FishRodData(fishPath)
      if gen2FishRod then return gen2FishRod end
      local ok, id = pcall(love.image.newImageData, fishPath)
      if not (ok and id) then return nil end
      gen2FishRod = id
      return id
    end
    -- The vanilla strip already carries the hands, the handle, and the body
    -- shape that connect to the loose rod tile at ROD_OAM's offsets, so
    -- serving it per character needs no pasted stubs at all -- only the
    -- shared recolor from Chris's palette to the custom sheet's.
    local function gen2FishingTiles(walkSheet, fishPath)
      local cached = gen2FishTiles[walkSheet]
      if cached ~= nil then return cached or nil end
      local fishId = gen2FishRodData(fishPath)
      if not fishId then
        gen2FishTiles[walkSheet] = false
        return nil
      end
      -- Crop the three pose rows out of the fishing sheet (FISH_ROW,
      -- engine/events/fishing_gfx.asm) and recolor them with the shared
      -- helper; right reuses left's row, X-flipped by drawTile.
      local ids = {}
      for key, row in pairs({ down = 0, up = 1, left = 2 }) do
        local ok, id = pcall(love.image.newImageData, 16, 8)
        if ok and id then
          pcall(id.paste, id, fishId, 0, 0, 0, row * 8, 16, 8)
          ids[key] = id
        end
      end
      local out = (ids.down or ids.up or ids.left)
        and crystalFishPoseTiles(ids, walkSheet) or nil
      if not out then
        gen2FishTiles[walkSheet] = false
        return nil
      end
      out.right = out.left  -- X-flipped by drawTile, same as vanilla
      gen2FishTiles[walkSheet] = out
      return out
    end
    local innerDrawFishing = Player2.drawFishing
    function Player2:drawFishing(yOffset)
      local def = self.sprite and self.sprite.def
      if not (def and def.__crystalOw)
          or type(self.fishSheet) ~= "string" then
        return innerDrawFishing(self, yOffset)
      end
      local tiles = gen2FishingTiles(def.image, self.fishSheet,
        self.sprite.frameWidth or 16, self.sprite.frameHeight or 16)
      if not tiles then
        return innerDrawFishing(self, yOffset)
      end
      local sprite = self.sprite
      local py = self.py + (yOffset or 0)
      local facing = self.facing
      sprite:draw(self.px, py, 0, 0, facing, 0, false, true)
      self.fishQuads = self.fishQuads or { rod = {} }
      for i = 0, 1 do
        self.fishQuads.rod[i] = self.fishQuads.rod[i]
          or love.graphics.newQuad(i * 8, 24, 8, 8, 16, 32)
      end
      local sx, sy = sprite:getScreenOrigin(self.px, py, 0, 0)
      sprite:drawTile(tiles[facing] or tiles.down, sx,
        sy + math.max(0, (sprite.frameHeight or 16) - 8),
        facing == "right")
      local oam = GEN2_ROD_OAM[facing] or GEN2_ROD_OAM.down
      sprite:drawTile(self.fishSheet, sx + oam.dx, sy + oam.dy, oam.flip,
        self.fishQuads.rod[oam.tile])
    end
  end
end

-- The live player character, wherever the current generation keeps it.
-- On Gen 1 the overworld controller sits on the state stack (battle states
-- expose .player too -- the player's mon -- but those carry an Image, not
-- a SpriteRenderer, so the def-shaped guard tells them apart).  On Gen 2
-- the world is Game.world, off the stack.
local function livePlayer()
  local game = owSkin.game
  if not game then return nil end
  local player
  if isGen2 then
    player = game.world and game.world.player
  elseif game.stack and game.stack.states then
    local states = game.stack.states
    for i = #states, 1, -1 do
      local p = states[i] and states[i].player
      if p and p.sprite and p.sprite.def then player = p break end
    end
  end
  return player
end

-- Re-apply the skin to the live player when PLAYER SPRITE changes in the
-- OPTION screen (the next player construction picks it up anyway, but the
-- character on screen should change now).  With no matching sheet the
-- vanilla sheet comes back.
local function reskinLivePlayer()
  local player = livePlayer()
  if not player then return end
  local def = player.sprite and player.sprite.def
  if not def then return end
  if isGen2 then
    -- Re-run the setSprite hook against the remembered vanilla record so
    -- the current PLAYER SPRITE choice skins whichever state (walk or
    -- bike) the player is in right now.
    if type(player.setSprite) ~= "function" then return end
    if def.id == "SPRITE_CHRIS" and player.__crystalOwVanilla then
      player:setSprite(player.__crystalOwVanilla)
    elseif def.id == "SPRITE_CHRIS_BIKE" and player.__crystalOwBikeVanilla then
      player:setSprite(player.__crystalOwBikeVanilla)
    end
  elseif SpriteRenderer then
    local vanilla = player.__crystalOwVanilla
    local sheet = overworldSheetPath()
    if vanilla then
      player.sprite = SpriteRenderer.new(
        sheet and skinDef(vanilla, sheet) or vanilla, "player")
    end
    if player.bikeSprite and player.bikeSprite.def then
      local bikeVanilla = player.__crystalOwBikeVanilla
        or player.bikeSprite.def
      local bikeSheet = overworldBikeSheetPath()
      player.bikeSprite = SpriteRenderer.new(
        bikeSheet and skinDef(bikeVanilla, bikeSheet) or bikeVanilla,
        "player")
    end
    -- The fishing pose follows the walk sheet: a custom sheet gets Red's
    -- fishing-hands strips recolored to its palette, the vanilla sheet
    -- keeps (or gets back) Red's pose untouched.
    player.__crystalOwWalkSheet = sheet
    if player.__crystalOwFishVanilla then
      if sheet then
        local def = player.sprite and player.sprite.def
        local tiles = overworldFishingTiles(sheet,
          owSkin.game and owSkin.game.data,
          (def and def.frameWidth) or 16, (def and def.frameHeight) or 16)
        player.fishTiles = tiles or nil
      else
        player.fishTiles = player.__crystalOwFishVanilla
      end
    end
  end
end

-- ---- Overworld trainer sprites -------------------------------------------
-- REPLACE SPRITES' OVERWORLD / ALL modes also replace the overworld NPC
-- sheets from assets/overworld/trainers/, keyed by the trainer CLASS
-- first (OPP_BROCK -> brock.png -- Gen 1 leaders reuse generic sprite
-- records, so the class is the only name that matches) then by the
-- sprite record (SPRITE_BROCK.png, sprite_brock.png or brock.png).
-- Like the player skin, sheets are full-color 16x96 PNGs with
-- transparency and the def clone marks trueColor.  Both generations
-- build NPCs through their own NPC class (which is NPC-only -- the
-- player uses its own class), so the swap cannot touch the player.
-- NPCs whose sprite another mod rebuilt (followers, overworld wilds)
-- are never adopted, so the options cannot clobber them.
local function overworldTrainerPath(spriteId)
  if not customOverworld() then return nil end
  if type(spriteId) ~= "string" or spriteId == "" then return nil end
  local base = ("%s/overworld/trainers/"):format(BASE)
  local plain = spriteId:lower()
  return firstExistingPath(
    base .. spriteId .. ".png",
    base .. plain .. ".png",
    base .. plain:gsub("^sprite_", "") .. ".png")
end

-- The sheet key for an NPC, trainer class first: Gen 1 gym leaders reuse
-- generic sprite records (Brock's map object is SPRITE_SUPER_NERD), so
-- the class OPP_BROCK -> brock.png is the only name that matches the
-- user's sheets.  The sprite record id stays the fallback (SPRITE_BLUE
-- -> blue.png for the rival, SPRITE_LORELEI -> lorelei.png for the E4).
local function npcTrainerPath(npc, id)
  if not customOverworld() then return nil end
  local cls = npc and npc.def and npc.def.trainerClass
  if type(cls) == "string" and cls ~= "" then
    local p = overworldTrainerPath(cls:gsub("^OPP_", ""):lower())
    if p then return p end
  end
  return overworldTrainerPath(id)
end

-- The sprite id for an NPC, preferring the def's own id (Gold's variable
-- sprites keep a SPRITE_VARS byte in .def.sprite rather than a name).
local function npcSpriteId(npc, def)
  local d = def or (npc and npc.sprite and npc.sprite.def)
  local id = d and d.id
  if type(id) == "string" and id ~= "" then return id end
  local raw = npc and npc.def and npc.def.sprite
  if type(raw) == "string" and raw ~= "" then return raw end
  return nil
end

-- Rebuild one NPC's sprite from its remembered vanilla record, skinning it
-- when overworld mode is on and a sheet exists, restoring it otherwise.
-- An NPC is only ever ADOPTED while its sprite is still the vanilla
-- registry record (sprites[id]); a sprite another mod rebuilt -- Yellow's
-- follower, overworld-wilds trailers -- is foreign and left untouched, so
-- cycling the option can never clobber it.  The adoption also waits for a
-- matching sheet, so a placeholder sprite that is about to be replaced
-- (the wilds NPCs construct with SPRITE_PIKACHU and swap in real art
-- right after) is never remembered as vanilla.
local function reskinNpc(npc, sprites)
  if not (npc and SpriteRenderer) then return end
  local cur = npc.sprite and npc.sprite.def
  if not cur then return end
  local objDef = npc.def
  local id = objDef and objDef.sprite
  local record = sprites and type(id) == "string" and sprites[id]
  local vanilla = npc.__crystalOwVanilla
  if not vanilla then
    if not (record and cur == record) then return end
    local path = npcTrainerPath(npc, id)
    if not path then return end
    vanilla = cur
    npc.__crystalOwVanilla = vanilla
    npc.sprite = SpriteRenderer.new(skinDef(vanilla, path), npc.id)
    if npc.spriteDef ~= nil then npc.spriteDef = npc.sprite.def end
    return
  end
  local path = npcTrainerPath(npc, id)
  local want = path and skinDef(vanilla, path) or vanilla
  if want ~= cur then
    npc.sprite = SpriteRenderer.new(want, npc.id)
    if npc.spriteDef ~= nil then npc.spriteDef = want end
  end
end

if not isGen2 then
  local NPC = gen1Require("src.world.NPC")
  if NPC and okSpriteRenderer and SpriteRenderer
      and not NPC.__crystalOwNpcHook then
    NPC.__crystalOwNpcHook = true
    local innerNpcNew = NPC.new
    function NPC.new(data, mapId, objDef)
      local npc = innerNpcNew(data, mapId, objDef)
      reskinNpc(npc, data and data.sprites)
      return npc
    end
  end
end

if isGen2 then
  -- The module file is Npc.lua; the wrong case only resolves on a
  -- case-insensitive filesystem, so use the exact name.
  local okNpc2, NPC2 = pcall(require, "src.world.gen2.Npc")
  if okNpc2 and NPC2 and not NPC2.__crystalOwNpcHook then
    NPC2.__crystalOwNpcHook = true
    -- Substitute a skin when overworld mode is on and a sheet matches.
    -- The vanilla record is remembered only when a skin is actually
    -- applied, so a def another mod supplied (followers, overworld
    -- wilds) is never adopted and a mode change can't clobber it.  Gold
    -- repaints variable sprites through setSpriteDef, so that path gets
    -- the same substitution as fresh construction.
    local function substitute(def, npc)
      if not def then return def end
      local path = npcTrainerPath(npc, npcSpriteId(npc, def))
      if path then
        if npc then npc.__crystalOwVanilla = def end
        return skinDef(def, path)
      end
      return def
    end
    local innerNpcNew = NPC2.new
    function NPC2.new(mapId, objDef, spriteDef)
      local skinned = substitute(spriteDef, nil)
      local npc = innerNpcNew(mapId, objDef, skinned)
      if npc and skinned ~= spriteDef then
        npc.__crystalOwVanilla = spriteDef
      end
      return npc
    end
    local innerSetSprite = NPC2.setSpriteDef
    function NPC2:setSpriteDef(spriteDef)
      return innerSetSprite(self, substitute(spriteDef, self))
    end
  end
end

-- The live world/overworld state, wherever the current generation keeps it.
local function liveWorld()
  local game = owSkin.game
  if not game then return nil end
  if isGen2 then return game.world end
  if game.stack and game.stack.states then
    local states = game.stack.states
    for i = #states, 1, -1 do
      local s = states[i]
      if s and s.npcs then return s end
    end
  end
  return nil
end

-- Re-skin (or restore) the overworld NPCs currently on screen when
-- REPLACE SPRITES changes in the OPTION screen.  The same NPC can appear
-- in both npcs and npcPool, so each is handled once.
local function reskinLiveOverworld()
  local world = liveWorld()
  if not world then return end
  -- The vanilla-record identity check (reskinNpc) needs the registry the
  -- NPCs were built from.
  local sprites = owSkin.game and owSkin.game.data
    and owSkin.game.data.sprites
  local seen = {}
  local function skin(npc)
    if not npc or seen[npc] then return end
    seen[npc] = true
    if isGen2 then
      if npc.__crystalOwVanilla and type(npc.setSpriteDef) == "function" then
        npc:setSpriteDef(npc.__crystalOwVanilla)
      end
    else
      reskinNpc(npc, sprites)
    end
  end
  for _, npc in ipairs(world.npcs or {}) do skin(npc) end
  for _, npc in pairs(world.npcPool or {}) do skin(npc) end
end

-- The install closure reaches the live re-skins through this one table.
owSkin.player = reskinLivePlayer
owSkin.overworld = reskinLiveOverworld


-- Sparkle rendering.
local function drawSparkleFrame(x, y, frame, scale)
  if not loadSparkles() then return end

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(
    sparkleImage,
    sparkleQuads[frame],
    math.floor(x),
    math.floor(y),
    0,
    scale or 1,
    scale or 1,
    8,
    8
  )
end

local function sparkleFrame(age)
  if age < 0 or age >= 24 then return nil end
  if age < 4 then return 1 end
  if age < 9 then return 2 end
  if age < 15 then return 3 end
  if age < 20 then return 4 end
  return 1
end

-- The sparkle positions/timings are fixed, so keep them as one shared
-- table rather than rebuilding the seven sub-tables every reveal frame
-- (drawReveal runs each battle frame while the reveal is playing).
local REVEAL_SEQUENCE = {
  {  6, 112, 22, 1 },
  { 14, 132, 28, 1 },
  { 22, 138, 48, 1 },
  { 30, 122, 59, 1 },
  { 38, 101, 52, 1 },
  { 46,  98, 33, 1 },
  { 54, 116, 39, 2 },
}

local function drawReveal(battle)
  if reveal.battle ~= battle or reveal.cryPlayed then return end

  local t = reveal.frame

  for _, item in ipairs(REVEAL_SEQUENCE) do
    local frame = sparkleFrame(t - item[1])
    if frame then
      drawSparkleFrame(item[2], item[3], frame, item[4])
    end
  end
end

-- ---- install steps --------------------------------------------------
-- The init closure below references nearly every helper in this file,
-- and Lua 5.1 caps a single function at 60 upvalues -- the mod once hit
-- "function ... has more than 60 upvalues" and failed to load -- so the
-- big self-contained blocks live in small module-scope functions and
-- the init just calls them.

-- COLORS-mode cache resets: hot reload wipes every baked-image cache so
-- the next frame re-resolves through the new pack.
local function resetCaches(event)
  if event and event.reason == "colors" then
    imageCache = {}
    monoBaked = setmetatable({}, { __mode = "k" })
    ballBaked = {}
    pngAnimCache = {}
    lumaPngCache = {}
    trimCache = setmetatable({}, { __mode = "k" })
    frontFrameCache = {}
    animStart = {}
    menuFrameImages = {}
    menuFrameImageCount = 0
    owSheetBake = {}
    generatedFishTiles = {}
    fishingRodSheet = nil
    if gen2FishTiles then
      for k in pairs(gen2FishTiles) do gen2FishTiles[k] = nil end
    end
    -- The player object survives a map reload, so its sprite def (and the
    -- generated fishing pose) still carry the pre-switch mode.  Re-skin it
    -- now -- NPCs are rebuilt by the reload itself -- so the on-foot, bike
    -- and fishing sheets flip between raw full color and the DMG bake.
    owSkin.player()
    owSkin.overworld()
  end
end

-- The player's battle back pic (the chosen portrait or a dedicated back
-- sprite) is full-color art served through the player.sprite hook.  In
-- every non-ADVANCED mode it must be luminance-baked onto the mode's
-- MEWMON display colors -- the same treatment modTrainerPic gives the
-- opponent portrait -- or the engine's recolor passes flatten the shading
-- (the red-channel quantize over the zone pass, the frame-level mono
-- remap).  Baked once per (image, mode) from a private pixel readback, so
-- the per-frame draw path is a table lookup; the weak key drops the entry
-- with the image.  Deliberately not registered in resetCaches: a COLORS
-- change re-bakes because the mode is part of the key, and each live
-- image holds at most one entry.
local lumaTrainerCache = setmetatable({}, { __mode = "k" })

local function lumaTrainerBackPic(battle, img)
  local mode = PaletteFX and PaletteFX.mode
  local hit = lumaTrainerCache[img]
  if hit and hit[1] == mode then return hit[2] or nil end
  local out = false
  local colors = modePalette(battle and battle.data, "MEWMON", mode)
  if colors then
    local id = readPixels(img)
    if id then
      local okM = pcall(function()
        id:mapPixel(function(_, _, r, g, b, a)
          if a == 0 then return r, g, b, a end
          local yy = 0.299 * r + 0.587 * g + 0.114 * b
          local col = yy > 0.83 and colors[1] or yy > 0.5 and colors[2]
            or yy > 0.17 and colors[3] or colors[4]
          return col[1] / 255, col[2] / 255, col[3] / 255, a
        end)
      end)
      if okM then
        local okN, baked = pcall(love.graphics.newImage, id)
        if okN and baked then
          baked:setFilter("nearest", "nearest")
          markCrystal(baked)
          out = baked
        end
      end
    end
  end
  lumaTrainerCache[img] = { mode, out }
  return out or nil
end

-- The staged-battle (voxel) mono bakes for pics and the party-ball row,
-- plus the player back-pic luminance bake for every other non-ADVANCED
-- mode.
local function installMonoHooks()
  if not BattleState.crystalMonoPicHook then
    BattleState.crystalMonoPicHook = true
    local innerPic = BattleState.picImage
    function BattleState:picImage(img)
      if battleMono() and not self.grayPics then
        local staged = voxelContext(self)
        if not staged then
          -- mono 2D battle: the frame-level mono remap buckets by red
          -- channel, so the full-color back pic needs a luminance bake
          -- first (the staged path below bakes via bakeStagedPic; the
          -- forced-mono modes exclude REDPP by definition)
          if img == self.playerBackPic and self.__crystalCustomBack then
            local baked = lumaTrainerBackPic(self, img)
            if baked then return baked end
          end
          return img
        end
        -- Mono 3D (voxel) battle: bakeStagedPic skips the mod's own
        -- art (it is marked crystal), but the back pic is loaded raw
        -- full-color (trueColor) and has never been baked, so it needs
        -- the same luminance bake the 2D mono path does above.
        if img == self.playerBackPic and self.__crystalCustomBack then
          local baked = lumaTrainerBackPic(self, img)
          if baked then return baked end
        end
        local out = innerPic(self, img)
        return bakeStagedPic(out)
      end
      local out = innerPic(self, img)
      -- The engine loaded the back pic raw (trueColor), so the palette
      -- passes leave it unchanged; bake it onto the mode's MEWMON colors
      -- when it is the mod's own art and inner's picImage did not
      -- transform it (out == img: no blackout silhouette, no BGP fade).
      if out == img and not colorMode() and img == self.playerBackPic
          and self.__crystalCustomBack then
        local baked = lumaTrainerBackPic(self, img)
        if baked then return baked end
      end
      return out
    end
  end

  if not BattleState.crystalBallRowHook then
    BattleState.crystalBallRowHook = true
    local innerBallRow = BattleState.drawBallRow
    function BattleState:drawBallRow(party, x, y, dx)
      -- The Gen 3 UI overhaul owns the party-ball display (its HD pods draw
      -- for both sides and the vanilla row is left running underneath); skip
      -- ours entirely so the two don't stack a duplicate row.
      if gen3BattleUI() then return end
      if not self.grayPics then
        local imgs = bakeBallRow(party)
        if imgs then
          if self:colorMode() then
            -- Colorized pipeline: the zone pass would recolor the bake onto
            -- the HP-bar palette, so skip the HUD draw and re-draw the row in
            -- battle.overlay on top of the finished frame.  The snapped voxel
            -- path never reaches here (hudTexture shadows colorMode to false),
            -- so those balls still draw straight into the HUD layer and keep
            -- their colours in the world image.
            recordBallOverlay(imgs, x, y, dx)
            return
          end
          if voxelContext(self) then
            -- Mono voxel battles have no zone pass; the DMG-ramp bake draws
            -- straight into the HUD.
            local g = love.graphics
            g.setColor(1, 1, 1, 1)
            for i = 1, 6 do
              g.draw(imgs[i], x + (i - 1) * dx, y)
            end
            return
          end
        end
      end
      return innerBallRow(self, party, x, y, dx)
    end
  end
end

-- DRAMATIC SHAPE / BATTLE_ART_VOXEL_FORK keep the Crystal art's own
-- transparency instead of sealing its bottom rows onto paper.
local function voxelPaperCompat()
  if voxelPaper then return true end
  local voxel = voxelMod()
  local lib = voxel and voxel.lib
  if not (lib and lib.require) then return false end
  local okBP, BattlePics = pcall(lib.require, "BattlePics")
  if not (okBP and BattlePics
          and type(BattlePics.filled) == "function"
          and not BattlePics.crystalTransparencyHook) then
    return false
  end
  local innerFilled = BattlePics.filled
  function BattlePics.filled(img, sealBottom)
    if isCrystalImage(img) then return img end
    return innerFilled(img, sealBottom)
  end
  BattlePics.crystalTransparencyHook = true
  voxelPaper = true
  mod.log:info(
    "DRAMATIC SHAPE: crystal transparency kept in staged battles")
  return true
end

local function exportHelpers()
  if not mod.exports.stagedPokemonSprite then
    local provider = V.require("Crystal/full_body")
    mod.exports.stagedPokemonSprite = provider(mod, dexFor, isShiny)
  end
  mod.exports.isShinyRevealPlaying = function()
    return reveal.battle ~= nil and not reveal.cryPlayed
  end

  mod.exports.logicToReal = logicToReal

  mod.exports.frontPrefEnabled = function()
    return frontPref
  end

  mod.exports.customTrainersMode = function()
    return trainerMode
  end

  mod.exports.colorMode = colorMode

  mod.exports.dexFor = dexFor

  mod.exports.hasCrystalArt = hasCrystalArt

  mod.exports.frontHookPath = frontHookPath

  -- pure helper (no love needed): testable in the headless harness
  mod.exports.advanceMenuSprite = advanceMenuSprite

  mod.exports.battleMono = battleMono

  mod.exports.monoDisplayColors = monoDisplayColors

  mod.exports.artVariantForMode = artVariantForMode

  mod.exports.artWhich = artWhich

  mod.exports.trainerPicName = trainerPicName

  mod.exports.playerArtPath = playerArtPath
  mod.exports.listPlayerSprites = listPlayerSprites
  mod.exports.overworldSheetPath = overworldSheetPath
  mod.exports.overworldBikeSheetPath = overworldBikeSheetPath
  mod.exports.overworldTrainerPath = overworldTrainerPath
  mod.exports.pngWidth = pngWidth

  mod.exports.isCrystalImage = isCrystalImage

  mod.exports.markCrystalBattlers = markCrystalBattlers

  mod.exports.bakeStagedPic = bakeStagedPic

  mod.exports.ballTile = ballTile

  mod.exports.ballShade = ballShade
end

return function()
  -- Reset hook flags so hot reload always picks up current code.
  BattleState.crystalMonoPicHook = nil
  BattleState.crystalBallRowHook = nil
  BattleState.crystalTrainerPicHook = nil

  mod.hooks:wrap("battle.overlay", function(next, screen)
    next(screen)
    -- Gen 1 raises the hook with the battle screen, which IS the battle;
    -- Gen 2 passes the screen, which carries the battle as `.battle`.
    local battle = (isGen2 and screen and screen.battle) or screen
    drawReveal(battle)
    -- Party balls recorded by the drawBallRow hook (colorized battles) draw
    -- here, on top of the finished frame, so the zone pass cannot recolor
    -- them; a no-op on every other path.
    drawOverlayBalls()
  end, 980)

  -- save.created fires for the boot skeleton (before game.ready) AND for a
  -- genuine New Game (after game.ready, once the title/menu hands off).
  -- Only the latter should reset the portrait to Red; the boot copy must
  -- keep the persisted choice or a CONTINUE builds the overworld player
  -- with the wrong sheet before save.loaded can correct it.  gameReady
  -- is derived from owSkin.game so a hot-reloaded install that runs after
  -- the boot handshake still knows New Game from the boot skeleton.
  local gameReady = owSkin.game ~= nil

  -- keep the FRONT SPRITES pref in step with the real save (game.ready's
  -- save is a skeleton; save.created / save.loaded carry the player's)
  local function readFrontPref(save)
    frontPref = save
                and save.options
                and save.options.crystalFront
                or false
  end

  -- REPLACE SPRITES defaults to "both": a save that predates the option
  -- (or a skeleton save with no options yet) must not silently change
  -- what it shows.  Anything that is not one of the three modes -- nil,
  -- or a legacy boolean from the pre-1.6 toggle -- reads as "both".
  local function readCustomTrainersPref(save)
    local v = save and save.options and save.options.crystalTrainers
    if v == "player" or v == "trainers" or v == "none"
        or v == "both" or v == "overworld" or v == "all" then
      trainerMode = v
    else
      trainerMode = "both"
    end
  end

  local function readPlayerSpritePref(save)
    local v = save and save.options and save.options.crystalPlayerSprite
    if type(v) == "string" and v ~= "" then
      playerSprite = v
    else
      playerSprite = DEFAULT_PLAYER_SPRITE
    end
  end

  -- BATTLE PIC defaults to "front" so a save that predates the option
  -- (or a skeleton save) keeps showing the front portrait in battle.
  local function readBattlePicPref(save)
    local v = save and save.options and save.options.crystalBattlePic
    battlePicPref = (v == "back") and "back" or "front"
  end

  -- ANIMATIONS defaults to "loop" so a save that predates the option
  -- (or a skeleton save) keeps cycling the sprites as before.
  local function readAnimModePref(save)
    local v = save and save.options and save.options.crystalAnimations
    animMode = (v == "once") and "once" or "loop"
  end

  mod.exports.playerSprite = function()
    return playerSprite
  end

  mod.exports.playerSpriteFlip = function()
    return playerSpriteFlip()
  end

  mod.exports.applyOption = function(key, val)
    if key == "crystalFront" then
      frontPref = val
    elseif key == "crystalTrainers" then
      trainerMode = val
      owSkin.player()
      owSkin.overworld()
    elseif key == "crystalPlayerSprite" then
      playerSprite = val
      owSkin.player()
    elseif key == "crystalBattlePic" then
      battlePicPref = (val == "back") and "back" or "front"
    elseif key == "crystalAnimations" then
      animMode = (val == "once") and "once" or "loop"
    end
  end

  mod.events:on("game.ready", function(event)
    gameReady = true
    owSkin.game = event and event.game
    local game = event and event.game
    readFrontPref(game and game.save)
    readCustomTrainersPref(game and game.save)
    readPlayerSpritePref(game and game.save)
    readBattlePicPref(game and game.save)
    readAnimModePref(game and game.save)
    syncTrueColor()
  end)

  mod.events:on("save.created", function(event)
    readFrontPref(event and event.save)
    readCustomTrainersPref(event and event.save)
    local save = event and event.save
    readBattlePicPref(save)
    readAnimModePref(save)
    if gameReady then
      -- a brand-new game always starts with the game's own default
      -- portrait (Red on Gen 1, Gold's trainer on Gen 2): the engine's
      -- options are global and survive New Game, so without this a fresh
      -- profile would inherit the last sprite picked on another profile.
      -- The other options carry over as usual.
      playerSprite = DEFAULT_PLAYER_SPRITE
      if save and save.options then
        save.options.crystalPlayerSprite = DEFAULT_PLAYER_SPRITE
      end
    else
      -- boot skeleton: keep the persisted choice
      readPlayerSpritePref(save)
    end
    syncTrueColor()
  end)

  mod.events:on("save.loaded", function(event)
    readFrontPref(event and event.save)
    readCustomTrainersPref(event and event.save)
    readPlayerSpritePref(event and event.save)
    readBattlePicPref(event and event.save)
    readAnimModePref(event and event.save)
    syncTrueColor()
    -- The overworld (world/NPCs and the player) is already standing by the
    -- time save.loaded fires, so re-apply the skins from the freshly read
    -- prefs -- a CONTINUE then shows the saved choices without a manual
    -- option toggle.  resetCaches clears every baked-image cache too, so a
    -- freshly loaded save never serves a grayscale bake a previous session's
    -- COLOR mode left behind before the current mode re-resolves it.
    resetCaches({ reason = "colors" })
  end)

  -- OPTIONS > CRYSTAL SPRITES rows.  The row descriptors carry the union
  -- of both generations' vocabularies (options_screen.makeRows): on Gen 1
  -- a single CRYSTAL SPRITES row opens the dedicated screen built on Gen
  -- 1's OptionRows; on Gen 2 Gold's OPTION screen is a scrolling list
  -- that answers the same step/value rows (src/ui/gen2/OptionsMenu.lua
  -- raises ui.options.rows with the same payload), so the three rows go
  -- straight into it, inserted before Gold's CANCEL row so the exit stays
  -- last.
  local optionScreen = V.require("Crystal/options_screen")
  optionScreen.init(mod)

  mod.hooks:wrap("ui.options.rows", function(next, game, rows)
    local out = next(game, rows)
    if type(out) == "table" then
      if isGen2 then
        local crystalRows = optionScreen.makeRows(game, true)
        local cancelIdx
        for i, row in ipairs(out) do
          if row and (row.cancel or row.id == "cancel") then
            cancelIdx = i
            break
          end
        end
        if cancelIdx then
          for i = #crystalRows, 1, -1 do
            table.insert(out, cancelIdx, crystalRows[i])
          end
        else
          for _, row in ipairs(crystalRows) do out[#out + 1] = row end
        end
      else
        out[#out + 1] = {
          id = "crystalSpriteOptions",
          label = "CRYSTAL SPRITES",
          value = function() return "" end,
          activate = function(g)
            optionScreen.open(g)
          end,
        }
      end
    end
    return out
  end, 900)

  -- PNG-frame sprites on the dex entry page and the status screen: once
  -- the screen has loaded its pic, swap in the frames and keep advancing
  -- them from update().  The species' shininess decides the variant on the
  -- status screen (its mon is right there); the dex page is always normal.
  if DexEntryMenu and not DexEntryMenu.__crystalAnimHook then
    DexEntryMenu.__crystalAnimHook = true
    local innerDexNew = DexEntryMenu.new
    function DexEntryMenu.new(game, speciesOrOpts, onDone)
      local self = innerDexNew(game, speciesOrOpts, onDone)
      if self then
        local species = type(speciesOrOpts) == "table"
          and (speciesOrOpts.species or speciesOrOpts[1])
          or speciesOrOpts
        installMenuFrames(self, species, "normal")
      end
      return self
    end
    local innerDexUpdate = DexEntryMenu.update
    function DexEntryMenu:update(dt)
      advanceMenuSprite(self, dt)
      return innerDexUpdate(self, dt)
    end
  end

  if SummaryMenu and not SummaryMenu.__crystalAnimHook then
    SummaryMenu.__crystalAnimHook = true
    local innerSummaryNew = SummaryMenu.new
    function SummaryMenu.new(game, mon)
      local self = innerSummaryNew(game, mon)
      if self then
        installMenuFrames(self, mon and mon.species, variant(mon))
      end
      return self
    end
    local innerSummaryUpdate = SummaryMenu.update
    function SummaryMenu:update(dt)
      advanceMenuSprite(self, dt)
      return innerSummaryUpdate(self, dt)
    end
  end

  -- Evolution movie: hand the evolving mons the Crystal PNG frames and
  -- ANIMATE them: the old form animates through the back-and-forth flash,
  -- and the new form keeps animating on the settled screen.  Frames are
  -- ground-trimmed so the mon sits on the movie's baseline (raw under
  -- ADVANCED, luminance-baked otherwise; the true-color flags the hook
  -- reported are already right on the state).
  if EvolutionState
      and type(EvolutionState.new) == "function"
      and type(EvolutionState.draw) == "function"
      and not EvolutionState.__crystalEvoHook then
    EvolutionState.__crystalEvoHook = true
    local innerEvoNew = EvolutionState.new
    function EvolutionState.new(game, mon, newSpecies, onDone, via)
      local self = innerEvoNew(game, mon, newSpecies, onDone, via)
      if self then
        local function evoFrames(species)
          local dex = dexFor(species)
          if not dex then return nil end
          local frames = menuFrames(self, species, variant(self.mon))
          if not frames then return nil end
          return {
            images = trimFrames(frames.images, "front"),
            durations = frames.durations,
          }
        end
        local anims = {}
        local oldFrames = evoFrames(self.mon and self.mon.species)
        if oldFrames then
          self.oldSprite = oldFrames.images[1]
          anims.old = {
            frame = 1, elapsed = 0,
            durations = oldFrames.durations, images = oldFrames.images,
          }
        end
        local newFrames = evoFrames(self.newSpecies)
        if newFrames then
          self.newSprite = newFrames.images[1]
          anims.new = {
            frame = 1, elapsed = 0,
            durations = newFrames.durations, images = newFrames.images,
          }
        end
        -- The engine's own frontSprite load left the trueColor flags
        -- false even under ADVANCED.  Repair them (like the title / Oak /
        -- menu screens do): under REDPP the vivid frames must be marked
        -- true-color so the SGB zone pass does not bucket the full-color
        -- art by red channel into a flat black-and-white silhouette; in
        -- the other modes the baked art is exactly what the zone pass is
        -- supposed to recolor, so false stays false.
        if colorMode() then
          self.oldSpriteTrueColor = true
          self.newSpriteTrueColor = true
        end
        if anims.old or anims.new then self.__crystalEvoAnims = anims end
      end
      return self
    end
    -- Once the movie settles it pushes the congratulations text box on
    -- top, so its update is no longer called and an update-driven loop
    -- would freeze the settled form.  Advance from draw instead (runs
    -- every rendered frame the movie is visible), like the Oak speech.
    local innerEvoDraw = EvolutionState.draw
    function EvolutionState:draw(...)
      local anims = self.__crystalEvoAnims
      if anims then
        local now = (love.timer and love.timer.getTime
          and love.timer.getTime()) or 0
        local dt = anims.last and (now - anims.last) or 0
        anims.last = now
        if dt > 0 and dt < 2 then
          local dtMs = dt * 1000
          for _, key in ipairs({ "old", "new" }) do
            local anim = anims[key]
            if anim then
              anim.elapsed = anim.elapsed + dtMs
              local changed = false
              local guard = 0
              while anim.elapsed >= math.max(1, anim.durations[anim.frame] or 100)
                  and guard < 50 and not anim.done do
                anim.elapsed = anim.elapsed - math.max(1, anim.durations[anim.frame] or 100)
                anim.frame = anim.frame + 1
                if anim.frame > #anim.durations then
                  if animMode == "once" then
                    anim.frame = #anim.durations
                    anim.done = true
                  else
                    anim.frame = 1
                  end
                end
                changed = true
                guard = guard + 1
              end
              if changed then
                if key == "old" then
                  self.oldSprite = anim.images[anim.frame]
                else
                  self.newSprite = anim.images[anim.frame]
                end
              end
            end
          end
        end
      end
      return innerEvoDraw(self, ...)
    end
  end

  -- Title screen: the cycling mon resolves through pokemon.sprite with
  -- kind "title".  Hand the screen the PNG frames (raw under REDPP,
  -- luminance-baked otherwise -- the engine's palette passes recolor
  -- them) and animate it from update() on the same fixed-step clock.
  if TitleState
      and type(TitleState.currentSprite) == "function"
      and type(TitleState.update) == "function"
      and not TitleState.__crystalTitleHook then
    TitleState.__crystalTitleHook = true
    local innerTitleSprite = TitleState.currentSprite
    function TitleState:currentSprite()
      local image, trueColor = innerTitleSprite(self)
      -- Red's OAM strip draws over the mon's box.  Under ADVANCED the mon
      -- is raw true color, so the strip is marked true color (otherwise
      -- the zone pass smears MEWMON purple over the mon pixels behind
      -- Red) and Red's DMG art is baked to his iconic outfit so he is
      -- not left raw gray.  In the other COLORS modes the trainer is
      -- left to the zone pass for the authentic palette colors -- and a
      -- recolor left over from an earlier ADVANCED visit is restored so
      -- the zone pass cannot mangle the baked colors.
      if self.player and PaletteFX and PaletteFX.markTrueColor then
        if not self.__crystalPlayerRaw then
          self.__crystalPlayerRaw = self.player
        end
        if colorMode() then
          pcall(bakeTitleTrainer, self)
          local okDim, pw, ph =
            pcall(self.player.getDimensions, self.player)
          if okDim and pw and ph then
            PaletteFX.markTrueColor(82, 80, pw, ph)
          end
        elseif self.__crystalTrainerBaked then
          self.player = self.__crystalPlayerRaw
          self.__crystalTrainerBaked = nil
        end
      end
      local species = self.cycleSpecies and self.cycleSpecies[self.cycleIndex]
      local dex = species and dexFor(species)
      if dex then
        -- The mon rides the engine's true-color mark under ADVANCED only
        -- (raw vivid art); in every other COLORS mode the grayscale art
        -- is drawn through the zone pass, which recolors its DMG-style
        -- shades into the mode's palette like vanilla art.
        local mode = PaletteFX and PaletteFX.mode or "?"
        local frames = menuFrames(self, species, "normal")
        if frames then
          local state = self.__crystalAnim
          if not state or state.dex ~= dex or state.mode ~= mode then
            state = {
              dex = dex,
              mode = mode,
              frame = 1,
              elapsed = 0,
              durations = frames.durations,
              images = frames.images,
            }
            self.__crystalAnim = state
          end
          return state.images[state.frame], colorMode()
        end
      end
      return image, trueColor
    end
    local innerTitleUpdate = TitleState.update
    function TitleState:update(dt)
      local result = innerTitleUpdate(self, dt)
      advanceMenuSprite(self, dt)
      return result
    end
  end

  -- New-game Oak speech: the NIDORINO show-off ("This world is inhabited
  -- by creatures called POKéMON!") loads through pokemon.sprite with
  -- kind "oak".  Hand the speech the PNG frames -- raw full color under
  -- REDPP (the true-color flag the hook reported keeps them vivid),
  -- luminance-baked otherwise so the zone pass colors them like vanilla
  -- art -- and animate them from draw().
  if OakSpeech
      and type(OakSpeech.new) == "function"
      and type(OakSpeech.update) == "function"
      and not OakSpeech.__crystalOakHook then
    OakSpeech.__crystalOakHook = true
    -- ADVANCED keeps the raw art vivid through the true-color mark; the
    -- other COLORS modes bake the full-color frames by luminance, which
    -- the MEWMON zone pass recolors like vanilla art.
    local function oakDemoFrames(dex, data, species)
      local art = artVariantForMode("normal")
      local base = frontFrameInfo(dex, art)
      if base and base == art then
        return pngFrames(dex, art, nil)
      end
      -- The grayscale folders are empty, so bake onto the 4-shade DMG ramp
      -- and let the MEWMON zone pass recolor the shades (see menuFrames).
      return lumaFrames(dex, DMG_RAMP, "oak-gray")
    end
    -- The speech's Oak and rival portraits load through the generated
    -- trainer data; swap in the mod's replacement art (full color under
    -- ADVANCED, grayscale otherwise) via the speech's override fields,
    -- which resolvePic prefers over the generated paths.
    local function speechTrainerPic(game, id)
      -- NONE / OVERWORLD leave the battle portraits (the intro included)
      -- fully vanilla.
      if not customTrainerPortraits() then return nil end
      local tr = game and game.data and game.data.trainers
        and game.data.trainers[id]
      local name = tr and trainerPicName(tr.pic)
      if not name then return nil end
      -- REPLACE SPRITES ("both" / "trainers"): the user.s own art in
      -- assets/trainers/opponents/ (or opponent/) wins over the
      -- mode-aware shipped portrait (pic basename, then the class id).
      local p
      if customOpponents() then
        p = firstExistingPath(
          ("%s/trainers/opponents/%s.png"):format(BASE, name),
          ("%s/trainers/opponent/%s.png"):format(BASE, name),
          ("%s/trainers/opponents/%s.png"):format(BASE, id),
          ("%s/trainers/opponent/%s.png"):format(BASE, id),
          ("%s/trainers/%s/%s.png"):format(
            BASE, artVariantForMode("normal"), name))
      else
        p = firstExistingPath(("%s/trainers/%s/%s.png"):format(
          BASE, artVariantForMode("normal"), name))
      end
      if not p then return nil end
      return loadImageRaw(p)
    end
    local innerOakNew = OakSpeech.new
    function OakSpeech.new(game, onDone)
      local self = innerOakNew(game, onDone)
      if self then
        local dex = self.demoSpecies and dexFor(self.demoSpecies)
        local frames = dex and oakDemoFrames(dex, game and game.data, self.demoSpecies)
        if frames then
          self.demoPic = frames.images[1]
          -- the demo pic's true-color flag came from the hook while the
          -- pic itself failed to load; restore it so REDPP keeps the
          -- raw art un-recolored
          self.demoTrueColor = self.demoTrueColor or colorMode()
          local anim = {
            frame = 1,
            elapsed = 0,
            durations = frames.durations,
            images = frames.images,
            byImage = {},
          }
          for i = 1, #frames.images do
            anim.byImage[frames.images[i]] = true
          end
          self.__crystalDemoAnim = anim
        end
        -- replacement Oak and rival portraits (the engine's resolvePic
        -- checks these override fields before the generated art)
        local oakImg = speechTrainerPic(game, "OPP_PROF_OAK")
        if oakImg then self.oakPic = oakImg end
        local rivalImg = speechTrainerPic(game, "OPP_RIVAL1")
        if rivalImg then self.rivalPic = rivalImg end
      end
      return self
    end
    -- The demo pic is drawn under the speech's dialogue box, and only
    -- the top state updates -- so OakSpeech.update is NOT called while
    -- the "This world is inhabited..." text is up, and an update-driven
    -- animation would freeze at frame 1.  Advance from draw instead,
    -- which runs every rendered frame the speech is visible.
    local innerOakDraw = OakSpeech.draw
    function OakSpeech:draw(...)
      local anim = self.__crystalDemoAnim
      if anim and anim.byImage[self.pic] then
        local now = (love.timer and love.timer.getTime
          and love.timer.getTime()) or 0
        local dt = anim.last and (now - anim.last) or 0
        anim.last = now
        if dt > 0 and dt < 2 then
          anim.elapsed = anim.elapsed + dt * 1000
          local changed = false
          local guard = 0
          while anim.elapsed >= math.max(1, anim.durations[anim.frame] or 100)
              and guard < 50 and not anim.done do
            anim.elapsed = anim.elapsed - math.max(1, anim.durations[anim.frame] or 100)
            anim.frame = anim.frame + 1
            if anim.frame > #anim.durations then
              if animMode == "once" then
                anim.frame = #anim.durations
                anim.done = true
              else
                anim.frame = 1
              end
            end
            changed = true
            guard = guard + 1
          end
          if changed then self.pic = anim.images[anim.frame] end
        end
      end
      return innerOakDraw(self, ...)
    end
    -- The engine reports the oak/rival portraits as non-true-color, so
    -- under ADVANCED the zone pass would flatten the full-color art;
    -- mark the mod's replaced portraits true-color instead (grayscale
    -- art in the other modes keeps riding the zone pass).
    if type(OakSpeech.resolvePic) == "function"
        and not OakSpeech.__crystalResolveHook then
      OakSpeech.__crystalResolveHook = true
      local innerResolve = OakSpeech.resolvePic
      function OakSpeech.resolvePic(game, desc, speech)
        local img, flip, tc = innerResolve(game, desc, speech)
        if img and speech and colorMode() and isCrystalImage(img) then
          if img == speech.oakPic or img == speech.rivalPic then
            return img, flip, true
          end
        end
        return img, flip, tc
      end
    end
  end

  -- Boot intro: Red and Blue open on the Gengar vs Nidorino fight.
  -- Whenever a game's own intro frames are blank (Yellow ships empty
  -- 1-bit placeholders for the fight it never plays), swap in the mod's
  -- animated Crystal Gengar and Nidorino, tinted onto the intro's
  -- PURPLEMON zone palette by luminance so the SGB pass colors them the
  -- same way, and keep them moving from update().
  if IntroMovie
      and type(IntroMovie.new) == "function"
      and type(IntroMovie.update) == "function"
      and not IntroMovie.__crystalIntroHook then
    IntroMovie.__crystalIntroHook = true
    local function introFightPal(data)
      return modePalette(data, "PURPLEMON")
        or modePalette(data, "MEWMON")
    end
    local function introArtEmpty(cfg, key, i)
      local entry = cfg and cfg[key] and cfg[key]["frame" .. i]
      if not (entry and entry.path) then return true end
      -- love.filesystem is sandboxed away from mods, so detect Yellow's
      -- blank placeholder frames (fully transparent PNGs) by decoding and
      -- scanning for any opaque pixel instead of reading the on-disk size.
      local okI, data = pcall(love.image.newImageData, entry.path)
      if not (okI and data) then return true end
      local w, h = data:getWidth(), data:getHeight()
      if not (w and h and w > 0 and h > 0) then return true end
      for y = 0, h - 1 do
        for x = 0, w - 1 do
          local _, _, _, a = data:getPixel(x, y)
          if a and a > 0 then return false end
        end
      end
      return true
    end
    local innerIntroNew = IntroMovie.new
    function IntroMovie.new(game, onDone)
      local self = innerIntroNew(game, onDone)
      if self then
        local pal = introFightPal(game and game.data)
        local nidoSet, gengarSet
        for i = 1, 3 do
          if introArtEmpty(self.introCfg, "nidorino", i) then
            nidoSet = nidoSet or lumaFrames(33, pal, "boot")
            if nidoSet then self.nidoFrames[i] = nidoSet.images[1] end
          end
          if introArtEmpty(self.introCfg, "gengar", i) then
            gengarSet = gengarSet or lumaFrames(94, pal, "boot")
            if gengarSet then self.gengarFrames[i] = gengarSet.images[1] end
          end
        end
        if nidoSet then
          self.__crystalNidoAnim = {
            frame = 1, elapsed = 0, durations = nidoSet.durations,
            images = nidoSet.images, frames = self.nidoFrames,
          }
        end
        if gengarSet then
          self.__crystalGengarAnim = {
            frame = 1, elapsed = 0, durations = gengarSet.durations,
            images = gengarSet.images, frames = self.gengarFrames,
          }
        end
      end
      return self
    end
    local innerIntroUpdate = IntroMovie.update
    function IntroMovie:update(dt)
      local dtReal = logicToReal(dt, self.game) * 1000
      for _, anim in ipairs(
          { self.__crystalNidoAnim, self.__crystalGengarAnim }) do
        if anim then
          anim.elapsed = anim.elapsed + dtReal
          local changed = false
          local guard = 0
          while anim.elapsed >= math.max(1, anim.durations[anim.frame] or 100)
              and guard < 50 and not anim.done do
            anim.elapsed = anim.elapsed - math.max(1, anim.durations[anim.frame] or 100)
            anim.frame = anim.frame + 1
            if anim.frame > #anim.durations then
              if animMode == "once" then
                anim.frame = #anim.durations
                anim.done = true
              else
                anim.frame = 1
              end
            end
            changed = true
            guard = guard + 1
          end
          if changed then
            local img = anim.images[anim.frame]
            anim.frames[1], anim.frames[2], anim.frames[3] = img, img, img
          end
        end
      end
      return innerIntroUpdate(self, dt)
    end
  end

  -- Transformed Ditto (battle): Transform copies the target's shape, so
  -- the copied species is recorded on the battler for the animation loop
  -- (the mon struct keeps Ditto's species).  The engine's speciesSprite
  -- swap -- used by TRANSFORM_EFFECT and the SE_TRANSFORM_MON anim event
  -- -- returns a Ditto-purple copy of the target instead of the raw pic,
  -- so the player-side back pic (never animated by the mod) is purple too.
  local okME, MoveEffects = pcall(require, "src.battle.MoveEffects")
  if not isGen2 and okME and MoveEffects
      and type(MoveEffects.TRANSFORM_EFFECT) == "function"
      and not MoveEffects.__crystalTransformHook then
    MoveEffects.__crystalTransformHook = true
    local innerTransform = MoveEffects.TRANSFORM_EFFECT
    function MoveEffects.TRANSFORM_EFFECT(battle, user, target)
      local out = innerTransform(battle, user, target)
      -- fallback only: the engine dispatches the deep-copied records, so
      -- this never runs in battle.  Mirror the real hooks' rule anyway --
      -- defer the copy to SE_TRANSFORM_MON, except with animations off.
      if user and target and type(battle) == "table"
          and type(battle.animationsOn) == "function"
          and not battle:animationsOn() then
        user.__crystalTransformed = target.mon and target.mon.species
      end
      return out
    end
  end
  -- The engine dispatches every move effect through
  -- BattleState:effectRecord, and the records it hands out are deep
  -- copies of MoveEffects.RECORDS (the loader's isolate wrapper
  -- deep-copies each registered record), so wrapping the module tables
  -- above never fires in battle.  The copied species has to be recorded
  -- on the battler so the animation loop keeps the Transform shape --
  -- but NOT when the effect applies: the Transform animation first shows
  -- Ditto shrinking into the transform square, and the mon should only
  -- take the copied shape when the square hits (the SE_TRANSFORM_MON
  -- anim event, hooked below).  Setting the flag at effect time is what
  -- made the copy appear from the very first frame of the animation.
  -- The exception is battle animations OFF: PlayMoveAnimation is skipped
  -- entirely (no SE events fire at all), so the record wrap is the only
  -- chance to record the copy -- the effect's own speciesSprite swap
  -- would otherwise be clobbered back to the Ditto pic by the loop.
  if not isGen2 and type(BattleState.effectRecord) == "function"
      and not BattleState.crystalEffectRecordHook then
    BattleState.crystalEffectRecordHook = true
    local innerEffectRecord = BattleState.effectRecord
    function BattleState:effectRecord(effect)
      local record = innerEffectRecord(self, effect)
      if effect == "TRANSFORM_EFFECT"
          and record and type(record.run) == "function"
          and not record.__crystalTransformRun then
        record.__crystalTransformRun = true
        local innerRun = record.run
        record.run = function(ctx)
          local out = innerRun(ctx)
          if ctx and ctx.user and ctx.target then
            local battle = ctx.battle
            if type(battle) == "table"
                and type(battle.animationsOn) == "function"
                and not battle:animationsOn() then
              ctx.user.__crystalTransformed =
                ctx.target.mon and ctx.target.mon.species
            end
          end
          return out
        end
      end
      return record
    end
  end
  -- SE_TRANSFORM_MON is the moment the transform square hits: the engine
  -- redraws the user as the opposing species there, and that is when the
  -- animation loop should take over with the copied species' animated
  -- (Ditto-purple) pic -- not at effect-apply time, which would show the
  -- copy throughout the shrink/square animation.  The engine's handler
  -- resolves the same battlers this hook reads (attacker/defender).
  if not isGen2 and type(BattleState.applyAnimEffect) == "function"
      and not BattleState.crystalAnimEffectHook then
    BattleState.crystalAnimEffectHook = true
    local innerApplyAnimEffect = BattleState.applyAnimEffect
    function BattleState:applyAnimEffect(ev)
      local out = innerApplyAnimEffect(self, ev)
      if ev and ev.effect == "SE_TRANSFORM_MON"
          and type(self.animFxBattler) == "function" then
        local user = self:animFxBattler(false)
        local target = self:animFxBattler(true)
        if user and target and target.mon then
          user.__crystalTransformed = target.mon.species
        end
      end
      return out
    end
  end

  if not isGen2 and not BattleState.crystalSpeciesSpriteHook then
    BattleState.crystalSpeciesSpriteHook = true
    local innerSpeciesSprite = BattleState.speciesSprite
    function BattleState:speciesSprite(species, isPlayerSide)
      local dex = dexFor(species)
      if dex then
        local pal = transformPalette(self.data)
        if pal then
          if isPlayerSide then
            local img = lumaPng(dex, pal.colors, pal.name)
            if img then return trimGround(img, "back", self) end
          else
            local frames = lumaFrames(dex, pal.colors,
              "transform:" .. pal.name)
            if frames then return trimGround(frames.images[1], "front", self) end
          end
        end
      end
      return innerSpeciesSprite(self, species, isPlayerSide)
    end
  end

  -- Trainer replacement sprites: the mod ships its own trainer portraits
  -- (full color under ADVANCED, grayscale otherwise) named after the
  -- engine's generated battle pics.
  if not isGen2 and not BattleState.crystalTrainerPicHook then
    BattleState.crystalTrainerPicHook = true
    local innerTrainerNew = BattleState.newTrainer
    function BattleState.newTrainer(game, oppClass, partyIndex)
      local self = innerTrainerNew(game, oppClass, partyIndex)
      if self and self.trainer then
        self.__crystalTrainerInfo = { game = game, trainer = self.trainer, oppClass = oppClass, partyIndex = partyIndex }
        local img = modTrainerPic(game, self.trainer, oppClass, partyIndex)
        if img then self.trainerPic = img end
      end
      return self
    end
  end

  -- Player portraits named *_flip.png are mirrored automatically for the
  -- battle back pic (no menu toggle).  Only while the player's art is
  -- actually being replaced (REPLACE SPRITES both / player only), and
  -- never in the demo battles -- the catch tutorial's back pic is the
  -- OLD MAN's and Yellow's Pallet intro is Prof. Oak's, neither of which
  -- is the player's own portrait, so mirroring them flips them the wrong
  -- way.  The engine loads playerBackPic in BattleState:enter -- AFTER
  -- newTrainer constructs the battle -- so the flip wraps enter and
  -- mirrors the pic the engine just loaded.  __crystalFlippedPic guards
  -- a re-entered battle against flipping the same pic twice.
  if not isGen2 and not BattleState.crystalEnterHook then
    BattleState.crystalEnterHook = true
    local innerEnter = BattleState.enter
    function BattleState:enter()
      local ret = innerEnter(self)
      -- Flag when the mod's own back art is in the slot (the hook serves
      -- it only under these same conditions), so the picImage wrap knows
      -- to luminance-bake it in non-ADVANCED modes.  The loaded image
      -- itself carries no filename, so this per-battle flag is the only
      -- cheap provenance check.
      if customPlayer() and not self.demo and not self.oakDemo
          and playerArtPath("back", "battle") then
        self.__crystalCustomBack = true
      end
      -- Flip only when the mod's own art is actually in the slot: with
      -- REPLACE SPRITES enabled but the custom file missing, the engine's
      -- vanilla back pic falls back in, and a *_flip.png selection must
      -- not mirror art that was never replaced.
      if customPlayer() and self.__crystalCustomBack and playerSpriteFlip()
          and not self.demo and not self.oakDemo and self.playerBackPic
          and self.playerBackPic ~= self.__crystalFlippedPic then
        self.playerBackPic = flipHImage(self.playerBackPic,
          playerArtPath("back", "battle"))
        self.__crystalFlippedPic = self.playerBackPic
      end
      return ret
    end
  end

  mod.events:on("battle.started", function(event)
    -- Gen 1 keys the payload by `game`; Gen 2 by `battle`.
    local battle = event and (event.battle or event.game)
    -- The battler-sprite animation loop is a Gen 1 BattleState patch; on
    -- Gen 2 Gold resolves its own battle sprites, so only the harmless
    -- shiny-pending flag is set.
    if not isGen2 then
      resetEnemyAnimation(battle)
      resetPlayerAnimation(battle)
    end

    if battle and enemyIsShiny(battle) then
      battle.__combinedShinyPending = true
    end
  end)

  mod.events:on("battle.battler_switched", function(event)
    local battle = event and (event.battle or event.game)

    if battle and battle.enemy then
      battle.enemy.__crystalAnimation = nil
      battle.enemy.__crystalTransformed = nil
    end
    if battle and battle.player then
      battle.player.__crystalTransformed = nil
    end

    if not isGen2 then
      resetEnemyAnimation(battle)
      resetPlayerAnimation(battle)
    end

    if battle and enemyIsShiny(battle) then
      battle.__combinedShinyPending = true
    end
  end)

  mod.events:on("battle.ended", function(event)
    local battle = event and (event.battle or event.game)

    if battle and battle.enemy then
      battle.enemy.__crystalAnimation = nil
      battle.enemy.__crystalTransformed = nil
    end
    if battle and battle.player then
      battle.player.__crystalAnimation = nil
      battle.player.__crystalTransformed = nil
    end

    if battle == reveal.battle then
      if reveal.source then
        pcall(reveal.source.stop, reveal.source)
      end
      reveal.battle = nil
      reveal.source = nil
      reveal.crySpecies = nil
      reveal.cryMon = nil
      reveal.cryPlayed = false
    end
  end)

  exportHelpers()

  -- The mono-mode staged-battle bakes and the voxel-mod interop are Gen 1
  -- battle internals; Gold has no staged battle, so both are gated out.
  if not isGen2 then installMonoHooks() end

  mod.events:on("map.reloaded", resetCaches)

  if not isGen2 then
    voxelPaperCompat()
    mod.events:on("game.ready", function() voxelPaperCompat() end)
  end

  mod.log:info(
    "Battle Art: integrated Crystal sprites loaded")
end
