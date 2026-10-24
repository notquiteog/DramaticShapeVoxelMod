-- Actual Scene owners, unchanged native layouts and normal outdoor cave entry.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL')));local edition=require('src.core.GameVersion').get();local pre=assert(({emerald='EM_',ruby='RU_',sapphire='SA_'})[edition])
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local C,S=V.require('Gen3Integration'),V.require('Gen3Scene');local A=V.require('Gen3HoennCaveEntrances')
 local Map,P=require('src.core.game3.map'),require('src.core.game3.player');local Warp,Fade,Field=require('src.core.game3.warp'),require('src.ui.game3.fade'),require('src.core.game3.field');local Space=require('src.core.game3.scripting.space')
 local refs,geometry={},{};local prepare=A.prepare
 A.prepare=function(cells,regions)
  local count=prepare(cells,regions)
  for _,c in pairs(cells)do if c.caveEntrance and c.caveEntrance.owner==c then local r=c.region;refs[r.def.id..':'..(c.cx-r.x)..':'..(c.cy-r.y)]=c end end
  return count
 end
 local append=A.append
 A.append=function(c,emit,uvFor)
  local p=c.caveEntrance;local rows={}
  append(c,function(v,t,shade)rows[#rows+1]={vertices=v,uv=t,shade=shade};emit(v,t,shade)end,uvFor)
  if p.owner==c then local r=c.region;geometry[r.def.id..':'..(c.cx-r.x)..':'..(c.cy-r.y)]=rows end
 end
 game:_handleBootAction({action='new_game',start={map=pre..'ROUTE116',x=47,y=11,facing='up'}})
 V.require('RenderDistance').setting:sync(32);V.require('DayNight').setting:sync('day')
 local function ready()
  game.input:reset();local n=0
  for _=1,3000 do U.wait(1)
   if not Warp.isBusy()and not Fade.lockInput and not Field.locked and not P.moving and not(Space.vm and Space.vm:isRunning())and not Space._pendingOnFrame then n=n+1 else n=0 end
   if n>=6 then return end
  end;error('native field did not settle')
 end
 local function settle()
  local n,last=0
  for _=1,3600 do U.wait(1);local a=S.streaming
   if S.sceneDef==Map.currentDef()and a.started+a.promoted==a.completed+a.cancelled and a.started==last then n=n+1 else n=0 end
   last=a.started;if n>=6 then break end
  end;assert(n>=6 and C.active and C.recovery.failures==0,'Scene did not settle')
  require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(3)
 end
 local function hash(d)local a={};for y=0,d.height-1 do for x=0,d.width-1 do local c=d.midLayout:cellAt(x,y);a[#a+1]=table.concat({c.mid,c.coll,c.elev},':')end end;return love.data.encode('string','hex',love.data.hash('sha256',table.concat(a,';')))end
 local out={edition=edition,fixture={FLAG_REGI_DOORS_OPENED=true},entries={},owners={},geometry=geometry,sourceSha256=love.data.encode('string','hex',love.data.hash('sha256',assert(V.mod:read('lib/Gen3HoennCaveEntrances.lua'))))};local targets={}
 for name,rows in pairs(A.locations)do for _,p in ipairs(rows)do targets[#targets+1]={map=pre..name,x=p[1],y=p[2]}end end
 if edition=='emerald'then for name,rows in pairs(A.emeraldLocations)do for _,p in ipairs(rows)do targets[#targets+1]={map=pre..name,x=p[1],y=p[2]}end end end
 if os.getenv('QA_MAP')then local filtered={};for _,q in ipairs(targets)do if q.map:match(os.getenv('QA_MAP'))then filtered[#filtered+1]=q end end;targets=filtered end
 table.sort(targets,function(a,b)return a.map==b.map and a.y<b.y or a.map<b.map end)
 local function shot(name)assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/'..name..'.png'))end
 -- Native on-load scripts seal the Regi exteriors before their story flag.
 -- Verify the closed live map first, then use an explicit disposable story
 -- fixture; production never opens a cave or changes its native flags.
 C.setLevel(0,game);assert(Map.load(nil,game,pre..'ROUTE105',{x=9,y=23,facing='up'}));ready()
 local closed=Map.currentDef();local closedHash=hash(closed);assert(closed.midLayout:cellAt(9,20).coll==7)
 C.setLevel(3,game);C.yaw=0;C.pitch=.24;settle();assert(not refs[pre..'ROUTE105:9:20']);assert(hash(closed)==closedHash)
 shot('regi-closed-native-preserved');out.closedRegiPreserved=true
 require('src.core.game3.rse.init').setFlag('FLAG_REGI_DOORS_OPENED',true,game.session)
 for _,q in ipairs(targets)do
  local def=assert(game.data.maps[q.map]);local layout=assert(Map.ensureMidLayout(game,q.map,def));local vx,vy
  for _,delta in ipairs{{0,3},{0,2},{1,3},{-1,3},{0,1},{1,2},{-1,2}}do local xx,yy=q.x+delta[1],q.y+delta[2]
   if xx>=0 and yy>=0 and xx<def.width and yy<def.height and layout:cellAt(xx,yy).coll==0 then vx,vy=xx,yy;break end
  end;assert(vx,'no native walkable cave viewpoint')
  C.setLevel(0,game);assert(Map.load(nil,game,q.map,{x=vx,y=vy,facing='up'}));ready();def=Map.currentDef();assert(def.id==q.map)
  assert(def.midLayout:cellAt(vx,vy).coll==0,'viewpoint changed native permission');local before=hash(def)
  local name=q.map..'-'..q.x..'-'..q.y
  if not os.getenv('QA_NO_SHOTS')then shot(name..'-native')end
  C.setLevel(3,game);C.yaw=0;C.pitch=.24;settle()
  local cell=refs[q.map..':'..q.x..':'..q.y]
  if not cell then
   local raw={};for yy=q.y-1,q.y+1 do for xx=q.x-1,q.x+1 do local t=def.midLayout:cellAt(xx,yy);raw[#raw+1]={x=xx,y=yy,mid=t.mid,collision=t.coll,elevation=t.elev}end end
   print('[HOENN CAVE OWNER MISSING]',name,require('src.link.Json').encode(raw))
  end
  assert(cell,'missing native cave owner '..name)
  assert(cell.caveEntrance.owner==cell and cell.caveEntrance.header.caveEntrance==cell.caveEntrance,'incomplete two-row ownership')
  out.owners[#out.owners+1]={map=q.map,x=q.x,y=q.y,mid=cell.mid,header=cell.caveEntrance.header.mid,nativeHash=before}
  if not os.getenv('QA_NO_SHOTS')then
   shot(name..'-front');C.setLevel(6,game);U.wait(4);shot(name..'-first');C.setLevel(7,game);C.yaw=math.pi/2;C.pitch=.5;U.wait(4);shot(name..'-side');C.yaw=math.pi;U.wait(4);shot(name..'-rear')
  end
  assert(before==hash(def),'native MID/collision/elevation mutated')
  print('[HOENN CAVE OWNER]',edition,q.map,q.x,q.y)
 end
 for _,level in ipairs{0,3}do
  C.setLevel(0,game);assert(Map.load(nil,game,pre..'ROUTE116',{x=47,y=9,facing='up'}));ready();local before=hash(Map.currentDef())
  C.yaw=0;C.pitch=.24;C.setLevel(level,game);if level~=0 then settle()end
  for _=1,600 do U.hold(game,'up',1);if Map.currentDef().id~=pre..'ROUTE116'then break end end
  assert(Map.currentDef().id==pre..'RUSTURF_TUNNEL','native cave entry failed');ready()
  local y=P.cellY;for _=1,600 do U.hold(game,'up',1);if P.cellY<y then break end end;ready()
  for _=1,1800 do U.hold(game,'down',1);if Map.currentDef().id==pre..'ROUTE116'and P.cellY>8 and not Warp.isBusy()then break end end
  assert(Map.currentDef().id==pre..'ROUTE116','native cave return failed');ready()
  if level~=0 then settle()end
  assert(before==hash(Map.currentDef()),'native layout changed after cave entry')
  out.entries[#out.entries+1]={level=level,destination=pre..'RUSTURF_TUNNEL',returned=true,nativeHash=before}
 end
 assert(C.recovery.failures==0);out.recovery=0
 local f=assert(io.open(assert(os.getenv('SHOT_DIR'))..'/hoenn-cave-entrances.json','wb'));f:write(require('src.link.Json').encode(out));f:close()
 print('[HOENN CAVE ENTRANCES ACCEPTANCE]',edition,#out.owners,#out.entries,'unchanged-grid',C.recovery.failures)
end
