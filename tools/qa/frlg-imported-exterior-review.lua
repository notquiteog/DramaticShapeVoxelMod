-- Isolated native source/door/footprint review for new FR/LG regional exteriors.
-- QA_FAMILY=houses|gyms|viridian_flowers; QA_UTIL names the external engine frame-driver helper.
return function(game)
 local family=os.getenv('QA_FAMILY')or'gyms';assert(family=='gyms'or family=='houses'or family=='viridian_flowers')
 local gym=family=='gyms';local flowers=family=='viridian_flowers';local fixtures=flowers and{{'FR_VIRIDIAN_CITY',24,15}}or gym and{{'FR_PEWTER_CITY',12,12},{'FR_VIRIDIAN_CITY',33,6}}or{{'FR_PEWTER_CITY',8,28},{'FR_PEWTER_CITY',32,9}}
 local doorX,doorY=gym and 3 or 1,gym and 4 or flowers and 3 or 2
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL'),'QA_UTIL must name the external engine frame-driver helper'))
 local edition=require('src.core.GameVersion').get();assert(edition=='firered'or edition=='leafgreen')
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C,S=V.require('Gen3Integration'),V.require('Gen3Scene');local Map,P=require('src.core.game3.map'),require('src.core.game3.player')
 local dir=os.getenv('SHOT_DIR');local json=require('src.link.Json');local out={};local missing=os.getenv('QA_MISSING_ASSETS')=='1'
 if missing then local read=V.mod.read;V.mod.read=function(self,path)if path:match(flowers and'^assets/scenery/viridian%-house/'or gym and'^assets/scenery/hgss%-kanto%-gyms/'or'^assets/scenery/pewter%-house/')then return nil end;return read(self,path)end end
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
  local n=S.performanceSnapshot().scenery[flowers and'viridianFlowerHouses'or gym and'hgssGyms'or'pewterHouses'];assert(missing and n==0 or not missing and n>0,'source/fallback mismatch')
  shot(index..'-modern')
  if os.getenv('QA_QUICK')~='1'then for _,v in ipairs{{'front',cx+doorX,cy+doorY+2,0},{'left',cx-3,cy+2,math.pi/2},{'right',cx+(gym and 9 or 7),cy+2,-math.pi/2},{'rear',cx+doorX,cy-2,math.pi}}do
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
