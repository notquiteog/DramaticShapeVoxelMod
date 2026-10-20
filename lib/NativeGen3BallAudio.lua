-- Native send-out/withdraw sounds keep their original event timing. Replace
-- only a recognized ball cue after the optional sound has actually played.
local V=...
local M={update=function()end}
local function pack(...)return {n=select('#',...),...}end
function M.install()
 local Audio=require('src.core.game3.audio')
 local SE=require('src.core.game3.se_ids')
 local Anim=require('src.core.game3.battle.anim')
 local Coords=require('src.core.game3.battle.anim_coords')
 local Switch=require('src.core.game3.battle.switch_seq')
 local Intro=require('src.core.game3.battle.intro_seq')
 local Catch=require('src.core.game3.battle.catch_seq')
 local Battle=require('src.core.game3.battle')
 local sound,update=Audio.playSe,Switch.update
 local inSwitch=false;local serial=0;local owner,audio
 local function cue(st)
  -- A withdraw is identified only inside the original sequencer update, at
  -- its current step. Do not infer recall from a generally shrinking actor.
  local step=Switch._st==st and Switch._steps and Switch._steps[Switch._i]
  if inSwitch and step and step.kind=='withdraw'then
   local d=step.data or{};return 'recall',d.id or Coords.idOf(d.side or'player')
  end
  -- The initial allied throw emits its sound just BEFORE setting frame1.
  -- Its native step supplies the same identity without moving that sound.
  if step and(step.kind=='sendout_player'or step.kind=='sendout_enemy')then
   local d=step.data or{};return 'sendout',d.id or(step.kind=='sendout_player'and 0 or 1)
  end
  local intro=Intro._st==st and Intro._steps and Intro._steps[Intro._i]
  if intro and(intro.kind=='player_throw'or intro.kind=='opponent_sendout')then
   local ids=intro.data and intro.data.ids
   return 'sendout',ids or(intro.kind=='player_throw'and 0 or 1)
  end
  local stage=Anim.stage();local ids,seen={},{}
  local function consider(ball,key)
   if ball and ball.visible and ball.frame==1 then
    local id=ball.battler or Coords.idOf(ball.side)or key
    if type(id)~='number'then ids.invalid=true;return end
    if not seen[id]then ids[#ids+1]=id;seen[id]=true end
   end
  end
  consider(stage.ball)
  for key,ball in pairs(stage.balls or{})do consider(ball,key)end
  -- A simultaneous native cue is shared; retain every known variant rather
  -- than choosing the first actor when normal and shiny battlers overlap.
  if #ids>0 and not ids.invalid then return 'sendout',ids end
 end
 local function replace(st,event,id)
  local ids=type(id)=='table'and id or{id};local variants,seen={},{}
  if #ids==0 then return false end
  for _,key in ipairs(ids)do
   local b=Coords.battler(st,key);if not b then return false end
   local variant=event=='sendout'and V.require('BattleArt').isShiny(b)==true or false
   if not seen[variant]then variants[#variants+1]=variant;seen[variant]=true end
  end
  local a=V.require('EmberLegacyAudio')
  a.nativeMaster(st,function()return Audio._sfxVolume or 1 end)
  if not a.sync(st)then return false end
  serial=serial+1
  local played
  if #variants>1 then
   played=type(a.playSendoutGroup)=='function'and a.playSendoutGroup(serial,variants)
  else played=a.play(event,serial,variants[1])end
  if played~=true then return false end
  owner,audio=st,a;return true
 end
 Audio.playSe=function(id,...)
  local st=Battle._st;local stage=V.require('Gen3Battle')
  -- Explicit mixer options belong to their caller; native ball cues use none.
  if id==SE.SE_BALL_OPEN and select(1,...)==nil and st and Battle.isActive()and stage.active and stage.enabled()
    and V.require('PokeballSettings').active()and not Anim._headless and not Catch.busy()then
   local ok,event,battler=pcall(cue,st)
   if ok and event then
    local played,result=pcall(replace,st,event,battler)
    if played and result then return true end
   end
  end
  return sound(id,...)
 end
 Switch.update=function(...)
  local before=inSwitch;inSwitch=true
  local result=pack(pcall(update,...));inSwitch=before
  if not result[1]then error(result[2],0)end
  return unpack(result,2,result.n)
 end
 M.update=function()
  if not owner then return end
  if Battle._st~=owner or not Battle.isActive()or not V.require('Gen3Battle').enabled()then
   pcall(audio.clear);owner,audio=nil,nil
  else
   local ok,active=pcall(audio.sync,owner)
   if not ok or not active then pcall(audio.clear);owner,audio=nil,nil end
  end
 end
 return function()
  Audio.playSe,Switch.update=sound,update;inSwitch=false
  if audio then pcall(audio.clear)end;owner,audio=nil,nil;M.update=function()end
 end
end
return M
