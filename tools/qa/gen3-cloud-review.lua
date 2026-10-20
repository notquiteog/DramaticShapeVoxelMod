-- Standalone native sky review; isolated QA saves only. For warm CPU submission
-- comparisons set QA_CLOUD_BENCH=1 and run one process at a time on the same GPU.
-- This measures host submission, not GPU execution time. Frozen packages can use
-- this unchanged driver through their normal QA_SUBDRIVER wrapper.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'isolated QA identity required')
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get()
 local prefix=({emerald='EM_',ruby='RU_',sapphire='SA_'})[ed]or'FR_'
 local dir=assert(os.getenv('SHOT_DIR'));local bench=os.getenv('QA_CLOUD_BENCH')=='1'
 local update=game.update;game.update=function(self,dt)self.input:reset();return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=prefix=='FR_'and'FR_PALLET_TOWN'or prefix..'OLDALE_TOWN',x=10,y=9,facing='up'}})
 local export=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK);local V=export.lib
 local K,R,C=V.require('KantoFirstPerson'),V.require('Voxel3D'),V.require('Gen3Integration')
 local Day,Weather=V.require('DayNight'),V.require('Weather');local okCloud,Cloud=pcall(V.require,'Clouds')
 assert(love.window.setMode(1280,720,{vsync=0,resizable=false}));require('src.core.VSync').apply('off');require('src.core.FrameCap').apply(160)
 V.require('RenderDistance').setting:sync(16);V.require('Water').setting:sync('off')
 V.require('AntiAlias').setting:sync(0);V.require('SpatialUpscale').setting:sync(1);V.require('WorldCurve').setting:sync(0)
 K.horizon:sync('off');K.aircraft:sync(false);K.birds:sync(false);K.rainbows:sync(false);K.bindGame(game)
 Weather.setting:sync('clear');Day.setting:sync('day');K.sky:sync(false);C.setLevel(6,game);C.yaw=0;C.pitch=-.50
 local stable,last=0
 for _=1,1800 do U.wait(1);local s=V.require('Gen3Scene').streaming
  if s.started==s.completed+s.cancelled and last==s.started and C.active then stable=stable+1 else stable=0 end
  last=s.started;if stable>=8 then break end
 end
 assert(stable>=8,'native scene did not settle')
 require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss()
 local rows,active={},false;local calls,verts=0,0;local kd,rd=K.draw,R.draw
 R.draw=function(mesh,...)if active then calls=calls+1;verts=verts+(mesh.getVertexCount and mesh:getVertexCount()or 0)end;return rd(mesh,...)end
 K.draw=function(state)
  calls,verts=0,0;active=true;local before=love.graphics.getStats().drawcalls;local start=love.timer.getTime()
  local out=kd(state);local elapsed=(love.timer.getTime()-start)*1000;active=false
  rows[#rows+1]={elapsed,calls,verts,love.graphics.getStats().drawcalls-before};return out
 end
 local renderer={love.graphics.getRendererInfo()};print('[CLOUD GPU]',unpack(renderer))
 local output=assert(io.open(dir..'/cloud-results.tsv','w'));output:write('edition\tcase\tframes\tcpu_median_ms\tcpu_p95_ms\tlegacy_draws\tlegacy_vertices\tgraphics_draws\thost_cloud_draws\thost_cloud_vertices\ttexture_bytes\n')
 local function capture(name,phase,mode,on,yaw)
  Day.setting:sync(phase);Weather.setting:sync(mode);K.sky:sync(on);C.yaw=yaw or 0
  U.wait(bench and 90 or 12);rows={};U.wait(bench and 240 or 3)
  local times={};for i,row in ipairs(rows)do times[i]=row[1]end;table.sort(times);assert(#times>0,'cloud path not drawn')
  local row=rows[#rows];local draws=okCloud and Cloud.stats.draws or 0;local vertices=draws>0 and Cloud.stats.vertices or 0
  output:write(table.concat({ed,name,#times,times[math.ceil(#times*.5)],times[math.ceil(#times*.95)],row[2],row[3],row[4],draws,vertices,okCloud and Cloud.stats.textureBytes or 0},'\t')..'\n');output:flush()
  if okCloud then assert(on==false or draws==1,Cloud.status);assert((Cloud.reflection()~=nil)==on,'cloud reflection eligibility mismatch')end
  assert(U.shot(game,dir..'/'..name..'.png'));print('[CLOUD CASE]',ed,name,'submission median/p95 ms',times[math.ceil(#times*.5)],times[math.ceil(#times*.95)],'draws',row[4])
 end
 capture('day-OFF','day','clear',false)
 capture('day-LAYERED','day','clear',true)
 if not bench then capture('day-side','day','clear',true,1.7);capture('day-seam-left','day','clear',true,math.pi-.01);capture('day-seam-right','day','clear',true,-math.pi+.01);capture('dusk-LAYERED','dusk','clear',true)end
 capture('night-OFF','night','clear',false);capture('night-LAYERED','night','clear',true);capture('storm-LAYERED','day','storm',true)
 if not bench then
  C.setLevel(0,game);local Map=require('src.core.game3.map');assert(Map.load(nil,game,prefix=='FR_'and'FR_OAKS_LAB'or prefix..'LITTLEROOT_TOWN_PROFESSOR_BIRCHS_LAB',{x=6,y=9,facing='up'}));require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(3);C.setLevel(6,game);C.pitch=.08
  local stable,last=0,0
  for _=1,1800 do U.wait(1);local scene=V.require('Gen3Scene');local s=scene.streaming
   if scene.sceneDef==Map.currentDef()and s.started==s.completed+s.cancelled and last==s.started then stable=stable+1 else stable=0 end
   last=s.started;if stable>=8 then break end
  end
  assert(stable>=8,'indoor scene did not settle');require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(3)
  assert(U.shot(game,dir..'/indoor.png'));if okCloud then assert(not Cloud.reflection(),'indoor retained cloud reflection')end
 end
 output:close();assert(#game.mods:status().errors==0);print('[CLOUD REVIEW] PASS',ed,bench and'CPU submission benchmark'or'visual+OFF+indoor');love.event.quit()
end
