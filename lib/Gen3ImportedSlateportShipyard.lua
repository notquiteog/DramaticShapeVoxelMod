-- Own ORAS Stern Shipyard, original paired portal, original native ground.
local V=...
local Models=V.require('SceneryModels')
-- Preserved source prototype only. No production dispatcher selects this module;
-- deliberate scratch opt-in is required until native fit/clearance acceptance.
local M={id='oras_slateport_shipyard',prototype=true,enabled=false}
local rows={{0x290,0x293,0x291,0x291,0x291,0x291,0x293,0x292},{0x298,0x29b,0x299,0x299,0x299,0x299,0x29b,0x29a},{0x300,0x301,0x301,0x301,0x301,0x301,0x301,0x302},{0x300,0x301,0x301,0x301,0x301,0x301,0x301,0x302},{0x2a0,0x2a1,0x2a1,0x2a1,0x2ab,0x2a1,0x2ab,0x2a2},{0x2a8,0x2a9,0x2ac,0x2a9,0x2a9,0x2a9,0x2a9,0x2aa},{0x2b0,0x2b1,0x2b4,0x2b1,0x2b1,0x2b1,0x2b1,0x2b2}}
M.rows=rows
function M.register()
 if Models.info(M.id)then return true end
 local ok,data=pcall(V.require,'ImportedSlateportShipyardData');if not ok or not data[M.id]then return nil,'original Stern Shipyard unavailable'end
 return Models.register(M.id,data[M.id],{read=function(path)return V.mod:read(path)end})
end
function M.eligible(g,cells)
 if not M.enabled then return false end
 if not(g and g.kind=='shipyard'and g.width==8 and g.depth==7 and g.pair=='general__slateport'and g.custom and g.custom.family=='rse'and g.custom.name=='slateport_shipyard'and not g.stageHidden)then return false end
 local c=cells[g.cx..':'..g.cy];local r=c and c.region;local id=r and r.def and r.def.id
 if not(id and(id=='EM_SLATEPORT_CITY'or id=='RU_SLATEPORT_CITY'or id=='SA_SLATEPORT_CITY')and g.cx-(r.x or 0)==24 and g.cy-(r.y or 0)==32)then return false end
 local base
 for y=0,6 do for x=0,7 do local a=cells[(g.cx+x)..':'..(g.cy+y)];local permission=y==6 and x==2 and 113 or 7
  if not(a and a.civic==g and a.region==r and a.pair==g.pair and a.mid==rows[y+1][x+1]and a.collision==permission and not(a.boundary or a.stageHidden))then return false end
  if permission==7 or permission==113 then if base==nil then base=a.base or 0 elseif math.abs((a.base or 0)-base)>.001 then return false end end
 end end;return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 local fit={groundInset=.05,width=128,depth=96,padding=.25,anchor='door',targetX=40,targetZ=91.25}
 local source,placed=Models.vertices(M.id,fit);if not source then return false,placed end
 local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,source);if not safe then return false,why end;placed.model=M.id
 local doors=V.require('Gen3ShipyardDoor');local cache,reason=doors.build(g,placed,newMesh,cells);if not cache then return false,reason end
 local result,message=Models.buildBatches({{model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then doors.release(g);return false,message end
 g.importedHoenn=placed;doors.commit(g);return true
end
return M
