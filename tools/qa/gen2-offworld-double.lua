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

 assert(gen<3)
 require('src.render.Pipelines').setLevel('voxel',0)
 game.mods.exports.BATTLE_ART_VOXEL_FORK.lib.require('OverworldBattle').setting:setIndex(os.getenv('QA_STAGE')=='off' and 2 or 1,game)
 game.save.options.battleBg='white'
 game.mods.modOptions.MODERN_POKEMON_UI={modernBattleUI=false,modernInterfaceUI=false}
 game.mods.modOptions.overworld_wild_spawns={enabled=false,random_encounters=true}
 local M=require(gen==2 and 'src.battle.gen2.Mon'or'src.pokemon.Pokemon')
 game.save.party={M.new(game.data,'PIKACHU',40),M.new(game.data,'PIDGEY',40)}
 for _,m in ipairs(game.save.party)do m.moves={{id='TACKLE',pp=35,maxPp=35}}end
 game.mods.modOptions.double_battles={wild_doubles='always',your_side='pair',gen2_doubles=true}
 local w=game.world or game.overworld;local p=w.player;local x,y
 for cy=0,w.map.def.height*2-1 do for cx=0,w.map.def.width*2-1 do
  local grass=gen==1 and w.map:isGrassCell(cx,cy)
  if gen==2 then local F=require('src.world.gen2.FieldMoves');local c=w.map:cellCollision(cx,cy);grass=F.canEncounterWildMon(w.map.def.environment,c,false)and F.encounterTable(c)=='grass'end
  if grass and w.map:isWalkableCell(cx,cy)then x,y=cx,cy;break end
 end;if x then break end end
 assert(x,'no native grass')
 p.cellX=x;p.cellY=y;p.px=x*16;p.py=y*16;p.moving=false
 for i=1,1000 do
  if gen==2 then if w:tryWildEncounter()then break end else w:onStepComplete();if game.stack:top()~=w then break end end
 end
 local screen,b
 for i=1,1800 do local top=game.stack:top()
  if top and(gen==1 and top.kind=='wild' or gen==2 and top.battle)then screen=top;b=gen==1 and top or top.battle;break end
  U.tap(game,'a');U.wait(1)
 end
 assert(b and b.enemy2,'native organic double absent')
 local function hp(e)return e and (e.mon and e.mon.hp or e.hp)end
 local first,second=hp(b.enemy),hp(b.enemy2);local damaged=false
 local pictured=false
 for i=1,6000 do
  if not pictured and screen.phase=='menu'then U.wait(2);assert(U.shot(game,dir..'/double.png'));pictured=true end
  if (hp(b.enemy)or first)<first or(hp(b.enemy2)or second)<second then damaged=true end
  if gen==1 and game.stack:top()==w or gen==2 and not w.battleActive and game.stack:top()==nil then break end
  U.tap(game,'a');U.wait(1)
 end
 assert(damaged,'opponents never lost HP')
 assert(gen==1 and game.stack:top()==w or gen==2 and not w.battleActive and game.stack:top()==nil,'battle did not return')
 assert(require('src.render.Pipelines').level('voxel')==0,'battle rewrote overworld setting')
 assert(U.shot(game,dir..'/returned.png'));print('[PASS Gen2 double with overworld OFF]',v,os.getenv('QA_STAGE')or'on')
 love.event.quit()
end
