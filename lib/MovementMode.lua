-- Camera steering and locomotion are separate preferences. Native grid steps
-- remain the default; continuous movement is explicitly selected by the user.
local V=...
local M={}
M.description='GRID keeps native tile steps with camera-relative controls in first/rotating third person. FREE enables continuous movement in those views. Static views retain native movement.'
M.setting=V.require('ModSetting').new('movementMode','3D MOVE',
 {'grid','free'},{'GRID','FREE'},1)
function M.free()return M.setting:get()=='free'end
function M.direction(x,z)
 if x*x+z*z<.01 then return nil end
 if math.abs(x)>math.abs(z)then return x>0 and 'right' or 'left'end
 return z>0 and 'down' or 'up'
end
-- Gen1 has no input parameter at its controller seam. Scope the proxy to that
-- single call and restore it even when another wrapper raises an error.
function M.grid(state,inner)
 local Game=require('src.core.Game')
 local input=Game.input
 local FP=V.require('FirstPerson')
 local x,z=FP.moveVector();x,z=FP.moveWorld(x,z)
 local dir=M.direction(x,z)
 local proxy=setmetatable({isDown=function(_,key)
  if key=='up' or key=='down' or key=='left' or key=='right'then return key==dir end
  return input:isDown(key)
 end,wasPressed=function(_,key)return input:wasPressed(key)end},{__index=input})
 Game.input=proxy
 local ok,result=pcall(inner,state)
 Game.input=input
 if not ok then error(result,0)end
 return result
end
return M
