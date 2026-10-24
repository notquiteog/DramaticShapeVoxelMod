-- Execute the production preparation/provider/card path with native seams.
local source=assert(io.open('lib/Gen3Scene.lua')):read('*a')
local first=assert(source:find("local actorFrames=",1,true))
local last=assert(source:find('\nfunction M.groundAt',first,true))
local factory=assert(loadstring('return function(V,cache,Sprites,SpriteAnchor,spriteMeshes,R,Mat,Shadow,M,quad) local reflectPlane,actorPlanes\n'..
 source:sub(first,last-1)..'\nreturn {draw=actor,begin=function()actorFrames:begin()end,plane=function(p)reflectPlane=p end} end'))()
local Mat=dofile('lib/Mat4.lua');local prepared,padded,ground,providers,contacts=0,0,0,0,0
local calls={};local function draw(mesh,image,model,_,caster)calls[#calls+1]={model=model,caster=caster}end
local Sh={draw=function(...)return draw(...)end,snug=function(base)local out={unpack(base)};out[8]=out[8]+.01;return out end}
local spr={width=16,image={},quads={[0]={getViewport=function()return 0,0,16,24 end}}}
local meshes={[tostring(spr)..':'..tostring(spr.image)..':0:false:2']={}}
local modules={ActorFrameCache=dofile('lib/ActorFrameCache.lua'),Gen3Integration={worldDirection=function(f)return f end},
 Water={CAST_RAISE=.03},SpriteFrustum={visible=function()return true end},ActorContact={draw=function()contacts=contacts+1 end}}
local providerOwns=false
for _,name in ipairs{'Gen3Boats','Gen3TruckExterior','Gen3TruckCargo','NativeItemPokeballs','NativeLegendarySapling'}do
 modules[name]={draw=function()providers=providers+1;return providerOwns end}
end
local S={getDraw=function()prepared=prepared+1;return spr end,pose=function(_,f,p,flip,opts)
 assert(opts.frame==0 and opts.fieldMoveFrame==4 and opts.running==1);return 0,false end}
local A={framePadding=function()padded=padded+1;return 2 end}
local height=6
local M={groundAt=function()ground=ground+1;return height end}
local actor=factory({require=function(n)return assert(modules[n],n)end},{cells={['0:0']={}}},S,A,meshes,{},Mat,Sh,M,function()error('unexpected mesh rebuild')end)
local id,cam={}, {level=7,yaw=.4}
local function paint(fn)
 actor.draw(1,0,0,'up',0,false,{frame=0,lift=1,fieldMoveFrame=4,running=1},cam,fn,id)
end
actor.begin();paint(Sh.draw)
for _,plane in ipairs{4,-2,8,9}do actor.plane(plane);paint(draw);assert(calls[#calls].model[8]==2*plane-7+.03)end
actor.plane(nil)
local mainDraw=function(...)return draw(...)end
paint(mainDraw)
assert(prepared==1 and padded==1 and ground==1 and providers==30 and contacts==1,'preparation/provider/pass counts changed')
assert(#calls==6 and calls[1].model[8]==7.01 and calls[6].model[8]==7,'shadow/main matrices changed')
assert(calls[6].caster[8]==7.01,'receiver lost snugged shadow transform')
providerOwns=true;paint(mainDraw);assert(#calls==6 and providers==31,'provider ownership was cached or bypassed')
providerOwns=false;height=10;actor.begin();paint(mainDraw)
assert(prepared==2 and ground==2 and calls[#calls].model[8]==11,'next render reused stale ground')
cam.yaw=.8;paint(mainDraw);assert(prepared==3,'same-render changed camera context ignored')
print('PASS production actor preparation reused across shadow/fourreflections/main; native hooks, matrix datums, ownership, fresh render and camera context preserved')
