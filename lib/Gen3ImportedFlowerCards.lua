-- Source flower/leaf artwork stays flat HD2D. It shares the existing native
-- cylindrical billboard shader and scene-owned cleanup; no closed petals.
local V=...
local Models=V.require('SceneryModels')
local M={FORMAT={{'VertexPosition','float',3},{'VertexTexCoord','float',2},
 {'VertexShade','float',1},{'VertexColor','float',4},{'VertexCanopy','float',3}}}
function M.geometry(g,fit)
 local source=V.require('ImportedHoennShopData').oras_route104_pretty_petal_shop
 local vs,indices={},{};local x0,z0=g.cx*16,(g.cy+1)*16;local base=g.groundHeight or 0
 for _,card in ipairs(source.hd2dCards)do
  local a=card.anchor;local ax,az=a[1]*fit.scale+fit.x,a[3]*fit.scale+fit.z
  local radius=0
  for _,v in ipairs(card.vertices)do radius=math.max(radius,math.abs(v[1]-a[1])*fit.scale)end
  assert(radius<23.75,'source flower card exceeds native footprint')
  local nx=math.max(.25+radius,math.min(95.75-radius,ax))
  local nz=math.max(.25+radius,math.min(47.75-radius,az))
  local ay=base+a[2]*fit.scale;local first=#vs
  for j,v in ipairs(card.vertices)do
   local color=card.colors[j]
   vs[#vs+1]={x0+v[1]*fit.scale+fit.x+nx-ax,base+v[2]*fit.scale,z0+nz,
    v[4],v[5],v[6],color[1],color[2],color[3],color[4],x0+nx,z0+nz,ay}
  end
  for _,i in ipairs(card.indices)do indices[#indices+1]=first+i end
 end
 return vs,indices,#source.hd2dCards
end
function M.build(g,fit,id,newMesh,parts)
 local part={modelId=id,role='hd2d_flower_cards',alphaMode='cutout',opacity=1,count=19}
 -- Register ownership before cooperative resource loading/upload can yield.
 parts[#parts+1]=part
 local ok,err=pcall(function()
  local vertices,indices,count=M.geometry(g,fit);part.count=count
  part.image=assert(Models.image(id,'assets/scenery/oras-route104-shop/r104_dif03.png','repeat','repeat'),'source flower atlas unavailable')
  part.mesh=assert(newMesh(vertices,indices,M.FORMAT),'HD2D flower upload failed');part.mesh:setTexture(part.image)
 end)
 if not ok then Models.releaseBatches({part});parts[#parts]=nil;return false,tostring(err)end
 return true
end
return M
