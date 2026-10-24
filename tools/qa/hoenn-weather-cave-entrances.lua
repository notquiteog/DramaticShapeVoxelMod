-- Actual native Emerald weather state, exact owners and normal warp roundtrips.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL')));local Json=require('src.link.Json');assert(require('src.core.GameVersion').get()=='emerald')
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local C,S,A=V.require('Gen3Integration'),V.require('Gen3Scene'),V.require('Gen3HoennCaveEntrances')
 local Map,P,Field,Warp,Collision,Objects=require('src.core.game3.map'),require('src.core.game3.player'),require('src.core.game3.field'),require('src.core.game3.warp'),require('src.core.game3.collision'),require('src.core.game3.objects')
 local R,Space,Fade=require('src.core.game3.rse.init'),require('src.core.game3.scripting.space'),require('src.ui.game3.fade')
 local cases={{1,'ROUTE114',7,4},{2,'ROUTE114',6,46},{3,'ROUTE115',21,6},{4,'ROUTE115',36,10},{5,'ROUTE116',59,13},{6,'ROUTE116',79,6},{7,'ROUTE118',42,6},{8,'ROUTE118',9,6}}
 local refs,geometry={},{};local prepare,append=A.prepare,A.append
 A.prepare=function(cells,regions)local n=prepare(cells,regions);for _,c in pairs(cells)do if c.caveEntrance and c.caveEntrance.owner==c then local r=c.region;refs[r.def.id..':'..(c.cx-r.x)..':'..(c.cy-r.y)]=c end end;return n end
 A.append=function(c,emit,uvFor)local rows={};append(c,function(v,t,shade)rows[#rows+1]={vertices=v,uv=t,shade=shade};emit(v,t,shade)end,uvFor);if c.caveEntrance.owner==c then local r=c.region;geometry[r.def.id..':'..(c.cx-r.x)..':'..(c.cy-r.y)]=rows end end
 game:_handleBootAction({action='new_game',start={map='EM_ROUTE116',x=47,y=11,facing='up'}})
 V.require('RenderDistance').setting:sync(32);V.require('DayNight').setting:sync('day')
 local out={edition='emerald',closedWeatherPreserved=0,closed={},owners={},entries={},geometry=geometry,sourceSha256=love.data.encode('string','hex',love.data.hash('sha256',assert(V.mod:read('lib/Gen3HoennCaveEntrances.lua'))))}
 local function ready()
  game.input:reset();local n=0
  for _=1,3000 do U.wait(1);if not Warp.isBusy()and not Fade.lockInput and not Field.locked and not P.moving and not(Space.vm and Space.vm:isRunning())and not Space._pendingOnFrame then n=n+1 else n=0 end;if n>=6 then return end end;error('native field did not settle')
 end
 local function settle()
  local n,last=0;for _=1,3600 do U.wait(1);local a=S.streaming;if S.sceneDef==Map.currentDef()and a.started+a.promoted==a.completed+a.cancelled and a.started==last then n=n+1 else n=0 end;last=a.started;if n>=6 then break end end
  assert(n>=6 and C.active and C.recovery.failures==0);require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(3)
 end
 local function hash(d)local a={};for y=0,d.height-1 do for x=0,d.width-1 do local c=d.midLayout:cellAt(x,y);a[#a+1]=table.concat({c.mid,c.coll,c.elev},':')end end;return love.data.encode('string','hex',love.data.hash('sha256',table.concat(a,';')))end
 local function shot(name)assert(U.shot(game,os.getenv('SHOT_DIR')..'/'..name..'.png'))end
 local function load(q,state)
  C.setLevel(0,game);R.setVar('VAR_SHOULD_END_ABNORMAL_WEATHER',0,game.session);R.setVar('VAR_ABNORMAL_WEATHER_LOCATION',state,game.session)
  local map='EM_'..q[2];assert(Map.load(nil,game,map,{x=q[3],y=q[4]+1,facing='up'}));ready()
  assert(Collision.isWalkable(P.cellX,P.cellY)and not Objects.blocks(P.cellX,P.cellY),'weather mouth viewpoint must be native unoccupied walkable land')
  return Map.currentDef()
 end
 for _,q in ipairs(cases)do
  local key='EM_'..q[2]..':'..q[3]..':'..q[4];local name=q[1]..'-'..q[2]
  refs[key]=nil;local closed=load(q,0);local closedHash=hash(closed);assert(closed.midLayout:cellAt(q[3],q[4]).coll==7)
  C.setLevel(3,game);C.yaw=0;C.pitch=.24;settle();assert(not refs[key]and closedHash==hash(closed));out.closedWeatherPreserved=out.closedWeatherPreserved+1;out.closed[#out.closed+1]={map=closed.id,x=q[3],y=q[4],nativeHash=closedHash};shot(name..'-closed')
  local d=load(q,q[1]);local before=hash(d);local mouth=d.midLayout:cellAt(q[3],q[4]);assert(mouth.coll==113);shot(name..'-native')
  C.setLevel(3,game);C.yaw=0;C.pitch=.24;settle();local owner=assert(refs[key],'missing reviewed weather cave owner '..key)
  assert(owner.caveEntrance.owner==owner and owner.caveEntrance.header.caveEntrance==owner.caveEntrance)
  out.owners[#out.owners+1]={map=d.id,x=q[3],y=q[4],state=q[1],mid=owner.mid,header=owner.caveEntrance.header.mid,nativeHash=before}
  shot(name..'-front');C.setLevel(6,game);U.wait(4);shot(name..'-first');C.setLevel(7,game);C.yaw=math.pi/2;C.pitch=.5;U.wait(4);shot(name..'-side');C.yaw=math.pi;U.wait(4);shot(name..'-rear');assert(before==hash(d))
  for _,level in ipairs{0,3}do
   d=load(q,q[1]);before=hash(d);C.yaw=0;C.pitch=.24;C.setLevel(level,game);if level~=0 then settle()end
   for _=1,900 do U.hold(game,'up',1);if Map.currentDef().id~=d.id then break end end
   assert(Map.currentDef().id=='EM_TERRA_CAVE_ENTRANCE','native Terra entry failed');ready()
   local y=P.cellY;for _=1,600 do U.hold(game,'up',1);if P.cellY<y then break end end;ready()
   for _=1,1800 do U.hold(game,'down',1);if Map.currentDef().id==d.id and P.cellY>q[4]and not Warp.isBusy()then break end end
   assert(Map.currentDef().id==d.id,'native Terra return failed');ready();if level~=0 then settle()end
   assert(before==hash(Map.currentDef()),'native layout changed after weather cave entry')
   out.entries[#out.entries+1]={map=d.id,x=q[3],y=q[4],state=q[1],level=level,destination='EM_TERRA_CAVE_ENTRANCE',returned=true,nativeHash=before}
  end
  print('[HOENN WEATHER CAVE OWNER]',q[1],d.id,q[3],q[4],'native2D/3D returned')
 end
 assert(out.closedWeatherPreserved==8 and #out.owners==8 and #out.entries==16 and C.recovery.failures==0);out.recovery=0
 local f=assert(io.open(os.getenv('SHOT_DIR')..'/hoenn-weather-cave-entrances.json','wb'));f:write(Json.encode(out));f:close();print('PASS HOENN WEATHER CAVE ACCEPTANCE',#out.owners,#out.entries)
end
