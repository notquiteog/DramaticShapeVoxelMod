-- Disposable native service-room input fixtures: no collision/script replacement.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA identity required')
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get();local pre=({ruby='RU_',sapphire='SA_',emerald='EM_'})[ed]or'FR_'
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=pre=='FR_'and'FR_PALLET_TOWN'or pre..'OLDALE_TOWN',x=10,y=9,facing='up'}})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local C=V.require('Gen3Integration')
 local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local Collision=require('src.core.game3.collision')
 local Message=require('src.ui.game3.message');local Choice=require('src.ui.game3.choice');local Shop=require('src.ui.game3.shop_menu');local Heal=require('src.core.game3.pokecenter_heal')
 local dir=assert(os.getenv('SHOT_DIR'));V.require('RenderDistance').setting:sync(32);V.require('DayNight').setting:sync('day')
 local Party=require('src.core.game3.party');game.session.party={}
 for _,species in ipairs{1,4,7}do assert(Party.giveMon(game.session,species,8))end
 local function settle()
  for _=1,120 do
   local vm=require('src.core.game3.scripting.space').getVm()
   if not Message.isOpen()and not Choice.isOpen()and not Shop.isOpen()and not(vm and vm:isRunning())then game.input:reset();return end
   U.hold(game,'b',16);U.wait(4)
  end
  error('native service script did not finish')
 end
 local function place(id,x,y,facing)
  settle();assert(Map.load(nil,game,id,{x=x,y=y,facing=facing or'up'}))
  require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss()
  C.setLevel(3,game);U.wait(55);settle()
 end
 local function views(id,x,y)
  local walked=false
  for _,a in ipairs{{'left',-1,0},{'right',1,0},{'up',0,-1},{'down',0,1}}do
   if Collision.isWalkable(x+a[2],y+a[3])and not Collision.warpAt(x+a[2],y+a[3])then
    Player.reset(x,y,'up');U.hold(game,a[1],16);U.wait(16)
    if Map.current==id and(Player.cellX~=x or Player.cellY~=y)then walked=true;break end
   end
  end
  assert(walked,'native service aisle failed '..id);print('[SERVICE AISLE] PASS',id)
  Player.reset(x,y,'up');C.setLevel(0,game);U.wait(3);assert(U.shot(game,dir..'/'..id..'-OFF.png'))
  C.setLevel(6,game);C.yaw=0;C.pitch=.12;U.wait(35);assert(C.active and C.recovery.failures==0)
  assert(U.shot(game,dir..'/'..id..'-1ST.png'));C.setLevel(3,game)
 end
 local function exit(id)
  local d=game.data.maps[id];local b=assert(V.require('InteriorDiorama').forMap(d,3)).bounds;local target
  for _,w in ipairs(d.warps or{})do if(w.y+1)*16>=b[4]-.01 and w.y>2 and Collision.arrowWarpDir(Collision.behavior(w.x,w.y))=='down'then target=w;break end end
  assert(target,'no native south exit '..id);Player.reset(target.x,target.y-1,'down');game.input:reset();U.hold(game,'down',40);U.wait(150)
  print('[SERVICE EXIT OBSERVED]',id,Map.current,Player.cellX,Player.cellY,target.x,target.y)
  assert(Map.current~=id,'native service door failed '..id);print('[SERVICE EXIT] PASS',id,Map.current)
 end
 local function escalator(id)
  local target
  local d=game.data.maps[id]
  for y=0,d.height-1 do for x=0,d.width-1 do
   if not target and Collision.isEscalatorWarp(game,x,y,'left')and Collision.isWalkable(x+1,y)and not Collision.warpAt(x+1,y)then target={x,y}end
  end end
  assert(target,'native escalator approach missing '..id)
  Player.reset(target[1]+1,target[2],'left');game.input:reset();U.hold(game,'left',24);U.wait(180)
  assert(Map.current~=id,'native escalator failed '..id);assert(C.active and C.recovery.failures==0)
  print('[SERVICE ESCALATOR] PASS',id,Map.current)
 end
 local cities=pre=='FR_'and{'VIRIDIAN_CITY','PEWTER_CITY'}or{'OLDALE_TOWN','PETALBURG_CITY'}
 if os.getenv('QA_CITY')then cities={cities[tonumber(os.getenv('QA_CITY'))]}end
 for _,city in ipairs(cities)do
  local id=pre..city..'_POKEMON_CENTER_1F';place(id,7,4);views(id,7,4)
  Player.reset(7,4,'up');game.input:reset()
  for _=1,200 do if Heal.isActive()then break end;U.tap(game,'a');U.wait(5)end
  assert(Heal.isActive(),'nurse did not start native heal '..id);U.wait(60);assert(U.shot(game,dir..'/'..id..'-healing.png'))
  for _=1,1200 do if not Heal.isActive()then break end;U.wait(1)end
  assert(not Heal.isActive(),'native heal did not finish');settle();print('[SERVICE HEAL] PASS',id,#game.session.party)
  Player.reset(7,4,'up');escalator(id)
  id=pre..city..'_POKEMON_CENTER_2F';place(id,7,7);views(id,7,7);escalator(id)
  id=pre..city..'_POKEMON_CENTER_1F';place(id,7,4);exit(id)
  id=pre..city..'_MART';place(id,5,5);views(id,5,5)
  local Objects=require('src.core.game3.objects');local Std=require('src.core.game3.scripting.collision_std')
  local clerk;for _,o in ipairs(Objects.forDraw())do if o.localId==1 then clerk=o;break end end
  assert(clerk,'native clerk missing');local approach
  for _,a in ipairs{{'up',0,-1},{'left',-1,0},{'down',0,1},{'right',1,0}}do
   local mx,my=clerk.cellX-a[2],clerk.cellY-a[3]
   if Std.isCounter(Collision.cell(mx,my))then
    local x,y=clerk.cellX-a[2]*2,clerk.cellY-a[3]*2
    if Collision.isWalkable(x,y)and not Collision.warpAt(x,y)and not Objects.at(x,y)then approach={x,y,a[1]};break end
   end
  end
  assert(approach,'native clerk counter approach missing')
  print('[SERVICE CLERK APPROACH]',id,clerk.cellX,clerk.cellY,unpack(approach))
  Player.reset(approach[1],approach[2],approach[3]);game.input:reset()
  local parcel=pre=='FR_'and city=='VIRIDIAN_CITY'
  for _=1,100 do if Shop.isOpen()or parcel and Message.isOpen()then break end;U.tap(game,'a');U.wait(5)end
  if parcel then
   -- Fresh native progression offers Oak's Parcel instead of a shop menu.
   -- Preserve that script branch; do not force quest flags or replace a VM.
   assert(Message.isOpen(),'native parcel clerk did not respond '..id)
   assert(U.shot(game,dir..'/'..id..'-parcel.png'));print('[SERVICE PARCEL] PASS',id)
  else
   assert(Shop.isOpen(),'native clerk did not open shop '..id);assert(U.shot(game,dir..'/'..id..'-shop.png'))
   print('[SERVICE SHOP] PASS',id)
  end
  settle();exit(id)
 end
 assert(#game.mods:status().errors==0,table.concat(game.mods:status().errors,';'))
 print('[SERVICE INPUT] PASS',ed,#cities,'cities');love.event.quit()
end
