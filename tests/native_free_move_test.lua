local F=dofile('lib/NativeFreeMove.lua')
local p={cellX=2,cellY=2,px=32,py=32,moving=false,stepFrames=16}
local map={};local arrivals=0
local function attempt(dir)
 local dx=dir=='right'and 1 or dir=='left'and -1 or 0
 local dz=dir=='down'and 1 or dir=='up'and -1 or 0
 p.targetX,p.targetY=p.cellX+dx,p.cellY+dz;p.moving=true;p.progress=0
 return 'ordinary','step'
end
local function tick()
 if p.moving then
  p.progress=p.progress+1
  if p.progress>=p.stepFrames then
   p.cellX,p.cellY=p.targetX,p.targetY;p.px,p.py=p.cellX*16,p.cellY*16;p.moving=false;arrivals=arrivals+1
  end
 end
end
local function move(x,z,blocked)
 tick();local b=assert(F.sync(p,map));F.advance(b,p,x,z,1,blocked or function()end,function(dir)
  local dx=dir=='right'and 1 or dir=='left'and -1 or 0
  local dz=dir=='down'and 1 or dir=='up'and -1 or 0
  if blocked and blocked(p.cellX+dx,p.cellY+dz)then return nil,'blocked'end
  return attempt(dir)
 end)
 return b
end
for _=1,6 do move(.6,.8)end
assert(p.px>35 and p.px<36 and p.py>36 and p.py<37,'not simultaneous subcell motion')
assert(arrivals==0,'arrival fired inside starting cell')
local px,py=p.px,p.py;move(0,0);assert(p.px==px and p.py==py,'release snapped to grid')
for _=1,20 do move(.6,.8)end
tick();F.sync(p,map)
assert(arrivals==2 and p.cellX==3 and p.cellY==3,'native boundaries not finalized exactly once')
assert(p.px~=p.cellX*16 and p.py~=p.cellY*16,'boundary snapped fractional pose')
F.drop(p,true);assert(p.px==p.cellX*16 and p.py==p.cellY*16,'GRID handback did not align')
p.cellX,p.cellY,p.px,p.py=2,2,32,32
for _=1,20 do move(.6,.8,function(x)return x>=3 and 'tile'or nil end)end
assert(p.px<=48-F.RADIUS-8 and p.py>40,'wall did not stop one axis while sliding along the other')
-- Engine-authored warp/script position wins over the adapter.
p.px,p.py,p.cellX,p.cellY=160,160,10,10
local b=F.sync(p,map);assert(b.x==168 and b.z==168,'external relocation undone')
F.drop(p,false);p.cellX,p.cellY,p.px,p.py=2,2,34.49,32
b=F.sync(p,map);F.advance(b,p,1,0,1,function()return'tile'end,function()
 p.moving=true;p.jumping=true;p.stepFrames=32;p.progress=0;p.targetX=4;p.targetY=2
 return 'special','ledge'
end)
assert(not F.body(p)and p.progress==0 and p.stepFrames==32,'native ledge timing accelerated')
-- Diagonal shoulder probes must preserve both one-way approaches.
local calls=0
assert(F.probe({cellX=1,cellY=1},2,2,function(ax,az,bx,bz)
 calls=calls+1;return not(ax==1 and az==2)
end)=='tile'and calls==4,'diagonal cut through one-way boundary')
print('PASS continuous diagonal/release/slide, native arrival count, GRID handback, warp adoption and untouched ledge timing')
-- Public Gen3 input-gate proof: no fractional writes while original update
-- returns before reading the d-pad (scripts, battle, menu or warp).
package.loaded['src.core.game3.map']={current='test'}
package.loaded['src.core.game3.collision']={canEnter=function()return true end}
p={cellX=2,cellY=2,px=32,py=32,moving=false,ordinaryStepFrames=function()return 16 end,canDash=function()return false end}
local input={isDown=function(_,k)return k=='right'end,wasPressed=function()return false end}
local n=0;F.gen3({},input,p,function()n=n+1 end,1,0)
assert(n==1 and p.px==32 and not F.body(p),'free movement bypassed native input gate')
F.gen3({},input,p,function(_,pad)n=n+1;assert(not pad:isDown('right'))end,.6,.8)
assert(n==2 and p.px>32 and p.py>32 and input:isDown('right'),'gated free intent lost or input mutated')
print('PASS native Gen3 input gates and original input isolation')

local lockedX,lockedZ=p.px,p.py
F.gen3({},input,p,function()end,1,0)
assert(p.px==lockedX and p.py==lockedZ and F.body(p),'menu snapped/dropped fractional pose')
local ix,iz=F.intent({stickAxis={x=.6,y=-.8},isDown=function()return false end})
assert(math.abs(ix-.6)<.001 and math.abs(iz-.8)<.001,'analog magnitude lost')
ix,iz=F.intent({stickAxis={x=.1,y=0},isDown=function(_,key)return key=='left'or key=='up'end})
assert(ix<-.7 and iz>.7 and math.abs(ix*ix+iz*iz-1)<.001,'deadzone/digital diagonal normalization')
print('PASS fractional native menu pause and current-game analog/digital intent')
