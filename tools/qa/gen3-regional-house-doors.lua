-- Native input-driven entry checks for the new RS exteriors. Private *-qa
-- identity only; source teleport precedes the normal walking/door/warp path.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'refusing a non-QA profile')
 local edition=require('src.core.GameVersion').get()
 assert(edition=='ruby' or edition=='sapphire')
 local prefix=edition=='ruby' and 'RU_' or 'SA_'
 local U=dofile('tests/drivers/util.lua');local update=game.update
 game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=prefix..'VERDANTURF_TOWN',x=1,y=15,facing='up'}})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C=V.require('Gen3Integration');local Map=require('src.core.game3.map')
 local Player=require('src.core.game3.player');local Collision=require('src.core.game3.collision')
 V.require('RenderDistance').setting:sync(32)
 for i,s in ipairs{{'VERDANTURF_TOWN',1,15},{'VERDANTURF_TOWN',10,15},{'MOSSDEEP_CITY',19,11}}do
  game.input:reset();local source=prefix..s[1]
  assert(Map.load(nil,game,source,{x=s[2],y=s[3],facing='up'}))
  require('src.ui.game3.map_preview_screen').dismiss()
  require('src.ui.game3.map_name_popup').dismiss()
  assert(Collision.isWalkable(s[2],s[3]) and not Collision.warpAt(s[2],s[3]),'approach is not native walking ground')
  C.setLevel(3,game);U.wait(70)
  assert(C.active and C.recovery.failures==0,'voxel field not ready')
  U.hold(game,'up',18);U.wait(180)
  assert(Map.current~=source and Map.current:sub(1,3)==prefix,'native house entry did not warp')
  assert(not V.require('Gen3Tilesets').outdoor(Map.currentDef()),'warp did not reach an interior')
  assert(C.active and C.recovery.failures==0,'native door warp lost selected camera')
  assert(C.level==3,'camera option changed during native warp')
  assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/entry-'..i..'.png'))
  print('[REGIONAL HOUSE ENTRY] PASS',edition,source,s[2],s[3],Map.current,Player.cellX,Player.cellY)
 end
 love.event.quit(0)
end
