return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local U=dofile('tests/drivers/util.lua');love.window.setMode(640,360,{vsync=0})
 game:_handleBootAction({action='new_game',start={map='FR_OAKS_LAB',x=6,y=6,facing='up'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 V.require('Gen3Integration').setLevel(4,game);V.require('Shadows').setting:sync('off')
 V.require('AntiAlias').setting:sync(0)
 V.require('LegendaryVisualsPreset').setting:setIndex(2,game)
 local Items=V.require('ItemPokeballs');local Native=V.require('NativeItemPokeballs')
 local draw=Native.draw;local modeled=0
 Native.draw=function(...)local used=draw(...);if used then modeled=modeled+1 end;return used end
 Items.setting:setIndex(2,game);U.wait(60);assert(modeled>0,'live item models not drawn')
 assert(U.shot(game,os.getenv('SHOT_DIR')..'/legendary.png'))
 Items.setting:setIndex(1,game);modeled=0;U.wait(20);assert(modeled==0,'sprite setting still claims item model')
 assert(U.shot(game,os.getenv('SHOT_DIR')..'/native.png'))
 Native.draw=draw;print('[native item models] live draw and default fallback PASS');love.event.quit()
end
