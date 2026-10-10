return function(game)
 local U=dofile('tests/drivers/util.lua');assert(love.filesystem.getIdentity():match('%-qa$'))
 local version=require('src.core.GameVersion').get();local prefix=version=='ruby'and'RU_'or'SA_';local id=prefix..'OLDALE_TOWN'
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=id,x=6,y=10,facing='down'}})
 require('src.ui.game3.map_preview_screen').reset()
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end
 local exports=game.mods.exports
 for _,name in ipairs{'BATTLE_ART_VOXEL_FORK','DRAMATIC_SKY_RIDE','MODERN_POKEMON_UI','double_battles','gen1online-plus','overworld_wild_spawns','wild_skies'}do assert(exports[name],name..' not loaded')end
 local sky=exports.wild_skies;local wild=exports.overworld_wild_spawns
 local Map=require('src.core.game3.map');local P=require('src.core.game3.pokemon')
 local pool=sky.nativeSkyEcology.pool(id,Map.currentDef(),12);assert(P.keyName(pool[1].species)=='TAILLOW','wrong regional sky')
 local V=exports.BATTLE_ART_VOXEL_FORK.lib;V.require('Gen3Integration').setLevel(3,game)
 U.wait(200)
 local snapshot=sky.sharedSkyFieldSnapshot(id);assert(snapshot and #snapshot.spawns>0,'no flying roster')
 local map,rows=wild.sharedSpawns.snapshot();local ambient=0
 for _,r in ipairs(rows)do if r.ambient then ambient=ambient+1;assert(P.keyName(r.species)=='ZIGZAGOON','wrong regional ambient resident')end end
 assert(ambient>0,'no native ambient residents')
 -- A guest must not generate either domain before host data arrives.
 sky.registerSharedSkyProvider('qa',{role='guest',localAuthority=false,requestClaim=function()end})
 wild.sharedSpawns.configure({role='guest',session='qa',request=function()end})
 U.wait(60)
 assert(#sky.sharedSkyFieldSnapshot(id).spawns==0,'guest invented flying roster')
 local _,empty=wild.sharedSpawns.snapshot();assert(#empty==0,'guest invented ground roster')
 assert(sky.applySharedSkyFieldSnapshot(snapshot));wild.sharedSpawns.apply(map,rows);U.wait(10)
 assert(#sky.sharedSkyFieldSnapshot(id).spawns==#snapshot.spawns,'host flying snapshot lost')
 local _,restored=wild.sharedSpawns.snapshot();assert(#restored==#rows,'host ground snapshot lost')
 U.shot(game,os.getenv('SHOT_DIR')..'/replica.png')
 print('[PASS native RSE imports, seven modules, regional residents and guest authority]',version,ambient,#snapshot.spawns,#restored)
 love.event.quit()
end
