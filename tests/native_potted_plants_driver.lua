return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');love.window.setMode(1280,720)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local dir=assert(os.getenv('SHOT_DIR'))
 if game.mods.exports.BATTLE_ART_VOXEL_FORK.firered then
  game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=9,facing='down'}})
  local Map=require('src.core.game3.map');local Player=require('src.core.game3.player')
  local C=game.mods.exports.BATTLE_ART_VOXEL_FORK.firered.camera
  Map.load(nil,game,'FR_SILPH_CO_11F',{x=7,y=10,facing='up'})
  Player.reset(7,10,'up');C.setLevel(6,game);C.yaw=0;C.pitch=.27;U.wait(180)
  U.shot(game,dir..'/office-front.png')
  Player.reset(5,8,'right');C.yaw=math.pi*.5;C.pitch=.27;U.wait(30)
  U.shot(game,dir..'/office-side.png')
 else
  local w=game.world;w.noWildEncounters=true;w.trySceneScript=function()return false end
  w:setMap('BILLS_FAMILYS_HOUSE',2,7,'down');game.stack:clear();w.textbox=nil;w.stayedTextBox=nil;w.vm=nil
  local P=require('src.render.Pipelines');local F=V.require('FirstPerson')
  P.setLevel('voxel',6);U.wait(180)
  for i=0,3 do F.yaw=i*math.pi*.5;F.pitch=.35;U.wait(20);U.shot(game,dir..'/house-'..i..'.png')end
 end
 local style=V.require('TreePresentation')
 local old=style.props:get();style.props:sync('cards');style.changed('sceneryProps');U.wait(100)
 U.shot(game,dir..'/native-cards.png')
 style.props:sync(old);style.changed('sceneryProps')
 print('[plant review] rendered native models and optional cards');love.event.quit()
end
