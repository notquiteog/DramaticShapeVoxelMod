-- Native scenes retain their timing, sounds, particles and record ownership.
local V=...
local M={}
local Pictures=V.require('NativeInterfaceArt')
local Scope=V.require('Gen2PictureScope')
local function picture(mon)
 if V.crystalSpritesActive or not mon or mon.isEgg or mon.species=='UNOWN'then return nil end
 return Pictures.picture(mon,56,'front')
end
function M.install()
 local restores={}
 local function wrap(module,resolve)
  local ok,Screen=pcall(require,module)
  if not ok or type(Screen.drawPic)~='function'then return end
  local original=Screen.drawPic
  Screen.drawPic=function(self,...)
   local image=picture(resolve(self,...))
   if not image then return original(self,...)end
   return Scope.draw(self,original,image,false,...)
  end
  restores[#restores+1]=function()Screen.drawPic=original end
 end
 wrap('src.ui.gen2.TradeAnim',function(_,record)return record end)
 wrap('src.ui.gen2.EggHatchAnim',function(self)
  -- Only the revealed hatchling changes; eggs, cracks and shell fragments
  -- remain native. The scene's species can differ from the source record.
  if not self.showMon or not self.mon then return nil end
  if not self.species or self.species==self.mon.species then return self.mon end
  local mon={};for key,value in pairs(self.mon)do mon[key]=value end
  mon.species=self.species
  return mon
 end)
 return function()for i=#restores,1,-1 do restores[i]()end end
end
return M
