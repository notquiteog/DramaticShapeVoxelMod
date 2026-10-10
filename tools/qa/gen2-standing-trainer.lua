return function(game)
 local U=dofile('tests/drivers/util.lua');assert(love.filesystem.getIdentity():match('%-qa$'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ROUTE_29',10,6,'down'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 require('src.render.Pipelines').setLevel('voxel',4)
 V.require('UiBackplates').arenaFill:setIndex(1,game)
 local S=V.require('StandingTrainer');S.setting:setIndex(2,game);V.require('OverworldBattle').setting:setIndex(1,game)
 local calls=0;local tex
 local handle=V.require('CharacterRenderers').register({id='qa-native-trainer',battleGenerations={2},drawBattleTrainer=function(ctx)
  assert(ctx.generation==2 and ctx.arena and ctx.battle)
  local screen=V.require('Gen2Staged').screenFor(game)
  if not tex then tex=screen.playerBackImage end
  if not tex then return false end
  local Mat=ctx.host.Mat4;local p,e=ctx.arena.player,ctx.arena.enemy
  local dx,dz=p[1]-e[1],p[2]-e[2];local length=math.sqrt(dx*dx+dz*dz);dx,dz=dx/length,dz/length
  local model=Mat.mul(Mat.mul(Mat.translate(p[1]+dx*10,ctx.groundY+8,p[2]+dz*10),Mat.rotateY(math.atan2(-dx,-dz))),Mat.scale(16,16,1))
  ctx.host.Voxel3D.draw(V.require('BattleBillboard').mesh(),tex,model,0);calls=calls+1;return true
 end})
 local Mon=require('src.battle.gen2.Mon');game.save.party={Mon.new(game.data,'CYNDAQUIL',10)}
 U.wait(100);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 game.world:startBattle({wild=Mon.new(game.data,'SENTRET',3)})
 local screen
 for i=1,450 do screen=V.require('Gen2Staged').screenFor(game);if screen and screen.phase=='menu'then break end;U.tap(game,'a');U.wait(2)end
 assert(screen,'no battle screen');U.wait(30);assert(calls>0,'native trainer never drawn')
 U.shot(game,os.getenv('SHOT_DIR')..'/legendary.png')
 S.setting:setIndex(1,game);U.wait(20);local stopped=calls;U.wait(10);assert(calls==stopped)
 U.shot(game,os.getenv('SHOT_DIR')..'/stock.png');handle:release()
 print('[PASS Gen2 native trainer public provider and STOCK]',calls);love.event.quit()
end
