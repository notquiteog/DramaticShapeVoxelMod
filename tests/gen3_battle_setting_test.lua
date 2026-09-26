-- Exercise both the lazy runtime value and the native menu's schema default.
local function fixture(stored)
 local cache,schema={},{}
 local V={mod={options={get=function(_,key)
  if stored[key]~=nil then return stored[key]end
  for _,s in ipairs(schema)do if s.key==key then return s.default end end
 end}}}
 function V.require(name)
  if not cache[name]then cache[name]=assert(loadfile('lib/'..name..'.lua'))(V)end
  return cache[name]
 end
 local B=V.require('Gen3Battle');B.setting:read();schema[1]=B.setting:schema()
 return B,V.mod.options
end
for _,old in ipairs({false,true})do
 local B,opts=fixture({fireredBattleStage=old})
 assert(B.enabled()==old and opts:get('battles')==old,'legacy preference/menu disagreed')
end
local B,opts=fixture({battles=true,fireredBattleStage=false})
assert(B.enabled() and opts:get('battles'),'legacy key overrode an explicit shared preference')
B,opts=fixture({});assert(B.enabled() and opts:get('battles'),'new install lost enabled default')
print('PASS shared battle option, legacy OFF migration and native menu agreement')
