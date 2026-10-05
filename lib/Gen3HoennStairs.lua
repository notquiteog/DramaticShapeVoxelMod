-- Littleroot's north-facing flights and enclosed descending wells.
-- The native warp, collision and actor movement remain engine-owned.
local M={}
function M.append(g,emit,uvFor)
 local ox,oz=g.cx*16,g.cy*16
 local function color(x,y)
  local mid=g.r.rows[math.floor(y/16)+1][math.floor(x/16)+1]
  local uv=assert(uvFor(g.ts,mid))
  local u=uv[1][1]+(uv[2][1]-uv[1][1])*(x%16+.5)/16
  local v=uv[1][2]+(uv[3][2]-uv[1][2])*(y%16+.5)/16
  return {{u,v},{u,v},{u,v},{u,v}}
 end
 local function face(q,uv,shade)
  for _,p in ipairs(q)do p[1],p[3]=p[1]+ox,p[3]+oz end
  emit(q,uv,shade or 1)
 end
 local function box(l,b,n,r,h,s,uv)
  face({{l,h,n},{r,h,n},{r,h,s},{l,h,s}},uv)
  face({{l,b,s},{r,b,s},{r,h,s},{l,h,s}},uv,.85)
  face({{r,b,n},{l,b,n},{l,h,n},{r,h,n}},uv,.7)
  face({{l,b,n},{l,b,s},{l,h,s},{l,h,n}},uv,.76)
  face({{r,b,s},{r,b,n},{r,h,n},{r,h,s}},uv,.8)
  face({{l,b,s},{l,b,n},{r,b,n},{r,b,s}},uv,.6)
 end
 -- The native drawing is a framed opening in the wall, not an exposed
 -- staircase with full-height solid banisters. Sample the gold trim, wood
 -- and dark recess separately; the old samples both hit the purple outline.
 local trim=color(16,11)
 local wood=color(24,g.r.down and 29 or 31)
 local dark=color(17,14)
 local wall=color(4,14)
 local floor=assert(uvFor(g.ts,0x201))
 for _,a in ipairs{{0,12},{36,48}}do
  face({{a[1],0,0},{a[2],0,0},{a[2],0,32},{a[1],0,32}},floor)
  box(a[1],0,7,a[2],32,30,wall)
  box(a[1],0,30,a[2],6,30.1,color(4,28))
 end
 -- Closed jambs and lintel surround a real opening; the tread flight is
 -- behind its front plane. Both floors use the same native portal silhouette.
 box(12,26,7,36,32,30,wall)
 box(12,0,28,15,26,31,wood)
 box(33,0,28,36,26,31,wood)
 box(12,24,28,36,27,31,wood)
 box(12.5,0,31,13.3,26,31.5,trim)
 box(34.7,0,31,35.5,26,31.5,trim)
 box(13,26,31,35,27,31.5,trim)
 local bottom=g.r.down and -16 or 0
 box(14,bottom,7,34,26,8,dark)
 box(14,bottom,8,15,26,30,dark)
 box(33,bottom,8,34,26,30,dark)
 box(15,bottom-1,8,33,bottom,32,wood)
 -- Five native golden treads rise into the recess; a descending flight
 -- begins flush at the threshold and drops away into the same opening.
 for i=0,4 do
  local z=10+i*4.4
  local h=g.r.down and (-15+i*3) or (15-i*3)
  box(15,bottom,z,33,h,z+4.4,wood)
  box(15,h-.5,z+3.7,33,h+.05,z+4.4,trim)
 end
 if g.r.down then box(15,-.5,31.6,33,0,32,wood)end
end
return M
