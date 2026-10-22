-- ORAS Center, adapted to the original Hoenn entrance and blocked rectangle.
local V=...
local Models=V.require('SceneryModels')
local M={id='oras_hoenn_center_left_door'}
local registered=false
local function shift(x)
 -- Keep the doorway/arched badge rigid. Fixed outer edges retain the source
 -- footprint; the right-hand display remains rigid too. Only adjoining wall
 -- and roof spans change length, with all UVs and connected joins retained.
 local xs={-.5,-.22,.22,.24,.5}
 local ys={-.5,-.345,.095,.24,.5}
 for i=1,#xs-1 do if x<=xs[i+1]then
  return ys[i]+(x-xs[i])*(ys[i+1]-ys[i])/(xs[i+1]-xs[i])
 end end
 return x
end
function M.register()
 if registered then return true end
 local source=V.require('SceneryModelData').oras_pokemon_center
 local d={parts={},anchors={}}
 for k,p in pairs(source.anchors)do d.anchors[k]={shift(p[1]),p[2],p[3]}end
 for i,p in ipairs(source.parts)do
  local q={};for k,value in pairs(p)do q[k]=value end;q.vertices={}
  for j,v in ipairs(p.vertices)do local row={unpack(v)};row[1]=shift(row[1]);q.vertices[j]=row end
  d.parts[i]=q
 end
 local ok,err=Models.register(M.id,d,{read=function(path)return V.mod:read(path)end})
 if not ok then return nil,err end
 registered=true;return true
end
function M.eligible(g,cells)
 if g.kind~='center' or not(g.custom and g.custom.family=='rse' and g.custom.centerRoof)
  or g.width~=4 or g.depth~=4 or g.stageHidden then return false end
 -- The top drawing row is a roof overhang in the original art. It can be
 -- walkable ground, solid terrain or Pacifidlog water; no mesh enters it.
 local rear=cells[g.cx..':'..g.cy];local rearPermission=rear and rear.collision
 if rearPermission~=0 and rearPermission~=7 and rearPermission~=0x29 then return false end
 local base
 for y=0,3 do for x=0,3 do
  local c=cells[(g.cx+x)..':'..(g.cy+y)]
  local expected=y==0 and rearPermission or(y==3 and x==1 and 0x71 or 7)
  if not c or c.civic~=g or c.collision~=expected or c.boundary or c.stageHidden then return false end
  if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end
 end end
 return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 local fit={width=64,depth=48,padding=.25,anchor='door',targetX=24,targetZ=47}
 local placement={model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}
 local result,why=Models.buildBatches({placement},newMesh,{parts=parts})
 if not result then return false,why end
 g.importedCenter=assert(Models.fit(M.id,fit))
 return true
end
function M.doorSurface(g,tx,ty)
 if not g.importedCenter or tx~=g.cx+1 or ty~=g.cy+3 then return end
 local a=g.importedCenter.anchors.door
 local x,z=g.cx*16+a[1],(g.cy+1)*16+a[3]+.025
 -- The native animated panel fits inside the source arch, below its transom.
 return {w=14,h=16,sourceX=g.cx*16+17,sourceY=g.cy*16+45,base=g.groundHeight or 0,
  vertices={{x-7,16,z},{x+7,16,z},{x+7,0,z},{x-7,0,z}}}
end
M.shift=shift
return M
