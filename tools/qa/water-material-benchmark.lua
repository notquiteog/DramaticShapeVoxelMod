-- Isolated material throughput. Durations include CPU submission, GPU completion
-- and a one-pixel (or reported full-canvas fallback) readback. They are neither
-- hardware GPU timestamps nor native-game FPS. Reserve a quiet GPU window.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 assert(require('src.core.Version').engine=='0.3.91')
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local W,R,Mat=V.require('Water'),V.require('Voxel3D'),V.require('Mat4')
 local w,h=tonumber(os.getenv('QA_WIDTH'))or 768,tonumber(os.getenv('QA_HEIGHT'))or 512
 local batch,samples=tonumber(os.getenv('QA_BATCH'))or 24,tonumber(os.getenv('QA_SAMPLES'))or 16
 local canvas=love.graphics.newCanvas(w,h,{format='rgba8',dpiscale=1})
 local data=love.image.newImageData(8,8)
 for y=0,7 do for x=0,7 do local q=(x+y)%3==0;data:setPixel(x,y,q and .85 or .1,q and .95 or .3,q and 1 or .6,1)end end
 local art=love.graphics.newImage(data);data:release();art:setFilter('nearest','nearest')
 local whiteData=love.image.newImageData(1,1);whiteData:setPixel(0,0,1,1,1,1)
 local white=love.graphics.newImage(whiteData);whiteData:release()
 local clearData=love.image.newImageData(1,1);clearData:setPixel(0,0,0,0,0,0)
 local clear=love.graphics.newImage(clearData);clearData:release()
 local mesh=assert(R.newMesh({{-256,0,-256,0,0,1},{256,0,-256,1,0,1},{256,0,256,1,1,1},{-256,0,256,0,1,1}},{1,2,3,1,3,4}));mesh:setTexture(art)
 local projection={1/256,0,0,0,0,0,1/256,0,0,0,0,0,0,0,0,1}
 local sunMatrix={1/512,0,0,.5,0,0,1/512,.5,0,0,0,.5,0,0,0,1}
 local flat=love.graphics.newShader([[
 uniform mat4 vp;
 #ifdef VERTEX
 vec4 position(mat4 ignored,vec4 p){return vp*p;}
 #endif
 #ifdef PIXEL
 vec4 effect(vec4 color,Image tex,vec2 uv,vec2 sc){return Texel(tex,uv)*color;}
 #endif
 ]])
 local result={engine='0.3.91',edition=require('src.core.GameVersion').get(),realistic=W.REALISTIC==true,
  renderer={love.graphics.getRendererInfo()},method='synchronous GPU-completed batch latency, CPU submission and readback included; not GPU timestamp/FPS',width=w,height=h,batch=batch,samples=samples,hashes={},segments={}}
 assert(table.concat(result.renderer,' '):lower():find('nvidia',1,true))
 for _,name in ipairs{'Water','NativeWaterSurface','Clouds'}do local b=V.mod:read('lib/'..name..'.lua');result.hashes[name]=love.data.encode('string','hex',love.data.hash('sha256',b))end
 love.graphics.push('all');love.graphics.setCanvas(canvas);love.graphics.origin()
 love.graphics.setBlendMode('replace');love.graphics.setColor(1,1,1,1);love.graphics.setDepthMode();love.graphics.setMeshCullMode('none')
 local tiny=pcall(function()local d=canvas:newImageData(1,1,0,0,1,1);assert(d:getWidth()==1 and d:getHeight()==1);d:release()end)
 result.readback=tiny and'one pixel'or'full canvas'
 local function finishGPU()
  love.graphics.flushBatch();love.graphics.setCanvas()
  local d=tiny and canvas:newImageData(1,1,0,0,1,1)or canvas:newImageData();d:release()
  love.graphics.setCanvas(canvas)
 end
 local function bind(shader,native)
  love.graphics.setShader(shader)
  local function send(name,...)if shader:hasUniform(name)then shader:send(name,...)end end
  send('vp','row',projection);send('model','row',Mat.identity());send('sunVP','row',sunMatrix)
  send('eye',{0,140,240});send('curve',{0,0,0});send('screen',{w,h});send('cell',1);send('pxAngle',1/h)
  send('sunMap',white);send('sunDark',.32);send('sunBias',.001);send('sunTexel',{1/1024,1/1024});send('dayTint',{1,1,1})
  send('reflectTex',art);send('depthTex',white);send('underDepth',white);send('underColor',art);send('underOn',0);send('transmissionOn',1);send('inverseVP','row',Mat.identity())
  send('rays',1);send('castTex',clear);send('castOn',1);send('castAlpha',.55);send('castWobble',.006)
  send('lookFlat',{0,0,-1});send('lean',0);send('leanElev',.3);send('faceShade',{.9,.8,.85,.95})
  local surface=V.require('NativeWaterSurface')
  send('waveHeight',(result.realistic or native)and surface.HEIGHT or W.WAVE_HEIGHT)
  send('waveSlope',(result.realistic or native)and surface.SLOPE or W.WAVE_SLOPE);send('waveSlopeLean',1.5)
  send('waveT',1);send('rippleT',1);send('nativeWater',native and 1 or 0);send('nativePalette',{0,0,0,0})
  send('reserveWater',0);send('gardenWater',0);send('atlasTileScale',1);send('atlasSize',{8,8})
  send('fresnelFloor',W.FRESNEL_FLOOR);send('fresnelCeil',W.FRESNEL_CEIL);send('fresnelPower',W.FRESNEL_POWER)
  send('rayStep',W.RAY_STEP);send('rayGrow',W.RAY_GROW);send('rayThick',W.RAY_THICK);send('edgeFade',W.EDGE_FADE)
  send('skyRamp',art);send('skyCount',8);send('skyEdge',h);send('skyStart',2);send('skyOn',1)
  send('bodyOn',0);send('cloudAtlas',clear);send('cloudOpacity',0);send('fogInfo',{0,0,0,0})
 end
 local function segment(label,shader,native)
  bind(shader,native);love.graphics.clear(0,0,0,1)
  for _=1,24 do love.graphics.draw(mesh)end;finishGPU()
  local times={}
  for _=1,samples do
   local before=love.graphics.getStats();local t=love.timer.getTime()
   for _=1,batch do love.graphics.draw(mesh)end
   finishGPU();times[#times+1]=(love.timer.getTime()-t)*1000
   local after=love.graphics.getStats();assert(after.drawcalls-before.drawcalls==batch,'unexpected material submission count')
  end
  table.sort(times);local total=0;for _,n in ipairs(times)do total=total+n end
  local r={label=label,batchMeanMs=total/#times,batchMedianMs=times[math.ceil(#times/2)],batchP95Ms=times[math.ceil(#times*.95)],draws=batch,minimumMs=times[1],maximumMs=times[#times],rawMs=times}
  result.segments[#result.segments+1]=r;print('[WATER MATERIAL BENCH]',label,r.batchMedianMs,r.batchP95Ms,'ms per',batch,'GPU-completed draws')
 end
 segment('flat-control-before',flat,false)
 for _,native in ipairs{false,true}do for _,sky in ipairs{true,false}do segment((native and'gba-'or'gb-')..(sky and'sky'or'full'),assert(W.shader(false,sky,native)),native)end end
 segment('flat-control-after',flat,false)
 love.graphics.setCanvas();love.graphics.pop()
 mesh:release();art:release();white:release();clear:release();canvas:release();flat:release()
 local f=assert(io.open(assert(os.getenv('SHOT_DIR'))..'/water-material-benchmark.json','w'));f:write(require('src.link.Json').encode(result));f:close()
 print('[GPU-COMPLETED MATERIAL BENCH] PASS',result.realistic and'realistic'or'prior',result.readback);love.event.quit()
end
