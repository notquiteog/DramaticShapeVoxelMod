-- Genuine separately-instanced ORAS Center doors. Source BM0008 panel bones,
-- textures and opening track; native engine frame/warp ownership is untouched.
local V=...
local Models=V.require('SceneryModels')
local Budget=V.require('BuildBudget')
local M={id='oras_center_sliding_panels'}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
local function source()
 local ok,d=pcall(V.require,'ImportedCenterDoorData')
 if ok and type(d)=='table'and d.id==M.id then return d end
 return nil,'original ORAS Center door source unavailable'
end
function M.register()
 if Models.info(M.id)then return true end
 local d,err=source();if not d then return nil,err end
 return Models.register(M.id,{parts=d.parts},{read=function(path)return V.mod:read(path)end})
end
function M.geometry(g,fit,state)
 local d,err=source();if not d then return nil,err end
 local a=fit and fit.anchors and fit.anchors.door
 if not(g and g.kind=='center'and g.width==4 and g.depth==4 and g.custom and g.custom.family=='rse'
  and g.custom.centerRoof and not g.stageHidden and fit and fit.width==64 and fit.depth==48
  and finite(fit.scale)and fit.scale>0 and a and finite(a[1])and finite(a[2])and finite(a[3])
  and finite(g.cx)and finite(g.cy)and finite(g.groundHeight or 0))then return nil,'unreviewed ORAS Center doorway'end
 if state~=0 and state~=1 and state~=2 then return nil,'invalid source door state'end
 local aperture=d.aperture
 local ratio=math.min(aperture.width/d.sourceSpan,aperture.height/d.sourceHeight)
 local scale=d.sourceSpan*ratio/aperture.buildingSpan*fit.scale
 local x0,y0,z0=g.cx*16+a[1],(g.groundHeight or 0)+a[2],(g.cy+1)*16+a[3]-aperture.insetFromDoorAnchor/aperture.buildingSpan*fit.scale
 local list={}
 for _,p in ipairs(d.parts)do
  local vertices={};local dx=d.poses[state+1][p.leaf]/d.sourceSpan
  for _,v in ipairs(p.vertices)do
   local x,y,z=x0+(v[1]+dx)*scale,y0+v[2]*scale,z0+v[3]*scale
   -- The whole sliding path remains inside the original three blocked body
   -- rows, including the side-wall pockets behind the source arch.
   if x<g.cx*16+.25 or x>g.cx*16+63.75 or z<(g.cy+1)*16+.25 or z>(g.cy+1)*16+47.75 then return nil,'source door leaves native Center body'end
   vertices[#vertices+1]={x,y,z,v[4],v[5],v[6]}
  end
  list[#list+1]={vertices=vertices,indices=p.indices,texture=p.texture,leaf=p.leaf}
 end
 return list
end
function M.release(g)
 if not g then return end
 local owner=g._importedCenterDoorOwner
 if owner and Budget.untrack then Budget.untrack(owner)end
 local cache=g.importedCenterDoors or g._importedCenterDoorPending
 if cache then Models.releaseBatches(cache.parts)end
 g.importedCenterDoors,g._importedCenterDoorPending,g._importedCenterDoorOwner=nil,nil,nil
end
function M.commit(g)
 -- Center.build calls this only after the structure is also uploaded. Until
 -- then cancellation owns every source door mesh through BuildBudget.
 local owner=g and g._importedCenterDoorOwner
 if owner and Budget.untrack then Budget.untrack(owner)end
 return g and g.importedCenterDoors
end
function M.build(g,fit,newMesh)
 M.release(g)
 local ok,err=M.register();if not ok then return nil,err end
 local cache={{},{},{},parts={}}
 g._importedCenterDoorPending=cache
 local owner={release=function()M.release(g)end};g._importedCenterDoorOwner=owner
 if Budget.track then Budget.track(owner)end
 local built,why=pcall(function()
  for state=0,2 do
   local geometry,reason=M.geometry(g,fit,state);assert(geometry,reason)
   for _,p in ipairs(geometry)do
    local part={count=1,role='source_center_door',alphaMode='cutout',opacity=1,leaf=p.leaf}
    cache[state+1][#cache[state+1]+1]=part;cache.parts[#cache.parts+1]=part
    part.image=assert(Models.image(M.id,p.texture,'repeat','repeat'),'original ORAS door texture unavailable')
    part.mesh=assert(newMesh(p.vertices,p.indices),'original ORAS door upload failed');part.mesh:setTexture(part.image)
   end
  end
 end)
 if not built then M.release(g);return nil,tostring(why)end
 g.importedCenterDoors=cache;g._importedCenterDoorPending=nil
 return cache
end
function M.state(g,anim)
 if not(anim and anim.x==g.cx+1 and anim.y==g.cy+3)then return 0 end
 local frame=tonumber(anim.frame)or 0
 if frame~=frame then return 0 end
 return math.max(0,math.min(2,math.floor(frame)))
end
function M.draw(g,anim,draw)
 local cache=g and g.importedCenterDoors;if not cache then return false end
 for _,p in ipairs(cache[M.state(g,anim)+1])do draw(p.mesh,p.image)end
 return true
end
return M
