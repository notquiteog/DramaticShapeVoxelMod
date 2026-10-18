-- Native early-region walking and boundary checks. Disposable QA profiles only.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA identity required')
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get();local pre=({ruby='RU_',sapphire='SA_',emerald='EM_'})[ed]or'FR_'
 local names=pre=='FR_'and{'PALLET_TOWN','VIRIDIAN_CITY','PEWTER_CITY','ROUTE_1','ROUTE_2','VIRIDIAN_FOREST'}or{'LITTLEROOT_TOWN','OLDALE_TOWN','PETALBURG_CITY','ROUTE101','ROUTE102','ROUTE103'}
 if os.getenv('QA_MAP_SUFFIXES')then names={};for n in os.getenv('QA_MAP_SUFFIXES'):gmatch('[%w_]+')do names[#names+1]=n end end
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=pre..names[1],x=10,y=9,facing='up'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local Cam=V.require('Gen3Integration');local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local Col=require('src.core.game3.collision');local Obj=require('src.core.game3.objects')
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day')
 local dirs={{1,0,'right'},{-1,0,'left'},{0,1,'down'},{0,-1,'up'}};local walks,bumps=0,0
 for _,name in ipairs(names)do
  local id=pre..name;Cam.setLevel(0,game);assert(Map.load(nil,game,id,{x=10,y=9,facing='up'}));require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(5)
  local def=Map.currentDef();local l=def.midLayout;local before={}
  for y=0,def.height-1 do for x=0,def.width-1 do local c=l:cellAt(x,y);before[y*def.width+x]={c.mid,c.coll,c.elev}end end
  local function dry(x,y)
   local b=Col.behavior(x,y);return x>1 and y>1 and x<def.width-2 and y<def.height-2 and Col.isWalkable(x,y)and not Col.isWater(x,y)and not Col.warpAt(x,y)and not Obj.at(x,y)and not(b and b>=0x38 and b<=0x3f)
  end
  local walk,bump;local walkScore,bumpScore=1e9,1e9
  for y=2,def.height-3 do for x=2,def.width-3 do if dry(x,y)then for _,d in ipairs(dirs)do
   local nx,ny=x+d[1],y+d[2]
   local score=(x-def.width/2)^2+(y-def.height/2)^2
   if dry(nx,ny)and score<walkScore then walk={x,y,d};walkScore=score end
   if score<bumpScore and l:collAt(nx,ny)==7 and not Obj.at(nx,ny)then bump={x,y,d};bumpScore=score end
  end end end end
  assert(walk and bump,'native fixture missing '..id)
  Cam.setLevel(3,game);U.wait(20)
  Player.reset(walk[1],walk[2],walk[3][3]);game.input:reset();U.hold(game,walk[3][3],16);U.wait(16)
  assert(Map.current==id and(Player.cellX~=walk[1]or Player.cellY~=walk[2]),'native aisle failed '..id);walks=walks+1
  Player.reset(bump[1],bump[2],bump[3][3]);game.input:reset();U.hold(game,bump[3][3],16);U.wait(16)
  assert(Map.current==id and Player.cellX==bump[1]and Player.cellY==bump[2],'native boundary failed '..id);bumps=bumps+1
  for y=0,def.height-1 do for x=0,def.width-1 do local c=l:cellAt(x,y);local b=before[y*def.width+x];assert(c.mid==b[1]and c.coll==b[2]and c.elev==b[3],'presentation changed native cell')end end
  Cam.setLevel(0,game);U.wait(2);assert(U.shot(game,os.getenv('SHOT_DIR')..'/'..id..'-OFF.png'))
  Cam.setLevel(6,game);Cam.yaw=0;Cam.pitch=.12;U.wait(15);assert(Cam.active and Cam.recovery.failures==0);assert(U.shot(game,os.getenv('SHOT_DIR')..'/'..id..'-1ST.png'))
  assert(#game.mods:status().errors==0,table.concat(game.mods:status().errors,';'));print('[EARLY OUTDOOR] PASS',id,'walk',walk[1],walk[2],walk[3][3],'boundary',bump[1],bump[2],bump[3][3])
 end
 if os.getenv('QA_WITH_BRIDGE')=='1'then
  local id=pre..(pre=='FR_'and'ROUTE_24'or'FORTREE_CITY');Cam.setLevel(0,game);assert(Map.load(nil,game,id,{x=pre=='FR_'and 12 or 13,y=pre=='FR_'and 37 or 4,facing=pre=='FR_'and'down'or'right'}));require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(5)
  local x,y,dir=pre=='FR_'and 12 or 13,pre=='FR_'and 37 or 4,pre=='FR_'and'down'or'right';Player.reset(x,y,dir);Cam.setLevel(3,game);U.wait(15);game.input:reset();print('[BRIDGE FIXTURE]',id,x,y,Col.isWalkable(x,y),Col.isWalkable(x,y+(pre=='FR_'and 1 or 0)),Obj.at(x,y)and'actor'or'clear');U.hold(game,dir,16);U.wait(16);print('[BRIDGE RESULT]',Map.current,Player.cellX,Player.cellY,require('src.ui.game3.message').isOpen());assert(Map.current==id and(Player.cellX~=x or Player.cellY~=y),'native bridge movement failed');print('[NATIVE BRIDGE] PASS',id)
  Cam.setLevel(6,game);U.wait(15);assert(U.shot(game,os.getenv('SHOT_DIR')..'/'..id..'-1ST.png'));assert(#game.mods:status().errors==0)
 end
 print('[EARLY NATIVE]',ed,walks,'aisles',bumps,'blocked boundaries');love.event.quit()
end
