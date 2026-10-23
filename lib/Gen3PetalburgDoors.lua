-- Genuine ORAS BM0004 hinged Petalburg home door, including the idle closed state. The
-- native engine owns animation frame, sound, player movement and warp timing.
local V=...
local Models,Budget=V.require('SceneryModels'),V.require('BuildBudget')
local M={id='oras_petalburg_home_doors'}
local families={petalburg_city_home=true,petalburg_city_wide_home=true}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
local function source()
 local ok,d=pcall(V.require,'ImportedPetalburgHomesData')
 if ok and type(d)=='table'and d.door and d.door.id==M.id then return d.door end
 return nil,'original ORAS Petalburg door unavailable'
end
function M.register()
 if Models.info(M.id)then return true end
 local d,err=source();if not d then return nil,err end
 local minY=math.huge;for _,p in ipairs(d.parts)do for _,v in ipairs(p.vertices)do minY=math.min(minY,v[2])end end
 local parts={};for i,p in ipairs(d.parts)do local q={};for k,v in pairs(p)do q[k]=v end;q.vertices={};for j,v in ipairs(p.vertices)do q.vertices[j]={v[1],v[2]-minY,v[3],v[4],v[5],1}end;parts[i]=q end
 return Models.register(M.id,{parts=parts},{read=function(path)return V.mod:read(path)end})
end
function M.geometry(g,fit,state)
 local d,err=source();if not d then return nil,err end
 if not(g and g.kind=='house'and (g.width==4 or g.width==5)and g.depth==4 and g.custom and g.custom.family=='rse'
  and families[g.custom.name]and not g.stageHidden and fit and (fit.model=='oras_petalburg_home_wide'or fit.model=='oras_petalburg_home_west'or fit.model=='oras_petalburg_home_east')
  and fit.width==g.width*16 and fit.depth==48 and finite(fit.scale)and fit.scale>0)then return nil,'unreviewed Petalburg doorway'end
 if state~=0 and state~=1 and state~=2 then return nil,'invalid Petalburg door state'end
 local parts={}
 for i,source in ipairs(d.parts)do
  local vertices={}
  for _,v in ipairs(d.poses[state+1][i])do
   vertices[#vertices+1]={g.cx*16+v[1]*fit.scale+fit.x,(g.groundHeight or 0)+(math.abs(v[2])<1e-7 and -(fit.groundInset or 0)or v[2]*fit.scale),(g.cy+1)*16+v[3]*fit.scale+fit.z,v[4],v[5],1}
  end
  parts[i]={vertices=vertices,indices=source.indices,texture=source.texture}
 end
 return parts
end
function M.release(g)
 if not g then return end
 local owner=g._petalburgDoorOwner;if owner and Budget.untrack then Budget.untrack(owner)end
 local cache=g.importedPetalburgDoors or g._petalburgDoorPending
 if cache then Models.releaseBatches(cache.parts)end
 g.importedPetalburgDoors,g._petalburgDoorPending,g._petalburgDoorOwner=nil,nil,nil
end
function M.build(g,fit,newMesh,cells)
 M.release(g)
 local ok,err=M.register();if not ok then return nil,err end
 local cache={parts={}};g._petalburgDoorPending=cache
 local owner={release=function()M.release(g)end};g._petalburgDoorOwner=owner
 if Budget.track then Budget.track(owner)end
 local built,why=pcall(function()
  for state=0,2 do
   local data,reason=M.geometry(g,fit,state);assert(data,reason);cache[state+1]={}
   for _,piece in ipairs(data)do
    local part={count=1,role='source_petalburg_door',alphaMode='cutout',opacity=1};cache[state+1][#cache[state+1]+1]=part;cache.parts[#cache.parts+1]=part
    if cells then
     local localPart={vertices={},indices=piece.indices}
     for _,v in ipairs(piece.vertices)do localPart.vertices[#localPart.vertices+1]={v[1]-g.cx*16,v[2],v[3]-(g.cy+1)*16}end
     local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,{localPart});assert(safe,why)
    end
    part.image=assert(Models.image(M.id,piece.texture,'repeat','repeat'),'original Petalburg door texture unavailable')
    part.mesh=assert(newMesh(piece.vertices,piece.indices),'original Petalburg door upload failed');part.mesh:setTexture(part.image)
   end
  end
 end)
 if not built then M.release(g);return nil,tostring(why)end
 g.importedPetalburgDoors=cache;g._petalburgDoorPending=nil
 return cache
end
function M.commit(g)
 if g and g._petalburgDoorOwner and Budget.untrack then Budget.untrack(g._petalburgDoorOwner)end
 return g and g.importedPetalburgDoors
end
function M.ownsDoor(g,x,y)
 return g and g.importedPetalburgDoors~=nil and x==g.cx+(g.width==5 and 2 or 1) and y==g.cy+3 or false
end
function M.state(g,anim)
 if not(anim and anim.x==g.cx+(g.width==5 and 2 or 1) and anim.y==g.cy+3)then return 0 end
 local frame=tonumber(anim.frame)or 0;if not finite(frame)then return 0 end
 return math.max(0,math.min(2,math.floor(frame)))
end
function M.draw(g,anim,draw)
 local cache=g and g.importedPetalburgDoors;if not cache then return false end
 for _,part in ipairs(cache[M.state(g,anim)+1])do draw(part.mesh,part.image)end;return true
end
return M
