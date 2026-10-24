-- Genuine ORAS BM0039 Stern Shipyard hinge. The
-- native engine owns animation frame, sound, player movement and warp timing.
local V=...
local Models,Budget=V.require('SceneryModels'),V.require('BuildBudget')
local M={id='oras_slateport_shipyard_door'}
local function family(g)return g and g.importedHoenn and g.importedHoenn.model=='oras_slateport_shipyard'and g.width==8 and g.depth==7 and g.custom and g.custom.name=='slateport_shipyard'end
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
local function source()
 local ok,d=pcall(V.require,'ImportedSlateportShipyardData')
 if ok and type(d)=='table'and d.door and d.door.id==M.id  then return d.door end
 return nil,'original ORAS Shipyard door unavailable'
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
 if not(fit and fit.model=='oras_slateport_shipyard'and g and g.kind=='shipyard'and g.width==8 and g.depth==7 and g.custom and g.custom.family=='rse'and g.custom.name=='slateport_shipyard'
  and not g.stageHidden and fit
  and fit.width==g.width*16 and fit.depth==(g.depth-1)*16 and finite(fit.scale)and fit.scale>0)then return nil,'unreviewed Shipyard doorway'end
 if state~=0 and state~=1 and state~=2 then return nil,'invalid Shipyard door state'end
 local parts={}
 for i,source in ipairs(d.parts)do
  local vertices={}
  for j,v in ipairs(d.poses[state+1][i])do
   -- Recess only genuine zero-height source contacts. The raised entrance,
   -- original hinges and every non-contact source coordinate stay fixed.
   vertices[#vertices+1]={g.cx*16+v[1]*fit.scale+fit.x,(g.groundHeight or 0)+(math.abs(v[2]*226)<.0016 and -(fit.groundInset or 0)or v[2]*fit.scale),(g.cy+1)*16+v[3]*fit.scale+fit.z,v[4],v[5],1}
  end
  parts[i]={vertices=vertices,indices=source.indices,texture=source.texture}
 end
 return parts
end
function M.release(g)
 if not g then return end
 local owner=g._shipyardDoorOwner;if owner and Budget.untrack then Budget.untrack(owner)end
 local cache=g.importedShipyardDoors or g._shipyardDoorPending
 if cache then Models.releaseBatches(cache.parts)end
 g.importedShipyardDoors,g._shipyardDoorPending,g._shipyardDoorOwner=nil,nil,nil
end
function M.build(g,fit,newMesh,cells)
 M.release(g)
 local ok,err=M.register();if not ok then return nil,err end
 local cache={parts={}};g._shipyardDoorPending=cache
 local owner={release=function()M.release(g)end};g._shipyardDoorOwner=owner
 if Budget.track then Budget.track(owner)end
 local built,why=pcall(function()
  for state=0,2 do
   local data,reason=M.geometry(g,fit,state);assert(data,reason);cache[state+1]={}
   for _,piece in ipairs(data)do
    local part={count=1,role='source_shipyard_door',alphaMode='cutout',opacity=1};cache[state+1][#cache[state+1]+1]=part;cache.parts[#cache.parts+1]=part
    if cells then
     local localPart={vertices={},indices=piece.indices}
     for _,v in ipairs(piece.vertices)do localPart.vertices[#localPart.vertices+1]={v[1]-g.cx*16,v[2],v[3]-(g.cy+1)*16}end
     local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,{localPart});assert(safe,why)
    end
    part.image=assert(Models.image(M.id,piece.texture,'repeat','repeat'),'original Shipyard door texture unavailable')
    part.mesh=assert(newMesh(piece.vertices,piece.indices),'original Shipyard door upload failed');part.mesh:setTexture(part.image)
   end
  end
 end)
 if not built then M.release(g);return nil,tostring(why)end
 g.importedShipyardDoors=cache;g._shipyardDoorPending=nil
 return cache
end
function M.commit(g)
 if g and g._shipyardDoorOwner and Budget.untrack then Budget.untrack(g._shipyardDoorOwner)end
 return g and g.importedShipyardDoors
end
function M.ownsDoor(g,x,y)
 return family(g)and g.importedShipyardDoors~=nil and x==g.cx+2 and y==g.cy+6 or false
end
function M.state(g,anim)
 -- Native0x2b4 has no door-animation entry; its original passage stays open.
 if not(family(g)and anim and anim.x==g.cx+2 and anim.y==g.cy+6)then return 2 end
 local frame=tonumber(anim.frame)or 2;if not finite(frame)then return 2 end
 return math.max(0,math.min(2,math.floor(frame)))
end
function M.draw(g,anim,draw)
 local cache=g and g.importedShipyardDoors;if not cache then return false end
 for _,part in ipairs(cache[M.state(g,anim)+1])do draw(part.mesh,part.image)end;return true
end
return M
