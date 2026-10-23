local C=dofile('lib/FrustumCull.lua')
local M=assert(loadfile('lib/ModelInstances.lua'))({require=function(n)assert(n=='FrustumCull');return C end})
local Mat=dofile('lib/Mat4.lua')
local bound,uniform,allocations,uploads,draws=nil,0,0,0,{}
local failNew,failUpload,failDraw,failAttach=false,false,false,false
local resources={}
local function copy(rows)local out={};for i,p in ipairs(rows)do out[i]={p[1],p[2],p[3]}end;return out end
local mesh={attachAttribute=function(_,_,buffer)
 bound=buffer
 if failAttach and buffer.usage=='dynamic'then error('attribute failed after binding')end
end,detachAttribute=function()bound=nil end}
local shader={send=function(_,_,v)uniform=v end}
love={graphics={getSupported=function()return {instancing=true}end,
 newMesh=function(_,positions,_,usage)
  if usage=='dynamic'and failNew then error('mobile allocation failed')end
  allocations=allocations+1
  local buffer={capacity=type(positions)=='number'and positions or #positions,rows=type(positions)=='table'and copy(positions)or{},usage=usage}
  function buffer:setVertices(rows,start)
   uploads=uploads+1;assert(start==1 and #rows<=self.capacity)
   if failUpload then self.rows={};error('mobile upload failed')end
   self.rows=copy(rows)
  end
  function buffer:release()assert(bound~=self);assert(not self.released);self.released=true end
  resources[#resources+1]=buffer;return buffer
 end,
 drawInstanced=function(m,count)
  assert(m==mesh and uniform==1 and bound and not bound.released)
  if failDraw and bound.usage=='dynamic'then error('dynamic submission failed')end
  draws[#draws+1]={rows=copy(bound.rows),count=count}
 end}}
local positions={{0,0,0},{10,0,0},{-.75,0,0},{-10,0,0}}
local b=assert(M.new(mesh,positions));positions[1][1]=999 -- ownership snapshot
local bounds={-.1,-.1,-.1,.1,.1,.1}
local p=C.prepare(Mat.identity())
local view=M.visible(b,p,bounds)
assert(view~=b and view.count==2 and view.offsets.capacity==4)
assert(view.offsets.rows[1][1]==0 and view.offsets.rows[2][1]==-.75)
local a,u=allocations,uploads
for _=1,100 do assert(M.visible(b,C.prepare(Mat.identity()),bounds)==view)end
assert(allocations==a and uploads==u,'unchanged selection uploaded again')
M.draw(view,shader);assert(draws[#draws].count==2)
M.draw(b,shader);assert(draws[#draws].count==4 and draws[#draws].rows[2][1]==10,'shadow lost full placements')
local shifted=Mat.identity();shifted[4]=-10
assert(M.visible(b,C.prepare(shifted),bounds)==view and view.count==1)
assert(view.offsets.rows[1][1]==10 and uploads==u+1,'camera failed to change subset')
shifted[4]=10
M.visible(b,C.prepare(shifted),bounds)
assert(view.count==1 and view.offsets.rows[1][1]==-10,'same-count selection kept stale positions')
local wide=Mat.scale(.01,.01,.01)
assert(M.visible(b,C.prepare(wide),bounds)==b,'all-visible created duplicate batch')
M.visible(b,p,bounds);assert(view.count==2 and view.offsets.rows[1][1]==0,'all-visible poisoned cached selection')
shifted[4]=100
local empty=M.visible(b,C.prepare(shifted),bounds);assert(empty==view and empty.count==0)
local nd=#draws;M.draw(empty,shader);assert(#draws==nd)
M.visible(b,p,bounds);assert(view.count==2)
-- A second base sharing this prototype owns independent placement buffers.
local other=assert(M.new(mesh,{{0,0,0},{20,0,0}}))
local otherView=M.visible(other,p,bounds)
M.draw(otherView,shader);M.draw(b,shader);M.draw(view,shader)
assert(draws[#draws].rows[2][1]==-.75)
other:release();assert(bound==view.offsets,'releasing another scene detached this one')
b:release();assert(not bound)

for _,failure in ipairs({'allocation','upload','attribute','draw'})do
 local base=assert(M.new(mesh,{{0,0,0},{10,0,0}}))
 failNew=failure=='allocation';failUpload=failure=='upload';failDraw=failure=='draw'
 failAttach=failure=='attribute'
 local result=M.visible(base,p,bounds)
 if failure=='draw'then M.draw(result,shader);assert(draws[#draws].count==2)
 else assert(result==base,'optional buffer failure did not retain full draw')end
 assert(M.visible(base,p,bounds)==base,'failed optional path retried per frame')
 failNew,failUpload,failDraw,failAttach=false,false,false,false
 M.draw(base,shader);assert(draws[#draws].count==2 and uniform==0)
 base:release()
end
local base=assert(M.new(mesh,{{0,0,0},{10,0,0}}))
local liveView=M.visible(base,p,bounds);M.draw(liveView,shader)
shifted[4]=-10;failUpload=true
assert(M.visible(base,C.prepare(shifted),bounds)==base,'failed update kept stale visible subset')
failUpload=false;M.draw(base,shader);assert(draws[#draws].count==2)
base:release()
for _,r in ipairs(resources)do assert(r.released,'offset buffer leaked')end
assert(M.visible(mesh,p,bounds)==mesh,'merged mobile fallback changed')
print('PASS visible offsets, stable-selection reuse, changing cameras, full shadow batch, scene isolation, allocation/upload/draw failure fallback and cleanup')
