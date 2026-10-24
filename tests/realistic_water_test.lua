local T=require('tests.modkit')
local root=os.getenv('DS_MOD_PATH')or'.'
local run=T.sdk.loadMod(root,{data=T.fixtures.load()});assert(#run.errors==0,table.concat(run.errors,';'))
local V=assert(run.loader.exports.BATTLE_ART_VOXEL_FORK).lib
local W=V.require('Water');assert(W.REALISTIC and W.setting.values[1]=='full')
assert(#W.setting.values==3 and W.setting.values[2]=='sky'and W.setting.values[3]=='off','existing native settings ladder changed')
local created,released=0,0
local original=love.graphics.newShader
love.graphics.newShader=function(source)
 created=created+1
 assert(not source:find('void relief',1,true)and not source:find('waveNormal(',1,true),'expensive column path still compiled')
 assert(not source:find('waveUV(',1,true)and not source:find('p.rgb',1,true),'sprite RGB still colors water')
 return{release=function()released=released+1 end,send=function()end}
end
W.invalidate()
for _,native in ipairs{false,true}do for _,sky in ipairs{false,true}do
 local sh=assert(W.shader(false,sky,native));assert(W.shader(true,sky,native)==sh,'grid compiled duplicate program')
 if not native and not sky then
  assert(not W._source(false,false,false,false):find('uniform Image cloudAtlas',1,true),'precise underColor FULL exceeds eight samplers')
 end
end end
assert(created==4,'unexpected program count '..created)
W.invalidate();assert(released==4,'shader ownership leaked or double released')
love.graphics.newShader=original
-- Curved compact RGB can include the native prepass. Keep precise depth
-- occlusion active while disabling only this unsafe transmission source.
local factory=W.shader;local uniforms,family={},nil
W.shader=function(_,_,compact)family=compact;return{send=function(_,name,...)uniforms[name]={...}end}end
local ctx={vp=V.require('Mat4').identity(),eye={0,10,0},curve={0,0,.0001},screen={320,288},
 reflect={},depth={},underDepth={},nativeWater=true}
W.setting:sync('full');assert(W.begin(ctx,false))
assert(family and uniforms.underOn[1]==1 and uniforms.transmissionOn[1]==0,'curved compact guard disabled depth or retained prepass color')
W.finish();ctx.curve[3]=0;assert(W.begin(ctx,false));assert(uniforms.transmissionOn[1]==1 and uniforms.underOn[1]==1);W.finish()
ctx.curve[3]=.0001;ctx.nativeWater=false;ctx.underColor={}
assert(W.begin(ctx,false));assert(not family and uniforms.underOn[1]==1 and uniforms.transmissionOn[1]==1,'precise opaque-color family lost safe curved transmission');W.finish()
W.shader=factory
local S=V.require('NativeWaterSurface')
for _,t in ipairs{0,.2,41,40*math.pi-.001}do
 for x=-3000,3000,137 do
  local h,dx,dz=S.sample(x,x*.75,t)
  assert(h>=0 and h<=1 and math.abs((h-.5)*S.HEIGHT)<=.15,'waves escaped physical bank clearance')
  local h2=S.sample(x,x*.75,t+.001);assert(h2==h2 and dx==dx and dz==dz)
 end
end
print('PASS realistic FULL default, existing SKY/OFF, four shared programs, no relief/sourceRGB path, lifecycle and bounded continuous large-world surface')
-- Exercise the production draw loop, including begin's uniform reset.
local sends,draws=0,0
local oldDraw=love.graphics.draw
love.graphics.draw=function()draws=draws+1 end
W.shader=function()return {send=function()sends=sends+1 end}end
local mesh={setTexture=function()end};local palette={.2,.4,.8,.88}
local model=V.require('Mat4').identity()
assert(W.begin(ctx,false));sends=0
for i=1,100 do W.draw(mesh,nil,model,palette)end
assert(draws==100 and sends==6,'water batching changed draw count or repeated uniforms')
palette[2]=.5;model[4]=4;W.draw(mesh,nil,model,palette)
assert(draws==101 and sends==8,'production draw lost mutable palette/model changes')
W.finish();assert(W.begin(ctx,false));sends=0;W.draw(mesh,nil,model,palette)
assert(sends==6,'new water pass reused uniforms overwritten by begin')
W.finish();W.shader=factory;love.graphics.draw=oldDraw
print('PASS production water mesh batch preserves 100 draws with 6 uniform sends, live changes and pass invalidation')
