return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 assert(require('src.core.GameVersion').get()==os.getenv('POKEPORT_VERSION'))
 local U=dofile('tests/drivers/util.lua');local update=game.update
 game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('VERMILION_CITY',7,15,'up'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('CommunityVisuals')
 require('src.render.Pipelines').setLevel('voxel',4)
 U.wait(100);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 C.buildings:setIndex(2,game);V.require('TreePresentation').changed('vermilionBuildings')
 local M=V.require('NativeGen2Buildings')
 for i=1,1800 do U.wait(1);if(M.lastCount or 0)>0 then break end end
 print('GEN2BUILDINGS',M.lastCount);assert((M.lastCount or 0)>0,'no native Gen2 building replacement')
 U.wait(240);local fingerprint=V.require('VoxelMeshDisk').fingerprint(game.world.map,'body',nil,'terrain');assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/legendary.png'))
 require('src.render.Pipelines').setLevel('voxel',6);U.wait(120);assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/first-person.png'));require('src.render.Pipelines').setLevel('voxel',4)
 C.buildings:setIndex(1,game);V.require('TreePresentation').changed('vermilionBuildings');U.wait(240)
 assert(fingerprint~=V.require('VoxelMeshDisk').fingerprint(game.world.map,'body',nil,'terrain'),'native style cache keys collide')
 assert(M.lastCount==0,'INSTALLED did not restore native models')
 assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/native.png'));print('[PASS native Gen2 buildings]');love.event.quit()
end
