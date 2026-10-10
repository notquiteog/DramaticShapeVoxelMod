return function(game)
 local U=dofile('tests/drivers/util.lua');local role=assert(os.getenv('QA_ROLE'));local dir=assert(os.getenv('SHOT_DIR'))
 local GV=require('src.core.GameVersion');local gen,v=GV.generation(),GV.get()
 if gen==3 then
  local prefix=({ruby='RU_',sapphire='SA_',emerald='EM_'})[v]
  game:_handleBootAction({action='new_game',start={map=prefix and prefix..'OLDALE_TOWN'or'FR_PALLET_TOWN',x=role=='host'and 7 or 6,y=8,facing='down'}})
  local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
  local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
  game.mods.exports.BATTLE_ART_VOXEL_FORK.lib.require('Gen3Integration').setLevel(3,game)
 elseif gen==1 then
  game:startNewGame({intro=false});game.overworld:setMap('ROUTE_1',role=='host'and 10 or 11,6,'down')
  if game.mods.exports.BATTLE_ART_VOXEL_FORK then require('src.render.Pipelines').setLevel('voxel',4)else require('src.render.Pipelines').setLevel('voxel',0)end
 else
  local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
  game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ROUTE_29',role=='host'and 10 or 11,6,'down'))
  if game.mods.exports.BATTLE_ART_VOXEL_FORK then require('src.render.Pipelines').setLevel('voxel',4)else require('src.render.Pipelines').setLevel('voxel',0)end
 end
 U.wait(200)
 local ride=assert(game.mods.exports.DRAMATIC_SKY_RIDE)
 local M=require(gen==2 and 'src.battle.gen2.Mon' or 'src.pokemon.Pokemon')
 game.save.party={M.new(game.data,'CHARIZARD',40)}
 if role=='host'then
  local o=game.mods.modOptions.DRAMATIC_SKY_RIDE or {};game.mods.modOptions.DRAMATIC_SKY_RIDE=o
  o.require_fly_move=false;o.badge_checks=false;o.story_gates=false
  game:keypressed('h','h',false);U.wait(90)
  assert(ride.isFlying(),'bound flight shortcut refused')
  local pose=assert(ride.networkPose());assert(pose.mode=='fly'and pose.species=='CHARIZARD')
  assert(pose.height>0,'flight did not rise')
  assert(U.shot(game,dir..'/flight.png'))
  assert(ride.requestLanding());for i=1,300 do if not ride.isFlying()then break end;U.wait(1)end
  assert(not ride.isFlying(),'flight did not land')
  game.save.party={M.new(game.data,'RAPIDASH',40)}
  assert(ride.requestGroundMount(game.save.party[1]),'owned ground mount unavailable');U.wait(30)
  assert(U.shot(game,dir..'/ground.png'));assert(ride.requestGroundDismount())
  print('[PASS standalone GB owned mounts]',v)
  love.event.quit()
 end
end
