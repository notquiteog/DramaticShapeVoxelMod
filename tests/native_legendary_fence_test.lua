local enabled=true;local V={require=function(k)
 if k=='CommunityVisuals'then return{customCourtyards=function()return enabled end}end
 return assert(loadfile('lib/'..k..'.lua'))()
end}
local M=assert(loadfile('lib/NativeLegendaryFence.lua'))(V)
local uv={{0,0},{1,0},{1,1},{0,1}}
for _,shape in ipairs{{kind='fence'},{kind='fence',axis=4},{kind='fence',axis=12,turn='north'},{kind='fence',axis=4,stop='south'}}do
 local n=0;local c={cx=2,cy=3,collision=7,shape=shape};local original=shape.stop
 assert(M.append(c,function(q,tex,shade)n=n+1;assert(tex and shade);for _,p in ipairs(q)do assert(p[1]>=32 and p[1]<=48 and p[3]>=48 and p[3]<=64 and p[2]>=0 and p[2]<=10.75)end end,uv,uv))
 assert(n>30 and shape.stop==original)
 c.collision=0;assert(not M.append(c,function()error('walkable intrusion')end,uv,uv))
end
enabled=false;assert(not M.append({collision=7,shape={kind='fence'}},function()error('OFF')end,uv,uv))
print('PASS shared Legendary native fence bays, turns, endpoints, closed bases, cell bounds, OFF and walkable guards')
