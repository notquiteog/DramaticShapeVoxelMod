local Rig=assert(loadfile('lib/Gen3CameraRig.lua'))()
local near=function(a,b)return math.abs(a-b)<1e-7 end
for _,pitch in ipairs({-math.rad(50),0,math.rad(10),math.rad(70)})do
 for _,yaw in ipairs({0,math.pi/2,math.pi,math.pi*1.5})do
  for _,zoom in ipairs({.45,1,2.4})do
   local c={level=7,pitch=pitch,yaw=yaw,boomZoom=zoom}
   local rig=Rig.place(c,100,200,32,14,6)
   local dx,dy,dz=rig.focus[1]-rig.eye[1],rig.focus[2]-rig.eye[2],rig.focus[3]-rig.eye[3]
   assert(near(math.atan2(-dy,math.sqrt(dx*dx+dz*dz)),pitch),'pitch changed with zoom')
   assert(rig.eye[2]>=37-1e-7,'orbit entered floor')
   local moved=Rig.place(c,116,184,48,14,6)
   for _,key in ipairs({'eye','focus'})do
    assert(near(moved[key][1]-rig[key][1],16)and near(moved[key][2]-rig[key][2],16)and near(moved[key][3]-rig[key][3],-16),'camera detached from actor/map coordinates')
   end
  end
 end
end
local first=Rig.place({level=6,yaw=0,pitch=0},100,200,32,14,6)
assert(first.eye[1]==100 and first.eye[2]==52 and first.eye[3]==200 and first.focus[2]==52)
assert(first.curve==0 and first.focus[3]==176,'first-person feet/eye anchor changed')
local camera={level=7,yaw=0,pitch=0,boomZoom=1,cameraDelta=.01}
local blocked=Rig.place(camera,100,200,0,14,0,function(x,y,z)return z>230 end)
assert(blocked.eye[3]==248,'boom lost minimum third-person framing')
assert(Rig.showsPlayer(camera),'collision unexpectedly hid third-person actor')
assert(Rig.showsPlayer({level=7,boomClearance=60})and Rig.showsPlayer({level=3}))
assert(not Rig.showsPlayer({level=6}))
local recovering=Rig.place(camera,100,200,0,14,0,function()return false end)
assert(recovering.eye[3]>blocked.eye[3]and recovering.eye[3]-blocked.eye[3]<=1.51,'boom snapped on clearance')
local function layout(block)return{width=4,height=4,collAt=function(_,x,y)return block and 1 or 0 end}end
local primary={midLayout=layout(false)};local neighbor={midLayout=layout(true)}
local collision={behaviorOn=function()return 'land'end,isSurfable=function(b)return b=='water'end}
local solid=Rig.obstacles({world={{def=neighbor,ox=4,oy=0}}},primary,function()return 8 end,collision,false)
assert(not solid(8,20,8)and solid(8,10,8),'ground clearance wrong')
assert(solid(70,20,8)and not solid(70,100,8),'connected obstruction coordinates wrong')
assert(solid(-16,100,8),'void was not closed')
collision.behaviorOn=function()return 'water'end
solid=Rig.obstacles({world={{def=neighbor,ox=4,oy=0}}},primary,function()return 0 end,collision,false)
assert(not solid(70,20,8),'water stopped camera like a wall')
print('PASS Gen3 orbit pitch/zoom/ground, movement/elevation follow and first-person anchor')
