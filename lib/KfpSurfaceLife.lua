-- KFP grass seed motes, adapted to native collision and rendered ground.
-- One bounded mesh; no gameplay writes, global random calls or scene ownership.
local V=...
local M={MAX_PARTICLES=48,MAX_VERTICES=48*24}
M.setting=V.require('ModSetting').new('kfpGrassSeeds','GRASS SEEDS',{'off','subtle','lively'},{'OFF','SUBTLE','LIVELY'})
M.rustle=V.require('ModSetting').new('kfpGrassRustle','GRASS RUSTLE',{'off','subtle'},{'OFF','SUBTLE'})
M.settings={M.setting,M.rustle}
local function hash(n,k)return((n*7919+k*104729)%65521)/65521 end
function M.new()
 local self={particles={},serial=0,distance=0}
 function self:update(f,t,level)
  local previous=self.previous
  self.previous={map=f.map,x=f.x,z=f.z,t=t}
  if level=='off'or not previous or previous.map~=f.map or t-previous.t>.3 or t<previous.t then
   self.particles={};self.distance=0;return
  end
  local keep={};for _,p in ipairs(self.particles)do if t-p.born<p.life then keep[#keep+1]=p end end;self.particles=keep
  local dx,dz=f.x-previous.x,f.z-previous.z;local distance=math.sqrt(dx*dx+dz*dz)
  -- Warp, door, surf and ledge movement must never throw grass out of thin air.
  if distance>12 or not f.grass or f.airborne or not f.height then self.distance=0;return end
  if distance<.02 then return end
  self.distance=self.distance+distance
  local stride=level=='lively'and 2.5 or 5
  while self.distance>=stride and #self.particles<M.MAX_PARTICLES do
   self.distance=self.distance-stride;self.serial=self.serial+1
   local n=self.serial;local a=hash(n,1)*math.pi*2
   -- Original donor disc art, scaled below native actors' knees; confined to the current cell.
   local x=f.x+(hash(n,2)-.5)*8;local z=f.z+(hash(n,3)-.5)*8
   x=math.max(f.minX or x,math.min(f.maxX or x,x));z=math.max(f.minZ or z,math.min(f.maxZ or z,z))
   self.particles[#self.particles+1]={x=x,z=z,y=f.height+.8+hash(n,4)*2,
    vx=math.cos(a)*2,vz=math.sin(a)*2,vy=3+hash(n,5)*3,
    born=t,life=.5+hash(n,6)*.4,size=.4+hash(n,7)*.4}
  end
  self.distance=math.min(self.distance,stride)
 end
 return self
end
function M.facts(state)
 local map=state.map;local p=state.player or{};local x=(p.px or p.x or 0)+8;local z=(p.py or p.y or 0)+8
 local cx,cz=math.floor(x/16),math.floor(z/16)
 local f={map=map,x=x,z=z,minX=cx*16+2,maxX=cx*16+14,minZ=cz*16+2,maxZ=cz*16+14}
 local jump=type(p.jumpSpriteY)=='function'and p.jumpSpriteY()or p.jumpSpriteY
 f.airborne=(tonumber(jump)or 0)<0 or (tonumber(p.spriteYOffset)or 0)<0 or p.hopping==true
 if map.nativeGeneration==3 then
  local C=require('src.core.game3.collision')
  f.grass=C.isGrass(cx,cz)and C.isWalkable(cx,cz)and not C.isWater(cx,cz)
  if f.grass then f.height=V.require('Gen3Elevation').at(map.nativeDef,x,z)end
 elseif type(map.isGrassCell)=='function'and type(map.isWalkableCell)=='function'then
  f.grass=map:inBounds(cx,cz)and map:isGrassCell(cx,cz)and map:isWalkableCell(cx,cz)and not map:isWaterCell(cx,cz)
  if f.grass then f.height=V.require('VoxelScene').groundAt(map,cx,cz,x-8,z-8)end
 end
 return f
end
function M.vertices(particles,t)
 local out={}
 for _,p in ipairs(particles)do
  local age=t-p.born
  if age>=0 and age<p.life then
   local x,z,y=p.x+p.vx*age,p.z+p.vz*age,p.y+p.vy*age-7*age*age
   local r=p.size*.5*math.min(1,(p.life-age)*6)
   -- Crossed upright cards remain visible at every yaw without leaning.
   for _,axis in ipairs({{1,0},{0,1}})do
    local a,b=axis[1]*r,axis[2]*r
    local q={{x-a,y-r,z-b,0,1,1},{x+a,y-r,z+b,1,1,1},{x+a,y+r,z+b,1,0,1},{x-a,y+r,z-b,0,0,1}}
    for _,i in ipairs({1,2,3,1,3,4,3,2,1,4,3,1})do out[#out+1]=q[i]end
   end
  end
 end
 return out
end
local model=M.new();local mesh,texture,lastTick
local function makeTexture()
 local data=love.image.newImageData(8,8)
 for y=0,7 do for x=0,7 do
  local d=math.sqrt(((x-3.5)/3.5)^2+((y-3.5)/3.5)^2)
  local k=d<.45 and 1 or d<.75 and .72 or .42
  data:setPixel(x,y,.55*k,.78*k,.35*k,d<.95 and 1 or 0)
 end end
 local tx=love.graphics.newImage(data);tx:setFilter('nearest','nearest');data:release();return tx
end
function M.draw(state)
 local level=M.setting:get()
 if level=='off'or not(state and state.map and state.player)then
  if model.previous then model=M.new();lastTick=nil end
  M.lastCount=0;return
 end
 local t=love.timer.getTime();local f=M.facts(state);model:update(f,t,level)
 M.lastCount=#model.particles
 if M.lastCount==0 then lastTick=nil;return end
 local tick=math.floor(t*30)
 local R=V.require('Voxel3D')
 if tick~=lastTick then
  local verts=M.vertices(model.particles,t)
  if #verts==0 then lastTick=nil;return end
  mesh=mesh or love.graphics.newMesh(R.FORMAT,M.MAX_VERTICES,'triangles','dynamic')
  texture=texture or makeTexture()
  mesh:setVertices(verts,1,#verts);mesh:setDrawRange(1,#verts);lastTick=tick
 end
 R.draw(mesh,texture)
end
local rustleMesh,rustleMap,rustleEpoch,rustleParticles
function M.drawRustles(state)
 if M.rustle:get()=='off'or not state or not state.map or not state.player then return end
 local H=V.require('KantoHabitat');local map=state.map
 if not H.profile(map)then return end
 local t=love.timer.getTime();local epoch=math.floor(t/3)
 if rustleMap~=map then rustleMap=map;rustleEpoch=nil;rustleParticles={}end
 if rustleEpoch~=epoch then
  rustleEpoch=epoch;rustleParticles={}
  local px,pz=(state.player.px or 0)+8,(state.player.py or 0)+8
  local habitat=H.scan(map,not V.require('NativeHabitat').native(map)and V.require('Structures').forMap(map)or nil,px,pz)
  local eligible={}
  for _,a in ipairs(habitat.green or{})do
   local d=(a.x-px)^2+(a.z-pz)^2
   if d>40*40 and d<112*112 then
    local f=M.facts({map=map,player={px=a.x-8,py=a.z-8}})
    if f.grass and f.height then eligible[#eligible+1]=f end
   end
  end
  if #eligible>0 then
   local a=eligible[epoch%#eligible+1]
   for i=1,5 do
    local angle=hash(epoch,i)*math.pi*2
    rustleParticles[#rustleParticles+1]={x=a.x+math.cos(angle)*2,z=a.z+math.sin(angle)*2,y=a.height+.7,
     vx=math.cos(angle)*2,vz=math.sin(angle)*2,vy=4+hash(epoch,i+7)*2,born=t,life=.65,size=.55}
   end
  end
 end
 local verts=M.vertices(rustleParticles or{},t);M.lastRustleCount=#verts/24
 if #verts==0 then return end
 local R=V.require('Voxel3D');rustleMesh=rustleMesh or love.graphics.newMesh(R.FORMAT,5*24,'triangles','dynamic')
 rustleMesh:setVertices(verts,1,#verts);rustleMesh:setDrawRange(1,#verts);texture=texture or makeTexture();R.draw(rustleMesh,texture)
end
function M.invalidate()
 if mesh then mesh:release()end;if texture then texture:release()end
 if rustleMesh then rustleMesh:release()end
 rustleMesh,rustleMap,rustleEpoch,rustleParticles=nil,nil,nil,nil
 mesh,texture,lastTick=nil,nil,nil;model=M.new();M.lastCount=0
end
return M
