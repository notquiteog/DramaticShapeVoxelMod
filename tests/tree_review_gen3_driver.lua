return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local U=dofile('tests/drivers/util.lua');love.window.setMode(1280,720)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local C=V.require('Gen3Integration')
 local Map=require('src.core.game3.map')
 game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=8,facing='up'}})
 for _,case in ipairs({{'FR_PALLET_TOWN',10,8},{'FR_VIRIDIAN_FOREST',10,20}})do
  assert(Map.load(nil,game,case[1],{x=case[2],y=case[3],facing='up'}));require('src.ui.game3.map_preview_screen').reset()
  for _,view in ipairs({{'overview',3,0,.25},{'first',6,0,.05}})do
   C.setLevel(view[2],game);C.yaw=view[3];C.pitch=view[4];U.wait(65);assert(C.active,case[1])
   U.shot(game,os.getenv('SHOT_DIR')..'/'..case[1]..'-'..view[1]..'.png')
  end
 end
 print('[native trees] Pallet/Viridian overview and first-person captures complete')
 love.event.quit()
end
