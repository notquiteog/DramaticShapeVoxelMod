-- Native GPU regression: retain a complete window, cancel on reversal/warp,
-- and never trade camera control for a partially uploaded scene.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local U=dofile('tests/drivers/util.lua');love.window.setMode(1280,720)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local Scene,C=V.require('Gen3Scene'),V.require('Gen3Integration')
 local Player,Map=require('src.core.game3.player'),require('src.core.game3.map')
 V.require('RenderDistance').setting:sync('auto')
 game:_handleBootAction({action='new_game',start={map='FR_VIRIDIAN_FOREST',x=10,y=20,facing='up'}})
 require('src.ui.game3.map_preview_screen').reset()
 C.setLevel(7,game);C.yaw=.8;C.pitch=.25;U.wait(120)
 local x=Player.px;local bounds=Scene.distance.bounds
 local started,cancelled=Scene.streaming.started,Scene.streaming.cancelled
 Player.px=x+96;U.wait(1)
 assert(Scene.streaming.started>started and Scene.distance.bounds==bounds and C.active,'partial window replaced live terrain')
 Player.px=x;U.wait(2)
 assert(Scene.streaming.cancelled>cancelled and Scene.distance.bounds==bounds and C.active,'reversal failed to cancel')
 Player.px=x+96;U.wait(1)
 local completed=Scene.builds
 for i=1,120 do U.wait(1);assert(C.active,'streaming lost camera');if Scene.builds>completed then break end end
 assert(Scene.builds>completed and Scene.distance.bounds~=bounds,'candidate never published')
 U.shot(game,os.getenv('SHOT_DIR')..'/forest-complete.png')
 Player.px=x+192;U.wait(1)
 cancelled=Scene.streaming.cancelled
 assert(Map.load(nil,game,'FR_OAKS_LAB',{x=5,y=10,facing='up'}))
 require('src.ui.game3.map_preview_screen').reset();C.setLevel(3,game);U.wait(70)
 assert(Scene.streaming.cancelled>cancelled and Scene.sceneDef==Map.currentDef() and C.active,'warp retained forest work')
 U.shot(game,os.getenv('SHOT_DIR')..'/lab-after-cancel.png')
 -- Rebuild invalidation must cancel even after some GPU resources exist.
 assert(Map.load(nil,game,'FR_VIRIDIAN_FOREST',{x=10,y=20,facing='up'}))
 require('src.ui.game3.map_preview_screen').reset();C.setLevel(7,game);U.wait(70)
 Player.px=Player.px+96;U.wait(2);Scene.invalidate();U.wait(30)
 assert(C.active and Scene.sceneDef==Map.currentDef(),'invalidated candidate survived or blocked recovery')
 print('[stream lifecycle] retained/complete windows, reversal, warp, invalidation and camera PASS')
 love.event.quit()
end
