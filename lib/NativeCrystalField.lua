-- Optional Crystal character sheets on the native overworld renderer. Companion
-- sprite overrides win; Pokemon and special avatar actions retain native art.
local V=...
local M={}
-- pret/pokefirered include/constants/event_objects.h (FRLG only).
-- https://github.com/pret/pokefirered/blob/master/include/constants/event_objects.h
local trainers={[72]='blue',[74]='lance',[75]='agatha',[77]='lorelei',[79]='bruno',
 [80]='brock',[81]='misty',[82]='lt.surge',[83]='erika',[84]='koga',[85]='sabrina',[86]='blaine',[87]='giovanni'}
function M.install()
 local Sprites=require('src.core.game3.ow_sprites');local Player=require('src.core.game3.player')
 local Crystal=V.require('NativeCrystalArt');local Assets=require('src.render.Assets')
 local base,pose,reflection=Sprites.getDraw,Sprites.pose,Sprites.getReflectionDraw
 local sheets={};local game
 local function sheet(path)
  if sheets[path]~=nil then return sheets[path]or nil end
  local ok,image=pcall(Assets.image,V.mod.path..'/assets/crystal/overworld/'..path..'.png')
  if not ok or not image then sheets[path]=false;return end
  local w,h=image:getDimensions();if w~=16 or h~=96 then sheets[path]=false;return end
  local s={image=image,width=16,height=16,w=16,h=16,frameCount=6,quads={},crystalNative=true}
  image:setFilter('nearest','nearest')
  for i=0,5 do s.quads[i]=love.graphics.newQuad(0,i*16,16,16,w,h)end
  sheets[path]=s;return s
 end
 local function selected(gid)
  if not Crystal.active()then return end
  local mode=V.mod.options:get('crystalTrainers')
  if mode~='overworld'and mode~='all'then return end
  if game and gid==Sprites.playerGraphicsId(game)then
   local state=Sprites.avatarState(Player)
   if state~='NORMAL'and state~='MACH_BIKE'and state~='ACRO_BIKE'then return end
   local portrait=V.mod.options:get('crystalPlayerSprite')or'red.png'
   if portrait=='default'then return end
   local stem=portrait:gsub('_flip%.png$',''):gsub('%.png$','')
   return 'player/'..stem..(state=='NORMAL'and''or'_bike')
  end
  local version=require('src.core.GameVersion').get()
  local name=(version=='firered'or version=='leafgreen')and trainers[tonumber(gid)]
  return name and 'trainers/'..name or nil
 end
 Sprites.getDraw=function(gid)
  local native=base(gid);local path=selected(gid)
  -- Explicit palette/provider replacements are not native base sheets.
  if not path or native~=Sprites.get(gid)then return native end
  return sheet(path)or native
 end
 Sprites.getReflectionDraw=function(gid)
  local s=Sprites.getDraw(gid)
  if s and s.crystalNative then return s end
  return reflection(gid)
 end
 Sprites.pose=function(s,facing,phase,flip,opts)
  if not(s and s.crystalNative)then return pose(s,facing,phase,flip,opts)end
  if opts and opts.frame~=nil then
   return math.max(0,math.min(5,tonumber(opts.frame)or 0)),facing=='right'
  end
  local dir=({down=0,up=1,left=2,right=2})[facing]or 0
  local walking=phase==1 or phase==true
  local frame=dir+(walking and 3 or 0)
  return frame,facing=='right'or(dir<2 and walking and flip==true)
 end
 V.mod.hooks:wrap('core.update',function(next,g,...)game=g;return next(g,...)end)
 local function clear()
  for _,s in pairs(sheets)do if s then for _,q in pairs(s.quads)do q:release()end end end;sheets={}
 end
 Assets.register({release=clear})
 return function()Sprites.getDraw,Sprites.pose,Sprites.getReflectionDraw=base,pose,reflection;clear();game=nil end
end
return M
