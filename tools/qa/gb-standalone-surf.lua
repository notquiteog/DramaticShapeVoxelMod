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
 local w=game.world or game.overworld
 if gen==2 then assert(w:warpToMapId('ROUTE_32',10,10,'down'))else w:setMap('ROUTE_19',5,5,'down')end
 U.wait(80)
 game.save.party={M.new(game.data,'LAPRAS',40)};game.save.party[1].moves={{id='SURF',pp=15,maxPp=15}}
 if gen==1 then local gate=require('src.world.FieldDefaults').constant(game.data,'hmBadges').SURF;game.save.inventory[gate.badge]=1 end
 local sx,sy
 for y=0,w.map.def.height*2-2 do for x=0,w.map.def.width*2-1 do
  if w.map:isWalkableCell(x,y)and not w.map:isWaterCell(x,y)and w.map:isWaterCell(x,y+1)then sx,sy=x,y;break end
 end;if sx then break end end
 assert(sx,'native shoreline missing')
 local p=w.player;p.cellX=sx;p.cellY=sy;p.px=sx*16;p.py=sy*16;p.facing='down';p.moving=false
 if gen==2 then assert(w:surfStartStep(game.save.party[1]))else w:trySurf(sx,sy+1)end
 for i=1,160 do if game.stack:top()and game.stack:top()~=w then U.tap(game,'a')else U.wait(1)end end
 assert(w.map:isWaterCell(p.cellX,p.cellY),'native surf step did not reach water')
 assert(ride.isWaterRiding(),'native Surf did not activate owned mount')
 assert(ride.waterMountSpecies()=='LAPRAS','wrong surf mount')
 assert(U.shot(game,dir..'/surf.png'))
 if gen==2 then w:applyPlayerState(require('src.world.gen2.FieldMoves').PLAYER_NORMAL)else w:stopSurfing()end
 U.wait(30);assert(not ride.isWaterRiding(),'surf mount lingered after native stop')
 print('[PASS standalone native Surf mount]',v)
 love.event.quit()
end
