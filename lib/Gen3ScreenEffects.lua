-- Native full-world flashes and scent rings without surrendering the camera.
-- BG-only whitening, cave aperture and actor motion remain separate effects.
local M={}
function M.supports(kind)return kind=='flash'or kind=='sweet_scent'end
function M.alpha(anims)
 local remaining=1
 for _,a in ipairs(anims or{})do
  if type(a)=='table'and a.kind=='flash'then
   local alpha=tonumber(a.alpha)or 0
   if alpha==alpha then remaining=remaining*(1-math.max(0,math.min(1,alpha)))end
  end
 end
 return 1-remaining
end
function M.draw(canvas,anims)
 local alpha=M.alpha(anims);local scents={}
 for _,a in ipairs(anims or{})do if type(a)=='table'and a.kind=='sweet_scent'and tonumber(a.radius)then scents[#scents+1]=a end end
 if alpha<=0 and #scents==0 then return false end
 local g=love.graphics;local w,h=canvas:getDimensions()
 g.push('all')
 local ok,err=pcall(function()
  g.setCanvas(canvas);g.origin();g.setShader();g.setScissor();g.setDepthMode()
  g.setBlendMode('alpha','alphamultiply')
  if alpha>0 then g.setColor(1,1,1,alpha);g.rectangle('fill',0,0,w,h)end
  local scale=math.min(w/240,h/160);g.setLineWidth(scale)
  for _,a in ipairs(scents)do
   local opacity=.6*math.max(0,1-(tonumber(a.timer)or 0)/math.max(1,tonumber(a.maxDur)or 1))
   local radius=math.max(0,tonumber(a.radius)or 0)
   g.setColor(1,.7,.9,opacity)
   g.circle('line',w/2,h/2,radius*scale)
   g.circle('line',w/2,h/2,math.max(0,radius-20)*scale)
  end
 end)
 g.pop();if not ok then error(err,0)end
 return true
end
return M
