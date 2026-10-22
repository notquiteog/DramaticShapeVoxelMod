-- One retained scene, one cooperative window and one bounded destination. Never expose partially
-- uploaded geometry, keep abandoned GPU resources out of the live scene, and
-- rebuild immediately when map/gameplay dependencies change.
local V=...
local Budget=V.require('BuildBudget')
local clock=(love and love.timer and love.timer.getTime) or os.clock
local M={}
function M.new(release)
 local self={stats={started=0,completed=0,cancelled=0,hits=0,slices=0,maxSlice=0,maxStreamSlice=0,prefetched=0,promoted=0,prefetchFailed=0,retainedHits=0,forcedCompletions=0,maxPromotionSlice=0}}
 function self:cancel()
  if self.pending then
   Budget.cancel(self.pending.co);release(self.pending.value);self.pending=nil
   self.stats.cancelled=self.stats.cancelled+1
  end
 end
 function self:discardPrefetch(keepRetained)
  if keepRetained and self.warm and self.warm.retained then return end
  if self.warm then Budget.cancel(self.warm.co);release(self.warm.value);self.warm=nil end
 end
 function self:clear()
  self:discardPrefetch()
  self:cancel()
  if self.active then release(self.active);self.active=nil end
  self.key,self.context=nil,nil
 end
 -- Preload exactly one destination with the same cooperative budget. It
 -- never replaces the live scene until the native world actually enters it.
 function self:prefetch(key,context,build,seconds,acceptWarm)
  if not key or not context then self:discardPrefetch();return end
  local p=self.warm
  if p and p.ready and p.context==context
   and (p.key==key or acceptWarm and acceptWarm(p.value))then
   if p.retained then self.stats.retainedHits=self.stats.retainedHits+1 end;return
  end
  -- Lateral movement can change a destination's window key
  -- before it completes. Finish that immutable snapshot, just like update(),
  -- instead of repeatedly throwing away uploads. Context/provider changes still cancel.
  if p and(p.context~=context or p.key~=key and
   (p.ready or p.failed or not acceptWarm or not acceptWarm(p.value)))then self:discardPrefetch();p=nil end
  if not p then
   p={key=key,context=context,value={}}
   p.co=coroutine.create(function()return build(p.value)end);self.warm=p
  end
  if p.ready or p.failed then return end
  Budget.begin(p.co,seconds,4)
  local start=clock();local ok,result=coroutine.resume(p.co);Budget.finish()
  self.stats.maxStreamSlice=math.max(self.stats.maxStreamSlice,clock()-start)
  if not ok then
   Budget.cancel(p.co);release(p.value);p.value={};p.failed=true
   self.stats.prefetchFailed=self.stats.prefetchFailed+1;return
  end
  if coroutine.status(p.co)=='dead'then
   result=result or p.value
   if result~=p.value then release(p.value);p.value=result end
   -- Never relabel geometry built while a script edited its world.
   if result.terrainContext and result.terrainContext~=context then self:discardPrefetch();return end
   p.ready=true;p.key=result.terrainKey or key
   self.stats.prefetched=self.stats.prefetched+1
  end
 end
 function self:update(key,context,build,seconds,acceptWarm)
  local warm=self.warm
  if warm and warm.context==context and not warm.failed and self.context~=context
   and (warm.key==key or acceptWarm and acceptWarm(warm.value)) then
   self:cancel();self.warm=nil
   -- A late crossing can finish an already partly prepared candidate rather
   -- than discarding all its work and starting the same build again.
   if not warm.ready then
    Budget.finish();local started=clock();local ok,result=coroutine.resume(warm.co)
    self.stats.forcedCompletions=self.stats.forcedCompletions+1
    local elapsed=clock()-started
    self.stats.maxPromotionSlice=math.max(self.stats.maxPromotionSlice,elapsed)
    self.stats.maxSlice=math.max(self.stats.maxSlice,elapsed)
    if not ok then self.stats.prefetchFailed=self.stats.prefetchFailed+1 end
    if ok and coroutine.status(warm.co)=='dead' then warm.value=result or warm.value;warm.ready=true end
   end
   if warm.ready and (not warm.value.terrainContext or warm.value.terrainContext==context)then
    -- Reuse the vacated destination slot for the scene just left. This keeps
    -- the same resource bound and avoids rebuilding the reverse connection.
    -- Context/key checks still reject changed tiles, providers and far windows.
    if self.active and self.key and self.context then
     self.warm={key=self.key,context=self.context,value=self.active,ready=true,retained=true}
    elseif self.active then release(self.active)end
    self.active=warm.value;self.key=warm.value.terrainKey or warm.key;self.context=context
    self.stats.promoted=self.stats.promoted+1;self.stats.completed=self.stats.completed+1
   else Budget.cancel(warm.co);release(warm.value)end
  elseif warm and self.context~=context then
   self:discardPrefetch()
  end
  if key and self.active and key==self.key and context==self.context then
   self:cancel();self.stats.hits=self.stats.hits+1;return self.active
  end
  -- Running can cross another window boundary before a candidate finishes.
  -- Restarting on each boundary starves the renderer forever. Complete the
  -- in-flight snapshot of this same world, then pursue the newest window.
  -- Returning to the active window above still cancels needless work; genuine
  -- map/collision context changes must never publish stale geometry. Provider
  -- readiness stays in the scene key and can be updated cooperatively.
  if self.pending and (self.pending.context~=context or not key)then self:cancel()end
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
   self.key=result.terrainKey or p.key
   self.context=result.terrainContext or p.context
  end
  return self.active
 end
 return self
end
return M
