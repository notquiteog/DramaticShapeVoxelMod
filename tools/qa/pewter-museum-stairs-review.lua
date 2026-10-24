-- Isolated Pewter Museum solid-stair/native-portal review.
-- QA_UTIL names the external engine frame-driver helper; use a disposable *-qa profile.
return function(game)
 local family='museum'
 local config={pendingGround=false,fixtures={{'FR_PEWTER_CITY',12,0,5,6},{'FR_PEWTER_CITY',12,0,13,4}},adapter='Gen3ImportedPewterMuseum',model='hgss_pewter_museum',doorX=5,doorY=6,stat='pewterMuseum',source='^assets/scenery/pewter%-museum/',right=17,left={-2,4,math.pi/2},rear={8,-2,math.pi}}
 local fixtures=config.fixtures;local doorX,doorY=config.doorX,config.doorY
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL'),'QA_UTIL must name the external engine frame-driver helper'))
 local edition=require('src.core.GameVersion').get();assert(edition=='firered'or edition=='leafgreen')
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C,S=V.require('Gen3Integration'),V.require('Gen3Scene');local Map,P=require('src.core.game3.map'),require('src.core.game3.player')
 local observed={};local adapter=V.require(config.adapter);local original=adapter.build;adapter.build=function(g,...)local ok,why=original(g,...);if ok then observed[Map.currentDef().id..':'..g.cx..':'..g.cy]=g.importedPewterMuseum.model or adapter.id end;return ok,why end
 local dir=os.getenv('SHOT_DIR');local json=require('src.link.Json');local out={};local missing=os.getenv('QA_MISSING_ASSETS')=='1'
 if missing then local read=V.mod.read;V.mod.read=function(self,path)if path:match(config.source)then return nil end;return read(self,path)end end
 game:_handleBootAction({action='new_game',start={map='FR_PEWTER_CITY',x=10,y=32,facing='up'}})
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day');V.require('RenderDistance').haze=function()return nil end
 local function settle()
  local stable,last=0
  for _=1,2000 do U.wait(1);local a=S.streaming
   if S.sceneDef==Map.currentDef()and a.started+a.promoted==a.completed+a.cancelled and last==a.started then stable=stable+1 else stable=0 end
   last=a.started;if stable>=6 then break end
  end;assert(stable>=6 and C.active and C.recovery.failures==0,'renderer/stream failure')
  require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(3)
 end
 local function shot(n)assert(U.shot(game,dir..'/'..n..'.png'))end
 local function hash(d)local a={};for y=0,d.height-1 do for x=0,d.width-1 do local c=d.midLayout:cellAt(x,y);a[#a+1]=table.concat({c.mid,c.coll,c.elev},':')end end;return love.data.encode('string','hex',love.data.hash('sha256',table.concat(a,';')))end
 for index,q in ipairs(fixtures)do if index>=tonumber(os.getenv('QA_START')or'1')and(not os.getenv('QA_INDEX')or index==tonumber(os.getenv('QA_INDEX')))then
  local map,cx,cy=q[1],q[2],q[3];local doorX,doorY=q[4]or config.doorX,q[5]or config.doorY;local pendingGround=false;C.setLevel(0,game);assert(Map.load(nil,game,map,{x=cx+doorX,y=cy+doorY+2,facing='up'}));game.input:reset();local before=hash(Map.currentDef())
  C.yaw=0;C.pitch=math.rad(8);C.setLevel(3,game);settle()
  local n=S.performanceSnapshot().scenery[config.stat];assert(missing and n==0 or not missing and n>0,'source/fallback mismatch')
  if config.model then local model=observed[map..':'..cx..':'..cy];assert(missing and not model or not missing and model==config.model,'exact regional source placement absent')end
  shot(index..'-modern')
  local left,rear=config.left or{-3,2,math.pi/2},config.rear or{doorX,-2,math.pi}
  if os.getenv('QA_QUICK')~='1'then for _,v in ipairs{{'front',cx+doorX,cy+doorY+2,0},{'rotated',cx+2,cy+9,math.pi/6},{'right-quarter',cx+9,cy+9,-math.pi/6},{'left',cx+left[1],cy+left[2],left[3]},{'right',cx+(config.right or 7),cy+2,-math.pi/2},{'rear',cx+rear[1],cy+rear[2],rear[3]}}do
   if v[2]>=0 and v[2]<Map.currentDef().width and v[3]>=0 and v[3]<Map.currentDef().height then P.reset(v[2],v[3],'up');C.yaw=v[4];C.setLevel(6,game);settle();shot(index..'-'..v[1])else print('[FRLG VIEW OUTSIDE NATIVE BOUNDS]',map,v[1])end
  end end
  local destination
  if map~='FR_SAFFRON_CITY_CONNECTION'then
  C.yaw=0;C.setLevel(3,game);P.reset(cx+doorX,cy+doorY+1,'up');game.input:reset();settle()
  local doors=require('src.core.game3.doors');local seen={}
  for _=1,160 do U.hold(game,'up',1);local a=doors.getActiveAnim();if a and not seen[a.frame]then seen[a.frame]=true;shot(index..'-enter-'..a.frame)end;if Map.currentDef().id~=map then break end end
  for _=1,300 do U.wait(1);if Map.currentDef().id~=map then break end end
  assert(Map.currentDef().id~=map,'native entrance failed');destination=Map.currentDef().id;settle();U.wait(90);shot(index..'-interior');U.wait(30)
  for _=1,260 do U.hold(game,'down',1);if Map.currentDef().id==map then break end end
  assert(Map.currentDef().id==map,'native return failed');settle();U.wait(90);shot(index..'-returned');assert(hash(Map.currentDef())==before,'native layout mutated')
  else for _,w in ipairs(Map.currentDef().warps or{})do assert(not(w.x==cx+doorX and w.y==cy+doorY),'projection has an unexpected native warp')end;assert(hash(Map.currentDef())==before,'native projection mutated')end
  C.setLevel(0,game);U.wait(15);shot(index..'-native')
  out[#out+1]={edition=require('src.core.GameVersion').get(),map=map,x=cx,y=cy,runtime='v'..require('src.core.Version').engine,doorX=doorX,doorY=doorY,sourceModel=not missing and config.model or nil,nativeHash=before,destination=destination,returned=map~='FR_SAFFRON_CITY_CONNECTION',nonEnterable=map=='FR_SAFFRON_CITY_CONNECTION',renderedVerified=not missing and not pendingGround,renderedGap=pendingGround and'Shared native-ground donor assessment pending.'or nil,missingAssets=missing}
  local f=assert(io.open(dir..'/results.json','w'));f:write(json.encode(out));f:close()
 end end
 local f=assert(io.open(dir..'/results.json','w'));f:write(json.encode(out));f:close();print('[FRLG IMPORTED EXTERIORS] PASS',family,#out)
end
