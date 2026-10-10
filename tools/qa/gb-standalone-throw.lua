return function(game)
 local U=dofile('tests/drivers/util.lua');local role='host';local dir=assert(os.getenv('SHOT_DIR'))
 local GV=require('src.core.GameVersion');local gen,v=GV.generation(),GV.get()
 if gen==3 then
  local prefix=({ruby='RU_',sapphire='SA_',emerald='EM_'})[v]
  game:_handleBootAction({action='new_game',start={map=prefix and prefix..'OLDALE_TOWN'or'FR_PALLET_TOWN',x=role=='host'and 7 or 6,y=8,facing='down'}})
  local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
  local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
  if game.mods.exports.BATTLE_ART_VOXEL_FORK then game.mods.exports.BATTLE_ART_VOXEL_FORK.lib.require('Gen3Integration').setLevel(3,game)end
 elseif gen==1 then
  game:startNewGame({intro=false});game.overworld:setMap('ROUTE_1',role=='host'and 10 or 11,6,'down')
  if game.mods.exports.BATTLE_ART_VOXEL_FORK then require('src.render.Pipelines').setLevel('voxel',4)end
 else
  local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
  game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ROUTE_29',role=='host'and 10 or 11,6,'down'))
  if game.mods.exports.BATTLE_ART_VOXEL_FORK then require('src.render.Pipelines').setLevel('voxel',4)end
 end
 U.wait(200)
 local target=assert(os.getenv('QA_MOD'));local found=false
 for _,m in ipairs(game.mods.loaded)do
  assert(m.manifest.id==target,'unexpected companion loaded: '..m.manifest.id);found=true
 end
 assert(found,'target mod did not load: '..target)
 U.wait(40)
 local ex=assert(game.mods.exports.overworld_wild_spawns);local C=assert(ex.catching)
 game.save.inventory=game.save.inventory or{};game.save.inventory.GREAT_BALL=5
 local opts=game.mods.modOptions.overworld_wild_spawns or{};game.mods.modOptions.overworld_wild_spawns=opts
 opts.overworld_catching=true;opts.catch_throw_key='c';C.selectedBallIndex=2
 local ow=game.world or game.overworld
 local block=C:_catchBlocker(game,ow);assert(not block,block)
 local taken=require('src.mods.Runtime').call('input.key',function()return false end,game,{key='c',phase='pressed',isrepeat=false})
 assert(taken,'bound key not owned');U.wait(3)
 assert(C.projectile.active and C.projectile.active.ballType=='GREAT_BALL','selected GREAT ball was not thrown: '..tostring(C.phase))
 assert(game.save.inventory.GREAT_BALL==4,'native inventory not debited exactly once')
 assert(U.shot(game,dir..'/throw.png'));U.wait(90)
 assert(not C.projectile:isBusy(),'projectile did not clean up')
 print('[PASS standalone bound selected throw]',v)
 love.event.quit()
end
