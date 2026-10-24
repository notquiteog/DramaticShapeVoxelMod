-- Isolated native source/door/footprint review for standard HGSS FR/LG Centers.
-- All18 detected standard drawings, including the blocked Saffron projection.
-- QA_UTIL names the external helper; QA_START/QA_INDEX support bounded reruns.
return function(game)
 local family='centers';local fixtures={{'FR_CELADON_CITY',46,7,5},{'FR_CERULEAN_CITY',20,15,5},{'FR_CINNABAR_ISLAND',12,7,5},{'FR_FIVE_ISLAND',16,2,5},{'FR_FOUR_ISLAND',16,16,5},{'FR_FUCHSIA_CITY',23,27,5},{'FR_LAVENDER_TOWN',4,1,5},{'FR_PEWTER_CITY',15,21,5},{'FR_ROUTE_10',11,16,5},{'FR_ROUTE_4',10,1,5},{'FR_SAFFRON_CITY',22,34,5},{'FR_SEVEN_ISLAND',10,0,4},{'FR_SIX_ISLAND',9,7,5},{'FR_THREE_ISLAND',12,23,5},{'FR_TWO_ISLAND',19,3,5},{'FR_VIRIDIAN_CITY',24,22,5},{'FR_VERMILION_CITY',13,2,5},{'FR_SAFFRON_CITY_CONNECTION',12,27,5}}
 assert(love.filesystem.getIdentity():match('%-qa$'))
 -- QA fixture only: suppress independent fresh-game Rival scripts, never save.
 local U=dofile(assert(os.getenv('QA_UTIL'),'QA_UTIL must name the external engine frame-driver helper'))
 local edition=require('src.core.GameVersion').get();assert(edition=='firered'or edition=='leafgreen')
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C,S=V.require('Gen3Integration'),V.require('Gen3Scene');local Map,P=require('src.core.game3.map'),require('src.core.game3.player')
 local doorDraws={};local doors=V.require('Gen3KantoCenterDoors');local draw=doors.draw
 doors.draw=function(g,anim,fn)local ok=draw(g,anim,fn);if ok then doorDraws[Map.currentDef().id..':'..g.cx..':'..g.cy]=true end;return ok end
 local observed={};local adapter=V.require('Gen3ImportedKantoCenters');local original=adapter.build;adapter.build=function(g,...)local ok,why=original(g,...);if ok then observed[Map.currentDef().id..':'..g.cx..':'..g.cy]=assert(g.importedKantoCenter).model end;return ok,why end
 local dir=os.getenv('SHOT_DIR');local json=require('src.link.Json');local out={};local missing=os.getenv('QA_MISSING_ASSETS')=='1'
 if missing then local read=V.mod.read;V.mod.read=function(self,path)if path:match('^assets/scenery/hgss%-center/')then return nil end;return read(self,path)end end
 game:_handleBootAction({action='new_game',start={map='FR_PEWTER_CITY',x=10,y=32,facing='up'}})
 local F=require('src.core.game3.scripting.flags');local store=assert(require('src.core.game3.scripting.space').store);F.setVar(store,nil,0x4086,1);F.setFlag(store,nil,0x97,true);F.setFlag(store,nil,0x3E,true);F.setVar(store,nil,0x4089,1);F.setFlag(store,nil,0x98,true)
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
  local map,cx,cy=q[1],q[2],q[3];local doorX,doorY=2,q[4]-1;C.setLevel(0,game);assert(Map.load(nil,game,map,{x=cx+doorX,y=cy+doorY+2,facing='up'}));game.input:reset();local before=hash(Map.currentDef())
  C.yaw=0;C.pitch=math.rad(8);C.setLevel(3,game);settle()
  local n=S.performanceSnapshot().scenery['kantoCenters'];assert(missing and n==0 or not missing and n>0,'source/fallback mismatch')
  local model=observed[map..':'..cx..':'..cy];assert(missing and not model or not missing and model=='hgss_kanto_center','exact Center source absent')
  assert(missing or doorDraws[map..':'..cx..':'..cy],'original source door did not reach scene draw')
  shot(index..'-modern')
  if os.getenv('QA_QUICK')~='1'then for _,v in ipairs{{'front',cx+doorX,cy+doorY+2,0},{'left',cx-3,cy+2,math.pi/2},{'right',cx+7,cy+2,-math.pi/2},{'rear',cx+doorX,cy-2,math.pi}}do
   P.reset(v[2],v[3],'up');C.yaw=v[4];C.setLevel(6,game);settle();shot(index..'-'..v[1])
  end end
  C.yaw=0;C.setLevel(3,game);P.reset(cx+doorX,cy+doorY+1,'up');game.input:reset();settle()
  local destination;local projection=map=='FR_SAFFRON_CITY_CONNECTION'
  if not projection then local doors=require('src.core.game3.doors');local seen={}
  for _=1,160 do U.hold(game,'up',1);local a=doors.getActiveAnim();if a and not seen[a.frame]then seen[a.frame]=true;shot(index..'-enter-'..a.frame)end;if Map.currentDef().id~=map then break end end
  for _=1,300 do U.wait(1);if Map.currentDef().id~=map then break end end
  assert(Map.currentDef().id~=map,'native entrance failed');destination=Map.currentDef().id;settle();U.wait(90);shot(index..'-interior');U.wait(30)
  for _=1,260 do U.hold(game,'down',1);if Map.currentDef().id==map then break end end
  assert(Map.currentDef().id==map,'native return failed');settle();U.wait(90);shot(index..'-returned');assert(hash(Map.currentDef())==before,'native layout mutated')
  else for _,w in ipairs(Map.currentDef().warps or{})do assert(not(w.x==cx+doorX and w.y==cy+doorY),'projection gained native warp')end;assert(hash(Map.currentDef())==before)end
  C.setLevel(0,game);U.wait(15);shot(index..'-native')
  out[#out+1]={edition=require('src.core.GameVersion').get(),map=map,x=cx,y=cy,runtime='v'..require('src.core.Version').engine,sourceModel=not missing and'hgss_kanto_center'or nil,nativeHash=before,destination=destination,returned=not projection,nonEnterable=projection,renderedVerified=false,missingAssets=missing}
  local f=assert(io.open(dir..'/results.json','w'));f:write(json.encode(out));f:close()
 end end
 local f=assert(io.open(dir..'/results.json','w'));f:write(json.encode(out));f:close();print('[FRLG IMPORTED EXTERIORS] PASS',family,#out)
end
