local phase='day';local weather='clear';local R={vp={}}
local D={time=function()return 0 end,mix=function()return{[phase]=1}end,body=function()return{dx=.3,dy=.8,dz=-.5}end}
local W={clock=123,mode=function()return weather end,isOutdoor=function(m)return m.def.outdoor==true end}
local V={require=function(n)return assert(({Voxel3D=R,DayNight=D,Weather=W})[n],n)end}
local C=assert(loadfile('lib/Clouds.lua'))(V)
local pixels={};local count,soft=0,0
C.field(128,64,function(x,y,r,g,b,a)
 for _,v in ipairs{r,g,b,a}do assert(v==v and v>=0 and v<=1)end
 pixels[y*128+x]={r,g,b,a}
end,function(x,y)local p=pixels[y*128+x];if p then return unpack(p)end;return 0,0,0,0 end)
for _,p in pairs(pixels)do if p[4]>0 then count=count+1;if p[4]>.05 and p[4]<.85 then soft=soft+1 end end end
assert(count>100 and soft>50,'cumulus has no filled bodies/soft transition')
for x=0,127 do assert(not pixels[x],'zenith rim must be clear');assert(not pixels[63*128+x],'horizon rim must be clear')end
math.randomseed(928);local first,nextExpected=math.random(),math.random();math.randomseed(928);assert(math.random()==first)
for y=-12,12 do for x=-15,15 do C.texel(x/10,y/10,2)end end;assert(math.random()==nextExpected,'cloud generation changed global gameplay RNG')
local p=C.parameters({});assert(p.opacity>0 and p.overcast==0)
phase='dusk';local dusk=C.parameters({});assert(dusk.light[1]/dusk.light[3]>p.light[1]/p.light[3],'dusk crown lost warm light')
phase='night';local night=C.parameters({});assert(night.light[1]<p.light[1]and night.opacity<p.opacity)
weather='storm';local storm=C.parameters({});assert(storm.overcast==1 and storm.light[1]<night.light[1]);phase='day';weather='clear'
local vertices=C.geometry();assert(#vertices==1152)
for _,v in ipairs(vertices)do assert(#v==3 and v[2]>=0);local len=math.sqrt(v[1]^2+v[2]^2+v[3]^2);assert(math.abs(len-3200)<1e-6)end
-- Both sides of every longitude seam meet exactly in world space. No plane
-- perimeter or UV rectangle can appear when the eye turns through north.
assert(C.glsl:find('fract(',1,true)and C.glsl:find('cloudDrift',1,true))
local creates,draws,releases,pushes=0,0,0,0;local drawError,meshError=false,false
local state={shader='scene',depth=true,blend='alpha'};local stack={}
local function resource()return{release=function()releases=releases+1 end}end
love={image={},graphics={}}
function love.image.newImageData(w,h)
 local data=resource();local pix={}
 function data:setPixel(x,y,r,g,b,a)assert(x>=0 and x<w and y>=0 and y<h);pix[y*w+x]={r,g,b,a}end
 function data:getPixel(x,y)local p=pix[y*w+x];if p then return unpack(p)end;return 0,0,0,0 end
 return data
end
local g=love.graphics
function g.newShader()creates=creates+1;local s=resource();function s:send()end;return s end
function g.newImage()creates=creates+1;local t=resource();function t:setFilter(a,b)assert(a=='linear'and b=='linear')end;function t:setWrap(a,b)assert(a=='repeat'and b=='clamp')end;return t end
function g.newMesh()if meshError then error('unsupported mesh')end;creates=creates+1;local t=resource();function t:setTexture()end;return t end
function g.push()pushes=pushes+1;stack[#stack+1]={shader=state.shader,depth=state.depth,blend=state.blend}end
function g.pop()state=table.remove(stack);pushes=pushes-1 end
function g.setShader(v)state.shader=v end
function g.setColor()end
function g.setBlendMode(v)state.blend=v end
function g.setDepthMode(_,write)assert(write==false,'clouds reserved terrain depth');state.depth=write end
function g.draw()if drawError then error('draw failed')end;draws=draws+1 end
package.loaded['src.core.Platform']={detect=function()return{mobile=true}end}
local outside={map={def={outdoor=true}},player={px=1,py=2}}
assert(not C.draw({map={def={outdoor=false}}})and creates==0)
assert(C.draw(outside)and C.stats.draws==1 and creates==3 and draws==1)
assert(state.shader=='scene'and state.depth and pushes==0,'cloud state leaked')
assert(C.reflection()and C.reflection().image and C.stats.textureBytes==512*256*4)
assert(C.draw(outside)and creates==3,'warm clouds recreated resources')
R.vp={};assert(not C.reflection(),'stale frame reflected clouds')
assert(C.draw(outside));C.clear();assert(not C.reflection(),'clouds OFF retained sky reflection')
drawError=true;assert(not C.draw(outside)and pushes==0 and state.shader=='scene'and state.depth);drawError=false
C.invalidate();assert(releases>=4,'cloud resources leaked')
meshError=true;local old=releases;assert(not C.draw(outside));assert(releases>=old+3,'partial cloud allocation leaked');local allocated=creates
assert(not C.draw(outside)and creates==allocated,'unsupported renderer retried allocation every frame')
print('PASS soft filled cumulus, no gameplay RNG changes, clock/weather shading, seamless dome, cached one-batch resources, reflection lifecycle and graphics/failure cleanup')
