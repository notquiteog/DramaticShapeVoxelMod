return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL')));local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C,S=V.require('Gen3Integration'),V.require('Gen3Scene');local Map,P=require('src.core.game3.map'),require('src.core.game3.player');local Json=require('src.link.Json')
 local open=os.getenv('QA_DOTTED_OPEN')=='1';local D=V.require('Gen3DottedHoleEntrance');local prepare=D.prepare;local seen=false
 D.prepare=function(...)local n=prepare(...);seen=seen or n==1;return n end
 game:_handleBootAction({action='new_game',start={map='FR_SIX_ISLAND_RUIN_VALLEY',x=24,y=26,facing='up'}})
 local F=require('src.core.game3.scripting.flags');local store=assert(require('src.core.game3.scripting.space').store)
 F.setFlag(store,nil,F.IDS.HIDE_RUIN_VALLEY_SCIENTIST,true) -- own unoccluded source-view fixture only
 F.setFlag(store,nil,F.IDS.USED_CUT_ON_RUIN_VALLEY_BRAILLE,open)
 assert(Map.load(nil,game,'FR_SIX_ISLAND_RUIN_VALLEY',{x=24,y=26,facing='up'}));U.wait(90)
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day');V.require('RenderDistance').haze=function()return nil end
 local function hash(d)local a={};for y=0,d.height-1 do for x=0,d.width-1 do local c=d.midLayout:cellAt(x,y);a[#a+1]=table.concat({c.mid,c.coll,c.elev},':')end end;return love.data.encode('string','hex',love.data.hash('sha256',table.concat(a,';')))end
 local function settle()
  local stable,last=0
  for _=1,1500 do U.wait(1);local a=S.streaming;if S.sceneDef==Map.currentDef()and a.started+a.promoted==a.completed+a.cancelled and last==a.started then stable=stable+1 else stable=0 end;last=a.started;if stable>=6 then break end end
  assert(stable>=6 and C.active and C.recovery.failures==0)
  require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(3)
 end
 local dir=assert(os.getenv('SHOT_DIR'));local function shot(name)assert(U.shot(game,dir..'/'..name..'.png'))end
 local shadow=V.require('Shadows').setting;local oldShadow=shadow:get();if os.getenv('QA_DOTTED_SHADOWS')=='off'then shadow:sync('off')end
 local before=hash(Map.currentDef());local door=Map.currentDef().midLayout:cellAt(24,24);assert(door.mid==(open and 856 or 855)and door.coll==(open and 113 or 7))
 C.yaw=0;C.pitch=.12;C.setLevel(3,game);settle();assert(seen,'native Dotted Hole source assembly not claimed');shot('overview')
 for _,a in ipairs{{'front',24,26,0},{'left',22,26,math.pi/6},{'right',26,26,-math.pi/6},{'threshold',24,25,0}}do P.reset(a[2],a[3],'up');C.yaw=a[4];C.setLevel(6,game);settle();shot(a[1])end
 C.yaw=0;C.setLevel(3,game);P.reset(24,25,'up');game.input:reset();settle()
 if open then
  for _=1,900 do U.hold(game,'up',1);if Map.currentDef().id~='FR_SIX_ISLAND_RUIN_VALLEY'then break end end;game.input:reset();assert(Map.currentDef().id=='FR_SIX_ISLAND_DOTTED_HOLE_1F','original opened entrance failed');U.wait(130);settle();shot('inside')
  for _=1,900 do U.hold(game,'down',1);if Map.currentDef().id=='FR_SIX_ISLAND_RUIN_VALLEY'then break end end;game.input:reset();assert(Map.currentDef().id=='FR_SIX_ISLAND_RUIN_VALLEY','original native return failed');settle();shot('returned')
 else
  U.hold(game,'up',40);game.input:reset();U.wait(24);assert(P.cellX==24 and P.cellY==25 and Map.currentDef().id=='FR_SIX_ISLAND_RUIN_VALLEY','native sealed slab bypassed');shot('closed-bump')
 end
 -- The two original lower projection cells stay walkable; the physical
 -- columns stop in the blocked row instead of moving into that native lane.
 for _,x in ipairs{23,25}do
  P.reset(x,26,'up');game.input:reset()
  for _=1,50 do U.hold(game,'up',1);if P.moving then break end end;game.input:reset();U.wait(24);assert(P.cellX==x and P.cellY==25,'native projection walking failed')
  U.hold(game,'up',30);game.input:reset();U.wait(24);assert(P.cellX==x and P.cellY==25,'native column collision changed')
 end
 settle();shot('projection-walked');assert(hash(Map.currentDef())==before,'native source map mutated')
 local hashes={};for _,p in ipairs{'lib/Gen3DottedHoleEntrance.lua','lib/Gen3CaveEntrances.lua','lib/Gen3Terrain.lua','lib/Gen3Scene.lua'}do hashes[p]=love.data.encode('string','hex',love.data.hash('sha256',assert(V.mod:read(p))))end
 local result={edition=require('src.core.GameVersion').get(),map='FR_SIX_ISLAND_RUIN_VALLEY',x=24,y=24,state=open and'native_cut_opened'or'closed_braille',nativeHash=before,nativeProjectionWalked=true,returned=open,nativeClosedBump=not open,runtime='v'..require('src.core.Version').engine,sourceHashes=hashes,renderedVerified=false}
 local f=assert(io.open(dir..'/results.json','w'));f:write(Json.encode({result}));f:close();if os.getenv('QA_DOTTED_SHADOWS')=='off'then shadow:sync(oldShadow)end;assert(#game.mods.errors==0);print('[DOTTED HOLE NATIVE] PASS',result.state)
end
