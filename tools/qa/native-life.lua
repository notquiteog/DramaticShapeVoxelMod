-- Crystal or FRLG isolated QA profile; tests real option/update wiring, not audible assets.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua')
 local update=game.update;game.update=function(self,dt)self.input:reset();return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local gen=require('src.core.GameVersion').generation()
 if gen==3 then
  game:_handleBootAction({action='new_game',start={map='FR_ROUTE_1',x=7,y=8,facing='down'}})
  require('src.ui.game3.map_preview_screen').reset()
 else
  game.stack:clear();assert(game:startWorld())
  assert(game.world:warpToMapId('ROUTE_29',10,6,'down'));U.wait(5)
 end
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C
 if gen==3 then C=V.require('Gen3Integration')else
  local P=require('src.render.Pipelines');C={setLevel=function(level)P.setLevel('voxel',level)end}
 end
 if gen==3 then
  local Collision=require('src.core.game3.collision');local Map=require('src.core.game3.map');local Player=require('src.core.game3.player')
  local d=Map.currentDef();Map.ensureMidLayout(game,Map.current,d)
  local found
  for y=3,d.height-4 do for x=3,d.width-4 do if not found and Collision.isGrass(x,y)and Collision.isWalkable(x,y)then Player.reset(x,y,'down');found=true end end end
  assert(found)
 end
 local S=V.require('CommunityVisuals').kantoLife;local before=S:read()
 local Day=V.require('DayNight').setting;local dayBefore=Day:read()
 C.setLevel(3,game);S:setIndex(3,game);Day:setIndex(2,game);U.wait(100)
 local L=V.require('KantoLife');local stats=L.last
 assert(stats and stats.anchors>0 and stats.vertices>0,'no native life geometry '..tostring(stats and stats.anchors))
 U.shot(game,os.getenv('SHOT_DIR')..'/native-life.png')
 print('[native life]',stats.map,stats.anchors,stats.butterflies,stats.fireflies,stats.vertices)
 Day:setIndex(3,game);U.wait(100);assert(L.last and L.last.fireflies>0,'night fireflies missing')
 U.shot(game,os.getenv('SHOT_DIR')..'/native-life-night.png')
 S:setIndex(1,game);U.wait(3)
 local H=V.require('KantoHabitat');assert(not L.ownsFireflies(game.world and game.world.map or V.require('NativeAtmosphere').gen3(require('src.core.game3.map').currentDef(),require('src.core.game3.map').current)))
 S:setIndex(before,game);Day:setIndex(dayBefore,game)
 print('[PASS native life]',require('src.core.GameVersion').get(),'real native habitat/render and OFF consumer')
 love.event.quit()
end
