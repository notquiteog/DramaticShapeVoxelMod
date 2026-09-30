-- Dump a labelled sheet of every metatile in one Gen 3 tileset pair, sampled
-- from the engine's OWN decoded atlas.
--
--   env MID_MAP   a map id whose pair should be dumped
--   env SHOT_DIR  output directory
--
-- Why the engine and not the cache files: metatiles.bin is flagged
-- "compressed": true in meta.json, so decoding it offline produced an all-black
-- sheet and every identification from it would have been a guess. That is how
-- fr_potted_plant briefly got registered on Celadon Gym's 0x2ba/0x2bb, which
-- are the wall band -- the registration opened a hole through the room.
--
-- ts.midToSlot[mid] gives the 16x16 metatile's slot in the atlas the engine
-- already decoded, so this reads exactly the pixels the renderer draws.
return function(game)
  local U = dofile("tests/drivers/util.lua")
  local dir = assert(os.getenv("SHOT_DIR"), "SHOT_DIR")
  local id = assert(os.getenv("MID_MAP"), "MID_MAP")

  -- Boot to the field, exactly as the sweep does, or the atlas never decodes.
  if game.phase == "boot" then
    for _ = 1, 6000 do
      if game.phase ~= "boot" then break end
      local b = game.boot
      pcall(function() U.tap(game, (b and b.introMovie) and "start" or "a") end)
      U.wait(1)
    end
  end

  local Map = require("src.core.game3.map")
  local def = game.data.maps[id]
  if not def then print("[mt] no def " .. id) return end
  Map.ensureMidLayout(game, id, def)
  pcall(function() Map.load(nil, game, id, { x = 2, y = 2, facing = "up" }) end)
  for _ = 1, 60 do U.wait(1) end
  local pair = def.midLayout.pair

  -- The engine's own decoded tileset record: lib/Gen3Scene.lua:33 requires
  -- src.core.game3.tileset_native for exactly this, and reads
  -- Tiles._pairs[pair] for midToSlot + image. Read it after the map is loaded
  -- so the pair's atlas has been decoded.
  local Tiles = require("src.core.game3.tileset_native")
  local rec = Tiles._pairs and Tiles._pairs[pair]
  if not rec then
    print("[mt] no tileset record for pair " .. tostring(pair))
    return
  end
  local iw = rec.imageWidth
  if not iw and rec.image and rec.image.getWidth then iw = rec.image:getWidth() end
  print("[mt] atlas width=" .. tostring(iw) .. " height="
        .. tostring(rec.image and rec.image.getHeight and rec.image:getHeight() or "?"))
  print("[mt] atlas cols=" .. tostring(rec.cols)
        .. " w=" .. tostring(rec.imageWidth)
        .. " imageData=" .. tostring(rec.imageData ~= nil)
        .. " image=" .. tostring(rec.image ~= nil))

  local mids = {}
  for m in pairs(rec.midToSlot) do mids[#mids + 1] = m end
  table.sort(mids)
  local per = 8
  local cols = per
  local rows = math.ceil(#mids / per)
  local W, H = cols * 16, rows * 16
  local img = love.image.newImageData(W, H)
  -- love Image:getPixel is the supported read; imageData is not a flat RGBA
  -- byte array, so indexing it read one pixel for the whole sheet.
  -- Sample exactly the way the renderer does. Gen3Civic.sourcePixel
  -- (lib/Gen3Civic.lua:120-124) is the reference: imageData:getPixel on a
  -- 16px metatile slot, with overImageData alpha-composited OVER the base.
  -- imageData is a love ImageData, not a flat byte array, and love.graphics
  -- readback is sandboxed for a driver, so getPixel is the only route.
  local base = rec.imageData
  local over = rec.overImageData
  print("[mt] base=" .. tostring(base ~= nil) .. " over=" .. tostring(over ~= nil))

  local mids = {}
  for m in pairs(rec.midToSlot) do mids[#mids + 1] = m end
  table.sort(mids)
  local per = 8
  local W, H = per * 16, math.ceil(#mids / per) * 16
  local raw = dir .. "/metatile-sheet.rgb"
  local f = assert(io.open(raw, "wb"))
  local idf = io.open(dir .. "/metatile-sheet.ids", "w")
  local touched = 0
  for n, m in ipairs(mids) do
    local slot = rec.midToSlot[m]
    local sx = (slot % rec.cols) * 16
    local sy = math.floor(slot / rec.cols) * 16
    local dx0 = ((n - 1) % per) * 16
    local dy0 = math.floor((n - 1) / per) * 16
    idf:write(string.format("0x%02x\t%d\n", m, slot))
    for y = 0, 15 do
      local row = {}
      for x = 0, 15 do
        local r, g, b, a = base:getPixel(sx + x, sy + y)
        if over then
          local rr, gg, bb, aa = over:getPixel(sx + x, sy + y)
          r = rr * aa + r * (1 - aa)
          g = gg * aa + g * (1 - aa)
          b = bb * aa + b * (1 - aa)
          a = aa + a * (1 - aa)
        end
        if a > 0.05 then
          row[#row + 1] = string.char(
            math.floor(math.min(1, math.max(0, r)) * 255),
            math.floor(math.min(1, math.max(0, g)) * 255),
            math.floor(math.min(1, math.max(0, b)) * 255))
          if r + g + b > 0.09 then touched = touched + 1 end
        else
          row[#row + 1] = string.char(0, 0, 0)
        end
      end
      f:write(table.concat(row))
    end
  end
  f:close(); idf:close()
  print(("[mt] atlas %dx%d, %d metatiles, %d opaque px -> %s")
    :format(base:getWidth(), base:getHeight(), #mids, touched, raw))
  return
end
