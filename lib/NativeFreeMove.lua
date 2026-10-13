-- Continuous position, with native cardinal transactions at cell boundaries.
-- This module never fires arrivals, warps, encounters or step counters itself.
local M={RADIUS=5.5}
local bodies=setmetatable({},{__mode='k'})
local EPS=.01
function M.direction(x,z)
 if x*x+z*z<.0001 then return nil end
 if math.abs(x)>math.abs(z)then return x>0 and 'right'or'left'end
 return z>0 and 'down'or'up'
end
-- Input belongs to the current native game. Gen3 must never require the
-- Gen1 Game singleton merely to read camera-space stick/d-pad intent.
function M.intent(input)
 local axes=input and input.stickAxis
 if axes then
  local x,y=axes.x or 0,axes.y or 0;local mag=math.sqrt(x*x+y*y)
  if mag>.18 then local scale=math.min(1,(mag-.18)/.82)/mag;return x*scale,-y*scale end
 end
 if not input then return 0,0 end
 local x=(input:isDown('right')and 1 or 0)-(input:isDown('left')and 1 or 0)
 local z=(input:isDown('up')and 1 or 0)-(input:isDown('down')and 1 or 0)
 local mag=math.sqrt(x*x+z*z)
 if mag==0 then return 0,0 end
 return x/mag,z/mag
end
function M.body(p)return bodies[p]end
function M.drop(p,snap)
 local b=bodies[p]
 if b and snap and not p.moving and p.px==b.lastX and p.py==b.lastZ then
  p.px,p.py=p.cellX*16,p.cellY*16
 end
 bodies[p]=nil
end
local function write(b,p)
 p.px,p.py=b.x-8,b.z-8;b.lastX,b.lastZ=p.px,p.py
end
function M.sync(p,map)
 local b=bodies[p]
 if b and (b.map~=map or b.player~=p)then M.drop(p,false);b=nil end
 if b and b.pending then
  if p.moving then return nil end
  local q=b.pending;b.pending=nil
  if p.cellX~=q.x or p.cellY~=q.y or p.px~=p.cellX*16 or p.py~=p.cellY*16 then
   M.drop(p,false);b=nil
  else write(b,p)end
 elseif b and (p.px~=b.lastX or p.py~=b.lastZ)then
  M.drop(p,false);b=nil
 end
 if not b then
  if p.moving then return nil end
  b={player=p,map=map,x=p.px+8,z=p.py+8,lastX=p.px,lastZ=p.py,clock=0,cooldown=0}
  bodies[p]=b
 end
 return b
end
function M.phase(p)
 local b=bodies[p]
 if b and b.moving then return math.floor(b.clock/5)%2 end
end
-- attempt(dir) returns 'ordinary' only after the native walker validated and
-- began a one-cell move; any special move is left entirely to that walker.
function M.advance(b,p,vx,vz,speed,blocked,attempt)
 b.moving=false;b.cooldown=math.max(0,(b.cooldown or 0)-1)
 if vx*vx+vz*vz<.0001 then return end
 local r=M.RADIUS;local hit,hitDir;local nativeResult
 for axis=1,2 do
  local delta=(axis==1 and vx or vz)*speed
  if delta~=0 then
   local old=axis==1 and b.x or b.z
   local other=axis==1 and b.z or b.x
   local nextValue=old+delta
   local edge=math.floor((nextValue+(delta>0 and r or -r))/16)
   local why
   for orth=math.floor((other-r+EPS)/16),math.floor((other+r-EPS)/16)do
    why=blocked(axis==1 and edge or orth,axis==1 and orth or edge)
    if why then break end
   end
   local dir=axis==1 and(delta>0 and'right'or'left')or(delta>0 and'down'or'up')
   if why then
    nextValue=delta>0 and math.min(nextValue,edge*16-r-EPS)or math.max(nextValue,(edge+1)*16+r+EPS)
    if math.abs(delta)>.4*speed then hit,hitDir=why,dir end
   end
   local nx,nz=axis==1 and nextValue or b.x,axis==2 and nextValue or b.z
   if math.floor(nx/16)~=p.cellX or math.floor(nz/16)~=p.cellY then
    local result,native=attempt(dir);nativeResult=native
    if result=='ordinary'then
     b.clock=b.clock+math.abs(nextValue-old);b.moving=true;b.x,b.z=nx,nz
     b.pending={x=p.targetX,y=p.targetY}
     -- The next native tick performs its real finalization and all arrivals.
     p.progress=math.max(0,(p.stepFrames or 16)-1)
     write(b,p);return nativeResult
    elseif result=='special'then M.drop(p,false);return nativeResult
    else break end
   end
   b.clock=b.clock+math.abs(nextValue-old)
   b.moving=b.moving or math.abs(nextValue-old)>.0001
   b.x,b.z=nx,nz
  end
 end
 write(b,p)
 if hit and b.cooldown==0 then
  local dx=hitDir=='right'and 1 or hitDir=='left'and -1 or 0
  local dz=hitDir=='down'and 1 or hitDir=='up'and -1 or 0
  -- A diagonal shoulder brushing a wall must not start a valid cardinal
  -- step. Only ask native blocked-push verbs about a truly blocked neighbour.
  if blocked(p.cellX+dx,p.cellY+dz)then
   b.cooldown=8
   local result,native=attempt(hitDir);nativeResult=native
   if result=='special'then M.drop(p,false)
   elseif result=='ordinary'then
    -- A native rule/hook admitted a tile the conservative body probe refused.
    -- Hand that complete transaction to the engine; never cancel its effects.
    M.drop(p,false)
   end
  end
 end
 return nativeResult
end
-- Check both cardinal approaches to a diagonal body cell, preserving one-way
-- tile/elevation permissions rather than cutting a blocked corner.
function M.probe(p,x,z,edge)
 if x==p.cellX and z==p.cellY then return nil end
 local function check(ax,az,bx,bz)
  local ok,why=edge(ax,az,bx,bz,M.direction(bx-ax,bz-az))
  return not ok and(why or'tile')or nil
 end
 if x~=p.cellX and z~=p.cellY then
  return check(p.cellX,p.cellY,x,p.cellY)or check(x,p.cellY,x,z)
   or check(p.cellX,p.cellY,p.cellX,z)or check(p.cellX,z,x,z)
 end
 return check(p.cellX,p.cellY,x,z)
end
function M.gen3(game,input,p,inner,vx,vz)
 local Map=require('src.core.game3.map');local Collision=require('src.core.game3.collision')
 -- Bikes, actions and hops retain native controls/timing. A pending ordinary
 -- boundary completion is the only native movement this adapter owns.
 local b=bodies[p]
 if p.biking or p.action or p.boulderPush or p.jumping or p.surfHopping or(p.moving and not(b and b.pending))then
  M.drop(p,false);return false
 end
 local polled=false
 local proxy=setmetatable({},{__index=input})
 for _,method in ipairs({'isDown','wasPressed'})do
  if input[method]then proxy[method]=function(_,key)
   if key=='up'or key=='down'or key=='left'or key=='right'then polled=true;return false end
   return input[method](input,key)
  end end
 end
 inner(game,proxy)
 -- Original update reached its real D-pad reads only after script, warp,
 -- menu, trainer-sight and step-event gates. Never restate/bypass those gates.
 if not polled or p.moving or p.action or p.boulderPush then
  -- A menu pauses the fractional pose. Scripted/foreign movement owns its
  -- coordinates; map/position changes are reconciled on the next sync.
  if b then b.moving=false end
  if p.moving or p.action or p.boulderPush then M.drop(p,false)end
  return true
 end
 b=M.sync(p,Map.current);if not b then return true end
 local dir=M.direction(vx,vz)
 if dir then p.facing=dir;p.turnArmed=false end
 local run=input:isDown('b')and p.canDash()
 local frames=p.ordinaryStepFrames(run)
 local function blocked(x,z)
  return M.probe(p,x,z,function(ax,az,bx,bz,direction)
   return Collision.canEnter(game,bx,bz,{fromX=ax,fromY=az,dir=direction,
    surfing=p.surfing or p.underwater,elevation=p.currentElevation})
  end)
 end
 M.advance(b,p,vx,vz,16/math.max(1,frames),blocked,function(direction)
  local result=p.tryMove(direction,game,run)
  if result=='step'and p.moving and not p.jumping and not p.biking and not p.dismounting
   and math.abs(p.targetX-p.cellX)+math.abs(p.targetY-p.cellY)==1 then return 'ordinary',result end
  if result and result~='blocked'and result~='turned'then return 'special',result end
  return nil,result
 end)
 return true
end
return M
