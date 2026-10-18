-- Native Hoenn field fixtures: blocked approaches, stock dialogue, OFF/1ST.
-- Disposable QA profiles only. No collision, VM or interaction replacement.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get();local pre=({emerald='EM_',ruby='RU_',sapphire='SA_'})[ed];assert(pre)
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=pre..'OLDALE_TOWN',x=10,y=9,facing='up'}})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local C=V.require('Gen3Integration');local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local Col=require('src.core.game3.collision');local Message=require('src.ui.game3.message');local dir=assert(os.getenv('SHOT_DIR'))
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day')
 local function settle()
  for _=1,100 do local vm=require('src.core.game3.scripting.space').getVm()
   if not Message.isOpen()and not(vm and vm:isRunning())then game.input:reset();return end
   U.hold(game,'b',16);U.wait(4)
  end;error('native field script did not settle')
 end
 local cases={{'PETALBURG_CITY','gym_notice',17,11,true},{'PETALBURG_CITY','garden_troughs',24,24,false},{'ROUTE102','berry_soil',24,3,true}}
 for _,a in ipairs(cases)do
  settle();C.setLevel(0,game);local id=pre..a[1];assert(Map.load(nil,game,id,{x=a[3],y=a[4],facing='up'}));require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(5);settle()
  assert(Col.isWalkable(a[3],a[4]),'fixture is not native walkable')
  local l=Map.currentDef().midLayout;assert(l:collAt(a[3],a[4]-1)==7,'fixture lost native blocked boundary')
  Player.reset(a[3],a[4],'up');C.setLevel(3,game);U.wait(20);game.input:reset();U.hold(game,'up',16);U.wait(16)
  assert(Player.cellX==a[3]and Player.cellY==a[4],'native obstacle became walkable');print('[FIELD BOUNDARY] PASS',id,a[2])
  C.setLevel(0,game);U.wait(3);assert(U.shot(game,dir..'/'..a[2]..'-OFF.png'));C.setLevel(6,game);C.yaw=0;C.pitch=.12;U.wait(25);assert(U.shot(game,dir..'/'..a[2]..'-1ST.png'));C.setLevel(3,game)
  if a[5]then game.input:reset();U.hold(game,'a',1);U.wait(45);assert(Message.isOpen(),'native dialogue did not open '..a[2]);assert(U.shot(game,dir..'/'..a[2]..'-dialogue.png'));print('[FIELD DIALOGUE] PASS',id,a[2]);settle()end
  assert(#game.mods:status().errors==0,table.concat(game.mods:status().errors,';'))
 end
 print('[FIELD PROPS NATIVE] PASS',ed);love.event.quit()
end
