-- Own original ORAS Oldale homes, including distinct front/side source glazing.
-- Native cells, original ground, collision and x+1/y+3 doorway stay authoritative.
local V=...
local Models=V.require('SceneryModels')
local M={}
local rows={{0x26c,0x26d,0x26d,0x26e},{0x274,0x275,0x275,0x276},{0x27c,0x27f,0x27d,0x27e},{0x284,0x287,0x28f,0x286}}
function M.modelFor(g,cells)
 local c=g and cells[g.cx..':'..g.cy];local r=c and c.region;local id=r and r.def and r.def.id
 if not(id and(id=='EM_OLDALE_TOWN'or id=='RU_OLDALE_TOWN'or id=='SA_OLDALE_TOWN'))then return end
 local x,y=g.cx-(r.x or 0),g.cy-(r.y or 0)
 if x==4 and y==4 then return 'oras_oldale_home_northwest',r elseif x==14 and y==13 then return 'oras_oldale_home_southeast',r end
end
function M.register(id)
 if Models.info(id)then return true end
 local ok,d=pcall(V.require,'ImportedOldaleHomesData');if not ok or not d[id]then return nil,'original Oldale home source unavailable'end
 return Models.register(id,d[id],{read=function(path)return V.mod:read(path)end})
end
function M.eligible(g,cells)
 if not(g and g.kind=='house'and g.width==4 and g.depth==4 and g.pair=='general__petalburg'and g.custom and g.custom.family=='rse'and g.custom.name=='oldale_house'and not g.stageHidden)then return false end
 local id,region=M.modelFor(g,cells);if not id then return false end
 local base
 for y=0,3 do for x=0,3 do local a=cells[(g.cx+x)..':'..(g.cy+y)];local permission=y==0 and 0 or(y==3 and x==1 and 0x71 or 7)
  if not(a and a.civic==g and a.region==region and a.pair==g.pair and a.mid==rows[y+1][x+1]and a.collision==permission and not(a.boundary or a.stageHidden))then return false end
  if y>0 then if base==nil then base=a.base or 0 elseif math.abs((a.base or 0)-base)>.001 then return false end end
 end end;return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local id=M.modelFor(g,cells);local ok,err=M.register(id);if not ok then return false,err end
 local fit={width=64,depth=48,padding=.25,anchor='door',targetX=24,targetZ=41}
 local source,placed=Models.vertices(id,fit);if not source then return false,placed end
 local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,source);if not safe then return false,why end;placed.model=id
 local doors=V.require('Gen3OldaleDoors');local cache,reason=doors.build(g,placed,newMesh,cells);if not cache then return false,reason end
 local function upload(vertices,indices,format)
  local cap=#vertices==28 and #indices==78
  if cap then for _,v in ipairs(vertices)do if math.abs(v[2])>1e-7 then cap=false;break end end end
  if cap then local copy={};for i,v in ipairs(vertices)do copy[i]={unpack(v)};copy[i][2]=v[2]-.05 end;vertices=copy end
  return newMesh(vertices,indices,format)
 end
 local result,message=Models.buildBatches({{model=id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},upload,{parts=parts})
 if not result then doors.release(g);return false,message end
 g.importedHoenn=placed;doors.commit(g);return true
end
return M
