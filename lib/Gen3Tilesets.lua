-- The importer adds generated pairs to Versions only while importing a ROM.
-- Cached boots retain their names on the map, but not those table entries.
-- Decode the importer's public pair naming convention; never read ROM/cache
-- files or interpret the opaque secondary suffix as an address.
local M={}
-- Resolve edition-specific generated pair names through public map identity.
-- No ROM addresses or imported files are read at runtime. Full drawing recipes
-- still validate each object before claiming it.
local aliases={}
local representatives={
 ["building__rom_082d4bcc"]={"FR_CERULEAN_CITY_MART","FR_CINNABAR_ISLAND_MART","FR_FOUR_ISLAND_MART","FR_FUCHSIA_CITY_MART","FR_LAVENDER_TOWN_MART","FR_PEWTER_CITY_MART","FR_SAFFRON_CITY_MART","FR_SEVEN_ISLAND_MART","FR_SIX_ISLAND_MART","FR_THREE_ISLAND_MART","FR_VERMILION_CITY_MART","FR_VIRIDIAN_CITY_MART"},
 ["general__rom_082d4af4"]={"FR_CERULEAN_CITY","FR_ROUTE_24","FR_ROUTE_25","FR_ROUTE_4","FR_ROUTE_5","FR_ROUTE_9"},
 ["general__rom_082d4b0c"]={"FR_LAVENDER_TOWN","FR_ROUTE_10","FR_ROUTE_12","FR_ROUTE_13","FR_ROUTE_14","FR_ROUTE_8"},
 ["general__rom_082d4b24"]={"FR_ROUTE_11","FR_ROUTE_6","FR_SSANNE_EXTERIOR","FR_VERMILION_CITY"},
 ["general__rom_082d4b3c"]={"FR_CELADON_CITY","FR_PROTOTYPE_SEVII_ISLE_6","FR_PROTOTYPE_SEVII_ISLE_7","FR_PROTOTYPE_SEVII_ISLE_8","FR_PROTOTYPE_SEVII_ISLE_9","FR_ROUTE_16","FR_ROUTE_17","FR_ROUTE_18","FR_ROUTE_7"},
 ["general__rom_082d4b54"]={"FR_FUCHSIA_CITY","FR_ROUTE_15","FR_ROUTE_19","FR_SAFARI_ZONE_CENTER","FR_SAFARI_ZONE_EAST","FR_SAFARI_ZONE_NORTH","FR_SAFARI_ZONE_WEST"},
 ["general__rom_082d4b9c"]={"FR_SAFFRON_CITY","FR_SAFFRON_CITY_CONNECTION"},
 ["general__rom_082d4dc4"]={"FR_SIX_ISLAND_PATTERN_BUSH","FR_VIRIDIAN_FOREST"},
 ["general__rom_082d5064"]={"FR_FIVE_ISLAND","FR_FIVE_ISLAND_MEADOW","FR_FIVE_ISLAND_MEMORIAL_PILLAR","FR_FIVE_ISLAND_RESORT_GORGEOUS","FR_FIVE_ISLAND_WATER_LABYRINTH","FR_FOUR_ISLAND"},
 ["general__rom_082d507c"]={"FR_BIRTH_ISLAND_EXTERIOR","FR_SEVEN_ISLAND","FR_SEVEN_ISLAND_SEVAULT_CANYON","FR_SEVEN_ISLAND_SEVAULT_CANYON_ENTRANCE","FR_SEVEN_ISLAND_TANOBY_RUINS","FR_SEVEN_ISLAND_TRAINER_TOWER","FR_SIX_ISLAND","FR_SIX_ISLAND_GREEN_PATH","FR_SIX_ISLAND_OUTCAST_ISLAND","FR_SIX_ISLAND_RUIN_VALLEY","FR_SIX_ISLAND_WATER_PATH"},
}
function M.bind(maps)
 aliases={}
 for recipe,ids in pairs(representatives)do
  for _,id in ipairs(ids)do
   local def=maps and maps[id]
   local pair=def and ((def.midLayout and def.midLayout.pair) or def.pair)
   if pair then aliases[pair]=recipe end
  end
 end
end
function M.canonical(pair)return aliases[pair] or pair end
function M.resolve(pair,known)
 pair=M.canonical(pair)
 local spec=known and known[pair]
 if spec then return spec end
 if type(pair)=='string' then
  local primary,secondary=pair:match('^([%w_]+)__(.+)$')
  if primary and secondary then return {primary=primary,secondary=secondary} end
 end
 return {}
end
function M.supports(def,spec)
 if not (def and def.midLayout) then return false end
 -- Caves and ships also use the General primary tileset. Its name alone
 -- must never enable outdoor recipes on those maps.
 if spec.primary=='general' then
  -- Generated cached map definitions can default environment to TOWN even
  -- for caves. The native header's mapType is the authoritative field.
  local kind=tonumber(def.mapType)
  if kind and kind>0 then return kind==1 or kind==2 or kind==3 or kind==6 end
  return def.environment=='TOWN' or def.environment=='ROUTE'
 end
 return spec.primary=='building' and
  (M.canonical(def.midLayout.pair)=='player_house' or M.canonical(def.midLayout.pair)=='house' or M.canonical(def.midLayout.pair)=='oak_lab'
    or M.canonical(def.midLayout.pair)=='network' or M.canonical(def.midLayout.pair)=='building__rom_082d4bcc')
end
return M
