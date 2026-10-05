-- Mirror native Crystal throw/wobble events into the shared 3D capture prop.
-- Native RNG, inventory, result, animation clock and queue remain authoritative.
local V=...
local M={}
local owner,runner
local function scene()return V.require('BattleScene')end
local function call(name,...)
 local ok,result=pcall(scene()[name],...)
 if not ok then
  owner,runner=nil,nil
  pcall(scene().finishNormalBattleBall)
  return false
 end
 return result
end
local function enabled(s)
 local stage=V.require('Gen2Battle')
 return V.require('PokeballSettings').active() and stage.enabled() and stage.sceneOverrideEnabled~=false
  and s and s.battle and s.battle.wild and not s.battle.doubles
  and not s.contest and not s.tutorial
end
function M.finish()
 if owner then call('finishNormalBattleBall')end
 owner,runner=nil,nil
end
function M.install()
 if M.installed then return true end
 local S=require('src.ui.gen2.BattleState')
 local View=require('src.ui.gen2.BattleAnimView')
 if type(S.startBallAnim)~='function'or type(S.pokeballWobble)~='function'then return false end
 local start,wobble,update,present,objects=S.startBallAnim,S.pokeballWobble,S.update,View.present,View.drawObjects
 S.startBallAnim=function(self,param,item,...)
  M.finish()
  local result=start(self,param,item,...)
  -- No animation or no scene means stock presentation retains ownership.
  if not(enabled(self)and self.ballThrow and self.anim and
    V.require('Gen2Battle').stagedMon(self:activeMon('enemy')))then return result end
  local throw=self.ballThrow
  if not call('startNormalBall',item,throw.caught,3,self.battle)then return result end
  owner,runner=self,self.anim
  local sound=runner.hooks and runner.hooks.sound
  if runner.hooks then runner.hooks.sound=function(name,...)
   if owner==self and runner==self.anim and (tostring(name):upper():gsub('_','')=='SFXBALLPOOF'or tostring(name):upper():gsub('_','')=='BALLPOOF')then
    call('normalBallAnimEvent','POOF_ANIM')
   end
   if sound then return sound(name,...)end
  end end
  return result
 end
 S.pokeballWobble=function(self,...)
  local result=wobble(self,...)
  if owner==self and enabled(self)then
   -- Even a zero-wobble breakout has completed intake and closed the ball.
   -- The shared renderer must leave its contact hold before the result.
   call('normalBallAnimEvent','SHAKE_ANIM')
   if result==0 then
    call('normalBallTimedEvent','SFX_TINK')
   elseif result==1 then call('normalBallCaughtEvent')
   elseif result==2 then call('normalBallAnimEvent','SHOWPIC_ANIM')end
  end
  return result
 end
 S.update=function(self,...)
  if owner==self and(not enabled(self)or self.phase=='done'or self.phase=='evolving')then M.finish()end
  return update(self,...)
 end
 View.present=function(self,anim,drawBg,battle,...)
  if owner and runner==anim and enabled(owner)then return drawBg()end
  return present(self,anim,drawBg,battle,...)
 end
 View.drawObjects=function(self,anim,battle,...)
  if owner and runner==anim and enabled(owner)then return end
  return objects(self,anim,battle,...)
 end
 M.installed=true
 return true
end
return M
