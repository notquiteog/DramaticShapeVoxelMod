-- Original HGSS glass Mart panel; authored native-frame inward hinge poses.
-- This is a native-placement adaptation, not an extracted HGSS animation track.
local V=...
local Models,Budget=V.require('SceneryModels'),V.require('BuildBudget')
local M={}
local function source(fit)return V.require('HGSSMartData')[fit.model]end
function M.register(fit)
 if Models.info(fit.model..'_doors')then return true end
 local d=source(fit);local minY=math.huge
 for _,p in ipairs(d.doorParts)do for _,v in ipairs(p.vertices)do minY=math.min(minY,v[2])end end
 local parts={}
 for _,p in ipairs(d.doorParts)do
  local hi,back=-math.huge,math.huge
  for _,v in ipairs(p.vertices)do hi,back=math.max(hi,v[1]),math.min(back,v[3])end
  -- The original panel is planar. Its genuine closed/open poses supply the
  -- image catalog's positive volume; this catalog is never submitted to draw.
  for state=0,1 do
   local q={};for k,v in pairs(p)do q[k]=v end;q.vertices={}
   for j,v in ipairs(p.vertices)do q.vertices[j]={state==0 and v[1]or hi,v[2]-minY,state==0 and v[3]or back+v[1]-hi,v[4],v[5],1}end
   parts[#parts+1]=q
  end
 end
 return Models.register(fit.model..'_doors',{parts=parts},{read=function(path)return V.mod:read(path)end})
end
function M.geometry(g,fit,state)
 if not(g and g.kind=='mart'and fit and fit.model=='hgss_kanto_mart'and g.width==4 and g.depth==4 and fit.width==64 and fit.depth==48 and fit.scale>0)then return nil,'unreviewed HGSS Mart doorway'end
 if state~=0 and state~=1 and state~=2 then return nil,'invalid native door frame'end
 local d=source(fit);local out={}
 for i,p in ipairs(d.doorParts)do
  -- Retain the original complete panel and its handle/UV orientation. The
  -- right-side hinge opens inward, keeping every pose inside native walls.
  local hi,back=-math.huge,math.huge
  for _,v in ipairs(p.vertices)do hi,back=math.max(hi,v[1]),math.min(back,v[3])end
  local vertices={};local indices={}
  for start=1,#p.indices,3 do
   local hinge=hi;local angle=-state*math.pi/4;local c,s=math.cos(angle),math.sin(angle)
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
 if g._hgssMartDoorOwner and Budget.untrack then Budget.untrack(g._hgssMartDoorOwner)end
 local cache=g.importedHGSSMartDoors or g._hgssMartDoorPending;if cache then Models.releaseBatches(cache.parts)end
 g.importedHGSSMartDoors,g._hgssMartDoorPending,g._hgssMartDoorOwner=nil,nil,nil
end
function M.build(g,fit,newMesh,cells)
 M.release(g);local ok,err=M.register(fit);if not ok then return nil,err end
 local cache={{},{},{},parts={}};g._hgssMartDoorPending=cache;g._hgssMartDoorOwner={release=function()M.release(g)end}
 if Budget.track then Budget.track(g._hgssMartDoorOwner)end
 local built,why=pcall(function()
  for state=0,2 do
   local geometry,reason=M.geometry(g,fit,state);assert(geometry,reason)
   for _,p in ipairs(geometry)do
    local part={count=1,role='source_hgss_mart_door',opacity=1,alphaMode='cutout'};cache[state+1][#cache[state+1]+1]=part;cache.parts[#cache.parts+1]=part
    if cells then local localPart={vertices={},indices=p.indices};for _,v in ipairs(p.vertices)do localPart.vertices[#localPart.vertices+1]={v[1]-g.cx*16,v[2],v[3]-(g.cy+1)*16}end;local safe,why=V.require('Gen3ImportedHGSSMarts').clearance(g,cells,{localPart});assert(safe,why)end
    part.image=assert(Models.image(fit.model..'_doors',p.texture,'repeat','repeat'),'original HGSS Mart door image unavailable')
    part.mesh=assert(newMesh(p.vertices,p.indices),'original HGSS Mart door upload failed');part.mesh:setTexture(part.image)
   end
  end
 end)
 if not built then M.release(g);return nil,tostring(why)end
 g.importedHGSSMartDoors=cache;g._hgssMartDoorPending=nil;return cache
end
function M.commit(g)
 if g and g._hgssMartDoorOwner and Budget.untrack then Budget.untrack(g._hgssMartDoorOwner)end
 return g and g.importedHGSSMartDoors
end
function M.ownsDoor(g,x,y)return g and g.importedHGSSMartDoors~=nil and x==g.cx+2 and y==g.cy+3 or false end
function M.state(g,anim)
 if not(anim and M.ownsDoor(g,anim.x,anim.y))then return 0 end
 local f=tonumber(anim.frame)or 0;if f~=f then return 0 end
 return math.max(0,math.min(2,math.floor(f)))
end
function M.draw(g,anim,draw)
 local cache=g and g.importedHGSSMartDoors;if not cache then return false end
 for _,p in ipairs(cache[M.state(g,anim)+1])do draw(p.mesh,p.image)end;return true
end
return M
