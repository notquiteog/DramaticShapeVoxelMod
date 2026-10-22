local root=os.getenv('DS_MOD_PATH')or'.'
local S=assert(loadfile(root..'/lib/SceneSize.lua'))()
local ww,wh,pw,ph=360,640,360,640
love={graphics={getDimensions=function()return ww,wh end,getPixelDimensions=function()return pw,ph end}}
local function check(w,h,ew,eh)
 local a,b=S.pixels{width=w,height=h};assert(a==ew and b==eh,tostring(a)..'x'..tostring(b))
end
check(360,640,360,640)
check(320,300,320,300) -- reserved viewport/portrait controller layout
ww,wh,pw,ph=360,640,945,1680
check(360,640,945,1680) -- preserve full-screen Android high-DPI sizing
check(320,300,840,788) -- crop first, then drawable resolution
ww,wh,pw,ph=640,360,1280,720
check(500,300,1000,600)
love.graphics.getPixelDimensions=nil;check(500,300,500,300)
print('scene_size_test: 6 checks passed')
