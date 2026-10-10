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
 game.save.inventory=game.save.inventory or{};game.save.inventory.MASTER_BALL=3
 local opts=game.mods.modOptions.overworld_wild_spawns or{};game.mods.modOptions.overworld_wild_spawns=opts
 opts.overworld_catching=true;opts.catch_throw_key='c';C.selectedBallIndex=4
 local ow=game.world or game.overworld
 local chosen
 for i=1,600 do
  for _,e in pairs(C.logic.entities)do
   if e.overworldWildSpawn and not e.hiddenEncounter and not e.wildsAmbientPokemon and e.visibleSprite~=false and ow.map:isWalkableCell(e.cellX,e.cellY+1)then chosen=e;break end
  end
  if chosen then break end;U.wait(1)
 end
 assert(chosen,'no native visible spawn')
 chosen.update=function()end;chosen.moving=false
 local p=ow.player;p.cellX=chosen.cellX;p.cellY=chosen.cellY+1;p.px=p.cellX*16;p.py=p.cellY*16;p.facing='up';p.moving=false
 local full=os.getenv('QA_FULL_PC')=='1'
 if full then
  local B=require(gen==2 and 'src.core.gen2.Boxes' or 'src.pokemon.Boxes')
  for i=#game.save.party+1,6 do game.save.party[i]={species='PIKACHU',hp=20,stats={hp=20},level=5}end
  game.save.boxes={};for i=1, B.NUM_BOXES or 12 do game.save.boxes[i]={};for j=1,B.MONS_PER_BOX or 20 do game.save.boxes[i][j]={species='PIKACHU'}end end
 end
 local before=#game.save.party;local species=chosen.species
 local block=C:_catchBlocker(game,ow);assert(not block,block)
 assert(require('src.mods.Runtime').call('input.key',function()return false end,game,{key='c',phase='pressed',isrepeat=false}))
 U.wait(3);assert(C.projectile:isBusy(),'master throw not launched')
 if full then
  U.wait(400)
  assert(#game.save.party==before,'full storage unexpectedly grew party')
  assert(C.logic.entities[chosen.id]==chosen and chosen.visibleSprite and not chosen.wildsCatchLocked,'full storage lost/locked actor')
 else
  for i=1,600 do if #game.save.party>before then break end;U.wait(1)end
  assert(#game.save.party==before+1,'capture not stored: '..tostring(C.phase))
  assert(game.save.party[#game.save.party].species==species,'wrong species')
  assert(not C.logic.entities[chosen.id],'captured actor remains')
 end
 assert(game.save.inventory.MASTER_BALL==2,'wrong inventory debit')
 assert(U.shot(game,dir..'/captured.png'))
 print('[PASS standalone native target capture]',v)
 love.event.quit()
end
