-- Selected artwork in the native Summary and Pokedex. The underlying menu
-- retains its layout, controls and species/form rules; substitution is scoped
-- to its draw and restored even when that draw raises an error.
local V=...
local M={}
local Interface=V.require('InterfaceSprites')
local Art=V.require('BattleArt')
local Animated=V.require('AnimatedBattleArt')
local prepared=setmetatable({},{__mode='k'})
M.settings={Interface.setting,Interface.scalingSetting}
function M.picture(mon,size)
 size=size or 64
 if Interface.setting:get()~='battle_art' then return nil end
 local image,frames
 if M.crystal and M.crystal.active()then image,frames=M.crystal.image(mon,'front')
 else image,frames=Animated.picture(mon,'front')end
 if not image then return nil end
 local full=Interface.scalingSetting:get()=='full'
 local owner=frames or image
 local cache=prepared[owner]
 if not cache then cache={};prepared[owner]=cache end
 local key=(full and 'full:' or 'fit:')..size
 if not cache[key] then
  -- Fit the complete animation union, keeping authored movement intact.
  cache[key]=Art.fitPreparedFrames(frames or {image},size,size,full)
 end
 local index=1
 for i,candidate in ipairs(frames or {})do if candidate==image then index=i;break end end
 return cache[key] and cache[key][index] or image
end
function M.install()
 local Pokemon=require('src.core.game3.pokemon')
 local Summary=require('src.ui.game3.summary_menu')
 local Dex=require('src.ui.game3.pokedex')
 local undo={}
 local function wrap(menu,monFor)
  local original=menu.draw
  menu.draw=function(...)
   if Interface.setting:get()~='battle_art' then return original(...)end
   local pic=Pokemon.frontPic
   local monPic=Pokemon.monFrontPic;local supplied
   if monPic then Pokemon.monFrontPic=function(mon,...)
    local previous=supplied;supplied=mon
    local r={pcall(monPic,mon,...)};supplied=previous
    if not r[1]then error(r[2],0)end;return unpack(r,2)
   end end
   Pokemon.frontPic=function(species,form,...)
    local source=supplied or(monFor and monFor()or nil)
    if (not form or form==0) and not (source and Pokemon.isEgg(source)) then
     local mon={species=Pokemon.national(species)}
     if source then
      mon.personality=source.personality;mon.otId=source.otId
      mon.otSecretId=source.otSecretId;mon.isShiny=source.isShiny
     end
     local image=M.picture(mon)
     if image then
      local w,h=image:getDimensions()
      return {image=image,w=w,h=h}
     end
    end
    return pic(species,form,...)
   end
   local okAnim,anim=pcall(require,'src.core.game3.mon_anim')
   local framePic=okAnim and anim.framePic
   if type(framePic)=='function'then
    anim.framePic=function(species,frame,shiny,...)
     local source=supplied or(monFor and monFor()or nil)
     if not(source and Pokemon.isEgg(source))then
      local mon={species=Pokemon.national(species),isShiny=shiny}
      if source then for _,k in ipairs({'personality','otId','otSecretId','isShiny'})do mon[k]=source[k]end end
      local image=M.picture(mon)
      if image then local w,h=image:getDimensions();return{image=image,w=w,h=h}end
     end
     return framePic(species,frame,shiny,...)
    end
   end
   local result={pcall(original,...)}
   if type(framePic)=='function'then anim.framePic=framePic end
   Pokemon.frontPic=pic;Pokemon.monFrontPic=monPic
   if not result[1]then error(result[2],0)end
   return unpack(result,2)
  end
  undo[#undo+1]=function()menu.draw=original end
 end
 wrap(Summary,function()return Summary._party and Summary._party[Summary._cursor or 1]end)
 wrap(Dex)
 -- These public draw seams resolve their pictures per frame; preserve all
 -- native evolution sequencing, confirmation input and Hall-of-Fame layout.
 for _,name in ipairs({'evolution_scene','hall_of_fame','hall_of_fame_pc'})do
  local ok,screen=pcall(require,'src.ui.game3.'..name)
  if ok and type(screen.draw)=='function'then
   wrap(screen,name=='evolution_scene'and function()return screen._mon end or nil)
  end
 end
 return function()
  for i=#undo,1,-1 do undo[i]()end
  prepared=setmetatable({},{__mode='k'})
 end
end
return M
