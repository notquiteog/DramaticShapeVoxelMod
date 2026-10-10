-- Native capture events feed the shared presentation; native CatchSeq still
-- owns every roll, shake, item, timer, party update and return value.
local V=...
local M={}
local pending,arena,ground
function M.settings()
 local p=V.require("PokeballSettings")
 return {p.enabled,p.size,p.captureSpeed,p.openTime,p.preset,p.streamers,p.beam,p.suction,p.pokemonGlow,p.suctionParticles,p.fxScale,p.audio,p.audioVolume}
end
local ballNames={[1]='MASTER_BALL',[2]='ULTRA_BALL',[3]='GREAT_BALL',[4]='POKE_BALL'}
local function call(name,...)
 local loaded,scene=pcall(V.require,'BattleScene')
 if not loaded then M.lastError=tostring(scene);pending=nil;return false end
 local ok,result=pcall(scene[name],...)
 if not ok then M.lastError=tostring(result);pending=nil;pcall(scene.finishNormalBattleBall);return false end
 return result
end
function M.finish()
 if pending then call('finishNormalBattleBall')end
 pending,arena,ground=nil,nil,nil
end
function M.active(st)
 return pending and pending.started and pending.st==st
  and V.require('PokeballSettings').active()and V.require('Gen3Battle').enabled() or false
end
function M.status()return {pending=pending~=nil,started=pending and pending.started,item=pending and pending.item,error=M.lastError}end
function M.install()
 local Seq=require('src.core.game3.battle.catch_seq')
 local Audio=require('src.core.game3.audio')
 local SE=require('src.core.game3.se_ids')
 local begin,reset,sound=Seq.begin,Seq.reset,Audio.playSe
 local function audioEvent(p,event,index)
  local ok,a=pcall(V.require,'EmberLegacyAudio')
  if not ok or not a then return false end
  local good,played=pcall(function()
   a.nativeMaster(p.st,function()return Audio._sfxVolume or 1 end)
   if not a.ready(event,index)then return false end
   return a.capture(event,index)
  end)
  return good and played==true
 end
 Seq.reset=function(...)M.finish();return reset(...)end
 Seq.begin=function(st,item,caught,shakes,opts)
  local result=begin(st,item,caught,shakes,opts)
  opts=opts or{}
  if ballNames[item]and st and st.wild and not(st.double or st.safari or st.oldManTutorial or st.pokedude or st.wally or opts.headless)
    and V.require('PokeballSettings').active()and V.require('Gen3Battle').enabled()then
   pending={st=st,item=ballNames[item],caught=caught,shakes=shakes}
  end
  return result
 end
 Audio.playSe=function(id,...)
  local p=pending;local replaced=false
  if p and V.require('PokeballSettings').active()and V.require('Gen3Battle').enabled()then
   if id==SE.SE_BALL_THROW and not p.started then
    p.started=call('startNormalBall',p.item,p.caught,p.shakes,p.st)==true
    if p.started then replaced=audioEvent(p,'throw')end
   elseif p.started then
    if id==SE.SE_BALL_OPEN then
     if p.opened and not p.caught then
      call('normalBallAnimEvent','SHAKE_ANIM');call('normalBallAnimEvent','SHOWPIC_ANIM');replaced=audioEvent(p,'breakout')
     else p.opened=true;call('normalBallAnimEvent','POOF_ANIM');replaced=audioEvent(p,'open')end
    elseif id==SE.SE_BALL then
     call('normalBallAnimEvent','SHAKE_ANIM');call('normalBallTimedEvent','SFX_TINK')
     p.audioShakes=(p.audioShakes or 0)+1;replaced=audioEvent(p,'shake',p.audioShakes)
    elseif id==SE.SE_BALL_CLICK then
     call('normalBallAnimEvent','SHAKE_ANIM');call('normalBallCaughtEvent');replaced=audioEvent(p,'success')
    end
   end
  elseif p then M.finish()end
  if not replaced then return sound(id,...)end
 end
 return function()Seq.begin,Seq.reset,Audio.playSe=begin,reset,sound;M.finish()end
end
function M.prepare(actors,floor)
 if not M.active(actors.st)then if pending and pending.started then M.finish()end;return end
 local p,e=actors.points[0],actors.points[1]
 if not(p and e)then return end
 ground=floor;arena={player={p[1],p[3]},enemy={e[1],e[3]},mid={(p[1]+e[1])/2,(p[3]+e[3])/2}}
 call('prepareNativeCapture',arena,actors.st,floor)
end
function M.draw(st,shadow)
 if not(M.active(st)and arena)then return end
 if shadow then call('castNativeCapture',shadow)
 else call('drawNativeCapture',arena,st,ground)end
end
return M
