local M=dofile('lib/ModelInstances.lua')
local draws,offsets,uniform,attached=0,nil,0,nil
local mesh={attachAttribute=function(_,name,source,rate)assert(name=='VertexInstanceOffset' and rate=='perinstance');attached=source end,
 detachAttribute=function()attached=nil end}
local shader={send=function(_,name,value)assert(name=='sceneryInstances');uniform=value end}
love={graphics={getSupported=function()return {instancing=true}end,
 newMesh=function(format,positions)assert(format[1][1]=='VertexInstanceOffset');offsets={positions=positions,release=function(self)self.released=true end};return offsets end,
 drawInstanced=function(m,count)assert(m==mesh and count==2 and attached==offsets and uniform==1);draws=draws+1 end,
 draw=function(m)assert(m==mesh and uniform==0);draws=draws+1 end}}
local batch=assert(M.new(mesh,{{4,0,8},{-16,2,32}}))
assert(not attached and M.mesh(batch)==mesh)
M.draw(batch,shader);assert(draws==1 and not attached and uniform==0)
M.draw(mesh,shader);assert(draws==2)
love.graphics.drawInstanced=function()error('driver failed')end
assert(not pcall(M.draw,batch,shader));assert(not attached and uniform==0,'instance state leaked')
batch:release();assert(offsets.released,'placement buffer leaked')
love.graphics.getSupported=function()return {instancing=false}end
assert(not M.new(mesh,{{0,0,0}}),'unsupported GPU must keep merged geometry')
print('PASS model reuse, offsets, shader cleanup, ownership and unsupported fallback')
