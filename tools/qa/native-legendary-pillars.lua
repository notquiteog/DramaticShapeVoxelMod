return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map='FR_FUCHSIA_CITY',x=20,y=20,facing='up'}})
 require('src.ui.game3.map_preview_screen').reset()
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local Collision=require('src.core.game3.collision')
 local def=Map.currentDef();local target
 for y=2,def.height-3 do for x=2,def.width-3 do
  local mid=def.midLayout:midAt(x,y)
  if mid==0xE7 and Collision.isWalkable(x,y+2)then target={x,y+2};break end
 end;if target then break end end
 assert(target,'no source stone fence vantage');Player.reset(target[1],target[2],'up')
 local C=V.require('Gen3Integration');C.setLevel(3,game)
 V.require('LegendaryVisualsPreset').setting:setIndex(2,game)
 local model=V.require('NativeLegendaryPillars');local build=model.build;local applied=0
 model.build=function(...)local result=build(...);if result then applied=applied+1 end;return result end
 for index=1,4 do
  V.require('CommunityVisuals').pillars:setIndex(index,game)
  V.require('TreePresentation').changed('communityPillars');U.wait(220)
  assert(C.active);U.shot(game,dir..'/pillars-'..index..'.png')
 end
 assert(applied>=3,'native pillar layouts not drawn');print('[PASS native pillar layouts]',applied,target[1],target[2])
 model.build=build;love.event.quit()
end
