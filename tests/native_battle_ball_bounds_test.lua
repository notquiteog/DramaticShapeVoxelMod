local draws,canvases=0,0;local active='world';local restored=0
local G={getCanvas=function()return active end,setCanvas=function(c)active=c end,
 push=function()end,pop=function()restored=restored+1 end,
 setDepthMode=function()end,origin=function()end,setShader=function()end,setScissor=function()end,clear=function()end,
 setColor=function()end,setBlendMode=function()end,
 newQuad=function(x,y,w,h)assert(y==0,'open animation frame changed resting radius');return{release=function()end}end,
 draw=function()draws=draws+1 end}
local bottom=14
G.newCanvas=function()canvases=canvases+1;return{release=function()end,newImageData=function()return{
 getPixel=function(_,x,y)return 1,1,1,(x>=2 and x<14 and y>=2 and y<bottom)and 1 or 0 end,
 release=function()end}end}end
love={graphics=G}
local M=dofile('lib/NativeBattleBallBounds.lua')
local image={getDimensions=function()return 192,48 end}
local quad={getViewport=function()return 0,32,16,16 end}
assert(M.radius(image,quad)==6 and M.radius(image,quad)==6)
assert(canvases==1 and active=='world'and restored==1)
bottom=16
assert(M.radius({getDimensions=image.getDimensions},quad)==8,'custom full-frame art was clipped')
assert(M.radius(nil,nil)==6 and M.radius(image,32)==6)
G.draw=function()error('readback unavailable')end
local retry={getDimensions=image.getDimensions}
assert(M.radius(retry,quad)==6 and active=='world')
G.draw=function()end
assert(M.radius(retry,quad)==8,'transient readback failure permanently cached')
print('PASS native/custom closed-ball opaque footing, shared cache and failure state restoration')
