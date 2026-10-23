-- Resolve the original generation's damage category; no modern type split.
local M={}
function M.resolve(metadata)
 local def=metadata and metadata.definition
 if not def then return 'attack'end
 if def.category=='special'then return 'special'end
 if def.category=='physical'then return 'attack'end
 if not def.type then return 'attack'end
 local gen=require('src.core.GameVersion').generation()
 if gen==1 then
  return require('src.battle.Damage').isSpecial(def.type)and'special'or'attack'
 elseif gen==2 then
  local battle=metadata.battle
  local types=battle and battle.data and battle.data.type_chart and battle.data.type_chart.types
  return require('src.battle.gen2.Damage').isPhysical(def.type,types)and'attack'or'special'
 end
 return 'attack'
end
return M
