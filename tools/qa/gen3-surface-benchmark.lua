-- Isolated native-water visual/throughput fixture. No gameplay replacement.
-- Run a single LÖVE process at a time for comparable performance evidence.
-- QA_MAPS=MAP;MAP, QA_WATER_MODES=full,sky,off, QA_CAMERAS=3,6.
-- QA_SAMPLES=180, QA_WARMUP=60, QA_WIDTH=1280, QA_HEIGHT=720,
-- QA_DISTANCE=16, QA_MEASURE=0 for screenshots/clock audit without FPS claims.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'isolated QA profile required')
 local U=dofile('tests/drivers/util.lua');local GV=require('src.core.GameVersion');local ed=GV.get()
 local prefix=({emerald='EM_',ruby='RU_',sapphire='SA_'})[ed]or'FR_'
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local w,h=tonumber(os.getenv('QA_WIDTH'))or 1280,tonumber(os.getenv('QA_HEIGHT'))or 720
 assert(love.window.setMode(w,h,{vsync=0,resizable=false}));require('src.core.VSync').apply('off')
 game:_handleBootAction({action='new_game',start={map=prefix=='FR_'and'FR_PALLET_TOWN'or prefix..'OLDALE_TOWN',x=10,y=9,facing='up'}});U.wait(3)
 local export=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK);local V=export.lib
 local Cam,Scene,Water=V.require('Gen3Integration'),V.require('Gen3Scene'),V.require('Water')
 local Map,Player,Col,Objects=require('src.core.game3.map'),require('src.core.game3.player'),require('src.core.game3.collision'),require('src.core.game3.objects')
 local NativeAnim=require('src.core.game3.tileset_anim');local FP=require('src.core.FrameProfiler');local Json=require('src.link.Json')
 V.require('DayNight').setting:sync('day');V.require('RenderDistance').setting:sync(tonumber(os.getenv('QA_DISTANCE'))or 16)
 V.require('AntiAlias').setting:sync(0);V.require('SpatialUpscale').setting:sync(1);V.require('WorldCurve').setting:sync(0)
 V.require('Shadows').setting:sync('high');V.require('TreePresentation').art:sync('modeled');V.require('CommunityVisuals').treeDetail:sync('balanced')
 V.require('Gen3SceneOptions').tilt:sync(0);require('src.core.FrameCap').apply(160)
 local dir=assert(os.getenv('SHOT_DIR'));local hashes={}
 for _,name in ipairs{'manifest.json','lib/Water.lua','lib/WaterSurfacePass.lua','lib/Gen3Scene.lua','lib/Voxel3D.lua','lib/Sky.lua','lib/Gen3SeaRocks.lua'}do
  local bytes=assert(V.mod:read(name));hashes[name]=love.data.encode('string','hex',love.data.hash('sha256',bytes))
 end
 for _,name in ipairs{'lib/NativeWaterSurface.lua','lib/Gen3Water.lua','lib/Clouds.lua','lib/WaterBackdrop.lua','lib/KantoFirstPerson.lua'}do
  local ok,bytes=pcall(V.mod.read,V.mod,name);if ok and bytes then hashes[name]=love.data.encode('string','hex',love.data.hash('sha256',bytes))end
 end
 local results={edition=ed,sourceVersion=export.performance.snapshot().sourceVersion,hashes=hashes,renderer={love.graphics.getRendererInfo()},settings={width=w,height=h,aa=0,fsr=1,distance=V.require('RenderDistance').setting:get(),shadows='high',day='day',curve=0,vsync=love.window.getVSync(),driverPaced=os.getenv('POKEPORT_DRIVER_PACED')or'unset'},segments={}}
 local lastGfx={};local draw=love.draw;love.draw=function(...)local a,b=draw(...);lastGfx=love.graphics.getStats();return a,b end
 local waterDraws,waterMeshes,waterVertices,waterLevels,nativeContext=0,{},0,{},false
 local Pass=V.require('WaterSurfacePass');local pass=Pass.draw
 Pass.draw=function(draws,...)
  waterDraws=waterDraws+1
  for _,d in ipairs(draws)do if not waterMeshes[d[1]]then waterMeshes[d[1]]=true;waterVertices=waterVertices+d[1]:getVertexCount();waterLevels[tostring(d[4])]=true end end
  FP.push('waterPassCPU');local a,b=pass(draws,...);FP.pop('waterPassCPU');return a,b
 end
 local begin=Water.begin;Water.begin=function(ctx,...)
  if ctx and ctx.nativeWater then nativeContext=true end
  return begin(ctx,...)
 end
 local sceneDraw=Scene.draw;Scene.draw=function(...)FP.push('nativeSceneCPU');local a,b=sceneDraw(...);FP.pop('nativeSceneCPU');return a,b end
 local function list(text,pattern)local t={};for s in text:gmatch(pattern)do t[#t+1]=s end;return t end
 local maps=list(os.getenv('QA_MAPS')or(prefix=='FR_'and'FR_ROUTE_21_NORTH;FR_PALLET_TOWN;FR_OAKS_LAB'or prefix..'ROUTE103;'..prefix..'ROUTE104;'..prefix..'PETALBURG_CITY'),'[%w_]+')
 local modes=list(os.getenv('QA_WATER_MODES')or'full,sky,off','[%w_]+');local cameras=list(os.getenv('QA_CAMERAS')or'3,6','%d+')
 local samples=tonumber(os.getenv('QA_SAMPLES'))or 180;local warm=tonumber(os.getenv('QA_WARMUP'))or 60
 local measure=os.getenv('QA_MEASURE')~='0'
 local report=assert(io.open(dir..'/surface-times.tsv','w'));report:write('map\tx\ty\tfacing\tcamera\twater\tframes\tinterval_mean_ms\tinterval_p95_ms\tinterval_max_ms\tfps\tdraw_cpu_mean_ms\twater_cpu_mean_ms\twater_cpu_p95_ms\tdrawcalls\tcanvasswitches\twater_vertices\tlegacy_phase_start\tlegacy_phase_end\tnative_counter_start\tnative_counter_end\n')
 local function stats(a)local copy,sum={},0;for j,n in ipairs(a)do copy[j]=n;sum=sum+n end;table.sort(copy);return {mean=sum/#copy,p95=copy[math.ceil(#copy*.95)],max=copy[#copy]}end
 local function sourceHash(def)local a={};for y=0,def.height-1 do for x=0,def.width-1 do local c=def.midLayout:cellAt(x,y);a[#a+1]=table.concat({c.mid,c.coll,c.elev},':')end end;return love.data.encode('string','hex',love.data.hash('sha256',table.concat(a,';')))end
 for _,id in ipairs(maps)do
  Cam.setLevel(0,game);assert(Map.load(nil,game,id,{x=6,y=9,facing='up'}));require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(3)
  local def=Map.currentDef();local before=sourceHash(def);local best,spot
  local dirs={{0,-1,'up',0},{1,0,'right',math.pi/2},{0,1,'down',math.pi},{-1,0,'left',math.pi*1.5}}
  for y=2,def.height-3 do for x=2,def.width-3 do
   if Col.isWalkable(x,y)and not Col.isWater(x,y)and not Col.warpAt(x,y)and not Objects.at(x,y)then
    for _,d in ipairs(dirs)do if Col.isWater(x+d[1],y+d[2])then
     local n=0;for yy=math.max(0,y-5),math.min(def.height-1,y+5)do for xx=math.max(0,x-5),math.min(def.width-1,x+5)do if Col.isWater(xx,yy)then n=n+1 end end end
     local score=n-((x-def.width/2)^2+(y-def.height/2)^2)*.001
     if not best or score>best then best,spot=score,{x,y,d[3],d[4]}end
    end end
   end
  end end
  if id=='FR_OAKS_LAB'then spot={6,10,'up',0}end
  if not spot and id:find('BIRCHS_LAB',1,true)then spot={6,9,'up',0}end
  assert(spot,'no native dry shoreline fixture '..id);Player.reset(spot[1],spot[2],spot[3]);game.input:reset()
  for _,camera in ipairs(cameras)do camera=tonumber(camera);Cam.setLevel(camera,game);Cam.yaw=spot[4];Cam.pitch=.12
   local stable,last=0
   for _=1,1800 do U.wait(1);local s=Scene.streaming
    if Scene.sceneDef==def and s.started==s.completed+s.cancelled and last==s.started then stable=stable+1 else stable=0 end
    last=s.started;if stable>=8 then break end
   end
   assert(stable>=8 and Cam.active,'native scene did not settle')
   for _,mode in ipairs(modes)do
    Water.setting:sync(mode);U.wait(warm);waterDraws,waterMeshes,waterVertices,waterLevels,nativeContext=0,{},0,{},false
    local legacyStart,nativeStart=Water._waveTime(),NativeAnim.counter;local rippleStart=Water._rippleTime()
    local interval={};local streamStart=Scene.performanceSnapshot();local t=love.timer.getTime()
    if measure then FP.WARMUP=0;FP.init(function(n)if n=='POKEPORT_GAME_PROF'then return'all'end end);U.wait(1);t=love.timer.getTime()end
    for _=1,measure and samples or 30 do U.wait(1);local now=love.timer.getTime();interval[#interval+1]=(now-t)*1000;t=now end
    local s=stats(interval);local cpu=measure and FP.stats('draw',samples)or{};local waterCPU=measure and FP.stats('waterPassCPU',samples)or{}
    local record={map=id,nativeLayoutDigest=before,x=spot[1],y=spot[2],facing=spot[3],camera=camera,water=mode,frames=#interval,measured=measure,interval=s,fps=1000/s.mean,cpuDraw=cpu,cpuWater=waterCPU,cpuUpdate=measure and FP.stats('update',samples)or{},cpuPresent=measure and FP.stats('present',samples)or{},cpuDriver=measure and FP.stats('driver',samples)or{},cpuFrame=measure and FP.stats('frame',samples)or{},reportedFPS=measure and FP.fps(samples)or 0,waterVertices=waterVertices,waterDraws=waterDraws,waterLevels=waterLevels,nativeContext=nativeContext,legacyPhase={legacyStart,Water._waveTime()},ripplePhase={rippleStart,Water._rippleTime()},nativeCounter={nativeStart,NativeAnim.counter},gfx=lastGfx,sceneBefore=streamStart,sceneAfter=Scene.performanceSnapshot(),provider=export.performance.snapshot()}
    assert(record.sceneBefore.builds==record.sceneAfter.builds and record.sceneBefore.stream.started==record.sceneAfter.stream.started,'streaming contaminated steady sample')
    results.segments[#results.segments+1]=record
    report:write(table.concat({id,spot[1],spot[2],spot[3],camera,mode,#interval,s.mean,s.p95,s.max,1000/s.mean,cpu.mean or'-',waterCPU.mean or'-',waterCPU.p95 or'-',lastGfx.drawcalls or 0,lastGfx.canvasswitches or 0,waterVertices,record.legacyPhase[1],record.legacyPhase[2],nativeStart,NativeAnim.counter},'\t')..'\n');report:flush()
    local f=assert(io.open(dir..'/surface-results.json','w'));f:write(Json.encode(results));f:close()
    assert(U.shot(game,dir..'/'..id..'-camera'..camera..'-'..mode..'.png'))
    print('[SURFACE]',id,spot[1],spot[2],spot[3],camera,mode,string.format('frame %.3f/%.3fms fps%.1f waterCPU%.3f',s.mean,s.p95,1000/s.mean,waterCPU.mean or 0),'legacy',legacyStart,Water._waveTime(),'native',nativeStart,NativeAnim.counter)
   end
  end
  assert(sourceHash(def)==before,'presentation changed native layout')
 end
 report:close();assert(#game.mods:status().errors==0,table.concat(game.mods:status().errors,';'))
 print('[SURFACE BENCHMARK] PASS',ed,#results.segments,'segments','measurement',measure);love.event.quit()
end
