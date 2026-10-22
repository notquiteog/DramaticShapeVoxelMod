-- Adapted from Voxel Ascendant 2.0.2, MIT; see THIRD_PARTY_NOTICES.md.
-- Lightweight outdoor weather drawn over the finished voxel canvas.
--
-- No particle objects are allocated and nothing is simulated off-screen:
-- every drop/flakes' position is a deterministic function of a small clock.
-- That keeps the option cheap on iPhone and makes a resize immediately fill
-- the new frame instead of waiting for a particle system to repopulate it.

local V = ...

local ModSetting = V.require("ModSetting")
-- Battle Art owns canvas orientation; no VASC presentation wrapper needed.

local Weather = { clock = 0 }

Weather.setting = ModSetting.new("weather", "WEATHER",
  { "clear", "auto", "rain", "snow", "fog", "storm" },
  { "CLEAR", "AUTO", "RAIN", "SNOW", "FOG", "STORM" })

-- AUTO changes only at these boundaries.  The multiplier below is coprime
-- with AUTO_BUCKETS, so every map visits the complete weather distribution
-- before it repeats; it never depends on math.random, the wall clock or draw
-- frequency.  FOG and STORM deliberately occupy the two rarest buckets.
Weather.AUTO_SECONDS = 45
Weather.AUTO_BUCKETS = 32

-- A forced storm remains mostly dark rain.  Its two very short flashes recur
-- slowly enough to read as weather rather than a screen effect.  These values
-- are public so the deterministic QA seam can find a flash without waiting in
-- real time.
Weather.LIGHTNING_SECONDS = 23

local COLD = {
  INDIGO_PLATEAU = true, ROUTE_23 = true, ROUTE_28 = true,
}

local SCENIC_OUTDOORS = {
  INDIGO_PLATEAU = true, ROUTE_23 = true, ROUTE_10 = true,
  ROUTE_9 = true, ROUTE_4 = true, ROUTE_3 = true,
  CINNABAR_ISLAND = true, VIRIDIAN_FOREST = true,
  SAFARI_ZONE_CENTER = true, SAFARI_ZONE_EAST = true,
  SAFARI_ZONE_NORTH = true, SAFARI_ZONE_WEST = true,
  VERMILION_DOCK = true, SS_ANNE_BOW = true,
}

local function defIsOutdoor(def)
  if def.outdoor ~= nil then return def.outdoor and true or false end
  if def.environment then
    return def.environment == "TOWN" or def.environment == "ROUTE"
      or def.environment == "FOREST"
  end
  if def.mapType then return def.mapType == 1 or def.mapType == 2 or def.mapType == 3 or def.mapType == 6 end
  return def.tileset == "OVERWORLD"
end

local function hashText(s)
  local h = 7
  for i = 1, #s do h = (h * 31 + s:byte(i)) % 65521 end
  return h
end

local function mapId(map)
  return tostring(map and (map.id or (map.def and map.def.id)) or ""):gsub("^FR_", "")
end

-- One small shared exception contract for source maps whose metadata says
-- "interior" even though the playable space is visibly outdoors. BattleScene
-- consumes this same predicate for the daylight rig; weather and battles can
-- therefore never disagree about Safari, the dock or the exposed ship bow.
-- Real rooms still require an ordinary outdoor definition or an explicit ID.
function Weather.isOutdoor(map)
  if not (map and map.def) then return false end
  return defIsOutdoor(map.def) or SCENIC_OUTDOORS[mapId(map)] == true
end

local function finite(value, fallback)
  if type(value) ~= "number" or value ~= value
      or value == math.huge or value == -math.huge then
    return fallback
  end
  return value
end

-- Deterministic clock control for save restoration and QA.  update() remains
-- the ordinary runtime path; neither entry point consults an OS clock.
function Weather.setClock(value)
  Weather.clock = finite(value, 0) % 65521
end

function Weather.update(dt)
  dt = finite(dt, 0)
  if dt > 0 then Weather.clock = (Weather.clock + dt) % 65521 end
end

-- Pure selection seam used by mode() and tests.  An explicit forced mode is
-- still refused indoors, and unknown/legacy values fail to CLEAR rather than
-- accidentally falling into a costly effect.
function Weather.modeAt(map, selected, clock)
  local id = mapId(map)
  if not Weather.isOutdoor(map) then
    return "clear"
  end
  if selected == "off" then return "clear" end
  if selected ~= "auto" then
    if selected == "rain" or selected == "snow"
        or selected == "fog" or selected == "storm" then
      return selected
    end
    return "clear"
  end

  local period = math.floor(finite(clock, Weather.clock)
                            / Weather.AUTO_SECONDS)
  local roll = (hashText(id) + period * 17) % Weather.AUTO_BUCKETS

  -- One thunderstorm and two fog spells per complete 32-spell sequence.
  -- Cold routes retain their stronger snow bias; ordinary rain remains much
  -- more common than either of the new atmospheric modes.
  if roll == 0 then return "storm" end
  if roll <= 2 then return "fog" end
  if COLD[id] and roll <= 10 then return "snow" end
  if (not COLD[id]) and roll <= 8 then return "rain" end
  if COLD[id] and roll <= 16 then return "rain" end
  return "clear"
end

function Weather.mode(map)
  return Weather.modeAt(map, Weather.setting:get(), Weather.clock)
end

-- Strength and occurrence key for a map's current lightning impulse.  This
-- is intentionally pure: visual QA can reproduce a frame exactly and the
-- optional thunder hook can be debounced without random state.
function Weather.lightningAt(clock, map)
  local id = mapId(map)
  local span = Weather.LIGHTNING_SECONDS
  local shifted = finite(clock, Weather.clock) + hashText(id) % span
  local occurrence = math.floor(shifted / span)
  local phase = shifted - occurrence * span
  local strength = 0
  if phase < 0.075 then
    strength = 1 - phase / 0.075
  elseif phase >= 0.135 and phase < 0.195 then
    strength = 0.58 * (1 - (phase - 0.135) / 0.060)
  end
  return strength, id .. ":" .. tostring(occurrence)
end

local thunderHook, lastThunder

-- Optional engine integration only.  A host that has an appropriate sample
-- may register a callback; without one storms remain completely visual.  A
-- broken callback is contained and cannot break the completed world canvas.
function Weather.setThunderHook(hook)
  thunderHook = type(hook) == "function" and hook or nil
  lastThunder = nil
end

-- Shared smooth precipitation for overworlds and battles. Three translucent
-- speed/size bands suggest depth without hiding actors or scenery.
local function battleRainBand(g, w, h, step, count, phase,
                              speed, length, width, alpha)
  if not g.line then return false end
  if g.setLineStyle then g.setLineStyle("smooth") end
  if g.setLineWidth then g.setLineWidth(width) end
  g.setColor(0.76, 0.86, 1.0, alpha)
  local tick = Weather.clock * speed
  for i = 1, count do
    local x = (i * (73 + phase * 11) + tick * (1.6 + phase * .2))
              % (w + 80) - 40
    local y = (i * (41 + phase * 7) + tick * (3.6 + phase * .35))
              % (h + 100) - 50
    local len = length * (0.82 + (i % 5) * .045)
    g.line(x, y, x - step * (1.2 + phase * .35), y + len)
  end
  return true
end

local function paintBattleRain(g, w, h, cell, storm)
  local step = math.max(1, cell)
  -- A cool atmospheric grade replaces the old opaque storm blanket.
  g.setColor(0.10, 0.18, 0.30, storm and 0.07 or 0.015)
  g.rectangle("fill", 0, 0, w, h)
  if not battleRainBand(g, w, h, step, 30, 1, 38,
                        step * 2.0,
                        math.max(1, math.min(1.5, step * .22)), .16) then
    -- Minimal renderers omit streaks rather than painting opaque blocks.
    return
  end
  battleRainBand(g, w, h, step, storm and 44 or 38, 2, 50,
                 step * 3.2,
                 math.max(1, math.min(2.1, step * .30)),
                 storm and .34 or .24)
  battleRainBand(g, w, h, step, storm and 26 or 20, 3, 64,
                 step * 4.6,
                 math.max(1, math.min(2.8, step * .40)),
                 storm and .46 or .33)
end

local function paintBattleSnow(g, w, h, cell)
  local step, tick = math.max(1, cell), Weather.clock
  g.setColor(1, 1, 1, 0.66)
  for i = 1, 42 do
    local drift = math.sin(tick * 1.25 + i * 1.73) * step * 6
    local x = (i * 79 + drift + tick * (7 + i % 4)) % (w + 30) - 15
    local y = (i * 43 + tick * (12 + i % 6)) % (h + 30) - 15
    local radius = step * (i % 9 == 0 and .9 or .48)
    if g.circle then g.circle("fill", x, y, math.max(.6, math.min(2.2, radius)))
    else g.rectangle("fill", x, y, math.max(.6, math.min(2.2, radius)), math.max(.6, math.min(2.2, radius))) end
  end
end

-- Fog belongs to the depth-aware scene shader, never a screen-space veil.
-- Five tiles around the scene focus remain clear; the far field fades smoothly.
function Weather.fogStrength(map)
 return Weather.mode(map)=='fog'and 0.003 or 0
end

-- Paint into and return the canvas supplied by VoxelScene. Failure is a
-- visual fallback only: the already-finished world canvas remains valid.
local function apply(canvas, w, h, map, cell, resolvedMode, battle)
  local mode = resolvedMode or Weather.mode(map)
  if mode == "clear" or mode == "off" or mode == "fog" or not canvas then return canvas end
  if mode ~= "rain" and mode ~= "snow"
      and mode ~= "fog" and mode ~= "storm" then return canvas end
  local g = love.graphics
  if not (g and g.setCanvas and g.rectangle) then return canvas end
  local flash, occurrence = 0, nil
  if mode == "storm" then
    flash, occurrence = Weather.lightningAt(Weather.clock, map)
  end
  local pushed = false
  local ok = pcall(function()
    g.push("all")
    pushed = true
    g.origin()
    g.setCanvas(canvas)
    if g.setShader then g.setShader() end
    if g.setDepthMode then g.setDepthMode("always", false) end
    if g.setBlendMode then g.setBlendMode("alpha") end
    cell = math.max(1, math.floor((cell or 1) + 0.5))
    if mode == "rain" then
      paintBattleRain(g, w, h, cell, false)
    elseif mode == "snow" then
      paintBattleSnow(g, w, h, cell)
    elseif mode == "storm" then
      paintBattleRain(g, w, h, cell, true)
      -- Diffuse illumination from a distant storm, not a pixel bolt pasted
      -- over the foreground or an opaque white camera flash.
      if flash > 0 then
        g.setColor(.78,.86,1,.10*flash)
        g.rectangle('fill',0,0,w,h)
      end
    end
    g.setCanvas()
    g.pop()
    pushed = false
  end)
  if not ok then
    pcall(g.setCanvas)
    if pushed then pcall(g.pop) end
  end
  if ok and mode == "storm" and flash > 0 and thunderHook
      and occurrence ~= lastThunder then
    lastThunder = occurrence
    pcall(thunderHook, map, flash, occurrence)
  end
  return canvas
end


function Weather.apply(canvas, w, h, map, cell, resolvedMode)
  return apply(canvas, w, h, map, cell, resolvedMode, false)
end

function Weather.applyBattle(canvas, w, h, map, cell, resolvedMode)
  return apply(canvas, w, h, map, cell, resolvedMode, true)
end

return Weather
