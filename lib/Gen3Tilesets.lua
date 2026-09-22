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
  -- Generated cached map definitions can default environment to TOWN even
  -- for caves. The native header's mapType is the authoritative field.
  local kind=tonumber(def.mapType)
  if kind and kind>0 then return kind==1 or kind==2 or kind==3 or kind==6 end
  return def.environment=='TOWN' or def.environment=='ROUTE'
 end
 return spec.primary=='building' and
  (def.midLayout.pair=='player_house' or def.midLayout.pair=='house' or def.midLayout.pair=='oak_lab'
    or def.midLayout.pair=='network' or def.midLayout.pair=='building__rom_082d4bcc')
end
return M
