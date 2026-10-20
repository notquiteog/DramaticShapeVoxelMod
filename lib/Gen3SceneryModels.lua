-- Selected imported scenery with native eligibility, ground and face artwork.
-- Larger buildings require individual blocked-footprint/doorway review first.
local V=...
local Models=V.require('SceneryModels')
local Permissions=require('src.core.CollPermissions')
local M={}
local fit={width=16,depth=16,rotation=0}
function M.placements(cells)
 local list={}
 if V.require('TreePresentation').props:get()~='modeled'
  or V.require('CommunityVisuals').customSigns()then return list end
 for _,c in pairs(cells)do
  if c.shape.kind=='sign'and c.primary=='general'and(c.mid==2 or c.mid==3)
   and c.collision~=nil and not Permissions.isWalkable(c.collision)
   and not(c.boundary or c.stageHidden)then
   list[#list+1]={model='bw2_sign01',x=c.cx*16,y=c.base or 0,z=c.cy*16,fit=fit,source=c}
  end
 end
 table.sort(list,function(a,b)return a.z==b.z and a.x<b.x or a.z<b.z end)
 return list
end
function M.build(cells,newMesh,parts)
 local list=M.placements(cells)
 local result,err=Models.buildBatches(list,newMesh,{parts=parts})
 if result then for _,p in ipairs(list)do p.source.importedSign=true end end
 return result,err,#list
end
-- Source face topology is preserved. Only its message UVs are rebound to the
-- existing native board, so regional lettering never becomes Unova text.
function M.face(c,uv)
 if not c.importedSign then return end
 local vertices,indices,normal=Models.surface('bw2_sign01','message',fit)
 if not vertices then return end
 local l,t,r,b=1,2,15,12
 if c.shape.hoenn then l,t,r,b=2,5,14,13 end
 local du,dv=uv[2][1]-uv[1][1],uv[3][2]-uv[1][2]
 for _,p in ipairs(vertices)do
  p[1]=p[1]+c.cx*16+normal[1]*.015
  p[2]=p[2]+(c.base or 0)+normal[2]*.015
  p[3]=p[3]+c.cy*16+normal[3]*.015
  p[4]=uv[1][1]+du*(l+(r-l)*p[4])/16
  p[5]=uv[1][2]+dv*(t+(b-t)*p[5])/16
 end
 return vertices,indices
end
return M
