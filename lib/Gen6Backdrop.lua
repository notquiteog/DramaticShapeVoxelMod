-- Location-aware flat battle backgrounds for ARENA FILL: GEN6.

local V = ...

local Map = require("src.world.Map")
local DayNight = V.require("DayNight")
local Images = V.require("BackdropImage")
local config = V.data("gen6_battle_backgrounds")
local Gen6Backdrop = {}
local PERIOD_FIELD = "dramaticShapeGen6Period"

local function phase()
  local mix = DayNight.mix(DayNight.time())
  local name, weight = "day", -1
  for candidate, value in pairs(mix) do
    if value > weight then name, weight = candidate, value end
  end
  if name == "golden" then return "dusk" end
  if name == "violet" then return "night" end
  return name
end

function Gen6Backdrop.setFor(map, battle)
  local id = type(map) == "table" and map.id or map
  local native = V.require('Gen2BattleBackdrop')
  local fishing = battle and (battle.dramaticShapeFishing or native.fishing(battle))
  local surfing = battle and battle.dramaticShapeSurfing
  local encounter = id and battle and config.encounters
                    and config.encounters[id] or nil

  -- Encounter provenance is deliberately layered in priority order. Cinnabar
  -- is always Cinnabar; Safari water follows; Route 19/20/21 fishing retains
  -- each route's normal view; other outdoor fishing uses the river-bank plate.
  -- Surf battles use open ocean only on Routes 19-21, the ordinary shore on
  -- other outdoor maps, and the room's normal mapping when surfing indoors.
  local setName
  if id == "CINNABAR_ISLAND" then
    setName = "cinnabarisland"
  elseif id and config.safariWaterMaps[id] and (fishing or surfing) then
    setName = "safariwater"
  elseif fishing and id and config.fishingSets[id] then
    setName = config.fishingSets[id]
  elseif fishing and id and config.fishingMapDefaults[id] then
    setName = config.maps[id]
  elseif fishing and type(map) == "table" and map.def
         and Map.isOutdoor(map.def) then
    setName = "safariwater"
  elseif surfing and id and config.surfingSets[id] then
    setName = config.surfingSets[id]
  elseif surfing and (id == "ROUTE_19" or id == "ROUTE_20"
                      or id == "ROUTE_21") then
    setName = "ocean"
  elseif surfing and type(map) == "table" and map.def
         and Map.isOutdoor(map.def) then
    setName = "shore"
  else
    setName = encounter and battle and encounter[battle.oppClass or native.trainer(battle)]
              or (id and config.maps[id] or nil)
  end
  if not setName and type(map) == "table" and map.def then
    -- A generic outdoor field is a reasonable imported-map fallback. There is
    -- intentionally no generic indoor plate: unmatched rooms retain their
    -- voxel arena rather than masquerading as Viridian Gym.
    setName = Map.isOutdoor(map.def) and "grassy" or nil
  end
  return setName
end

-- A battle keeps the hour it entered with. BattleScene renders every frame,
-- while CYCLE/SYNC continue advancing behind it; resolving phase() there made
-- an illustrated arena jump abruptly from (for example) dusk to night during
-- a long fight. Stamp the ordinary mutable BattleState alongside the existing
-- fishing/surfing provenance, and never replace an established stamp.
function Gen6Backdrop.snapshot(battle, period)
  if type(battle) ~= "table" then return period or phase() end
  if battle[PERIOD_FIELD] == nil then
    battle[PERIOD_FIELD] = period or phase()
  end
  return battle[PERIOD_FIELD]
end

function Gen6Backdrop.fileFor(map, period, battle)
  local setName = Gen6Backdrop.setFor(map, battle)
  local set = setName and config.sets[setName] or nil
  if type(set) == "string" then return set end
  if type(set) ~= "table" then return nil end
  period = period or Gen6Backdrop.snapshot(battle)
  return set[period] or set.day or set.dawn or set.dusk or set.night
end

function Gen6Backdrop.image(map, battle)
  return Images.load("gen6", Gen6Backdrop.fileFor(map, nil, battle))
end

function Gen6Backdrop.clear()
  Images.clear()
end

Gen6Backdrop._phase = phase
Gen6Backdrop.PERIOD_FIELD = PERIOD_FIELD

return Gen6Backdrop
