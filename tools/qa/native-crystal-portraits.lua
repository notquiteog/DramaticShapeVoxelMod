-- Disposable profiles only. Native screens draw; fixture controls setup, not saves.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua')
 local version=require('src.core.GameVersion').get()
 love.window.setMode(480,320,{vsync=0})
 local update=game.update
 game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local map=({ruby='RU_LITTLEROOT_TOWN',sapphire='SA_LITTLEROOT_TOWN',emerald='EM_LITTLEROOT_TOWN'})[version]or'FR_PALLET_TOWN'
 game:_handleBootAction({action='new_game',start={map=map,x=7,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end
 require('src.ui.game3.message').reset();U.wait(90)
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 V.require('Gen3Integration').setLevel(0,game)
 local C=V.require('NativeCrystalArt');local P=V.require('NativeCrystalPortraits')
 local bucket=game.mods.modOptions.BATTLE_ART_VOXEL_FORK
 local old={pack=C.pack:get(),mode=bucket.crystalTrainers,player=bucket.crystalPlayerSprite,view=bucket.crystalBattlePic}
 bucket.crystalTrainers='player';bucket.crystalPlayerSprite='kris_flip.png';bucket.crystalBattlePic='back';C.pack:sync('crystal')
 local selected=assert(P.picture(),'selected front portrait unavailable')
 local graphics=love.graphics;local draw=graphics.draw;local hits=0
 graphics.draw=function(image,...)if image==selected then hits=hits+1 end;return draw(image,...)end
 local dir=assert(os.getenv('SHOT_DIR'))
 local function shot(name,want)
  hits=0;U.wait(2);assert(U.shot(game,dir..'/'..name..'.png'))
  print('[portrait draw]',name,hits,C.active(),C.pack:get(),bucket.crystalTrainers)
  assert((hits>0)==want,name..': selected portrait ownership mismatch')
 end
 local RS=version=='ruby'or version=='sapphire'
 local Card=require(RS and'src.ui.game3.rs.trainer_card'or'src.ui.game3.trainer_card')
 Card.show({session=game.session});U.wait(60);assert(Card.isOpen(),'native card did not stay open')
 assert(Card._session==require('src.core.game3.runtime').getSession(),'local card session seam')
 local card=Card._card;shot('card-selected',true)
 C.pack:sync('selected');shot('card-native',false);C.pack:sync('crystal')
 if RS then Card._link=true;shot('card-peer-fallback',false);Card._link=false end
 U.tap(game,'a');U.wait(90);assert(Card.side=='back','native card flip failed');shot('card-back',false)
 assert(Card._card==card,'draw replaced native card record')
 U.tap(game,'b');U.wait(90)
 if not RS then
  assert(Card.side=='front','native card flip back failed')
  U.tap(game,'b');U.wait(60)
 end
 assert(not Card.isOpen(),'native card close failed')
 local Hall=require('src.ui.game3.hall_of_fame')
 Hall.start({session=game.session,dontSave=true,warp=false});U.wait(90)
 Hall._phase='playerpic';Hall.update(1/60);assert(Hall._player,'native Hall of Fame player phase')
 local hallUpdate=Hall.update;Hall.update=function()end
 local hallPlayer=Hall._player;local hallX=hallPlayer.x
 shot('hall-selected',true);C.pack:sync('selected');shot('hall-native',false);C.pack:sync('crystal')
 assert(Hall._player==hallPlayer and hallPlayer.x==hallX,'Hall of Fame draw changed slide state')
 Hall.update=hallUpdate;Hall.close()
 local Stack=require('src.ui.game3.stack');local scene,player,original,frame
 if RS or version=='emerald'then
  local Birch=require(RS and'src.ui.game3.rs.birch_speech'or'src.ui.game3.rse.birch_speech')
  scene=Birch.new({textSpeed=1});scene.bgVisible=true
  player=scene.sprites.may;player.invisible=false;player.x=120;player.y=60
  original,frame=player.img,player.frame
 else
  local assets=require('src.ui.game3.boot').new(game).assets
  scene=require('src.ui.game3.new_game_scene').new(assets,{textSpeed=1})
  scene:loadTrainerPic('female');scene.bgVisible[2]=true;scene.backdrop={31,31,31}
  original=scene.pic.image
 end
 Stack.push('portrait-fixture',{draw=function()scene:draw()end},{hideBelow=true,fullscreen=true})
 shot('intro-selected',true)
 C.pack:sync('selected');shot('intro-native',false);C.pack:sync('crystal')
 if player then
  player.scale=.65;player.blend=true;scene.bld.eva=8
 else
  scene.bg2Affine={pa=384,pd=384};scene.bld={pic=true};scene.bldAlpha={eva=8,evb=8}
 end
 shot('intro-native-transform',true)
 if player then assert(player.img==original and player.frame==frame and player.scale==.65,'draw changed native intro sprite state')
 else assert(scene.pic.image==original and scene.bg2Affine.pa==384,'draw changed native intro picture state')end
 bucket.crystalTrainers='none';shot('intro-mode-off',false)
 Stack.pop('portrait-fixture');graphics.draw=draw
 C.pack:sync(old.pack);bucket.crystalTrainers=old.mode;bucket.crystalPlayerSprite=old.player;bucket.crystalBattlePic=old.view
 print('[PASS native Crystal player portraits]',version,'card/flip/close/front-only/intro-transform/fallback')
 love.event.quit()
end
