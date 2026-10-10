return function(game)
 local U=dofile('tests/drivers/util.lua');local role='host';local dir=assert(os.getenv('SHOT_DIR'))
 local GV=require('src.core.GameVersion');local gen,v=GV.generation(),GV.get()
 if gen==3 then
  local prefix=({ruby='RU_',sapphire='SA_',emerald='EM_'})[v]
  game:_handleBootAction({action='new_game',start={map=prefix and prefix..'ROUTE101'or'FR_ROUTE_1',x=role=='host'and 7 or 6,y=8,facing='down'}})
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
 local bag=require('src.core.game3.bag');assert(bag.add(game.session.bag,1,3))
 local opts=game.mods.modOptions.overworld_wild_spawns or{};game.mods.modOptions.overworld_wild_spawns=opts
 opts.overworld_catching=true;opts.catch_throw_key='c';C.ball=1
 local P=require('src.core.game3.player');local Col=require('src.core.game3.collision');local O=require('src.core.game3.objects')
 local chosen
 for i=1,600 do
  for _,r in pairs(S.spawns)do
   local x,y=r.cellX,r.cellY+1
   if not r.ambient and not r.scenery and r.behavior~='hidden'and Col.isWalkable(x,y)and not Col.warpAt(x,y)and not O.blocks(x,y)then chosen=r;break end
  end
  if chosen then break end;U.wait(1)
 end
 if not chosen then local E=require('src.core.game3.encounters');local Map=require('src.core.game3.map');local t=E.tableFor(Map.current);print('[spawn diagnostic]',Map.current,S.map,t and t.land and #t.land.slots);for id,r in pairs(S.spawns)do print('[spawn]',id,r.species,r.cellX,r.cellY,r.ambient,r.behavior)end end
 assert(chosen,'no actual native catchable spawn');chosen.catching=true
 P.reset(chosen.cellX,chosen.cellY+1,'up');U.wait(2)
 local before=#game.session.party;local species=chosen.species
 assert(require('src.mods.Runtime').call('input.key',function()return false end,game,{key='c',phase='pressed',isrepeat=false}))
 U.wait(3);assert(C.projectile and C.projectile.ball==1,'master throw not launched: '..tostring(C.message))
 U.wait(90)
 assert(#game.session.party==before+1,'native capture not stored: '..tostring(C.message))
 assert(game.session.party[#game.session.party].species==species,'wrong species stored')
 assert(bag.get(game.session.bag,1)==2,'capture debited wrong ball count')
 assert(not S.spawns[chosen.id]and not C.projectile,'captured actor/projectile not removed')
 assert(U.shot(game,dir..'/captured.png'))
 print('[PASS standalone native target capture]',v)
 love.event.quit()
end
