return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=os.getenv('ROCKET_MAP')or'FR_ROCKET_HIDEOUT_ELEVATOR',x=4,y=4,facing='up'}})
 require('src.ui.game3.map_preview_screen').reset()
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local Map=require('src.core.game3.map');local P=require('src.core.game3.player');local Collision=require('src.core.game3.collision')
 local def=Map.currentDef();
 local best,score
 for y=1,def.height-2 do for x=1,def.width-2 do if Collision.isWalkable(x,y)then local d=(x-def.width/2)^2+(y-def.height/2)^2;if not score or d<score then best,score={x,y},d end end end end
 assert(best);P.reset(best[1],best[2],'up')
 local C=V.require('Gen3Integration');C.setLevel(3,game)
 V.require('LegendaryVisualsPreset').setting:setIndex(2,game)
 V.require('TreePresentation').art:setIndex(3,game)
 local Models=V.require('NativeRocketWalls');local original=Models.build;local applied=0
 Models.build=function(...)local r=original(...);if r then applied=applied+1 end;return r end
 for _,index in ipairs{1,2}do
  V.require('CommunityVisuals')[os.getenv('ROCKET_MAP')and'rocket'or'elevator']:setIndex(index,game)
  V.require('TreePresentation').changed(os.getenv('ROCKET_MAP')and'communityRocket'or'communityElevator');U.wait(220)
  assert(C.active);U.shot(game,dir..'/elevator-'..index..'.png')
 end
 assert(applied>0,'no native Rocket walls replaced');Models.build=original;print('[PASS native Rocket elevator]',applied);love.event.quit()
end
