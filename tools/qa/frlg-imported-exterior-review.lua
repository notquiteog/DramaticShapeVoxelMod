-- Isolated native source/door/footprint review for new FR/LG regional exteriors.
-- QA_FAMILY=houses|gyms|gyms_all|viridian_flowers|lavender|name_rater|cerulean_gym|marts; QA_UTIL names the external engine frame-driver helper.
return function(game)
 local family=os.getenv('QA_FAMILY')or'gyms'
 local configs={
  celadon_short={front=4,frontX=4,frontYaw=-math.pi/3,walkWidth=4,noEntrance=true,fixtures={{'FR_CELADON_CITY',20,26}},adapter='Gen3ImportedCeladonShortHouse',model='hgss_celadon_short_house',doorX=1,doorY=3,stat='celadonShortHouse',source='^assets/scenery/celadon%-short%-house/',right=5,left={0,-1,math.pi},rear={2,-2,math.pi}},
  cerulean_closed={noEntrance=true,fixtures={{'FR_CERULEAN_CITY',31,25}},adapter='Gen3ImportedCeruleanClosedHouse',model='hgss_cerulean_closed_house',doorX=2,doorY=3,stat='ceruleanClosedHouse',source='^assets/scenery/cerulean%-closed%-house/',right=6,left={-1,3,math.pi/2},rear={2,-2,math.pi}},
  psychic={pendingGround=false,fixtures={{'FR_SAFFRON_CITY',46,17},{'FR_SAFFRON_CITY_CONNECTION',36,10}},adapter='Gen3ImportedSaffronPsychic',model='hgss_saffron_psychic',doorX=1,doorY=4,stat='saffronPsychic',source='^assets/scenery/saffron%-psychic/',right=7,left={-2,5,math.pi/4},rear={2,-2,math.pi}},
  copycat={pendingGround=false,fixtures={{'FR_SAFFRON_CITY',21,10},{'FR_SAFFRON_CITY_CONNECTION',11,3}},adapter='Gen3ImportedSaffronCopycat',model='hgss_saffron_copycat',doorX=1,doorY=4,stat='saffronCopycat',source='^assets/scenery/saffron%-copycat/',right=7,left={-2,5,math.pi/4},rear={2,-2,math.pi}},
  museum={pendingGround=true,fixtures={{'FR_PEWTER_CITY',12,0,5,6},{'FR_PEWTER_CITY',12,0,13,4}},adapter='Gen3ImportedPewterMuseum',model='hgss_pewter_museum',doorX=5,doorY=6,stat='pewterMuseum',source='^assets/scenery/pewter%-museum/',right=17,left={-2,4,math.pi/2},rear={8,-2,math.pi}},
  viridian_plain={fixtures={{'FR_VIRIDIAN_CITY',24,8}},adapter='Gen3ImportedViridianHouses',model='hgss_viridian_house',doorX=1,doorY=3,stat='viridianHouses',source='^assets/scenery/viridian%-house/',right=7},
  marts_story={fixtures={{'FR_FOUR_ISLAND',20,23},{'FR_VIRIDIAN_CITY',34,16}},adapter='Gen3ImportedHGSSMarts',model='hgss_kanto_mart',doorX=2,doorY=3,stat='hgssMarts',source='^assets/scenery/hgss%-mart/',right=6,left={-1,4,math.pi/4},rear={2,-3,math.pi}},
  marts={fixtures={{'FR_CERULEAN_CITY',27,25},{'FR_CINNABAR_ISLAND',17,8},{'FR_FOUR_ISLAND',20,23},{'FR_FUCHSIA_CITY',9,12},{'FR_LAVENDER_TOWN',18,12},{'FR_PEWTER_CITY',26,15},{'FR_SAFFRON_CITY',38,18},{'FR_SAFFRON_CITY_CONNECTION',28,11},{'FR_SIX_ISLAND',18,8},{'FR_THREE_ISLAND',16,9},{'FR_VERMILION_CITY',27,14},{'FR_VIRIDIAN_CITY',34,16}},adapter='Gen3ImportedHGSSMarts',model='hgss_kanto_mart',doorX=2,doorY=3,stat='hgssMarts',source='^assets/scenery/hgss%-mart/',right=6,left={-1,4,math.pi/4},rear={2,-3,math.pi}},
  marts_pilot={fixtures={{'FR_PEWTER_CITY',26,15},{'FR_SAFFRON_CITY',38,18},{'FR_SAFFRON_CITY_CONNECTION',28,11}},adapter='Gen3ImportedHGSSMarts',model='hgss_kanto_mart',doorX=2,doorY=3,stat='hgssMarts',source='^assets/scenery/hgss%-mart/',right=6,left={-1,4,math.pi/4},rear={2,-3,math.pi}},
  saffron_dojo={fixtures={{'FR_SAFFRON_CITY',37,8},{'FR_SAFFRON_CITY_CONNECTION',27,1}},doorX=3,doorY=4,stat='saffronDojo',source='^assets/scenery/saffron%-dojo/',pendingGround=true,right=6,left={-1,5,math.pi/4},rear={3,0,math.pi}},
  saffron_gym={fixtures={{'FR_SAFFRON_CITY',43,8},{'FR_SAFFRON_CITY_CONNECTION',33,1}},doorX=3,doorY=4,stat='hgssGyms',source='^assets/scenery/hgss%-kanto%-gyms/hgss_saffron_gym/',right=9,left={-1,5,math.pi/4},rear={3,0,math.pi}},
  gyms={fixtures={{'FR_PEWTER_CITY',12,12},{'FR_VIRIDIAN_CITY',33,6}},doorX=3,doorY=4,stat='hgssGyms',source='^assets/scenery/hgss%-kanto%-gyms/',right=9},
  gyms_all={fixtures={{'FR_PEWTER_CITY',12,12},{'FR_VIRIDIAN_CITY',33,6},{'FR_CERULEAN_CITY',28,17}},doorX=3,doorY=4,stat='hgssGyms',source='^assets/scenery/hgss%-kanto%-gyms/',right=9},
  cerulean_gym={fixtures={{'FR_CERULEAN_CITY',28,17}},doorX=3,doorY=4,stat='hgssGyms',source='^assets/scenery/hgss%-kanto%-gyms/hgss_cerulean_gym/',right=9},
  houses={fixtures={{'FR_PEWTER_CITY',8,28},{'FR_PEWTER_CITY',32,9}},doorX=1,doorY=2,stat='pewterHouses',source='^assets/scenery/pewter%-house/'},
  viridian_flowers={adapter='Gen3ImportedViridianFlowerHouses',model='hgss_viridian_flower_house',fixtures={{'FR_VIRIDIAN_CITY',24,15}},doorX=1,doorY=3,stat='viridianFlowerHouses',source='^assets/scenery/viridian%-house/'},
  lavender={fixtures={{'FR_LAVENDER_TOWN',8,8},{'FR_LAVENDER_TOWN',3,13}},doorX=2,doorY=3,stat='lavenderHouses',source='^assets/scenery/lavender%-house/'},
  name_rater={fixtures={{'FR_LAVENDER_TOWN',8,13}},doorX=2,doorY=3,stat='lavenderNameRater',source='^assets/scenery/lavender%-name%-rater/',left={-1,4,math.pi/4},rear={6,-1,-3*math.pi/4}},
 }
 local config=assert(configs[family],'unreviewed source family');local fixtures=config.fixtures;local doorX,doorY=config.doorX,config.doorY
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL'),'QA_UTIL must name the external engine frame-driver helper'))
 local edition=require('src.core.GameVersion').get();assert(edition=='firered'or edition=='leafgreen')
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C,S=V.require('Gen3Integration'),V.require('Gen3Scene');local Map,P=require('src.core.game3.map'),require('src.core.game3.player')
 local observed={};local adapter=V.require(config.adapter or(family=='saffron_dojo'and'Gen3ImportedSaffronDojo'or'Gen3ImportedHGSSGyms'));local original=adapter.build;adapter.build=function(g,...)local ok,why=original(g,...);if ok then observed[Map.currentDef().id..':'..g.cx..':'..g.cy]=(g.importedCeladonShortHouse or g.importedCeruleanClosedHouse or g.importedHGSSGym or g.importedSaffronDojo or g.importedHGSSMart or g.importedViridianHouse or g.importedViridianFlowerHouse or g.importedPewterMuseum or g.importedSaffronCopycat or g.importedSaffronPsychic).model end;return ok,why end
 local dir=os.getenv('SHOT_DIR');local json=require('src.link.Json');local out={};local missing=os.getenv('QA_MISSING_ASSETS')=='1'
 if missing then local read=V.mod.read;V.mod.read=function(self,path)if path:match(config.source)then return nil end;return read(self,path)end end
 game:_handleBootAction({action='new_game',start={map='FR_PEWTER_CITY',x=10,y=32,facing='up'}})
 if family=='saffron_gym'or family=='saffron_dojo'or family=='copycat'or family=='psychic'or config.model=='hgss_kanto_mart'then require('src.core.game3.scripting.flags').setFlag(assert(require('src.core.game3.scripting.space').store),nil,0x3E,true)end
 if config.model=='hgss_kanto_mart'then local F=require('src.core.game3.scripting.flags');local store=assert(require('src.core.game3.scripting.space').store);F.setVar(store,nil,0x4086,1);F.setFlag(store,nil,0x97,true);F.setVar(store,nil,0x4057,1);F.setFlag(store,nil,0x829,true)end
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
  local map,cx,cy=q[1],q[2],q[3];local doorX,doorY=q[4]or config.doorX,q[5]or config.doorY;local pendingGround=config.pendingGround or(config.model=='hgss_kanto_mart'and(map=='FR_SAFFRON_CITY'or map=='FR_SAFFRON_CITY_CONNECTION'));C.setLevel(0,game);assert(Map.load(nil,game,map,{x=cx+(config.frontX or doorX),y=cy+(config.front or doorY+2),facing='up'}));game.input:reset();local before=hash(Map.currentDef())
  C.yaw=0;C.pitch=math.rad(8);C.setLevel(3,game);settle()
  local n=S.performanceSnapshot().scenery[config.stat];if config.model then n=observed[map..':'..cx..':'..cy]and 1 or 0 end;if family=='saffron_dojo'and not missing and n==0 then for yy=cy,cy+4 do local row={}for xx=cx,cx+5 do local c=Map.currentDef().midLayout:cellAt(xx,yy);row[#row+1]={c.mid,c.coll,c.elev}end;print('[DOJO FAILED ROW]',yy,json.encode(row))end end;assert(missing and n==0 or not missing and n>0,'source/fallback mismatch')
  if family=='saffron_gym'or family=='saffron_dojo'or config.model then local model=observed[map..':'..cx..':'..cy];assert(missing and not model or not missing and model==(config.model or(family=='saffron_dojo'and'hgss_saffron_dojo'or'hgss_saffron_gym')),'exact regional source placement absent')end
  shot(index..'-modern')
  local left,rear=config.left or{-3,2,math.pi/2},config.rear or{doorX,-2,math.pi}
  if os.getenv('QA_QUICK')~='1'then for _,v in ipairs{{'front',cx+(config.frontX or doorX),cy+(config.front or doorY+2),config.frontYaw or 0},{'quarter',cx+4,cy+(config.front or doorY+2),-math.pi/6},{'left',cx+left[1],cy+left[2],left[3]},{'right',cx+(config.right or 7),cy+2,-math.pi/2},{'rear',cx+rear[1],cy+rear[2],rear[3]}}do
   if v[2]>=0 and v[2]<Map.currentDef().width and v[3]>=0 and v[3]<Map.currentDef().height then P.reset(v[2],v[3],'up');C.yaw=v[4];C.setLevel(6,game);settle();shot(index..'-'..v[1])else print('[FRLG VIEW OUTSIDE NATIVE BOUNDS]',map,v[1])end
  end end
  local destination
  if not config.noEntrance and map~='FR_SAFFRON_CITY_CONNECTION'then
  C.yaw=0;C.setLevel(3,game);P.reset(cx+doorX,cy+doorY+1,'up');game.input:reset();settle()
  local doors=require('src.core.game3.doors');local seen={}
  for _=1,160 do U.hold(game,'up',1);local a=doors.getActiveAnim();if a and not seen[a.frame]then seen[a.frame]=true;shot(index..'-enter-'..a.frame)end;if Map.currentDef().id~=map then break end end
  for _=1,300 do U.wait(1);if Map.currentDef().id~=map then break end end
  assert(Map.currentDef().id~=map,'native entrance failed');destination=Map.currentDef().id;settle();U.wait(90);shot(index..'-interior');U.wait(30)
  for _=1,260 do U.hold(game,'down',1);if Map.currentDef().id==map then break end end
  assert(Map.currentDef().id==map,'native return failed');settle();U.wait(90);shot(index..'-returned');assert(hash(Map.currentDef())==before,'native layout mutated')
  else for _,w in ipairs(Map.currentDef().warps or{})do assert(not(w.x==cx+doorX and w.y==cy+doorY),'projection has an unexpected native warp')end;assert(hash(Map.currentDef())==before,'native projection mutated')end
  if family=='cerulean_closed'then
   C.setLevel(3,game);C.yaw=0;P.reset(cx+2,cy+4,'up');game.input:reset();settle()
   U.hold(game,'up',30);game.input:reset();U.wait(30)
   assert(P.cellX==cx+2 and P.cellY==cy+4,'native solid front became walkable')
   shot(index..'-front-blocked')
   P.reset(cx,cy+4,'right');game.input:reset()
   local function step(dir,x,y)
    local oldX,oldY=P.cellX,P.cellY
    for _=1,50 do U.hold(game,dir,1);if P.moving then break end end
    game.input:reset();U.wait(24);assert(P.cellX==x and P.cellY==y,'native perimeter step failed '..dir..' want '..x..':'..y..' got '..P.cellX..':'..P.cellY)
   end
   local width=config.walkWidth or 5
   for x=cx+1,cx+width do step('right',x,cy+4)end
   step('up',cx+width,cy+3);step('up',cx+width,cy+2)
   U.hold(game,'left',30);game.input:reset();U.wait(30)
   assert(P.cellX==cx+(config.walkWidth or 5)and P.cellY==cy+2,'native solid side became walkable')
   settle();shot(index..'-side-blocked')
  end
  if family=='celadon_short'then
   -- No front aisle: the next native building begins immediately at y30.
   -- Walk the actual eastern street and native roof header behind this house.
   C.setLevel(3,game);C.yaw=-math.pi/6;P.reset(cx+4,cy+4,'up');game.input:reset();settle()
   local function step(dir,x,y)
    for _=1,50 do U.hold(game,dir,1);if P.moving then break end end
    game.input:reset();U.wait(24);assert(P.cellX==x and P.cellY==y,'native Celadon street/header step failed '..dir..' '..P.cellX..':'..P.cellY)
   end
   step('up',cx+4,cy+3);step('up',cx+4,cy+2)
   U.hold(game,'left',30);game.input:reset();U.wait(30)
   assert(P.cellX==cx+4 and P.cellY==cy+2,'native solid side became walkable');shot(index..'-side-blocked')
   for y=cy+1,cy-1,-1 do step('up',cx+4,y)end
   for x=cx+3,cx+1,-1 do step('left',x,cy-1)end
   step('down',cx+1,cy)
   U.hold(game,'down',30);game.input:reset();U.wait(30)
   assert(P.cellX==cx+1 and P.cellY==cy,'native rear wall became walkable');settle();shot(index..'-header-walked')
  end
  C.setLevel(0,game);U.wait(15);shot(index..'-native')
  out[#out+1]={edition=require('src.core.GameVersion').get(),map=map,x=cx,y=cy,runtime='v'..require('src.core.Version').engine,doorX=doorX,doorY=doorY,sourceModel=not missing and config.model or nil,nativeHash=before,destination=destination,returned=not config.noEntrance and map~='FR_SAFFRON_CITY_CONNECTION',nativeWalkChecked=(family=='cerulean_closed'or family=='celadon_short')or nil,nonEnterable=config.noEntrance==true or map=='FR_SAFFRON_CITY_CONNECTION',renderedVerified=not missing and not pendingGround,renderedGap=pendingGround and'Shared native-ground donor assessment pending.'or nil,missingAssets=missing}
  local f=assert(io.open(dir..'/results.json','w'));f:write(json.encode(out));f:close()
 end end
 local f=assert(io.open(dir..'/results.json','w'));f:write(json.encode(out));f:close();assert(#game.mods.errors==0,table.concat(game.mods.errors,'\n'));print('[FRLG IMPORTED EXTERIORS] PASS',family,#out)
end
