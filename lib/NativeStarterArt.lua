-- StarterChoose's native sprite quad is fixed at 64 pixels. Draw selected
-- pictures at its public final-fade seam so FULL art is not silently cropped.
local M={}
local function pack(...)return {n=select('#',...),...}end
function M.install(Art,Pokemon)
 local ok,Screen=pcall(require,'src.ui.game3.rse.starter_choose')
 local okKit,Kit=pcall(require,'src.ui.game3.rse.scene_kit')
 if not(ok and okKit and type(Screen)=='table'and type(Screen.draw)=='function'and type(Kit)=='table'and type(Kit.drawFade)=='function')then return function()end end
 local draw=Screen.draw
 Screen.draw=function(self,...)
  local mon=self.mon
  if not(love and love.graphics and type(love.graphics.getStackDepth)=='function')then return draw(self,...)end
  local image=mon and Art.picture({species=Pokemon.national(mon.species)})
  if not image then return draw(self,...)end
  local fade=Kit.drawFade;local drawn=false
  Kit.drawFade=function(...)
   if not drawn then
    drawn=true
    local g=love.graphics;local w,h=image:getDimensions()
    local depth=g.getStackDepth()
    g.push('all')
    local okDraw,err=pcall(function()
     local function picture(scale)g.draw(image,mon.x,mon.y,0,scale,scale,w/2,h/2)end
     if self.policy and type(self.policy.drawAffine)=='function'then
      -- Keep RS's original affine/scissor policy; expand only the selected
      -- FULL image's viewport when its authored canvas exceeds 64 pixels.
      self.policy.drawAffine(mon.x,mon.y,mon.affine.scale,math.max(w,h)/2,picture)
     else picture(mon.affine.scale/256)end
    end)
    while g.getStackDepth()>depth do g.pop()end
    if not okDraw then error(err,0)end
   end
   return fade(...)
  end
  self.mon=nil
  local result=pack(pcall(draw,self,...))
  self.mon=mon;Kit.drawFade=fade
  if not result[1]then error(result[2],0)end
  return unpack(result,2,result.n)
 end
 return function()Screen.draw=draw end
end
return M
