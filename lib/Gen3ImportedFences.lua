-- Authentic ORAS fence pieces in reviewed native blocked cells. Source art,
-- collision, scripts and native ground remain authoritative on any failure.
local V=...
local Models=V.require('SceneryModels')
local Families=V.require('Gen3FenceFamilies')
local M={}
local registered={}
function M.register(id)
 if registered[id]and Models.info(id)then return true end
 local ok,data=pcall(V.require,'ImportedFenceData')
 if not ok or type(data)~='table'or not data[id]then return nil,'imported fence source unavailable'end
 local success,why=Models.register(id,data[id],{read=function(path)return V.mod:read(path)end})
 if success then registered[id]=true end
 return success,why
end
function M.eligible(c)
 if not c or c.boundary or c.prop or c.civic or c.stairs or c.stageHidden
  or not(c.ts and c.ts.layered)or c.collision~=7 or c.primary~='general'then return end
 local shape=Families.shape(c.primary,c.secondary,c.mid,c.behavior,c.collision)
 if shape and shape.nativeFence=='rural149'then return 'oras_rural_fence'end
end
function M.placements(cells)
 local out={}
 for _,c in pairs(cells)do
  local id=M.eligible(c)
  if id then out[#out+1]={model=id,x=c.cx*16,y=c.base or 0,z=c.cy*16,
   fit={width=16,depth=16,padding=0},source=c}end
 end
 table.sort(out,function(a,b)return a.z==b.z and a.x<b.x or a.z<b.z end)
 return out
end
function M.build(cells,newMesh,parts)
 local list=M.placements(cells)
 if #list==0 then return parts,nil,0 end
 for _,p in ipairs(list)do local ok,err=M.register(p.model);if not ok then return nil,err,0 end end
 local result,err=Models.buildBatches(list,newMesh,{parts=parts})
 if result then for _,p in ipairs(list)do p.source.importedFence=p.model end end
 return result,err,result and #list or 0
end
function M.floor(c)
 if c and c.importedFence and M.eligible(c)==c.importedFence then return c.importedFence=='oras_rural_fence'and 1 or c.mid end
end
function M.underOnly(c)return M.floor(c)~=nil and c.ts.layered==true end
return M
