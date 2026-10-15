-- Cached native script/contest pictures: substitute only for the original draw.
-- The engine retains its cached frame, animation transform, window and cries.
local M={}
local function pack(...)return {n=select('#',...),...}end
function M.install(Art,Pokemon)
 local okPic,Pic=pcall(require,'src.ui.game3.mon_pic')
 local okEntry,Entry=pcall(require,'src.ui.game3.rse.contest_entry_pic')
 if not(okPic and okEntry and type(Pic)=='table'and type(Entry)=='table')then return function()end end
 for _,name in ipairs({'draw','show','hide'})do if type(Pic[name])~='function'then return function()end end end
 for _,name in ipairs({'show','hide','reset'})do if type(Entry[name])~='function'then return function()end end end
 local context
 local originals={draw=Pic.draw,show=Pic.show,hide=Pic.hide,entryShow=Entry.show,entryHide=Entry.hide,entryReset=Entry.reset}
 local function clear(original,...)
  context=nil;return original(...)
 end
 Pic.show=function(...)return clear(originals.show,...)end
 Pic.hide=function(...)return clear(originals.hide,...)end
 Entry.hide=function(...)return clear(originals.entryHide,...)end
 Entry.reset=function(...)return clear(originals.entryReset,...)end
 Entry.show=function(mon,...)
  local active=Entry.active
  local result=pack(pcall(originals.entryShow,mon,...))
  if not result[1]then error(result[2],0)end
  -- A second show while active is ignored by the original scene. Keep the
  -- first entry's identity instead of labeling its picture as another mon.
  if not active and Entry.active and Pic.active then
   local ot=tonumber(mon.otId)or 0
   local source={species=tonumber(mon.species),personality=tonumber(mon.personality)or 0,
    otId=ot%65536,otSecretId=math.floor(ot/65536)%65536}
   source.isShiny=Pokemon.isShiny(source)
   context=source
  end
  return unpack(result,2,result.n)
 end
 Pic.draw=function(...)
  local species=tonumber(Pic.species)
  local source=context and Entry.active and context.species==species and context or nil
  local pid=source and source.personality or 0x8000
  local picSpecies=Pokemon.picSpecies(species,pid)
  local special=species==Pokemon.SPECIES_EGG or species==Pokemon.SPECIES_SPINDA or species==Pokemon.SPECIES_DEOXYS
  local selected
  if Pic.active and Pic._img and not special and picSpecies==species then
   selected=Art.picture({species=Pokemon.national(species),personality=pid,
    otId=source and source.otId,otSecretId=source and source.otSecretId,
    isShiny=source and source.isShiny or false})
  end
  if not selected then return originals.draw(...)end
  local image,w,h,transform=Pic._img,Pic._w,Pic._h,Pic._animTransform
  Pic._img=selected;Pic._w,Pic._h=selected:getDimensions()
  -- MonPic normally scales every cached image into 64x64. FULL must retain
  -- authored pixels; compensate only that viewport scale, keeping the native
  -- center, translation, rotation and animation squash/stretch unchanged.
  local scale=math.min(64/Pic._w,64/Pic._h)
  if Art.settings[2]:get()=='full'and scale<1 then
   local t={};for key,value in pairs(transform or {})do t[key]=value end
   t.sx=(t.sx or 1)/scale;t.sy=(t.sy or 1)/scale
   Pic._animTransform=t
  end
  local result=pack(pcall(originals.draw,...))
  Pic._img,Pic._w,Pic._h,Pic._animTransform=image,w,h,transform
  if not result[1]then error(result[2],0)end
  return unpack(result,2,result.n)
 end
 return function()
  context=nil
  Pic.draw,Pic.show,Pic.hide=originals.draw,originals.show,originals.hide
  Entry.show,Entry.hide,Entry.reset=originals.entryShow,originals.entryHide,originals.entryReset
 end
end
return M
