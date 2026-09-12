-- Gold's neighbour rows, given the field the mesher reads.
--
-- A connected map's row is the one world shape the two engines genuinely
-- disagree about, and the disagreement is silent in the worst way: it only
-- bites OUTDOORS. An interior has no connections, so a Gen 2 boot renders a
-- bedroom as a perfect diorama and then falls open to the flat 2D map the
-- moment the player steps into a town.
--
--   Gen 1   { map = <Map>, ox, oy }          src/world/OverworldController
--   Gold    { id, ox, oy, image }            src/world/gen2/World:rebuildNeighbors
--
-- Gold has no Map instance to put there because it does not need one: it draws
-- a neighbour as one pre-baked whole-map image (`imageFor`). The mesher cannot
-- use an image -- it needs blocks, a tileset and the cell predicates -- so
-- every `nb.map.id` in this mod read nil and took the whole world pass down.
--
-- Gen2Compat records the field as WARNED for exactly this reason, and its note
-- is the shape of the whole problem: "Gold's entries are { id, ox, oy, image }
-- where Gen 1's are { map = mapDef, ox, oy }, so the field answers nil rather
-- than a list whose nb.map is nil on every row."
--
-- The fix is additive rather than a translation layer, and deliberately so.
-- Gold already builds and caches a Map per connected id --
-- `World:connectionMap(mapId)`, "a neighbour map, built once and kept for its
-- collision alone" (src/world/gen2/World.lua:10210) -- so the row only has to
-- be told about it. Writing `map` onto the engine's own row means every
-- existing `nb.map` reader in this mod is correct with no edit, and nothing in
-- the engine is disturbed: Gold reads `id`, `ox`, `oy` and `image`, and has no
-- opinion about a fifth key.
--
-- Called per frame from the two entries that walk the list. The nil test makes
-- it free after the first pass and correct across a rebuild, which is what
-- matters -- `rebuildNeighbors` replaces the rows outright on a zoom change or
-- a map load, so a one-shot pass at map.entered would go stale.

local V = ...
local Generation = V.require("Generation")

local Gen2Neighbors = {}

-- Rows we could not give a map to, by id, so the reason is reported once
-- rather than every frame.
local refused = {}

-- How many rows the last call could not resolve. Read by tests; a non-zero
-- value here is the difference between "the diorama is complete" and "a
-- connected map is missing from it".
Gen2Neighbors.unresolved = 0

function Gen2Neighbors.ensure(state)
  Gen2Neighbors.unresolved = 0
  if not Generation.isGen2() then return true end
  if type(state) ~= "table" then return false end
  local rows = state.neighbors
  if type(rows) ~= "table" then return true end
  local builder = state.connectionMap
  if type(builder) ~= "function" then return false end

  local ok = true
  for _, nb in ipairs(rows) do
    if nb.map == nil and nb.id ~= nil then
      local built, map = pcall(builder, state, nb.id)
      if built and type(map) == "table" then
        nb.map = map
      else
        ok = false
        Gen2Neighbors.unresolved = Gen2Neighbors.unresolved + 1
        if not refused[nb.id] then
          refused[nb.id] = true
          local log = V.mod and V.mod.log
          if log and log.error then
            pcall(log.error, log,
              "no neighbour map for %s; that connected map stays flat",
              tostring(nb.id))
          end
        end
      end
    end
  end
  return ok
end

-- Only the rows that carry a map, for a caller that would rather skip a
-- neighbour than read nil off it. `state.neighbors` itself stays the engine's.
function Gen2Neighbors.resolved(state)
  Gen2Neighbors.ensure(state)
  local rows = (type(state) == "table" and state.neighbors) or {}
  local out = {}
  for _, nb in ipairs(rows) do
    if type(nb.map) == "table" then out[#out + 1] = nb end
  end
  return out
end

return Gen2Neighbors
