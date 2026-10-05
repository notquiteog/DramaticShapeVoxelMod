-- The live engine object list continues to own Cut flags and removal.
local V=...
local M={};local meshes={}
local function hash(a,b,c)local s=math.sin(a*127.1+b*311.7+(c or 0)*74.7)*43758.5453123;return s-math.floor(s)end
function M.draw(gid,x,z,height,texture,draw,reflection)
 if not V.require('CommunityVisuals').customCutTrees()or not V.require('TreePresentation').voxel()then return false end
 local ids=require('src.core.game3.field_moves').GFX_IDS
 if not tonumber(gid)or tonumber(gid)~=ids.CUT_TREE then return false end
 local cx,cy=math.floor(x/16),math.floor(z/16);local key=(cx%4)..':'..(cy%4)
 local ok,result=pcall(function()
  local mesh=meshes[key]
  if not mesh then
   local wood,wi,leaf,li={},{},{},{}
   V.require('LegendarySapling').append(wood,wi,0,leaf,li,0,0,0,0,cx%4,cy%4,hash)
   local Materials=V.require('ReferenceMaterials')
   for _,p in ipairs(wood)do p[6]=Materials.encode('forestBark',p[6])end
   local offset=#wood
   for _,p in ipairs(leaf)do p[6]=Materials.encode('forestLeaf',p[6]);wood[#wood+1]=p end
   for _,i in ipairs(li)do wi[#wi+1]=i+offset end
   mesh=V.require('Voxel3D').newMesh(wood,wi);if not mesh then return false end
   meshes[key]=mesh
  end
  local Mat=V.require('Mat4')
  local y=reflection and 2*reflection-height+V.require('Water').CAST_RAISE or height
  local model=Mat.translate(x+8,y,z+8)
  if reflection then model=Mat.mul(model,Mat.scale(1,-1,1))end
  local Shadow=V.require('ShadowMap');local caster=Shadow.snug(model)
  if draw==Shadow.draw then draw(mesh,texture,caster)
  else draw(mesh,texture,model,nil,caster)end
  return true
 end)
 if not ok then M.lastError=tostring(result);return false end
 return result
end
function M.clear()for _,m in pairs(meshes)do m:release()end;meshes={}end
return M
