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
 local image,frames=Animated.picture(mon,'front')
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
   Pokemon.frontPic=function(species,form,...)
    local source=monFor and monFor() or nil
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
   local result={pcall(original,...)}
   Pokemon.frontPic=pic
   if not result[1]then error(result[2],0)end
   return unpack(result,2)
  end
  undo[#undo+1]=function()menu.draw=original end
 end
 wrap(Summary,function()return Summary._party and Summary._party[Summary._cursor or 1]end)
 wrap(Dex)
 return function()
  for i=#undo,1,-1 do undo[i]()end
  prepared=setmetatable({},{__mode='k'})
 end
end
return M
