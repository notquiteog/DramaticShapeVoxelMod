-- Render one isolated capture per distinct tile drawing.
--
--   env CENSUS_TSV   ledger from tools/qa/drawing-census.lua (required)
--   env SHOT_DIR     output root (required)
--   env DRAW_LIMIT   stop after N drawings (smoke test)
--   env DRAW_CAMERA  "1p" (default) or "3p"
--   env DRAW_SETTLE  settle frames per capture (default 26)
--
-- The census gives each drawing a representative map and cell, so this does not
-- have to search: it jumps to the cell, lets the mesher settle, and shoots.
-- Each drawing is its own file, which is what makes 36k of them reviewable.
--
-- Grouped by representative map so the ordering is stable and a resume picks up
-- where it stopped rather than re-rendering from scratch.
return function(game)
  local U = dofile("tests/drivers/util.lua")
  local dir = assert(os.getenv("SHOT_DIR"), "SHOT_DIR")
  local tsv = assert(os.getenv("CENSUS_TSV"), "CENSUS_TSV")
  local limit = tonumber(os.getenv("DRAW_LIMIT")) or math.huge
  local camera = os.getenv("DRAW_CAMERA") or "1p"
  local settle = tonumber(os.getenv("DRAW_SETTLE")) or 26
  local V = game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
  local okGV, GameVersion = pcall(require, "src.core.GameVersion")
  local version = okGV and GameVersion.get() or "?"
  local okGen, Generation = pcall(function() return V.require("Generation") end)
  local gen = Generation.number()

  -- Gen 3 must be in the overworld before map data resolves.
  if game.phase == "boot" then
    for _ = 1, 6000 do
      if game.phase ~= "boot" then break end
      local b = game.boot
      pcall(function() U.tap(game, (b and b.introMovie) and "start" or "a") end)
      U.wait(1)
    end
  end

  -- Read the ledger.
  local rows = {}
  for line in io.lines(tsv) do
    if not line:match("^#") and not line:match("^drawing\t") then
      local d, mc, cc, rmap, rcx, rcy = line:match("^(.-)\t(%d+)\t(%d+)\t([^\t]+)\t(%-?%d+)\t(%-?%d+)")
      if d and rmap then rows[#rows + 1] = { d = d, map = rmap, x = tonumber(rcx), y = tonumber(rcy) } end
    end
  end
  table.sort(rows, function(a, b)
    if a.map ~= b.map then return a.map < b.map end
    if a.y ~= b.y then return a.y < b.y end
    return a.x < b.x
  end)
  print(("[dc] %s: %d drawings to render, camera=%s"):format(version, #rows, camera))

  local function safe(s) return (tostring(s):gsub("[^%w%._-]", "_")) end
  local function shotsFor(mapId) return dir .. "/" .. safe(mapId) end

  local P = nil
  if gen == 1 or gen == 2 then P = require("src.render.Pipelines") end

  local function loadAt(mapId, cx, cy, facing)
    if gen == 3 then
      local Map = require("src.core.game3.map")
      if game.data and game.data.maps and game.data.maps[mapId] then
        pcall(function() Map.ensureMidLayout(game, mapId, game.data.maps[mapId]) end)
      end
      return pcall(function()
        assert(Map.load(nil, game, mapId, { x = cx, y = cy, facing = facing or "up" }))
      end)
    elseif gen == 2 then
      local w = game.world
      w.noWildEncounters = true
      w.trySceneScript = function() return false end
      w.rollEncounter = function() return nil end
      local ok = pcall(function() assert(w:setMap(mapId, cx, cy, "up")) end)
      w.vm, w.textbox, w.mapSign = nil, nil, nil
      return ok
    else
      local ok = pcall(function()
        if game.stack then game.stack:clear() end
        game.stack:push(require("src.world.OverworldController"), mapId, cx, cy, facing or "up")
      end)
      return ok
    end
  end

  -- Stand NEXT TO the drawing, not on it.
  --
  -- The census records the cell the drawing occupies, and for anything that is
  -- not floor -- every wall, tree, fence, ledge, sign -- that cell is by
  -- definition not walkable. Standing there puts the first-person camera
  -- inside the geometry and the frame comes back empty apart from the HUD.
  -- That produced 509 false "renders nothing" readings across Crystal's 1864
  -- drawings; OLIVINE_LIGHTHOUSE_2F is the clearest case, and the per-map sweep
  -- of that same map shows a correctly rendered room.
  --
  -- So: find the nearest walkable cell and aim the camera at the drawing.
  local function viewpoint(mapId, tx, ty)
    local map = nil
    local walkable
    if gen == 3 then
      local Map = require("src.core.game3.map")
      local def = game.data and game.data.maps and game.data.maps[mapId]
      if def then pcall(function() Map.ensureMidLayout(game, mapId, def) end) end
      local Perm = require("src.core.game3.permissions")
      local L = def and def.midLayout
      walkable = function(x, y)
        if not L then return false end
        local ok, c = pcall(function() return L:collAt(x, y) end)
        return ok and Perm.isWalkable(c)
      end
    elseif gen == 2 then
      local G2 = require("src.world.gen2.Map")
      local def = game.world and game.world.maps and game.world.maps[mapId]
      local ts = def and game.world.tilesets[def.tileset]
      if def and ts then pcall(function() map = G2.new(def, ts) end) end
      local Perm = require("src.world.gen2.Permissions")
      walkable = function(x, y)
        if not map then return false end
        local ok, c = pcall(function() return map:cellCollision(x, y) end)
        return ok and Perm.of(tonumber(c) or -1) == Perm.LAND
      end
    else
      local G1 = require("src.world.Map")
      local def = game.data and game.data.maps and game.data.maps[mapId]
      local ts = def and (game.data.tilesets or {})[def.tileset]
      if def then pcall(function() map = { def = def, tileset = ts } end) end
      walkable = function(x, y)
        if not def then return false end
        local ok, v = pcall(function() return G1.defIsWalkableCell(def, ts, x, y) end)
        return ok and v
      end
    end

    -- Spiral outward, preferring cells adjacent to the drawing.
    local best
    for radius = 0, 5 do
      for dy = -radius, radius do
        for dx = -radius, radius do
          if math.max(math.abs(dx), math.abs(dy)) == radius then
            local x, y = tx + dx, ty + dy
            if walkable(x, y) then
              local d = dx * dx + dy * dy
              -- prefer being BELOW the drawing: looking up puts the wall in frame
              if dx == 0 and dy > 0 then return x, y, "down" end
              if not best or d < best.d then best = { x = x, y = y, d = d, dx = dx, dy = dy } end
            end
          end
        end
      end
      if best then
        return best.x, best.y, (best.dy > 0 and "up" or (best.dx < 0 and "right" or "left"))
      end
    end
    return tx, ty, "up"
  end

  local done, skipped, failed = 0, 0, 0
  local currentMap = nil
  for i, r in ipairs(rows) do
    if done + skipped >= limit then break end
    local name = r.d:match("([^:]+)::(.+)$") or r.d
    local file = shotsFor(r.map) .. "/" .. safe(r.d) .. "-" .. camera .. ".png"
    -- Resume: the census ledger is the checklist, so presence is the record.
    local f = io.open(file, "rb")
    if f then f:close(); skipped = skipped + 1
    else
      local vx, vy, facing = viewpoint(r.map, r.x, r.y)
      if currentMap ~= r.map then
        if not loadAt(r.map, vx, vy, facing) then failed = failed + 1 end
        currentMap = r.map
        for _ = 1, 8 do U.wait(1) end
      end
      if gen == 1 or gen == 2 then
        pcall(function() P.setLevel("voxel", camera == "3p" and 7 or 6) end)
      end
      for _ = 1, settle do U.wait(1) end
      os.execute(("mkdir -p %q"):format(shotsFor(r.map)))
      if U.shot(game, file) then done = done + 1 else failed = failed + 1 end
    end
    if i % 250 == 0 then
      print(("[dc] %d/%d rendered, %d skipped, %d failed"):format(i, #rows, skipped, failed))
    end
  end
  print(("[dc] DONE %s: rendered=%d skipped=%d failed=%d -> %s")
    :format(version, done, skipped, failed, dir))
  return
end
