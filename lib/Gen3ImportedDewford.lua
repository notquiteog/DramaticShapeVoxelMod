-- The actual ORAS Dewford narrow-house family. Existing native recipes own
-- family recognition and their fallback; this adapter never claims new cells.
local V=...
local Models=V.require('SceneryModels')
local M={id='oras_dewford_narrow_house'}
local registered=false
local rows={
 dewford_town_home={{0x20b,0x20c,0x212,0x218},{0x213,0x214,0x214,0x215},{0x20e,0x21d,0x21e,0x20f},{0x216,0x225,0x226,0x217}},
 dewford_town_south_home={{0x20b,0x20c,0x20c,0x20d},{0x213,0x214,0x214,0x215},{0x20e,0x21d,0x21e,0x20f},{0x216,0x225,0x226,0x217}}}
local rear={dewford_town_home={0,0,7,7},dewford_town_south_home={0,0,0,0}}
M.families=rows
function M.register()
 if registered then return true end
 local source=V.require('ImportedDewfordData')[M.id]
 local ok,err=Models.register(M.id,source,{read=function(path)return V.mod:read(path)end})
 if not ok then return nil,err end
 registered=true;return true
end
function M.eligible(g,cells)
 local name=g.custom and g.custom.name;local expected=rows[name]
 if not expected or g.custom.family~='rse' or g.pair~='general__dewford'
  or g.kind~='house' or g.width~=4 or g.depth~=4 or g.stageHidden then return false end
 local base
 for y=0,3 do for x=0,3 do
  local c=cells[(g.cx+x)..':'..(g.cy+y)]
  local permission=y==0 and rear[name][x+1] or(y==3 and x==1 and 0x71 or 7)
  if not c or c.civic~=g or c.pair~=g.pair or c.mid~=expected[y+1][x+1]
   or c.collision~=permission or c.boundary or c.stageHidden then return false end
  if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end
 end end
 return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 -- Preserve the entire source object, including ridge knobs and overhangs.
 -- The first native art row contains walkable cells; the whole mesh remains
 -- inside the three solid rows. Both original narrow homes share this shape.
 local fit={groundInset=.05,width=64,depth=48,padding=.25,anchor='door',targetX=24,targetZ=43.05}
 local placed=assert(Models.fit(M.id,fit));placed.model=M.id
 local doors=V.require('Gen3DewfordDoors')
 local door,doorError=doors.build(g,placed,newMesh)
 if not door then return false,doorError end
 local result,why=Models.buildBatches({{model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then doors.release(g);return false,why end
 g.importedHoenn=placed;doors.commit(g)
 return true
end
function M.doorSurface(g,tx,ty)
 local fit=g.importedHoenn
 if not fit or fit.model~=M.id or tx~=g.cx+1 or ty~=g.cy+3 then return end
 local a,b,c=fit.anchors.doorLeft,fit.anchors.doorRight,fit.anchors.doorTop
 local x,z=g.cx*16,(g.cy+1)*16+a[3]+.025
 return {w=14,h=18,sourceX=g.cx*16+17,sourceY=g.cy*16+45,base=g.groundHeight or 0,
  vertices={{x+a[1],c[2],z},{x+b[1],c[2],z},{x+b[1],a[2],z},{x+a[1],a[2],z}}}
end
return M
