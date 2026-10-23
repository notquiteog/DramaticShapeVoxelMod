-- Read-only actor preparation scoped to ONE render, not one engine update.
-- Call begin() before every scene draw, including manual/repeated draws.
-- Provider draw hooks, current-pass VP/reflections and visibility stay outside.
local M={}
M.__index=M
function M.new()
 return setmetatable({entries=setmetatable({},{__mode='k'}),epoch=0},M)
end
function M:begin()self.epoch=self.epoch+1 end
function M:clear()self.entries=setmetatable({},{__mode='k'});self.epoch=0 end
 -- key: stable native actor identity (use a table, not a synthesized string).
 -- context: explicit primitive/identity arguments consumed by prepare. Flatten
 -- mutable options into these arguments; a table identity cannot detect edits.
 -- prepare(record, ...) populates ALL owned fields and returns true/false.
 -- Scratch records are private to this cache and must not escape the render.
function M:get(key,prepare,...)
  local epoch,entries=self.epoch,self.entries
  assert(epoch>0,'actor preparation requires begin for this render')
  assert(key~=nil and type(prepare)=='function','actor identity/producer required')
  local entry=entries[key]
  if not entry then entry={args={},record={}};entries[key]=entry end
  local n=select('#',...)
  local same=entry.epoch==epoch and entry.prepare==prepare and entry.n==n
  if same then
   for i=1,n do if entry.args[i]~=select(i,...)then same=false;break end end
  end
  if same then return entry.ready and entry.record or nil end
  -- Invalidate before calling: a failed producer must never expose a stale
  -- cached result or turn a transient failure into a successful cache hit.
  entry.epoch=nil
  local ready=prepare(entry.record,...)
  for i=1,n do entry.args[i]=select(i,...)end
  for i=n+1,entry.n or 0 do entry.args[i]=nil end
  entry.n,entry.prepare,entry.ready,entry.epoch=n,prepare,not not ready,epoch
  return entry.ready and entry.record or nil
end
return M
