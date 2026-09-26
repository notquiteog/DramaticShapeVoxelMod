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
