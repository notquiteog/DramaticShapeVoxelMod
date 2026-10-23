-- Original HGSS Lavender door mesh; native FR/LG frames drive an authored inward
-- hinge transform. This is a placement adaptation, not an extracted HGSS track.
local V=...
local Models,Budget=V.require('SceneryModels'),V.require('BuildBudget')
local M={id='hgss_lavender_house_door'}
local function source()return V.require('LavenderHouseData').hgss_lavender_house end
function M.register()
 if Models.info(M.id)then return true end
 local d=source();local minY=math.huge
 for _,p in ipairs(d.doorParts)do for _,v in ipairs(p.vertices)do minY=math.min(minY,v[2])end end
 local parts={};for i,p in ipairs(d.doorParts)do local q={};for k,v in pairs(p)do q[k]=v end;q.vertices={};for j,v in ipairs(p.vertices)do q.vertices[j]={v[1],v[2]-minY,v[3],v[4],v[5],1}end;parts[i]=q end
 return Models.register(M.id,{parts=parts},{read=function(path)return V.mod:read(path)end})
end
function M.geometry(g,fit,state)
 if not(g and g.family=='lavender_house'and g.pair=='general__rom_082d4b0c'and g.width==5 and g.depth==4 and not g.stageHidden and fit and fit.width==80 and fit.depth==48 and fit.scale>0)then return nil,'unreviewed Lavender doorway'end
 if state~=0 and state~=1 and state~=2 then return nil,'invalid native door frame'end
 local d=source();local h=d.anchors.doorHinge;local angle=-state*math.pi/4;local c,s=math.cos(angle),math.sin(angle);local out={}
 for i,p in ipairs(d.doorParts)do
  local vertices={}
  for _,v in ipairs(p.vertices)do
   local dx,dz=v[1]-h[1],v[3]-h[3];local x,z=h[1]+dx*c+dz*s,h[3]-dx*s+dz*c
   x,z=x*fit.scale+fit.x,z*fit.scale+fit.z
   if x<.25 or x>79.75 or z<.25 or z>47.75 then return nil,'source hinge leaves native blocked body'end
   vertices[#vertices+1]={g.cx*16+x,(g.groundHeight or 0)+v[2]*fit.scale,(g.cy+1)*16+z,v[4],v[5],1}
  end
  out[i]={vertices=vertices,indices=p.indices,texture=p.texture}
 end
 return out
end
function M.release(g)
 if not g then return end
 if g._lavenderDoorOwner and Budget.untrack then Budget.untrack(g._lavenderDoorOwner)end
 local cache=g.importedLavenderDoors or g._lavenderDoorPending;if cache then Models.releaseBatches(cache.parts)end
 g.importedLavenderDoors,g._lavenderDoorPending,g._lavenderDoorOwner=nil,nil,nil
end
function M.build(g,fit,newMesh)
 M.release(g);local ok,err=M.register();if not ok then return nil,err end
 local cache={{},{},{},parts={}};g._lavenderDoorPending=cache;g._lavenderDoorOwner={release=function()M.release(g)end}
 if Budget.track then Budget.track(g._lavenderDoorOwner)end
 local built,why=pcall(function()
  for state=0,2 do
   local geometry,reason=M.geometry(g,fit,state);assert(geometry,reason)
   for _,p in ipairs(geometry)do
    local part={count=1,role='source_lavender_door',opacity=1,alphaMode='cutout'};cache[state+1][#cache[state+1]+1]=part;cache.parts[#cache.parts+1]=part
    part.image=assert(Models.image(M.id,p.texture,'repeat','repeat'),'original Lavender door image unavailable')
    part.mesh=assert(newMesh(p.vertices,p.indices),'original Lavender door upload failed');part.mesh:setTexture(part.image)
   end
  end
 end)
 if not built then M.release(g);return nil,tostring(why)end
 g.importedLavenderDoors=cache;g._lavenderDoorPending=nil;return cache
end
function M.commit(g)
 if g and g._lavenderDoorOwner and Budget.untrack then Budget.untrack(g._lavenderDoorOwner)end
 return g and g.importedLavenderDoors
end
function M.ownsDoor(g,x,y)return g and g.importedLavenderDoors~=nil and x==g.cx+2 and y==g.cy+3 or false end
function M.state(g,anim)
 if not(anim and M.ownsDoor(g,anim.x,anim.y))then return 0 end
 local f=tonumber(anim.frame)or 0;if f~=f then return 0 end
 return math.max(0,math.min(2,math.floor(f)))
end
function M.draw(g,anim,draw)
 local cache=g and g.importedLavenderDoors;if not cache then return false end
 for _,p in ipairs(cache[M.state(g,anim)+1])do draw(p.mesh,p.image)end;return true
end
return M
