-- Native free-camera inputs share Gen1 boom tuning and input direction.
local V=...
local T=V.require('ThirdPerson')
local M={}
function M.new(camera)
 local state={zoom=1,goal=1}
 local mouseAt,pointerSeen
 function state:step(n)
  if camera.level~=7 or not n or n==0 then return false end
  self.goal=math.max(T.ZOOM_MIN,math.min(T.ZOOM_MAX,self.goal*T.ZOOM_STEP^n))
  return true
 end
 function state:pointer()pointerSeen=true end
 function state:update(dt,looking,mouse)
  self.zoom=self.zoom+(self.goal-self.zoom)*(1-math.exp(-math.max(0,dt or 0)/T.ZOOM_TIME))
  camera.boomZoom=self.zoom
  if not looking or camera.level<6 or not mouse or not mouse.isDown or not mouse.getPosition or not mouse.isDown(2)then mouseAt=nil
  else
   local x,y=mouse.getPosition()
   if mouseAt and not pointerSeen then
    -- Ignore cursor warps, matching the bounded Gen1 pointer input.
    local dx,dy=math.max(-40,math.min(40,x-mouseAt[1])),math.max(-40,math.min(40,y-mouseAt[2]))
    camera.look(dx*.005,dy*.004)
   end
   mouseAt={x,y}
  end
  pointerSeen=false
 end
 return state
end
return M
