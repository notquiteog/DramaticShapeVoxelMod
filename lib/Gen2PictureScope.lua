-- Temporarily supply a selected picture through a native public draw method.
-- Update/input still see the original animation and picture reader.
local M={}
function M.draw(self,original,image,blackout,...)
  local graphics=love.graphics
  local draw=graphics.draw
  local previousPic,animation=rawget(self,'pic'),self.picAnim
  -- The original MonAnim continues stepping in update. Its ROM sheet only
  -- yields during this draw, exactly as the Summary/Hall-of-Fame readers do.
  self.picAnim=nil
  self.pic=function()return image,true end
  if blackout then
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
return M
