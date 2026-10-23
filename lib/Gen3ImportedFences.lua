-- Authentic ORAS fence pieces in reviewed native blocked cells. Source art,
-- collision, scripts and native ground remain authoritative on any failure.
local V=...
local Models=V.require('SceneryModels')
local Families=V.require('Gen3FenceFamilies')
local M={}
local registered={}
function M.register(id)
 if registered[id]and Models.info(id)then return true end
 local ok,data=pcall(V.require,'ImportedFenceData')
 if not ok or type(data)~='table'or not data[id]then return nil,'imported fence source unavailable'end
 local success,why=Models.register(id,data[id],{read=function(path)return V.mod:read(path)end})
 if success then registered[id]=true end
 return success,why
end
function M.eligible(c)
 if not c or c.boundary or c.prop or c.civic or c.stairs or c.stageHidden
  or not(c.ts and c.ts.layered)or c.collision~=7 or c.primary~='general'then return end
 local shape=Families.shape(c.primary,c.secondary,c.mid,c.behavior,c.collision)
 if not(c.shape and shape and c.shape.nativeFence==shape.nativeFence)then return end
 if shape and shape.nativeFence=='rural149'then return 'oras_rural_fence'end
 if shape and shape.nativeFence=='rustboro'then
  for _,q in ipairs(Families.ground[c.mid])do if not(c.ts.midToSlot and c.ts.midToSlot[q[1]])then return end end
  if Families.plants[c.mid]and not c.ts.midToSlot[c.mid]then return end
  return 'oras_rustboro_fence'
 end
end
function M.placements(cells)
 local out={}
 for _,c in pairs(cells)do
  local id=M.eligible(c)
  if id=='oras_rural_fence'then out[#out+1]={model=id,x=c.cx*16,y=c.base or 0,z=c.cy*16,
   fit={width=16,depth=16,padding=0},source=c,marker=id}
  elseif id then for _,segment in ipairs(Families.ornate[c.mid])do
   out[#out+1]={model='oras_rustboro_fence_'..segment[1],x=c.cx*16,y=c.base or 0,z=c.cy*16,
    fit={width=16,depth=16,height=11,padding=0,rotation=segment[4],anchor='center',targetX=segment[2],targetZ=segment[3]},source=c,marker=id}
  end end
 end
 table.sort(out,function(a,b)return a.z==b.z and a.x<b.x or a.z<b.z end)
 return out
end
function M.build(cells,newMesh,parts)
 local list=M.placements(cells)
 if #list==0 then return parts,nil,0 end
 for _,p in ipairs(list)do local ok,err=M.register(p.model);if not ok then return nil,err,0 end end
 local result,err=Models.buildBatches(list,newMesh,{parts=parts})
 if result then for _,p in ipairs(list)do p.source.importedFence=p.marker end end
 local count,seen=0,{}
 if result then for _,p in ipairs(list)do if not seen[p.source]then seen[p.source]=true;count=count+1 end end end
 return result,err,count
end
function M.floor(c)
 if c and c.importedFence and M.eligible(c)==c.importedFence then return c.importedFence=='oras_rural_fence'and 1 or c.mid end
end
-- emit receives ordinary four-position quad + exact cropped atlas UVs. The
-- caller owns elevation lifting, just as for its ordinary terrain plane.
function M.appendFloor(c,emit,uvFor)
 if M.eligible(c)~='oras_rustboro_fence'or c.importedFence~='oras_rustboro_fence'then return false end
 local quads={}
 for n,q in ipairs(Families.ground[c.mid])do
  local uv=uvFor(c.ts,q[1]);if not uv then return false end
  local u,v=q[2]%2*.5,math.floor(q[2]/2)*.5
  local function at(x,y)
   return{uv[1][1]+(uv[2][1]-uv[1][1])*(u+x*.5),uv[1][2]+(uv[4][2]-uv[1][2])*(v+y*.5)}
  end
  local x,z=c.cx*16+(n-1)%2*8,c.cy*16+math.floor((n-1)/2)*8
  quads[#quads+1]={{{x,0,z},{x+8,0,z},{x+8,0,z+8},{x,0,z+8}},{at(0,0),at(1,0),at(1,1),at(0,1)}}
 end
 if Families.plants[c.mid]then
  local uv=uvFor(c.ts,c.mid);if not uv then return false end
  local du,dv=uv[2][1]-uv[1][1],uv[4][2]-uv[1][2]
  for _,row in ipairs(Families.plantRows(c))do
   local x,z,w=row[1],row[2],row[3]
   local l,r=uv[1][1]+du*x/16,uv[1][1]+du*(x+w)/16
   local t,b=uv[1][2]+dv*z/16,uv[1][2]+dv*(z+1)/16
   x,z=x+c.cx*16,z+c.cy*16
   quads[#quads+1]={{{x,.025,z},{x+w,.025,z},{x+w,.025,z+1},{x,.025,z+1}},{{l,t},{r,t},{r,b},{l,b}}}
  end
 end
 for _,q in ipairs(quads)do emit(q[1],q[2],1)end
 return true
end
function M.underOnly(c)return M.floor(c)~=nil and c.ts.layered==true end
return M
