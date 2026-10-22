-- Native RSE truck cargo only. The engine owns the sequence, locks, sounds,
-- moving object offsets and live doorway; this module only supplies geometry.
local V=...
local M={pair='general__inside_of_truck'}
local editions={ruby=true,sapphire=true,emerald=true}
local blocked={'11111','10000','10000','11100','11111'}
local closed={[0x208]=0x20d,[0x210]=0x215,[0x218]=0x21d}
local meshes={}
local function recipe(r)
 return r and r.name=='hoenn_truck_cargo' and r.pair==M.pair
  and r.family=='rse' and r.primary=='general' and r.design=='em_truck_cargo'
end
function M.claimCells()
 local out={}
 for y,row in ipairs(blocked)do for x=1,#row do
  if row:sub(x,x)=='1'then out[x..':'..y]=true end
 end end
 return out
end
function M.matches(r,actual,expected)
 return recipe(r) and closed[expected]~=nil and actual==closed[expected]
end
-- Exact artwork identifies the room; known native permissions still veto
-- any static cargo whose blocked footprint was changed by another provider.
function M.footprint(r,cells,x,y)
 if not recipe(r)then return true end
 for dy,row in ipairs(blocked)do for dx=1,#row do if row:sub(dx,dx)=='1'then
  local c=cells[(x+dx-1)..':'..(y+dy-1)]
  if not c or c.collision~=nil and c.collision~=7 then return false end
 end end end
 return true
end
function M.eligible(gid,def,edition)
 return editions[edition]==true and tonumber(gid)==113
  and def and def.midLayout and def.midLayout.pair==M.pair or false
end
-- The reviewed native single-frame 16px moving-box drawing has a top in
-- rows1..4 and a front in rows5..14. Unproject those onto a closed box,
-- excluding the drawing's outer background border. Reuse its crate panels
-- on the hidden sides/rear; never project the perspective top down a wall.
-- Coordinates are local to the native cell centre; camera yaw is irrelevant.
function M.geometry(spr,frame)
 if not(spr and spr.image and spr.quads and spr.quads[frame])then return nil,'moving-box source unavailable' end
 local qx,qy,qw,qh=spr.quads[frame]:getViewport()
 if qw~=16 or qh~=16 or frame~=0 or spr.frameCount~=1 then return nil,'unreviewed moving-box drawing' end
 local iw,ih=spr.image:getDimensions()
 local function uv(l,t,r,b)
  return {{(qx+l+.01)/iw,(qy+t+.01)/ih},{(qx+r-.01)/iw,(qy+t+.01)/ih},
   {(qx+r-.01)/iw,(qy+b-.01)/ih},{(qx+l+.01)/iw,(qy+b-.01)/ih}}
 end
 local top,front=uv(1,1,15,5),uv(1,5,15,15)
 local u,v=(qx+8.5)/iw,(qy+14.5)/ih
 local bottom={{u,v},{u,v},{u,v},{u,v}}
 local vertices,indices={},{}
 local function face(points,tex,shade)
  local base=#vertices
  for k,p in ipairs(points)do vertices[#vertices+1]={p[1],p[2],p[3],tex[k][1],tex[k][2],shade}end
  for _,n in ipairs{1,2,3,1,3,4}do indices[#indices+1]=base+n end
 end
 face({{-7,10,-7},{7,10,-7},{7,10,7},{-7,10,7}},top,.95)
 face({{-7,10,7},{7,10,7},{7,0,7},{-7,0,7}},front,.85)
 face({{7,10,-7},{-7,10,-7},{-7,0,-7},{7,0,-7}},front,.8)
 face({{-7,10,-7},{-7,10,7},{-7,0,7},{-7,0,-7}},front,.82)
 face({{7,10,7},{7,10,-7},{7,0,-7},{7,0,7}},front,.88)
 face({{-7,0,7},{7,0,7},{7,0,-7},{-7,0,-7}},bottom,.7)
 return vertices,indices
end
-- actor() passes native raiseX in x and -raiseY in height already. A pure
-- world translation preserves those offsets in opaque, shadow and reflection
-- passes, without consuming player/character style or mutating any object.
function M.draw(gid,x,z,height,spr,frame,draw,reflection)
 local ok,result=pcall(function()
  local GV=require('src.core.GameVersion')
  local Map=require('src.core.game3.map')
  if not M.eligible(gid,Map.currentDef(),GV.get()) or V.require('VisualStyles').hd2d('props')then return false end
  local byFrame=meshes[spr and spr.image]
  local mesh=byFrame and byFrame[frame]
  if not mesh then
   local vertices,indices=M.geometry(spr,frame)
   if not vertices then return false end
   mesh=V.require('Voxel3D').newMesh(vertices,indices)
   if not mesh then return false end
   byFrame=byFrame or {};meshes[spr.image]=byFrame;byFrame[frame]=mesh
  end
  local Mat,Shadow=V.require('Mat4'),V.require('ShadowMap')
  local model=Mat.translate(x+8,height,z+8)
  local caster=Shadow.snug(model)
  if reflection then
   model=Mat.mul(Mat.translate(x+8,2*reflection-height+V.require('Water').CAST_RAISE,z+8),Mat.scale(1,-1,1))
  end
  if draw==Shadow.draw then draw(mesh,spr.image,caster)
  else draw(mesh,spr.image,model,nil,caster)end
  return true
 end)
 if not ok then M.lastError=tostring(result);return false end
 return result
end
function M.clear()
 for _,frames in pairs(meshes)do for _,mesh in pairs(frames)do mesh:release()end end
 meshes={}
end
return M
