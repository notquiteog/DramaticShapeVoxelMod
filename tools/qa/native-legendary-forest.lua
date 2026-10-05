return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map='FR_VIRIDIAN_FOREST',x=18,y=28,facing='up'}})
 require('src.ui.game3.map_preview_screen').reset()
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local Map=require('src.core.game3.map');local P=require('src.core.game3.player');local Collision=require('src.core.game3.collision')
 local def=Map.currentDef();local found
 for y=8,def.height-8 do for x=8,def.width-8 do if Collision.isWalkable(x,y)and not Collision.isWater(x,y)then found={x,y};break end end;if found then break end end
 assert(found);P.reset(found[1],found[2],'up')
 local C=V.require('Gen3Integration');C.setLevel(3,game)
 V.require('LegendaryVisualsPreset').setting:setIndex(2,game)
 V.require('TreePresentation').art:setIndex(3,game)
 local Models=V.require('NativeLegendaryForest');local original=Models.card;local applied=0
 Models.card=function(...)local card=original(...);if card and card.legendaryForest then applied=applied+1 end;return card end
 for _,index in ipairs{1,2}do
  V.require('CommunityVisuals').forest:setIndex(index,game)
  V.require('TreePresentation').changed('communityForest');U.wait(220)
  assert(C.active);U.shot(game,dir..'/forest-'..index..'.png')
 end
 assert(applied>0,'no native trees replaced');print('[PASS native Legendary forest]',applied,Map.current,def.id)
 Models.card=original;love.event.quit()
end
