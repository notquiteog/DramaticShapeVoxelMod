-- Genuine ORAS exterior for the engine-owned RSE Littleroot truck actor.
-- Its native visibility, position, entrance scripts and lifetime stay native.
local V=...
local M={id='oras_opening_truck'}
local parts,failed
local towns={RU_LITTLEROOT_TOWN=true,SA_LITTLEROOT_TOWN=true,EM_LITTLEROOT_TOWN=true}
local editions={ruby=true,sapphire=true,emerald=true}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
function M.eligible(gid,edition,def,spr,frame)
 return tonumber(gid)==94 and editions[edition]==true and def and towns[def.id]==true
  and def.midLayout and def.midLayout.pair=='general__petalburg'
  and spr and spr.graphicsId==94 and spr.width==48 and spr.height==48
  and spr.frameCount==1 and spr.inanimate==true and frame==0 or false
end
local function prepare()
 if parts then return parts end
 if failed then return end
 local Models=V.require('SceneryModels')
 if not Models.info(M.id)then
  local ok,data=pcall(V.require,'ImportedTruckExteriorData')
  if not ok or type(data)~='table'then failed=true;M.lastError='original ORAS truck exterior unavailable';return end
  local registered,err=Models.register(M.id,data,{read=function(path)return V.mod:read(path)end})
  if not registered then failed=true;M.lastError=err;return end
 end
 -- One uniform fit preserves cabin, loading doors, lettering and wheel sizes.
 -- The native48px truck drawing owns its extent, rather than a trainer scale.
 local result,why=Models.buildBatches({{model=M.id,x=-24,y=0,z=-18,
  fit={width=48,depth=36,padding=.25}}},V.require('Voxel3D').newMesh)
 if not result then failed=true;M.lastError=why;return end
 parts=result;M.lastError=nil;return parts
end
function M.draw(gid,x,z,height,spr,frame,draw,reflection)
 local ok,result=pcall(function()
  if not V.require('VisualStyles').modern('props')or not M.eligible(gid,require('src.core.GameVersion').get(),
   require('src.core.game3.map').currentDef(),spr,frame)then return false end
  if not(finite(x)and finite(z)and finite(height))then return false end
  local ready=prepare();if not ready then return false end
  local Mat,Shadow=V.require('Mat4'),V.require('ShadowMap')
  local model=Mat.translate(x+8,height,z+8);local caster=Shadow.snug(model)
  if reflection then model=Mat.mul(Mat.translate(x+8,2*reflection-height+V.require('Water').CAST_RAISE,z+8),Mat.scale(1,-1,1))end
  for _,part in ipairs(ready)do
   if draw==Shadow.draw then draw(part.mesh,part.image,caster)
   else draw(part.mesh,part.image,model,nil,caster)end
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
