-- Actual native entry/return and multi-angle inspection; disposable identity.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL')));local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local E,C,S=V.require('Gen3CaveEntrances'),V.require('Gen3Integration'),V.require('Gen3Scene')
 local Map,P=require('src.core.game3.map'),require('src.core.game3.player');local json=require('src.link.Json')
 local dir=assert(os.getenv('SHOT_DIR'));local observed={};local prepare=E.prepare
 E.prepare=function(cells,regions)
  local n=prepare(cells,regions)
  for _,c in pairs(cells)do if c.caveEntrance then local r=c.region;observed[r.def.id..':'..(c.cx-r.x)..':'..(c.cy-r.y)]=true end end
  if os.getenv('QA_DEBUG')=='1'then for _,r in ipairs(regions)do for _,p in ipairs(E.locations[r.def.id]or{})do
   local x,y=r.x+p[1],r.y+p[2];local c=cells[x..':'..y]
   if c and not c.caveEntrance then
    print('[MOUTH REJECT]',r.def.id,p[1],p[2])
    for _,d in ipairs{{0,0},{0,-1},{-1,0},{1,0},{0,1}}do local a=cells[(x+d[1])..':'..(y+d[2])];if a then print('[MOUTH DEBUG]',d[1],d[2],a.mid,a.collision,a.base,a.shape.kind,a.shape.height,a.pair,a.column~=nil,a.civic~=nil,a.prop~=nil,a.stairs~=nil)end end
    local h=cells[x..':'..(y-1)]and cells[x..':'..(y-1)].shape.height or 16
    c.caveEntrance={height=h};local ah=V.require('Gen3Terrain').height(cells,x*16+8,y*16+8,h)-(c.base or 0)
    for _,xx in ipairs{0,3,5,11,13,16}do for _,zz in ipairs{0,4,8,12,16}do local h=V.require('Gen3Terrain').height(cells,x*16+xx,y*16+zz,h);local expected=(c.base or 0)+ah*math.min(1,(16-zz)/4);if math.abs(h-expected)>1e-7 then print('[MOUTH SEAM]',xx,zz,h,expected)end end end;c.caveEntrance=nil
   end
  end end end
  return n
 end
 game:_handleBootAction({action='new_game',start={map='FR_ROUTE_4',x=19,y=7,facing='up'}})
 -- Own completed-story walking fixture. Production keeps every native guard,
 -- trainer challenge, introduction and tunnel progression restriction.
 local F=require('src.core.game3.scripting.flags');F.setFlag(assert(require('src.core.game3.scripting.space').store),nil,92,true)
 local store=assert(require('src.core.game3.scripting.space').store)
 F.setVar(store,nil,0x4086,1);F.setFlag(store,nil,0x97,true) -- Four Island after Rival introduction
 F.setFlag(store,nil,0x840,true) -- Native National Dex opens the completed Dunsparce Tunnel
 for id=1,767 do F.setTrainerDefeated(store,nil,id,true)end -- own postgame walking fixture; prevent unrelated sight battles
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day');V.require('RenderDistance').haze=function()return nil end
 local fixtures={};for map,points in pairs(E.locations)do for _,p in ipairs(points)do fixtures[#fixtures+1]={map,p[1],p[2]}end end
 table.sort(fixtures,function(a,b)return a[1]<b[1]or a[1]==b[1]and(a[2]<b[2]or a[2]==b[2]and a[3]<b[3])end)
 local function settle(allowInactive)
  if allowInactive and not C.active then U.wait(10);return end
  local stable,last=0
  for _=1,2000 do U.wait(1);local a=S.streaming
   if S.sceneDef==Map.currentDef()and a.started+a.promoted==a.completed+a.cancelled and last==a.started then stable=stable+1 else stable=0 end
   last=a.started;if stable>=6 then break end
  end
  assert(stable>=6 and C.active and C.recovery.failures==0,'cave scene failed')
  require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(3)
 end
 local function shot(name)assert(U.shot(game,dir..'/'..name..'.png'))end
 local function hash(d)local raw={};for y=0,d.height-1 do for x=0,d.width-1 do local c=d.midLayout:cellAt(x,y);raw[#raw+1]=table.concat({c.mid,c.coll,c.elev},':')end end;return love.data.encode('string','hex',love.data.hash('sha256',table.concat(raw,';')))end
 local sourceHashes={}
 for _,path in ipairs{'lib/Gen3CaveEntrances.lua','lib/Gen3Scene.lua','lib/Gen3Terrain.lua','lib/Gen3RouteGates.lua'}do sourceHashes[path]=love.data.encode('string','hex',love.data.hash('sha256',assert(V.mod:read(path))))end
 local out={};local first,last=tonumber(os.getenv('QA_START')or 1),tonumber(os.getenv('QA_END')or 999)
 for index,q in ipairs(fixtures)do if index>=first and index<=last then
  local map,x,y=unpack(q);C.setLevel(0,game);assert(Map.load(nil,game,map,{x=x,y=y+2,facing='up'}));game.input:reset();U.wait(80)
  require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss()
  local before=hash(Map.currentDef());shot(index..'-native')
  C.yaw=0;C.pitch=math.rad(8);C.setLevel(3,game);settle();assert(observed[map..':'..x..':'..y],'exact cave mouth was not modeled: '..map..':'..x..':'..y);shot(index..'-overview')
  for _,a in ipairs{{'front',0,2,0},{'left',-1,2,math.pi/6},{'right',1,2,-math.pi/6},{'threshold',0,1,0}}do
   if x+a[2]>=0 then P.reset(x+a[2],y+a[3],'up');C.yaw=a[4];C.setLevel(6,game);settle();shot(index..'-'..a[1])end
  end
  C.setLevel(3,game);C.yaw=0;P.reset(x,y+1,'up');game.input:reset();settle()
  local expected;for _,w in ipairs(Map.currentDef().warps or{})do if w.x==x and w.y==y then expected=w.destMap end end
  for _=1,900 do U.hold(game,'up',1);if Map.currentDef().id~=map then break end end;game.input:reset()
  if Map.currentDef().id~=expected then shot(index..'-entry-failed');print('[CAVE ENTRY STATE]',map,P.cellX,P.cellY,P.moving,F.getFlag(assert(require('src.core.game3.scripting.space').store),nil,92))end
  assert(Map.currentDef().id==expected,'native cave entry failed: '..map);U.wait(110);settle(true);shot(index..'-inside');local back={}for _,w in ipairs(Map.currentDef().warps or{})do if w.destMap==map then back[#back+1]=w end end;print('[CAVE INSIDE SPAWN]',index,P.cellX,P.cellY,json.encode(back));local cc=Map.currentDef().midLayout:cellAt(P.cellX,P.cellY);print('[CAVE EXIT TILE]',cc.mid,cc.coll,require('src.core.game3.collision').behavior(P.cellX,P.cellY))
  local Collision=require('src.core.game3.collision');local exitDir=Collision.arrowWarpDir(Collision.behavior(P.cellX,P.cellY))
  if not exitDir and not Collision.isExitWarp(game,P.cellX,P.cellY)then
   U.hold(game,'down',16);game.input:reset();U.wait(24);exitDir='up'
  end
  exitDir=exitDir or'down'
  for _=1,900 do U.hold(game,exitDir,1);if Map.currentDef().id==map then break end end;game.input:reset()
  if Map.currentDef().id~=map then shot(index..'-return-failed');print('[CAVE RETURN STATE]',Map.currentDef().id,P.cellX,P.cellY)end
  assert(Map.currentDef().id==map,'native cave return failed: '..map);settle();U.wait(35);shot(index..'-returned');assert(hash(Map.currentDef())==before,'native map mutated')
  out[#out+1]={edition=require('src.core.GameVersion').get(),map=map,x=x,y=y,nativeHash=before,destination=expected,returned=true,runtime='v'..require('src.core.Version').engine,sourceHashes=sourceHashes,renderedVerified=false}
  local f=assert(io.open(dir..'/results.json','w'));f:write(json.encode(out));f:close();print('[CAVE ENTRY PASS]',index,map,x,y)
 end end
 assert(#game.mods.errors==0,table.concat(game.mods.errors,'\n'));print('[FRLG CAVE ENTRANCES] PASS',#out)
end
