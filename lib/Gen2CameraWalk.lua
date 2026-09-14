-- Camera-relative intent at Gen 2's real input seam. The engine still owns
-- grid steps, speed hooks, ledges, connections, ice, collisions and arrivals.
local V=...
local M={}
function M.available()
  local ok,World=pcall(require,"src.world.gen2.World")
  return ok and type(World.pollInput)=="function"
end
function M.direction(x,z)
  if x*x+z*z<.01 then return nil end
  if math.abs(x)>math.abs(z) then return x>0 and "right" or "left" end
  return z>0 and "down" or "up"
end
function M.install()
  local World=require("src.world.gen2.World")
  if World.battleArtCameraWalk then return end
  local inner=World.pollInput
  if type(inner)~="function" then return end
  World.battleArtCameraWalk=true
  local FP=V.require("FirstPerson")
  function World:pollInput(input)
    if not FP.driving() or self:busy() then return inner(self,input) end
    local mx,mz=FP.moveVector()
    local x,z=FP.moveWorld(mx,mz)
    local dir=M.direction(x,z)
    -- Only the d-pad reads in pollInput are transformed. The actual input
    -- object (A/B, menus, held-source bookkeeping) is never modified.
    local proxy={isDown=function(_,key)
      if key=="up" or key=="down" or key=="left" or key=="right" then return key==dir end
      return input and input:isDown(key) or false
    end}
    return inner(self,proxy)
  end
end
return M
