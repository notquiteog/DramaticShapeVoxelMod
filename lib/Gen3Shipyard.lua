-- Stern's native shipyard: edition-specific roof/wall pixels on a closed shed.
local M={}
function M.append(g,p,emit)
 local x,z=g.cx*16,g.cy*16
 local function uv(a,b,c,d)return {{a/260,b/112},{c/260,b/112},{c/260,d/112},{a/260,d/112}}end
 local function sw(a,b)return uv(a+.1,b+.1,a+.2,b+.2)end
 local trim,metal=sw(3,74),sw(40,82)
 local function face(v,t,s)local out={};for i,q in ipairs(v)do out[i]={x+q[1],q[2],z+q[3]}end;emit(out,t,s or 1)end
 local function box(a,b,n,c,h,f,t)
  face({{a,h,f},{c,h,f},{c,b,f},{a,b,f}},t)
  face({{c,h,n},{a,h,n},{a,b,n},{c,b,n}},t,.8)
  face({{a,h,n},{a,h,f},{a,b,f},{a,b,n}},t,.82)
  face({{c,h,f},{c,h,n},{c,b,n},{c,b,f}},t,.9)
  face({{a,h,n},{c,h,n},{c,h,f},{a,h,f}},t)
  face({{a,b,f},{c,b,f},{c,b,n},{a,b,n}},t,.65)
 end
 -- The rear projected roof row and the inner entrance cell remain traversable.
 box(2,0,18,32,40,111,metal);box(48,0,18,126,40,111,metal)
 box(32,0,18,48,40,79,metal);box(32,24,79,48,40,111,metal)
 local function front(a,b,top,bottom,depth)
  face({{a,112-top,depth},{b,112-top,depth},{b,112-bottom,depth},{a,112-bottom,depth}},uv(a+.03,top+.03,b-.03,bottom-.03))
 end
 front(2,32,72,112,111.03);front(48,126,72,112,111.03);front(32,48,72,88,111.03)
 front(32,48,88,112,110.05)
 -- Carry the native material around the unseen walls: metal courses in Emerald,
 -- timber battens in Ruby/Sapphire. All sampling stays within a solid wall bay.
 for zz=18,98,16 do
  for _,sx in ipairs({1.97,126.03})do
   face({{sx,40,zz},{sx,40,math.min(zz+16,111)},{sx,0,math.min(zz+16,111)},{sx,0,zz}},uv(48,72,64,112),sx<64 and .82 or .9)
  end
 end
 for xx=2,114,16 do
  face({{math.min(xx+16,126),40,17.97},{xx,40,17.97},{xx,0,17.97},{math.min(xx+16,126),0,17.97}},uv(48,72,64,112),.8)
 end
 -- Shallow mono-pitch industrial roof, closed on every edge and underneath.
 local function h(zz)return 54-(zz-16)*12/96 end
 face({{0,h(16),16},{128,h(16),16},{128,h(112),112},{0,h(112),112}},uv(34,4,94,68))
 face({{0,40,112},{128,40,112},{128,40,16},{0,40,16}},trim,.65)
 face({{0,h(16),16},{0,h(112),112},{0,40,112},{0,40,16}},trim,.82)
 face({{128,h(112),112},{128,h(16),16},{128,40,16},{128,40,112}},trim,.9)
 face({{128,h(16),16},{0,h(16),16},{0,40,16},{128,40,16}},trim,.8)
 face({{0,h(112),112},{128,h(112),112},{128,40,112},{0,40,112}},trim)
 -- Two low, framed dark roof vents, reconstructed above the roof plane.
 for _,xx in ipairs({16,96})do
  face({{xx,h(22)+1.2,22},{xx+16,h(22)+1.2,22},{xx+16,h(96)+1.2,96},{xx,h(96)+1.2,96}},uv(16,14,32,64))
  for _,side in ipairs({xx,xx+16})do
   face({{side,h(22)+1.2,22},{side,h(96)+1.2,96},{side,h(96),96},{side,h(22),22}},trim,.8)
  end
  for _,zz in ipairs({22,96})do face({{xx,h(zz)+1.2,zz},{xx+16,h(zz)+1.2,zz},{xx+16,h(zz),zz},{xx,h(zz),zz}},trim)end
 end
end
return M
