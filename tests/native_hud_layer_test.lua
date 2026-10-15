local count=0;local function check(v,m)count=count+1;assert(v,m)end
local depth,allocations,draws,fail,shaders=0,0,{},false,0
local state={canvas='native',shader='native',scissor=true,blend='native'};local stack={}
local effect={send=function(self,k,v)self[k]=v end,release=function()end}
local release
package.loaded['src.render.Assets']={register=function(t)release=t.release end}
love={graphics={newShader=function()shaders=shaders+1;return effect end,
 newCanvas=function(w,h)allocations=allocations+1;if fail then error('no canvas')end;return{w=w,h=h,setFilter=function()end,release=function()end}end,
 push=function()depth=depth+1;local c={};for k,v in pairs(state)do c[k]=v end;stack[depth]=c end,
 pop=function()state=stack[depth];depth=depth-1 end,
 setCanvas=function(v)state.canvas=v end,setShader=function(v)state.shader=v end,
 setScissor=function(v)state.scissor=v end,setBlendMode=function(v)state.blend=v end,
 origin=function()end,setDepthMode=function()end,clear=function()end,setColor=function()end,
 draw=function(...)draws[#draws+1]={args={...},shader=state.shader,canvas=state.canvas}end}}
local L=assert(loadfile('lib/NativeHudLayer.lua'))()
check(L.scale('og',{Ux=2,Uy=2})==1 and L.scale('scaled',{Ux=2,Uy=2})==.5,'OG and compact integer rung')
check(L.scale('scaled',{Ux=6.75,Uy=6.75})==5/6.75 and L.scale('scaled',{Ux=.5,Uy=.5})==1,'fractional output scale and small-window fallback')
local calls=0;local function native(x)
 calls=calls+1;check(state.canvas.w==240 and not state.scissor and not state.shader,'capture restores native logical drawing environment')
 state.shader='native-font';return x,'second'
end
local a,b=L.draw('qa',240,160,.5,240,72,nil,native,'result')
check(a=='result'and b=='second'and calls==1,'native call exactly once and return values preserved')
check(#draws==0,'compact layer waits until window composition')
L.paint('qa',{Ux=2,Uy=2,uox=0,uoy=0})
check(draws[1].args[2]==240 and draws[1].args[3]==72 and draws[1].args[5]==1,'player right/top anchor and integer output pixels preserved')
check(state.canvas=='native'and state.shader=='native'and state.scissor and depth==0,'all caller graphics state restored')
L.begin('qa');L.draw('qa',240,160,.5,0,14,nil,native);check(allocations==1,'capture canvas reused')
local pal={0,8+8*32+8*1024,31+31*32+27*1024,27+26*32+22*1024}
L.draw('qa',240,160,1,0,0,pal,native)
check(draws[#draws].shader==effect and shaders==1 and effect.ink[1]==66/255 and effect.paper[3]==222/255,'exact ROM palette keys sent to inversion shader')
local before=#draws;L.draw('qa',240,160,1,0,0,nil,function()calls=calls+1 end)
check(#draws==before,'native OG COLOR avoids capture')
local ok=pcall(L.draw,'qa',240,160,.5,0,0,nil,function()error('native error')end)
check(not ok and depth==0 and state.canvas=='native','native draw failure restores canvas/state')
local priorAllocations=allocations;release();fail=true;local fallback=0
L.draw('qa',240,160,.5,0,0,pal,function()fallback=fallback+1 end)
L.draw('qa',240,160,.5,0,0,pal,function()fallback=fallback+1 end)
check(fallback==2 and allocations==priorAllocations+1 and depth==0,'allocation failure retains native draw without repeated allocation')
print('PASS '..count..' native HUD layer contracts')
