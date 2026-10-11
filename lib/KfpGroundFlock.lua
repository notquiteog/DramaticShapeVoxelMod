-- KFP pecking / flushing flock, placed on real dry native ground. Decorative
-- only: never creates a world entity, encounter, collision, or partner dependency.
local V=...;local M={}
M.setting=V.require('ModSetting').new('kfpGroundBirds','GROUND BIRDS',{false,true},{'OFF','ON'})
M.settings={M.setting}
function M.find(surface,px,pz)
 local cx,cz=math.floor(px/16),math.floor(pz/16)
 -- Candidate offsets are stable until a flock has left, avoiding camera jitter.
 local offsets={{0,-5},{5,0},{0,5},{-5,0},{4,-4},{-4,4}}
 for radius=3,6 do for z=-radius,radius do for x=-radius,radius do
  if math.max(math.abs(x),math.abs(z))==radius then offsets[#offsets+1]={x,z}end
 end end end
 for _,offset in ipairs(offsets)do
  local x,z=cx+offset[1],cz+offset[2];local anchor=surface(x,z)
  if anchor and anchor.walk and not anchor.water then
   local clear=true
   for dz=-1,1 do for dx=-1,1 do
    local c=surface(x+dx,z+dz)
    if not c or not c.walk or c.water or math.abs(c.y-anchor.y)>.5 then clear=false end
   end end
   -- Keep decorative flocks on the player's accessible side of a wall/cliff.
   for step=1,6 do
    local q=surface(math.floor(cx+offset[1]*step/6),math.floor(cz+offset[2]*step/6))
    if not q or not q.walk or q.water or math.abs(q.y-anchor.y)>.5 then clear=false end
   end
   if clear then
    return{{x=x*16+3,z=z*16+4,y=anchor.y},{x=x*16+12,z=z*16+8,y=anchor.y},{x=x*16+7,z=z*16+13,y=anchor.y}}
   end
  end
 end
end
function M.new()
 local self={}
 function self:update(map,surface,px,pz,t,enabled)
  if self.map~=map or not enabled or(self.time and t<self.time)then self.map=map;self.birds=nil;self.flushed=nil;self.nextAt=t end
  self.time=t;if not enabled then return{}end
  if not self.birds and t>=(self.nextAt or 0)then self.birds=M.find(surface,px,pz);self.nextAt=t+8 end
  if not self.birds then return{}end
  if not self.flushed then
   for _,b in ipairs(self.birds)do
    local c=surface(math.floor(b.x/16),math.floor(b.z/16))
    if not c or not c.walk or c.water or math.abs(c.y-b.y)>.5 then self.birds=nil;return{}end
    if(b.x-px)^2+(b.z-pz)^2<32*32 then self.flushed=t end
   end
  end
  local age=self.flushed and t-self.flushed
  if age and age>3 then self.birds=nil;self.flushed=nil;self.nextAt=t+8;return{}end
  local out={}
  for i,b in ipairs(self.birds)do
   local x,z,y=b.x,b.z,b.y
   if age then
    -- Source flock flushes away and climbs; use elapsed time, not frame count.
    if not b.angle then b.angle=math.atan2(b.z-pz,b.x-px)+(i-2)*.25 end
    x=x+math.cos(b.angle)*age*42;z=z+math.sin(b.angle)*age*42;y=y+age*28+age*age*3
   else y=y+math.max(0,math.sin(t*(1.4+i*.35)+i*2))*.35 end
   out[#out+1]={x=x,y=y,z=z,frame=age and math.floor(t*7)%2==1 and 'b'or'a'}
  end
  return out
 end
 return self
end
local model=M.new();local mesh
function M.draw(state)
 if not state or not state.map or not state.player then return end
 local map=state.map;local K=V.require('KantoFirstPerson');local enabled=M.setting:get()and K.outdoor(map)
 if not enabled then model=M.new();M.lastCount=0;return end
 local t=love.timer.getTime();local p=state.player
 local game=K.currentGame();if not game then return end
 local ground=V.require('KfpAmbientDetails').surface(map)
 local world=game.world or game.overworld
 local Objects=map.nativeGeneration==3 and require('src.core.game3.objects')
 local function surface(x,z)
  if Objects and Objects.at(x,z)then return end
  if not Objects and world and world.npcAtCell and world:npcAtCell(x,z)then return end
  return ground(x,z)
 end
 local birds=model:update(map.nativeDef or map.def or map,surface,(p.px or 0)+8,(p.py or 0)+8,t,enabled)
 M.lastBirds=birds;M.lastCount=#birds;if #birds==0 then return end
 local R=V.require('Voxel3D');local camera=R.camera;local yaw=0
 if camera and camera.eye and camera.focus then yaw=math.atan2(camera.focus[1]-camera.eye[1],camera.focus[3]-camera.eye[3])end
 local dx,dz=math.cos(yaw)*4,-math.sin(yaw)*4
 mesh=mesh or love.graphics.newMesh(R.FORMAT,12,'triangles','dynamic')
 for _,b in ipairs(birds)do
  local Art=V.require('KfpBirdArt');local ok,image=pcall(Art.image,game,'pidgey',b.frame)
  if not ok then M.error=tostring(image);return end
  M.error=nil;local base=b.y-Art.footing('pidgey',b.frame)*8
  local q={{b.x-dx,base,b.z-dz,0,1,1},{b.x+dx,base,b.z+dz,1,1,1},{b.x+dx,base+8,b.z+dz,1,0,1},{b.x-dx,base+8,b.z-dz,0,0,1}}
  local v={};for _,i in ipairs({1,2,3,1,3,4,3,2,1,4,3,1})do v[#v+1]=q[i]end
  mesh:setVertices(v);R.draw(mesh,image)
 end
end
function M.invalidate()if mesh then mesh:release()end;mesh=nil;model=M.new();M.lastCount=0 end
return M
