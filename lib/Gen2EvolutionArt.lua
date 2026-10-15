-- Selected-art evolution pictures. The native screen still controls phases,
-- cancellation, swapping species, cries, particles and animation duration.
local V=...
local M={}
local Pictures=V.require('NativeInterfaceArt')
local Scope=V.require('Gen2PictureScope')

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
  return Scope.draw(self,original,image,self.blackout,...)
 end
 return function()Screen.drawPic=original end
end

return M
