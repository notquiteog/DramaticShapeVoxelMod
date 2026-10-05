return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map='FR_LAVENDER_TOWN',x=8,y=14,facing='up'}})
 require('src.ui.game3.map_preview_screen').reset()
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local Map=require('src.core.game3.map');local P=require('src.core.game3.player');local Collision=require('src.core.game3.collision')
 local def=Map.currentDef();local best,score
 for y=1,def.height-2 do for x=1,def.width-2 do local mid=def.midLayout:midAt(x,y)
 if (mid==0x163 or mid==0x173)and Collision.isWalkable(x,y)then local d=(x-def.width/2)^2+(y-def.height/2)^2;if not score or d<score then best,score={x,y},d end end end end
 assert(best);P.reset(best[1],best[2],'up')
 local C=V.require('Gen3Integration');C.setLevel(3,game)
 V.require('LegendaryVisualsPreset').setting:setIndex(2,game)
 V.require('TreePresentation').art:setIndex(3,game)
 local Models=V.require('NativeLegendaryRoads');local original=Models.build;local applied=0
 Models.build=function(...)local yes=original(...);if yes then applied=applied+1 end;return yes end
 for _,index in ipairs{1,2}do
  V.require('CommunityVisuals').roads:setIndex(index,game)
  V.require('TreePresentation').changed('communityRoads');U.wait(220)
  assert(C.active);U.shot(game,dir..'/roads-'..index..'.png')
 end
 assert(applied>0,'no native paths replaced');print('[PASS native Legendary roads]',applied,Map.current,def.id)
 Models.build=original;love.event.quit()
end
