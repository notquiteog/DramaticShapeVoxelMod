-- Selected-art evolution pictures. The native screen still controls phases,
-- cancellation, swapping species, cries, particles and animation duration.
local V=...
local M={}
local Pictures=V.require('NativeInterfaceArt')

local function picture(screen)
 if V.crystalSpritesActive then return nil end
 local source=screen.mon
 local species=screen.showNew and screen.newSpecies or screen.oldSpecies
 if not source or source.isEgg or not species or species=='UNOWN'then return nil end
 -- During the flash the party record is still the original species. The
 -- target picture shares its real DVs/shiny identity without editing it.
 local mon=source
 if species~=source.species then
  mon={};for key,value in pairs(source)do mon[key]=value end
  mon.species=species
 end
 return Pictures.picture(mon,56,'front')
end

function M.install()
 local ok,Screen=pcall(require,'src.ui.gen2.EvolutionAnim')
 if not ok or type(Screen.drawPic)~='function'then return function()end end
 local original=Screen.drawPic
 Screen.drawPic=function(self,...)
  local image=picture(self)
  if not image then return original(self,...)end
  local graphics=love.graphics
  local draw=graphics.draw
  local previousPic,animation=rawget(self,'pic'),self.picAnim
  -- The original MonAnim continues stepping in update. Its ROM sheet only
  -- yields during this draw, exactly as the Summary/Hall-of-Fame readers do.
  self.picAnim=nil
  self.pic=function()return image,true end
  if self.blackout then
   graphics.draw=function(texture,...)
    if texture~=image then return draw(texture,...)end
    local r,g,b,a=graphics.getColor()
    -- A native palette shader indexes grayscale by red. Applying that to
    -- full-color yellow/red art would erase bright body pixels. Black tint
    -- preserves the selected frame's alpha silhouette in every color mode.
    graphics.setColor(0,0,0,a)
    local result={pcall(draw,texture,...)}
    graphics.setColor(r,g,b,a)
    if not result[1]then error(result[2],0)end
    return unpack(result,2)
   end
  end
  local result={pcall(original,self,...)}
  graphics.draw=draw
  self.pic,self.picAnim=previousPic,animation
  if not result[1]then error(result[2],0)end
  return unpack(result,2)
 end
 return function()Screen.drawPic=original end
end

return M
