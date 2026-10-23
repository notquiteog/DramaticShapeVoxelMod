-- Genuine ORAS Oldale Mart. Other towns have distinct source geometry/UVs and
-- remain separate work; never broaden this adapter from a common material name.
local V=...
local Models=V.require('SceneryModels')
local M={id='oras_oldale_mart'}
local rows={{0x28,0x29,0x29,0x285},{0x30,0x31,0x32,0x33},{0x38,0x39,0x3a,0x3b},{0x60,0x41,0x42,0x43}}
function M.register()
 if Models.info(M.id)then return true end
 local ok,data=pcall(V.require,'ImportedHoennMartData');if not ok or not data[M.id]then return nil,'original Oldale Mart source unavailable'end
 return Models.register(M.id,data[M.id],{read=function(path)return V.mod:read(path)end})
end
function M.eligible(g,cells)
 if not(g and g.kind=='mart'and g.width==4 and g.depth==4 and g.custom and g.custom.family=='rse'and g.custom.name=='oldale_mart'and g.pair=='general__petalburg'and not g.stageHidden)then return false end
 local c=cells[g.cx..':'..g.cy];local region=c and c.region;local id=region and region.def and region.def.id
 if not(id and(id=='EM_OLDALE_TOWN'or id=='RU_OLDALE_TOWN'or id=='SA_OLDALE_TOWN')and g.cx-(region.x or 0)==13 and g.cy-(region.y or 0)==3)then return false end
 local base
 for y=0,3 do for x=0,3 do local a=cells[(g.cx+x)..':'..(g.cy+y)];local permission=y==0 and(x==3 and 7 or 0)or(y==3 and x==1 and 0x71 or 7)
  if not(a and a.civic==g and a.region==region and a.mid==rows[y+1][x+1]and a.pair==g.pair and a.collision==permission and not(a.boundary or a.stageHidden))then return false end
  if y>0 then if base==nil then base=a.base or 0 elseif math.abs((a.base or 0)-base)>.001 then return false end end
 end end;return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 local fit={width=64,depth=48,padding=.25,anchor='door',targetX=24,targetZ=44.5}
 local source,placed=Models.vertices(M.id,fit);if not source then return false,placed end
 local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,source);if not safe then return false,why end;placed.model=M.id
 local doors=V.require('Gen3MartDoors');local cache,reason=doors.build(g,placed,newMesh,cells);if not cache then return false,reason end
 local result,message=Models.buildBatches({{model=M.id,x=g.cx*16,y=(g.groundHeight or 0)-.05,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then doors.release(g);return false,message end
 g.importedHoenn=placed;doors.commit(g);return true
end
return M
