return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ILEX_FOREST',6,22,'up'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 require('src.render.Pipelines').setLevel('voxel',4)
 U.wait(100);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 V.require('LegendaryVisualsPreset').setting:setIndex(2,game)
 V.require('TreePresentation').art:setIndex(3,game)
 local Models=V.require('NativeLegendaryForest');local original=Models.card;local applied=0
 Models.card=function(...)local card=original(...);if card and card.legendaryForest then applied=applied+1 end;return card end
 for _,index in ipairs{1,2}do
  V.require('CommunityVisuals').forest:setIndex(index,game)
  V.require('TreePresentation').changed('communityForest');U.wait(240)
  U.shot(game,dir..'/forest-'..index..'.png')
 end
 assert(applied>0,'no native trees replaced');print('[PASS Crystal Legendary forest]',applied)
 Models.card=original;love.event.quit()
end
