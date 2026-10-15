-- Selected artwork in native interfaces. The shared picture reader supports
-- front/back poses; each installed screen retains its own pose rules. The menu
-- retains its layout, controls and species/form rules; substitution is scoped
-- to its draw and restored even when that draw raises an error.
local V=...
local M={}
local Interface=V.require('InterfaceSprites')
local Art=V.require('BattleArt')
local Animated=V.require('AnimatedBattleArt')
local prepared=setmetatable({},{__mode='k'})
local function pack(...)return {n=select('#',...),...}end
M.settings={Interface.setting,Interface.scalingSetting}
function M.picture(mon,size,side)
 size=size or 64
 side=side or 'front'
 if Interface.setting:get()~='battle_art' then return nil end
 local image,frames
 local crystal=M.crystal and M.crystal.active()
 if crystal then image,frames=M.crystal.image(mon,side)
 else image,frames=Animated.picture(mon,side)end
 if not image then return nil end
 local full=Interface.scalingSetting:get()=='full'
 local owner=frames or image
 local cache=prepared[owner]
 if not cache then cache={};prepared[owner]=cache end
 if crystal and cache.base==nil then
  -- Raw Crystal PNGs have no BattleArt bounds. Prepare their CPU pixels once
  -- so FIT/FULL shares the complete animation union just like selected art.
  local base={}
  for _,frame in ipairs(frames or {image})do
   local data=M.crystal.imageData and M.crystal.imageData(frame)
   local ready=data and Art.prepareData(data,'color')
   if not ready then base=false;break end
   base[#base+1]=ready
  end
  cache.base=base
 end
 if cache.base==false then return nil end
 local key=(full and 'full:' or 'fit:')..size
 if not cache[key] then
  -- Fit the complete animation union, keeping authored movement intact.
  cache[key]=Art.fitPreparedFrames(cache.base or frames or {image},size,size,full)
 end
 local index=1
 for i,candidate in ipairs(frames or {})do if candidate==image then index=i;break end end
 return cache[key] and cache[key][index] or image
end
function M.install()
 local undoPortraits=V.require('NativeCrystalPortraits').install()
 local Pokemon=require('src.core.game3.pokemon')
 local undoScripted=V.require('NativeScriptedArt').install(M,Pokemon)
 local undoPokeblock=V.require('NativePokeblockArt').install(M,Pokemon)
 local function eligible(species,form,source)
  if form and form~=0 or source and Pokemon.isEgg(source)then return false end
  -- These native pictures encode egg state, PID spots or edition-specific
  -- forms that a species-only selected illustration cannot reproduce.
  local n=tonumber(species)
  if n and(n==Pokemon.SPECIES_EGG or n==Pokemon.SPECIES_SPINDA or n==Pokemon.SPECIES_DEOXYS)then return false end
  return true
 end
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
    local r=pack(pcall(monPic,mon,...));supplied=previous
    if not r[1]then error(r[2],0)end;return unpack(r,2,r.n)
   end end
   Pokemon.frontPic=function(species,form,...)
    local source=supplied or(monFor and monFor()or nil)
    if eligible(species,form,source)then
     local shiny,personality=...
     local mon={species=Pokemon.national(species),isShiny=shiny,personality=personality}
     if source then
      for _,k in ipairs({'personality','otId','otSecretId','isShiny'})do
       if source[k]~=nil then mon[k]=source[k]end
      end
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
     if eligible(species,nil,source)then
      local mon={species=Pokemon.national(species),isShiny=shiny}
      if source then for _,k in ipairs({'personality','otId','otSecretId','isShiny'})do mon[k]=source[k]end end
      local image=M.picture(mon)
      if image then local w,h=image:getDimensions();return{image=image,w=w,h=h}end
     end
     return framePic(species,frame,shiny,...)
    end
   end
   local result=pack(pcall(original,...))
   if type(framePic)=='function'then anim.framePic=framePic end
   Pokemon.frontPic=pic;Pokemon.monFrontPic=monPic
   if not result[1]then error(result[2],0)end
   return unpack(result,2,result.n)
  end
  undo[#undo+1]=function()menu.draw=original end
 end
 wrap(Summary,function()return Summary._party and Summary._party[Summary._cursor or 1]end)
 wrap(Dex)
 -- These public draw seams resolve their pictures per frame; preserve all
 -- native scene sequencing, PokeNav navigation and layout. PokeNav class
 -- methods supply their own mon to monFrontPic during the scoped draw.
 for _,name in ipairs({'evolution_scene','hall_of_fame','hall_of_fame_pc','trade_scene','egg_hatch',
  'rs.pokenav.condition','rs.pokenav.ribbons','rse.pokenav.condition','rse.pokenav.ribbons_summary',
  'rse.factory_select','rse.factory_swap','rse.credits'})do
  local ok,screen=pcall(require,'src.ui.game3.'..name)
  if ok and type(screen.draw)=='function'then
   wrap(screen,(name=='evolution_scene'or name=='egg_hatch')and function()return screen._mon end or nil)
  end
 end
 return function()
  undoPokeblock()
  undoScripted()
  undoPortraits()
  for i=#undo,1,-1 do undo[i]()end
  prepared=setmetatable({},{__mode='k'})
 end
end
return M
