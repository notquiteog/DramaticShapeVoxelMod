-- Permitted Kanto First Person audio, without a second particle/weather owner.
local V=...
local S=V.require('ModSetting')
local M={}
M.ambient=S.new('kfpAmbience','TOWN / ROUTE SOUND',{'off','low','mid'},{'OFF','LOW','MID'})
M.rain=S.new('kfpRainSound','RAIN SOUND',{'off','low','mid'},{'OFF','LOW','MID'})
M.steps=S.new('kfpFootsteps','SURFACE FOOTSTEPS',{false,true},{'OFF','ON'})
M.doors=S.new('kfpDoorSounds','DOOR SOUNDS',{false,true},{'OFF','ON'})
M.settings={M.ambient,M.rain,M.steps,M.doors}
local permitted={['amb-cave.mp3']=true,['amb-forest.mp3']=true,['amb-night.mp3']=true,
 ['amb-rain.mp3']=true,['amb-route.mp3']=true,['amb-town.mp3']=true,['amb-water.mp3']=true,
 ['sfx-cavestep.mp3']=true,['sfx-door.mp3']=true,['sfx-grass1.mp3']=true,
 ['sfx-grass2.mp3']=true,['sfx-shopdoor.mp3']=true,['sfx-woodstep.mp3']=true}
function M.read(name)
 if not permitted[name]then return nil end
 for _,base in ipairs({'assets/legendary/','vendor/kanto-first-person/'})do
  local ok,bytes=pcall(V.mod.read,V.mod,base..name)
  if ok and type(bytes)=='string'and #bytes>0 then return bytes end
 end
end
function M.new()
 local self={sources={},volumes={},errors={}}
 function self:source(name,loop)
  if self.sources[name]~=nil then return self.sources[name]or nil end
  local ok,s=pcall(function()
   local bytes=assert(M.read(name),'sound unavailable: '..name)
   local data=love.filesystem.newFileData(bytes,name)
   local source=love.audio.newSource(data,loop and 'stream'or 'static')
   if data.release then data:release()end
   source:setLooping(loop);source:setVolume(0);return source
  end)
  self.sources[name]=ok and s or false
  if not ok then self.errors[name]=tostring(s)end
  return ok and s or nil
 end
 function self:play(name,gain)
  local s=self:source(name,false)
  if s then s:stop();s:setVolume(gain);s:play()end
 end
 -- facts are normalized by the owner, never inferred from foreign tile IDs.
 -- cave/forest audio stays with the existing Legendary sound controls.
 function self:update(facts,dt,master,enabled)
  facts=facts or {};dt=math.max(0,math.min(.1,tonumber(dt)or 0))
  local gain=enabled and math.max(0,math.min(1,tonumber(master)or 1))or 0
  local level=({low=.35,mid=.62})[M.ambient:get()]or 0
  for _,kind in ipairs({'town','route','rain'})do
   local name='amb-'..kind..'.mp3'
   local target=facts.kind==kind and gain*level or 0
   if kind=='rain'then target=facts.rain and gain*(( {low=.35,mid=.62})[M.rain:get()]or 0)or 0 end
   local vol=self.volumes[name]or 0
   vol=gain==0 and 0 or vol+math.max(-dt*.55,math.min(dt*.30,target-vol))
   self.volumes[name]=vol
   local s=self.sources[name];if vol>.001 then s=self:source(name,true)end
   if s then s:setVolume(vol);if vol>.001 then if not s:isPlaying()then s:play()end else s:stop()end end
  end
  local prev=self.previous
  if gain>0 and prev and prev.active and facts.map and facts.map==prev.map then
   local distance=math.abs((facts.x or 0)-prev.x)+math.abs((facts.z or 0)-prev.z)
   self.distance=(self.distance or 0)+(distance<=8 and distance or 0)
   if distance>24 then self.distance=0 end
   if self.distance>=8 then
    self.distance=self.distance%8
    if M.steps:get()then
     if facts.grass then self.flip=not self.flip;self:play(self.flip and 'sfx-grass1.mp3'or 'sfx-grass2.mp3',.65*gain)
     elseif facts.kind=='room'then self:play('sfx-woodstep.mp3',.5*gain)end
    end
   end
  elseif gain>0 and prev and prev.active and facts.map and facts.map~=prev.map then
   self.distance=0
   if M.doors:get()and (facts.kind=='room')~=(prev.kind=='room')then
    local room=facts.kind=='room'and facts or prev
    if room.kind=='room' then self:play(room.shop and 'sfx-shopdoor.mp3'or 'sfx-door.mp3',.7*gain)end
   end
  else self.distance=0 end
  self.previous={map=facts.map,kind=facts.kind,shop=facts.shop,x=facts.x or 0,z=facts.z or 0,active=gain>0}
 end
 function self:clear()
  for _,s in pairs(self.sources)do if s then s:stop();s:release()end end
  self.sources={};self.volumes={};self.previous=nil;self.distance=0
 end
 return self
end
-- Normalize maps only for sound selection; no tile IDs or engine patches.
function M.facts(map,player,generation)
 local d=map and (map.nativeDef or map.def or map)or {}
 local id=tostring(map and map.id or d.id or '')
 local kind=map and V.require('NativeAtmosphere').kind(map)
 local tid=tostring(d.tileset or '')
 if not kind then
  if tid=='CAVERN'or tid=='UNDERGROUND'then kind='cave'
  elseif tid=='FOREST'then kind='forest'
  else
   local outdoor
   if generation==3 then local t=tonumber(map and map.nativeType or d.mapType);outdoor=t==1 or t==2 or t==3 or t==5 or t==6
   elseif generation==2 then outdoor=d.environment=='TOWN'or d.environment=='ROUTE'
   else outdoor=tid=='OVERWORLD'or tid=='PLATEAU'or tid=='SHIP_PORT'end
   kind=outdoor and ((id:find('TOWN')or id:find('CITY'))and 'town'or 'route')or 'room'
  end
 end
 local p=player or {};local grass=false
 if map and type(map.isGrassCell)=='function'then
  local size=16 -- native collision/grass cells are 16px in every generation
  local ok,g=pcall(map.isGrassCell,map,math.floor((p.px or 0)/size),math.floor((p.py or 0)/size));grass=ok and g or false
 elseif generation==3 and map then
  local ok,g=pcall(function()return require('src.core.game3.collision').isGrass(p.cellX,p.cellY)end);grass=ok and g or false
 end
 local weatherMap=generation==3 and map and {id=map.id,def={outdoor=kind=='town'or kind=='route'or kind=='forest'}}or map
 local weather=weatherMap and V.require('Weather').mode(weatherMap)
 return {map=map,kind=kind,x=p.px,z=p.py,grass=grass,
  rain=(kind=='town'or kind=='route'or kind=='forest')and (weather=='rain'or weather=='storm'),
  shop=id:find('MART')~=nil or id:find('POKECENTER')~=nil or tid=='MART'or tid=='POKECENTER'}
end
function M.install(cameraEnabled)
 if M.current then return M.current end
 local audio=M.new();M.current=audio
 V.mod.hooks:wrap('core.update',function(next,game,dt,...)
  local horizon=V.require('KantoFirstPerson');if horizon.bindGame then horizon.bindGame(game)end
  local result=next(game,dt,...)
  local generation=V.require('Generation').number()
  local map,p,enabled
  if generation==3 then
   local native=require('src.core.game3.map');p=require('src.core.game3.player')
   map=V.require('NativeAtmosphere').gen3(native.currentDef(),native.current)
   enabled=game.phase=='field' and not require('src.core.game3.battle').isActive()
  else
   local state=generation==2 and game.world or game.overworld
   map=state and state.map;p=state and state.player
   local top=game.stack and game.stack:top()
   enabled=map and p and (not top or top==state)
  end
  local opts=game.save and game.save.options or {}
  audio:update(M.facts(map,p,generation),dt,math.max(0,math.min(7,tonumber(opts.sfxVol)or 7))/7,
   enabled and cameraEnabled())
  return result
 end)
 V.mod.hooks:wrap('core.quit_to_launcher',function(next,...)
  audio:clear();return next(...)
 end)
 return audio
end
return M
