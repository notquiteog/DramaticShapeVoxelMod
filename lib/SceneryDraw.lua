-- Opaque/cutout scenery shares the ordinary terrain pass. Authored blended
-- surfaces retain source opacity and render after opaque geometry and actors.
local V=...
local R=V.require('Voxel3D')
local M={}
local Cull=V.require('FrustumCull')
local function visible(p,planes)return p.role=='hd2d_flower_cards'or Cull.visible(planes,p.bounds)end
local function blended(p)return p.alphaMode=='blend'or(p.opacity or 1)<1 end
local function partDraw(p,draw)
 if p.role~='hd2d_flower_cards'then return draw(p.mesh,p.image)end
 local before=R.canopyFacing;R.canopyFacing=true
 local ok,err=pcall(draw,p.mesh,p.image)
 R.canopyFacing=before
 if not ok then error(err,0)end
end
function M.opaque(parts,draw,shadow,planes,lightPlanes)
 -- Light planes are explicit: a caller passing camera planes must never
 -- accidentally drop an off-camera caster. Unknown/deformed parts fail open.
 local passPlanes=planes
 if shadow then passPlanes=lightPlanes end
 for _,p in ipairs(parts or{})do
  if p.count>0 and not blended(p) and not(shadow and p.role=='ground_shadow')and visible(p,passPlanes)then partDraw(p,draw)end
 end
end
function M.blended(parts,draw,eye,planes)
 local list={};eye=eye or{0,0,0}
 for i,p in ipairs(parts or{})do if p.count>0 and blended(p)and(p.opacity or 1)>0 and visible(p,planes)then
  local c=p.center or{0,0,0};local d=0
  for a=1,3 do d=d+(c[a]-eye[a])^2 end
  list[#list+1]={part=p,distance=d,index=i}
 end end
 table.sort(list,function(a,b)return a.distance==b.distance and a.index<b.index or a.distance>b.distance end)
 for _,entry in ipairs(list)do local p=entry.part
  R.withSceneryMaterial(p.opacity or 1,function()partDraw(p,draw)end)
 end
 return #list
end
return M
