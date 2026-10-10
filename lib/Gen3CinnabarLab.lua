-- Cinnabar's rounded laboratory. Native art supplies the cream ribs, red
-- center roof, glass and sign; every volume is closed inside blocked cells.
local M={}
function M.append(g,p,emit)
 local x,z=g.cx*16,g.cy*16;local W,D=p.w,p.h
 local function uv(a,b,c,d)return {{a/(W*2+4),b/D},{c/(W*2+4),b/D},{c/(W*2+4),d/D},{a/(W*2+4),d/D}}end
 local function sw(a,b)return uv(a+.5,b+.5,a+.5,b+.5)end
 local cream,dark,pale,green=sw(18,10),sw(30,14),sw(5,25),sw(30,58)
 local function face(v,t,s)local q={};for i,a in ipairs(v)do q[i]={x+a[1],a[2],z+a[3]}end;emit(q,t,s or 1)end
 local function box(a,b,c,d,e,f,t)
  face({{a,e,d},{c,e,d},{c,b,d},{a,b,d}},t)
  face({{c,e,f},{a,e,f},{a,b,f},{c,b,f}},t,.8)
  face({{a,e,f},{a,e,d},{a,b,d},{a,b,f}},t,.82)
  face({{c,e,d},{c,e,f},{c,b,f},{c,b,d}},t,.9)
  face({{a,e,f},{c,e,f},{c,e,d},{a,e,d}},t)
  face({{a,b,d},{c,b,d},{c,b,f},{a,b,f}},t,.7)
 end
 -- Flat central body and rounded end caps, all low surfaces south of row 0.
 box(16,0,48,64,48,18,pale);box(64,0,96,64,48,18,pale)
 box(48,24,64,64,48,18,pale);box(48,0,64,19,24,18,pale)
 for _,right in ipairs({false,true})do
  local cx=right and 96 or 16
  for i=0,11 do
   local a,b=-math.pi/2+i*math.pi/12,-math.pi/2+(i+1)*math.pi/12
   local sign=right and 1 or -1
   local ax,az=cx+sign*14*math.cos(a),41+23*math.sin(a)
   local bx,bz=cx+sign*14*math.cos(b),41+23*math.sin(b)
   face({{ax,48,az},{bx,48,bz},{bx,0,bz},{ax,0,az}},pale,.9)
   face({{cx,0,41},{bx,0,bz},{ax,0,az},{cx,0,41}},dark,.6)
   local gx,gz=cx+(ax-cx)*1.003,41+(az-41)*1.003
   local hx,hz=cx+(bx-cx)*1.003,41+(bz-41)*1.003
   face({{gx,7,gz},{hx,7,hz},{hx,1,hz},{gx,1,gz}},green,.85)
  end
 end
 local function panel(a,b,t,d,zz)
  face({{a,(64-t)*1.5,zz},{b,(64-t)*1.5,zz},{b,(64-d)*1.5,zz},{a,(64-d)*1.5,zz}},uv(a+.03,t+.03,b-.03,d-.03))
 end
 panel(16,48,32,64,64.03);panel(64,96,32,64,64.03)
 panel(48,64,32,48,64.03);panel(48,64,48,64,63.05)
 for _,xx in ipairs({48,64})do box(xx-.2,0,xx+.2,64,24,63,cream)end
 -- Closed capsule roof. A raised rim follows the curved end caps.
 local ring={}
 for i=0,12 do local a=-math.pi/2+i*math.pi/12;ring[#ring+1]={96+16*math.cos(a),40+24*math.sin(a)}end
 for i=0,12 do local a=math.pi/2+i*math.pi/12;ring[#ring+1]={16+16*math.cos(a),40+24*math.sin(a)}end
 for i,a in ipairs(ring)do
  local b=ring[i%#ring+1]
  face({{56,50,40},{a[1],50,a[2]},{b[1],50,b[2]},{56,50,40}},dark)
  face({{56,48,40},{b[1],48,b[2]},{a[1],48,a[2]},{56,48,40}},cream,.7)
  face({{a[1],50,a[2]},{b[1],50,b[2]},{b[1],48,b[2]},{a[1],48,a[2]}},cream)
 end
 -- The original pale longitudinal ribs and crossbars are actual solids.
 for _,xx in ipairs({16,40,64,88})do box(xx,48,xx+6,64,54,17,cream)end
 for _,zz in ipairs({20,36,52})do
  local edge=16-16*math.sqrt(1-(math.max(math.abs(zz-40),math.abs(zz+3-40))/24)^2)
  box(edge,50,48,zz+3,52,zz,cream);box(70,50,112-edge,zz+3,52,zz,cream)
 end
 box(48,50,64,48,52,17,cream)
 face({{48,52.03,17},{64,52.03,17},{64,52.03,48},{48,52.03,48}},uv(48.05,1.05,63.95,43.95))
 -- Side/rear window glass continues the native two facade window motif.
 for _,right in ipairs({false,true})do
  local cx,sign=right and 96 or 16,right and 1 or -1
  for i=5,6 do
   local a,b=-math.pi/2+i*math.pi/12,-math.pi/2+(i+1)*math.pi/12
   local ax,az=cx+sign*14.08*math.cos(a),41+23.08*math.sin(a)
   local bx,bz=cx+sign*14.08*math.cos(b),41+23.08*math.sin(b)
   face({{ax,31,az},{bx,31,bz},{bx,23,bz},{ax,23,az}},uv(27+(i-5)*5,40,32+(i-5)*5,47))
  end
 end
 for _,xx in ipairs({27,75})do face({{xx+10,31,17.95},{xx,31,17.95},{xx,23,17.95},{xx+10,23,17.95}},uv(27,40,37,46))end
 -- Foreground sign moves onto its blocked interaction cells; its projected
 -- lower row becomes original ground, with no low post on walkable row 4.
 box(70,0,72,64.04,18,62,dark);box(90,0,92,64.04,18,62,dark)
 local sign={{68,28},{92,28},{94,25},{94,13},{92,10},{68,10},{66,13},{66,25}}
 local function signUV(q)return {(W+q[1])/(W*2+4),(56+(28-q[2])*12/18)/D}end
 for i,a in ipairs(sign)do
  local b=sign[i%#sign+1];local center={80,19}
  face({{80,19,64.08},{a[1],a[2],64.08},{b[1],b[2],64.08},{80,19,64.08}},
   {signUV(center),signUV(a),signUV(b),signUV(center)})
  face({{80,19,61},{b[1],b[2],61},{a[1],a[2],61},{80,19,61}},cream,.8)
  face({{a[1],a[2],61},{b[1],b[2],61},{b[1],b[2],64.08},{a[1],a[2],64.08}},cream,.9)
 end
end
return M
