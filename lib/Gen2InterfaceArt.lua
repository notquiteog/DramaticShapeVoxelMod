-- Native GB2 menus expose picture readers independently of input/layout.
-- Their 56px block and animation state stay native; only selected-art fronts
-- are supplied. Crystal owns its own menu methods when that pack is active.
local V=...
local M={}
local Pictures=V.require('NativeInterfaceArt')
local function picture(mon,back)
 if V.crystalSpritesActive or not mon or mon.isEgg or mon.species=='UNOWN' then return nil end
 return Pictures.picture(mon,56,back and 'back' or 'front')
end
function M.install()
 local undoEvolution=V.require('Gen2EvolutionArt').install()
 local undoTradeHatch=V.require('Gen2TradeHatchArt').install()
 local undoOak=V.require('Gen2OakArt').install()
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
 local boxOK,Box=pcall(require,'src.ui.gen2.BoxMenu')
 local boxPic=boxOK and Box.picFor
 if type(boxPic)=='function'then
  Box.picFor=function(self,mon,...)
   local image=picture(mon)
   if image then return image,true end
   return boxPic(self,mon,...)
  end
 end
 -- Hall-of-Fame records retain the original DVs. Its two slide poses use
 -- different public readers; keep native scrolling, timing and record writes.
 local ok,Hall=pcall(require,'src.ui.gen2.HallOfFame')
 local hofPic,hofAnim
 if ok and type(Hall.monPic)=='function' and type(Hall.picAnimFrame)=='function'
  and type(Hall.currentMon)=='function'then
  hofPic,hofAnim=Hall.monPic,Hall.picAnimFrame
  Hall.monPic=function(self,mon,back,...)
   local image=picture(mon,back)
   if image then return image,true end
   return hofPic(self,mon,back,...)
  end
  Hall.picAnimFrame=function(self,...)
   if picture(self:currentMon())then return nil end
   return hofAnim(self,...)
  end
 end
 return function()
  undoOak()
  undoTradeHatch()
  undoEvolution()
  Summary.picFor,Summary.picAnimFrame,Dex.picFor=summary,animation,dex
  if type(boxPic)=='function'then Box.picFor=boxPic end
  if hofPic then Hall.monPic,Hall.picAnimFrame=hofPic,hofAnim end
 end
end
return M
