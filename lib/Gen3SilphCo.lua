-- Silph's native glazed office tower and curved central rooflight.
local M={}
function M.append(g,p,emit)
 local x,z=g.cx*16,g.cy*16
 local function uv(a,b,c,d)return {{a/292,b/240},{c/292,b/240},{c/292,d/240},{a/292,d/240}}end
 local function sw(a,b)return uv(a+.5,b+.5,a+.5,b+.5)end
 local stone,dark=sw(6,86),sw(8,96)
 local function face(v,t,s)local out={};for i,q in ipairs(v)do out[i]={x+q[1],q[2],z+q[3]}end;emit(out,t,s or 1)end
 local function box(a,b,n,c,h,f,t)
  face({{a,h,f},{c,h,f},{c,b,f},{a,b,f}},t)
  face({{c,h,n},{a,h,n},{a,b,n},{c,b,n}},t,.8)
  face({{a,h,n},{a,h,f},{a,b,f},{a,b,n}},t,.82)
  face({{c,h,f},{c,h,n},{c,b,n},{c,b,f}},t,.9)
  face({{a,h,n},{c,h,n},{c,h,f},{a,h,f}},t)
  face({{a,b,f},{c,b,f},{c,b,n},{a,b,n}},t,.65)
 end
 -- Source first row is native walking floor; do not place a rear wall there.
 box(2,0,18,64,160,239,stone);box(80,0,18,142,160,239,stone)
 box(64,20,18,80,160,239,stone);box(64,0,18,80,20,19,stone)
 local function front(a,b,top,bottom,depth)
  face({{a,240-top,depth},{b,240-top,depth},{b,240-bottom,depth},{a,240-bottom,depth}},uv(a+.03,top+.03,b-.03,bottom-.03))
 end
 front(2,64,80,240,239.03);front(80,142,80,240,239.03);front(64,80,80,224,239.03)
 face({{64,20,238.05},{80,20,238.05},{80,0,238.05},{64,0,238.05}},uv(64.03,224.03,79.97,239.97))
 -- Storey bands and glazed panels continue around the solid side/rear faces.
 for level=0,9 do
  local low=level*16
  for zz=24,216,24 do
   face({{1.97,low+14,zz},{1.97,low+14,zz+16},{1.97,low+2,zz+16},{1.97,low+2,zz}},uv(32,100,48,112),.88)
   face({{142.03,low+14,zz+16},{142.03,low+14,zz},{142.03,low+2,zz},{142.03,low+2,zz+16}},uv(32,100,48,112),.9)
  end
  for xx=8,120,24 do
   face({{xx+16,low+14,17.97},{xx,low+14,17.97},{xx,low+2,17.97},{xx+16,low+2,17.97}},uv(32,100,48,112),.8)
  end
  box(1,low+14,18,3,low+16,239,dark);box(141,low+14,18,143,low+16,239,dark)
  box(1,low+14,17.5,143,low+16,19,dark)
 end
 -- Closed lavender roof deck with narrow eaves tied to the real rear wall.
 box(0,159,16,144,162,240,dark)
 face({{2,162.03,18},{48,162.03,18},{48,162.03,238},{2,162.03,238}},uv(3,10,48,74))
 face({{96,162.03,18},{142,162.03,18},{142,162.03,238},{96,162.03,238}},uv(96,10,141,74))
 for _,xx in ipairs({6,14,22,30,38,102,110,118,126,134})do box(xx,162,18,xx+1,163,238,stone)end
 -- Arched rooflight: original blue glazing, solid end caps and transverse ribs.
 local points={}
 for i=0,16 do local a=math.pi-i*math.pi/16;points[i+1]={72+24*math.cos(a),162+18*math.sin(a)}end
 for i=1,16 do
  local a,b=points[i],points[i+1]
  face({{a[1],a[2],18},{b[1],b[2],18},{b[1],b[2],238},{a[1],a[2],238}},uv(48+(i-1)*3,8,48+i*3,66))
  for _,zz in ipairs({18,238})do
   face({{72,162,zz},{a[1],a[2],zz},{b[1],b[2],zz},{72,162,zz}},{{72/292,80/240},{a[1]/292,(80-(a[2]-162)*.8)/240},{b[1]/292,(80-(b[2]-162)*.8)/240},{72/292,80/240}},.9)
  end
 end
 for _,zz in ipairs({18,62,106,150,194,236})do
  for i=1,16 do local a,b=points[i],points[i+1]
   local v={{a[1],a[2]+.4,zz},{b[1],b[2]+.4,zz},{b[1],b[2]+.4,zz+1.2},{a[1],a[2]+.4,zz+1.2}}
   face(v,stone,.92)
   local bot={};for j,q in ipairs(v)do bot[j]={q[1],q[2]-.4,q[3]}end
   face({bot[4],bot[3],bot[2],bot[1]},stone,.65)
   for j,q in ipairs(v)do local k=j%4+1;face({q,v[k],bot[k],bot[j]},stone,.85)end
  end
 end
 -- Recessed door surround and enclosed canopy use the original entry pixels.
 for _,xx in ipairs({64,80})do box(xx-.3,0,238,xx+.3,20,239,stone)end
 box(48,20,234,96,32,239,dark)
 face({{48,32,239.05},{96,32,239.05},{96,20,239.05},{48,20,239.05}},uv(48.03,208.03,95.97,223.97))
end
return M
