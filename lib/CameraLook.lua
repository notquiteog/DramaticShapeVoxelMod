-- Common free-look tuning. Gen 1/2 yaw grows in the opposite direction to
-- Gen 3; adapters apply that one sign change, not different stick curves.
local M={DEAD=.18,YAW=3.5,PITCH=2.4,MOUSE=.0032,TOUCH=2.2*math.pi,
 UP=-math.rad(50),DOWN=math.rad(70)}
function M.axis(value)
 local n=tonumber(value)or 0
 if n~=n then return 0 end
 local a=math.min(1,math.abs(n))
 if a<=M.DEAD then return 0 end
 a=(a-M.DEAD)/(1-M.DEAD)
 return (n<0 and -1 or 1)*a*a
end
function M.focused(window)
 if not(window and window.hasFocus)then return true end
 local ok,focused=pcall(window.hasFocus)
 return ok and focused==true
end
function M.resetLost(stick,window)
 local connected=true
 if stick.controller and stick.controller.isConnected then
  local ok,value=pcall(stick.controller.isConnected,stick.controller)
  connected=ok and value~=false
 end
 if not connected or not M.focused(window)then
  stick.x,stick.y,stick.controller=0,0,nil
  return true
 end
 return false
end
return M
