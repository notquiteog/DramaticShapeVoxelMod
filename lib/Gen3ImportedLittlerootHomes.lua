-- Actual own-source ORAS Littleroot houses. Native coordinates/art/warp evidence
-- selects each original model; neither a mirror nor an unrelated house is used.
local V=...
local Models=V.require('SceneryModels')
local M={}
local west={{0x208,0x209,0x209,0x209,0x20a},{0x210,0x211,0x211,0x211,0x212},{0x218,0x219,0x219,0x219,0x21a},{0x222,0x232,0x230,0x240,0x221},{0x22a,0x23a,0x238,0x248,0x229}}
local east={{0x208,0x209,0x209,0x209,0x20a},{0x210,0x211,0x211,0x211,0x212},{0x218,0x219,0x219,0x219,0x21a},{0x220,0x240,0x231,0x232,0x223},{0x228,0x248,0x239,0x23a,0x22b}}
local families={
 ['2:4']={id='oras_littleroot_home_west',name='littleroot_player_house',width=5,rear=0,door=3,rows=west},
 ['13:4']={id='oras_littleroot_home_east',name='littleroot_rival_house',width=5,rear=0,door=1,rows=east}}
function M.family(g,cells)
 local c=g and cells[g.cx..':'..g.cy];local r=c and c.region;local id=r and r.def and r.def.id
 if not(id and(id=='EM_LITTLEROOT_TOWN'or id=='RU_LITTLEROOT_TOWN'or id=='SA_LITTLEROOT_TOWN'))then return end
 return families[(g.cx-(r.x or 0))..':'..(g.cy-(r.y or 0))],r
end
function M.register(id)
 if Models.info(id)then return true end
 local ok,data=pcall(V.require,'ImportedLittlerootHomesData');if not ok or not data[id]then return nil,'original Littleroot house unavailable'end
 return Models.register(id,data[id],{read=function(path)return V.mod:read(path)end})
end
function M.eligible(g,cells)
 if not(g and g.kind=='house'and g.depth==5 and g.pair=='general__petalburg'and g.custom and g.custom.family=='rse'and not g.stageHidden)then return false end
 local f,r=M.family(g,cells);if not(f and g.width==f.width and g.custom.name==f.name)then return false end
 local base
 for y=0,4 do for x=0,g.width-1 do local a=cells[(g.cx+x)..':'..(g.cy+y)];local permission=y==0 and f.rear or(y==4 and x==f.door and 0x71 or 7)
  if not(a and a.civic==g and a.region==r and a.pair==g.pair and a.mid==f.rows[y+1][x+1]and a.collision==permission and not(a.boundary or a.stageHidden))then return false end
  if y>0 then if base==nil then base=a.base or 0 elseif math.abs((a.base or 0)-base)>.001 then return false end end
 end end;return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local f=M.family(g,cells);local ok,err=M.register(f.id);if not ok then return false,err end
 local fit={groundInset=.05,width=g.width*16,depth=64,padding=.25,anchor='door',targetX=f.door*16+8,targetZ=54}
 local source,placed=Models.vertices(f.id,fit);if not source then return false,placed end
 local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,source);if not safe then return false,why end;placed.model=f.id
 local doors=V.require('Gen3LittlerootDoors');local cache,reason=doors.build(g,placed,newMesh,cells);if not cache then return false,reason end
 local result,message=Models.buildBatches({{model=f.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then doors.release(g);return false,message end
 g.importedHoenn=placed;doors.commit(g);return true
end
return M
