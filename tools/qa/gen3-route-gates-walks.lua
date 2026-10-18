-- Native Kanto gate aisles, blocked fixtures, both exits and original UI.
-- No replacement collision, script VM, actor or warp behavior.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'disposable QA profile required')
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get()
 assert(ed=='firered'or ed=='leafgreen')
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=9,facing='up'}})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local Camera=V.require('Gen3Integration')
 local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local Col=require('src.core.game3.collision');local Obj=require('src.core.game3.objects');local Message=require('src.ui.game3.message')
 local ids={'FR_ROUTE_2_EAST_BUILDING','FR_ROUTE_2_HOUSE','FR_ROUTE_2_VIRIDIAN_FOREST_NORTH_ENTRANCE','FR_ROUTE_2_VIRIDIAN_FOREST_SOUTH_ENTRANCE'}
 local dir=assert(os.getenv('SHOT_DIR'))
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day')
 local function settle()
  for _=1,120 do local vm=require('src.core.game3.scripting.space').getVm()
   if not Message.isOpen()and not(vm and vm:isRunning())then game.input:reset();return end
   U.hold(game,'b',16);U.wait(4)
  end;error('native route script did not settle')
 end
 local function load(id)
  settle();assert(Map.load(nil,game,id,{x=2,y=3,facing='up'}));require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();Camera.setLevel(3,game);U.wait(60);settle()
 end
 local deltas={right={1,0},left={-1,0},down={0,1},up={0,-1}}
 for _,id in ipairs(ids)do
  load(id);local house=id=='FR_ROUTE_2_HOUSE'
  local cases=house and{{1,3,'down'},{8,4,'down'}}or{{3,3,'right'}}
  if not house then
   local picked
   for _,a in ipairs{{10,4,'down'},{10,7,'down'},{13,4,'down'},{13,7,'down'}}do
    if not Obj.at(a[1],a[2])and not Obj.at(a[1],a[2]+1)then picked=a;break end
   end
   assert(picked,'all native seat approaches occupied');cases[#cases+1]=picked
  end
  for _,a in ipairs(cases)do
   local dx,dy=unpack(deltas[a[3]]);assert(Col.isWalkable(a[1],a[2])and Col.isWalkable(a[1]+dx,a[2]+dy),'bad native aisle')
   assert(not Obj.at(a[1],a[2])and not Obj.at(a[1]+dx,a[2]+dy),'native actor in aisle fixture')
   Player.reset(a[1],a[2],a[3]);game.input:reset();U.hold(game,a[3],16);U.wait(16)
   assert(Map.current==id and(Player.cellX~=a[1]or Player.cellY~=a[2]),'native aisle failed');print('[ROUTE AISLE] PASS',id,a[1],a[2],a[3])
  end
  local x,y=house and 4 or 10,4
  if not house and Obj.at(x,y)then y=7 end
  assert(Col.isWalkable(x,y)and not Col.isWalkable(x+1,y),'bad fixture boundary')
  assert(not Obj.at(x,y),'native actor at boundary fixture');Player.reset(x,y,'right');game.input:reset();U.hold(game,'right',16);U.wait(16)
  assert(Player.cellX==x and Player.cellY==y,'native fixture no longer blocks');print('[ROUTE BUMP] PASS',id)
  Player.reset(house and 4 or 7,house and 7 or 9,'up');Camera.setLevel(0,game);U.wait(3);assert(U.shot(game,dir..'/'..id..'-OFF.png'))
  Camera.setLevel(6,game);Camera.yaw=0;Camera.pitch=.12;U.wait(30);assert(Camera.active and Camera.recovery.failures==0);assert(U.shot(game,dir..'/'..id..'-1ST.png'))
  local def=assert(game.data.maps[id]);local exits={}
  for _,w in ipairs(def.warps or{})do local b=Col.arrowWarpDir(Col.behavior(w.x,w.y));if b=='down'or not house and w.y==1 then exits[#exits+1]={w,b=='down'and'down'or'up'}end end
  assert(#exits>0,'native gate exits missing')
  local seen={}
  for _,e in ipairs(exits)do if not seen[e[2]]then
   load(id);local w,dir=e[1],e[2];local dy=dir=='down'and-1 or 1;assert(Col.isWalkable(w.x,w.y+dy),'native exit approach blocked')
   -- Native transitions are also checked with presentation OFF; this keeps
   -- unrelated connected outdoor construction out of an interior exit test.
   Camera.setLevel(0,game)
   Player.reset(w.x,w.y+dy,dir);game.input:reset();U.hold(game,dir,40);U.wait(150)
   assert(Map.current~=id,'native exit did not fire '..dir);print('[ROUTE EXIT] PASS',id,dir,Map.current);seen[dir]=true
  end end
 end
 assert(#game.mods:status().errors==0,table.concat(game.mods:status().errors,';'));print('[ROUTE INPUT] PASS',ed);love.event.quit()
end
