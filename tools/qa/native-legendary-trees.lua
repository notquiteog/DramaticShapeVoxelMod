return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local R=require('src.mods.Runtime');local old=game.update
 game.update=function(self,dt)return R.call('core.update',old,self,dt)end
 local version=require('src.core.GameVersion').get();local hoenn=version=='emerald'or version=='ruby'or version=='sapphire'
 game:_handleBootAction({action='new_game',start={map=hoenn and (version=='ruby'and'RU_'or version=='sapphire'and'SA_'or'EM_')..'OLDALE_TOWN'or'FR_PALLET_TOWN',x=8,y=12,facing='up'}})
 local Space=require('src.core.game3.scripting.space');Space.runOnFrame=function()end;local vm=Space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('CommunityVisuals');local scene=V.require('Gen3Scene');local I=V.require('Gen3Integration')
 V.require('TreePresentation').art:setIndex(3,game);C.trees:setIndex(2,game);C.treeDetail:setIndex(2,game);I.setLevel(3,game);scene.invalidate()
 for i=1,1800 do U.wait(1);if(scene.legendaryTreeCount or 0)>0 then break end end
 assert((scene.legendaryTreeCount or 0)>0,'no native mature tree model');print('LEGENDARY TREES',scene.legendaryTreeCount)
 U.wait(90);assert(U.shot(game,os.getenv('SHOT_DIR')..'/legendary.png'))
 I.setLevel(6,game);I.yaw=0;I.pitch=0;U.wait(90);assert(U.shot(game,os.getenv('SHOT_DIR')..'/first-person.png'))
 C.trees:setIndex(1,game);V.require('TreePresentation').changed('communityTrees');I.setLevel(3,game);U.wait(150)
 assert((scene.legendaryTreeCount or 0)==0,'OFF retained shared mature trees');assert(U.shot(game,os.getenv('SHOT_DIR')..'/native.png'))
 print('[PASS native Legendary trees]',version);love.event.quit()
end
