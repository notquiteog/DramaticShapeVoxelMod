return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local R=require('src.mods.Runtime');local old=game.update
 game.update=function(self,dt)return R.call('core.update',old,self,dt)end
 local version=require('src.core.GameVersion').get();local prefix=({ruby='RU_',sapphire='SA_',emerald='EM_'})[version]
 game:_handleBootAction({action='new_game',start={map=os.getenv('QA_CACHE_MAP')or(prefix and prefix..'OLDALE_TOWN' or 'FR_PALLET_TOWN'),x=7,y=8,facing='down'}})
 local Space=require('src.core.game3.scripting.space');Space.runOnFrame=function()end
 local vm=Space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local cache=V.require('NativeGeometryCache');local scene=V.require('Gen3Scene')
 V.require('RamPrecache').setting:sync('session');V.require('Gen3Integration').setLevel(3,game)
 U.wait(180);assert(cache.stats.misses>0,'no authored models recorded')
 local misses,hits=cache.stats.misses,cache.stats.hits;scene.invalidate();U.wait(90)
 print('CACHESTATS',cache.stats.misses,cache.stats.hits,cache.stats.bytes,scene.builds)
 assert(cache.stats.hits>hits,'scene rebuild did not replay CPU records')
 assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/replayed.png'))
 print('[PASS native scene geometry replay]',version,'builds',misses,'hits',cache.stats.hits,'bytes',cache.stats.bytes)
 love.event.quit()
end
