-- Native GB2 menus expose picture readers independently of input/layout.
-- Their 56px block and animation state stay native; only selected-art fronts
-- are supplied. Crystal owns its own menu methods when that pack is active.
local V=...
local M={}
local Pictures=V.require('NativeInterfaceArt')
local function picture(mon)
 if V.crystalSpritesActive or not mon or mon.isEgg or mon.species=='UNOWN' then return nil end
 return Pictures.picture(mon,56)
end
function M.install()
 local Summary=require('src.ui.gen2.SummaryMenu')
 local Dex=require('src.ui.gen2.PokedexMenu')
 local summary,animation,dex=Summary.picFor,Summary.picAnimFrame,Dex.picFor
 Summary.picFor=function(self,mon,...)
  local image=picture(mon)
  if image then return image,true end
  return summary(self,mon,...)
 end
 Summary.picAnimFrame=function(self,...)
  -- Never let the ROM's MonAnimView repaint over a selected atlas frame.
  -- Do not erase/advance the original animation: switching OFF restores it.
  if picture(self.mon)then return nil end
  return animation(self,...)
 end
 Dex.picFor=function(self,species,...)
  local image=picture({species=species})
  if image then return image,true end
  return dex(self,species,...)
 end
 return function()Summary.picFor,Summary.picAnimFrame,Dex.picFor=summary,animation,dex end
end
return M
