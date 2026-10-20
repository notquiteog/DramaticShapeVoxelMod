local allocations,draws,canvas,restore,depthSource,depthFailure={},{},nil,{},nil,false
local function target(w,h)
 local t={w=w,h=h}
 function t:setFilter(a,b)self.filter={a,b}end
 function t:setWrap(a,b)self.wrap={a,b}end
 return t
end
local shader={send=function(_,name,value)assert(name=='sourceDepth');depthSource=value end}
local g={newShader=function()return shader end,push=function()end,pop=function()end,
 origin=function()end,setScissor=function()end,setStencilTest=function()end,setDepthMode=function()end,
 setShader=function()end,setColor=function()end,setBlendMode=function()end,clear=function()end,
 setCanvas=function(c)canvas=c end,draw=function(source)
  if depthFailure then error('simulated snapshot failure')end
  draws[#draws+1]={source,canvas}
 end}
_G.love={graphics=g}
local B=assert(loadfile('lib/WaterBackdrop.lua'))({require=function(name)
 assert(name=='PixelCanvas');return {new=function(w,h)local t=target(w,h);allocations[#allocations+1]=t;return true,t end}
end})
local source,depth={},{};local slot={w=641,h=361,depth=depth}
local color,packed=B.capture(slot,source,restore,true)
assert(not color and packed==slot.underDepth and not slot.underColor)
assert(#allocations==1 and packed.w==641 and packed.h==361 and #draws==1 and draws[1][2]==packed)
assert(depthSource==depth and canvas==restore and packed.filter[1]=='nearest')
B.capture(slot,source,restore,true);assert(#allocations==1 and #draws==2,'steady depth-only snapshot allocated a new canvas')
color,packed=B.capture(slot,source,restore)
assert(color==slot.underColor and packed==slot.underDepth and #allocations==2 and #draws==4)
assert(color.w==321 and color.h==181 and color.filter[1]=='linear','legacy color snapshot size/filter changed')
assert(draws[3][2]==color and draws[4][2]==packed and canvas==restore)
depthFailure=true;color,packed=B.capture(slot,source,restore,true)
assert(not color and not packed and canvas==restore,'failed depth snapshot leaked render target or claimed success')
assert(not B.inverse({0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}),'singular view matrix accepted')
print('PASS depth-only capture avoids color copy/allocation, cached reuse, legacy color fallback and error restoration')
