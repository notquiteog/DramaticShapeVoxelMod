-- Selected Pokemon pictures through Oak's public draw boundary. Native
-- trainer portraits, steps, input, naming and reveal timers retain ownership.
local V=...
local M={}
local Pictures=V.require('NativeInterfaceArt')
local Palette=require('src.render.GbcPalette')
function M.install()
 local ok,Screen=pcall(require,'src.ui.gen2.OakSpeech')
 if not ok or type(Screen.drawPic)~='function'or type(Screen.resolvePic)~='function'then return function()end end
 local draw,resolve=Screen.drawPic,Screen.resolvePic
 local records=setmetatable({},{__mode='k'})
 Screen.resolvePic=function(self,desc,...)
  local image,colors=resolve(self,desc,...)
  if image and type(desc)=='table'and desc.type=='pokemon'then
   records[self]={[image]={species=desc.id}}
  else
   records[self]=nil
  end
  return image,colors
 end
 Screen.drawPic=function(self,...)
  -- Palette rotation is a native indexed-color effect. Preserve that exact
  -- reveal, then resume selected frames; never index full-color art by red.
  if V.crystalSpritesActive or(self.picReveal and self.picReveal.kind=='rotate')then return draw(self,...)end
  local mon=self.pic and self.pic==self.marillPic and {species=self.demoSpecies}
   or(records[self]and records[self][self.pic])
  if not mon or mon.species=='UNOWN'then return draw(self,...)end
  local image=Pictures.picture(mon,56,'front')
  if not image then return draw(self,...)end
  local pic,colors=self.pic,self.picColors
  self.pic=image
  if Palette.mode=='gbc'then self.picColors=nil end
  local result={pcall(draw,self,...)}
  self.pic,self.picColors=pic,colors
  if not result[1]then error(result[2],0)end
  return unpack(result,2)
 end
 return function()Screen.drawPic,Screen.resolvePic=draw,resolve end
end
return M
