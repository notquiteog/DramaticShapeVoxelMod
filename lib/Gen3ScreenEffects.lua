-- Native full-world palette flashes without surrendering the voxel camera.
-- BG-only whitening, cave aperture and actor motion remain separate effects.
local M={}
function M.supports(kind)return kind=='flash'end
function M.alpha(anims)
 local remaining=1
 for _,a in ipairs(anims or{})do
  if type(a)=='table'and M.supports(a.kind)then
   local alpha=tonumber(a.alpha)or 0
   if alpha==alpha then remaining=remaining*(1-math.max(0,math.min(1,alpha)))end
  end
 end
 return 1-remaining
end
function M.draw(canvas,anims)
 local alpha=M.alpha(anims);if alpha<=0 then return false end
 local g=love.graphics;local w,h=canvas:getDimensions()
 g.push('all')
 local ok,err=pcall(function()
  g.setCanvas(canvas);g.origin();g.setShader();g.setScissor();g.setDepthMode()
  g.setBlendMode('alpha','alphamultiply');g.setColor(1,1,1,alpha)
  g.rectangle('fill',0,0,w,h)
 end)
 g.pop();if not ok then error(err,0)end
 return true
end
return M
