-- Asset transform: the birds' two frames.
--
-- Nothing in this mod ships a sprite, and nothing reads the imported
-- cache at runtime.  This recipe runs once on the player's own machine,
-- reads their generated battle pics, and writes DERIVED frames that the
-- sky layer draws.  If the cache has no pic for a species, that species
-- is simply absent from the sky.
--
-- Gen 1 gives one frame per creature, so the second frame is made here:
-- the silhouette squeezed vertically about its middle, which at altitude
-- reads as a wingbeat.  Doing it as a transform rather than as a runtime
-- scale means the flap is baked pixel art -- chunky, palette-true, and
-- consistent with everything else on screen.

local COMMON = { "pidgey", "pidgeotto", "spearow", "fearow", "zubat",
                 "golbat", "butterfree", "venomoth", "farfetchd" }
local RARE = { "articuno", "zapdos", "moltres", "aerodactyl", "dragonite" }

-- vertical squeeze for frame B: wings down becomes wings mid-beat
local SQUEEZE = 0.62

return function(ctx)
  local manifest = {}

  local function derive(name)
    local rel = "battle/front/" .. name .. ".png"
    if not ctx.exists(rel) then return false end
    local ok, src = pcall(ctx.readImage, rel)
    if not (ok and src) then return false end

    local w, h = src:getWidth(), src:getHeight()
    if w < 8 or h < 8 then return false end

    -- frame A: the pic as it stands
    ctx.writeImage(src, "birds/" .. name .. "_a.png")

    -- frame B: squeezed about the vertical centre, on a canvas of the
    -- same size so the two frames swap without the bird jumping
    local okB, dst = pcall(function()
      local out = ctx.blank(w, h)
      local newH = math.max(2, math.floor(h * SQUEEZE))
      local top = math.floor((h - newH) / 2)
      for y = 0, newH - 1 do
        local sy = math.min(h - 1, math.floor(y / SQUEEZE))
        for x = 0, w - 1 do
          local r, g, b, a = src:getPixel(x, sy)
          if a and a > 0 then out:setPixel(x, top + y, r, g, b, a) end
        end
      end
      return out
    end)
    if okB and dst then
      ctx.writeImage(dst, "birds/" .. name .. "_b.png")
    else
      -- no second frame is survivable: the sky layer will simply not flap
      ctx.writeImage(src, "birds/" .. name .. "_b.png")
    end
    return true
  end

  for _, name in ipairs(COMMON) do
    if derive(name) then manifest[#manifest + 1] = "c:" .. name end
  end
  for _, name in ipairs(RARE) do
    if derive(name) then manifest[#manifest + 1] = "r:" .. name end
  end

  -- The sky layer probes for these frames at load; whatever this machine
  -- could derive is what flies over it.
  return #manifest
end
