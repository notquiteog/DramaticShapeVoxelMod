-- Native input-driven entry checks for the new department-store exteriors. Private *-qa
-- identity only; source teleport precedes the normal walking/door/warp path.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'refusing a non-QA profile')
 local edition=require('src.core.GameVersion').get()
 assert(({firered=true,leafgreen=true,emerald=true,ruby=true,sapphire=true})[edition])
 local prefix=edition=='ruby'and'RU_'or edition=='sapphire'and'SA_'or edition=='emerald'and'EM_'or'FR_'
 local celadon=prefix=='FR_'
 local map=prefix..(celadon and'CELADON_CITY'or'LILYCOVE_CITY')
 local spots=celadon and {{11,15},{15,15}}or{{27,7}}
 local U=dofile('tests/drivers/util.lua');local update=game.update
 game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=map,x=spots[1][1],y=spots[1][2],facing='up'}})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C=V.require('Gen3Integration');local Map=require('src.core.game3.map')
 local Player=require('src.core.game3.player');local Collision=require('src.core.game3.collision')
 V.require('RenderDistance').setting:sync(32)
 -- The native rear projection row in Celadon remains an actual walking
 -- lane. Exercise normal input there before entering either front door.
 if celadon then
  assert(Map.load(nil,game,map,{x=10,y=5,facing='right'}))
  require('src.ui.game3.map_preview_screen').dismiss()
  require('src.ui.game3.map_name_popup').dismiss()
  C.setLevel(3,game);U.wait(70)
  assert(Collision.isWalkable(10,5)and Collision.isWalkable(11,5))
  U.hold(game,'right',18);U.wait(20)
  assert(Map.current==map and Player.cellY==5 and Player.cellX>10,'native rear lane blocked')
  print('[DEPARTMENT REAR LANE] PASS',edition,Player.cellX,Player.cellY)
 end
 for i,s in ipairs(spots)do
  game.input:reset();local source=map
  assert(Map.load(nil,game,source,{x=s[1],y=s[2],facing='up'}))
  require('src.ui.game3.map_preview_screen').dismiss()
  require('src.ui.game3.map_name_popup').dismiss()
  assert(Collision.isWalkable(s[1],s[2]) and not Collision.warpAt(s[1],s[2]),'approach is not native walking ground')
  C.setLevel(0,game);U.wait(10)
  assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/native-flat-'..i..'.png'))
  C.setLevel(3,game);U.wait(70)
  assert(C.active and C.recovery.failures==0,'voxel field not ready')
  U.hold(game,'up',18);U.wait(180)
  assert(Map.current~=source and Map.current:sub(1,3)==prefix,'native house entry did not warp')
  assert(not V.require('Gen3Tilesets').outdoor(Map.currentDef()),'warp did not reach an interior')
  assert(C.active and C.recovery.failures==0,'native door warp lost selected camera')
  assert(C.level==3,'camera option changed during native warp')
  assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/entry-'..i..'.png'))
  print('[DEPARTMENT STORE ENTRY] PASS',edition,source,s[1],s[2],Map.current,Player.cellX,Player.cellY)
 end
 love.event.quit(0)
end
