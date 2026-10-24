-- Genuine ORAS BM0040 paired Oceanic Museum doors, including the native open idle state. The
-- native engine owns animation frame, sound, player movement and warp timing.
local V=...
local Models,Budget=V.require('SceneryModels'),V.require('BuildBudget')
local M={id='oras_slateport_museum_doors'}
local function family(g)return g and g.importedHoenn and g.importedHoenn.model=='oras_slateport_museum'and g.width==6 and g.depth==5 and g.custom and g.custom.name=='slateport_oceanic_museum'end
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
local function source()
 local ok,d=pcall(V.require,'ImportedSlateportMuseumData')
 if ok and type(d)=='table'and d.door and d.door.id==M.id and finite(d.door.meetingPlane)and type(d.door.owners)=='table'and #d.door.owners==4 and type(d.door.angles)=='table'and #d.door.angles==3 then return d.door end
 return nil,'original ORAS Museum door unavailable'
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
 if not(fit and fit.model=='oras_slateport_museum'and g and g.kind=='oceanic_museum'and g.width==6 and g.depth==5 and g.custom and g.custom.family=='rse'and g.custom.name=='slateport_oceanic_museum'
  and not g.stageHidden and fit
  and fit.width==g.width*16 and fit.depth==(g.depth-1)*16 and finite(fit.scale)and fit.scale>0)then return nil,'unreviewed Museum doorway'end
 if state~=0 and state~=1 and state~=2 then return nil,'invalid Museum door state'end
 local parts={}
 for i,source in ipairs(d.parts)do
  local vertices={}
  for j,v in ipairs(d.poses[state+1][i])do
   -- The original closed leaves share their central cap plane. Recess that
   -- edge into each leaf, rotating the same inset with its original hinge.
   local dx,dz=0,0
   if math.abs(d.poses[1][i][j][1]-d.meetingPlane)<1e-6 then local owner=d.owners[i];local angle=d.angles[state+1][owner];local inward=owner==1 and .05 or-.05;dx,dz=inward*math.cos(angle),-inward*math.sin(angle)end
   -- Recess only genuine zero-height source contacts. The raised entrance,
   -- original hinges and every non-contact source coordinate stay fixed.
   vertices[#vertices+1]={g.cx*16+v[1]*fit.scale+fit.x+dx,(g.groundHeight or 0)+(math.abs(v[2]*152)<.0016 and -(fit.groundInset or 0)or v[2]*fit.scale),(g.cy+1)*16+v[3]*fit.scale+fit.z+dz,v[4],v[5],1}
  end
  parts[i]={vertices=vertices,indices=source.indices,texture=source.texture}
 end
 return parts
end
function M.release(g)
 if not g then return end
 local owner=g._museumDoorOwner;if owner and Budget.untrack then Budget.untrack(owner)end
 local cache=g.importedMuseumDoors or g._museumDoorPending
 if cache then Models.releaseBatches(cache.parts)end
 g.importedMuseumDoors,g._museumDoorPending,g._museumDoorOwner=nil,nil,nil
end
function M.build(g,fit,newMesh,cells)
 M.release(g)
 local ok,err=M.register();if not ok then return nil,err end
 local cache={parts={}};g._museumDoorPending=cache
 local owner={release=function()M.release(g)end};g._museumDoorOwner=owner
 if Budget.track then Budget.track(owner)end
 local built,why=pcall(function()
  for state=0,2 do
   local data,reason=M.geometry(g,fit,state);assert(data,reason);cache[state+1]={}
   for _,piece in ipairs(data)do
    local part={count=1,role='source_museum_door',alphaMode='cutout',opacity=1};cache[state+1][#cache[state+1]+1]=part;cache.parts[#cache.parts+1]=part
    if cells then
     local localPart={vertices={},indices=piece.indices}
     for _,v in ipairs(piece.vertices)do localPart.vertices[#localPart.vertices+1]={v[1]-g.cx*16,v[2],v[3]-(g.cy+1)*16}end
     local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,{localPart});assert(safe,why)
    end
    part.image=assert(Models.image(M.id,piece.texture,'repeat','repeat'),'original Museum door texture unavailable')
    part.mesh=assert(newMesh(piece.vertices,piece.indices),'original Museum door upload failed');part.mesh:setTexture(part.image)
   end
  end
 end)
 if not built then M.release(g);return nil,tostring(why)end
 g.importedMuseumDoors=cache;g._museumDoorPending=nil
 return cache
end
function M.commit(g)
 if g and g._museumDoorOwner and Budget.untrack then Budget.untrack(g._museumDoorOwner)end
 return g and g.importedMuseumDoors
end
function M.ownsDoor(g,x,y)
 return family(g)and g.importedMuseumDoors~=nil and(x==g.cx+2 or x==g.cx+3)and y==g.cy+4 or false
end
function M.state(g,anim)
 -- Exact native0x32a Museum entries have no door animation/closed graphic.
 -- Keep their authentic leaves open unless an explicit matching pose is supplied.
 if not(family(g)and anim and(anim.x==g.cx+2 or anim.x==g.cx+3)and anim.y==g.cy+4)then return 2 end
 local frame=tonumber(anim.frame)or 2;if not finite(frame)then return 2 end
 return math.max(0,math.min(2,math.floor(frame)))
end
function M.draw(g,anim,draw)
 local cache=g and g.importedMuseumDoors;if not cache then return false end
 for _,part in ipairs(cache[M.state(g,anim)+1])do draw(part.mesh,part.image)end;return true
end
return M
