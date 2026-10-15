-- Native walk across a real connection; isolated QA profile only.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local U=dofile('tests/drivers/util.lua');local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local C,S=V.require('Gen3Integration'),V.require('Gen3Scene')
 local Map=require('src.core.game3.map');local P=require('src.core.game3.player');local Coll=require('src.core.game3.collision');local Conn=require('src.core.game3.connections')
 love.window.setMode(2560,1440,{vsync=0,fullscreen=true,fullscreentype='desktop'})
 local version=require('src.core.GameVersion').get()
 local start=version=='firered' or version=='leafgreen'
 start=start and 'FR_ROUTE_1' or (version=='ruby' and 'RU_ROUTE104' or version=='sapphire' and 'SA_ROUTE104' or 'EM_ROUTE104')
 game:_handleBootAction({action='new_game',start={map=start,x=10,y=20,facing='up'}})
 local sp=require('src.core.game3.scripting.space');sp.runOnFrame=function()end
 local function clear()local vm=sp.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset();require('src.ui.game3.map_preview_screen').reset()end
 clear();C.setLevel(7,game);C.yaw=0;C.pitch=.25
 V.require('RenderDistance').setting:sync('auto');V.require('AntiAlias').setting:sync(0);V.require('SpatialUpscale').setting:sync(1);V.require('Shadows').setting:sync('high')
 local def=Map.currentDef();local w,h=Conn.sizeOf(def);local found
 local running=os.getenv('CONNECTION_RUN')=='1';local approach=running and 12 or 2
 local function walkable(d,x,y)return d.midLayout:collAt(x,y)==0 and not Coll.isSurfable(Coll.behaviorOn(d,x,y))end
 for _,n in ipairs(Conn.each(def))do
  local d=game.data.maps[n.map];Map.ensureMidLayout(game,n.map,d)
  local vertical=n.dir=='north'or n.dir=='south';local dx=n.dir=='east'and 1 or n.dir=='west'and -1 or 0;local dy=n.dir=='south'and 1 or n.dir=='north'and -1 or 0
  for along=0,(vertical and w or h)-1 do
   local x=vertical and along or(dx==1 and w-1 or 0);local y=vertical and(dy==1 and h-1 or 0)or along
   local nx,ny=Conn.localPos({dir=n.dir,offset=n.offset,def=d},x+dx,y+dy,w,h)
   local clearLane=true;for step=0,approach do if not walkable(def,x-step*dx,y-step*dy)then clearLane=false end end
   if clearLane and nx and walkable(def,x,y)and walkable(def,x-dx,y-dy)and walkable(def,x-2*dx,y-2*dy)and walkable(d,nx,ny)and walkable(d,nx+dx,ny+dy)then
    found={x=x-approach*dx,y=y-approach*dy,dir=({north='up',south='down',east='right',west='left'})[n.dir],dest=n.map};break
   end
  end
  if found then break end
 end
 assert(found,'no walkable connection fixture');print('[cross fixture]',found.x,found.y,found.dir,found.dest)
 assert(Map.load(nil,game,start,{x=found.x,y=found.y,facing=found.dir}));clear();C.setLevel(7,game);U.wait(running and 1 or 180)
 if running then
  local flags=require('src.core.game3.scripting.flags')
  flags.setFlag(sp.getStore(),nil,flags.forVersion(version).IDS.FLAG_SYS_B_DASH,true);assert(P.canDash())
 end
 local ran=false
 U.shot(game,os.getenv('SHOT_DIR')..'/before.png')
 local scene=S.draw;local crossing=false
 S.draw=function(...)local t=love.timer.getTime();local r=scene(...);local ms=(love.timer.getTime()-t)*1000;if ms>10 then print('[cross scene]',Map.current,ms,S.streaming.maxSlice,S.streaming.maxStreamSlice)end;return r end
 print('[pre-cross]',S.streaming.prefetched,S.streaming.prefetchFailed)
 local base=Map.current;local wall={};local last=love.timer.getTime()
 for i=1,1800 do
  if running then game.input.state.b=true end
  U.hold(game,found.dir,1);ran=ran or P.running;local t=love.timer.getTime();wall[#wall+1]=(t-last)*1000;last=t
  if Map.current~=base and not crossing then crossing=true;print('[crossed]',Map.current,i,P.cellX,P.cellY,C.active)end
  if crossing then U.wait(25);break end
 end
 print('[position]',Map.current,P.cellX,P.cellY,P.px,P.py)
 game.input:reset();assert(not running or ran,'native running not exercised');assert(Map.current==found.dest,'native movement did not cross');assert(C.active,'connection lost 3D camera');assert(S.streaming.promoted>0,'prepared destination not promoted')
 local direct={};for _,n in ipairs(Conn.each(Map.currentDef()))do direct[#direct+1]={dir=n.dir,offset=n.offset,def=game.data.maps[n.map]}end
 local Look=V.require('SceneLookahead');local def=Map.currentDef();local comparisons=0
 for y=-12,def.midLayout.height+12 do for x=-12,def.midLayout.width+12 do
  local a,b,c=Map.worldMidAt(x,y,def);local aa,bb,cc=Look.sample(def,direct,Map.world,x,y)
  assert(a==aa and b==bb and not not c==not not cc,'lookahead differs from native sampler');comparisons=comparisons+1
 end end
 print('[native sampler]',comparisons)
 table.sort(wall);print('[cross wall]',wall[math.ceil(#wall*.95)],wall[#wall]);print('[lookahead]',S.streaming.prefetched,S.streaming.promoted,S.streaming.prefetchFailed,S.streaming.maxStreamSlice);U.shot(game,os.getenv('SHOT_DIR')..'/after.png');local cache=V.require('NativeGeometryCache');print('[cache dirty]',cache.ramStats().dirty,cache.ramStats().files)
 love.event.quit()
end
