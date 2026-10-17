-- One build's native classification results. Never retain across edition,
-- provider or recipe changes; every cell owns a copy for layout preparation.
local M={}
local absent={}
local function copy(value)
 if type(value)~='table'then return value end
 local out={};for k,v in pairs(value)do out[k]=copy(v)end
 return out
end
local function branch(node,k)
 if k==nil then k=absent end
 local child=node[k]
 if not child then child={};node[k]=child end
 return child
end
function M.new(classify)
 local roots={}
 return function(primary,secondary,mid,behavior,collision)
  local node=roots
  -- No string fingerprints or per-cell argument arrays in this hot loop.
  node=branch(node,primary);node=branch(node,secondary)
  node=branch(node,mid);node=branch(node,behavior)
  local key=collision==nil and absent or collision
  local result=node[key]
  if not result then
   result={value=copy(classify(primary,secondary,mid,behavior,collision))}
   node[key]=result
  end
  return copy(result.value)
 end
end
return M
