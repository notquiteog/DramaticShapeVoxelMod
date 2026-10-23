-- Regional ordinary Viridian house with the native flower-planter variant.
-- Only exact native art/permissions qualify; source failure keeps full fallback.
local V=...
local Models=V.require('SceneryModels')
local M={id='hgss_viridian_flower_house'}
local rows={{640,641,642,643,644},{648,649,650,651,652},{656,657,658,659,660},{664,665,666,667,668},{672,206,674,675,676}}
function M.eligible(g,cells)
 if not(g and g.family=='viridian_flower_house'and g.pair=='viridian_outdoor'and g.width==5 and g.depth==5 and not g.stageHidden)then return false end
 local base
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do
  local c=cells[(g.cx+x-1)..':'..(g.cy+y-1)];local permission=(y==1 or y==5)and 0 or(y==4 and x==2 and 113 or 7)
  if not(c and c.civic==g and c.pair==g.pair and c.mid==mid and c.collision==permission and not(c.boundary or c.stageHidden or c.prop))then return false end
  if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end
 end end
 return true
end
function M.register()
 if Models.info(M.id)then return true end
 local source=V.require('ViridianHouseData').hgss_viridian_house;local parts={}
 for _,p in ipairs(source.parts)do if p.role~='source_door'and p.role~='ground_shadow'and p.role~='source_shading'then parts[#parts+1]=p end end
 return Models.register(M.id,{parts=parts,anchors=source.anchors},{read=function(path)return V.mod:read(path)end})
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 local fit={width=80,depth=48,padding=.25,groundInset=.05,anchor='door',targetX=24,targetZ=35.4};local fitted,why=Models.fit(M.id,fit);if not fitted then return false,why end
 local doors=V.require('Gen3ViridianFlowerHouseDoors');local ready,reason=doors.build(g,fitted,newMesh);if not ready then return false,reason end
 local first=#parts+1
 local result,message=Models.buildBatches({{model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then doors.release(g);return false,message end
 local cards=V.require('Gen3ViridianFlowerCards');local complete,cardError=cards.build(g,fitted,newMesh,parts)
 if not complete then for i=#parts,first,-1 do Models.releaseBatches({parts[i]});parts[i]=nil end;doors.release(g);return false,cardError end
 doors.commit(g);cards.commit(g);g.importedViridianFlowerHouse=fitted;return true
end
function M.release(g)V.require('Gen3ViridianFlowerCards').release(g)end
function M.chimney(g)
 local f=g.importedViridianFlowerHouse;if not f then return end;local a=f.anchors.chimney
 return{x=g.cx*16+a[1],y=(g.groundHeight or 0)+a[2],z=(g.cy+1)*16+a[3]}
end
return M
