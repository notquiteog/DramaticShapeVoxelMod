-- Disposable profile, spritePack=selected before boot; no player save writes.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua')
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 assert(not V.crystalSpritesActive,'SELECTED ART must be set before boot')
 love.window.setMode(480,432,{vsync=0})
 print('[renderer]',love.graphics.getRendererInfo())
 game.world.trySceneScript=function()return false end
 game.stack:clear();assert(game.world:setMap('NEW_BARK_TOWN',7,8,'down'));game.world.vm=nil
 require('src.render.Pipelines').setLevel('voxel',0)
 local I=V.require('InterfaceSprites');local Art=V.require('BattleArt')
 I.setting:sync('battle_art');I.scalingSetting:sync('fit')
 Art.setting:sync('animated');Art.frontAnimationSetting:sync('gen5');Art.duplicateSetting:sync('battle_art')
 local Screen=require('src.ui.gen2.EvolutionAnim')
 local Mon=require('src.battle.gen2.Mon')
 local original=Mon.new(game.data,'CYNDAQUIL',16,{dvs={attack=2,defense=10,speed=10,special=10}})
 local party={original};local done
 local function make()
  done=nil
  local s=Screen.new(game,{mon=original,party=party,index=1,entry={method='level',into='QUILAVA'},onDone=function(result)done=result end})
  game.stack:push(s);return s
 end
 local s=make()
 for _=1,600 do if s.phase=='flash'then break end;U.wait(1)end
 assert(s.phase=='flash'and s.blackout,'native flash not reached')
 local update,timer,shown=s.update,s.timer,s.showNew
 s.update=function()end
 local dir=assert(os.getenv('SHOT_DIR'))
 for _,target in ipairs({false,true})do
  s.showNew=target
  for _,scale in ipairs({'fit','full'})do
   I.scalingSetting:sync(scale)
   assert(V.require('NativeInterfaceArt').picture({species=target and 'QUILAVA'or'CYNDAQUIL',shiny=original.shiny,dvs=original.dvs},56),'fixture selected art missing')
   U.wait(1);assert(U.shot(game,dir..'/'..(target and 'target-'or'source-')..scale..'-silhouette.png'))
  end
 end
 assert(s.timer==timer and party[1]==original and original.species=='CYNDAQUIL','draw mutated native evolution')
 s.showNew=shown;s.update=update;I.scalingSetting:sync('fit')
 U.tap(game,'b')
 for _=1,600 do if done then break end;U.tap(game,'a');U.wait(1)end
 assert(done and done.canceled and party[1]==original,'native cancellation changed')
 s=make();local reveal=false
 for _=1,1500 do
  if s.phase=='reveal'and not reveal then
   reveal=true;local step=s.update;s.update=function()end
   assert(not s.blackout and s.showNew,'native reveal flags')
   U.wait(1);assert(U.shot(game,dir..'/selected-reveal.png'))
   I.setting:sync('off');U.wait(1);assert(U.shot(game,dir..'/native-reveal.png'));I.setting:sync('battle_art')
   s.update=step
  end
  if done then break end
  if s.phase=='congrats'or s.phase=='learn'or s.phase=='waitingLearn'then U.tap(game,'a')else U.wait(1)end
 end
 assert(done and not done.canceled and party[1].species=='QUILAVA'and reveal,'native completion changed')
 assert(party[1].shiny==original.shiny and party[1].dvs.attack==original.dvs.attack,'native shiny/DVs changed')
 print('[PASS native selected evolution silhouette, reveal, cancel, completion and DVs]',require('src.core.GameVersion').get())
 love.event.quit()
end
