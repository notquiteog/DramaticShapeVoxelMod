-- RS hatch uses the native indexed PPU, not an RGBA sprite draw. Only frames
-- representable by its original 64x64 / 15-color object are substituted.
local M={}
local function pack(...)return {n=select('#',...),...}end
local function blend(c,fx)
 if not fx then return c end
 local y,color=fx.y or 0,fx.color or 0
 local out=0
 for _,shift in ipairs({1,32,1024})do
  local v=math.floor(c/shift)%32;local target=math.floor(color/shift)%32
  out=out+(v+math.floor((target-v)*y/16))*shift
 end
 return out
end
function M.install(Art,Pokemon)
 local ok,H=pcall(require,'src.ui.game3.rs.egg_hatch')
 local okV,Vram=pcall(require,'src.ui.game3.rse.contest_vram')
 if not(ok and okV and type(H)=='table'and type(H.Scene)=='table'and type(H.Scene.draw)=='function'
  and type(Vram)=='table'and type(Vram.indexedPic)=='function')then return function()end end
 local cache=setmetatable({},{__mode='k'})
 local function indexed(image)
  if cache[image]~=nil then return cache[image]or nil end
  cache[image]=false
  local data=Art.imageData and Art.imageData(image)
  if not(data and data.getDimensions and data.getPixel)then return end
  local w,h=data:getDimensions();if w~=64 or h~=64 then return end
  local colors,n,bytes={},0,{}
  for y=0,63 do for x=0,63 do
   local r,g,b,a=data:getPixel(x,y)
   if a~=0 and a~=1 then return end
   r,g,b=math.floor(r*255+0.5),math.floor(g*255+0.5),math.floor(b*255+0.5)
   if a==1 then
    local color=math.floor(r*31/255+0.5)+math.floor(g*31/255+0.5)*32+math.floor(b*31/255+0.5)*1024
    if not colors[color]then colors[color]=true;n=n+1;if n>15 then return end end
   end
   bytes[#bytes+1]=string.char(r,g,b,a*255)
  end end
  local ok,sheet,palette=pcall(Vram.indexedPic,table.concat(bytes),false)
  if not(ok and sheet and palette)then return end
  local result={sheet=sheet,palette=palette};cache[image]=result;return result
 end
 local draw=H.Scene.draw
 local function nativeDraw(self,...)
  local effects=self.displayFx;local fx=effects and effects[14]
  -- RS stores RGB555 here, while the public nickname-frame shader expects RGB5.
  -- Adapt only that draw argument; retain the transferred native fade snapshot.
  if not(fx and type(fx.color)=='number')then return draw(self,...)end
  local temporary={};for k,v in pairs(effects)do temporary[k]=v end
  local normalized={};for k,v in pairs(fx)do normalized[k]=v end
  local color=fx.color
  normalized.color={color%32,math.floor(color/32)%32,math.floor(color/1024)%32}
  temporary[14]=normalized;self.displayFx=temporary
  local result=pack(pcall(draw,self,...));self.displayFx=effects
  if not result[1]then error(result[2],0)end
  return unpack(result,2,result.n)
 end
 H.Scene.draw=function(self,...)
  local mon,front=self.mon,self.front
  local ppu=self.m and self.m.ppu
  local sprites=ppu and ppu.sprites;local palette=ppu and ppu.palette
  if self.headless or not(mon and front and self.frontSheet and sprites and palette and palette.pltt)then return nativeDraw(self,...)end
  local species=Pokemon.speciesOf(mon)
  if Pokemon.isEgg(mon)or species==Pokemon.SPECIES_SPINDA or species==Pokemon.SPECIES_DEOXYS
   or Pokemon.monPicSpecies(mon)~=species then return nativeDraw(self,...)end
  local shown=sprites.oamShown;local entries,bank={}
  for _,entry in ipairs(shown or{})do
   if entry.sheet==self.frontSheet then
    if(entry.w and entry.w~=64)or(entry.h and entry.h~=64)or(entry.frame or 0)~=0 then return nativeDraw(self,...)end
    if bank~=nil and bank~=entry.paletteNum then return nativeDraw(self,...)end
    entries[#entries+1]=entry;bank=entry.paletteNum
   end
  end
  if #entries==0 or type(bank)~='number'then return nativeDraw(self,...)end
  for _,entry in ipairs(shown)do
   if entry.paletteNum==bank and entry.sheet~=self.frontSheet then return nativeDraw(self,...)end
  end
  local image=Art.picture({species=Pokemon.national(species),personality=mon.personality,
   otId=mon.otId,otSecretId=mon.otSecretId,isShiny=Pokemon.isShiny(mon)})
  local selected=image and indexed(image)
  if not selected then return nativeDraw(self,...)end
  local original={};local offset=256+bank*16
  local fx=self.displayFx and self.displayFx[16+bank]
  for i=0,15 do original[i]=palette.pltt[offset+i];palette.pltt[offset+i]=blend(selected.palette[i+1]or 0,fx)end
  for _,entry in ipairs(entries)do entry.sheet=selected.sheet end
  local result=pack(pcall(nativeDraw,self,...))
  for _,entry in ipairs(entries)do entry.sheet=self.frontSheet end
  for i=0,15 do palette.pltt[offset+i]=original[i]end
  if not result[1]then error(result[2],0)end
  return unpack(result,2,result.n)
 end
 return function()H.Scene.draw=draw;cache=setmetatable({},{__mode='k'})end
end
return M
