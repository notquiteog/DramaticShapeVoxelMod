-- Native cave ambience shares the Legendary setting and optional sound assets.
-- The engine keeps music, encounters and movement; no audio callback is replaced.
local V=...
local M={}
local volumes={low=.35,mid=.62}
function M.new()
 local self={sources={},errors={},volume=0}
 function self:source(name,loop)
  if self.sources[name]~=nil then return self.sources[name]or nil end
  local ok,result=pcall(function()
   local bytes=assert(V.mod:read('assets/legendary/'..name),'optional cave sound absent')
   local data=love.filesystem.newFileData(bytes,name)
   local source=love.audio.newSource(data,loop and 'stream' or 'static')
   source:setLooping(loop);source:setVolume(0);return source
  end)
  self.sources[name]=ok and result or false
  if not ok then self.errors[name]=tostring(result)end
  return ok and result or nil
 end
 function self:update(dt,map,x,y,enabled,master)
  dt=math.max(0,math.min(tonumber(dt)or 0,.25))
  local sound=V.require('CommunityVisuals').caveSoundLevel()
  local active=enabled and V.require('NativeAtmosphere').kind(map)=='cave' and volumes[sound]~=nil
  master=math.max(0,math.min(1,tonumber(master)or 1))
  local target=active and volumes[sound]*master or 0
  if self.volume<target then self.volume=math.min(target,self.volume+.30*dt)
  else self.volume=math.max(target,self.volume-.55*dt)end
  local bed=self.sources['amb-cave.mp3']
  if target>0 then bed=self:source('amb-cave.mp3',true)end
  if bed then
   bed:setVolume(self.volume)
   if self.volume>.004 then if not bed:isPlaying()then bed:play()end else bed:stop()end
  end
  -- Native Gen2/3 cells are 16 pixels. Teleports and first entry are not steps.
  local cx,cy=math.floor((x or 0)/16),math.floor((y or 0)/16)
  if active and target>0 and self.map==map and self.x and
     math.abs(cx-self.x)+math.abs(cy-self.y)==1 then
   local step=self:source('sfx-cavestep.mp3',false)
   if step then
    self.flip=not self.flip;step:stop();step:setPitch(self.flip and .96 or 1.04)
    step:setVolume(.82*master);step:play()
   end
  end
  self.map,self.x,self.y=active and map or nil,cx,cy
 end
 function self:clear()
  for _,s in pairs(self.sources)do if s then s:stop();s:release()end end
  self.sources={};self.volume=0;self.map=nil
 end
 return self
end
function M.install(gen,cameraEnabled)
 local audio=M.new();M.current=audio
 V.mod.hooks:wrap('core.update',function(next,game,dt,...)
  local result=next(game,dt,...)
  local map,x,y,enabled
  if gen==3 then
   local Map=require('src.core.game3.map');local P=require('src.core.game3.player')
   map=V.require('NativeAtmosphere').gen3(Map.currentDef(),Map.current)
   x,y=P.px,P.py
   enabled=game.phase=='field' and not require('src.core.game3.battle').isActive()
  else
   local w=game.world;map=w and w.map
   local p=w and w.player;x,y=p and p.px,p and p.py
   local top=game.stack and game.stack:top()
   enabled=game.phase=='play' and not top and map~=nil
  end
  local opts=game.save and game.save.options or {}
  audio:update(dt,map,x,y,enabled and cameraEnabled(),math.max(0,math.min(7,tonumber(opts.sfxVol)or 7))/7)
  return result
 end)
 V.mod.hooks:wrap('core.quit_to_launcher',function(next,...)
  audio:clear();return next(...)
 end)
 return audio
end
return M
