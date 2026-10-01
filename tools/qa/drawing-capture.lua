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

  local aim = nil

  -- Gen 3 must be in the overworld before map data resolves.
  if game.phase == "boot" then
    for _ = 1, 6000 do
      if game.phase ~= "boot" then break end
      local b = game.boot
      pcall(function() U.tap(game, (b and b.introMovie) and "start" or "a") end)
      U.wait(1)
    end
  end

  -- Only now is it safe to zero input every frame. Installing this wrapper
  -- before the boot drive wiped each U.tap on the same frame, so Gen 3 never
  -- left the title screen and every capture was the title art.
  do
    local realUpdate = game.update
    game.update = function(self, dt)
      self.input:reset()
      if aim then aim() end
      return require("src.mods.Runtime").call("core.update", realUpdate, self, dt)
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
  local F = nil
  if gen == 1 or gen == 2 then
    local okF, FP = pcall(function() return V.require("FirstPerson") end)
    F = okF and FP or nil
  end
  local C = nil
  if gen == 3 then
    local okC, G3 = pcall(function() return V.require("Gen3Integration") end)
    C = okC and G3 or nil
  end
  local Zoom = nil
  do
    local okZ, Z = pcall(require, "src.render.Zoom")
    Zoom = okZ and Z or nil
  end

  -- AIM THE CAMERA AT THE SUBJECT.
  --
  -- The third variant of the same harness bug. This driver never set yaw or
  -- pitch, so the default heading could face a wall at point-blank range and
  -- fill the whole frame with one surface -- which scored as a flat drawing.
  -- WHIRL_ISLAND_NW/TILESET_DARK_CAVE__9 came back as a uniform brown field
  -- while the per-map sweep of that map renders with uniq=837, ink=0.57.
  -- The sweep never had this problem because it pins yaw/pitch per view AND
  -- re-applies it every frame; the mod's rigs rewrite them from held input, so
  -- a one-shot assignment drifts immediately.
  local function aimAt(vx, vy, tx, ty)
    -- Yaw convention from VoxelScene's YAW table: down(+z)=0, right(+x)=pi/2,
    -- up(-z)=pi, left(-x)=-pi/2 -- which is exactly atan2(dx, dz).
    local dx, dz = tx - vx, ty - vy
    if dx == 0 and dz == 0 then dx, dz = 0, -1 end
    local yaw = math.atan(dx, dz)
    -- A floor has to be looked DOWN at. Aiming horizontally at one puts the
    -- camera's eye level across it, the floor falls to the bottom edge and the
    -- frame reads as a flat card -- which is how TILESET_TRADITIONAL_HOUSE
    -- blocks scored flat when the real defect was only that block 4 is the
    -- reviewed tatami floor and the rest fall through to native art.
    -- Positive pitch is downward in this rig (sweep.lua uses .22 for 3p).
    local pitch = subjectFloor and 0.55 or 0.06
    if gen == 3 then
      if C and C.setLevel then pcall(function() C.setLevel(camera == "3p" and 7 or 6, game) end) end
      if C then aim = function() C.yaw, C.pitch = yaw, pitch end end
    else
      if P then pcall(function() P.setLevel("voxel", camera == "3p" and 7 or 6) end) end
      if F then aim = function() F.yaw, F.pitch = yaw, pitch end end
    end
    if Zoom then pcall(function() Zoom.offset = 1 end) end
  end

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
    -- "openness" matters more than strict walkability. A Burned Tower B1F floor
    -- is not Perm.LAND, so a LAND-only test found no acceptable cell anywhere,
    -- fell back to standing on the drawing, and buried the camera in geometry --
    -- 79 readings that looked like defects and were all harness error, since
    -- the per-map sweep of Burned Tower B1F renders with uniq=1050, ink=0.66.
    -- Accept anything that is not a wall, preferring LAND, then WATER.
    if gen == 3 then
      local Map = require("src.core.game3.map")
      -- There is no src.core.game3.permissions module; the walkability test is
      -- Collision.isWalkable(cx, cy) in src/core/game3/collision.lua:858, which
      -- is bound to the loaded map. Requiring the non-existent name threw on
      -- every Gen 3 drawing and produced zero captures for all three games.
      local Collision = require("src.core.game3.collision")
      local def = game.data and game.data.maps and game.data.maps[mapId]
      if def then pcall(function() Map.ensureMidLayout(game, mapId, def) end) end
      local L = def and def.midLayout
      walkable = function(x, y)
        if not L then return 0 end
        local ok, v = pcall(function() return Collision.isWalkable(x, y) end)
        if ok and v then return 3 end
        local okc, c = pcall(function() return L:collAt(x, y) end)
        if okc and c == 7 then return 0 end
        return 1
      end
    elseif gen == 2 then
      local G2 = require("src.world.gen2.Map")
      local Coll = require("src.core.CollPermissions")
      local def = game.world and game.world.maps and game.world.maps[mapId]
      local ts = def and game.world.tilesets[def.tileset]
      if def and ts then pcall(function() map = G2.new(def, ts) end) end
      walkable = function(x, y)
        if not map then return 0 end
        local ok, c = pcall(function() return map:cellCollision(x, y) end)
        if not ok or c == 0xff then return 0 end
        local ok2, k = pcall(function() return Coll.of(c) end)
        if ok2 and k == Coll.WALL then return 0 end
        if ok2 and k == Coll.LAND then return 3 end
        return 1
      end
    else
      local G1 = require("src.world.Map")
      local def = game.data and game.data.maps and game.data.maps[mapId]
      local ts = def and (game.data.tilesets or {})[def.tileset]
      if def then pcall(function() map = { def = def, tileset = ts } end) end
      walkable = function(x, y)
        if not def or not ts then return 0 end
        local ok, v = pcall(function() return G1.defIsWalkableCell(def, ts, x, y) end)
        if ok and v then return 3 end
        local ok2, p2 = pcall(function() return G1.defPassable(def, ts, x, y) end)
        if ok2 and p2 then return 1 end
        return 0
      end
    end

    local subjectFloor = false
    local best
    for radius = 0, 8 do
      for dy = -radius, radius do
        for dx = -radius, radius do
          if math.max(math.abs(dx), math.abs(dy)) == radius then
            local x, y = tx + dx, ty + dy
            local openness = walkable(x, y)
            if openness > 0 then
              local d = dx * dx + dy * dy
              -- prefer standing below the subject so it is in frame, not overhead
              if dx == 0 and dy > 0 and openness == 3 then
                return x, y, "up", subjectFloor
              end
              -- more open beats less; nearer beats further
              local better = not best
                or openness > best.openness
                or (openness == best.openness and d < best.d)
              if better then
                best = { x = x, y = y, d = d, dx = dx, dy = dy, openness = openness }
              end
            end
          end
        end
      end
      -- A LAND cell on the first ring is good enough; don't scan the whole map.
      if best and best.openness == 3 then break end
    end
    if best then
      return best.x, best.y, (best.dy > 0 and "up" or (best.dx < 0 and "right" or "left")),
             subjectFloor
    end
    return tx, ty, "up", subjectFloor
  end

  local done, skipped, failed, blank = 0, 0, 0, 0
  local currentMap = nil
  for i, r in ipairs(rows) do
    if done + skipped >= limit then break end
    local name = r.d:match("([^:]+)::(.+)$") or r.d
    local file = shotsFor(r.map) .. "/" .. safe(r.d) .. "-" .. camera .. ".png"
    -- Resume: the census ledger is the checklist, so presence is the record.
    local f = io.open(file, "rb")
    if f then f:close(); skipped = skipped + 1
    else
      local vx, vy, facing, subjectFloor = viewpoint(r.map, r.x, r.y)
      aimAt(vx, vy, r.x, r.y, subjectFloor)
      -- Reload per drawing, not per map. Loading once and only re-aiming left
      -- the player standing in the same cell for every subject, so a whole
      -- room's captures came out byte-identical -- every building__lab drawing
      -- was the same 6038 bytes. The viewpoint is the whole point of the
      -- capture, so it has to be honoured for every row.
      if not loadAt(r.map, vx, vy, facing) then failed = failed + 1 end
      currentMap = r.map
      for _ = 1, 8 do U.wait(1) end
      if gen == 1 or gen == 2 then
        pcall(function() P.setLevel("voxel", camera == "3p" and 7 or 6) end)
      end
      for _ = 1, settle do U.wait(1) end
      os.execute(("mkdir -p %q"):format(shotsFor(r.map)))
      -- Same settle race the per-map sweep has: the frame comes back empty
      -- (HUD only) while the mesher is still filling. Gen 1 hit this 31-39
      -- times per game and it looked exactly like "these tiles render nothing"
      -- -- CERULEAN_CITY/OVERWORLD__24 came back pure black. A blank PNG is a
      -- few hundred bytes, so re-shoot on size rather than recording it.
      local ok = false
      for attempt = 1, 3 do
        if not U.shot(game, file) then break end
        local bytes = 0
        local fh = io.open(file, 'rb')
        if fh then bytes = fh:seek('end') or 0; fh:close() end
        if bytes > 6000 then ok = true; break end
        blank = blank + 1
        if attempt < 3 then
          for _ = 1, 90 do U.wait(1) end
        end
      end
      if ok then done = done + 1 else failed = failed + 1 end
    end
    if i % 250 == 0 then
      print(("[dc] %d/%d rendered, %d skipped, %d failed"):format(i, #rows, skipped, failed))
    end
  end
  print(("[dc] DONE %s: rendered=%d skipped=%d failed=%d blank_retries=%d -> %s")
    :format(version, done, skipped, failed, blank, dir))
  return
end
