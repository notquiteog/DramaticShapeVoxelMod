-- Real GPU invariance test: sprite-wave RGB cannot alter realistic material,
-- while source alpha still cuts coverage. No engine callbacks are replaced.
return function(game)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local W,R,Mat=V.require('Water'),V.require('Voxel3D'),V.require('Mat4')
 assert(W.REALISTIC and W.setting.values[1]=='full')
 local identity=Mat.identity()
 local projection={1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1}
 local vertices={{-1,0,-1,0,0,1},{1,0,-1,1,0,1},{1,0,1,1,1,1},{-1,0,1,0,1,1}}
 local mesh=assert(R.newMesh(vertices,{1,2,3,1,3,4}))
 local function texture(striped,cut)
  local d=love.image.newImageData(4,4)
  for y=0,3 do for x=0,3 do
   local stripe=striped and(x+y)%2==0
   d:setPixel(x,y,stripe and 1 or .03,stripe and 1 or .2,stripe and 1 or .4,cut and x<2 and 0 or 1)
  end end
  local image=love.graphics.newImage(d);d:release();image:setFilter('nearest','nearest');return image
 end
 local a,b,c=texture(false),texture(true),texture(true,true)
 local canvas=love.graphics.newCanvas(64,64,{format='rgba8',dpiscale=1})
 local packed=love.image.newImageData(1,1);packed:setPixel(0,0,191/255,1,1,1)
 local bedDepth=love.graphics.newImage(packed);packed:release()
 local d=love.image.newImageData(1,1);d:setPixel(0,0,1,1,1,1);local farDepth=love.graphics.newImage(d);d:release()
 local inverse={1,0,0,0,0,0,-8,0,0,1,0,0,0,0,0,1}
 local function render(sh,texture,bed,transmit)
  love.graphics.push('all');love.graphics.setCanvas(canvas);love.graphics.clear(.8,.1,.8,1)
  love.graphics.setShader(sh);love.graphics.setColor(1,1,1,1);love.graphics.setBlendMode('replace')
  love.graphics.setDepthMode();love.graphics.setMeshCullMode('none');love.graphics.origin()
  local function send(name,...)if sh:hasUniform(name)then sh:send(name,...)end end
  send('vp','row',projection);send('model','row',identity);send('sunVP','row',identity)
  send('eye',{0,10,0});send('curve',{0,0,bed and .0001 or 0});send('sunDark',0);send('dayTint',{1,1,1})
  send('sunMap',a);send('skyRamp',a);send('cloudAtlas',a);send('castTex',a)
  send('skyOn',0);send('bodyOn',0);send('castOn',0);send('cloudOpacity',0)
  send('nativePalette',{0,0,0,0});send('waveHeight',.3);send('waveSlope',3.2);send('rippleT',1)
  send('fresnelFloor',.08);send('fresnelCeil',.92);send('fogInfo',{0,0,0,0})
  send('underOn',bed and 1 or 0);send('transmissionOn',transmit or 0)
  send('underDepth',bedDepth);send('depthTex',farDepth);send('reflectTex',bed or a);send('underColor',bed or a)
  send('inverseVP','row',inverse);send('rays',0)
  mesh:setTexture(texture);love.graphics.draw(mesh)
  love.graphics.pop();return canvas:newImageData()
 end
 local result={renderer={love.graphics.getRendererInfo()},variants={},samplers={}}
 for _,native in ipairs{false,true}do
  for _,sky in ipairs{false,true}do
   local shader=assert(W.shader(false,sky,native));local names={'MainTex'}
   for _,name in ipairs{'sunMap','reflectTex','underColor','underDepth','depthTex','castTex','skyRamp','cloudAtlas'}do
    if shader:hasUniform(name)then names[#names+1]=name end
   end
   assert(#names<=8,'GLES2 sampler budget exceeded '..#names)
   result.samplers[#result.samplers+1]={native=native,sky=sky,count=#names,names=names}
  end
  local sh=assert(W.shader(false,true,native));assert(W.shader(true,true,native)==sh)
  assert(W.shader(false,false,native),'FULL realistic program did not compile')
  local x,y,z=render(sh,a),render(sh,b),render(sh,c);local maxDiff,transparent,painted=0,0,0
  for j=0,63 do for i=0,63 do
   local ar,ag,ab=x:getPixel(i,j);local br,bg,bb=y:getPixel(i,j)
   maxDiff=math.max(maxDiff,math.abs(ar-br),math.abs(ag-bg),math.abs(ab-bb))
   local cr,cg,cb=z:getPixel(i,j)
   if math.abs(cr-.8)<.01 and math.abs(cg-.1)<.01 and math.abs(cb-.8)<.01 then transparent=transparent+1 else painted=painted+1 end
  end end
  x:release();y:release();z:release()
  assert(maxDiff==0,'native pixel-wave RGB leaked into realistic shader '..maxDiff)
  assert(transparent==2048 and painted==2048,'source alpha coverage changed '..transparent..'/'..painted)
  result.variants[#result.variants+1]={native=native,maxRGBDifference=maxDiff,transparent=transparent,painted=painted}
 end
 local function difference(x,y)
  local delta=0
  for j=0,63 do for i=0,63 do local a,b,c=x:getPixel(i,j);local d,e,f=y:getPixel(i,j);delta=math.max(delta,math.abs(a-d),math.abs(b-e),math.abs(c-f))end end
  x:release();y:release();return delta
 end
 local full=assert(W.shader(false,false,true))
 local guarded=difference(render(full,a,a,0),render(full,a,b,0))
 local exposed=difference(render(full,a,a,1),render(full,a,b,1))
 assert(guarded==0 and exposed>.01,'curved positive-depth transmission guard not exercised '..guarded..'/'..exposed)
 result.curvedTransmission={curvature=.0001,bedDepth=4,guardedRGBDifference=guarded,positiveControlRGBDifference=exposed}
 bedDepth:release();farDepth:release()
 mesh:release();a:release();b:release();c:release();canvas:release()
 local f=assert(io.open(assert(os.getenv('SHOT_DIR'))..'/water-material-gpu.json','w'));f:write(require('src.link.Json').encode(result));f:close()
 print('[REALISTIC GPU MATERIAL] PASS sourceRGB invariance, alpha coverage, four shader programs, grid reuse')
end
