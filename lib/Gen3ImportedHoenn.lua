-- Original ORAS Route104 Briney exterior. Eligibility never changes native
-- collision, map art or warps; missing public resources retain Civic fallback.
local V=...
local Models=V.require('SceneryModels')
local M={id='oras_route104_briney_house'}
local registered=false
local rows={{0x268,0x269,0x26a,0x26b,0x26c},{0x270,0x271,0x272,0x273,0x274},
 {0x278,0x279,0x27a,0x27b,0x27c},{0x280,0x281,0x282,0x283,0x284}}
local permissions={{0,0,0,0,0},{7,7,7,7,7},{7,7,7,7,7},{7,7,0x71,7,7}}
-- Append this family to the ordinary Hoenn exterior recipes before Civic.prepare.
-- Its ordinary native-art Civic shell is also the missing-resource fallback.
M.recipes={{family='rse',name='route104_briney_house',pair='general__rustboro',header=4,
 rows=rows,permissions=permissions,back=2,bodyBack=16,roofEnd=36,wallBottom=63,
 bevel=0,roofShape='gable',roofRise=13,openings={{33,45,47,63,door=true}},
 groundCandidates={[1]=true},wallSample={5,57},trimSample={5,40}}}
function M.register()
 if registered then return true end
 local data=V.require('ImportedHoennData')
 local ok,err=Models.register(M.id,data[M.id],{read=function(path)return V.mod:read(path)end})
 if not ok then return nil,err end
 registered=true;return true
end
function M.eligible(g,cells)
 if not(g.custom and g.custom.family=='rse' and g.custom.name=='route104_briney_house')
  or g.pair~='general__rustboro' or g.kind~='house' or g.width~=5 or g.depth~=4
  or g.stageHidden then return false end
 local base
 for y=0,3 do for x=0,4 do
  local c=cells[(g.cx+x)..':'..(g.cy+y)]
  if not c or c.civic~=g or c.pair~=g.pair or c.mid~=rows[y+1][x+1]
   or c.collision~=permissions[y+1][x+1] or c.boundary or c.stageHidden then return false end
  if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end
 end end
 return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 -- Rear art row47 is walkable. All house/deck/support vertices stay inside
 -- the original solid80x48 rectangle at rows48..50. Uniform scale preserves
 -- the complete source house and attachments; entrance X matches native17.
 local fit={width=80,depth=48,padding=.25,anchor='door',targetX=40,targetZ=38}
 local placement={model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}
 local result,why=Models.buildBatches({placement},newMesh,{parts=parts})
 if not result then return false,why end
 g.importedHoenn=assert(Models.fit(M.id,fit))
 return true
end
function M.doorSurface(g,tx,ty)
 if not g.importedHoenn or tx~=g.cx+2 or ty~=g.cy+3 then return end
 local fit=g.importedHoenn;local a=fit.anchors.door;local top=fit.anchors.doorTop
 local x,z=g.cx*16+a[1],(g.cy+1)*16+a[3]+.025
 local half=12/132.5*fit.scale
 return {w=14,h=18,sourceX=g.cx*16+33,sourceY=g.cy*16+45,base=g.groundHeight or 0,
  vertices={{x-half,top[2],z},{x+half,top[2],z},{x+half,a[2],z},{x-half,a[2],z}}}
end
return M
