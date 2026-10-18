local Look=assert(loadfile('lib/CameraLook.lua'))()
assert(Look.axis(.18)==0 and Look.axis(-.18)==0)
assert(Look.axis(1)==1 and Look.axis(-1)==-1 and Look.axis(5)==1)
assert(math.abs(Look.axis(.59)-.25)<1e-9)
assert(Look.axis(0/0)==0)
local stick={x=1,y=-1,controller={isConnected=function()return false end}}
assert(Look.resetLost(stick)and stick.x==0 and stick.y==0)
stick.x=1;assert(Look.resetLost(stick,{hasFocus=function()return false end})and stick.x==0)
stick.x=1;assert(not Look.resetLost(stick,{hasFocus=function()return true end})and stick.x==1)
local Touch=assert(loadfile('lib/CameraTouch.lua'))()
local t=Touch.new();local points={};local turns,scales=0,0;local dx,dy,last
local api={getTouches=function()local ids={};for id in pairs(points)do ids[#ids+1]=id end;table.sort(ids);return ids end,
 getPosition=function(id)return points[id][1],points[id][2]end}
local overlay={hitTest=function(_,x)return x<100 and 'dpad' or nil end}
local function update(mode)
 t:update(api,overlay,mode,1000,500,function(x,y)turns=turns+1;dx,dy=x,y end,
 mode==7 and function(f)scales=scales+1;last=f end or nil)
end
points.a={20,20};update(7);points.a={400,200};update(7)
assert(turns==0,'native dpad touch changed ownership after leaving pad')
points.b={400,200};update(7);points.b={500,250};update(7)
assert(turns==1 and dx==.1 and dy==.1)
points.c={700,250};update(7);points.c={800,250};update(7)
assert(scales==1 and last==1.5 and turns==1,'pinch also turned camera')
points.c=nil;update(7);assert(turns==1,'pinch release jumped camera')
points.b={520,250};update(7);assert(turns==2)
update(nil);points.b={550,250};update(7);assert(turns==2,'menu finger became a look drag')
points={};update(7);points.b={500,250};update(6);points.b={550,260};update(6)
assert(turns==3 and scales==1,'first person lost look or changed zoom')
points.b={570,270};update(7);assert(turns==3,'mode change jumped view')
points={};update(nil)
overlay.active=false;points.a={20,20};update(7);points.a={40,20};update(7)
assert(turns==4,'disabled touch overlay reserved invisible buttons')
print('PASS shared precision response, disconnect/focus, touch ownership, pinch, menus and mode changes')
