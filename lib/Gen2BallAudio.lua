-- Use the native normal send-out runner's poof. The separate shiny-star arm,
-- cries and capture result jingles retain their original sound ownership.
local V=...
local M={}
local owner,ownerBattle,audio,serial=nil,nil,nil,0
local function pack(...)return {n=select('#',...),...}end
local function staged()
 local stage=V.require('Gen2Battle')
 if not V.require('PokeballSettings').active()or not stage.enabled()or stage.sceneOverrideEnabled==false then return false end
 local shot=V.require('OverworldBattle').shot()
 return shot and shot.canvas~=nil
end
local function current(screen,runner,battle)
 return battle and screen.battle==battle and screen.anim==runner
  and screen.phase~='done'and screen.phase~='fadeout'and screen.phase~='evolving'
end
function M.finish()
 if audio then pcall(audio.clear)end
 owner,ownerBattle,audio=nil,nil,nil
end
function M.install()
 if M.installed then return true end
 local S=require('src.ui.gen2.BattleState')
 if type(S.animForId)~='function'or type(S.update)~='function'or type(S.finishBattle)~='function'then return false end
 local animate,update,finish=S.animForId,S.update,S.finishBattle
 S.animForId=function(self,id,side,param,...)
  local result=pack(animate(self,id,side,param,...))
  local runner,battle=self.anim,self.battle
  if result[1]and id=='ANIM_SEND_OUT_MON'and(param==nil or param==0)and runner and runner.hooks and type(runner.hooks.sound)=='function'then
   local sound=runner.hooks.sound
   local mon=self:activeMon(side)
   runner.hooks.sound=function(name,...)
    local key=tostring(name or''):upper():gsub('_',''):gsub('^SFX','')
    if key=='BALLPOOF'and current(self,runner,battle) and mon and self:activeMon(side)==mon then
     local ok,played=pcall(function()
      if not staged()then return false end
      local a=V.require('EmberLegacyAudio')
      a.nativeMaster(battle,function()
       local game=self.game;local opts=game and(game.options or(game.save and game.save.options))or{}
       return math.max(0,math.min(7,tonumber(opts.sfxVol)or 7))/7
      end)
      if not a.sync(battle)then return false end
      serial=serial+1
      if a.play('sendout',serial,V.require('BattleArt').isShiny(mon))~=true then return false end
      owner,ownerBattle,audio=self,battle,a;return true
     end)
     if ok and played then return end
    end
    return sound(name,...)
   end
  end
  return unpack(result,1,result.n)
 end
 -- Native-only specialty/contest/blocked throws still expose the original
 -- sound runner. They need no substitute ball model to consume optional audio.
 if type(S.startBallAnim)=='function'then
  local start=S.startBallAnim
  S.startBallAnim=function(self,...)
   local result=pack(start(self,...));local runner,battle=self.anim,self.battle
   if runner and runner.hooks and type(runner.hooks.sound)=='function'then
    local sound=runner.hooks.sound;local begun=false;local opened=false;local wobble=0
    runner.hooks.sound=function(name,...)
     local key=tostring(name or''):upper():gsub('_',''):gsub('^SFX','')
     local event,index
     if key=='THROWBALL'then event='throw'
     elseif key=='BALLPOOF'then event=opened and'breakout'or'open';opened=true
     elseif key=='BALLWOBBLE'then wobble=wobble+1;event,index='shake',wobble
     elseif key=='BALLBOUNCE'then event,index='land',1 end
     if event and current(self,runner,battle)then
      local ok,played=pcall(function()
       if not staged()then return false end
       -- The outer 3D adapter owns its supported sequence, including fallback.
       -- Do not retry/suppress its original sound after failed playback.
       local capture=V.require('Gen2Capture')
       if battle.doubles and not(capture and capture.targetReady and capture.targetReady(self))then return false end
       if capture and capture.active and capture.active(self,runner)then return false end
       local a=V.require('EmberLegacyAudio')
       a.nativeMaster(battle,function()
        local game=self.game;local opts=game and(game.options or(game.save and game.save.options))or{}
        return math.max(0,math.min(7,tonumber(opts.sfxVol)or 7))/7
       end)
       if not a.sync(battle)or not a.ready(event,index)then return false end
       if not begun then a.beginCapture(battle);begun=true end
       if a.capture(event,index)~=true then return false end
       owner,ownerBattle,audio=self,battle,a;return true
      end)
      if ok and played then return end
     end
     return sound(name,...)
    end
   end
   return unpack(result,1,result.n)
  end
 end
 S.update=function(self,...)
  if owner==self then
   local ok,active=pcall(function()
    return self.battle==ownerBattle and self.phase~='done'and self.phase~='fadeout'and self.phase~='evolving'and staged()and audio.sync(ownerBattle)
   end)
   if not ok or not active then M.finish()end
  end
  return update(self,...)
 end
 S.finishBattle=function(self,...)
  if owner==self then M.finish()end
  return finish(self,...)
 end
 M.installed=true;return true
end
return M
