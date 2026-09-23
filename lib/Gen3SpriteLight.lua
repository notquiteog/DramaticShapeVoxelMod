-- Native actors stay on the UI plane. Shade only their tagged image draws,
-- multiplying native flash/fade colors and restoring state even on errors.
-- World-space cast shadows remain a separate, unsupported native adapter.
local V=...
local M={}
local images
function M.tag(entry)
 if images and entry and entry.image then images[entry.image]=true end
 return entry
end
function M.scope(draw,...)
 local oldImages=images;images={}
 local G=love.graphics;local old=G.draw
 local stage=V.require('Gen3Battle')
 local UI=V.require('UiBackplates')
 G.draw=function(image,...)
  if images[image] and stage.active and not UI.spritesUnlit()then
   local Map=require('src.core.game3.map')
   local tint=V.require('DayNight').tint(V.require('Gen3Tilesets').outdoor(Map.currentDef()))
   local r,g,b,a=G.getColor();G.setColor(r*tint[1],g*tint[2],b*tint[3],a)
   local result={pcall(old,image,...)};G.setColor(r,g,b,a)
   if not result[1]then error(result[2],0)end
   return unpack(result,2)
  end
  return old(image,...)
 end
 local result={pcall(draw,...)}
 G.draw=old;images=oldImages
 if not result[1]then error(result[2],0)end
 return unpack(result,2)
end
return M
