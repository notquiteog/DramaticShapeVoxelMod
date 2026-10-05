-- Gen3 adapter for the bundled Crystal PNG frame sets. The native compositor
-- still owns animation effects/UI; this module supplies one selected picture.
local V=...
local M={pack=V.require('CrystalSprites').setting}
M.pack.defaultIndex=2 -- Gen3 keeps its existing selected/native art on first use.
local Assets=require('src.render.Assets')
local durations=V.require('Crystal/animation_data')
local entries,started={},{}
local owner
local function option(key)return V.mod.options:get(key)end
function M.active()return M.pack:get()=='crystal'end
function M.front()return M.active()and option('crystalFront')==true end
function M.schemas()
 local out={}
 for _,s in ipairs(V.require('CrystalSprites').schemas())do
  out[#out+1]=s
 end
 return out
end
function M.begin(battle)
 if owner~=battle then owner=battle;started={}end
end
local function load(path)
 local ok,img=pcall(Assets.image,V.mod.path..'/assets/crystal/'..path)
 if ok and img then img:setFilter('nearest','nearest');return img end
end
local portraits={}
local function portrait(path)
 if portraits[path]==nil then portraits[path]=load(path)or false end
 return portraits[path]or nil
end
function M.opponent(key)
 if not M.active()or not key then return end
 local mode=option('crystalTrainers')or'both'
 if mode~='both'and mode~='trainers'and mode~='all'then return end
 return portrait('trainers/opponent/'..key:gsub('%-','')..'.png')
end
function M.player()
 if not M.active()then return end
 local mode=option('crystalTrainers')or'both'
 if mode~='both'and mode~='player'and mode~='all'then return end
 local selection=option('crystalPlayerSprite')or'red.png'
 if selection=='default'then return end
 local stem=selection:gsub('_flip%.png$',''):gsub('%.png$','')
 if option('crystalBattlePic')=='back'then
  local image=portrait('trainers/back/'..stem..'.png')
  if image then return image,false end
 end
 local image=portrait('trainers/player/'..selection)
 if not image and selection=='leaf.png'then image=portrait('trainers/player/leaf_flip.png');return image,true end
 return image,selection:match('_flip%.png$')~=nil
end
function M.image(mon,side)
 if not M.active()or not mon then return end
 local dex=tonumber(mon.species);if not dex or dex<1 or dex>251 then return end
 local variant=V.require('BattleArt').isShiny({mon=mon})and'shiny'or'normal'
 local key=side..'/'..variant..'/'..dex
 local e=entries[key]
 if e==nil then
  if side=='back'then
   e={images={load('back/'..variant..'/'..dex..'.png')},durations={100}}
  else
   local timing=(durations[variant]or{})[tostring(dex)]or(durations.normal or{})[tostring(dex)]
   e={images={},durations=timing or{100}}
   for i=1,#e.durations do
    local image=load(('front/%s/%d/%03d.png'):format(variant,dex,i))
    if not image then break end
    e.images[#e.images+1]=image
   end
  end
  if #e.images==0 then e=false end
  entries[key]=e
 end
 if not e then return end
 if #e.images==1 then return e.images[1],e.images end
 local now=love.timer.getTime()*1000
 started[key]=started[key]or now
 local total=0;for i=1,#e.images do total=total+math.max(1,e.durations[i]or 100)end
 local elapsed=now-started[key]
 if option('crystalAnimations')=='once'and elapsed>=total then return e.images[#e.images],e.images end
 elapsed=elapsed%total
 for i,image in ipairs(e.images)do
  elapsed=elapsed-math.max(1,e.durations[i]or 100)
  if elapsed<0 then return image,e.images end
 end
 return e.images[1],e.images
end
Assets.register({release=function()entries={};started={};portraits={};owner=nil end})
return M
