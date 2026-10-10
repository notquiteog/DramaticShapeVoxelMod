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
  require('src.render.Pipelines').setLevel('voxel',4)
 else
  local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
  game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ROUTE_29',role=='host'and 10 or 11,6,'down'))
  require('src.render.Pipelines').setLevel('voxel',4)
 end
 U.wait(200)

 assert(gen==1)
 game.mods.modOptions.double_battles={wild_doubles='always',your_side='pair'}
 local M=require('src.pokemon.Pokemon');game.save.party={M.new(game.data,'PIKACHU',40),M.new(game.data,'PIDGEY',40)}
 game.save.party[1].moves={{id='THUNDERSHOCK',pp=30,maxPp=30}}
 local logic=assert(game.mods.exports.overworld_wild_spawns.logic)
 local record
 for i=1,600 do
  for _,r in pairs(logic.spawns)do local e=logic.entities[r.id]
   if e and not e.hiddenEncounter and not e.wildsAmbientPokemon then record=r;break end
  end
  if record then break end;U.wait(1)
 end
 assert(record,'no visible encounter')
 local species,level=record.species,record.level
 assert(logic:_startBattle(record),'native visible encounter did not queue')
 local screen
 for i=1,1800 do local top=game.stack:top()
  if top and top.kind=='wild'and top.enemy then screen=top;break end
  U.tap(game,'a');U.wait(1)
 end
 assert(screen,'native wild screen missing')
 assert(not screen.__double and not screen.enemy2,'visible encounter was overridden')
 assert(screen.enemy.mon.species==species and screen.enemy.mon.level==level,'visible encounter identity changed')
 assert(U.shot(game,dir..'/owned-encounter.png'))
 print('[PASS visible encounter ownership]',v,species,level)
 love.event.quit()
end
