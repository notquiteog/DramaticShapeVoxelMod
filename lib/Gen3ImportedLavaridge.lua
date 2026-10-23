-- Two original ORAS Lavaridge homes. Native front drawings are shared, but
-- source side windows differ, so retain the actual west/east source variants.
local V=...
local Models=V.require('SceneryModels')
local M={ids={herb='oras_lavaridge_herb_shop_native',home='oras_lavaridge_home_native'}}
local sourceIds={[M.ids.herb]='oras_lavaridge_herb_shop',[M.ids.home]='oras_lavaridge_home'}
local maps={RU_LAVARIDGE_TOWN=true,SA_LAVARIDGE_TOWN=true,EM_LAVARIDGE_TOWN=true}
local rows={{8,9,9,10},{16,17,17,18},{24,25,11,26},{32,33,19,34}}
local registered={}
function M.depthShift(z,bays)
 local out=z
 for _,b in ipairs(bays)do
  if z<=b.start then out=out+b.shorten
  elseif z<b.finish then out=out+b.shorten*(b.finish-z)/(b.finish-b.start)end
 end
 return out
end
function M.register(id)
 if not sourceIds[id]then return nil,'unknown Lavaridge source variant'end
 if registered[id]then return true end
 local source=V.require('ImportedLavaridgeData')[sourceIds[id]];local d={parts={},anchors={}}
 for name,a in pairs(source.anchors)do d.anchors[name]={a[1],a[2],M.depthShift(a[3],source.nativeDepthBays)}end
 for i,p in ipairs(source.parts)do
  local q={};for k,value in pairs(p)do q[k]=value end;q.vertices={}
  for j,v in ipairs(p.vertices)do local row={unpack(v)};row[3]=M.depthShift(row[3],source.nativeDepthBays);q.vertices[j]=row end
  d.parts[i]=q
 end
 local ok,err=Models.register(id,d,{read=function(path)return V.mod:read(path)end})
 if not ok then return nil,err end
 registered[id]=true;return true
end
function M.modelFor(g,cells)
 local c=cells[g.cx..':'..g.cy];local r=c and c.region
 if not(r and r.def and maps[r.def.id])or g.cy-(r.y or 0)~=12 then return end
 local x=g.cx-(r.x or 0)
 if x==11 then return M.ids.herb,r elseif x==15 then return M.ids.home,r end
end
function M.eligible(g,cells)
 if not(g.custom and g.custom.family=='rse' and g.custom.name=='lavaridge_town_home')
  or g.pair~='general__lavaridge' or g.kind~='house' or g.width~=4 or g.depth~=4 or g.stageHidden then return false end
 local id,region=M.modelFor(g,cells);if not id then return false end
 local base
 for y=0,3 do for x=0,3 do
  local c=cells[(g.cx+x)..':'..(g.cy+y)]
  local permission=y==0 and 0 or(y==3 and x==1 and 0x71 or 7)
  if not c or c.civic~=g or c.pair~=g.pair or c.mid~=rows[y+1][x+1] or c.region~=region
   or c.collision~=permission or c.boundary or c.stageHidden then return false end
  if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end
 end end
 return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local id=M.modelFor(g,cells);local ok,err=M.register(id);if not ok then return false,err end
 -- Shorten two empty side-wall bays4sourceunits each, preserving the full
 -- windows, corner posts, front portal and vent pipe as rigid assemblies.
 -- Every vertex stays in the three native blocked body rows.
 local fit={groundInset=.05,width=64,depth=48,padding=.25,anchor='door',targetX=24,targetZ=39.05}
 local result,why=Models.buildBatches({{model=id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then return false,why end
 g.importedHoenn=assert(Models.fit(id,fit));g.importedHoenn.model=id
 return true
end
function M.doorSurface(g,tx,ty)
 local fit=g.importedHoenn
 if not fit or not sourceIds[fit.model] or tx~=g.cx+1 or ty~=g.cy+3 then return end
 local a,b,c=fit.anchors.doorLeft,fit.anchors.doorRight,fit.anchors.doorTop
 local x,z=g.cx*16,(g.cy+1)*16+a[3]+.025
 return {w=14,h=18,sourceX=g.cx*16+17,sourceY=g.cy*16+45,base=g.groundHeight or 0,
  vertices={{x+a[1],c[2],z},{x+b[1],c[2],z},{x+b[1],a[2],z},{x+a[1],a[2],z}}}
end
return M
