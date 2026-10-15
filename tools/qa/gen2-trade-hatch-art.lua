-- Native scene fixture in a disposable imported profile; never saves progress.
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
 local Mon=require('src.battle.gen2.Mon')
 local given=Mon.new(game.data,'CHIKORITA',5,{dvs={attack=15,defense=15,speed=15,special=15}})
 local received=Mon.new(game.data,'CYNDAQUIL',5,{dvs={attack=2,defense=10,speed=10,special=10}})
 given.otName='SOURCE';given.otId=123;received.otName='RECEIVER';received.otId=456
 local dir=assert(os.getenv('SHOT_DIR'))
 local function capture(s,name)
  local update=s.update;s.update=function()end
  local frame,left,anim=s.frame,s.beatLeft,s.picAnim
  for _,scale in ipairs({'fit','full'})do
   I.scalingSetting:sync(scale);U.wait(1);assert(U.shot(game,dir..'/'..name..'-'..scale..'.png'))
  end
  I.setting:sync('off');U.wait(1);assert(U.shot(game,dir..'/'..name..'-native.png'));I.setting:sync('battle_art')
  assert(s.frame==frame and s.beatLeft==left and s.picAnim==anim,'draw changed native timeline')
  I.scalingSetting:sync('fit');s.update=update
 end
 local Trade=require('src.ui.gen2.TradeAnim')
 local done=0
 local function trade()
  local s=Trade.new(game,{given=given,received=received,onDone=function()done=done+1 end})
  game.stack:clear();game.stack:push(s);return s
 end
 local s=trade();local sawGive,sawGet=false,false
 for _=1,4000 do
  local id=(s.beat or {}).id
  if id=='givemon_hold'and not sawGive then sawGive=true;capture(s,'trade-give')end
  if id=='getmon_hold'and not sawGet then sawGet=true;capture(s,'trade-get')end
  if s.done then break end;U.wait(1)
 end
 print('[trade final]',s.frame,s.beat and s.beat.id,s.done,done,sawGive,sawGet,s.picAnim and 'anim-active')
 assert(s.done and done==1 and sawGive and sawGet,'native trade full sequence')
 assert(s.give.dvs==given.dvs and s.get.dvs==received.dvs and s.get.shiny==received.shiny and s.get.id==456,'trade record identity')
 s=trade();U.tap(game,'b');U.wait(1);assert(s.done and done==2,'native trade B skip')
 local Hatch=require('src.ui.gen2.EggHatchAnim');local hatched=0
 s=Hatch.new(game,{mon=received,onDone=function()hatched=hatched+1 end})
 game.stack:clear();game.stack:push(s)
 assert(not s.showMon);capture(s,'hatch-egg')
 local revealed=false;local animated=false
 for _=1,1200 do
  if s.showMon and not revealed then revealed=true;capture(s,'hatch-reveal')end
  if s.picAnim and not animated then animated=true;capture(s,'hatch-animation')end
  if s.done then break end;U.wait(1)
 end
 assert(s.done and hatched==1 and revealed,'native hatch completion')
 assert(received.species=='CYNDAQUIL' and received.otId==456 and received.dvs.attack==2,'source record unchanged')
 local Box=require('src.ui.gen2.BoxMenu')
 local fixtureSave={party={received,given},currentBox=1}
 s=Box.new(game,{mode='deposit',save=fixtureSave})
 game.stack:clear();game.stack:push(s);capture(s,'box')
 assert(fixtureSave.party[1]==received and #fixtureSave.party==2,'box preview changed storage')
 local Oak=require('src.ui.gen2.OakSpeech')
 s=Oak.new(game,{data={demoSpecies='MARILL'}})
 -- Draw the public native scene without entering the new-game script.
 s.enter=function()end;s.update=function()end
 game.stack:clear();game.stack:push(s)
 s.pic,s.picColors=s.marillPic,s.marillColors
 capture(s,'oak-demo')
 s.picReveal={kind='wipe',t=16,dur=32};s.picFlip=true;capture(s,'oak-wipe')
 s.picReveal={kind='rotate',t=16,dur=32};capture(s,'oak-native-rotation')
 assert(s.pic==s.marillPic and s.picColors==s.marillColors and s.picReveal.t==16,'Oak reveal state changed')
 s.picReveal=nil;s.picFlip=false
 s:applyPic({pic={type='pokemon',id='CYNDAQUIL'}});capture(s,'oak-custom')
 print('[PASS native Box/Oak selected frames, FIT/FULL/OFF and native reveal state]',require('src.core.GameVersion').get())
 print('[PASS native trade/hatch selected frames, FIT/FULL/OFF, timers, completion, skip and identity]',require('src.core.GameVersion').get(),'hatchAnimated',animated)
 love.event.quit()
end
