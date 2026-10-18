-- Disposable native home inputs. No VM, collision, warp or save replacement.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA identity required')
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get();local pre=({ruby='RU_',sapphire='SA_',emerald='EM_'})[ed]or'FR_'
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=pre=='FR_'and'FR_PALLET_TOWN'or pre..'OLDALE_TOWN',x=10,y=9,facing='up'}})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local C=V.require('Gen3Integration')
 local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local Col=require('src.core.game3.collision');local Obj=require('src.core.game3.objects')
 local dir=assert(os.getenv('SHOT_DIR'));local Message=require('src.ui.game3.message')
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day')
 local function settle()
  for _=1,100 do local vm=require('src.core.game3.scripting.space').getVm()
   if not Message.isOpen()and not(vm and vm:isRunning())then game.input:reset();return end
   U.hold(game,'b',16);U.wait(4)
  end;error('native home script did not finish')
 end
 local rooms={};for id in io.lines(assert(os.getenv('QA_MAP_LIST')))do rooms[#rooms+1]=id end
 if os.getenv('QA_ROOM')then rooms={rooms[tonumber(os.getenv('QA_ROOM'))]}end
 local function load(id,x,y)
  settle();assert(Map.load(nil,game,id,{x=x,y=y,facing='up'}));require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();C.setLevel(3,game);U.wait(55);settle()
 end
 for _,id in ipairs(rooms)do
  load(id,5,4);local d=game.data.maps[id];local walked,x,y
  for yy=2,d.height-2 do if walked then break end;for xx=1,d.width-2 do if walked then break end
   if Col.isWalkable(xx,yy)and not Col.warpAt(xx,yy)and not Obj.at(xx,yy)then
    for _,a in ipairs{{'left',-1,0},{'right',1,0},{'up',0,-1},{'down',0,1}}do
     if Col.isWalkable(xx+a[2],yy+a[3])and not Col.warpAt(xx+a[2],yy+a[3])and not Obj.at(xx+a[2],yy+a[3])then
      Player.reset(xx,yy,'up');U.hold(game,a[1],16);U.wait(16)
      if Map.current==id and(Player.cellX~=xx or Player.cellY~=yy)then walked=true;x,y=xx,yy;break end
     end
    end
   end
  end end
  assert(walked,'native aisle failed '..id);print('[HOME AISLE] PASS',id)
  local bx,by,score=x,y,1e9
  for yy=2,d.height-2 do for xx=1,d.width-2 do
   local q=(xx-d.width/2)^2+(yy-d.height*.7)^2
   if q<score and Col.isWalkable(xx,yy)and not Col.warpAt(xx,yy)and not Obj.at(xx,yy)then bx,by,score=xx,yy,q end
  end end
  Player.reset(bx,by,'up');C.setLevel(0,game);U.wait(3);assert(U.shot(game,dir..'/'..id..'-OFF.png'))
  C.setLevel(6,game);C.yaw=0;C.pitch=.12;U.wait(35);assert(C.active and C.recovery.failures==0);assert(U.shot(game,dir..'/'..id..'-1ST.png'));C.setLevel(3,game)
  if id=='FR_PLAYERS_HOUSE_1F'or id=='FR_PLAYERS_HOUSE_2F'then
   local target
   for _,w in ipairs(d.warps or{})do if w.y<3 then target=w;break end end
   assert(target,'native Kanto stair missing '..id)
   local dx=id:match('_2F$')and 1 or -1;local direction=dx==1 and'left'or'right'
   assert(Col.isWalkable(target.x+dx,target.y),'stair approach blocked')
   Player.reset(target.x+dx,target.y,direction);game.input:reset();U.hold(game,direction,20);U.wait(150)
   assert(Map.current~=id,'native Kanto stair failed '..id);print('[HOME STAIR] PASS',id,Map.current)
   assert(U.shot(game,dir..'/'..id..'-stair.png'))
  elseif id:find('LITTLEROOT',1,true)then
   local target
   for _,w in ipairs(d.warps or{})do if w.y<3 and Col.isWalkable(w.x,w.y+1)and not Col.warpAt(w.x,w.y+1)then target=w;break end end
   assert(target,'native stair missing '..id);Player.reset(target.x,target.y+1,'up');game.input:reset();U.hold(game,'up',20);U.wait(150)
   assert(Map.current~=id,'native stair failed '..id);print('[HOME STAIR] PASS',id,Map.current)
   assert(U.shot(game,dir..'/'..id..'-stair.png'))
  end
  if not id:match('_2F$')then
   load(id,5,4);local target
   for _,w in ipairs(d.warps or{})do if w.y>=d.height-2 and Col.arrowWarpDir(Col.behavior(w.x,w.y))=='down'then target=w;break end end
   assert(target,'native home south arrow missing '..id);Player.reset(target.x,target.y-1,'down');game.input:reset();U.hold(game,'down',40);U.wait(150)
   assert(Map.current~=id,'native exit failed '..id);print('[HOME EXIT] PASS',id,Map.current)
  end
 end
 assert(#game.mods:status().errors==0,table.concat(game.mods:status().errors,';'));print('[HOME INPUT] PASS',ed,#rooms);love.event.quit()
end
