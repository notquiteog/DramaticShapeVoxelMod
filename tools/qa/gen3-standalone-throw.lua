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
 local ex=assert(game.mods.exports.overworld_wild_spawns);local C=assert(ex.gen3Catching);local S=ex.gen3
 local bag=require('src.core.game3.bag');assert(bag.add(game.session.bag,3,5))
 local opts=game.mods.modOptions.overworld_wild_spawns or{};game.mods.modOptions.overworld_wild_spawns=opts
 opts.overworld_catching=true;opts.catch_throw_key='c';C.ball=3
 local P=require('src.core.game3.player');local Col=require('src.core.game3.collision');local O=require('src.core.game3.objects')
 local found
 for y=5,15 do for x=4,14 do
  if not found then
   local good=true;for dy=0,2 do
    if not Col.isWalkable(x,y+dy)or Col.warpAt(x,y+dy)or O.blocks(x,y+dy)then good=false end
    for _,r in pairs(S.spawns)do if r.cellX==x and r.cellY==y+dy then good=false end end
   end
   if good then P.reset(x,y,'down');found=true end
  end
 end end
 assert(found,'no clear native throw lane');U.wait(2)
 local before=bag.get(game.session.bag,3)
 local taken=require('src.mods.Runtime').call('input.key',function()return false end,game,{key='c',phase='pressed',isrepeat=false})
 assert(taken,'bound key not owned');U.wait(3)
 assert(C.projectile and C.projectile.ball==3,'selected GREAT ball was not thrown: '..tostring(C.message))
 assert(bag.get(game.session.bag,3)==before-1,'native inventory not debited exactly once')
 assert(U.shot(game,dir..'/throw.png'));U.wait(60)
 assert(not C.projectile,'projectile did not clean up')
 print('[PASS standalone bound selected throw]',v)
 love.event.quit()
end
