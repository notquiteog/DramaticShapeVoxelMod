-- Native free-camera inputs share Gen1 boom tuning and input direction.
local V=...
local T=V.require('ThirdPerson')
local Look=V.require('CameraLook')
local M={}
function M.new(camera)
 local state={zoom=1,goal=1}
 local mouseAt,pointerSeen
 function state:step(n)
  if camera.level~=7 or not n or n==0 then return false end
  self.goal=math.max(T.ZOOM_MIN,math.min(T.ZOOM_MAX,self.goal*T.ZOOM_STEP^n))
  return true
 end
 function state:scale(factor)
  if camera.level~=7 or not factor or factor<=0 then return false end
  self.goal=math.max(T.ZOOM_MIN,math.min(T.ZOOM_MAX,self.goal*factor))
  return true
 end
 function state:pointer()pointerSeen=true end
 function state:update(dt,looking,mouse,targetAngle)
  if targetAngle then
   if self.angle==nil or not self.level or self.level==0 or self.level>=6 or camera.level==0 or camera.level>=6 then
    self.angle,self.angleTarget,self.angleTime=targetAngle,targetAngle,1
   else
    if self.angleTarget~=targetAngle then
     self.angleFrom,self.angleTarget,self.angleTime=self.angle,targetAngle,0
    end
    self.angleTime=math.min(1,self.angleTime+math.max(0,dt or 0)/.25)
    local a=self.angleTime;local e=a*a*(3-2*a)
    self.angle=(self.angleFrom or targetAngle)+(targetAngle-(self.angleFrom or targetAngle))*e
   end
   camera.angle=self.angle
  end
  -- The 1ST/3RD pair is one rig with a sliding boom, as in Gen 1/2.
  -- Entering from a static view starts at its chosen framing; changing
  -- maps/dialogue never restarts this interpolation.
  local target=camera.level==7 and 1 or 0
  if self.level~=6 and self.level~=7 or camera.level<6 then self.extension=target
  else
   local step=math.max(0,dt or 0)/(T.BOOM_TIME or .35)
   self.extension=self.extension<target and math.min(target,self.extension+step)
    or math.max(target,self.extension-step)
  end
  self.level=camera.level
  local e=self.extension
  camera.boomBlend=e*e*(3-2*e)
  self.zoom=self.zoom+(self.goal-self.zoom)*(1-math.exp(-math.max(0,dt or 0)/T.ZOOM_TIME))
  camera.boomZoom=self.zoom
  if not looking or camera.level<6 or not mouse or not mouse.isDown or not mouse.getPosition or not mouse.isDown(2)then mouseAt=nil
  else
   local x,y=mouse.getPosition()
   if mouseAt and not pointerSeen then
    -- Ignore cursor warps, matching the bounded Gen1 pointer input.
    local dx,dy=math.max(-40,math.min(40,x-mouseAt[1])),math.max(-40,math.min(40,y-mouseAt[2]))
    camera.look(dx*Look.MOUSE,dy*Look.MOUSE)
   end
   mouseAt={x,y}
  end
  pointerSeen=false
 end
 return state
end
return M
