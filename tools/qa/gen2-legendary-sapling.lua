return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ILEX_FOREST',6,24,'up'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 require('src.render.Pipelines').setLevel('voxel',4)
 U.wait(100);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 V.require('LegendaryVisualsPreset').setting:setIndex(2,game)
 V.require('TreePresentation').art:setIndex(3,game)
 local map=game.world.map;local P=require('src.world.gen2.Permissions');local found
 for y=0,map.def.height*2-1 do for x=0,map.def.width*2-1 do if P.isCutTree(map:cellCollision(x,y))then found={x,y};break end end;if found then break end end
 assert(found,'no native Cut cell');print('CUT',found[1],found[2]);assert(game.world:warpToMapId('ILEX_FOREST',found[1],found[2]+2,'up'));U.wait(80);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 local Models=V.require('LegendarySapling');local original=Models.append;local applied=0
 Models.append=function(...)applied=applied+1;return original(...)end
 for _,index in ipairs{1,2}do
  V.require('CommunityVisuals').cutTrees:setIndex(index,game)
  V.require('TreePresentation').changed('communityCutTrees');U.wait(240)
  U.shot(game,dir..'/sapling-'..index..'.png')
 end
 assert(applied>0,'no native trees replaced');print('[PASS Crystal Legendary Cut saplings]',applied)
 Models.append=original;love.event.quit()
end
