local tuning={ZOOM_MIN=.45,ZOOM_MAX=2.4,ZOOM_STEP=1.18,ZOOM_TIME=.18}
local C=assert(loadfile('lib/Gen3CameraControls.lua'))({require=function(n)assert(n=='ThirdPerson');return tuning end})
local yaw,pitch=0,0
local camera={level=7,look=function(dx,dy)yaw=yaw+dx;pitch=pitch+dy end}
local c=C.new(camera);local x,y,held=10,10,true
local mouse={isDown=function(b)assert(b==2);return held end,getPosition=function()return x,y end}
c:update(.01,true,mouse);assert(yaw==0)
x,y=30,20;c:update(.01,true,mouse);assert(yaw==.1 and pitch==.04)
c:pointer();x=40;c:update(.01,true,mouse);assert(yaw==.1,'hook and poll doubled motion')
c:update(.01,false,mouse);x=500;c:update(.01,true,mouse);assert(yaw==.1,'menu exit jumped camera')
assert(c:step(1) and c.goal==1.18);c:update(.09,true,mouse)
assert(camera.boomZoom>1 and camera.boomZoom<c.goal,'zoom did not ease')
c:step(100);assert(c.goal==2.4);c:step(-100);assert(c.goal==.45)
for _,level in ipairs({0,3,6})do camera.level=level;assert(not c:step(1),'wrong camera stole zoom')end
print('PASS native boom zoom, Gen1 tuning, mouse polling, hook deduplication and menu ownership')
