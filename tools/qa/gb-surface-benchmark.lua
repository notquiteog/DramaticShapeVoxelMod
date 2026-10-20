-- Matched native GB/GBC shore and indoor controls. Run serially on a quiet GPU.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get()
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local gen=V.require('Generation').number()
 local P=require('src.render.Pipelines');local F=V.require('FirstPerson');local R=V.require('Voxel3D')
 local M,S,Water=V.require('ChunkMesher'),V.require('VoxelScene'),V.require('Water')
 local FP=require('src.core.FrameProfiler');local Json=require('src.link.Json');local dir=assert(os.getenv('SHOT_DIR'))
 local samples=tonumber(os.getenv('QA_SAMPLES'))or 180;local warm=tonumber(os.getenv('QA_WARMUP'))or 60
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 assert(love.window.setMode(1280,720,{vsync=0,resizable=false}))
 V.require('AntiAlias').setting:sync(0);V.require('SpatialUpscale').setting:sync(1);V.require('WorldCurve').setting:sync(0)
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day');V.require('Weather').setting:sync('clear');V.require('KantoFirstPerson').sky:sync(false)
 require('src.core.FrameCap').apply(160)
 local results={engine='0.3.91',edition=ed,realistic=Water.REALISTIC==true,renderer={love.graphics.getRendererInfo()},hashes={},segments={}}
 assert(table.concat(results.renderer,' '):lower():find('nvidia',1,true))
 for _,n in ipairs{'Water','NativeWaterSurface','VoxelScene','ChunkMesher','GBWater','ImportedTrees','GrassModels'}do
  local b=assert(V.mod:read('lib/'..n..'.lua'));results.hashes[n]=love.data.encode('string','hex',love.data.hash('sha256',b))
 end
 local metrics={};local draw=love.draw;love.draw=function(...)local a,b=draw(...);metrics=love.graphics.getStats();return a,b end
 local waterDraw=S.drawWater;S.drawWater=function(...)FP.push('waterPassCPU');local a,b=waterDraw(...);FP.pop('waterPassCPU');return a,b end
 local function enter(id,x,y,facing)
  P.setLevel('voxel',0);game.input:reset()
  if gen==1 then U.teleport(game,id,x,y,facing)else game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId(id,x,y,facing))end
  U.wait(25);if game.options then game.options.zoom=0 end;require('src.render.Zoom').reset()
  if gen==2 then game.world:zoomStep(0)end;U.wait(3)
  return gen==1 and game.overworld or game.world
 end
 local function settle()
  local stable=0;for _=1,2400 do U.wait(1);if M.pending()==0 then stable=stable+1 else stable=0 end;if stable>=8 then break end end
  assert(stable>=8,'streaming did not settle');U.wait(20)
 end
 local function stats(a)
  table.sort(a);local n,total=#a,0;for _,v in ipairs(a)do total=total+v end
  return{mean=total/n,median=a[math.ceil(n*.5)],p95=a[math.ceil(n*.95)],max=a[n],min=a[1]}
 end
 local maps=gen==1 and{{'PALLET_TOWN',7,13,'down',0},{'OAKS_LAB',6,10,'up',math.pi}}or{{'CHERRYGROVE_CITY',6,12,'up',math.pi},{'ELMS_LAB',5,8,'up',math.pi}}
 for _,spot in ipairs(maps)do
  local world=enter(spot[1],spot[2],spot[3],spot[4]);assert(world.map.id==spot[1])
  for _,camera in ipairs{3,6}do
   P.setLevel('voxel',camera);settle();if camera==6 then F.yaw=spot[5];F.pitch=.15 end
   for _,mode in ipairs{'full','sky','off'}do
    Water.setting:sync(mode);U.wait(warm)
    FP.WARMUP=0;FP.init(function(n)if n=='POKEPORT_GAME_PROF'then return'all'end end);U.wait(1)
    local intervals={};local t=love.timer.getTime()
    for _=1,samples do U.wait(1);local now=love.timer.getTime();intervals[#intervals+1]=(now-t)*1000;t=now end
    local r={map=spot[1],camera=camera,mode=mode,frames=samples,interval=stats(intervals),drawCPU=FP.stats('draw',samples),waterCPU=FP.stats('waterPassCPU',samples),updateCPU=FP.stats('update',samples),gfx=metrics}
    results.segments[#results.segments+1]=r
    assert(U.shot(game,dir..'/'..spot[1]..'-'..camera..'-'..mode..'.png'))
    local f=assert(io.open(dir..'/gb-surface-benchmark.json','w'));f:write(Json.encode(results));f:close()
    print('[GB SURFACE BENCH]',ed,spot[1],camera,mode,r.interval.median,r.interval.p95,r.gfx.drawcalls)
   end
  end
 end
 assert(#game.mods:status().errors==0);print('[GB SURFACE BENCH] PASS',ed,#results.segments);love.event.quit()
end
