-- Optional source blossoms in the existing Pretty Petal planter. The default
-- remains HD2D. Missing modern source retains those cards; unsupported native
-- voxel mode returns failure so the caller restores its native-art building.
local V=...
local Models=V.require('SceneryModels')
local Cards=V.require('Gen3ImportedFlowerCards')
local M={id='oras_route104_pretty_petal_pink_flowers',shopId='oras_route104_pretty_petal_shop_native'}
function M.style()
 local ok,styles=pcall(V.require,'VisualStyles')
 if ok and type(styles)=='table'and type(styles.get)=='function'then
  local got,value=pcall(styles.get,'flowers')
  if got and(value=='modern'or value=='voxel'or value=='hd2d')then return value end
 end
 return'hd2d'
end
local function data()
 local ok,d=pcall(V.require,'ImportedHoennFlowerData')
 return ok and type(d)=='table'and d[M.id]or nil
end
local function eligible(g,fit)
 return(g and g.kind=='house'and g.width==6 and g.depth==4 and g.pair=='general__rustboro'
  and g.custom and g.custom.name=='route104_pretty_petal_shop'and g.custom.family=='rse'
  and not g.stageHidden and fit and type(fit.scale)=='number'and fit.scale>0
  and fit.width==96 and fit.depth==48)or false
end
function M.geometry(g,fit)
 if not eligible(g,fit)then return nil,'unreviewed flower placement'end
 local source=data();if not source then return nil,'original ORAS flower source unavailable'end
 local vs,indices={},{};local x0,z0=g.cx*16,(g.cy+1)*16;local base=g.groundHeight or 0
 local p=source.planterBounds
 for _,component in ipairs(source.components)do
  local first=#vs
  for j,v in ipairs(component.vertices)do
   if v[1]<p[1]-1e-6 or v[1]>p[3]+1e-6 or v[3]<p[2]-1e-6 or v[3]>p[4]+1e-6 then return nil,'source flower leaves its original planter'end
   local x,y,z=v[1]*fit.scale+fit.x,v[2]*fit.scale,v[3]*fit.scale+fit.z
   if x<.25 or x>95.75 or z<.25 or z>47.75 then return nil,'source flower crosses native blocked body'end
   local c=component.colors[j]
   vs[#vs+1]={x0+x,base+y,z0+z,v[4],v[5],1,1,1,1,c[4]}
  end
  for _,i in ipairs(component.indices)do indices[#indices+1]=first+i end
 end
 return vs,indices,#source.components
end
local function unwind(parts,first)
 for i=#parts,first,-1 do Models.releaseBatches({parts[i]});parts[i]=nil end
end
local function modern(g,fit,id,newMesh,parts)
 local vertices,indices,count=M.geometry(g,fit);if not vertices then return false,indices end
 local source=data();local part={modelId=id,role='source_flower_faces',alphaMode='cutout',opacity=1,count=count}
 parts[#parts+1]=part
 part.image=assert(Models.image(id,source.texture,'repeat','repeat'),'original flower atlas unavailable')
 part.mesh=assert(newMesh(vertices,indices,Models.COLOR_FORMAT),'original flower mesh unavailable');part.mesh:setTexture(part.image)
 local ok,err=Cards.build(g,fit,id,newMesh,parts,{exclude=source.excludedHd2dCards})
 if not ok then return false,err end
 return true,nil,{style='modern',modernFlowers=count,hd2dComponents=19-count}
end
function M.build(g,fit,id,newMesh,parts,options)
 if not eligible(g,fit)or id~=M.shopId then return false,'unreviewed flower placement'end
 options=options or{};local style=options.style or M.style();local first=#parts+1;local why
 if style=='modern'and id==M.shopId then
  local ok,result,err,info=pcall(modern,g,fit,id,newMesh,parts)
  if ok and result then return true,nil,info end
  why=ok and err or result;unwind(parts,first)
 elseif style=='voxel'then
  if type(options.nativeVoxelBuild)~='function'then return false,'native source unavailable for Pretty Petal flower voxels'end
  -- Provider must use the original native sprite pixels and this same owner.
  -- Its scene-owned destination is registered before any cooperative upload.
  local ok,result,err=pcall(options.nativeVoxelBuild,g,fit,id,newMesh,parts)
  if ok and result==true and #parts>=first then return true,nil,{style='voxel'}end
  why=ok and err or result;unwind(parts,first)
  return false,'native source unavailable for Pretty Petal flower voxels: '..tostring(why or'provider returned no geometry')
 end
 local ok,err=Cards.build(g,fit,id,newMesh,parts)
 return ok,err,{style='hd2d',modernFlowers=0,hd2dComponents=ok and 19 or 0,fallbackReason=why}
end
return M
