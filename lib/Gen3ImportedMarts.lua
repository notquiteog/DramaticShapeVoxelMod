-- Genuine original ORAS Oldale/Petalburg/Rustboro Mart variants. Each town
-- retains its own source topology/UVs; other families remain native fallback.
local V=...
local Models=V.require('SceneryModels')
local M={id='oras_oldale_mart'}
local oldaleRows={{0x28,0x29,0x29,0x285},{0x30,0x31,0x32,0x33},{0x38,0x39,0x3a,0x3b},{0x60,0x41,0x42,0x43}}
local families={
 oldale_mart={id='oras_oldale_mart',map='OLDALE_TOWN',pair='general__petalburg',x=13,y=3,rear={0,0,0,7},rows=oldaleRows},
 petalburg_city_mart={id='oras_petalburg_mart',map='PETALBURG_CITY',pair='general__petalburg',x=24,y=9,rear={0,0,7,7},rows={{0x250,0x251,0x258,0x259},{0x30,0x31,0x32,0x33},{0x38,0x39,0x3a,0x3b},{0x60,0x41,0x42,0x43}}},
 rustboro_city_mart={id='oras_rustboro_mart',map='RUSTBORO_CITY',pair='general__rustboro',x=15,y=42,rear={0,0,0,0},rows={{0x325,0x267,0x267,0x326},{0x30,0x31,0x32,0x33},{0x38,0x39,0x3a,0x3b},{0x266,0x41,0x42,0x27f}}}}
function M.register(id)
 id=id or M.id
 if Models.info(id)then return true end
 local ok,data=pcall(V.require,'ImportedHoennMartData');if not ok or not data[id]then return nil,'original native-town Mart source unavailable'end
 return Models.register(id,data[id],{read=function(path)return V.mod:read(path)end})
end
function M.eligible(g,cells)
 local f=g and g.custom and families[g.custom.name]
 if not(f and g.kind=='mart'and g.width==4 and g.depth==4 and g.custom.family=='rse'and g.pair==f.pair and not g.stageHidden)then return false end
 local c=cells[g.cx..':'..g.cy];local region=c and c.region;local id=region and region.def and region.def.id
 if not(id and(id=='EM_'..f.map or id=='RU_'..f.map or id=='SA_'..f.map)and g.cx-(region.x or 0)==f.x and g.cy-(region.y or 0)==f.y)then return false end
 local base
 for y=0,3 do for x=0,3 do local a=cells[(g.cx+x)..':'..(g.cy+y)];local permission=y==0 and f.rear[x+1]or(y==3 and x==1 and 0x71 or 7)
  if not(a and a.civic==g and a.region==region and a.mid==f.rows[y+1][x+1]and a.pair==g.pair and a.collision==permission and not(a.boundary or a.stageHidden))then return false end
  if y>0 then if base==nil then base=a.base or 0 elseif math.abs((a.base or 0)-base)>.001 then return false end end
 end end;return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local id=families[g.custom.name].id;local ok,err=M.register(id);if not ok then return false,err end
 local fit={width=64,depth=48,padding=.25,anchor='door',targetX=24,targetZ=44.5}
 local source,placed=Models.vertices(id,fit);if not source then return false,placed end
 local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,source);if not safe then return false,why end;placed.model=id
 local doors=V.require('Gen3MartDoors');local cache,reason=doors.build(g,placed,newMesh,cells);if not cache then return false,reason end
 local result,message=Models.buildBatches({{model=id,x=g.cx*16,y=(g.groundHeight or 0)-.05,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then doors.release(g);return false,message end
 g.importedHoenn=placed;doors.commit(g);return true
end
return M
