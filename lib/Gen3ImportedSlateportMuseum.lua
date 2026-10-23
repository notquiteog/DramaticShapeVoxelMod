-- Own ORAS Oceanic Museum, original paired portal, original native ground.
local V=...
local Models=V.require('SceneryModels')
local M={id='oras_slateport_museum'}
local rows={{0x308,0x309,0x30a,0x30a,0x30b,0x30c},{0x310,0x311,0x312,0x2fb,0x313,0x314},{0x318,0x319,0x31a,0x303,0x31b,0x31c},{0x320,0x321,0x322,0x322,0x323,0x324},{0x328,0x329,0x32a,0x32a,0x32b,0x32c}}
M.rows=rows
function M.register()
 if Models.info(M.id)then return true end
 local ok,data=pcall(V.require,'ImportedSlateportMuseumData');if not ok or not data[M.id]then return nil,'original Oceanic Museum unavailable'end
 return Models.register(M.id,data[M.id],{read=function(path)return V.mod:read(path)end})
end
function M.eligible(g,cells)
 if not(g and g.kind=='oceanic_museum'and g.width==6 and g.depth==5 and g.pair=='general__slateport'and g.custom and g.custom.family=='rse'and g.custom.name=='slateport_oceanic_museum'and not g.stageHidden)then return false end
 local c=cells[g.cx..':'..g.cy];local r=c and c.region;local id=r and r.def and r.def.id
 if not(id and(id=='EM_SLATEPORT_CITY'or id=='RU_SLATEPORT_CITY'or id=='SA_SLATEPORT_CITY')and g.cx-(r.x or 0)==28 and g.cy-(r.y or 0)==22)then return false end
 local base
 for y=0,4 do for x=0,5 do local a=cells[(g.cx+x)..':'..(g.cy+y)];local permission=y==4 and(x==2 or x==3)and 113 or 7
  if not(a and a.civic==g and a.region==r and a.pair==g.pair and a.mid==rows[y+1][x+1]and a.collision==permission and not(a.boundary or a.stageHidden))then return false end
  if permission==7 or permission==113 then if base==nil then base=a.base or 0 elseif math.abs((a.base or 0)-base)>.001 then return false end end
 end end;return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 local fit={groundInset=.05,width=96,depth=64,padding=.25,anchor='door',targetX=48,targetZ=59.25}
 local source,placed=Models.vertices(M.id,fit);if not source then return false,placed end
 local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,source);if not safe then return false,why end;placed.model=M.id
 local doors=V.require('Gen3MuseumDoors');local cache,reason=doors.build(g,placed,newMesh,cells);if not cache then return false,reason end
 local result,message=Models.buildBatches({{model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then doors.release(g);return false,message end
 g.importedHoenn=placed;doors.commit(g);return true
end
return M
