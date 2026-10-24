-- Original HGSS Center glass panel, split at its UV midpoint into sliding leaves.
-- This is a native-placement adaptation, not an extracted HGSS animation track.
local V=...
local Models,Budget,R=V.require('SceneryModels'),V.require('BuildBudget'),V.require('Voxel3D')
local M={}
local function island(g)return g and g.kind=='center'and g.width==7 and g.depth==6 and g.custom and g.custom.name=='one_island_center'end
local function baseOffset(g)return island(g)and 0 or g.depth-4 end
local function source(fit)return V.require('HGSSCenterData')[fit.model]end
function M.register(fit)
 if Models.info(fit.model..'_doors')then return true end
 -- The genuine complete source is only an image catalog. Body/leaf meshes
 -- are independently submitted; this catalog never draws duplicate geometry.
 return Models.register(fit.model..'_doors',source(fit),{read=function(path)return V.mod:read(path)end})
end
function M.geometry(g,fit,state)
 local standard=g and g.kind=='center'and g.width==5 and(g.depth==4 or g.depth==5)and fit and fit.width==80 and fit.depth==64
 local wider=island(g)and fit and fit.width==112 and fit.depth==96
 if not((standard or wider)and fit.model=='hgss_kanto_center'and fit.scale>0)then return nil,'unreviewed HGSS Center doorway'end
 if state~=0 and state~=1 and state~=2 then return nil,'invalid native door frame'end
 local out={}
 for _,p in ipairs(source(fit).parts)do if p.role=='source_door'then
  local lo,hi,bottom,top,z=math.huge,-math.huge,math.huge,-math.huge
  for _,v in ipairs(p.vertices)do lo,hi,bottom,top=math.min(lo,v[1]),math.max(hi,v[1]),math.min(bottom,v[2]),math.max(top,v[2]);z=v[3]end
  local mid=(lo+hi)/2
  for leaf=0,1 do
   local a,b=leaf==0 and lo or mid,leaf==0 and mid or hi
   local u0,u1=leaf/2,(leaf+1)/2;local shift=(leaf==0 and-1 or 1)*(hi-lo)/2*state/2
   local vertices={}
   for _,v in ipairs{{b,bottom,z,u1,1},{a,top,z,u0,0},{a,bottom,z,u0,1},{b,top,z,u1,0}}do
    vertices[#vertices+1]={g.cx*16+(v[1]+shift)*fit.scale+fit.x,(g.groundHeight or 0)+v[2]*fit.scale,(g.cy+baseOffset(g))*16+v[3]*fit.scale+fit.z,v[4],v[5],1}
   end
   out[#out+1]={vertices=vertices,indices={1,2,3,1,4,2},texture=p.texture,opacity=p.opacity,alphaMode=p.alphaMode,leaf=leaf}
  end
 end end
 return out
end
-- Rebase the unchanged native body cells for the shared three-row clipper.
function M.clearance(g,cells,parts)
 local mask=setmetatable({},{__index=function(_,k)
  local x,y=k:match('^(-?%d+):(-?%d+)$');if not x then return cells[k]end
  local c=cells[x..':'..(tonumber(y)+baseOffset(g)-1)];if not c or c.collision~=130 then return c end
  local q={};for n,v in pairs(c)do q[n]=v end;q.collision=7;return q
 end})
 return V.require('Gen3ImportedGyms').clearance(g,mask,parts)
end
function M.release(g)
 if not g then return end
 if g._kantoCenterDoorOwner and Budget.untrack then Budget.untrack(g._kantoCenterDoorOwner)end
 local cache=g.importedKantoCenterDoors or g._kantoCenterDoorPending;if cache then Models.releaseBatches(cache.parts)end
 g.importedKantoCenterDoors,g._kantoCenterDoorPending,g._kantoCenterDoorOwner=nil,nil,nil
end
function M.build(g,fit,newMesh,cells)
 M.release(g);local ok,err=M.register(fit);if not ok then return nil,err end
 local cache={{},{},{},parts={}};g._kantoCenterDoorPending=cache;g._kantoCenterDoorOwner={release=function()M.release(g)end}
 if Budget.track then Budget.track(g._kantoCenterDoorOwner)end
 local built,why=pcall(function()
  for state=0,2 do
   local geometry,reason=M.geometry(g,fit,state);assert(geometry,reason)
   for _,p in ipairs(geometry)do
    local part={count=1,role='source_hgss_center_door',opacity=p.opacity,alphaMode=p.alphaMode};cache[state+1][#cache[state+1]+1]=part;cache.parts[#cache.parts+1]=part
    if cells then local localPart={vertices={},indices=p.indices};for _,v in ipairs(p.vertices)do localPart.vertices[#localPart.vertices+1]={v[1]-g.cx*16,v[2],v[3]-(g.cy+baseOffset(g))*16}end;local safe,why=M.clearance(g,cells,{localPart});assert(safe,why)end
    part.image=assert(Models.image(fit.model..'_doors',p.texture,'repeat','repeat'),'original HGSS Center door image unavailable')
    part.mesh=assert(newMesh(p.vertices,p.indices),'original HGSS Center door upload failed');part.mesh:setTexture(part.image)
   end
  end
 end)
 if not built then M.release(g);return nil,tostring(why)end
 g.importedKantoCenterDoors=cache;g._kantoCenterDoorPending=nil;return cache
end
function M.commit(g)
 if g and g._kantoCenterDoorOwner and Budget.untrack then Budget.untrack(g._kantoCenterDoorOwner)end
 return g and g.importedKantoCenterDoors
end
function M.ownsDoor(g,x,y)return g and g.importedKantoCenterDoors~=nil and x==g.cx+(island(g)and 3 or 2)and y==g.cy+g.depth-1 or false end
function M.state(g,anim)
 if not(anim and M.ownsDoor(g,anim.x,anim.y))then return 0 end
 local f=tonumber(anim.frame)or 0;if f~=f then return 0 end
 return math.max(0,math.min(2,math.floor(f)))
end
function M.draw(g,anim,draw)
 local cache=g and g.importedKantoCenterDoors;if not cache then return false end
 for _,p in ipairs(cache[M.state(g,anim)+1])do R.withSceneryMaterial(p.opacity,function()draw(p.mesh,p.image)end)end;return true
end
return M
