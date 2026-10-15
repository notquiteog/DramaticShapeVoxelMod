-- Real production 1ST camera from native museum approaches, no inspection lens.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA profile required')
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get()
 local prefix=ed=='emerald'and'EM_'or ed=='ruby'and'RU_'or ed=='sapphire'and'SA_'or'FR_'
 local id=prefix..(prefix=='FR_'and'SEVEN_ISLAND_TRAINER_TOWER'or prefix=='EM_'and'BATTLE_FRONTIER_OUTSIDE_EAST'or'BATTLE_TOWER_OUTSIDE');local x=prefix=='FR_'and 58 or prefix=='EM_'and 16 or 14;local ys=prefix=='FR_'and{13,8}or prefix=='EM_'and{20,15}or{14,9};local update=game.update
 game.update=function(self,dt)self.input:reset();return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=id,x=x,y=ys[1],facing='up'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('Gen3Integration');local Map=require('src.core.game3.map')
 V.require('RenderDistance').setting:sync(32);V.require('DayNight').setting:sync('day')
 for time in (os.getenv('QA_TIMES')or'day'):gmatch('[^,]+')do
 V.require('DayNight').setting:sync(time)
 for _,y in ipairs(ys)do
  assert(Map.load(nil,game,id,{x=x,y=y,facing='up'}))
  require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss()
  assert(require('src.core.game3.collision').isWalkable(x,y))
  C.setLevel(6,game);C.yaw=0;C.pitch=.16;U.wait(60)
  assert(C.active and C.level==6 and C.recovery.failures==0)
  assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/tower-first-person-'..time..'-'..y..'.png'))
 end
 end
 print('[TOWER FIRST PERSON] PASS',ed);love.event.quit()
end
