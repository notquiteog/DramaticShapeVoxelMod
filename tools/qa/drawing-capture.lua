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

  local function loadAt(mapId, cx, cy)
    if gen == 3 then
      local Map = require("src.core.game3.map")
      if game.data and game.data.maps and game.data.maps[mapId] then
        pcall(function() Map.ensureMidLayout(game, mapId, game.data.maps[mapId]) end)
      end
      return pcall(function()
        assert(Map.load(nil, game, mapId, { x = cx, y = cy, facing = "up" }))
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
        game.stack:push(require("src.world.OverworldController"), mapId, cx, cy, "up")
      end)
      return ok
    end
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
      if currentMap ~= r.map then
        if not loadAt(r.map, r.x, r.y) then failed = failed + 1 end
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
