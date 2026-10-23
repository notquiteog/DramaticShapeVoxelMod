-- Isolated native source/door/footprint review for new FR/LG regional exteriors.
-- QA_FAMILY=houses|gyms|gyms_all|viridian_flowers|lavender|name_rater|cerulean_gym; QA_UTIL names the external engine frame-driver helper.
return function(game)
 local family=os.getenv('QA_FAMILY')or'gyms'
 local configs={
  gyms={fixtures={{'FR_PEWTER_CITY',12,12},{'FR_VIRIDIAN_CITY',33,6}},doorX=3,doorY=4,stat='hgssGyms',source='^assets/scenery/hgss%-kanto%-gyms/',right=9},
  gyms_all={fixtures={{'FR_PEWTER_CITY',12,12},{'FR_VIRIDIAN_CITY',33,6},{'FR_CERULEAN_CITY',28,17}},doorX=3,doorY=4,stat='hgssGyms',source='^assets/scenery/hgss%-kanto%-gyms/',right=9},
  cerulean_gym={fixtures={{'FR_CERULEAN_CITY',28,17}},doorX=3,doorY=4,stat='hgssGyms',source='^assets/scenery/hgss%-kanto%-gyms/hgss_cerulean_gym/',right=9},
  houses={fixtures={{'FR_PEWTER_CITY',8,28},{'FR_PEWTER_CITY',32,9}},doorX=1,doorY=2,stat='pewterHouses',source='^assets/scenery/pewter%-house/'},
  viridian_flowers={fixtures={{'FR_VIRIDIAN_CITY',24,15}},doorX=1,doorY=3,stat='viridianFlowerHouses',source='^assets/scenery/viridian%-house/'},
  lavender={fixtures={{'FR_LAVENDER_TOWN',8,8},{'FR_LAVENDER_TOWN',3,13}},doorX=2,doorY=3,stat='lavenderHouses',source='^assets/scenery/lavender%-house/'},
  name_rater={fixtures={{'FR_LAVENDER_TOWN',8,13}},doorX=2,doorY=3,stat='lavenderNameRater',source='^assets/scenery/lavender%-name%-rater/',left={-1,4,math.pi/4},rear={6,-1,-3*math.pi/4}},
 }
 local config=assert(configs[family],'unreviewed source family');local fixtures=config.fixtures;local doorX,doorY=config.doorX,config.doorY
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL'),'QA_UTIL must name the external engine frame-driver helper'))
 local edition=require('src.core.GameVersion').get();assert(edition=='firered'or edition=='leafgreen')
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C,S=V.require('Gen3Integration'),V.require('Gen3Scene');local Map,P=require('src.core.game3.map'),require('src.core.game3.player')
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
 for index,q in ipairs(fixtures)do
  local map,cx,cy=q[1],q[2],q[3];C.setLevel(0,game);assert(Map.load(nil,game,map,{x=cx+doorX,y=cy+doorY+2,facing='up'}));game.input:reset();local before=hash(Map.currentDef())
  C.yaw=0;C.pitch=math.rad(8);C.setLevel(3,game);settle()
  local n=S.performanceSnapshot().scenery[config.stat];assert(missing and n==0 or not missing and n>0,'source/fallback mismatch')
  shot(index..'-modern')
  local left,rear=config.left or{-3,2,math.pi/2},config.rear or{doorX,-2,math.pi}
  if os.getenv('QA_QUICK')~='1'then for _,v in ipairs{{'front',cx+doorX,cy+doorY+2,0},{'left',cx+left[1],cy+left[2],left[3]},{'right',cx+(config.right or 7),cy+2,-math.pi/2},{'rear',cx+rear[1],cy+rear[2],rear[3]}}do
   P.reset(v[2],v[3],'up');C.yaw=v[4];C.setLevel(6,game);settle();shot(index..'-'..v[1])
  end end
  C.yaw=0;C.setLevel(3,game);P.reset(cx+doorX,cy+doorY+1,'up');game.input:reset();settle()
  local doors=require('src.core.game3.doors');local seen={}
  for _=1,160 do U.hold(game,'up',1);local a=doors.getActiveAnim();if a and not seen[a.frame]then seen[a.frame]=true;shot(index..'-enter-'..a.frame)end;if Map.currentDef().id~=map then break end end
  for _=1,300 do U.wait(1);if Map.currentDef().id~=map then break end end
  assert(Map.currentDef().id~=map,'native entrance failed');local destination=Map.currentDef().id;settle();U.wait(90);shot(index..'-interior');U.wait(30)
  for _=1,260 do U.hold(game,'down',1);if Map.currentDef().id==map then break end end
  assert(Map.currentDef().id==map,'native return failed');settle();U.wait(90);shot(index..'-returned');assert(hash(Map.currentDef())==before,'native layout mutated')
  C.setLevel(0,game);U.wait(15);shot(index..'-native')
  out[#out+1]={edition=require('src.core.GameVersion').get(),map=map,x=cx,y=cy,nativeHash=before,destination=destination,returned=true,missingAssets=missing}
 end
 local f=assert(io.open(dir..'/results.json','w'));f:write(json.encode(out));f:close();print('[FRLG IMPORTED EXTERIORS] PASS',family,#out)
end
