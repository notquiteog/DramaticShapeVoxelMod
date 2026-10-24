return function(game)
 local U=dofile(assert(os.getenv('QA_UTIL')));local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local C,S=V.require('Gen3Integration'),V.require('Gen3Scene');local Map,P=require('src.core.game3.map'),require('src.core.game3.player')
 game:_handleBootAction({action='new_game',start={map='FR_ROUTE_2',x=5,y=52,facing='up'}})
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day')
 for i,q in ipairs{{5,51,'up','down','FR_ROUTE_2_VIRIDIAN_FOREST_SOUTH_ENTRANCE',52},{5,13,'down','up','FR_ROUTE_2_VIRIDIAN_FOREST_NORTH_ENTRANCE',12}}do
  C.setLevel(0,game);assert(Map.load(nil,game,'FR_ROUTE_2',{x=q[1],y=q[6],facing=q[3]}));U.wait(80);require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss()
  C.setLevel(3,game);C.yaw=q[3]=='down'and math.pi or 0;C.pitch=.12;U.wait(170);assert(C.active and C.recovery.failures==0);assert(U.shot(game,os.getenv('SHOT_DIR')..'/'..i..'-overview.png'))
  for _=1,180 do U.hold(game,q[3],1);if Map.currentDef().id~= 'FR_ROUTE_2'then break end end;game.input:reset();assert(Map.currentDef().id==q[5],'native forest gate entry failed');U.wait(130)
  for _=1,240 do U.hold(game,q[4],1);if Map.currentDef().id=='FR_ROUTE_2'then break end end;game.input:reset();assert(Map.currentDef().id=='FR_ROUTE_2','native forest gate return failed');U.wait(70);assert(U.shot(game,os.getenv('SHOT_DIR')..'/'..i..'-returned.png'));print('[NATIVE FOREST GATE] PASS',i)
 end
 assert(#game.mods.errors==0 and C.recovery.failures==0);print('[FOREST GATE REGRESSION] PASS')
end
