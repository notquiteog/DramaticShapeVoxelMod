-- Native League sculptures: upper BG2 figure on a separate, closed plinth.
-- Neither the artwork's projected top row nor its shadow becomes solid floor.
local V=...
local M={}
local templates=setmetatable({},{__mode='k'})
function M.append(p,emit,uvFor,box,source,sample)
 local ts,r=p.ts,p.recipe
 local x,z=p.cx*16,p.cy*16
 if r.baseMid then
  local base=assert(uvFor(ts,r.baseMid))
  local function tex(px,py)return{base[1][1]+(base[2][1]-base[1][1])*px/16,base[1][2]+(base[3][2]-base[1][2])*py/16}end
  sample=function(px,py)local t=tex(px+.5,py-16+.5);return{t,t,t,t}end
  source=function(px,py,w,h,a,b,c,d)
   py=py-16;emit({a,b,c,d},{tex(px,py),tex(px+w,py),tex(px+w,py+h),tex(px,py+h)},1)
  end
 end
 local stone=sample(7,22)
 box(x+1,0,z+17,x+15,2,z+31,stone)
 box(x+2,2,z+18,x+14,9,z+30,sample(3,23))
 box(x+1,9,z+17,x+15,11,z+31,stone)
 source(3,22,10,7,{x+3,8,z+30.02},{x+13,8,z+30.02},{x+13,2,z+30.02},{x+3,2,z+30.02})
 -- Close the underside (the shared box helper emits five faces).
 emit({{x+1,0,z+31},{x+15,0,z+31},{x+15,0,z+17},{x+1,0,z+17}},stone,.65)
 if not ts.imageData or not ts.overImageData then return end
 local mid=r.rows[1][1]
 local byMid=templates[ts] or {};templates[ts]=byMid
 local faces=byMid[mid]
 if not faces then
  local slot=ts.midToSlot[mid];local uv=uvFor(ts,mid)
  if not slot or not uv then return end
  local ax,ay=slot%ts.cols*16,math.floor(slot/ts.cols)*16
  faces=V.require('VoxelHull').build(16,16,function(px,py)
   -- The statue's figure is entirely in the transparent upper layer.
   -- Using its alpha excludes every floor pixel without palette guesses.
   local rr,gg,bb,aa=ts.overImageData:getPixel(ax+px,ay+py)
   local u=uv[1][1]+(uv[2][1]-uv[1][1])*(px+.5)/16
   local v=uv[1][2]+(uv[3][2]-uv[1][2])*(py+.5)/16
   return rr,gg,bb,aa,u,v
  end,1,0,8)
  byMid[mid]=faces
 end
 for _,q in ipairs(faces)do
  local vertices={};for i,v in ipairs(q)do vertices[i]={x+8+v[1],11+v[2],z+24+v[3]}end
  local t={q.u,q.v};emit(vertices,{t,t,t,t},q.shade)
 end
end
return M
