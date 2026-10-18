local Cam=assert(loadfile('lib/BattleCam.lua'))({})
local Mat=assert(loadfile('lib/Mat4.lua'))()
local arena={mid={0,0},player={0,24},enemy={0,-24},cam='wide'}
assert(Cam.forLayout(arena,nil)==arena and Cam.forLayout(arena,'provider')==arena)
local framed=Cam.forLayout(arena,'gen2-native-pair')
assert(arena.cam=='wide'and framed.player==arena.player,'layout mutated native arena')
local rig=Cam.rig(framed,0,true)
local vp=Mat.mul(Mat.perspective(rig.fov,160/144,1,4096),Mat.lookAt(rig.eye,rig.focus,{0,1,0}))
local function project(x,y,z)
 local w=vp[13]*x+vp[14]*y+vp[15]*z+vp[16]
 return 80+80*(vp[1]*x+vp[2]*y+vp[3]*z+vp[4])/w,
  72-72*(vp[5]*x+vp[6]*y+vp[7]*z+vp[8])/w
end
for _,v in ipairs({{24,40,88,36},{-24,120,40,32}})do
 local x,y=project(0,0,v[1]);assert(math.abs(x-v[2])<.01 and math.abs(y-v[3])<.01,'pair feet overlap reserved native HUD region')
 local rx,rz=rig.eye[3]-v[1],-rig.eye[1];local len=math.sqrt(rx*rx+rz*rz);rx,rz=rx/len,rz/len
 local a=project(8*rx,0,v[1]+8*rz);local b=project(-8*rx,0,v[1]-8*rz)
 assert(math.abs(a-b-v[4])<.01,'native pair span escaped clear picture region')
end
print('PASS native-pair camera keeps source world scale and fits native HUD picture regions')

local gba=Cam.rig(Cam.forLayout(arena,'gen3-native-pair'),0,true)
vp=Mat.mul(Mat.perspective(gba.fov,240/160,1,4096),Mat.lookAt(gba.eye,gba.focus,{0,1,0}))
local function pixel(x,y,z)
 local w=vp[13]*x+vp[14]*y+vp[15]*z+vp[16]
 return 120+120*(vp[1]*x+vp[2]*y+vp[3]*z+vp[4])/w,
  80-80*(vp[5]*x+vp[6]*y+vp[7]*z+vp[8])/w
end
for _,p in ipairs({{-12,40,45,92},{12,40,100,104},{-12,-40,155,40},{12,-40,205,50}})do
 local x,y=pixel(p[1],0,p[2]);assert(math.abs(x-p[3])<1 and math.abs(y-p[4])<1,'GBA pair feet escaped clear native picture region')
 assert(y<112,'GBA command panel covered feet')
end
print('PASS GBA four source-scale feet fit native240x160 HUD regions')
