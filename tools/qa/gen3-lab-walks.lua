-- Native laboratory approaches, dialogue, exit, OFF and actual first person.
-- Disposable fixtures only; never replace collision, VM, scripts or warp logic.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA identity required')
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get();local kanto=ed=='firered'or ed=='leafgreen'
 local pre=({ruby='RU_',sapphire='SA_',emerald='EM_'})[ed]or'FR_'
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=kanto and'FR_PALLET_TOWN'or pre..'OLDALE_TOWN',x=10,y=9,facing='up'}})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local C=V.require('Gen3Integration')
 local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local Col=require('src.core.game3.collision');local Obj=require('src.core.game3.objects');local Message=require('src.ui.game3.message')
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day')
 local dir=assert(os.getenv('SHOT_DIR'));local id=assert(io.lines(assert(os.getenv('QA_MAP_LIST')))());local d=assert(game.data.maps[id])
 local function settle()
  for _=1,100 do local vm=require('src.core.game3.scripting.space').getVm()
   if not Message.isOpen()and not(vm and vm:isRunning())then game.input:reset();return end
   U.hold(game,'b',16);U.wait(4)
  end;error('native lab script did not finish')
 end
 local function load()
  settle();assert(Map.load(nil,game,id,{x=6,y=6,facing='up'}));require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();C.setLevel(3,game);U.wait(60);settle()
 end
 load()
 local cases=kanto and{{'north_desk',2,2,'right',1,0},{'starter_approach',8,5,'right',1,0},{'shelf_south',4,9,'down',0,1}}
  or{{'north_desk',6,2,'right',1,0},{'shelf_south',1,8,'right',1,0},{'west_seat',2,10,'down',0,1},{'east_seat',10,10,'down',0,1}}
 for _,a in ipairs(cases)do
  settle();assert(Col.isWalkable(a[2],a[3])and Col.isWalkable(a[2]+a[5],a[3]+a[6]),'invalid native approach '..a[1])
  assert(not Obj.at(a[2],a[3])and not Obj.at(a[2]+a[5],a[3]+a[6]),'native actor occupies approach '..a[1])
  Player.reset(a[2],a[3],a[4]);game.input:reset();U.hold(game,a[4],16);U.wait(16)
  assert(Map.current==id and(Player.cellX~=a[2]or Player.cellY~=a[3]),'native lab walk failed '..a[1]);print('[LAB AISLE] PASS',id,a[1])
 end
 Player.reset(6,kanto and 10 or 9,'up');C.setLevel(0,game);U.wait(3);assert(U.shot(game,dir..'/OFF.png'))
 C.setLevel(6,game);C.yaw=0;C.pitch=.12;U.wait(30);assert(C.active and C.recovery.failures==0);assert(U.shot(game,dir..'/1ST.png'))
 -- A second first-person view puts the newly bounded tabletop/apron and
 -- the back wall in view without parking the camera inside a fixture.
 Player.reset(kanto and 8 or 7,kanto and 5 or 2,'up');U.wait(25);assert(U.shot(game,dir..'/1ST-desk.png'));C.setLevel(3,game)
 -- Both labs have a native readable object next to a clear approach.
 -- Use the engine's normal A button, then dismiss with normal B input.
 if kanto then
  Player.reset(6,2,'up');U.hold(game,'a',1);U.wait(45)
  assert(Message.isOpen(),'Oak notice did not open native dialogue');assert(U.shot(game,dir..'/native-notice.png'));print('[LAB DIALOGUE] PASS',id);settle()
 end
 load();local target
 for _,w in ipairs(d.warps or{})do if Col.arrowWarpDir(Col.behavior(w.x,w.y))=='down'then target=w;break end end
 assert(target,'native south lab exit missing');assert(Col.isWalkable(target.x,target.y-1),'lab exit approach blocked')
 Player.reset(target.x,target.y-1,'down');game.input:reset();U.hold(game,'down',40);U.wait(150)
 assert(Map.current~=id,'native lab exit failed');print('[LAB EXIT] PASS',id,Map.current)
 assert(#game.mods:status().errors==0,table.concat(game.mods:status().errors,';'));print('[LAB INPUT] PASS',ed);love.event.quit()
end
