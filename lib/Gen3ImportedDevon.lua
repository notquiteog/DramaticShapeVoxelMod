-- Own ORAS Devon Corporation, original paired portal, original native ground.
local V=...
local Models=V.require('SceneryModels')
local M={id='oras_rustboro_devon'}
local rows={{0x288,0x289,0x289,0x28b,0x28c,0x28c,0x28d,0x289,0x289,0x28a},{0x290,0x291,0x291,0x293,0x294,0x294,0x295,0x291,0x291,0x292},{0x298,0x299,0x29a,0x28e,0x28f,0x296,0x297,0x29a,0x29a,0x29b},{0x2a0,0x2a1,0x2a2,0x29c,0x29d,0x29d,0x29e,0x2a2,0x2a2,0x2a3},{0x298,0x299,0x29a,0x2a4,0x2a5,0x2a5,0x2a6,0x29a,0x29a,0x29b},{0x2a0,0x2a1,0x2a2,0x29c,0x29d,0x29d,0x29e,0x2a2,0x2a2,0x2a3},{0x2a8,0x2a9,0x2a9,0x2a4,0x2a5,0x2a5,0x2a6,0x2aa,0x2aa,0x2ab},{0x2b0,0x2b1,0x2b1,0x2ac,0x2ad,0x2ad,0x2ae,0x2b2,0x2b2,0x2b3},{0x2c4,0x2c3,0x2c3,0x2b4,0x2b5,0x2b5,0x2b6,0x2c3,0x2c3,0x2c3}}
M.rows=rows
function M.register()
 if Models.info(M.id)then return true end
 local ok,data=pcall(V.require,'ImportedRustboroDevonData');if not ok or not data[M.id]then return nil,'original Devon building unavailable'end
 return Models.register(M.id,data[M.id],{read=function(path)return V.mod:read(path)end})
end
function M.eligible(g,cells)
 if not(g and g.kind=='devon'and g.width==10 and g.depth==9 and g.pair=='general__rustboro'and g.custom and g.custom.family=='rse'and g.custom.name=='rustboro_devon_corporation'and (g.custom.geometry=='devon'or g.custom.geometry=='landmark')and g.custom.preserveWalkableFloor and not g.stageHidden)then return false end
 local c=cells[g.cx..':'..g.cy];local r=c and c.region;local id=r and r.def and r.def.id
 if not(id and(id=='EM_RUSTBORO_CITY'or id=='RU_RUSTBORO_CITY'or id=='SA_RUSTBORO_CITY')and g.cx-(r.x or 0)==7 and g.cy-(r.y or 0)==7)then return false end
 local base
 for y=0,8 do for x=0,9 do local a=cells[(g.cx+x)..':'..(g.cy+y)];local permission=y<8 and 7 or(x==3 or x==6)and 7 or(x==4 or x==5)and 113 or 0
  if not(a and a.civic==g and a.region==r and a.pair==g.pair and a.mid==rows[y+1][x+1]and a.collision==permission and not(a.boundary or a.stageHidden))then return false end
  if permission==7 or permission==113 then if base==nil then base=a.base or 0 elseif math.abs((a.base or 0)-base)>.001 then return false end end
 end end;return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 local fit={groundInset=.05,width=160,depth=128,padding=4,anchor='door',targetX=80,targetZ=118}
 local source,placed=Models.vertices(M.id,fit);if not source then return false,placed end
 local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,source);if not safe then return false,why end;placed.model=M.id
 local doors=V.require('Gen3DevonDoors');local cache,reason=doors.build(g,placed,newMesh,cells);if not cache then return false,reason end
 local result,message=Models.buildBatches({{model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then doors.release(g);return false,message end
 g.importedHoenn=placed;doors.commit(g);return true
end
return M
