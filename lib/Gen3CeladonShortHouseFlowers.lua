-- Original ta_h01 leaf/petal art stays flat and uses the native HD2D shader.
local V=...
local Models=V.require('SceneryModels')
local M={FORMAT={{'VertexPosition','float',3},{'VertexTexCoord','float',2},{'VertexShade','float',1},{'VertexColor','float',4},{'VertexCanopy','float',3}}}
function M.geometry(g,fit)
 local source=V.require('CeladonShortHouseData').hgss_celadon_short_house
 local vertices,indices={},{};local x0,z0,base=g.cx*16,(g.cy+1)*16,g.groundHeight or 0
 for _,card in ipairs(source.hd2dCards)do
  local a=card.anchor;local ax,az=a[1]*fit.scale+fit.x,a[3]*fit.scale+fit.z;local radius=0
  for _,v in ipairs(card.vertices)do radius=math.max(radius,math.abs(v[1]-a[1])*fit.scale)end
  assert(radius<23.75,'source card exceeds native body')
  local nx=math.max(.25+radius,math.min(63.75-radius,ax));local nz=math.max(.25+radius,math.min(47.75-radius,az))
  local ay=base+a[2]*fit.scale;local first=#vertices
  for _,v in ipairs(card.vertices)do
   vertices[#vertices+1]={x0+v[1]*fit.scale+fit.x+nx-ax,base+v[2]*fit.scale,z0+nz,v[4],v[5],1,1,1,1,1,x0+nx,z0+nz,ay}
  end
  for _,i in ipairs(card.indices)do indices[#indices+1]=first+i end
 end
 return vertices,indices
end
function M.build(g,fit,newMesh,parts)
 local part={modelId='hgss_celadon_short_house',role='hd2d_flower_cards',alphaMode='cutout',opacity=1,count=8};parts[#parts+1]=part
 local ok,why=pcall(function()
  local vertices,indices=M.geometry(g,fit)
  part.image=assert(Models.image(part.modelId,'assets/scenery/celadon-short-house/ta_h01.png','repeat','repeat'),'source flower atlas unavailable')
  part.mesh=assert(newMesh(vertices,indices,M.FORMAT),'source HD2D card upload failed');part.mesh:setTexture(part.image)
 end)
 if not ok then Models.releaseBatches({part});parts[#parts]=nil;return false,tostring(why)end
 return true
end
return M
