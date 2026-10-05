return function(game)
 local U=dofile('tests/drivers/util.lua');assert(love.filesystem.getIdentity():match('%-qa$'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ROUTE_29',10,6,'down'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 require('src.render.Pipelines').setLevel('voxel',4)
 U.wait(100);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 local map=game.world.map;local target
 for y=2,map.def.height*2-3 do for x=2,map.def.width*2-3 do
  if map:isGrassCell(x,y)and map:isWalkableCell(x,y+1)then target={x,y}end
 end end
 assert(target);assert(game.world:warpToMapId('ROUTE_29',target[1],target[2]+1,'up'))
 U.wait(100);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 V.require('LegendaryVisualsPreset').setting:setIndex(2,game)
 for _,index in ipairs{1,2}do
  V.require('CommunityVisuals').grass:setIndex(index,game)
  assert(V.require('CommunityVisuals').grass:get()==(index==1 and'default'or'n64memory'))
  V.require('TreePresentation').changed('communityGrass');U.wait(160)
  U.shot(game,assert(os.getenv('SHOT_DIR'))..'/grass-'..index..'.png')
 end
 print('[PASS Crystal native grass options]',target[1],target[2]);love.event.quit()
end
