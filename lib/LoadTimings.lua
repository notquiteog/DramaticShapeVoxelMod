-- TEST114 diagnostic panel. Times are elapsed CPU-side wall time, never GPU.
-- Keep collection and the START > TIMINGS control available for later
-- optimization work, but do not cover gameplay on a normal launch.
-- execution time. Nested probes are exclusive; suspended jobs accrue nothing.
local V = ...
local Generation = V.require("Generation")
local D = { visible = false }
local clock = (love and love.timer and love.timer.getTime) or os.clock
local main = { stack = {}, running = true }
local contexts = setmetatable({}, { __mode = "k" })
local frame, peaks, totals, calls = {}, {}, {}, {}
local counts = {}
local lastFrame, windowStart, epoch = clock(), clock(), clock()
local window, live, worst = {}, {}, { ms = 0, rows = {} }
local frameNo, resets, cancels, jobErrors, fallbacks = 0, 0, 0, 0, 0
local font, installed = nil, false

D.rows = {
  { "tree_all", "Tree work + draw", {
      "tree_build", "tree_pack", "tree_upload", "tree_keys", "tree_other", "tree_draw" } },
  { "terrain_all", "Terrain + props", {
      "terrain_build", "terrain_upload", "terrain_other" } },
  { "mesh_all", "Mesh allocation / writes", { "mesh_alloc", "mesh_write" } },
  { "cache_all", "Cache work", {
      "cache_read", "cache_decode", "cache_encode", "cache_write", "cache_other" } },
  { "prefetch", "Prefetch / precache" },
  { "actor_prepare", "Actor / model prepare" },
  { "actor_draw", "Actor / model draw" },
  { "grass_flowers", "Grass / flowers" },
  { "textures", "Textures / atlas" },
  { "world_other", "World render other" },
  { "update_other", "Game update other" },
  { "shadow_setup", "Shadow setup / target" },
  { "shadow_keys", "Shadow keys" },
  { "shadow_world", "Shadow terrain / flowers" },
  { "shadow_trees", "Shadow trees" },
  { "shadow_figures", "Shadow figures" },
  { "shadow_actors", "Shadow characters" },
  { "shadow_finish", "Shadow finish" },
  { "shadows", "Shadow other" },
  { "outside", "Outside probes / wait" },
}

local function pack(...) return { n = select("#", ...), ... } end

local function context(co)
  if not co then return main end
  local c = contexts[co]
  if not c then
    c = { stack = {}, running = true }
    contexts[co] = c
  end
  return c
end

local function charge(c, t)
  local token = c.stack[#c.stack]
  if c.running and c.start and token then
    local ms = math.max(0, t - c.start) * 1000
    local key = token.key
    frame[key] = (frame[key] or 0) + ms
    totals[key] = (totals[key] or 0) + ms
    token.ms = token.ms + ms
  end
  c.start = t
end

function D.begin(key)
  local c = context(coroutine.running())
  charge(c, clock())
  counts[key] = (counts[key] or 0) + 1
  local token = { key = key, ms = 0, context = c }
  c.stack[#c.stack + 1] = token
  return token
end

function D.finish(token)
  local c = token.context
  charge(c, clock())
  assert(c.stack[#c.stack] == token, "unbalanced load timing probe")
  c.stack[#c.stack] = nil
  calls[token.key] = math.max(calls[token.key] or 0, token.ms)
end

function D.call(key, fn, ...)
  local token = D.begin(key)
  local results = pack(pcall(fn, ...))
  D.finish(token)
  if not results[1] then error(results[2], 0) end
  return unpack(results, 2, results.n)
end

function D.wrap(key, fn)
  return function(...) return D.call(key, fn, ...) end
end

-- Both owning pumps use this instead of coroutine.resume. Pause the caller
-- while its child runs, and pause the child before control returns to caller.
-- No hooks, sleeps, extra yields, or changes to either scheduler's deadlines.
function D.resume(co, ...)
  local parent = context(coroutine.running())
  local child = context(co)
  charge(parent, clock())
  parent.running = false
  child.running, child.start = true, clock()
  local results = pack(coroutine.resume(co, ...))
  local t = clock()
  charge(child, t)
  child.running = false
  parent.running, parent.start = true, t
  if coroutine.status(co) == "dead" then contexts[co] = nil end
  return unpack(results, 1, results.n)
end

function D.cancel(co)
  if co then contexts[co] = nil end
  cancels = cancels + 1
end

function D.jobError() jobErrors = jobErrors + 1 end
function D.fallback() fallbacks = fallbacks + 1 end

function D.reset()
  V.require("SaplingEdits").resetStats()
  local t = clock()
  frame, peaks, totals, calls, window, live = {}, {}, {}, {}, {}, {}
  counts = {}
  worst = { ms = 0, rows = {} }
  lastFrame, windowStart, epoch = t, t, t
  frameNo, cancels, jobErrors, fallbacks = 0, 0, 0, 0
  resets = resets + 1
  local function clear(c)
    c.start = t
    for _, token in ipairs(c.stack) do token.ms = 0 end
  end
  clear(main)
  for _, c in pairs(contexts) do clear(c) end
end

function D.endFrame(mapId)
  local t = clock()
  charge(context(coroutine.running()), t)
  local ms = math.max(0, t - lastFrame) * 1000
  frameNo = frameNo + 1
  local measured = 0
  for _, value in pairs(frame) do measured = measured + value end
  frame.outside = math.max(0, ms - measured)
  for _, row in ipairs(D.rows) do
    local key = row[1]
    if row[3] then
      local grouped = 0
      for _, child in ipairs(row[3]) do grouped = grouped + (frame[child] or 0) end
      frame[key] = grouped
    end
    local value = frame[key] or 0
    peaks[key] = math.max(peaks[key] or 0, value)
    window[key] = math.max(window[key] or 0, value)
  end
  window.ms = math.max(window.ms or 0, ms)
  if ms > worst.ms then
    worst = { ms = ms, rows = frame, map = tostring(mapId or "-"),
              at = t - epoch, frame = frameNo }
  end
  if t - windowStart >= 0.5 or frameNo == 1 then
    live, window, windowStart = window, {}, t
  end
  frame, lastFrame = {}, t
end

-- Read-only by convention: exposed for local verification and mod diagnostics.
function D.snapshot()
  return { current = frame, live = live, worst = worst, peaks = peaks,
           totals = totals, calls = calls, counts = counts, cancels = cancels,
           errors = jobErrors, fallbacks = fallbacks, resets = resets }
end

local function number(value) return string.format("%6.1f", value or 0) end

local function panel(g, mapId)
  if not font then font = g.newFont(16) end
  local w, h = g.getDimensions()
  local pw, ph = 456, 659
  local scale = math.min(1.2, (w - 24) / pw, (h - 60) / ph)
  if scale <= 0 then return end
  g.origin()
  g.setShader()
  g.setScissor()
  g.setDepthMode()
  g.setBlendMode("alpha")
  g.translate(12, 44)
  g.scale(scale, scale)
  g.setColor(0.025, 0.035, 0.055, 0.9)
  g.rectangle("fill", 0, 0, pw, ph, 8, 8)
  g.setFont(font)
  g.setColor(0.45, 0.9, 0.85, 1)
  g.print("TEST137  |  TOWER VISUALS + WALL FINISHES", 14, 10)
  g.setColor(1, 1, 1, 1)
  g.print("Map: " .. tostring(mapId or "-"):sub(1, 39), 14, 33)
  g.print("Frame ms   live " .. number(live.ms)
    .. "   worst " .. number(worst.ms), 14, 56)
  g.setColor(0.75, 0.8, 0.85, 1)
  g.print("Elapsed ms (exclusive)", 14, 85)
  g.print("LIVE MAX", 265, 85)
  g.print("WORST", 374, 85)
  for i, row in ipairs(D.rows) do
    local y = 109 + (i - 1) * 19
    local value = worst.rows[row[1]] or 0
    if value >= 30 then g.setColor(1, 0.72, 0.33, 1)
    else g.setColor(0.9, 0.93, 0.97, 1) end
    g.print(row[2], 14, y)
    g.printf(number(live[row[1]]), 260, y, 76, "right")
    g.printf(number(value), 364, y, 76, "right")
  end
  g.setColor(0.65, 0.85, 0.82, 1)
  g.print(string.format("Worst at %.1fs: %s", worst.at or 0,
    (worst.map or "-"):sub(1, 29)), 14, 494)
  g.print(string.format("Tree cancels %d  |  job errors %d  |  fallback %d",
    cancels, jobErrors, fallbacks), 14, 516)
  g.setColor(0.75, 0.8, 0.85, 1)
  g.print(string.format("Scene calls %d  |  prefetch calls %d",
    counts.world_other or 0, counts.prefetch or 0), 14, 540)
  local shadow = V.require("ShadowMap").stats()
  g.print(string.format("Shadow %dpx | allocs (session) %d",
    shadow.size, shadow.allocations), 14, 563)
  local sapling = V.require("SaplingEdits").stats()
  g.print(string.format("Sapling cuts %d | restores %d | rebuilds %d",
    sapling.cuts, sapling.restores, sapling.fallbacks), 14, 586)
  g.print("LIVE: max/0.5s. WORST: one retained frame.", 14, 609)
  g.print("CPU-side time; not GPU time. START > TIMINGS", 14, 631)
end

function D.draw(mapId)
  local g = love and love.graphics
  if not D.visible or not (g and g.newFont and g.push) then return end
  g.push("all")
  local ok, err = pcall(panel, g, mapId)
  g.pop()
  -- Never let a missing HUD API interfere with the world's render pass.
  D.hudError = not ok and tostring(err) or nil
end

function D.install(mod)
  if installed then return end
  installed = true
  -- Probe render/prefetch at the calling code. Stadium ba.9 regenerates the
  -- scene after this install, replacing these functions on the same table.
  -- Wrapping their exports here both loses coverage and obscures the upvalues
  -- that legacy actor adapters inspect. The actual functions stay untouched.
  local voxel = V.require("Voxel3D")
  voxel.newMesh = D.wrap("mesh_alloc", voxel.newMesh)
  mod.hooks:wrap("core.update", function(next, game, dt)
    return D.call("update_other", next, game, dt)
  end)
  mod.hooks:wrap("render.hud", function(next, game, viewport)
    local results = pack(next(game, viewport))
    local map = game and game.overworld and game.overworld.map
    D.endFrame(map and (map.id or (map.def and map.def.id)))
    if map then D.draw(map.id or (map.def and map.def.id)) end
    return unpack(results, 1, results.n)
  end)
  mod.hooks:wrap("ui.start_menu.items", function(next, game, items)
    local out = next(game, items)
    if type(out) ~= "table" then return out end
    table.insert(out, {
      label = "TIMINGS",
      onSelect = function()
        local Menu = require("src.ui.Menu")
        local Screens = require("src.ui.Screens")
        game.stack:push(Menu.new(game, {
          { label = "RESET", onSelect = function() D.reset() end },
          { label = D.visible and "HIDE" or "SHOW",
            onSelect = function() D.visible = not D.visible end },
        }, { tx = 10, ty = 0, tw = 10,
             onCancel = function()
               Screens.push(game, Generation.screenId("StartMenu"))
             end }))
      end,
    })
    return out
  end)
  mod.events:on("save.loaded", D.reset)
  mod.events:on("save.created", D.reset)
  D.reset()
end

return D
