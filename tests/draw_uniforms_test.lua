local U=dofile('lib/DrawUniforms.lua').new();local count=0
local sh={send=function()count=count+1 end}
U.send(sh,'facing',0);U.send(sh,'facing',0);assert(count==1)
U.send(sh,'facing',1);assert(count==2)
U.reset();U.send(sh,'facing',1);assert(count==3,'new scene inherited old shader state')
local other={send=sh.send};U.send(other,'facing',1);assert(count==4)
U.send(sh,'facing',1);assert(count==5,'shader switch retained another shader cache')
local bad={send=function()count=count+1;error('unsupported')end}
U.send(bad,'x',0);U.send(bad,'x',0);assert(count==7,'failed send was cached')
print('PASS unchanged state reuse, new scene and shader invalidation, unsupported uniform fallback')
local m={1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}
U.reset();local before=count
U.matrix(sh,'model',m);U.matrix(sh,'model',m);assert(count==before+1)
local copy={};for i=1,16 do copy[i]=m[i]end
U.matrix(sh,'model',copy);assert(count==before+1,'equal matrices were uploaded twice')
m[4]=20;U.matrix(sh,'model',m);assert(count==before+2,'mutable animated transform stayed stale')
U.matrix(sh,'sunModel',m);assert(count==before+3,'uniform names shared matrix state')
U.reset();U.matrix(sh,'model',m);assert(count==before+4)
U.matrix(other,'model',m);assert(count==before+5)
U.matrix(bad,'model',m);U.matrix(bad,'model',m);assert(count==before+7)
print('PASS matrix value snapshots, in-place animation, scene/shader reset and failed-send retry')
