-- Isolated profile must select spritePack=selected before boot (restart option).
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua')
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 assert(not V.crystalSpritesActive,'fixture requires SELECTED ART at boot')
 love.window.setMode(480,432,{resizable=false,vsync=0})
 print('[renderer]',love.graphics.getRendererInfo())
 game.world.trySceneScript=function()return false end
 game.stack:clear();assert(game.world:setMap('NEW_BARK_TOWN',7,8,'down'));game.world.vm=nil
 require('src.render.Pipelines').setLevel('voxel',0)
 local Interface=V.require('InterfaceSprites')
 local Art=V.require('BattleArt')
 Art.setting:sync('animated');Art.frontAnimationSetting:sync('gen5');Art.backAnimationSetting:sync('gen5')
 Art.duplicateSetting:sync('battle_art')
 Interface.setting:sync('battle_art')
 local Hall=require('src.ui.gen2.HallOfFame')
 local mon={species='PIKACHU',nickname='PIKACHU',level=50,otId=12345,dvs={attack=15,defense=15,speed=15,special=15}}
 local entry={winCount=1,mons={mon}}
 local screen=Hall.new(game,{entry=entry,onDone=function()end})
 game.stack:push(screen)
 -- Freeze just the test screen so source/native and selected pictures share
 -- the same scroll position; production timing is tested separately below.
 local step=screen.update;screen.update=function()end
 local dir=assert(os.getenv('SHOT_DIR'))
 for _,side in ipairs({'front','back'})do
  screen.phase=side=='front'and 'display'or'backpic';screen.scx=0;screen.scy=0
  for _,scale in ipairs({'fit','full'})do
   Interface.setting:sync('battle_art');Interface.scalingSetting:sync(scale)
   local image,color=screen:monPic(mon,side=='back')
   assert(image and color,'selected Hall-of-Fame art missing: '..side)
   local selected=V.require('NativeInterfaceArt').picture(mon,56,side)
   assert(selected and image:getWidth()==56 and image:getHeight()==56,'selected frame block')
   U.wait(2);assert(U.shot(game,dir..'/'..side..'-'..scale..'.png'))
  end
  Interface.setting:sync('off');U.wait(2);assert(U.shot(game,dir..'/'..side..'-native.png'))
 end
 Interface.setting:sync('battle_art');screen.phase='display';screen.timer=120
 screen.update=step;screen:update(1/60)
 assert(screen.timer<120 and screen.entry==entry and entry.mons[1]==mon,'native timing/record ownership changed')
 print('[PASS native Hall-of-Fame selected fronts/backs FIT/FULL/OFF and native timer]',require('src.core.GameVersion').get())
 love.event.quit()
end
