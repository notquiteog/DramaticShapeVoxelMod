-- Real production 1ST camera from native museum approaches, no inspection lens.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA profile required')
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get()
 local prefix=ed=='emerald'and'EM_'or ed=='ruby'and'RU_'or assert(ed=='sapphire')and'SA_'
 local id=prefix..'LILYCOVE_CITY';local update=game.update
 game.update=function(self,dt)self.input:reset();return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=id,x=11,y=9,facing='up'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('Gen3Integration');local Map=require('src.core.game3.map')
 V.require('RenderDistance').setting:sync(32);V.require('DayNight').setting:sync('day')
 for time in (os.getenv('QA_TIMES')or'day'):gmatch('[^,]+')do
 V.require('DayNight').setting:sync(time)
 for _,y in ipairs{9,6}do
  assert(Map.load(nil,game,id,{x=11,y=y,facing='up'}))
  require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss()
  assert(require('src.core.game3.collision').isWalkable(11,y))
  C.setLevel(6,game);C.yaw=0;C.pitch=.16;U.wait(60)
  assert(C.active and C.level==6 and C.recovery.failures==0)
  assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/museum-first-person-'..time..'-'..y..'.png'))
 end
 end
 print('[MUSEUM FIRST PERSON] PASS',ed);love.event.quit()
end
