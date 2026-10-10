-- Complete five-cell yellow office drawing; source roof tank raised in volume.
local M={}
function M.append(g,p,emit)
 local x,z=g.cx*16,g.cy*16
 local function uv(a,b,c,d)return {{a/164,b/96},{c/164,b/96},{c/164,d/96},{a/164,d/96}}end
 local function sw(a,b)return uv(a+.1,b+.1,a+.2,b+.2)end
 local wall,trim=sw(8,55),sw(2,34)
 local function face(v,t,s)local out={};for i,q in ipairs(v)do out[i]={x+q[1],q[2],z+q[3]}end;emit(out,t,s or 1)end
 local function box(a,b,n,c,h,f,t)
  face({{a,h,f},{c,h,f},{c,b,f},{a,b,f}},t)
  face({{c,h,n},{a,h,n},{a,b,n},{c,b,n}},t,.8)
  face({{a,h,n},{a,h,f},{a,b,f},{a,b,n}},t,.82)
  face({{c,h,f},{c,h,n},{c,b,n},{c,b,f}},t,.9)
  face({{a,h,n},{c,h,n},{c,h,f},{a,h,f}},t)
  face({{a,b,f},{c,b,f},{c,b,n},{a,b,n}},t,.65)
 end
 -- Native roof projection's rear row is walkable in both editions.
 box(2,0,18,78,64,95,wall)
 face({{2,64,95.03},{78,64,95.03},{78,0,95.03},{2,0,95.03}},uv(2.03,44.03,77.97,95.97))
 for level=0,2 do
  local low=level*16+8
  for zz=24,72,24 do
   face({{1.97,low+12,zz},{1.97,low+12,zz+16},{1.97,low,zz+16},{1.97,low,zz}},uv(8,45,24,60),.82)
   face({{78.03,low+12,zz+16},{78.03,low+12,zz},{78.03,low,zz},{78.03,low,zz+16}},uv(8,45,24,60),.9)
  end
  box(1,low+13,18,3,low+15,95,wall);box(77,low+13,18,79,low+15,95,wall)
  box(1,low+13,17.5,79,low+15,19,wall)
  for xx=8,56,24 do face({{xx+16,low+12,17.97},{xx,low+12,17.97},{xx,low,17.97},{xx+16,low,17.97}},uv(8,45,24,60),.8)end
 end
 box(0,63,16,80,66,96,trim)
 -- Clean central roof stripes; original tank pixels belong to the raised tank.
 face({{3,66.03,19},{77,66.03,19},{77,66.03,93},{3,66.03,93}},uv(4,5,45,29))
 for _,v in ipairs({{1,17,79,20},{1,92,79,95},{1,20,4,92},{76,20,79,92}})do box(v[1],66,v[2],v[3],68,v[4],wall)end
 box(50,66,23,69,76,45,uv(49,18,69,27))
 local metal=sw(58,12)
 for i=0,15 do
  local a,b=i*math.pi/8,(i+1)*math.pi/8
  local function q(t,h)return {59.5+8*math.cos(t),h,34+8*math.sin(t)}end
  face({q(a,81),q(b,81),q(b,76),q(a,76)},metal,.85+.12*math.sin(a))
  face({{59.5,81,34},q(a,81),q(b,81),{59.5,81,34}},metal)
  face({{59.5,76,34},q(b,76),q(a,76),{59.5,76,34}},metal,.65)
 end
end
return M
