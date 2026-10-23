local V=...
-- Bounded desktop session diagnostics; failures never affect rendering.
local Trace = {}
local sequence, counts, recent = 0, {}, {}
local MAX_RECENT = 64

local function record(event, map, detail)
  sequence = sequence + 1
  event = tostring(event or "unknown")
  counts[event] = (counts[event] or 0) + 1
  recent[#recent + 1] = {
    sequence = sequence,
    event = event,
    map = tostring(map or "*"),
    detail = tostring(detail or ""):sub(1, 512),
    at = love and love.timer and love.timer.getTime and love.timer.getTime() or 0,
  }
  if #recent > MAX_RECENT then table.remove(recent, 1) end
end

function Trace.enabled()
  if not (love and love.system and love.system.getOS) then return false end
  local ok, name = pcall(love.system.getOS)
  return ok and (name == "Windows" or name == "Linux" or name == "OS X")
end
function Trace.log(event, map, detail)
  -- Structured counters are platform-neutral and intentionally tiny. They let
  -- external diagnostics consume cache behavior through mod.exports instead of
  -- parsing this desktop-only text file or reaching into VoxelMeshDisk locals.
  pcall(record, event, map, detail)
  if not Trace.enabled() then return end
  pcall(function()
    local now=love.timer and love.timer.getTime and love.timer.getTime()or 0
    local line=string.format('[BAV cache %.3f] %s map=%s %s',now,tostring(event),tostring(map or'*'),tostring(detail or''))
    print(line)
    local cache=V and V.mod and V.mod.cache
    if cache and(sequence==1 or sequence%64==0)then
      local lines={'Battle Art cache trace: latest64 events'}
      for _,row in ipairs(recent)do lines[#lines+1]=string.format('%.3f %s %s %s',row.at,row.event,row.map,row.detail)end
      cache:write('diagnostics/cache-trace.log',table.concat(lines,'\n'))
    end
  end)
end

function Trace.snapshot()
  local copiedCounts = {}
  for event, count in pairs(counts) do copiedCounts[event] = count end
  local copiedRecent = {}
  for i, row in ipairs(recent) do
    copiedRecent[i] = {
      sequence = row.sequence, event = row.event, map = row.map,
      detail = row.detail, at = row.at,
    }
  end
  return { sequence = sequence, capacity = MAX_RECENT,
           counts = copiedCounts, recent = copiedRecent }
end

return Trace
