return function(game)
 local U=dofile('tests/drivers/util.lua')
 assert(love.filesystem.getIdentity()=='firered-hd2d-qa')
 love.window.setMode(2560,1440,{resizable=true})
 game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=17,y=15,facing='up'}})
 local export=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK)
 local C,V=export.firered.camera,export.lib
 C.setLevel(3,game);U.wait(240)
 local Scene=V.require('Gen3Scene')
 assert(C.active and Scene.chimneyCount==1,'Oak lab chimney not assembled')
 assert(Scene.renderWidth>=2400 and Scene.renderHeight>=1300,'1440p scene downsampled')
 local dir=assert(os.getenv('SHOT_DIR'))
 assert(U.shot(game,dir..'/oak_lab_static.png'))
 for _,level in ipairs({7,6})do
  C.setLevel(level,game)
  for i,yaw in ipairs({0,.7,-.7,math.pi})do
   C.yaw=yaw;U.wait(15);assert(C.active)
   assert(U.shot(game,dir..'/oak_lab_'..level..'_'..i..'.png'))
  end
 end
 -- Place the camera north of the lab, outside its collision footprint.
 local Player=require('src.core.game3.player')
 local Collision=require('src.core.game3.collision')
 assert(Collision.isWalkable(17,8),'rear camera position is not walkable')
 Player.reset(17,8,'down');C.setLevel(7,game)
 for i,yaw in ipairs({math.pi,math.pi+.65,math.pi-.65})do
  C.yaw=yaw;U.wait(20)
  assert(U.shot(game,dir..'/oak_lab_rear_'..i..'.png'))
 end
 print('[FireRed roofs] PASS 1440p flat lab/chimney, gables, static and eight free-camera views')
 love.event.quit()
end
