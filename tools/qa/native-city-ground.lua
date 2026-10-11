return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local R=require('src.mods.Runtime');local old=game.update
 game.update=function(self,dt)return R.call('core.update',old,self,dt)end
 local id=os.getenv('QA_CITY_MAP')or'FR_LAVENDER_TOWN'
 game:_handleBootAction({action='new_game',start={map=id,x=7,y=10,facing='down'}})
 local Space=require('src.core.game3.scripting.space');Space.runOnFrame=function()end
 local vm=Space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('CommunityVisuals');local scene=V.require('Gen3Scene')
 C.cityGround:setIndex(2,game);V.require('Gen3Integration').setLevel(3,game);V.require('TreePresentation').changed('communityCityGround')
 for i=1,1800 do U.wait(1);if scene.cityGroundCount then break end end
 assert(scene.cityGroundCount and scene.cityGroundCount>0,'missing native city turf')
 U.wait(30);assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/legendary.png'))
 print('CITYGROUND',id,scene.cityGroundCount)
 C.cityGround:setIndex(1,game);V.require('TreePresentation').changed('communityCityGround');U.wait(120)
 assert(not scene.cityGroundCount,'OFF retained city turf')
 assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/native.png'))
 print('[PASS native city turf]',id);love.event.quit()
end
