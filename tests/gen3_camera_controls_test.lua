local tuning={ZOOM_MIN=.45,ZOOM_MAX=2.4,ZOOM_STEP=1.18,ZOOM_TIME=.18,BOOM_TIME=.35}
local C=assert(loadfile('lib/Gen3CameraControls.lua'))({require=function(n)if n=='CameraLook'then return assert(loadfile('lib/CameraLook.lua'))()end;assert(n=='ThirdPerson');return tuning end})
local yaw,pitch=0,0
local camera={level=7,look=function(dx,dy)yaw=yaw+dx;pitch=pitch+dy end}
local c=C.new(camera);local x,y,held=10,10,true
local mouse={isDown=function(b)assert(b==2);return held end,getPosition=function()return x,y end}
c:update(.01,true,mouse);assert(yaw==0)
x,y=30,20;c:update(.01,true,mouse);assert(math.abs(yaw-.064)<1e-9 and math.abs(pitch-.032)<1e-9)
c:pointer();x=40;c:update(.01,true,mouse);assert(math.abs(yaw-.064)<1e-9,'hook and poll doubled motion')
c:update(.01,false,mouse);x=500;c:update(.01,true,mouse);assert(math.abs(yaw-.064)<1e-9,'menu exit jumped camera')
assert(c:step(1) and c.goal==1.18);c:update(.09,true,mouse)
assert(camera.boomZoom>1 and camera.boomZoom<c.goal,'zoom did not ease')
assert(c:scale(2)and c.goal==2.36);assert(not c:scale(0));c:step(100);assert(c.goal==2.4);c:step(-100);assert(c.goal==.45)
for _,level in ipairs({0,3,6})do camera.level=level;assert(not c:step(1),'wrong camera stole zoom')end
camera.level=6;c:update(.01,true,mouse);c:update(1,true,mouse)
assert(camera.boomBlend==0)
camera.level=7;c:update(.035,true,mouse)
assert(camera.boomBlend>0 and camera.boomBlend<.1,'1ST to 3RD snapped its boom')
local last=camera.boomBlend
c:update(.035,false,mouse)
assert(camera.boomBlend>last,'dialogue/menu interrupted ongoing boom interpolation')
c:update(1,true,mouse);assert(camera.boomBlend==1)
camera.level=6;c:update(.035,true,mouse)
assert(camera.boomBlend<1 and camera.boomBlend>.9,'3RD to 1ST snapped its boom')
camera.level=3;c:update(.01,false,mouse,math.rad(35))
camera.level=5;c:update(.025,false,mouse,math.rad(75))
assert(camera.angle>math.rad(35)and camera.angle<math.rad(40),'fixed angle snapped')
local angle=camera.angle
camera.level=2;c:update(.001,false,mouse,math.rad(15))
assert(math.abs(camera.angle-angle)<.001,'mid-tween mode change recentered angle')
c:update(.3,false,mouse,math.rad(15));assert(math.abs(camera.angle-math.rad(15))<1e-9)
print('PASS native boom zoom, Gen1 tuning, mouse polling, hook deduplication and menu ownership')
