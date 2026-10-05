return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map='FR_ROUTE_1',x=7,y=8,facing='up'}})
 require('src.ui.game3.map_preview_screen').reset()
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local Map=require('src.core.game3.map');local P=require('src.core.game3.player')
 local Collision=require('src.core.game3.collision');local def=Map.currentDef()
 local spec=V.require('Gen3Tilesets').resolve(def.midLayout.pair,require('src.import.gba.versions').TILESET_PAIRS)
 local target
 for y=2,def.height-4 do for x=2,def.width-3 do
  if V.require('Gen3TileShape').of(spec.primary,spec.secondary,def.midLayout:midAt(x,y)).kind=='grass' and Collision.isWalkable(x,y+2)then target={x,y}end
 end end
 assert(target);P.reset(target[1],target[2]+2,'up')
 local camera=V.require('Gen3Integration');camera.setLevel(3,game)
 local setting=V.require('CommunityVisuals').grass
 V.require('LegendaryVisualsPreset').setting:setIndex(2,game)
 for _,index in ipairs{1,2}do
  setting:setIndex(index,game);assert(setting:get()==(index==1 and 'default'or'n64memory'));V.require('TreePresentation').changed('communityGrass');U.wait(180)
  assert(camera.active);U.shot(game,dir..'/grass-'..index..'.png')
  print('QA native grass',index,target[1],target[2])
 end
 print('[PASS native grass options runtime]');love.event.quit()
end
