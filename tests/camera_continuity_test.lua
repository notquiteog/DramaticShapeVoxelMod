local state={level=7,isThirdPerson=function(n)return n==7 end}
local function third()
 return assert(loadfile('lib/ThirdPerson.lua'))({require=function(n)assert(n=='VoxelState');return state end})
end
local near=function(a,b)return math.abs(a-b)<1e-7 end
-- Looking upward must not send the eye underneath the native support plane.
-- This is a floor bound, not obstruction/collision testing or player movement.
for _,ground in ipairs({0,32,128})do
 for _,pitch in ipairs({-math.rad(50),0,math.rad(70)})do
  local t=third();t.out=1
  local lx,ly,lz=0,-math.sin(pitch),math.cos(pitch)
  local pivot={100,ground+12,200}
  local eye,aim=t.place(pivot,lx,ly,lz,{100,pivot[2]+ly*24,200+lz*24},nil,ground)
  assert(eye[2]>=ground+5-1e-7,'Gen1/2 upward orbit entered supporting floor')
  local dx,dy,dz=aim[1]-eye[1],aim[2]-eye[2],aim[3]-eye[3]
  assert(near(math.atan2(-dy,math.sqrt(dx*dx+dz*dz)),pitch),'floor bound changed look pitch')
 end
end
local values={}
for _,fps in ipairs({30,60,165})do
 local t=third();t.zoomGoal=2
 for _=1,fps do t.update(1/fps,1)end
 values[#values+1]=t.zoom
end
assert(near(values[1],values[2])and near(values[2],values[3]),'zoom smoothing depends on frame rate')
print('PASS Gen1/2 support-plane clearance, pitch preservation and frame-rate-independent zoom')
