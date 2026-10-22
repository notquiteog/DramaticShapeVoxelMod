-- Briney's engine-owned actor and travel scripts keep their native lifetime,
-- position and heading. Only the Modern 3D prop drawing is replaced.
local V=...
local M={}
local parts,failed
local id='oras_briney_boat'
local headings={down=0,right=math.pi*.5,up=math.pi,left=math.pi*1.5}
function M.eligible(gid,edition)
 return tonumber(gid)==88 and(edition=='ruby'or edition=='sapphire'or edition=='emerald')
end
local function prepare()
 if parts then return parts end
 if failed then return end
 local Models=V.require('SceneryModels')
 local info=Models.info(id)
 if not info then
  local ok,data=pcall(V.require,'OrasBoatData')
  if not ok or type(data)~='table'then failed=true;M.lastError='ORAS boat source unavailable';return end
  local registered,err=Models.register(id,data,{read=function(path)return V.mod:read(path)end})
  if not registered then failed=true;M.lastError=err;return end
 end
 local options={width=32,depth=32,padding=.25}
 local fit,err=Models.fit(id,options)
 if not fit or not fit.anchors.waterline then failed=true;M.lastError=err or'boat waterline unavailable';return end
 local result,why=Models.buildBatches({{model=id,x=-16,y=-fit.anchors.waterline[2],z=-16,fit=options}},V.require('Voxel3D').newMesh)
 if not result then failed=true;M.lastError=why;return end
 parts=result;M.lastError=nil;return parts
end
function M.draw(gid,x,z,height,facing,draw,reflection)
 if not M.eligible(gid,require('src.core.GameVersion').get())or not V.require('VisualStyles').modern('props')then return false end
 local ok,result=pcall(function()
  local ready=prepare();if not ready then return false end
  local Mat,Shadow,R=V.require('Mat4'),V.require('ShadowMap'),V.require('Voxel3D')
  local rotation=Mat.rotateY(headings[facing]or 0)
  local model=Mat.mul(Mat.translate(x+8,height,z+8),rotation)
  local caster=Shadow.snug(model)
  if reflection then
   model=Mat.mul(Mat.translate(x+8,2*reflection-height+V.require('Water').CAST_RAISE,z+8),Mat.mul(Mat.scale(1,-1,1),rotation))
  end
  for _,part in ipairs(ready)do
   if draw==Shadow.draw then draw(part.mesh,part.image,caster)
   else
    local function paint()draw(part.mesh,part.image,model,nil,caster)end
    if part.alphaMode=='blend'or(part.opacity or 1)<1 then R.withSceneryMaterial(part.opacity or 1,paint)
    else paint()end
   end
  end
  M.draws=(M.draws or 0)+1;return true
 end)
 if not ok then M.lastError=tostring(result);return false end
 return result
end
function M.clear()
 if parts then V.require('SceneryModels').releaseBatches(parts)end
 parts,failed=nil,nil
end
return M
