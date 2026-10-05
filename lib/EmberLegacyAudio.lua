-- Ember Legacy by Legend x Solo Dolo. Event-owned sounds; no gameplay clocks.
local V=...
local Settings=V.require('PokeballSettings')
local A={errors={}}
local cache,voices,session={}, {},nil
local owner,style=nil,nil
local serial=0
local nativeMasters=setmetatable({},{__mode='k'})
function A.nativeMaster(battle,read)
 if battle then nativeMasters[battle]=read end
end
local function masterVolume()
 local read=owner and nativeMasters[owner]
 if read then
  local ok,value=pcall(read)
  if ok and tonumber(value)then return math.max(0,math.min(1,value))end
 end
 local options=owner and owner.game and owner.game.save and owner.game.save.options
 return math.max(0,math.min(7,tonumber(options and options.sfxVol)or 7))/7
end
local function release(x) if x and x.release then pcall(x.release,x) end end
local function stop(x) if x and x.stop then pcall(x.stop,x) end end
function A.clear()
  for _,v in ipairs(voices)do stop(v.source);release(v.source)end
  for _,s in pairs(cache)do if s then release(s)end end
  cache,voices,session={}, {},nil;owner,style=nil,nil
end
local function mode()
  return Settings.active() and Settings.audio:get() or 'ORIGINAL'
end
function A.sync(battle)
  local selected=mode()
  if selected~=style or (battle and owner and owner~=battle) then
    local retained=(not battle or battle==owner) and session or nil
    A.clear();session=retained
  end
  style=selected;owner=battle or owner
  for i=#voices,1,-1 do
    local v=voices[i];local ok,playing=pcall(v.source.isPlaying,v.source)
    if not ok or not playing then release(v.source);table.remove(voices,i)
    else
      local master=masterVolume()
      pcall(v.source.setVolume,v.source,(tonumber(Settings.audioVolume:get()) or .75)*master*v.gain)
    end
  end
  return style~='ORIGINAL'
end
local function filename(event,index,shiny,critical)
  local ancient=style=='ANCIENT'
  index=math.max(1,math.floor(tonumber(index) or 1))
  if event=='throw' then return 'poke_ball_throw_'..((index-1)%4+1)..'.ogg' end
  if event=='shake' then
    if critical then return 'poke_ball_shake_critical.ogg' end
    return 'poke_ball_shake_'..(ancient and 'ancient_' or '')..((index-1)%4+1)..'.ogg'
  end
  if event=='land' then return ancient and ('poke_ball_land_ancient_'..((index-1)%2+1)..'.ogg') or 'poke_ball_bounce.ogg' end
  if event=='sendout' then
    return (index%2==0 and 'poke_ball_send_out' or 'poke_ball_sendout')..(shiny and '_shiny' or '')..'.ogg'
  end
  local names={hit='hit',open='open',close='shut',bounce='bounce',breakout='break',success='capture_succeeded',recall='recall',trail='trail'}
  local name=names[event];if not name then return nil end
  if ancient and (event=='open' or event=='close' or event=='bounce' or event=='breakout' or event=='success')then name=name..'_ancient' end
  return 'poke_ball_'..name..'.ogg'
end
local function source(name)
  if not name or not (love and love.audio and love.filesystem)then return nil end
  if cache[name]~=nil then return cache[name] or nil end
  local ok,s=pcall(function()
    local bytes=assert(V.mod:read('assets/legendary/ember-legacy/poke_ball/'..name),'missing audio asset')
    local data=love.filesystem.newFileData(bytes,name)
    local good,value=pcall(love.audio.newSource,data,'static');release(data)
    if not good then error(value)end
    value:setLooping(false);return value
  end)
  cache[name]=ok and s or false
  if not ok then A.errors[name]=tostring(s)end
  return ok and s or nil
end
function A.ready(event,index,shiny,critical)
  if not A.sync() then return false end
  return source(filename(event,index,shiny,critical))~=nil
end
function A.play(event,index,shiny,critical,gain)
  if not A.sync()then return false end
  local cut={open={'trail','throw'},close={'open'},shake={'shake','land','bounce'},
    breakout={'open','shake','trail'},success={'open','shake','trail'},
    sendout={'recall'},recall={'sendout'}}
  for _,old in ipairs(cut[event] or {})do A.stopEvent(old)end
  local name=filename(event,index,shiny,critical)
  local original=source(name);if not original then return false end
  local ok,s=pcall(original.clone,original);if not ok then A.errors[name]=tostring(s);return false end
  local master=masterVolume()
  local played,err=pcall(function()
    s:setVolume((tonumber(Settings.audioVolume:get()) or .75)*master*(gain or 1));s:play()
  end)
  if not played then release(s);A.errors[name]=tostring(err);return false end
  -- Bound overlapping voices even during fast-forward or repeated switches.
  if #voices>=12 then stop(voices[1].source);release(voices[1].source);table.remove(voices,1)end
  voices[#voices+1]={source=s,event=event,gain=gain or 1}
  return true
end
function A.stopEvent(event)
  for i=#voices,1,-1 do if voices[i].event==event then
    stop(voices[i].source);release(voices[i].source);table.remove(voices,i)
  end end
end
function A.beginCapture(battle)
  A.sync(battle);A.stopEvent('trail');serial=serial+1
  session={owner=battle,seen={},serial=serial}
end
function A.critical(value) if session then session.critical=value==true end end
function A.capture(event,index)
  if not session or not A.sync(session.owner) or not session then return false end
  local key=event..':'..tostring(index or 0)
  if session.seen[key]~=nil then return session.seen[key] end
  if event=='open' or event=='success' or event=='breakout' then A.stopEvent('trail')end
  local played=A.play(event,index or session.serial,false,event=='shake' and session.critical,
    event=='trail' and .25 or event=='bounce' and .5 or 1)
  session.seen[key]=played
  if event=="shake" then session.lastShakePlayed=played end
  return played
end
function A.hasCaptureSound(event,index)
  return session and session.seen[event..':'..tostring(index or 0)]==true or false
end

-- All hook targets are from the engine's BattleState/Sound implementation.
-- Preserve event data and non-audio side effects; only mute replaced sounds.
function A.install(BattleState)
  if BattleState.emberLegacyAudioInstalled then return end
  BattleState.emberLegacyAudioInstalled=true
  local function staged(b)
    if not b or not Settings.active()then return false end
    local ok,o=pcall(V.require,'OverworldBattle')
    return ok and o.enabled() and A.sync(b)
  end
  local context
  local ok,Sound=pcall(require,'src.core.Sound')
  if ok and type(Sound.play)=='function' and type(BattleState.updateQueue)=='function' then
    local previous=Sound.play
    Sound.play=function(data,name,...)
      local b=context
      if name=='Ball_Poof' and staged(b) then
        if b._legendaryBallSequence then
          -- Intake verb plays hit/open at the same POOF/HIDEPIC edge.
          if session and session.owner==b and A.ready('open') and A.ready('hit')then return nil end
        else
          local battler=b.enemySendingOut and b.enemy or b.player
          local shiny=V.require('BattleArt').isShiny(battler)
          serial=serial+1
          if A.play('sendout',serial,shiny)then return nil end
        end
      end
      return previous(data,name,...)
    end
    local previousQueue=BattleState.updateQueue
    local function pack(...) return {n=select('#',...),...} end
    BattleState.updateQueue=function(self,...)
      local before=context;context=self
      local result=pack(pcall(previousQueue,self,...));context=before
      if not result[1]then error(result[2],0)end
      return unpack(result,2,result.n)
    end
  end
  if type(BattleState.playAnimSound)=='function' then
    local previous=BattleState.playAnimSound
    BattleState.playAnimSound=function(self,soundMove,...)
      if staged(self) and self._legendaryBallSequence and session and session.owner==self then
        local events={TOSS_ANIM='throw',GREATTOSS_ANIM='throw',ULTRATOSS_ANIM='throw',
          POOF_ANIM='open',HIDEPIC_ANIM='open',SHOWPIC_ANIM='breakout',SHAKE_ANIM='shake'}
        local event=events[self.animName]
        if event and A.ready(event)then return end
      end
      return previous(self,soundMove,...)
    end
  end
  if type(BattleState.applyAnimEffect)=='function' then
    local previous=BattleState.applyAnimEffect
    BattleState.applyAnimEffect=function(self,ev,...)
      if staged(self) and self._legendaryBallSequence and type(ev)=='table'
          and ev.effect=='SFX_TINK' and session and session.owner==self
          and session.lastShakePlayed then
        local copy={};for k,v in pairs(ev)do copy[k]=v end;copy.effect=nil
        return previous(self,copy,...)
      end
      return previous(self,ev,...)
    end
  end
  if type(BattleState.updateFx)=='function' then
    local previous=BattleState.updateFx
    BattleState.updateFx=function(self,...)
      if staged(self) then
        local retreat=self.shrinkOut
        if retreat and retreat.battler and retreat~=self._emberLegacyRecall then
          self._emberLegacyRecall=retreat;A.play('recall')
        elseif not retreat then self._emberLegacyRecall=nil end
      else A.clear() end
      return previous(self,...)
    end
  end
end
return A
