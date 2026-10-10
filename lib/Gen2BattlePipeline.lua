-- A staged arena is independent of the user's overworld WORLD rung. Select
-- its existing pipeline only inside Gen 2's world draw; never rewrite settings
-- or bypass the engine's guarded pipeline/presentation calls.
local M = {}
function M.install(World, Pipelines, active)
  if not (World and type(World.draw)=='function' and Pipelines
      and type(Pipelines.worldPipeline)=='function') then return false end
  if World.dramaticBattlePipeline then return true end
  local draw, select = World.draw, Pipelines.worldPipeline
  local depth = 0
  function Pipelines.worldPipeline(...)
    if depth > 0 and active() then return 'voxel' end
    return select(...)
  end
  function World:draw(...)
    depth = depth + 1
    local result = {pcall(draw, self, ...)}
    depth = depth - 1
    if not result[1] then error(result[2], 0) end
    return unpack(result, 2)
  end
  World.dramaticBattlePipeline = true
  return true
end
return M
