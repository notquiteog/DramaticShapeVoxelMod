return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local R=require('src.mods.Runtime');local old=game.update
 game.update=function(self,dt)return R.call('core.update',old,self,dt)end
 local id=os.getenv('QA_TUNNEL_MAP')or'FR_UNDERGROUND_PATH_NORTH_SOUTH_TUNNEL'
 game:_handleBootAction({action='new_game',start={map=id,x=5,y=6,facing='down'}})
 local Space=require('src.core.game3.scripting.space');Space.runOnFrame=function()end
 local vm=Space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('CommunityVisuals');local scene=V.require('Gen3Scene')
 C.tunnels:setIndex(2,game);V.require('Gen3Integration').setLevel(3,game);scene.invalidate()
 for i=1,1800 do U.wait(1);if scene.tunnelCounts then break end end;assert(scene.tunnelCounts and scene.tunnelCounts.floors>0,'missing native tunnel floor')
 print('TUNNEL',id,scene.tunnelCounts.floors,scene.tunnelCounts.walls)
 U.wait(30);assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/legendary.png'))
 C.tunnels:setIndex(1,game);scene.invalidate();U.wait(70);assert(not scene.tunnelCounts,'OFF retained tunnel kit')
 assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/native.png'))
 print('[PASS native Legendary tunnel]',id);love.event.quit()
end
