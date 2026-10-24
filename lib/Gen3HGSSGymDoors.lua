-- Original regional HGSS paired Gym panels, with authored native-frame inward
-- hinges. No HGSS animation track or native engine timing is replaced.
local V=...
local Models,Budget=V.require('SceneryModels'),V.require('BuildBudget')
local M={}
local function source(fit)return V.require('HGSSKantoGymData')[fit.model]end
function M.register(fit)
 if Models.info(fit.model..'_doors')then return true end
 local d=source(fit);local minY=math.huge
 for _,p in ipairs(d.doorParts)do for _,v in ipairs(p.vertices)do minY=math.min(minY,v[2])end end
 local parts={};for i,p in ipairs(d.doorParts)do local q={};for k,v in pairs(p)do q[k]=v end;q.vertices={};for j,v in ipairs(p.vertices)do q.vertices[j]={v[1],v[2]-minY,v[3],v[4],v[5],1}end;parts[i]=q end
 return Models.register(fit.model..'_doors',{parts=parts},{read=function(path)return V.mod:read(path)end})
end
function M.geometry(g,fit,state)
 if not(g and g.kind=='gym'and V.require('Gen3ImportedHGSSGyms').selection(g)and fit and fit.model==V.require('Gen3ImportedHGSSGyms').selection(g).id and fit.width==g.width*16 and fit.depth==64 and fit.scale>0)then return nil,'unreviewed regional HGSS Gym doorway'end
 if state~=0 and state~=1 and state~=2 then return nil,'invalid native door frame'end
 local d=source(fit);local out={}
 for i,p in ipairs(d.doorParts)do
  -- The curved source facade has four triangles per leaf. Preserve every
  -- original position/UV, rotating each complete leaf about its outer hinge.
  local lo,hi,back=math.huge,-math.huge,math.huge
  for _,v in ipairs(p.vertices)do lo,hi,back=math.min(lo,v[1]),math.max(hi,v[1]),math.min(back,v[3])end
  local center=(lo+hi)/2;local vertices={};local indices={}
  for start=1,#p.indices,3 do
   local mean=0;for j=0,2 do mean=mean+p.vertices[p.indices[start+j]][1]/3 end
   local left=mean<center;local hinge=left and lo or hi;local angle=(left and 1 or -1)*state*math.pi/4;local c,s=math.cos(angle),math.sin(angle)
   for j=0,2 do
    local v=p.vertices[p.indices[start+j]];local dx,dz=v[1]-hinge,v[3]-back
    local x,z=hinge+dx*c+dz*s,back-dx*s+dz*c
    vertices[#vertices+1]={g.cx*16+x*fit.scale+fit.x,(g.groundHeight or 0)+v[2]*fit.scale,(g.cy+1)*16+z*fit.scale+fit.z,v[4],v[5],1};indices[#indices+1]=#vertices
   end
  end
  out[i]={vertices=vertices,indices=indices,texture=p.texture}
 end
 return out
end
function M.release(g)
 if not g then return end
 if g._hgssGymDoorOwner and Budget.untrack then Budget.untrack(g._hgssGymDoorOwner)end
 local cache=g.importedHGSSGymDoors or g._hgssGymDoorPending;if cache then Models.releaseBatches(cache.parts)end
 g.importedHGSSGymDoors,g._hgssGymDoorPending,g._hgssGymDoorOwner=nil,nil,nil
end
function M.build(g,fit,newMesh,cells)
 M.release(g);local ok,err=M.register(fit);if not ok then return nil,err end
 local cache={{},{},{},parts={}};g._hgssGymDoorPending=cache;g._hgssGymDoorOwner={release=function()M.release(g)end}
 if Budget.track then Budget.track(g._hgssGymDoorOwner)end
 local built,why=pcall(function()
  for state=0,2 do
   local geometry,reason=M.geometry(g,fit,state);assert(geometry,reason)
   for _,p in ipairs(geometry)do
    local part={count=1,role='source_hgss_gym_door',opacity=1,alphaMode='cutout'};cache[state+1][#cache[state+1]+1]=part;cache.parts[#cache.parts+1]=part
    if cells then local localPart={vertices={},indices=p.indices};for _,v in ipairs(p.vertices)do localPart.vertices[#localPart.vertices+1]={v[1]-g.cx*16,v[2],v[3]-(g.cy+1)*16}end;local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,{localPart});assert(safe,why)end
    part.image=assert(Models.image(fit.model..'_doors',p.texture,'repeat','repeat'),'original HGSS Gym door image unavailable')
    part.mesh=assert(newMesh(p.vertices,p.indices),'original HGSS Gym door upload failed');part.mesh:setTexture(part.image)
   end
  end
 end)
 if not built then M.release(g);return nil,tostring(why)end
 g.importedHGSSGymDoors=cache;g._hgssGymDoorPending=nil;return cache
end
function M.commit(g)
 if g and g._hgssGymDoorOwner and Budget.untrack then Budget.untrack(g._hgssGymDoorOwner)end
 return g and g.importedHGSSGymDoors
end
function M.ownsDoor(g,x,y)return g and g.importedHGSSGymDoors~=nil and x==g.cx+3 and y==g.cy+4 or false end
function M.state(g,anim)
 if not(anim and M.ownsDoor(g,anim.x,anim.y))then return 0 end
 local f=tonumber(anim.frame)or 0;if f~=f then return 0 end
 return math.max(0,math.min(2,math.floor(f)))
end
function M.draw(g,anim,draw)
 local cache=g and g.importedHGSSGymDoors;if not cache then return false end
 for _,p in ipairs(cache[M.state(g,anim)+1])do draw(p.mesh,p.image)end;return true
end
return M
