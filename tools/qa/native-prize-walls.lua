return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local R=require('src.mods.Runtime');local old=game.update
 game.update=function(self,dt)return R.call('core.update',old,self,dt)end
 local id='FR_CELADON_CITY_GAME_CORNER_PRIZE_ROOM'
 game:_handleBootAction({action='new_game',start={map=id,x=4,y=6,facing='down'}})
 local Space=require('src.core.game3.scripting.space');Space.runOnFrame=function()end
 local vm=Space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('CommunityVisuals');local scene=V.require('Gen3Scene')
 C.prizeRoom:setIndex(2,game);V.require('Gen3Integration').setLevel(3,game);scene.invalidate()
 for i=1,1800 do U.wait(1);if scene.prizeWallCount then break end end;assert(scene.prizeWallCount and scene.prizeWallCount>0,'missing native Prize Room panels')
 print('PRIZE WALLS',id,scene.prizeWallCount)
 U.wait(30);assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/legendary.png'))
 V.require('Gen3Integration').setLevel(6,game);U.wait(70);assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/first-person.png'))
 V.require('Gen3Integration').setLevel(3,game);C.prizeRoom:setIndex(1,game);scene.invalidate();U.wait(70);assert(not scene.prizeWallCount,'OFF retained tunnel kit')
 assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/native.png'))
 print('[PASS native Legendary Prize Room]',id);love.event.quit()
end
