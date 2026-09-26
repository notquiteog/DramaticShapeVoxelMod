-- One retained scene and one cooperative candidate. Never expose partially
-- uploaded geometry, keep abandoned GPU resources out of the live scene, and
-- rebuild immediately when map/provider/gameplay dependencies change.
local V=...
local Budget=V.require('BuildBudget')
local clock=(love and love.timer and love.timer.getTime) or os.clock
local M={}
function M.new(release)
 local self={stats={started=0,completed=0,cancelled=0,hits=0,slices=0,maxSlice=0,maxStreamSlice=0}}
 function self:cancel()
  if self.pending then
   release(self.pending.value);self.pending=nil
   self.stats.cancelled=self.stats.cancelled+1
  end
 end
 function self:clear()
  self:cancel()
  if self.active then release(self.active);self.active=nil end
  self.key,self.context=nil,nil
 end
 function self:update(key,context,build,seconds)
  if key and self.active and key==self.key and context==self.context then
   self:cancel();self.stats.hits=self.stats.hits+1;return self.active
  end
  if self.pending and (self.pending.key~=key or self.pending.context~=context)then self:cancel()end
  local immediate=not self.active or not context or context~=self.context or not key
  if not self.pending then
   local p={key=key,context=context,value={}}
   p.co=coroutine.create(function()return build(p.value,self.active)end)
   self.pending=p;self.stats.started=self.stats.started+1
  end
  local p=self.pending
  local start=clock()
  if not immediate then Budget.begin(p.co,seconds,4)end
  local ok,result=coroutine.resume(p.co)
  Budget.finish()
  self.stats.slices=self.stats.slices+1
  self.stats.maxSlice=math.max(self.stats.maxSlice,clock()-start)
  if not immediate then self.stats.maxStreamSlice=math.max(self.stats.maxStreamSlice,clock()-start)end
  if not ok then self:cancel();error(result,0)end
  if coroutine.status(p.co)=='dead' then
   self.pending=nil
   result=result or p.value
   if result~=p.value then release(p.value)end
   if self.active~=result then
    if self.active then release(self.active)end
    self.active=result;self.stats.completed=self.stats.completed+1
   end
   -- A cold build may load a previously absent tileset. Its final key owns
   -- that new provider identity; the next request rechecks the context.
   self.key=result.terrainKey or key;self.context=context
  end
  return self.active
 end
 return self
end
return M
