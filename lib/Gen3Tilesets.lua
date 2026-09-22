-- The importer adds generated pairs to Versions only while importing a ROM.
-- Cached boots retain their names on the map, but not those table entries.
-- Decode the importer's public pair naming convention; never read ROM/cache
-- files or interpret the opaque secondary suffix as an address.
local M={}
function M.resolve(pair,known)
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
  return def.environment=='TOWN' or def.environment=='ROUTE'
 end
 return spec.primary=='building' and
  (def.midLayout.pair=='player_house' or def.midLayout.pair=='house')
end
return M
