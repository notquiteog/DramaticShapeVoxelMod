-- Drawing census: enumerate EVERY distinct tile drawing a game actually uses.
--
--   usage: POKEPORT_DRIVER=tools/qa/drawing-census.lua  CENSUS_OUT=/path/ledger.tsv
--
-- Why this shape of unit, and why it is tractable:
--
--   Gen 1 / Gen 2  The engine stores NO metatile id for either. The granularity
--                  is cell (2x2 tiles) -> block (2x2 cells = 4x4 tiles = 32x32px)
--                  -> finest stored unit is the 8x8 tile id. A GB "metatile" is
--                  2x2 tiles, i.e. half a block, and nothing names it. So the
--                  reviewable unit is the whole block drawing, keyed by
--                  (tilesetId, blockId). That set is bounded: Gen 2 writes
--                  METATILE_COUNT = 128 blocks per tileset, which is where the
--                  "~1,114 drawings" figure in the handoff comes from. That is
--                  enumerable and reviewable, unlike ~100k cell instances.
--
--   Gen 3          Here the engine does have a real metatile id:
--                  def.midLayout:midAt(cx,cy) with the pair from
--                  def.midLayout.pair (what lib/Gen3Scene.lua:157 reads).
--                  Unit is (pair, mid), bounded and small.
--
-- GEN 2 TRAP: Map:cellTile() and Map.defCellTile() return the COLLISION BYTE on
-- Gen 2, not a tile id -- src/world/gen2/Map.lua:165-166 says so explicitly.
-- The tile id is Map:tileAt(tx,ty). Gen 1 is the opposite: Map.defCellTile
-- returns the 8x8 tile id and needs the tilesetDef passed in.
--
-- This writes a ledger only. It renders nothing, so it is cheap enough to run
-- over every map of every game, and it turns "coverage unknown" into a number.
return function(game)
  local U = dofile("tests/drivers/util.lua")
  local V = game.mods and game.mods.exports
      and game.mods.exports.BATTLE_ART_VOXEL_FORK and game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
  local okGV, GameVersion = pcall(require, "src.core.GameVersion")
  local version = okGV and GameVersion.get() or "?"
  local okGen, Generation = pcall(function() return V and V.require and V.require("Generation") end)
  local gen = (okGen and Generation and Generation.number and Generation.number()) or 0

  -- Gen 3 needs the overworld before map data is readable.
  if game.phase == "boot" then
    local last, taps = nil, 0
    for _ = 1, 6000 do
      if game.phase ~= "boot" then break end
      local b = game.boot
      if (b and b.phase) ~= last then last = b and b.phase end
      pcall(function() U.tap(game, (b and b.introMovie) and "start" or "a") end)
      taps = taps + 1
      U.wait(1)
    end
    print(("[c] gen3 boot driven out of phase=boot after %d taps (phase=%s)")
      :format(taps, tostring(game.phase)))
  end

  -- drawingKey -> { maps = {mapId=true}, cells = n, rep = {mapId, cx, cy} }
  local drawings, mapCount, cellTotal = {}, 0, 0

  local function note(key, mapId, cx, cy)
    local d = drawings[key]
    if not d then d = { maps = {}, cells = 0 }; drawings[key] = d end
    d.maps[mapId] = true
    d.cells = d.cells + 1
    -- One representative cell per drawing, so a later capture harness can jump
    -- straight to it instead of re-deriving where the drawing lives.
    if not d.rep then d.rep = { mapId, cx, cy } end
  end

  if gen == 3 then
    local Map = require("src.core.game3.map")
    local store = game.data and game.data.maps
    if type(store) ~= "table" then
      print("[c] no game.data.maps for gen3")
      return
    end
    for id, def in pairs(store) do
      mapCount = mapCount + 1
      local L = def and def.midLayout
      if type(L) == "table" and L.midAt and L.pair then
        local w = (def.width or 0) * 2
        local h = (def.height or 0) * 2
        for cy = 0, h - 1 do
          for cx = 0, w - 1 do
            local ok, mid = pcall(function() return L:midAt(cx, cy) end)
            if ok and mid ~= nil then
              note(tostring(L.pair) .. "::" .. tostring(mid), id, cx, cy)
              cellTotal = cellTotal + 1
            end
          end
        end
      end
    end
  else
    local Gen2Map = gen == 2 and require("src.world.gen2.Map") or nil
    local Gen1Map = gen == 1 and require("src.world.Map") or nil
    local store, tilesets
    if gen == 2 then
      store = game.world and game.world.maps
      tilesets = game.world and game.world.tilesets
    else
      store = game.data and game.data.maps
      tilesets = game.data and game.data.tilesets
    end
    if type(store) ~= "table" then
      print(("[c] no map store for gen %d"):format(gen))
      return
    end
    for id, def in pairs(store) do
      mapCount = mapCount + 1
      local ts = tilesets and tilesets[def.tileset]
      local blockId
      if gen == 2 and Gen2Map and ts then
        local okm, map = pcall(function() return Gen2Map.new(def, ts) end)
        if okm and map then
          blockId = function(cx, cy)
            local ok, b = pcall(function() return map:blockId(math.floor(cx/2), math.floor(cy/2)) end)
            return ok and b or nil
          end
        end
      elseif gen == 1 and def.blocks then
        -- Gen 1: defCellTile needs tilesetDef.blocks; blockAt is plain index math.
        local border = def.borderBlock or 0
        blockId = function(cx, cy)
          local bx, by = math.floor(cx/2), math.floor(cy/2)
          local b = def.blocks[by * def.width + bx + 1]
          if b == nil then b = border end
          return b
        end
      end
      if blockId then
        local w = (def.width or 0) * 2
        local h = (def.height or 0) * 2
        for cy = 0, h - 1 do
          for cx = 0, w - 1 do
            local ok, b = pcall(blockId, cx, cy)
            if ok and b ~= nil then
              note(tostring(def.tileset) .. "::" .. tostring(b), id, cx, cy)
              cellTotal = cellTotal + 1
            end
          end
        end
      end
    end
  end

  -- Ledger: one row per distinct drawing.
  local out = os.getenv("CENSUS_OUT")
    or ("drawing-census-" .. tostring(version) .. ".tsv")
  local f = assert(io.open(out, "w"))
  f:write("# version\t", tostring(version), "\tgen\t", tostring(gen),
          "\tmaps\t", tostring(mapCount),
          "\tcells\t", tostring(cellTotal),
          "\tdistinct_drawings\t", tostring((function()
            local n = 0; for _ in pairs(drawings) do n = n + 1 end; return n
          end)()), "\n")
  f:write("# unit: gen1/gen2 = (tilesetId, blockId); gen3 = (pair, mid)\n")
  f:write("drawing\tmap_count\tcell_count\trep_map\trep_cx\trep_cy\tmaps\n")
  local keys = {}
  for k in pairs(drawings) do keys[#keys + 1] = k end
  table.sort(keys)
  for _, k in ipairs(keys) do
    local d = drawings[k]
    local ms = {}
    for m in pairs(d.maps) do ms[#ms + 1] = m end
    table.sort(ms)
    f:write(k, "\t", #ms, "\t", d.cells, "\t", d.rep[1], "\t", d.rep[2], "\t",
           d.rep[3], "\t", table.concat(ms, ","), "\n")
  end
  f:close()
  local distinct = #keys
  print(("[c] %s gen=%d maps=%d cells=%d distinct_drawings=%d -> %s")
    :format(tostring(version), gen, mapCount, cellTotal, distinct, out))
  return
end
