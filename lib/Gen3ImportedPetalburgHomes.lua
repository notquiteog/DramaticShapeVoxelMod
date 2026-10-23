-- Actual own-source ORAS Petalburg houses. Native coordinates/art/warp evidence
-- selects each original model; neither a mirror nor an unrelated house is used.
local V=...
local Models=V.require('SceneryModels')
local M={}
local narrow={{8,9,9,10},{16,17,17,18},{24,25,11,26},{32,33,19,34}}
local wide={{8,9,9,9,10},{16,17,17,17,18},{24,11,25,11,26},{32,19,33,19,34}}
local families={
 ['5:2']={id='oras_petalburg_home_wide',name='petalburg_city_wide_home',width=5,rear=7,door=2,rows=wide},
 ['9:16']={id='oras_petalburg_home_west',name='petalburg_city_home',width=4,rear=0,door=1,rows=narrow},
 ['19:21']={id='oras_petalburg_home_east',name='petalburg_city_home',width=4,rear=7,door=1,rows=narrow}}
function M.family(g,cells)
 local c=g and cells[g.cx..':'..g.cy];local r=c and c.region;local id=r and r.def and r.def.id
 if not(id and(id=='EM_PETALBURG_CITY'or id=='RU_PETALBURG_CITY'or id=='SA_PETALBURG_CITY'))then return end
 return families[(g.cx-(r.x or 0))..':'..(g.cy-(r.y or 0))],r
end
function M.register(id)
 if Models.info(id)then return true end
 local ok,data=pcall(V.require,'ImportedPetalburgHomesData');if not ok or not data[id]then return nil,'original Petalburg house unavailable'end
 return Models.register(id,data[id],{read=function(path)return V.mod:read(path)end})
end
function M.eligible(g,cells)
 if not(g and g.kind=='house'and g.depth==4 and g.pair=='general__petalburg'and g.custom and g.custom.family=='rse'and not g.stageHidden)then return false end
 local f,r=M.family(g,cells);if not(f and g.width==f.width and g.custom.name==f.name)then return false end
 local base
 for y=0,3 do for x=0,g.width-1 do local a=cells[(g.cx+x)..':'..(g.cy+y)];local permission=y==0 and f.rear or(y==3 and x==f.door and 0x71 or 7)
  if not(a and a.civic==g and a.region==r and a.pair==g.pair and a.mid==f.rows[y+1][x+1]and a.collision==permission and not(a.boundary or a.stageHidden))then return false end
  if y>0 then if base==nil then base=a.base or 0 elseif math.abs((a.base or 0)-base)>.001 then return false end end
 end end;return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local f=M.family(g,cells);local ok,err=M.register(f.id);if not ok then return false,err end
 local fit={groundInset=.05,width=g.width*16,depth=48,padding=.25,anchor='door',targetX=f.door*16+8,targetZ=41}
 local source,placed=Models.vertices(f.id,fit);if not source then return false,placed end
 local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,source);if not safe then return false,why end;placed.model=f.id
 local doors=V.require('Gen3PetalburgDoors');local cache,reason=doors.build(g,placed,newMesh,cells);if not cache then return false,reason end
 local result,message=Models.buildBatches({{model=f.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then doors.release(g);return false,message end
 g.importedHoenn=placed;doors.commit(g);return true
end
return M
