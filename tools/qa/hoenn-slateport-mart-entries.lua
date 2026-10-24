-- Isolated native source/door/footprint review for own ORAS Rustboro exteriors.
-- QA_UTIL names the external engine frame-driver helper; QA_MISSING_ASSETS checks native fallback.
return function(game)
 local family='slateport-mart'
 local fixtures={{'SLATEPORT_CITY',12,23,'hoennMarts',1,3,4}}
 local doorX,doorY=2,4
 assert(love.filesystem.getIdentity():match('%-qa$'))
 assert(not love.joystick or love.joystick.getJoystickCount()==0,'isolate physical controller input before automated QA')
 local U=dofile(assert(os.getenv('QA_UTIL'),'QA_UTIL must name the external engine frame-driver helper'))
 local edition=require('src.core.GameVersion').get();assert(edition=='emerald'or edition=='ruby'or edition=='sapphire');local pre=({emerald='EM_',ruby='RU_',sapphire='SA_'})[edition]
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local F=V.require('Gen3ModernHoennBuildings');local originalBuild=F.build;local builtGroups={}
 F.build=function(g,...)local ok,why=originalBuild(g,...);if ok and F.kind(g)=='hoennMarts'then builtGroups[g]=true end;return ok,why end
 local C,S=V.require('Gen3Integration'),V.require('Gen3Scene');local Map,P=require('src.core.game3.map'),require('src.core.game3.player')
 local dir=os.getenv('SHOT_DIR');local json=require('src.link.Json');local out={};local missing=os.getenv('QA_MISSING_ASSETS')=='1'
 if missing then local read=V.mod.read;V.mod.read=function(self,path)if path:match('^assets/scenery/oras%-slateport%-mart/')then return nil end;return read(self,path)end end
 local Warp,Fade,Field=require('src.core.game3.warp'),require('src.ui.game3.fade'),require('src.core.game3.field')
 local Space=require('src.core.game3.scripting.space')
 local function ready()
  game.input:reset();local stable=0
  for _=1,3000 do U.wait(1);if not Warp.isBusy()and not Fade.lockInput and not Field.locked and not P.moving and not(Space.vm and Space.vm:isRunning())and not Space._pendingOnFrame then stable=stable+1 else stable=0 end;if stable>=6 then return end end
  print('[RUSTBORO NATIVE NOT READY]',Map.currentDef().id,P.cellX,P.cellY,Field.locked,Warp.isBusy(),Fade.lockInput,Space.vm and Space.vm:isRunning(),Space._pendingOnFrame);error('native field did not finish its transition')
 end
 game:_handleBootAction({action='new_game',start={map=pre..'OLDALE_TOWN',x=10,y=12,facing='up'}});ready()
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
  doorX=q[5];doorY=q[6]or 4;local map,cx,cy=pre..q[1],q[2],q[3];C.setLevel(0,game);assert(Map.load(nil,game,map,{x=cx+doorX,y=cy+doorY+2,facing='up'}));game.input:reset();ready();assert(Map.currentDef().id==map,'native fixture changed map');local before=hash(Map.currentDef())
  C.yaw=0;C.pitch=math.rad(8);C.setLevel(3,game);settle()
  assert(Map.currentDef().id==map,'native map changed during source review');local n=0;for g in pairs(builtGroups)do if F.kind(g)=='hoennMarts'and g.cx==cx and g.cy==cy then n=n+1 end end;assert(missing and n==0 or not missing and n>0,'source/fallback mismatch')
  shot(index..'-modern')
  if os.getenv('QA_QUICK')~='1'then
   local depth=doorY+1
   local candidates={
    {'front',{{cx+doorX,cy+doorY+2}},0},
    {'left',{{cx-1,cy+2},{cx-1,cy+depth},{cx-2,cy+depth},{cx-2,cy+2}},math.pi/2},
    {'right',{{cx+q[7],cy+2},{cx+q[7],cy+depth},{cx+q[7]+1,cy+depth},{cx+q[7]+1,cy+2}},-math.pi/2},
    {'rear',{{cx+doorX,cy-1},{cx+doorX,cy-2},{cx+doorX,cy-3},{cx+doorX,cy-4}},math.pi}}
   for _,view in ipairs(candidates)do
    local spot;for _,xy in ipairs(view[2])do local c=Map.currentDef().midLayout:cellAt(xy[1],xy[2]);if c and c.coll==0 then spot=xy;break end end
    if spot then P.reset(spot[1],spot[2],'up');C.setLevel(6,game);C.yaw=view[3];settle();shot(index..'-'..view[1]);print('[RUSTBORO WALKABLE VIEW]',index,view[1],spot[1],spot[2])
    else print('[RUSTBORO VIEW BLOCKED BY NATIVE COLLISION]',index,view[1])end
   end
  end
  C.setLevel(3,game);C.yaw=0;P.reset(cx+doorX,cy+doorY+1,'up');game.input:reset();settle()
  assert(P.cellX==cx+doorX and P.cellY==cy+doorY+1,'native player moved during fixture settle')
  local doors=require('src.core.game3.doors');local seen={};print('[RUSTBORO BEFORE ENTRY]',Map.currentDef().id,P.cellX,P.cellY,P.facing,Field.locked,Warp.isBusy(),Fade.lockInput,C.yaw,C.level)
  for _=1,600 do U.hold(game,'up',1);local a=doors.getActiveAnim();if a and not seen[a.frame]then seen[a.frame]=true;shot(index..'-enter-'..a.frame)end;if Map.currentDef().id~=map then break end end
  for _=1,3000 do U.wait(1);if Map.currentDef().id~=map then break end end
  if Map.currentDef().id==map then print('[RUSTBORO ENTRY FAILED]',Map.currentDef().id,P.cellX,P.cellY,P.facing,Field.locked,Warp.isBusy(),Fade.lockInput,C.yaw);shot(index..'-entry-failed')end
  assert(Map.currentDef().id~=map,'native entrance failed');local destination=Map.currentDef().id;assert(destination==pre..'SLATEPORT_CITY_MART','wrong native destination');ready();print('[RUSTBORO ARRIVAL]',destination,P.cellX,P.cellY,P.facing);settle();U.wait(90);shot(index..'-interior');U.wait(30)
  local arrivalY=P.cellY;for _=1,600 do U.hold(game,'up',1);if P.cellY<arrivalY then break end end;ready();print('[RUSTBORO NORMAL STEP INSIDE]',P.cellX,P.cellY)
  for _=1,1800 do U.hold(game,'down',1);if Map.currentDef().id==map and P.cellY>cy+doorY and not Warp.isBusy()then break end end
  if Map.currentDef().id~=map then print('[RUSTBORO RETURN FAILED]',Map.currentDef().id,P.cellX,P.cellY,P.facing,Field.locked,Warp.isBusy(),Fade.lockInput);shot(index..'-return-failed')end
  assert(Map.currentDef().id==map,'native return failed');ready();settle();U.wait(90);shot(index..'-returned');assert(hash(Map.currentDef())==before,'native layout mutated')
  C.setLevel(0,game);U.wait(15);shot(index..'-native')
  out[#out+1]={edition=require('src.core.GameVersion').get(),map=map,x=cx,y=cy,nativeHash=before,destination=destination,returned=true,missingAssets=missing}
 end
 local f=assert(io.open(dir..'/results.json','w'));f:write(json.encode(out));f:close();print('[HOENN NATIVE SOURCE DOORS] PASS',family,#out)
end
