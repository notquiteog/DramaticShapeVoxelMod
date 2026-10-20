-- Read original GSC send-out ownership; never change its runner or reveal clock.
local V=...
local M={}
function M.screen(game,battle)
 local s=V.require('Gen2Staged').screenFor(game)
 if not s or (s~=battle and s.battle~=battle) or not s.battle then return nil end
 local stage=V.require('Gen2Battle')
 if not stage.enabled() or stage.sceneOverrideEnabled==false
  or s.phase=='done' or s.phase=='fadeout' or s.phase=='evolving'
  or V.require('Gen2Capture').active(s,s.anim) then return nil end
 if s.battle.doubles then
  local models=V.require('StadiumModels')
  if type(s.nativeAnimationSlot)~='function'or s.legendaryModelRelease or s.battle.legendaryModelRelease
   or models.active()then return nil end
 end
 return s
end
function M.cue(screen,side,battler)
 if not screen or not battler or (side~='player'and side~='player2'and side~='enemy'and side~='enemy2') then return nil end
 -- Wild opponents appear directly; they were never released from a ball.
 if side:match('^enemy') and screen.battle.wild then return nil end
 local after=screen.afterSendOut
 local anim=screen.anim
 if not anim or anim.animId~='ANIM_SEND_OUT_MON' or (anim.param or 0)~=0
  or not after or after.side~=side or after.mon~=battler
  or screen:activeMon(side)~=battler then return nil end
 -- This public event table survives the shiny arm but changes on every send.
 if screen.battle.doubles and screen:nativeAnimationSlot()~=side then return nil end
 return after
end
function M.paired(screen,side,mon)
 if not(screen and screen.battle and screen.battle.doubles
  and V.require('PokeballSettings').active())then return nil end
 local ok,result=pcall(function()
  if not M.screen(V.mod.world.game,screen)then return end
  return M.cue(screen,side,mon)
 end)
 return ok and result or nil
end
-- Native size commands, not a new wall clock, own the paired release beat.
function M.progress(screen,side)
 local p=screen.animPicState and screen:animPicState(side)
 local sizes={[0]=6,[1]=4,[2]=2,[3]=7,[4]=5,[5]=3}
 local size=p and sizes[p.size]
 return size and math.min(1,size/(side:match('^player')and 6 or 7))or 0
end
function M.install()
 if M.installed then return end
 local View=require('src.ui.gen2.BattleAnimView')
 local original=View.drawObjects
 function View:drawObjects(runner,battle,...)
  local s=M.screen(V.mod.world.game,battle)
  local after=s and s.afterSendOut
  local poses=s and (s.legendaryQ57 or battle.legendaryQ57)
  local pose=poses and after and poses[after.side]
  local e=pose and pose.entry
  if s and not s.battle.doubles and V.require('PokeballSettings').active() and s.anim==runner and e and e.q57Used
   and e.nativeCue==after and M.cue(s,after.side,e.battler)==after then return end
  -- Shiny stars, OFF, missing/failed geometry and every unrelated script stay native.
  return original(self,runner,battle,...)
 end
 M.installed=true
end
return M
