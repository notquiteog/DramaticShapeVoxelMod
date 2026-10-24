-- Read-only native review of every exact ordinary/tall Saffron block placement.
-- QA_UTIL supplies an external frame helper. Disposable *-qa identity required.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL')))
 local edition=require('src.core.GameVersion').get();assert(edition=='firered'or edition=='leafgreen')
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C,S=V.require('Gen3Integration'),V.require('Gen3Scene');local Map,P=require('src.core.game3.map'),require('src.core.game3.player')
 local adapter=V.require('Gen3ImportedSaffronBlocks');local observed={};local build=adapter.build
 adapter.build=function(g,...)
  local ok,why=build(g,...)
  if ok then observed[Map.currentDef().id..':'..g.cx..':'..g.cy]=g.importedSaffronBlock.model end
  return ok,why
 end
 local missing=os.getenv('QA_MISSING_ASSETS')=='1'
 if missing then local read=V.mod.read;V.mod.read=function(self,path)if path:match('^assets/scenery/saffron%-blocks/')then return nil end;return read(self,path)end end
 game:_handleBootAction({action='new_game',start={map='FR_SAFFRON_CITY',x=24,y=16,facing='up'}})
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day');V.require('RenderDistance').haze=function()return nil end
 local dir=assert(os.getenv('SHOT_DIR'));local json=require('src.link.Json');local results={}
 local fixtures={{18,34,4,5},{31,34,4,5},{35,34,4,5},{46,34,4,5},{18,17,4,5},{17,10,4,5},{25,10,4,5},{19,25,5,6},{24,25,5,6},{38,25,5,6},{43,25,5,6}}
 local function settle()
  local stable,last=0
  for _=1,2000 do U.wait(1);local a=S.streaming
   if S.sceneDef==Map.currentDef()and a.started+a.promoted==a.completed+a.cancelled and last==a.started then stable=stable+1 else stable=0 end
   last=a.started;if stable>=6 then break end
  end
  assert(stable>=6 and C.active and C.recovery.failures==0,'native renderer/stream failure')
  require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(3)
 end
 local function shot(n)assert(U.shot(game,dir..'/'..n..'.png'))end
 local function hash(d)local a={};for y=0,d.height-1 do for x=0,d.width-1 do local c=d.midLayout:cellAt(x,y);a[#a+1]=table.concat({c.mid,c.coll,c.elev},':')end end;return love.data.encode('string','hex',love.data.hash('sha256',table.concat(a,';')))end
 for _,map in ipairs{'FR_SAFFRON_CITY','FR_SAFFRON_CITY_CONNECTION'}do
  if not os.getenv('QA_MAP')or os.getenv('QA_MAP')==map then
  for index,q in ipairs(fixtures)do if(not os.getenv('QA_INDEX')or index==tonumber(os.getenv('QA_INDEX')))and index>=tonumber(os.getenv('QA_START')or'1')then
   local cx,cy,w,d=unpack(q);if map=='FR_SAFFRON_CITY_CONNECTION'then cx,cy=cx-10,cy-7 end;local focus=math.floor(w/2);C.setLevel(0,game)
   assert(Map.load(nil,game,map,{x=cx+focus,y=cy+d+1,facing='up'}));assert(Map.currentDef().id==map,'native loader changed requested map identity');game.input:reset();local before=hash(Map.currentDef())
   C.yaw=0;C.pitch=math.rad(8);C.setLevel(3,game);settle()
   local key=map..':'..cx..':'..cy;if not missing and not observed[key]then print('[SAFFRON OBSERVED]',json.encode(observed));for yy=cy,cy+d-1 do local row={}for xx=cx,cx+w-1 do local cell=Map.currentDef().midLayout:cellAt(xx,yy);row[#row+1]={cell.mid,cell.coll,cell.elev}end;print('[SAFFRON FAILED ROW]',yy,json.encode(row))end end;assert(missing and not observed[key]or not missing and observed[key],'requested source placement not built/fallback mismatch')
   local tag=(map=='FR_SAFFRON_CITY'and'city-'or'connection-')..index;shot(tag..'-modern')
   if os.getenv('QA_QUICK')~='1'and(index==1 or index==8)then
    for _,v in ipairs{{'front',cx+focus,cy+d+1,0},{'right',cx+w+2,cy+2,-math.pi/2},{'rear',cx+focus,cy-2,math.pi},{'left',cx-2,cy+2,math.pi/2}}do
     P.reset(v[2],v[3],'up');C.yaw=v[4];C.setLevel(6,game);settle();shot(tag..'-'..v[1])
    end
   end
   assert(hash(Map.currentDef())==before,'native source layout mutated')
   C.setLevel(0,game);U.wait(10);shot(tag..'-native')
   results[#results+1]={edition=edition,map=map,x=cx,y=cy,nativeHash=before,sourceModel=observed[key],nonEnterable=true,renderedVerified=not missing,missingAssets=missing}
   local f=assert(io.open(dir..'/results.json','w'));f:write(json.encode(results));f:close()
  end end end
 end
 print('[SAFFRON BLOCK REVIEW] PASS captures/native hashes',edition,#results,'missing',missing)
end
