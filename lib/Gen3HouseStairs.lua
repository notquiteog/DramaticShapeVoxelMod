-- Complete native player-house staircase. Independent treads, risers,
-- stringers and continuous handrails, with the original rug on the landing.
-- The native warp remains at the foot; no actor/collision state is changed.
local M={}
function M.append(g,emit,uvFor)
 local down=g.r.down
 local ox,oz=g.cx*16,g.cy*16
 local function tex(x,y)
  local mid=g.r.rows[math.floor(y/16)+1][math.floor(x/16)+1]
  local uv=assert(uvFor(g.ts,mid))
  return {uv[1][1]+(uv[2][1]-uv[1][1])*(x%16+.5)/16,
   uv[1][2]+(uv[3][2]-uv[1][2])*(y%16+.5)/16}
 end
 local function color(x,y)local t=tex(x,y);return {t,t,t,t}end
 local function face(q,uv,shade)
  for _,p in ipairs(q)do p[1],p[3]=p[1]+ox,p[3]+oz end
  emit(q,uv,shade or 1)
 end
 local function box(l,b,n,r,h,s,uv)
  face({{l,h,n},{r,h,n},{r,h,s},{l,h,s}},uv)
  face({{l,b,s},{r,b,s},{r,h,s},{l,h,s}},uv,.85)
  face({{r,b,n},{l,b,n},{l,h,n},{r,h,n}},uv,.72)
  face({{l,b,n},{l,b,s},{l,h,s},{l,h,n}},uv,.78)
  face({{r,b,s},{r,b,n},{r,h,n},{r,h,s}},uv,.8)
  face({{l,b,s},{l,b,n},{r,b,n},{r,b,s}},uv,.6)
 end
 local floor=assert(uvFor(g.ts,1))
 local x0,x1=down and 0 or 16,down and 32 or 48
 -- Tiling the actual clean floor avoids baking stair shadows/rails into it.
 for y=0,2 do for x=0,2 do
  if not down or x==2 or y==0 then
   face({{x*16,0,y*16},{x*16+16,0,y*16},{x*16+16,0,y*16+16},{x*16,0,y*16+16}},floor)
  end
 end end
 -- Only the native landing rectangle: remaining source cells belong to the
 -- modeled flight. Never draw the old diagonal stringer below the new one.
 local rx=down and 32 or 0
 for y=16,32,16 do
  local uv=assert(uvFor(g.ts,g.r.rows[y/16+1][rx/16+1]))
  face({{rx,.02,y},{rx+16,.02,y},{rx+16,.02,y+16},{rx,.02,y+16}},uv)
 end
 local wood=down and color(10,32)or color(19,17)
 local tread=down and color(22,23)or color(25,18)
 local trim=down and color(9,36)or color(20,33)
 -- Ascending right / descending left are both higher toward positive X.
 for i=0,7 do
  local x=x0+i*4;local h=down and (-24+i*3)or (i+1)*3
  box(x,h-1.2,17,x+4,h,43,tread)
  box(x,h-3,17,x+.7,h-1.2,43,wood)
  box(x-.2,h-.65,16.7,x+.7,h+.02,43.3,trim)
 end
 -- Closed sloped rectangular beams: no gaps at stair corners or exposed
 -- underside. Handrails use the same slope as the supporting stringers.
 local low=down and -24 or 3
 local function beam(z,width,y,thickness)
  local a,b=low+y,low+24+y
  face({{x0,a,z},{x1,b,z},{x1,b,z+width},{x0,a,z+width}},trim)
  face({{x0,a-thickness,z+width},{x1,b-thickness,z+width},{x1,b,z+width},{x0,a,z+width}},wood,.85)
  face({{x1,b-thickness,z},{x0,a-thickness,z},{x0,a,z},{x1,b,z}},wood,.72)
  face({{x0,a-thickness,z},{x0,a-thickness,z+width},{x0,a,z+width},{x0,a,z}},trim,.78)
  face({{x1,b-thickness,z+width},{x1,b-thickness,z},{x1,b,z},{x1,b,z+width}},trim,.8)
  face({{x0,a-thickness,z+width},{x0,a-thickness,z},{x1,b-thickness,z},{x1,b-thickness,z+width}},wood,.6)
 end
 for _,z in ipairs({15.5,43.5})do
  beam(z,1,-1,4)
  if not down then
   beam(z-.3,1.6,7,1.4)
   for i=0,4 do
    local x=x0+i*8;local h=low+i*6
    box(x-.55,h-1,z,x+.55,h+7,z+1,wood)
   end
  end
 end
 if down then
  -- Enclose the cut-out on three sides and at its bottom. Leave its
  -- landing edge open so the descending flight reads as a stairwell.
  box(0,-27,15,32,0,16,wood);box(0,-27,44,32,0,48,wood)
  box(0,-27,16,1,0,44,wood);box(0,-28,16,32,-27,44,wood)
  box(0,0,15,32,1,16,trim);box(0,0,44,32,1,46,trim)
  box(31.3,-3,16,32,0,44,wood)
 end
end
return M
