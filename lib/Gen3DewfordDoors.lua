-- Genuine ORAS BM0034 house door, including the idle closed state. The
-- native engine owns animation frame, sound, player movement and warp timing.
local V=...
local Models,Budget=V.require('SceneryModels'),V.require('BuildBudget')
local M={id='oras_dewford_hinged_door'}
local families={dewford_town_home=true,dewford_town_south_home=true}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
local function source()
 local ok,d=pcall(V.require,'ImportedDewfordDoorData')
 if ok and type(d)=='table'and d.id==M.id then return d end
 return nil,'original ORAS Dewford door unavailable'
end
function M.register()
 if Models.info(M.id)then return true end
 local d,err=source();if not d then return nil,err end
 return Models.register(M.id,{parts=d.parts},{read=function(path)return V.mod:read(path)end})
end
function M.geometry(g,fit,state)
 local d,err=source();if not d then return nil,err end
 local a=fit and fit.anchors
 if not(g and g.kind=='house'and g.width==4 and g.depth==4 and g.custom and g.custom.family=='rse'
  and families[g.custom.name]and g.pair=='general__dewford'and not g.stageHidden
  and fit and fit.model=='oras_dewford_narrow_house'and fit.width==64 and fit.depth==48
  and a and a.door and a.doorLeft and a.doorRight and a.doorTop
  and finite(g.cx)and finite(g.cy)and finite(g.groundHeight or 0))then return nil,'unreviewed Dewford doorway'end
 if state~=0 and state~=1 and state~=2 then return nil,'invalid Dewford door state'end
 local width=a.doorRight[1]-a.doorLeft[1];local height=a.doorTop[2]-a.door[2]
 if not(finite(width)and finite(height)and width>0 and height>0)then return nil,'invalid source aperture'end
 local scale=math.min(width,height/d.height)
 local vertices={}
 for _,v in ipairs(d.poses[state+1])do
  local x,y,z=g.cx*16+a.door[1]+v[1]*scale,(g.groundHeight or 0)+a.door[2]+v[2]*scale,
   (g.cy+1)*16+a.door[3]+.025+v[3]*scale
  if x<g.cx*16+.25 or x>g.cx*16+63.75 or z<(g.cy+1)*16+.25 or z>(g.cy+1)*16+47.75 then return nil,'source door leaves native house body'end
  vertices[#vertices+1]={x,y,z,v[4],v[5],v[6]}
 end
 return {vertices=vertices,indices=d.parts[1].indices,texture=d.parts[1].texture}
end
function M.release(g)
 if not g then return end
 local owner=g._dewfordDoorOwner;if owner and Budget.untrack then Budget.untrack(owner)end
 local cache=g.importedDewfordDoors or g._dewfordDoorPending
 if cache then Models.releaseBatches(cache.parts)end
 g.importedDewfordDoors,g._dewfordDoorPending,g._dewfordDoorOwner=nil,nil,nil
end
function M.build(g,fit,newMesh)
 M.release(g)
 local ok,err=M.register();if not ok then return nil,err end
 local cache={parts={}};g._dewfordDoorPending=cache
 local owner={release=function()M.release(g)end};g._dewfordDoorOwner=owner
 if Budget.track then Budget.track(owner)end
 local built,why=pcall(function()
  for state=0,2 do
   local data,reason=M.geometry(g,fit,state);assert(data,reason)
   local part={count=1,role='source_dewford_door',alphaMode='cutout',opacity=1}
   cache[state+1]=part;cache.parts[#cache.parts+1]=part
   part.image=assert(Models.image(M.id,data.texture,'repeat','repeat'),'original Dewford door texture unavailable')
   part.mesh=assert(newMesh(data.vertices,data.indices),'original Dewford door upload failed');part.mesh:setTexture(part.image)
  end
 end)
 if not built then M.release(g);return nil,tostring(why)end
 g.importedDewfordDoors=cache;g._dewfordDoorPending=nil
 return cache
end
function M.commit(g)
 if g and g._dewfordDoorOwner and Budget.untrack then Budget.untrack(g._dewfordDoorOwner)end
 return g and g.importedDewfordDoors
end
function M.ownsDoor(g,x,y)
 return g and g.importedDewfordDoors~=nil and x==g.cx+1 and y==g.cy+3 or false
end
function M.state(g,anim)
 if not(anim and anim.x==g.cx+1 and anim.y==g.cy+3)then return 0 end
 local frame=tonumber(anim.frame)or 0;if not finite(frame)then return 0 end
 return math.max(0,math.min(2,math.floor(frame)))
end
function M.draw(g,anim,draw)
 local cache=g and g.importedDewfordDoors;if not cache then return false end
 local part=cache[M.state(g,anim)+1];draw(part.mesh,part.image);return true
end
return M
