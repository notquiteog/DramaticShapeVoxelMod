-- Exact native FR/LG Pewter ordinary houses, using the newer regional HGSS scene.
-- Native collision/warps remain untouched; commit presentation only after upload.
local V=...
local Models=V.require('SceneryModels')
local M={id='hgss_pewter_house'};local registered=false
local rows={{687,702,702,702,655},{695,710,688,689,663},{703,718,696,697,671}}
function M.eligible(g,cells)
 if g.family~='pewter_house'or not g.custom or g.pair~='pewter_outdoor'or g.width~=5 or g.depth~=3 or g.stageHidden then return false end
 local base
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do
  local c=cells[(g.cx+x-1)..':'..(g.cy+y-1)]
  local permission=y==3 and x==2 and 0x71 or 7
  if not c or c.civic~=g or c.pair~=g.pair or c.mid~=mid or c.collision~=permission or c.boundary or c.stageHidden or c.prop then return false end
  if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end
 end end
 return true
end
function M.register()
 if registered then return true end
 local ok,err=Models.register(M.id,V.require('PewterHouseData')[M.id],{read=function(path)return V.mod:read(path)end})
 if ok then registered=true end;return ok,err
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 local fit={width=80,depth=48,padding=.25,groundInset=.05,anchor='door',targetX=24,targetZ=40}
 local fitted,fitError=Models.fit(M.id,fit);if not fitted then return false,fitError end
 local doors=V.require('Gen3PewterHouseDoors');local ready,doorError=doors.build(g,fitted,newMesh);if not ready then return false,doorError end
 local p={model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=g.cy*16,fit=fit}
 local result,why=Models.buildBatches({p},newMesh,{parts=parts});if not result then doors.release(g);return false,why end
 doors.commit(g)
 g.importedPewterHouse=assert(Models.fit(M.id,fit));return true
end
function M.doorSurface(g,tx,ty)
 local f=g.importedPewterHouse;if not f or tx~=g.cx+1 or ty~=g.cy+2 then return end
 local a=f.anchors.door;local x,z=g.cx*16+a[1],g.cy*16+a[3]+.025
 local half,height=10*f.scale/66.67578,28.97559*f.scale/66.67578
 return{w=14,h=16,sourceX=g.cx*16+17,sourceY=(g.cy+2)*16,base=g.groundHeight or 0,
  vertices={{x-half,a[2]+height,z},{x+half,a[2]+height,z},{x+half,a[2],z},{x-half,a[2],z}}}
end
function M.chimney(g)
 local f=g.importedPewterHouse;if not f then return end
 local a=f.anchors.chimney;return{x=g.cx*16+a[1],y=(g.groundHeight or 0)+a[2],z=g.cy*16+a[3]}
end
return M
