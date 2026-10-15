-- True boss/static-legendary overrides, independent from the art collection.

local V = ...
local BattleArt = V.require("BattleArt")
local Images = V.require("BackdropImage")
local config = V.data("boss_battle_backgrounds")
local BossBackdrop = {}

local function mapId(map)
  return type(map) == "table" and map.id or map
end

function BossBackdrop.fileFor(map, battle)
  local id = mapId(map)
  if not id then return nil end

  local room = config.rooms[id]
  if room then return room end

  local native = V.require('Gen2BattleBackdrop')
  local trainer = battle and config.trainers[battle.oppClass or native.trainer(battle)] or nil
  if trainer then
    -- Most trainers have one canonical room. Repeating trainers such as
    -- Giovanni instead use a map-keyed table so each story encounter can
    -- select its own plate without making the whole room a boss override.
    if trainer.map == id then return trainer.file end
    if trainer[id] then return trainer[id] end
  end

  local species = battle and (native.species(battle) or BattleArt.speciesFor(battle.enemy)) or nil
  local encounter = species and config.species[species] or nil
  if encounter and encounter.map == id then return encounter.file end
  return nil
end

function BossBackdrop.image(map, battle)
  return Images.load("bosses", BossBackdrop.fileFor(map, battle))
end

return BossBackdrop
