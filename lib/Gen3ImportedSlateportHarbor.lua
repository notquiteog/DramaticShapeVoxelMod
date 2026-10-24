-- Own ORAS Oceanic Harbor, original native portal, original native ground.
local V=...
local Models=V.require('SceneryModels')
local M={id='oras_slateport_harbor'}
local rows={{0x295,0x296,0x296,0x296,0x296,0x296,0x297},{0x29d,0x29e,0x29e,0x29e,0x29e,0x29e,0x29f},{0x29d,0x29e,0x29e,0x29e,0x29e,0x29e,0x29f},{0x2a5,0x2a6,0x2a6,0x2a6,0x2a6,0x2a6,0x2a7},{0x2ad,0x268,0x2bd,0x2be,0x2bf,0x269,0x2af},{0x2b5,0x2b6,0x2c5,0x2c6,0x2d7,0x2b6,0x2b7}}
M.rows=rows
function M.register()
 if Models.info(M.id)then return true end
 local ok,data=pcall(V.require,'ImportedSlateportHarborData');if not ok or not data[M.id]then return nil,'original Oceanic Harbor unavailable'end
 return Models.register(M.id,data[M.id],{read=function(path)return V.mod:read(path)end})
end
function M.eligible(g,cells)
 if not(g and g.kind=='harbor'and g.width==7 and g.depth==6 and g.pair=='general__slateport'and g.custom and g.custom.family=='rse'and g.custom.name=='slateport_harbor'and not g.stageHidden)then return false end
 local c=cells[g.cx..':'..g.cy];local r=c and c.region;local id=r and r.def and r.def.id
 if not(id and(id=='EM_SLATEPORT_CITY'or id=='RU_SLATEPORT_CITY'or id=='SA_SLATEPORT_CITY')and g.cx-(r.x or 0)==25 and g.cy-(r.y or 0)==7)then return false end
 local base
 for y=0,5 do for x=0,6 do local a=cells[(g.cx+x)..':'..(g.cy+y)];local permission=y==5 and x==3 and 113 or 7
  if not(a and a.civic==g and a.region==r and a.pair==g.pair and a.mid==rows[y+1][x+1]and a.collision==permission and not(a.boundary or a.stageHidden))then return false end
  if permission==7 or permission==113 then if base==nil then base=a.base or 0 elseif math.abs((a.base or 0)-base)>.001 then return false end end
 end end;return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 local fit={groundInset=.05,width=112,depth=80,padding=.25,anchor='door',targetX=56,targetZ=74.25}
 local source,placed=Models.vertices(M.id,fit);if not source then return false,placed end
 local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,source);if not safe then return false,why end;placed.model=M.id
 local doors=V.require('Gen3HarborDoors');local cache,reason=doors.build(g,placed,newMesh,cells);if not cache then return false,reason end
 local result,message=Models.buildBatches({{model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then doors.release(g);return false,message end
 g.importedHoenn=placed;doors.commit(g);return true
end
return M
