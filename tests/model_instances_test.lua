local M=dofile('lib/ModelInstances.lua')
local draws,uniform,attached,attaches,detaches=0,0,nil,0,0
local mesh={attachAttribute=function(_,name,source,rate)
 assert(name=='VertexInstanceOffset' and rate=='perinstance');attached=source;attaches=attaches+1
end,detachAttribute=function()attached=nil;detaches=detaches+1 end}
local shader={send=function(_,name,value)assert(name=='sceneryInstances');uniform=value end}
love={graphics={getSupported=function()return {instancing=true}end,
 newMesh=function(format,positions)
  assert(format[1][1]=='VertexInstanceOffset')
  return {positions=positions,release=function(self)assert(attached~=self,'released a bound buffer');self.released=true end}
 end,
 drawInstanced=function(m,count)assert(m==mesh and count==#attached.positions and not attached.released and uniform==1);draws=draws+1 end,
 draw=function(m)assert(m==mesh and not attached and uniform==0);draws=draws+1 end}}
local batch=assert(M.new(mesh,{{4,0,8},{-16,2,32}}))
assert(not attached and M.mesh(batch)==mesh)
local a,d=attaches,detaches
for _=1,2000 do M.draw(batch,shader)end
assert(draws==2000 and attached==batch.offsets and uniform==0)
assert(attaches-a==1 and detaches-d==0,'unchanged sun/main batch rebuilt bindings')
M.draw(mesh,shader);assert(draws==2001 and not attached,'ordinary draw retained offsets')
M.draw(batch,shader)
local other=assert(M.new(mesh,{{0,0,0}}))
assert(not attached,'validation left cache pointing at stale binding')
M.draw(batch,shader);assert(attached==batch.offsets)
M.draw(other,shader);assert(attached==other.offsets,'shared prototype did not change placement')
batch:release();assert(batch.offsets.released and attached==other.offsets,'old batch detached newer binding')
other:release();assert(other.offsets.released and not attached,'placement buffer leaked')
local failed=assert(M.new(mesh,{{0,0,0}}))
love.graphics.drawInstanced=function()error('driver failed')end
assert(not pcall(M.draw,failed,shader));assert(not attached and uniform==0,'instance state leaked')
failed:release()
mesh.attachAttribute=function()error('unsupported attribute')end
assert(not M.new(mesh,{{0,0,0}}),'failed attribute setup must keep merged geometry')
love.graphics.getSupported=function()return {instancing=false}end
assert(not M.new(mesh,{{0,0,0}}),'unsupported GPU must keep merged geometry')
print('PASS retained bindings, shared prototype swaps, ordinary draw, release, errors and fallback')
