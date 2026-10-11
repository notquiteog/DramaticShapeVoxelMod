-- Cosmetic Kanto First Person movement, adapted with the author's permission.
-- Only camera offsets are returned: never write player, collision or input state.
local V=...
local S=V.require('ModSetting')
local M={}
M.jump=S.new('kfpJump','JUMP FEEL',{'off','subtle','big'},{'OFF','SUBTLE','BIG'})
M.bob=S.new('kfpHeadBob','HEAD BOB',{false,true},{'OFF','ON'})
M.door=S.new('kfpDoorstep','DOORSTEP',{false,true},{'OFF','ON'})
M.settings={M.jump,M.bob,M.door}
local previous,walked,envelope,lastTime,riseAt,landAt,doorAt=nil,0,0,nil,nil,nil,nil
local function finite(v)return type(v)=='number' and v==v and math.abs(v)<1e8 end
function M.reset()
 previous,walked,envelope,lastTime,riseAt,landAt,doorAt=nil,0,0,nil,nil,nil,nil
end
-- t is the renderer's monotonic clock; a map identity catches same-coordinate
-- door warps. Lift is supplied by each edition's existing posed-player adapter.
function M.sample(me,map,yaw,t)
 if not me or not finite(me.px)or not finite(me.py)or not finite(t)then M.reset();return 0,0,0 end
 local dt=lastTime and math.max(0,math.min(.1,t-lastTime))or 0
 local lift=finite(me.lift)and math.max(0,me.lift)or 0
 local step=0
 if previous then
  local dx,dz=me.px-previous.x,me.py-previous.z
  step=math.sqrt(dx*dx+dz*dz)
  if map~=previous.map or step>24 then
   step=0;walked=0;envelope=0;riseAt=nil;landAt=nil
   doorAt=M.door:get()and t or nil
  else
   if lift>0 and previous.lift<=0 then riseAt=t end
   if lift<=0 and previous.lift>0 then landAt=t end
  end
 end
 if not M.door:get()then doorAt=nil end
 previous={x=me.px,z=me.py,lift=lift,map=map};lastTime=t
 walked=(walked+step)%(math.pi*2/.22)
 envelope=envelope+((step>.01 and 1 or 0)-envelope)*(1-math.exp(-6*dt))
 local scale=({off=0,subtle=.6,big=1.6})[M.jump:get()]or 0
 local y=lift*scale
 if riseAt and lift>0 and t-riseAt<.1 then y=y-1.6*(1-(t-riseAt)/.1)^2*scale end
 if landAt and t-landAt<.26 then
  local a=(t-landAt)/.26;y=y-2.4*(1-a)^2*math.cos(a*math.pi*4)*scale
 end
 if M.bob:get()and lift==0 then y=y-math.sin(walked*.22)*1.5*envelope end
 local push=0
 if doorAt and t-doorAt<.30 then
  local k=1-(t-doorAt)/.30
  y=y-2.2*k*math.sin(k*math.pi);push=5*math.sin(k*math.pi)
 end
 yaw=finite(yaw)and yaw or 0
 return math.sin(yaw)*push,y,math.cos(yaw)*push
end
return M
