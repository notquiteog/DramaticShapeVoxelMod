-- FLORA: grass with height to it, and the small moving things.
-- payload-version: 65
--
-- TUFTS.  Dramatic Shape stands two thin rows of grass per tile, evenly,
-- which is honest to the art and reads as a lawn.  Tall grass in this
-- game is supposed to be where things live.  This adds extra blades at
-- hashed positions and varied heights across every encounter cell -- the
-- engine's own Map:isGrassCell decides which those are -- built as
-- crossed pairs so a blade reads from any angle, and textured from the
-- tileset's own grass art.  Deterministic by position: the same meadow
-- grows the same way every time you walk into it, which is what stops it
-- shimmering.
--
-- PARTICLES.  Three kinds, all short-lived camera-facing motes drawn
-- from textures generated here at load (no asset ships, and none is
-- derived from anything):
--
--   SEEDS    kicked up behind you while you move through tall grass --
--            the visible reason to be wary of it
--   DRIPS    falling in caves, with a splash at the bottom, seeded on
--            the ceiling above wherever you are
--   FIREFLIES  outdoors after dark, bobbing low over grass, slow and few
--   LEAVES   drifting down under the forest canopy, tumbling as they fall
--   DUST     motes turning slowly in the air of an interior
--   FOAM     spray lifting off the water's edge
--   SMOKE    rising from a building's chimney, thinning as it climbs
--   RUSTLE   very occasionally, a shudder in a distant grass cell with
--            nothing attached to it -- purely to make you look
--
-- DARKNESS.  Gen 1's unlit floors exist so that Flash has a point, but a
-- top-down view can only express that as a smaller window.  Standing in
-- one, it should be dark.  This nests translucent shells around the eye:
-- anything a long way off sits behind several of them and fades toward
-- black, anything close sits in front of them all and is clear.  The
-- engine's own answer decides when -- field.darkMaps for the floor,
-- save.flashLit for whether Flash is up -- so using Flash genuinely
-- pushes the walls back, which in 2D it never quite did.
--
-- RAIN.  Gen 1 has no weather, so this mod keeps its own: long dry
-- spells broken by showers, on a clock seeded per session, outdoors only.
-- Drops fall around the eye and burst on landing; the world does not get
-- wet, because nothing here may touch the game.  While it rains every
-- NPC puts up an UMBRELLA -- a small pixel canopy generated in code,
-- bobbing with their walk -- which is the single cheapest way to make a
-- town feel like it noticed the weather.
--
-- SHAFTS.  Under the forest canopy, angled slabs of pale light lean down
-- through the leaves, drifting slowly so the wood never looks still.
--
-- FOG.  Lavender Town and its tower wear pale shells, the same trick the
-- cave dark uses but reversed: distance whitens instead of blackening.
--
-- Everything here is presentational: no collision, no encounter rates, no
-- movement.  Particles live in a fixed pool and are recycled, so a long
-- walk costs no more than a short one.

local V = ...
-- SELF-LOCATION. The installer manages every family base because it
-- cannot see which one the launcher enabled -- but THIS copy, the one
-- actually executing, was loaded from the live base by definition. If
-- the chunk name carries the folder, claim the runtime globals for it,
-- which settles the asset paths however many siblings were patched.
pcall(function()
  local src = debug.getinfo(1, "S").source or ""
  local home = src:match("@?(.-mods/[^/]+)/lib/")
  if home then
    local rel = home:match("(mods/[^/]+)$") or home
    _G.__ds_patch_base = rel
    _G.__ds_posters_dir = rel .. "/lib/"
  end
end)


local Voxel3D = V.require("Voxel3D")
local okTS, TileShape = pcall(V.require, "TileShape")
local Mat4 = V.require("Mat4")
-- The first-person rig, if this build has one.  absol89's battle-art fork
-- is based on Dramatic Shape 1.3.0, which predates the rig entirely --
-- and an unguarded require there would fail at load and take this whole
-- module with it.  Without a rig the blend reads as zero, which means the
-- diorama's cutaway view: exactly right for a build that has no first
-- person to be inside of.
local okFP, FirstPerson = pcall(V.require, "FirstPerson")
if not (okFP and type(FirstPerson) == "table") then
  FirstPerson = { yaw = 0, blendEased = function() return 0 end }
end
local okDN, DayNight = pcall(V.require, "DayNight")

local Flora = {}

-- ------- tufts
local BLADES = { OFF = 0, SUBTLE = 2, WILD = 4 }   -- extra blades per cell

-- ------- darkness
local SHELLS = 7             -- nested shells; more is smoother and dearer
local DARK_NEAR = 26         -- clear within this radius
local DARK_FAR = 150         -- effectively black beyond it
local FLASH_MULT = 3.4       -- how far Flash pushes the walls back
local SHELL_SEGMENTS = 20


-- Draw blocks run inside this rather than a bare pcall.  Every one of
-- them changes graphics state -- colour, alpha, depth mode -- and a bare
-- pcall that throws midway leaves that state set for the REST OF THE
-- FRAME.  Anything drawn after us then inherits it: a stray alpha makes
-- another mod's sprites invisible, a stray depth mode makes them sort
-- wrongly, and the fault looks like theirs.  push("all")/pop() restores
-- the lot whatever happens inside.
local function guarded(fn)
  -- headless, or a driver without a graphics stack: just run it
  local g = love and love.graphics
  if not (g and g.push and g.pop) then return pcall(fn) end
  local pushed = pcall(g.push, "all")
  pcall(fn)
  if pushed then pcall(g.pop) end
end

-- ------- WIND.
-- The tufts are a cached mesh, so per-blade animation would mean
-- rebuilding it every frame -- far too dear.  Instead the blades are
-- split into a few meshes by position, and each is drawn through a SHEAR
-- that leans its tops over and leaves its roots where they are.  Give
-- each group its own phase and a gust travels ACROSS a field rather than
-- the whole meadow nodding in unison, which is the thing that would
-- betray it as a trick.
local WIND = { OFF = 0, BREEZE = 0.10, GUSTY = 0.26 }
local WIND_GROUPS = 4
local WIND_RATE = 0.9        -- how quickly a gust passes
local WIND_DIR = 0.7         -- prevailing direction, radians

-- x and z displaced in proportion to height; row-major, as Mat4 is.
local function shear(kx, kz)
  return { 1, kx, 0, 0,
           0, 1,  0, 0,
           0, kz, 1, 0,
           0, 0,  0, 1 }
end

-- ------- weather
local RAIN_DROPS = 70          -- drops aloft while it rains
local STORM_DROPS = 130        -- and in a proper storm
local RAIN_RADIUS = 120
local RAIN_TOP, RAIN_FALL = 130, 260
local DRY_MIN, DRY_MAX = 240, 900     -- seconds between showers
local WET_MIN, WET_MAX = 45, 150      -- seconds a shower lasts
local STORM_ODDS = 0.14               -- how many showers turn into storms

-- ------- lightning, with care.
-- Flashing light is a genuine photosensitivity risk, so this is built to
-- be rare and gentle rather than dramatic: strikes are far apart, never
-- in bursts (a hard minimum gap is enforced, well below the three-per-
-- second guidance), the screen brightening is partial and low-alpha
-- rather than a white-out, and it eases in and out instead of cutting.
-- Anyone who wants the storm without the flash has LIGHTNING off, and
-- the rain and thunderheads remain.
local BOLT_GAP_MIN = 4.5      -- seconds; a hard floor between strikes
local BOLT_CHANCE = 0.10      -- per second beyond that floor
local BOLT_LIFE = 0.42        -- how long a bolt hangs in the air
local FLASH_MAX = 0.17        -- the very most the screen brightens
local FLASH_FADE = 0.55       -- seconds to ease back down
local BOLT_Y, BOLT_DIST = 300, 620

-- ------- puddles
local PUDDLE_EVERY = 11       -- roughly one walkable cell in this many
local PUDDLE_SIDES = 10       -- corners on a puddle: round, not square
local PUDDLE_GROUPS = 4       -- staggered so they appear a few at a time
local PUDDLE_FILL = 26        -- seconds of rain to fill them
local PUDDLE_DRY = 70         -- and to dry them out again
-- The umbrella's centre height above an NPC's feet.  The art hangs its
-- pole down to the bottom of the frame, so this puts the grip at about
-- the middle of a 16px sprite -- where a hand would be -- rather than
-- floating above the head.
local UMBRELLA_H = 14

-- ------- shafts, fog, windows
local SHAFTS = 7
local FOG_MAPS = { LAVENDER_TOWN = true, POKEMONTOWER = true,
                   LAVENDER = true }

local LIP_H = 1.5            -- how far the lip stands proud of the top
local LIP_SHADE = 1.35       -- brighter than the surface it sits on
local BLADE_MIN, BLADE_MAX = 7, 20                 -- pixel heights
local BLADE_W = 7

-- ------- particles
local POOL = 300
local SEED_RATE = 22        -- per second while moving through grass
local DRIP_RATE = 3.5
local FLY_TARGET = 14       -- fireflies aloft at once, after dark
local LEAF_RATE = 2.2       -- per second under canopy
local TLEAF_RATE = 34       -- picks per second off the lifted trees
                            -- (misses -- far cells, boulders -- thin it,
                            -- and the pool is the hard ceiling; a leaf
                            -- is one textured quad, so even a heavy
                            -- shower costs what the rain already does)
local DUST_TARGET = 12      -- motes hanging in an interior
local FOAM_RATE = 5         -- per second near a shoreline
local SMOKE_RATE = 2.4      -- per chimney per second
local RUSTLE_CHANCE = 0.06  -- per second, somewhere in view
local SWARMS = 3            -- swarm columns near the player
local GNATS_PER_SWARM = 7
local SWARM_RANGE = 150

local tuftCache = nil       -- { map, key, mesh, note }
local shellMesh = nil
local shaftMesh, umbrellaImg, dropImg = nil, nil, nil
local canopyCache = nil     -- { map, mesh, note, vines }
local vineHits = {}         -- [block key] = { x, z, at }
local swarms = nil          -- { { x, y, z, r } , ... }
local storm, boltAt, bolts, flash = false, nil, nil, 0
local movedThisFrame = 0
local boltImgs = nil
local puddleCache, wetness = nil, 0
local lightCache = nil
local rainUntil, dryUntil, raining = nil, nil, false
local drops = nil
local featureCache = nil    -- { map, chimneys = {}, shores = {}, grass = {} }
local parts, partMesh, tex = nil, nil, nil
local lastT, wasX, wasZ = nil, nil, nil

local function status(s) _G.__ds_flora_status = s end
status("loaded; awaiting the first frame")

local OPEN_AIR_TILESETS = {
  OVERWORLD = true, FOREST = true, PLATEAU = true, SHIP_PORT = true,
}

local function config()
  local pub = rawget(_G, "__ds_ceiling_config")
  if type(pub) == "function" then
    local ok, cfg = pcall(pub)
    if ok and type(cfg) == "table" then return cfg end
  end
  return {}
end

local function now()
  local ok, t = pcall(function() return love.timer.getTime() end)
  return ok and t or 0
end

local function isOutdoor(map)
  local def = map and map.def
  if not def then return false end
  local tid = def.tileset or (map.tileset and map.tileset.id)
  if tid and OPEN_AIR_TILESETS[tid] then return true end
  local ok, outdoor = pcall(function()
    local Map = require("src.world.Map")
    return Map.isOutdoor and Map.isOutdoor(def)
  end)
  if ok and outdoor ~= nil then return outdoor end
  local conns = def.connections
  return (conns and next(conns) ~= nil) and true or false
end

-- Dramatic Shape 1.5.5 added a 3RD rung: the same first-person rig with
-- the eye boomed back behind the shoulder.  The blend reads as engaged
-- there, so a sealed ceiling would slam shut in front of a camera that
-- is now OUTSIDE the room -- the lid problem, again.
--
-- showsPlayer() is the signal to use rather than extended(): it is false
-- when the boom collapses into the head (backed against a wall), and at
-- that moment the view really is first person and really does want its
-- ceiling.  Dramatic Shape reasons the same way about its own character
-- card.
local okTP, ThirdPerson = pcall(V.require, "ThirdPerson")
local function boomedOut()
  if not (okTP and ThirdPerson and ThirdPerson.showsPlayer) then
    return false
  end
  local ok, out = pcall(ThirdPerson.showsPlayer)
  return (ok and out) and true or false
end

local function isCanopy(map)
  if not (okDN and DayNight and DayNight.isCanopy) then return false end
  local ok, v = pcall(DayNight.isCanopy, map)
  return ok and v or false
end

-- The engine's own answers: which floors are unlit, and whether Flash is
-- currently up.  Both live on the running game rather than on the map, so
-- they are read fresh every frame and every read is fenced.
local function darkness(map)
  local ok, res = pcall(function()
    local Game = require("src.core.Game")
    local id = map.def and (map.def.id or map.def.name)
    -- The engine keeps the list at field.darkMaps.MAPS -- an array
    -- inside a table, as its own Rock Tunnel test asserts. This module
    -- looked for the ids directly on darkMaps, matched nothing, and so
    -- CAVE DARKNESS never once fired. Everything gated behind it -- the
    -- shells, Flash widening them, and later the pools, torches and bats
    -- -- was dead for the same reason.
    local dark = Game.data and Game.data.field and Game.data.field.darkMaps
    local isDark = false
    if dark and id then
      for _, m in ipairs(dark.maps or {}) do
        if m == id then isDark = true break end
      end
      -- tolerate a plain list, or a set, in case the shape ever changes
      if not isDark and dark[id] == true then isDark = true end
      if not isDark then
        for _, m in ipairs(dark) do
          if m == id then isDark = true break end
        end
      end
    end
    local lit = Game.save and Game.save.flashLit and true or false
    return { dark = isDark, flash = lit }
  end)
  if ok and type(res) == "table" then return res end
  return { dark = false, flash = false }
end

local function isNight()
  -- Dramatic Shape has no isNight(); what it has is bodyAt(t), whose
  -- third return says whether the body in the sky is the MOON.  That is
  -- the honest answer to "is it night", and it follows whichever mode the
  -- player is in -- pinned, cycling, or synced to their own clock.
  if okDN and DayNight and DayNight.bodyAt then
    local ok, moon = pcall(function()
      local t = DayNight.time and DayNight.time() or 0
      local _, _, isMoon = DayNight.bodyAt(t)
      return isMoon
    end)
    if ok and moon ~= nil then return moon and true or false end
  end
  -- without the module at all, fall back to the wall clock
  local okD, h = pcall(function() return tonumber(os.date("%H")) end)
  if okD and h then return (h < 6 or h >= 20) end
  return false
end

-- stable per-position pseudo-random in [0, 1)
-- The voxel shader DISCARDS any texel under half alpha and draws the rest
-- fully opaque (see Voxel3D: "if (p.a < 0.5) discard"), so this renderer
-- cannot express a soft edge at all -- every gradient sprite becomes a
-- hard blob, which is why the glows looked like cut-out squares.  The
-- answer is the one the hardware this game came from used: ORDERED
-- DITHER.  Partial coverage becomes a stipple of fully-on and fully-off
-- texels, which survives the discard and looks like Game Boy art rather
-- than like a mistake.
local BAYER = {
  {  0,  8,  2, 10 },
  { 12,  4, 14,  6 },
  {  3, 11,  1,  9 },
  { 15,  7, 13,  5 },
}
local function dither(x, y, a)
  if a >= 0.999 then return 1 end
  if a <= 0.001 then return 0 end
  local threshold = (BAYER[(y % 4) + 1][(x % 4) + 1] + 0.5) / 16
  return (a > threshold) and 1 or 0
end

-- A position hash, well distributed in every bit.  The previous one --
-- an LCG step over a 2^20 modulus -- had such poor high bits that
-- floor(h * 4) returned ZERO for every cell on a map: every puddle
-- landed in the same group, and nothing that leaned on it varied as
-- much as it looked like it did.  This is the standard fract-of-sine
-- mixer: deterministic, no bit operations, and properly spread.
local function hash01(a, b, c)
  local x = a * 127.1 + b * 311.7 + (c or 0) * 74.7
  local s = math.sin(x) * 43758.5453123
  return s - math.floor(s)
end

-- ------- tuft mesh
local INSET = 0.5
-- The atlas geometry, taken the way the chunk mesher takes it: the row
-- stride is tileset.tilesPerRow, NOT imageWidth/8.  Outdoor atlases carry
-- animation frames beyond the tile grid, so the two disagree there -- and
-- when they do, every tile index lands in the wrong place and quads
-- sample wide ribbons of the whole tileset.  That was the sky-ribbon
-- glitch: the maths, not the geometry.
local function uvFor(map, tile)
  local ts = map.tileset or {}
  local perRow = ts.tilesPerRow or 16
  local aw = ts.imageWidth or (perRow * 8)
  local ah = ts.imageHeight or 48
  -- and clamp into the grid: a tile index the atlas has no room for
  -- would otherwise sample off the end of the texture, which is how a
  -- quad ends up wearing a ribbon of the whole tileset
  local rows = math.max(1, math.floor(ah / 8))
  tile = math.max(0, math.floor(tile or 0)) % (perRow * rows)
  local ax = (tile % perRow) * 8
  local ay = math.floor(tile / perRow) * 8
  return (ax + INSET) / aw, (ax + 8 - INSET) / aw,
         (ay + INSET) / ah, (ay + 8 - INSET) / ah
end

local function buildTufts(map, perCell)
  local grassTile = map.tileset and map.tileset.grassTile
  if not grassTile then return nil, "tileset names no grass tile" end
  local wc, hc = map.widthCells or 0, map.heightCells or 0
  if wc == 0 or hc == 0 then return nil, "map has no cells" end
  local u0, u1, v0, v1 = uvFor(map, grassTile)
  -- one vertex list per wind group, so each can be sheared on its own
  -- clock; with wind off they simply all draw unsheared
  local groups = {}
  for g = 1, WIND_GROUPS do groups[g] = { verts = {}, idx = {}, quads = 0 } end
  local quads, cells = 0, 0

  local function blade(g, bx, bz, h, ang, shade)
    local G = groups[g]
    -- crossed pair: two quads at right angles, so it reads from any side
    for k = 0, 1 do
      local a = ang + k * math.pi * 0.5
      local dx, dz = math.cos(a) * BLADE_W * 0.5, math.sin(a) * BLADE_W * 0.5
      G.verts[#G.verts + 1] = { bx - dx, h, bz - dz, u0, v0, shade }
      G.verts[#G.verts + 1] = { bx + dx, h, bz + dz, u1, v0, shade }
      G.verts[#G.verts + 1] = { bx + dx, 0, bz + dz, u1, v1, shade }
      G.verts[#G.verts + 1] = { bx - dx, 0, bz - dz, u0, v1, shade }
      Voxel3D.pushQuad(G.idx, G.quads)
      G.quads = G.quads + 1
      quads = quads + 1
    end
  end

  for cy = 0, hc - 1 do
    for cx = 0, wc - 1 do
      local ok, grass = pcall(function() return map:isGrassCell(cx, cy) end)
      if ok and grass then
        cells = cells + 1
        for i = 1, perCell do
          local r1 = hash01(cx, cy, i)
          local r2 = hash01(cy, cx, i * 7)
          local r3 = hash01(cx + i, cy - i, 3)
          local bx = cx * 16 + 2 + r1 * 12
          local bz = cy * 16 + 2 + r2 * 12
          local h = BLADE_MIN + r3 * (BLADE_MAX - BLADE_MIN)
          -- taller blades read slightly darker: depth in the clump
          local shade = 0.78 + 0.22 * (1 - (h - BLADE_MIN)
                        / (BLADE_MAX - BLADE_MIN))
          -- group by POSITION, so a gust sweeps a band of the meadow
          local g = 1 + math.floor(hash01(cx + cy, cx - cy, 53) * WIND_GROUPS)
                        % WIND_GROUPS
          blade(g, bx, bz, h, r1 * math.pi, shade)
        end
      end
    end
  end
  if quads == 0 then return nil, "no grass cells" end
  local meshes = {}
  for g = 1, WIND_GROUPS do
    local G = groups[g]
    if G.quads > 0 then
      local m = Voxel3D.newMesh(G.verts, G.idx)
      if m then meshes[#meshes + 1] = { mesh = m, phase = g * 1.7 } end
    end
  end
  if #meshes == 0 then return nil, "driver refused the tuft meshes" end
  return meshes, ("%d blades over %d cells"):format(quads / 2, cells)
end

-- ------- the darkness shells: nested cylinders, drawn back to front so
-- each adds a little more black to whatever is behind it
local function buildShells()
  local verts, indexMap, quads = {}, {}, 0
  for s = 1, SHELLS do
    local f = s / SHELLS
    local r = DARK_NEAR + (DARK_FAR - DARK_NEAR) * f
    -- alpha carried in the shade attribute: near shells barely tint,
    -- far ones are almost solid, so the falloff is not linear
    local shade = 1 - (f * f) * 0.55
    for i = 0, SHELL_SEGMENTS - 1 do
      local a0 = (i / SHELL_SEGMENTS) * math.pi * 2
      local a1 = ((i + 1) / SHELL_SEGMENTS) * math.pi * 2
      local x0, z0 = math.cos(a0) * r, math.sin(a0) * r
      local x1, z1 = math.cos(a1) * r, math.sin(a1) * r
      -- UVs kept inside a single texel of the white pixel: these are
      -- tints, and must never sample anything with art in it
      verts[#verts + 1] = { x1, 90, z1, 0.5, 0.5, shade }
      verts[#verts + 1] = { x0, 90, z0, 0.5, 0.5, shade }
      verts[#verts + 1] = { x0, -40, z0, 0.5, 0.5, shade }
      verts[#verts + 1] = { x1, -40, z1, 0.5, 0.5, shade }
      Voxel3D.pushQuad(indexMap, quads)
      quads = quads + 1
    end
  end
  return Voxel3D.newMesh(verts, indexMap)
end

-- ------- an umbrella, drawn in code: a four-shade GBC canopy with a
-- scalloped hem, a shaft and a crooked handle.  Eight pixels of dome is
-- all it takes to read as "raining" from across a street.
local function makeUmbrella()
  local ok, img = pcall(function()
    local S = 16
    local data = love.image.newImageData(S, S)
    local DARK = { 0.13, 0.13, 0.18 }
    local BODY = { 0.83, 0.24, 0.28 }
    local LITE = { 0.96, 0.52, 0.50 }
    local SHAF = { 0.55, 0.44, 0.30 }
    local function put(x, y, c, a)
      if x >= 0 and y >= 0 and x < S and y < S then
        data:setPixel(x, y, c[1], c[2], c[3], dither(x, y, a or 1))
      end
    end
    -- The pole sits a pixel right of centre, and the whole thing is
    -- drawn around it: carried off to one side, the way a person holds
    -- an umbrella, rather than balanced on their head.  Baking the
    -- offset into the ART keeps it true from every angle, which a world
    -- offset would not -- a billboard turns to face you.
    local POLE = 9

    -- the canopy, higher in the frame now to leave room for the pole
    for x = 0, 15 do
      local dx = (x - POLE + 0.5) / 8.5
      local top = math.floor(1 + dx * dx * 3.5)
      for y = top, 5 do
        local c = (y == top) and DARK or ((x < POLE) and LITE or BODY)
        put(x, y, c)
      end
    end
    -- the scalloped hem
    for x = 0, 15 do
      put(x, 5, DARK)
      if (x % 4) == 1 or (x % 4) == 2 then put(x, 6, BODY); put(x, 7, DARK) end
    end
    -- the pole: all the way down the frame, so the grip lands at the
    -- height this is drawn at rather than somewhere above the sprite
    for y = 5, 15 do
      put(POLE, y, SHAF)
      put(POLE + 1, y, DARK)
    end
    -- a hand-sized grip, and the crook turning off to the left
    put(POLE, 11, DARK); put(POLE + 1, 11, DARK)
    put(POLE - 1, 14, SHAF); put(POLE - 2, 15, SHAF)
    put(POLE - 1, 15, DARK)
    local i = love.graphics.newImage(data)
    i:setFilter("nearest", "nearest")
    return i
  end)
  return ok and img or nil
end

-- a raindrop: a short vertical streak, not a dot
local function makeDrop()
  local ok, img = pcall(function()
    local S = 8
    local data = love.image.newImageData(S, S)
    for y = 0, S - 1 do
      for x = 0, S - 1 do
        local on = (x >= 3 and x <= 4 and y >= 1 and y <= 6)
        data:setPixel(x, y, 0.72, 0.82, 0.98,
                      dither(x, y, on and 0.8 or 0))
      end
    end
    local i = love.graphics.newImage(data)
    i:setFilter("nearest", "nearest")
    return i
  end)
  return ok and img or nil
end

-- How green a tile is, measured off the atlas: green minus the mean of
-- red and blue, averaged over its 64 pixels.  Leaves score high, fence
-- posts and dirt paths score at or below zero.
local function greenness(map, tex, tiles)
  local data = nil
  local ok = pcall(function()
    if tex.newImageData then data = tex:newImageData()
    elseif tex.getData then data = tex:getData() end
  end)
  if not (ok and data) then return nil end
  local ts = map.tileset or {}
  local perRow = ts.tilesPerRow or 16
  local dw, dh = data:getWidth(), data:getHeight()
  local out = {}
  for _, tile in ipairs(tiles) do
    local ax = (tile % perRow) * 8
    local ay = math.floor(tile / perRow) * 8
    if ax + 8 <= dw and ay + 8 <= dh then
      local sum, n = 0, 0
      for y = 0, 7 do
        for x = 0, 7 do
          local okP, r, g, b = pcall(function()
            local rr, gg, bb = data:getPixel(ax + x, ay + y)
            return rr, gg, bb
          end)
          if okP and g then
            sum = sum + (g - (r + b) / 2)
            n = n + 1
          end
        end
      end
      out[tile] = (n > 0) and (sum / n) or -1
    end
  end
  pcall(function() data:release() end)
  return out
end



-- Shared by what works across a boundary: the neighbouring-map draws,
-- the distance haze and the backs of buildings.
local MOUND = {}

-- NEIGHBOURING MAPS.
-- Dramatic Shape already meshes and draws the maps either side of you --
-- but every feature in this module was built for state.map alone, so
-- mountains, grass and canopy stopped dead at the boundary and appeared
-- the moment you crossed it.  That is the popping.  These build the same
-- geometry for each neighbour and draw it at the neighbour's offset,
-- exactly as the terrain is drawn.
--
-- Caches are per MAP rather than a single slot, so a neighbour's mesh is
-- built once and kept for as long as it stays next door.
MOUND.tufts, MOUND.seen = {}, {}

-- ------- THE BACKS OF BUILDINGS.
-- The mesher extrudes a building cell as a box and wears the same tile
-- on every face, so a shopfront's door and windows appear again on the
-- back wall -- false doors all over Kanto, leading nowhere.
--
-- A building's SIDE tile is the honest one: plain wall, which is what a
-- back wall is.  For every building cell whose north face is exposed, a
-- quad of the side tile is laid a hair proud of it.  Fronts are left
-- alone: a shopfront should look like a shopfront.
MOUND.BACKS = { cache = {}, EPS = 0.35 }

-- ------- TRUNKS.
-- The patcher lifts every tree-class bush onto empty air (Structures
-- tags the stamp, the mesher raises it); these are the trunks that go
-- underneath. Same hash as the splice -- (cx * 73856093 + cy * 19349663)
-- % 3 -- so each trunk meets its own bush's base exactly. Tree cells are
-- found the way the engine finds them: TileShape's authored `tree`
-- class, sampled at the cell's canonical bottom-left tile. Drawn as two
-- crossed quads of generated bark, with a short branch on every third
-- tree.
MOUND.TRUNK = { cache = {}, nbcache = {}, img = nil }
do
  local okTS, TS = pcall(V.require, "TileShape")
  MOUND.TRUNK.ts = okTS and TS or nil
end

-- WHICH TILES a round object is drawn from decides what it IS. The
-- palette theory died on a route: the grey rounds there are grey under a
-- GREEN palette, because they are a different DRAWING -- the border-wall
-- cell (tiles 64/65/80/81 on OVERWORLD), not the lone canopy
-- (42/43/58/59). Dramatic Shape pins both into its cylinder pool, but
-- they are distinct authored tile ids, and the ids are the exact,
-- per-cell delineator that was wanted from the start. The gym rock
-- (44-47 over 7/8/23/24) is authored as boulders outright.
-- (Swapped from the first cut: in the shipped art the border-wall
-- drawing is the GREEN tree rows and the lone-canopy drawing is the
-- grey rock -- playtest beats archaeology.)
MOUND.BOULDER_TILES = {
  OVERWORLD = { [42] = true, [43] = true, [58] = true, [59] = true },
  GYM = { [44] = true, [45] = true, [46] = true, [47] = true,
          [7] = true, [8] = true, [23] = true, [24] = true },
}
-- and the TREES, named explicitly so the union below is complete
MOUND.TREE_TILES = {
  OVERWORLD = { [64] = true, [65] = true, [80] = true, [81] = true },
}
-- GHOST FILTER. Registry entries have appeared for cells that carry no
-- round drawing at all -- bare trunks standing on pathways, clustered
-- at map-section seams. Whatever publishes them, a support is only
-- deserved where the cell's own tile is a KNOWN round id (tree set or
-- boulder set). Where a tileset has no curated sets, the registry is
-- trusted as-is, so uncatalogued tilesets lose nothing.
function MOUND.roundUnion(tsid)
  local b, t = MOUND.BOULDER_TILES[tsid], MOUND.TREE_TILES[tsid]
  if not (b or t) then return nil end
  local u = {}
  for k in pairs(b or {}) do u[k] = true end
  for k in pairs(t or {}) do u[k] = true end
  return u
end
-- the registry of REAL stamps, filled by the Structures splice as each
-- chunk meshes: cell key -> the exact lift the mesher applied. Building
-- from this instead of re-deriving cells makes a support on a walkable
-- path impossible by construction, and the heights can never drift.
_G.__ds_round_cells = rawget(_G, "__ds_round_cells") or {}
-- each lifted stamp's TRUE base, published by the mesher: DS bakes the
-- cell's terrain height into the stamp template, so a bush on a ledge
-- terrace sits at terrain + lift -- while supports rooted at y=0
-- detached from their bushes on every terrace. THAT was the ghost: a
-- short stem at ground level, its canopy floating at terrace height.
_G.__ds_round_base = rawget(_G, "__ds_round_base") or {}

function MOUND.stoneImg()
  local T = MOUND.TRUNK
  if T.stone ~= nil then return T.stone or nil end
  local ok, img = pcall(function()
    local W, H = 12, 24
    local data = love.image.newImageData(W, H)
    local DARK = { 0.30, 0.30, 0.33 }
    local MID  = { 0.52, 0.52, 0.55 }
    local LITE = { 0.68, 0.68, 0.70 }
    for y = 0, H - 1 do
      for x = 0, W - 1 do
        local c = MID
        if x == 0 or x == W - 1 or y == 11 or y == 12 then c = DARK
        elseif (x * 5 + y * 3) % 11 == 0 then c = DARK
        elseif (x * 2 + y * 7) % 9 == 0 then c = LITE end
        data:setPixel(x, y, c[1], c[2], c[3], 1)
      end
    end
    local i = love.graphics.newImage(data)
    i:setFilter("nearest", "nearest")
    return i
  end)
  T.stone = (ok and img) or false
  return T.stone or nil
end

-- the leafy skin the BOULDER TREES canopy wears: two greens in a
-- coarse checker with dark pits, cut to read as voxel foliage at the
-- same crunch as the map's own trees
-- the shadow blob: a radial falloff into transparency, drawn dark
function MOUND.shadowImg()
  local T = MOUND.TRUNK
  if T.simg ~= nil then return T.simg or nil end
  local ok, img = pcall(function()
    local W = 16
    local data = love.image.newImageData(W, W)
    for y = 0, W - 1 do
      for x = 0, W - 1 do
        local dx, dy = (x + 0.5) / W - 0.5, (y + 0.5) / W - 0.5
        local d = math.sqrt(dx * dx + dy * dy) * 2
        local a = math.max(0, 1 - d)
        data:setPixel(x, y, 0, 0, 0, a * a * 0.55)
      end
    end
    local i = love.graphics.newImage(data)
    i:setFilter("linear", "linear")
    return i
  end)
  T.simg = (ok and img) or false
  return T.simg or nil
end

function MOUND.leafyImg()
  local T = MOUND.TRUNK
  if T.limg ~= nil then return T.limg or nil end
  local ok, img = pcall(function()
    local W, H = 8, 8
    local data = love.image.newImageData(W, H)
    local DK = { 0.16, 0.36, 0.14 }
    local MD = { 0.26, 0.52, 0.20 }
    local LT = { 0.42, 0.68, 0.28 }
    for y = 0, H - 1 do
      for x = 0, W - 1 do
        local c = ((x + y) % 2 == 0) and MD or LT
        if (x * 5 + y * 3) % 11 == 0 then c = DK end
        data:setPixel(x, y, c[1], c[2], c[3], 1)
      end
    end
    local i = love.graphics.newImage(data)
    i:setFilter("nearest", "nearest")
    -- REPEAT, or any UV past 1 clamp-smears the edge texels into long
    -- streaks -- the plaid banding 1.58.1 shipped was exactly that
    i:setWrap("repeat", "repeat")
    return i
  end)
  T.limg = (ok and img) or false
  return T.limg or nil
end

function MOUND.barkImg()
  local T = MOUND.TRUNK
  if T.img ~= nil then return T.img or nil end
  local ok, img = pcall(function()
    local W, H = 8, 32
    local data = love.image.newImageData(W, H)
    local DARK = { 0.28, 0.19, 0.11 }
    local MID  = { 0.42, 0.29, 0.16 }
    local LITE = { 0.55, 0.40, 0.22 }
    for y = 0, H - 1 do
      for x = 0, W - 1 do
        local c = MID
        if x == 0 or x == W - 1 then c = DARK
        elseif (x + math.floor(y / 3)) % 4 == 0 then c = DARK
        elseif (x * 3 + y) % 7 == 0 then c = LITE end
        data:setPixel(x, y, c[1], c[2], c[3], 1)
      end
    end
    local i = love.graphics.newImage(data)
    i:setFilter("nearest", "nearest")
    return i
  end)
  T.img = (ok and img) or false
  return T.img or nil
end

-- HOW A STEM PROVES ITS CANOPY WAS DRAWN. Registry entries are published
-- when Structures CREATES a stamp -- but ChunkMesher decides later
-- whether the stamp is ever MESHED, and two of its rules discard stamps
-- outright: ring stamps wholly buried under a connected neighbour's
-- body rect (skipAll = containedInMask) and, in body-only builds, every
-- ring stamp. A discarded stamp draws no round object, so its stem
-- stands bare on whatever the neighbour draws there -- which at a
-- connection is the walkway. THOSE are the seam ghosts on pathways.
--
-- Two gates, both replicas of facts the mesher already established, so
-- neither can strand a drawn canopy:
--   1. the MASK GATE re-runs the mesher's own containment test (same
--      rects, same not-over-body condition): a stamp the full build
--      provably skipped gets no stem, full stop.
--   2. the BASE GATE requires the stamp's __ds_round_base entry, which
--      is written ONLY inside the mesher's quad expansion -- a stamp
--      that was never expanded never wrote one. Entries land when the
--      async full build does, so the cache watches the base count and
--      rebuilds as they arrive (late stems pop in with their trees,
--      exactly as the trees themselves do).
function MOUND.buildTrunks(map, nbRects)
  MOUND.TRUNK.tN, MOUND.TRUNK.bN, MOUND.TRUNK.cells = 0, 0, {}
  local bw = ((map.def or {}).width or 0) * 32
  local bh = ((map.def or {}).height or 0) * 32
  local function buriedUnderNeighbour(mx, mz)
    local sx0, sz0, sx1, sz1 = mx - 8, mz - 8, mx + 8, mz + 8
    -- the mesher only skips stamps NOT over the body; match it exactly
    if sx1 > 0 and sx0 < bw and sz1 > 0 and sz0 < bh then return false end
    for _, mk in ipairs(nbRects or {}) do
      if sx0 >= mk[1] and sx1 <= mk[3]
         and sz0 >= mk[2] and sz1 <= mk[4] then
        return true
      end
    end
    return false
  end
  -- the engine reuses ONE map object across transitions, so the
  -- registry is keyed by the map's stable id -- the same derivation the
  -- splice uses. Keying by the object merged every map into one bucket,
  -- and crossing a connection rained the previous map's cells onto the
  -- new one as ghost stems until remeshes caught up.
  local rk = map.id or (map.def and map.def.id) or map
  local reg = (rawget(_G, "__ds_round_cells") or {})[rk] or {}
  local cfgTrunk = config() or {}
  local tsid = tostring((map.def or {}).tileset or "")
  local boulderSet = MOUND.BOULDER_TILES[tsid] or {}
  local tV, tI, tQ = {}, {}, 0
  local sV, sI, sQ = {}, {}, 0
  local cV, cI, cQ = {}, {}, 0
  local shV, shI, shQ = {}, {}, 0
  -- BLOB SHADOWS (toggleable): a soft dark square under every raised
  -- object, a whisker above the ground so it never z-fights. Cheapest
  -- possible grounding -- one quad each -- and the difference between
  -- floating and standing is entirely this quad.
  local function blob(bx, bz, by, half)
    if cfgTrunk.shadows == false then return end
    shV[#shV + 1] = { bx - half, by, bz - half, 0, 0, 1 }
    shV[#shV + 1] = { bx + half, by, bz - half, 1, 0, 1 }
    shV[#shV + 1] = { bx + half, by, bz + half, 1, 1, 1 }
    shV[#shV + 1] = { bx - half, by, bz + half, 0, 1, 1 }
    Voxel3D.pushQuad(shI, shQ)
    shQ = shQ + 1
  end
  local count = 0
  for key, lift in pairs(reg) do
    local cx, cy = key:match("^(-?%d+)|(-?%d+)$")
    cx, cy = tonumber(cx), tonumber(cy)
    if cx and cy and lift and lift > 0 then
      local okT, tile = pcall(function()
        if map.cellTile then return map:cellTile(cx, cy) end
        return map:tileAt(cx * 2, cy * 2 + 1)
      end)
      local union = MOUND.roundUnion(tsid)
      if union and not (okT and tile and union[tile]) then
        -- a ghost: stamped, but the cell draws no round object
        goto continue
      end
      -- (The CONNECTION-BAND suppression that lived here from 1.45.7 is
      -- retired. It was a tourniquet for the seam ghosts, whose real
      -- causes -- the shared-object registry, group supersession, and
      -- above all supports rooted at flat ground under terraced stamps
      -- -- were each fixed properly afterwards. With those fixes in
      -- place the band rule only starved LEGITIMATE seam rows of their
      -- stems, leaving floating rounds along every connected edge. The
      -- walkability gate below still keeps path-overlay cells bare.)
      -- THE WALKABILITY TEST, which cannot be lied to. Near connection
      -- seams the base map data is padded with the border TREE block and
      -- the overlay draws path on top -- so the tile id says "tree"
      -- while the player strolls across it, which is exactly the ghost
      -- rows on pathways. Collision has to match what the player can
      -- actually do, so it tells the truth where the tile does not: a
      -- real tree is never walkable, a path always is. Out-of-bounds
      -- ring and strip cells return not-walkable and keep their trees.
      do
        local okW, wk = pcall(function()
          return map:isWalkableCell(cx, cy)
        end)
        if okW and wk then goto continue end
      end
      -- MASK GATE: the mesher discarded this stamp under a neighbour's
      -- body, so its canopy was never drawn -- the seam ghost exactly
      if buriedUnderNeighbour(cx * 16 + 8, cy * 16 + 8) then
        goto continue
      end
      -- BASE GATE: no base entry means the full build never expanded
      -- this stamp's quads -- no drawn round, no stem. A build still in
      -- flight lands its entries shortly and the cache's base count
      -- triggers the rebuild that grows the stem then.
      local base = (rawget(_G, "__ds_round_base") or {})
                   [rk .. ":" .. (cx * 16 + 8) .. "|" .. (cy * 16 + 8)]
      if base == nil then goto continue end
      local boulder = okT and tile and boulderSet[tile] or false
      -- BOULDER TREES (off by default): every lifted round grows a
      -- bark trunk, and the rock itself turns GREEN -- a leafy hood, a
      -- slightly oversize five-faced cap drawn snug over the lifted
      -- round so the boulder art underneath never shows. With the
      -- trunk beneath and leaves falling, the whole object IS a tree.
      local hood = false
      if cfgTrunk.bouldertrees == true and boulder then
        boulder, hood = false, true
      end
      if boulder then
        MOUND.TRUNK.bN = (MOUND.TRUNK.bN or 0) + 1
      else
        MOUND.TRUNK.tN = (MOUND.TRUNK.tN or 0) + 1
      end
      MOUND.TRUNK.cells[#MOUND.TRUNK.cells + 1] =
        { cx, cy, boulder and "b" or "t",
          -- the crown's underside, where a leaf lets go
          (not boulder) and (base + lift + 3) or nil }
      local mx, mz = cx * 16 + 8, cy * 16 + 8
      blob(mx, mz, base + 0.35, boulder and 6.5 or 8.5)
      if hood then
        -- THE HOOD, second attempt: not a slab but a stepped voxel
        -- canopy -- three tiers, wide in the middle and inset above,
        -- the silhouette the map's own trees carry. UVs are locked to
        -- the world grid at one texel per world unit (span/8 repeats
        -- of the 8px leaf image), so the pattern reads as voxel
        -- foliage instead of stretching into plaid, and each tier's
        -- sides shade differently so the steps catch light. A per-cell
        -- hash nudges the whole crown's brightness so a grove is not
        -- one green wall.
        local tone = 0.92 + 0.12 * hash01(cx, cy, 211)
        local y0 = base + lift - 1
        local function tier(hw2, ty0, ty1)
          local cs = { { mx - hw2, mz - hw2 }, { mx + hw2, mz - hw2 },
                       { mx + hw2, mz + hw2 }, { mx - hw2, mz + hw2 } }
          local rep = hw2 * 2 / 8
          local vrep = (ty1 - ty0) / 8
          for i = 1, 4 do
            local a, b = cs[i], cs[i % 4 + 1]
            local sh = ((i == 1 or i == 4) and 1 or 0.82) * tone
            cV[#cV + 1] = { b[1], ty1, b[2], rep, 0, sh }
            cV[#cV + 1] = { a[1], ty1, a[2], 0, 0, sh }
            cV[#cV + 1] = { a[1], ty0, a[2], 0, vrep, sh }
            cV[#cV + 1] = { b[1], ty0, b[2], rep, vrep, sh }
            Voxel3D.pushQuad(cI, cQ)
            cQ = cQ + 1
          end
          cV[#cV + 1] = { mx - hw2, ty1, mz - hw2, 0, 0, 1.06 * tone }
          cV[#cV + 1] = { mx + hw2, ty1, mz - hw2, rep, 0, 1.06 * tone }
          cV[#cV + 1] = { mx + hw2, ty1, mz + hw2, rep, rep, 1.06 * tone }
          cV[#cV + 1] = { mx - hw2, ty1, mz + hw2, 0, rep, 1.06 * tone }
          Voxel3D.pushQuad(cI, cQ)
          cQ = cQ + 1
        end
        tier(7.6, y0, y0 + 5)          -- underside, tucked in
        tier(9.2, y0 + 4, y0 + 12)     -- the full waist
        tier(6.4, y0 + 11, y0 + 16)    -- the inset cap
      end
      if boulder then
        -- SOLID: a four-sided box in two courses, wide below, narrower
        -- above -- a stack of stones, not a panel
        local function box(w, y0, y1, v0, v1)
          local c = { { mx - w, mz - w }, { mx + w, mz - w },
                      { mx + w, mz + w }, { mx - w, mz + w } }
          for i = 1, 4 do
            local a, b = c[i], c[i % 4 + 1]
            sV[#sV + 1] = { b[1], y1, b[2], 1, v0, 1 }
            sV[#sV + 1] = { a[1], y1, a[2], 0, v0, 1 }
            sV[#sV + 1] = { a[1], y0, a[2], 0, v1, 1 }
            sV[#sV + 1] = { b[1], y0, b[2], 1, v1, 1 }
            Voxel3D.pushQuad(sI, sQ)
            sQ = sQ + 1
          end
        end
        box(4.5, base, base + lift * 0.55, 0.5, 1)
        box(3.2, base + lift * 0.55, base + lift + 2, 0.05, 0.48)
      else
        local HW = 2.5
        for _, axis in ipairs({ "x", "z" }) do
          local x0, z0, x1, z1
          if axis == "x" then
            x0, z0, x1, z1 = mx - HW, mz, mx + HW, mz
          else
            x0, z0, x1, z1 = mx, mz - HW, mx, mz + HW
          end
          for _, flip in ipairs({ false, true }) do
            local ax0, az0, ax1, az1 = x0, z0, x1, z1
            if flip then ax0, az0, ax1, az1 = x1, z1, x0, z0 end
            tV[#tV + 1] = { ax1, base + lift + 3, az1, 1, 0, 1 }
            tV[#tV + 1] = { ax0, base + lift + 3, az0, 0, 0, 1 }
            tV[#tV + 1] = { ax0, base, az0, 0, 1, 1 }
            tV[#tV + 1] = { ax1, base, az1, 1, 1, 1 }
            Voxel3D.pushQuad(tI, tQ)
            tQ = tQ + 1
          end
        end
        if (cx * 73856093 + cy * 19349663) % 3 == 2 then
          local by = base + lift * 0.6
          for _, w in ipairs({ { 0.2, 0.5 }, { 0.5, 0.2 } }) do
            tV[#tV + 1] = { mx + 7, by + 4, mz, 1, w[1], 1 }
            tV[#tV + 1] = { mx + 1, by, mz, 0, w[1], 1 }
            tV[#tV + 1] = { mx + 1, by - 1.2, mz, 0, w[2], 1 }
            tV[#tV + 1] = { mx + 7, by + 2.8, mz, 1, w[2], 1 }
            Voxel3D.pushQuad(tI, tQ)
            tQ = tQ + 1
          end
        end
      end
      count = count + 1
      ::continue::
    end
  end
  local shm = shQ > 0 and Voxel3D.newMesh(shV, shI) or nil
  local cm2 = cQ > 0 and Voxel3D.newMesh(cV, cI) or nil
  local tm = tQ > 0 and Voxel3D.newMesh(tV, tI) or nil
  local sm = sQ > 0 and Voxel3D.newMesh(sV, sI) or nil
  if not (tm or sm) then return nil end
  return tm, sm, count, cm2, shm
end

-- ------- MOUNTAIN PEAKS.
-- The rock walls of the routes are authored: on OVERWORLD the mound
-- drawing is `wall = { 2, 36 }` in Dramatic Shape's own tables -- "the
-- rock pillar, the plateau body". Where those cells run in CLUSTERS,
-- this stacks further courses of the same rock on top, rising toward
-- the cluster's interior like a massif: each cell's height grows with
-- its distance from the cluster's edge, so rims stay low and hearts
-- peak. Every face is textured with the cell's OWN subtiles, band by
-- band, so the drawn rock simply continues upward.
--
-- The gate stack, in the order the ghosts taught: authored tile id AND
-- authored upright class AND not walkable AND outdoors AND not in a
-- connection band. No stamps, no registry -- this derives from stable
-- map data alone.
-- Retuned after the community review (issue thread): the massif now
-- BLANKETS its cluster -- every rock cell carries at least two courses
-- so the yellow-hued ranges read as solid mountains rather than
-- scattered spires, at the cost of some horizon (their words: worth
-- it). MIN drops so small outcrops join in; REACH drops and the
-- building veto widens so no structure ever inherits rock again.
MOUND.PEAK = { cache = {}, BAND = 16, STEP = 4, CAP = 12, MIN = 2,
               REACH = 2 }
MOUND.PEAK_TILES = {
  OVERWORLD = { [2] = true, [36] = true },
}

function MOUND.buildPeaks(map)
  local wc, hc = map.widthCells or 0, map.heightCells or 0
  if wc == 0 or hc == 0 or not MOUND.TRUNK.ts then return nil end
  local pool = MOUND.PEAK_TILES[tostring((map.def or {}).tileset or "")]
  if not pool then return nil end
  local okSh, shapes = pcall(MOUND.TRUNK.ts.forMap, map)
  if not (okSh and shapes) then return nil end
  local conn = (map.def or {}).connections or {}
  local RING = 2
  local rock, order = {}, {}
  for cy = -RING, hc - 1 + RING do
    for cx = -RING, wc - 1 + RING do
      local banded = (conn.north and cy < 2)
                     or (conn.south and cy > hc - 3)
                     or (conn.west and cx < 2)
                     or (conn.east and cx > wc - 3)
      if not banded then
        local okT, tile = pcall(function()
          if map.cellTile then return map:cellTile(cx, cy) end
          return map:tileAt(cx * 2, cy * 2 + 1)
        end)
        -- EVERY upright, unwalkable cell is a candidate; whether it
        -- joins depends on the pool. Seeds are authored pool ids; the
        -- SAME massif often runs two materials (the dark check and the
        -- light orange), so contiguous candidates within REACH of a
        -- seed join too -- the cluster vouches for them. A building
        -- cannot join: walkable ground separates it, and even direct
        -- wall contact leaks at most REACH cells before the cap bites.
        if okT and tile then
          local okC, sh = pcall(MOUND.TRUNK.ts.at, map, shapes, tile,
                                cx * 2, cy * 2 + 1)
          if okC and sh and (sh.class == "wall" or sh.class == "cliff")
          then
            local okW, wk = pcall(function()
              return map:isWalkableCell(cx, cy)
            end)
            if not (okW and wk) then
              -- BUILDING VETO: a candidate touching a roof-class cell
              -- or a door is a building's wall, not rock -- the Poke
              -- Center wore a summit for three cells of flood reach.
              -- Seeds (authored rock ids) are immune; only the flooded
              -- second material must prove itself.
              local veto = false
              -- SEEDS answer to roofs now as well (Celadon report:
              -- authored rock ids appear in city drawings, so seed
              -- immunity let structures wear stone). Doors still only
              -- veto the flooded material -- a cave mouth's door sits
              -- against real cliff and must not bald it.
              do
                for dy = -2, 2 do
                  for dx = -2, 2 do
                    if not veto and (dx ~= 0 or dy ~= 0) then
                      local okN, t2 = pcall(function()
                        if map.cellTile then
                          return map:cellTile(cx + dx, cy + dy)
                        end
                        return map:tileAt((cx + dx) * 2,
                                          (cy + dy) * 2 + 1)
                      end)
                      if okN and t2 then
                        local okC2, s2 = pcall(MOUND.TRUNK.ts.at, map,
                          shapes, t2, (cx + dx) * 2, (cy + dy) * 2 + 1)
                        if okC2 and s2 and s2.class == "roof" then
                          veto = true
                        end
                      end
                    end
                  end
                end
              end
              if not veto and not pool[tile] then
                for dy = -2, 2 do
                  for dx = -2, 2 do
                    if not veto and (dx ~= 0 or dy ~= 0) then
                      local okN, t2 = pcall(function()
                        if map.cellTile then
                          return map:cellTile(cx + dx, cy + dy)
                        end
                        return map:tileAt((cx + dx) * 2,
                                          (cy + dy) * 2 + 1)
                      end)
                      if okN and t2 then
                        local okC2, s2 = pcall(MOUND.TRUNK.ts.at, map,
                          shapes, t2, (cx + dx) * 2, (cy + dy) * 2 + 1)
                        if okC2 and s2 and s2.class == "roof" then
                          veto = true
                        end
                      end
                      local okD, dr = pcall(function()
                        return map.isDoorTileCell
                               and map:isDoorTileCell(cx + dx, cy + dy)
                      end)
                      if okD and dr then veto = true end
                    end
                  end
                end
              end
              if not veto then
                local key = cx .. "|" .. cy
                rock[key] = { cx = cx, cy = cy, top = (sh.h or 16),
                              seed = pool[tile] or nil }
                order[#order + 1] = key
              end
            end
          end
        end
      end
    end
  end
  -- keep candidates within REACH of a pool seed; drop the rest
  do
    local fr, seen = {}, {}
    for key, c in pairs(rock) do
      if c.seed then c.reach = 0; fr[#fr + 1] = key; seen[key] = true end
    end
    local h2 = 1
    while fr[h2] do
      local c = rock[fr[h2]]
      h2 = h2 + 1
      if c.reach < MOUND.PEAK.REACH then
        for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
          local nk = (c.cx + d[1]) .. "|" .. (c.cy + d[2])
          local nc = rock[nk]
          if nc and not seen[nk] then
            seen[nk] = true
            nc.reach = c.reach + 1
            fr[#fr + 1] = nk
          end
        end
      end
    end
    local kept = {}
    for _, key in ipairs(order) do
      if seen[key] then kept[#kept + 1] = key else rock[key] = nil end
    end
    order = kept
  end
  if #order < MOUND.PEAK.MIN then return nil end

  -- distance to the cluster edge, by BFS from every rim cell inward:
  -- a rim cell is one with a missing neighbour
  local frontier = {}
  for key, c in pairs(rock) do
    local n = 0
    for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
      if rock[(c.cx + d[1]) .. "|" .. (c.cy + d[2])] then n = n + 1 end
    end
    if n < 4 then
      c.dist = 0
      frontier[#frontier + 1] = key
    end
  end
  local head = 1
  while frontier[head] do
    local c = rock[frontier[head]]
    head = head + 1
    for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
      local nk = (c.cx + d[1]) .. "|" .. (c.cy + d[2])
      local nc = rock[nk]
      if nc and nc.dist == nil then
        nc.dist = c.dist + 1
        frontier[#frontier + 1] = nk
      end
    end
  end

  -- extra bands above the drawn wall: rims get a little, hearts a lot,
  -- with a per-cell jitter so ridgelines are not staircases
  -- THE LINTEL. A door cell flanked by cluster rock on opposite sides
  -- is a CAVE MOUTH -- Mt. Moon's entrance -- and skipping it (doors
  -- are walkable) notched a slot of sky through the massif. Rock now
  -- bridges over it: the bridge's underside sits one band above the
  -- wall top so the doorway stays open, and its summit follows the
  -- lower of its two shoulders.
  do
    local adds = {}
    for cy = -RING, hc - 1 + RING do
      for cx = -RING, wc - 1 + RING do
        if not rock[cx .. "|" .. cy] then
          local okD, dr = pcall(function()
            return map.isDoorTileCell and map:isDoorTileCell(cx, cy)
          end)
          if okD and dr then
            local L = rock[(cx - 1) .. "|" .. cy]
            local R = rock[(cx + 1) .. "|" .. cy]
            local U = rock[cx .. "|" .. (cy - 1)]
            local D = rock[cx .. "|" .. (cy + 1)]
            local a, b = nil, nil
            if L and R then a, b = L, R
            elseif U and D then a, b = U, D end
            if a and b then
              adds[#adds + 1] = {
                key = cx .. "|" .. cy, cx = cx, cy = cy,
                top = math.min(a.top, b.top) + MOUND.PEAK.BAND,
                bridge = true,
                dist = math.min(a.dist or 0, b.dist or 0),
                shoulders = math.min(a.top, b.top),
              }
            end
          end
        end
      end
    end
    for _, c in ipairs(adds) do
      rock[c.key] = c
      order[#order + 1] = c.key
    end
  end

  -- JAGGED: distance gives the massif its profile, a strong per-cell
  -- jitter breaks the staircase, and an occasional spire punches past
  -- both -- so ridgelines read as rock, not battlements
  for _, c in pairs(rock) do
    local d = c.dist or 0
    local h1 = (c.cx * 73856093 + c.cy * 19349663) % 4
    local h2 = (c.cx * 2654435761 + c.cy * 40503) % 7
    local spire = (h2 == 0) and 3 or 0
    c.bands = math.min(2 + d * MOUND.PEAK.STEP + h1 + spire,
                       MOUND.PEAK.CAP)
    c.high = c.top + c.bands * MOUND.PEAK.BAND
  end
  -- a bridge never overtops its shoulders
  for _, c in pairs(rock) do
    if c.bridge then
      for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local nc = rock[(c.cx + d[1]) .. "|" .. (c.cy + d[2])]
        if nc and not nc.bridge then
          c.high = math.min(c.high, nc.high)
        end
      end
      if c.high < c.top + MOUND.PEAK.BAND then
        c.high = c.top + MOUND.PEAK.BAND
      end
    end
  end

  local verts, indexMap, quads = {}, {}, 0
  local function faceQuads(cx, cy, y0, y1, side)
    -- one band of one face, as four 8px subtile quads (two columns,
    -- two rows) so the rock art continues at true scale
    local x0, z0 = cx * 16, cy * 16
    for sy = 0, 1 do
      for sx = 0, 1 do
        local okS, t = pcall(function()
          return map:tileAt(cx * 2 + sx, cy * 2 + sy)
        end)
        if okS and t then
          local uv = { uvFor(map, t) }
          local yT = y1 - sy * 8
          local yB = yT - 8
          local a, b
          if side == "n" then
            a = { x0 + 8 + sx * 8, z0 }
            b = { x0 + sx * 8, z0 }
          elseif side == "s" then
            a = { x0 + sx * 8, z0 + 16 }
            b = { x0 + 8 + sx * 8, z0 + 16 }
          elseif side == "w" then
            a = { x0, z0 + sx * 8 }
            b = { x0, z0 + 8 + sx * 8 }
          else
            a = { x0 + 16, z0 + 8 + sx * 8 }
            b = { x0 + 16, z0 + sx * 8 }
          end
          for _, flip in ipairs({ false, true }) do
            local p, q = a, b
            if flip then p, q = b, a end
            verts[#verts + 1] = { p[1], yT, p[2], uv[1], uv[3], 0.85 }
            verts[#verts + 1] = { q[1], yT, q[2], uv[2], uv[3], 0.85 }
            verts[#verts + 1] = { q[1], yB, q[2], uv[2], uv[4], 0.85 }
            verts[#verts + 1] = { p[1], yB, p[2], uv[1], uv[4], 0.85 }
            Voxel3D.pushQuad(indexMap, quads)
            quads = quads + 1
          end
        end
      end
    end
  end
  for _, key in ipairs(order) do
    local c = rock[key]
    -- exposed side faces, band by band, down to each neighbour's height
    for _, d in ipairs({ { 1, 0, "e" }, { -1, 0, "w" },
                         { 0, 1, "s" }, { 0, -1, "n" } }) do
      local nc = rock[(c.cx + d[1]) .. "|" .. (c.cy + d[2])]
      local floor2 = nc and nc.high or c.top
      local y = c.high
      while y > floor2 + 0.01 do
        faceQuads(c.cx, c.cy, y - MOUND.PEAK.BAND, y, d[3])
        y = y - MOUND.PEAK.BAND
      end
    end
    -- a bridge's UNDERSIDE: the doorway's ceiling, in the same art
    if c.bridge then
      local x0, z0 = c.cx * 16, c.cy * 16
      for sy = 0, 1 do
        for sx = 0, 1 do
          local okS, t = pcall(function()
            return map:tileAt(c.cx * 2 + sx, c.cy * 2 + sy)
          end)
          if okS and t then
            local uv = { uvFor(map, t) }
            local qx, qz = x0 + sx * 8, z0 + sy * 8
            verts[#verts + 1] = { qx, c.top, qz, uv[2], uv[3], 0.7 }
            verts[#verts + 1] = { qx + 8, c.top, qz, uv[1], uv[3], 0.7 }
            verts[#verts + 1] = { qx + 8, c.top, qz + 8, uv[1], uv[4], 0.7 }
            verts[#verts + 1] = { qx, c.top, qz + 8, uv[2], uv[4], 0.7 }
            Voxel3D.pushQuad(indexMap, quads)
            quads = quads + 1
          end
        end
      end
    end
    -- SUMMIT KNOB: a cell overtopping all four neighbours (and off the
    -- rim) carries one more inset block -- half footprint, one band --
    -- so ridgelines break into actual peaks instead of level mesas
    if (c.dist or 0) >= 1 then
      local summit = true
      for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local nc = rock[(c.cx + d[1]) .. "|" .. (c.cy + d[2])]
        if nc and nc.high >= c.high then summit = false end
      end
      if summit then
        local x0k, z0k = c.cx * 16 + 4, c.cy * 16 + 4
        local okS, t = pcall(function()
          return map:tileAt(c.cx * 2, c.cy * 2)
        end)
        if okS and t then
          local uv = { uvFor(map, t) }
          local kt = c.high + MOUND.PEAK.BAND * 0.75
          local cs = { { x0k, z0k }, { x0k + 8, z0k },
                       { x0k + 8, z0k + 8 }, { x0k, z0k + 8 } }
          for i = 1, 4 do
            local a, b = cs[i], cs[i % 4 + 1]
            verts[#verts + 1] = { b[1], kt, b[2], uv[1], uv[3], 0.72 }
            verts[#verts + 1] = { a[1], kt, a[2], uv[2], uv[3], 0.72 }
            verts[#verts + 1] = { a[1], c.high, a[2], uv[2], uv[4], 0.72 }
            verts[#verts + 1] = { b[1], c.high, b[2], uv[1], uv[4], 0.72 }
            Voxel3D.pushQuad(indexMap, quads)
            quads = quads + 1
          end
          verts[#verts + 1] = { x0k, kt, z0k, uv[1], uv[3], 0.9 }
          verts[#verts + 1] = { x0k + 8, kt, z0k, uv[2], uv[3], 0.9 }
          verts[#verts + 1] = { x0k + 8, kt, z0k + 8, uv[2], uv[4], 0.9 }
          verts[#verts + 1] = { x0k, kt, z0k + 8, uv[1], uv[4], 0.9 }
          Voxel3D.pushQuad(indexMap, quads)
          quads = quads + 1
        end
      end
    end
    -- the cap, in the cell's own art
    local x0, z0 = c.cx * 16, c.cy * 16
    for sy = 0, 1 do
      for sx = 0, 1 do
        local okS, t = pcall(function()
          return map:tileAt(c.cx * 2 + sx, c.cy * 2 + sy)
        end)
        if okS and t then
          local uv = { uvFor(map, t) }
          local qx, qz = x0 + sx * 8, z0 + sy * 8
          verts[#verts + 1] = { qx + 8, c.high, qz, uv[1], uv[3], 1 }
          verts[#verts + 1] = { qx, c.high, qz, uv[2], uv[3], 1 }
          verts[#verts + 1] = { qx, c.high, qz + 8, uv[2], uv[4], 1 }
          verts[#verts + 1] = { qx + 8, c.high, qz + 8, uv[1], uv[4], 1 }
          Voxel3D.pushQuad(indexMap, quads)
          quads = quads + 1
        end
      end
    end
  end
  if quads == 0 then return nil end
  return Voxel3D.newMesh(verts, indexMap), #order
end

-- ------- THE APRON.
-- The map is a plateau with nothing past its rim: the eye sees a
-- paper-thin edge and then void, all the way to the painted backdrop,
-- and the world reads as SMALL. This continues each boundary cell's own
-- tile outward, ring by ring, stepping gently down and fading with the
-- same haze the neighbour maps use -- grass runs on as grass, water as
-- water, because the tile IS the edge it extends. Built once per map as
-- a single mesh from the atlas already bound: no new textures, a few
-- hundred quads, memory cost as near nothing as makes no difference.
--
-- It sits a shade BELOW true ground, so real terrain -- and Dramatic
-- Shape's own neighbour-map meshes on the connected sides -- always draw
-- over it. No seams to manage, no need to know which sides connect.
MOUND.APRON = { cache = {}, RINGS = 14, DROP = 2.5, SINK = 2 }

function MOUND.buildApron(map)
  local wc, hc = map.widthCells or 0, map.heightCells or 0
  if wc == 0 or hc == 0 then return nil end
  local function tileAtCell(cx, cy)
    local ok, t = pcall(function()
      if map.cellTile then return map:cellTile(cx, cy) end
      return map:tileAt(cx * 2, cy * 2 + 1)
    end)
    return ok and t or nil
  end
  local function isWater(cx, cy)
    local ok, w = pcall(function() return map:isWaterCell(cx, cy) end)
    return ok and w
  end
  local function isWalk(cx, cy)
    local ok, w = pcall(function() return map:isWalkableCell(cx, cy) end)
    return ok and w
  end
  -- THE GROUND, not the obstacle. A map's boundary row is very often
  -- the thing that STOPS you -- fences, ledges, tree lines -- and
  -- continuing that outward smeared dark fence to the horizon. What
  -- should continue is the ground the obstacle stands on: water stays
  -- water, and otherwise the tile comes from the first WALKABLE cell
  -- walking inward from the edge, which is the grass or path or sand
  -- the boundary sits in.
  local function groundTile(cx, cy, inx, iny)
    if isWater(cx, cy) then return tileAtCell(cx, cy) end
    for step = 0, 6 do
      local nx, ny = cx + inx * step, cy + iny * step
      if isWater(nx, ny) or isWalk(nx, ny) then
        return tileAtCell(nx, ny)
      end
    end
    return tileAtCell(cx, cy)
  end
  local verts, indexMap, quads = {}, {}, 0
  local A = MOUND.APRON
  local function ring(cx, cy, dirx, diry, tile)
    local uv = { uvFor(map, tile) }
    for r = 1, A.RINGS do
      local fade = r / A.RINGS
      -- the same cooling the neighbour maps get, deepened at the far rim
      -- gently: the haze COOLS the distance, it must not black it out --
      -- the streaks in the first cut were half darkness, half fence
      local shade = (1 - fade * 0.18)
      local y = -A.SINK - (r - 1) * A.DROP
      local y2 = -A.SINK - r * A.DROP
      -- the ring's near edge starts at the map's rim and each ring
      -- steps one cell further out ALONG ITS OWN DIRECTION; the drop
      -- runs the same way, so an east apron falls eastward, not south
      local bx = cx * 16 + dirx * 16 * (r - 1)
      local bz = cy * 16 + diry * 16 * (r - 1)
      local ex = bx + (dirx ~= 0 and dirx * 16 or 0)
      local ez = bz + (diry ~= 0 and diry * 16 or 0)
      if dirx == 0 then
        -- north/south: width in x, depth outward in z
        verts[#verts + 1] = { bx + 16, y, bz, uv[1], uv[3], shade }
        verts[#verts + 1] = { bx, y, bz, uv[2], uv[3], shade }
        verts[#verts + 1] = { bx, y2, ez, uv[2], uv[4], shade }
        verts[#verts + 1] = { bx + 16, y2, ez, uv[1], uv[4], shade }
      else
        -- east/west: width in z, depth outward in x
        verts[#verts + 1] = { bx, y, bz + 16, uv[1], uv[3], shade }
        verts[#verts + 1] = { bx, y, bz, uv[2], uv[3], shade }
        verts[#verts + 1] = { ex, y2, bz, uv[2], uv[4], shade }
        verts[#verts + 1] = { ex, y2, bz + 16, uv[1], uv[4], shade }
      end
      Voxel3D.pushQuad(indexMap, quads)
      quads = quads + 1
    end
  end
  -- north and south edges, each cell's GROUND continued outward
  for cx = 0, wc - 1 do
    local tN = groundTile(cx, 0, 0, 1)
    if tN then ring(cx, 0, 0, -1, tN) end
    local tS = groundTile(cx, hc - 1, 0, -1)
    if tS then ring(cx, hc, 0, 1, tS) end
  end
  -- east and west
  for cy = 0, hc - 1 do
    local tW = groundTile(0, cy, 1, 0)
    if tW then ring(0, cy, -1, 0, tW) end
    local tE = groundTile(wc - 1, cy, -1, 0)
    if tE then ring(wc, cy, 1, 0, tE) end
  end
  -- corners: carry the corner cell's tile out diagonally as a square
  for _, c in ipairs({ { 0, 0, -1, -1 }, { wc - 1, 0, 1, -1 },
                       { 0, hc - 1, -1, 1 }, { wc - 1, hc - 1, 1, 1 } }) do
    local t = groundTile(c[1], c[2], -c[3], -c[4])
    if t then
      local uv = { uvFor(map, t) }
      for rx = 1, A.RINGS do
        for ry = 1, A.RINGS do
          local r = math.max(rx, ry)
          local shade = (1 - (r / A.RINGS) * 0.18)
          local y = -A.SINK - (r - 1) * A.DROP
          local bx = c[1] * 16 + c[3] * 16 * rx
          local bz = c[2] * 16 + c[4] * 16 * ry
          verts[#verts + 1] = { bx + 16, y, bz, uv[1], uv[3], shade }
          verts[#verts + 1] = { bx, y, bz, uv[2], uv[3], shade }
          verts[#verts + 1] = { bx, y, bz + 16, uv[2], uv[4], shade }
          verts[#verts + 1] = { bx + 16, y, bz + 16, uv[1], uv[4], shade }
          Voxel3D.pushQuad(indexMap, quads)
          quads = quads + 1
        end
      end
    end
  end
  if quads == 0 then return nil end
  return Voxel3D.newMesh(verts, indexMap), quads
end

function MOUND.buildBacks(map)
  local wc, hc = map.widthCells or 0, map.heightCells or 0
  if wc == 0 or hc == 0 then return nil, 0 end
  local function walk(cx, cy)
    if cx < 0 or cy < 0 or cx >= wc or cy >= hc then return true end
    local ok, w = pcall(function() return map:isWalkableCell(cx, cy) end)
    return ok and w
  end
  local function tileOf(cx, cy)
    local ok, t = pcall(function() return map:tileAt(cx * 2, cy * 2) end)
    return ok and t or nil
  end

  -- ONLY THE MIRRORED DOOR.
  -- Covering the whole back wall put a slab of one tile across the
  -- entire rear of a building, which bleeds past its edges and looks
  -- worse than the fault it was fixing.  The mirroring that matters is
  -- the DOOR: the mesher repeats the door tile on the far face, so a
  -- house appears to have a second entrance round the back.  Cover that
  -- column and nothing else.
  local body, doors = {}, {}
  local function markColumn(cx, cy)
    for up = 1, 5 do
      local ay = cy - up
      if not walk(cx, ay) then
        local okB, isDoor = pcall(function()
          return map.isDoorTileCell and map:isDoorTileCell(cx, ay)
        end)
        if not (okB and isDoor) then body[ay * wc + cx] = true end
      else break end
    end
  end
  for cy = 0, hc - 1 do
    for cx = 0, wc - 1 do
      local okD, door = pcall(function()
        return map.isDoorTileCell and map:isDoorTileCell(cx, cy)
      end)
      if okD and door then
        doors[#doors + 1] = { cx, cy }
        -- JUST THE MIRRORED DOOR, in the back wall's OWN brick.
        -- Six cells of the side wall's art was worse than the fault: it
        -- pasted the gable end's flat purple over the brick and ran past
        -- the corner of the house. Only the door cell is covered now,
        -- and the tile comes from ALONG THE SAME BACK WALL -- the
        -- nearest cell left or right whose north face is also exposed --
        -- so the patch is the same brick as its neighbours and vanishes
        -- into them.
        -- A cell that is a REAL door in its own right is never covered:
        -- some houses genuinely have a back entrance.
        markColumn(cx, cy)
      end
    end
  end

  -- DOUBLE-WIDE DOORS. A department-store entrance spans two cells but
  -- the engine flags only the warp cell, leaving its twin as a black
  -- column beside the patch. If a solid, unflagged neighbour's body row
  -- carries the SAME art as the door column's body row, it is the other
  -- half of the doorway: mark it too. A false positive on a plain wall
  -- is harmless -- it gets covered with its own matching brick.
  for _, d in ipairs(doors) do
    local cx, cy = d[1], d[2]
    for _, dx in ipairs({ -1, 1 }) do
      local nx = cx + dx
      if nx >= 0 and nx < wc and not walk(nx, cy) then
        local okN, nDoor = pcall(function()
          return map.isDoorTileCell and map:isDoorTileCell(nx, cy)
        end)
        if not (okN and nDoor) then
          local a, b = tileOf(nx, cy - 1), tileOf(cx, cy - 1)
          if a and b and a == b then markColumn(nx, cy) end
        end
      end
    end
  end

  local verts, indexMap, quads, backs = {}, {}, 0, 0
  for key in pairs(body) do
    local cy, cx = math.floor(key / wc), key % wc
    -- the north face is the back: exposed when the cell above is open
    if walk(cx, cy - 1) then
      -- THE BACK WALL'S OWN BRICK. Walk left and right along this same
      -- row looking for a cell that is solid, is not itself patched, and
      -- whose north face is exposed too -- that is a neighbouring piece
      -- of the very wall being repaired, so the patch matches. Only if
      -- the wall is one cell wide does this fall back to the row above.
      local side, donorX = nil, nil
      for step = 1, 6 do
        for _, dx in ipairs({ -step, step }) do
          local nx = cx + dx
          if not side and nx >= 0 and nx < wc
             and not walk(nx, cy) and walk(nx, cy - 1)
             and body[cy * wc + nx] == nil then
            side = tileOf(nx, cy)
            donorX = nx
          end
        end
        if side then break end
      end
      side = side or tileOf(cx, cy + 1) or tileOf(cx, cy)
      if donorX then
        -- THE DONOR'S OWN FOUR SUBTILES, each at true 8px scale. One
        -- tile stretched over the 16px cell drew the brick at double
        -- size -- a smear that matched nothing around it. The cell is
        -- four tiles; the patch is now four quads, each sampling the
        -- donor's matching quadrant, so the courses line up with the
        -- wall either side.
        local x0, z0 = cx * 16, cy * 16
        local o = MOUND.BACKS.EPS
        for sy = 0, 1 do
          for sx = 0, 1 do
            local okS, t = pcall(function()
              return map:tileAt(donorX * 2 + sx, cy * 2 + sy)
            end)
            if okS and t then
              local uv = { uvFor(map, t) }
              local qx = x0 + sx * 8
              local yT = 16 - sy * 8
              verts[#verts + 1] = { qx + 8, yT, z0 - o,
                                    uv[1], uv[3], 0.62 }
              verts[#verts + 1] = { qx, yT, z0 - o, uv[2], uv[3], 0.62 }
              verts[#verts + 1] = { qx, yT - 8, z0 - o,
                                    uv[2], uv[4], 0.62 }
              verts[#verts + 1] = { qx + 8, yT - 8, z0 - o,
                                    uv[1], uv[4], 0.62 }
              Voxel3D.pushQuad(indexMap, quads)
              quads = quads + 1
            end
          end
        end
        backs = backs + 1
      elseif side then
        local uv = { uvFor(map, side) }
        local x0, z0 = cx * 16, cy * 16
        local o = MOUND.BACKS.EPS
        verts[#verts + 1] = { x0 + 16, 16, z0 - o, uv[1], uv[3], 0.62 }
        verts[#verts + 1] = { x0, 16, z0 - o, uv[2], uv[3], 0.62 }
        verts[#verts + 1] = { x0, 0, z0 - o, uv[2], uv[4], 0.62 }
        verts[#verts + 1] = { x0 + 16, 0, z0 - o, uv[1], uv[4], 0.62 }
        Voxel3D.pushQuad(indexMap, quads)
        quads = quads + 1
        backs = backs + 1
      end
    end
  end
  if quads == 0 then return nil, 0 end
  return Voxel3D.newMesh(verts, indexMap), backs
end


-- DISTANCE HAZE.  Air is not clear: things far off lose contrast and go
-- toward the colour of the sky.  The renderer multiplies, so this cools
-- and softens rather than truly lightening -- enough to sit a far map
-- back behind a near one, which is what stops the boundary reading as a
-- cut.
MOUND.HAZE_START, MOUND.HAZE_FULL = 220, 900
function MOUND.haze(dist)
  local f = math.max(0, math.min(1,
    (dist - MOUND.HAZE_START)
    / (MOUND.HAZE_FULL - MOUND.HAZE_START)))
  -- toward a pale cool grey, never all the way
  return 1 - f * 0.30, 1 - f * 0.22, 1 - f * 0.08
end

-- keep a cache from growing without limit as the player crosses Kanto
function MOUND.trim(store, keep)
  local n = 0
  for _ in pairs(store) do n = n + 1 end
  if n <= keep then return end
  for k, v in pairs(store) do
    if not MOUND.seen[k] then
      if v and v.mesh then pcall(v.mesh.release, v.mesh) end
      store[k] = nil
      n = n - 1
      if n <= keep then return end
    end
  end
end

-- MOUNTAINS were tried here and removed.  Deriving HEIGHT from how deep
-- a cell sits inside its cluster worked well and looked good; deciding
-- WHICH cells are rock never did.  The classes come back unauthored for
-- ordinary terrain, an Image cannot be read back for colour, and every
-- rule tried either raised the whole world -- trees, houses and sea --
-- or none of it.  Left out rather than left broken.

-- ------- WHAT LIVES UNDERGROUND: still water, torches, and bats.
--
-- POOLS are the puddles' permanent cousin: water that was here before
-- you and will be here after, so they are built once per cave rather
-- than filled by weather.  The drips we already spawn land in them.
--
-- SCONCES are torches set into the rock at intervals along a wall, not
-- only at the mouth: somebody has been down here before, and a cave with
-- one lit entrance and a mile of blackness reads as unfinished rather
-- than as dark.
--
-- BATS roost in clusters near the roof and scatter when you come too
-- close, exactly as the ground flock does out in the daylight -- and
-- they wear frames derived from the player's own Zubat, which is both
-- the right animal and no new artwork.
local POOL_EVERY = 13         -- one walkable cave cell in this many
local POOL_SIDES = 9
local SCONCE_EVERY = 7        -- cells of wall between torches
local SCONCE_Y = 19
local BAT_ROOSTS = 3
local BAT_PER_ROOST = 6
local BAT_Y = 27
local BAT_FLUSH = 46
local BAT_LIFE = 120
local DERIVED = "save/mod-derived/ds_fp_ceiling/birds/"

local poolCache, sconceCache = nil, nil
local bats, batPics, batsAt = nil, nil, nil

local function buildPools(map)
  local wc, hc = map.widthCells or 0, map.heightCells or 0
  if wc == 0 or hc == 0 then return nil, 0 end
  local waterTile = nil
  for tile in pairs(map.waterTiles or {}) do
    if type(tile) == "number" and (not waterTile or tile < waterTile) then
      waterTile = tile
    end
  end
  local u0, u1, v0, v1 = 0.5, 0.5, 0.5, 0.5
  if waterTile then u0, u1, v0, v1 = uvFor(map, waterTile) end
  local verts, indexMap, quads, pools = {}, {}, 0, 0
  for cy = 0, hc - 1 do
    for cx = 0, wc - 1 do
      local ok, walk = pcall(function() return map:isWalkableCell(cx, cy) end)
      if ok and walk
         and math.floor(hash01(cx, cy, 281) * POOL_EVERY) == 0 then
        local ccx = cx * 16 + 4 + hash01(cx, cy, 283) * 8
        local ccz = cy * 16 + 4 + hash01(cy, cx, 293) * 8
        local rx = 4.5 + hash01(cx, cy, 307) * 3.5
        local rz = 4.0 + hash01(cy, cx, 311) * 3.5
        local y = 1.2
        for i = 0, POOL_SIDES - 1 do
          local a0 = (i / POOL_SIDES) * math.pi * 2
          local a1 = ((i + 1) / POOL_SIDES) * math.pi * 2
          local w0 = 0.78 + hash01(cx * 5 + i, cy, 313) * 0.44
          local w1 = 0.78 + hash01(cx * 5 + i + 1, cy, 313) * 0.44
          verts[#verts + 1] = { ccx, y, ccz, (u0 + u1) * 0.5,
                                (v0 + v1) * 0.5, 0.9 }
          verts[#verts + 1] = { ccx + math.cos(a0) * rx * w0, y,
                                ccz + math.sin(a0) * rz * w0, u0, v0, 0.8 }
          verts[#verts + 1] = { ccx + math.cos(a1) * rx * w1, y,
                                ccz + math.sin(a1) * rz * w1, u1, v1, 0.8 }
          verts[#verts + 1] = { ccx, y, ccz, (u0 + u1) * 0.5,
                                (v0 + v1) * 0.5, 0.9 }
          Voxel3D.pushQuad(indexMap, quads)
          quads = quads + 1
        end
        pools = pools + 1
      end
    end
  end
  if quads == 0 then return nil, 0 end
  return Voxel3D.newMesh(verts, indexMap), pools
end

-- torches along the rock: a cell that is solid with open floor beside it
local function buildSconces(map)
  local wc, hc = map.widthCells or 0, map.heightCells or 0
  local out = {}
  local function walk(cx, cy)
    local ok, w = pcall(function() return map:isWalkableCell(cx, cy) end)
    return ok and w
  end
  for cy = 0, hc - 1 do
    for cx = 0, wc - 1 do
      if not walk(cx, cy) and (walk(cx, cy + 1) or walk(cx, cy - 1)
                               or walk(cx + 1, cy) or walk(cx - 1, cy)) then
        if math.floor(hash01(cx, cy, 317) * SCONCE_EVERY) == 0 then
          out[#out + 1] = { cx * 16 + 8, cy * 16 + 8 }
        end
      end
    end
  end
  return out
end

local function loadBatPics()
  if batPics ~= nil then return batPics end
  local function frame(suffix)
    local ok, img = pcall(function()
      local i = love.graphics.newImage(DERIVED .. "zubat" .. suffix .. ".png")
      i:setFilter("nearest", "nearest")
      return i
    end)
    return ok and img or nil
  end
  local a, b = frame("_a"), frame("_b")
  batPics = (a and { a = a, b = b or a }) or false
  return batPics
end

-- ------- DYNAMIC LIGHT (prototype).
-- Route C of the three we weighed: no shader patching and no re-meshing
-- of Dramatic Shape's chunks.  Light is flood-filled through the CELL
-- GRID from each source -- it spreads into walkable cells and stops at
-- solids -- so occlusion is inherent rather than computed: a lamp lights
-- round a corner and not through a wall.  The result is drawn as our own
-- floor pool, one quad per lit cell shaded by its light level, plus a
-- glow at the source itself.
--
-- Sources are found rather than authored: every doorway on an outdoor map
-- gets a lamp over it, which is what puts light outside the Pokemon
-- Centre and either side of the Mt Moon entrance.  It is additive over
-- Dramatic Shape's own shading, so it brightens surfaces rather than
-- truly relighting them -- at this scale that reads as lamplight.
local LIGHT_RADIUS = 7        -- cells the fill reaches
local LIGHT_Y = 1.1
local LAMP_HEIGHT = 22        -- where the lamp itself hangs
local LIGHT_WARM = { 1.0, 0.86, 0.55 }

local function buildLight(map)
  local wc, hc = map.widthCells or 0, map.heightCells or 0
  if wc == 0 or hc == 0 then return nil, 0 end

  -- the sources: doorways, which is where a porch lamp would be
  local sources = {}
  for cy = 0, hc - 1 do
    for cx = 0, wc - 1 do
      local okD, door = pcall(function()
        return map.isDoorTileCell and map:isDoorTileCell(cx, cy)
      end)
      if okD and door then sources[#sources + 1] = { cx, cy } end
    end
  end
  if #sources == 0 then return nil, 0 end

  -- flood fill: light spreads cell to cell and stops at anything solid
  local level = {}
  local queue, head = {}, 1
  for _, srcCell in ipairs(sources) do
    local key = srcCell[2] * wc + srcCell[1]
    level[key] = LIGHT_RADIUS
    queue[#queue + 1] = srcCell
  end
  while head <= #queue do
    local cell = queue[head]; head = head + 1
    local cx, cy = cell[1], cell[2]
    local here = level[cy * wc + cx] or 0
    if here > 1 then
      for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local nx, ny = cx + d[1], cy + d[2]
        if nx >= 0 and ny >= 0 and nx < wc and ny < hc then
          local nkey = ny * wc + nx
          local okW, walk = pcall(function()
            return map:isWalkableCell(nx, ny)
          end)
          -- a wall takes the light: it neither lights up nor passes it on
          if okW and walk and (level[nkey] or 0) < here - 1 then
            level[nkey] = here - 1
            queue[#queue + 1] = { nx, ny }
          end
        end
      end
    end
  end

  local verts, indexMap, quads = {}, {}, 0
  for key, lv in pairs(level) do
    local cy = math.floor(key / wc)
    local cx = key % wc
    local f = lv / LIGHT_RADIUS
    if f > 0.05 then
      local x0, z0 = cx * 16, cy * 16
      -- brightness falls off with the square, as light does
      local a = f * f
      verts[#verts + 1] = { x0, LIGHT_Y, z0 + 16, 0.5, 0.5, a }
      verts[#verts + 1] = { x0 + 16, LIGHT_Y, z0 + 16, 0.5, 0.5, a }
      verts[#verts + 1] = { x0 + 16, LIGHT_Y, z0, 0.5, 0.5, a }
      verts[#verts + 1] = { x0, LIGHT_Y, z0, 0.5, 0.5, a }
      Voxel3D.pushQuad(indexMap, quads)
      quads = quads + 1
    end
  end
  if quads == 0 then return nil, 0 end
  local mesh = Voxel3D.newMesh(verts, indexMap)
  if not mesh then return nil, 0 end
  return { mesh = mesh, sources = sources }, #sources
end

-- ------- PUDDLES.
-- Flat sheens laid on walkable ground while the rain fills them, hashed
-- so the same lane puddles in the same places, and fading out slowly once
-- the sky clears.  Sat a hair above the floor so they never fight it for
-- depth, and dark rather than mirror-bright: this world has no reflection
-- to give them, and a fake one would look worse than a wet patch.
-- Puddles are ROUND, wear the map's own water art, and arrive a few at a
-- time.  The first version drew one square quad per cell in a flat grey,
-- all of them appearing together -- which read as tiles switching on,
-- because that is exactly what it was.
--
-- Each puddle is a fan of wedges about a centre, with a wobble on the rim
-- so it is not a neat circle either, and each belongs to one of a few
-- GROUPS.  A group is its own mesh, and the draw eases them in one after
-- another as the ground wets, so puddles gather across a street.
local function buildPuddles(map)
  local wc, hc = map.widthCells or 0, map.heightCells or 0
  if wc == 0 or hc == 0 then return nil end

  -- the map's own water, so a puddle is made of the stuff the sea is
  local waterTile = nil
  for tile in pairs(map.waterTiles or {}) do
    if type(tile) == "number" and (not waterTile or tile < waterTile) then
      waterTile = tile
    end
  end
  local wu0, wu1, wv0, wv1 = 0.5, 0.5, 0.5, 0.5
  if waterTile then wu0, wu1, wv0, wv1 = uvFor(map, waterTile) end

  local groups = {}
  for g = 1, PUDDLE_GROUPS do groups[g] = { verts = {}, idx = {}, n = 0 } end
  local total = 0

  for cy = 0, hc - 1 do
    for cx = 0, wc - 1 do
      local ok, walk = pcall(function() return map:isWalkableCell(cx, cy) end)
      if ok and walk
         and math.floor(hash01(cx, cy, 71) * PUDDLE_EVERY) == 0 then
        local g = 1 + math.floor(hash01(cx, cy, 97) * PUDDLE_GROUPS)
                      % PUDDLE_GROUPS
        local G = groups[g]
        local ccx = cx * 16 + 5 + hash01(cx, cy, 83) * 6
        local ccz = cy * 16 + 5 + hash01(cy, cx, 89) * 6
        local rx = 3.6 + hash01(cx, cy, 73) * 2.8
        local rz = 3.2 + hash01(cy, cx, 79) * 2.6
        -- clear of the floor by enough that a moving camera cannot make
        -- the two surfaces argue about which is in front
        local y = 1.6
        local shade = 0.88 + hash01(cx, cy, 101) * 0.20
        for i = 0, PUDDLE_SIDES - 1 do
          local a0 = (i / PUDDLE_SIDES) * math.pi * 2
          local a1 = ((i + 1) / PUDDLE_SIDES) * math.pi * 2
          local w0 = 0.80 + hash01(cx * 7 + i, cy, 103) * 0.40
          local w1 = 0.80 + hash01(cx * 7 + i + 1, cy, 103) * 0.40
          local x0p = ccx + math.cos(a0) * rx * w0
          local z0p = ccz + math.sin(a0) * rz * w0
          local x1p = ccx + math.cos(a1) * rx * w1
          local z1p = ccz + math.sin(a1) * rz * w1
          local mu, mv = (wu0 + wu1) * 0.5, (wv0 + wv1) * 0.5
          -- a wedge, as a quad with its inner edge collapsed
          G.verts[#G.verts + 1] = { ccx, y, ccz, mu, mv, shade }
          G.verts[#G.verts + 1] = { x0p, y, z0p, wu0, wv0, shade * 0.93 }
          G.verts[#G.verts + 1] = { x1p, y, z1p, wu1, wv1, shade * 0.93 }
          G.verts[#G.verts + 1] = { ccx, y, ccz, mu, mv, shade }
          Voxel3D.pushQuad(G.idx, G.n)
          G.n = G.n + 1
        end
        total = total + 1
      end
    end
  end

  local out = {}
  for g = 1, PUDDLE_GROUPS do
    local G = groups[g]
    if G.n > 0 then
      local m = Voxel3D.newMesh(G.verts, G.idx)
      -- the share of wetness at which this group starts to show
      if m then out[#out + 1] = { mesh = m, at = (g - 1) / PUDDLE_GROUPS } end
    end
  end
  if #out == 0 then return nil end
  return out, total
end

-- ------- THE CANOPY.
-- Under the trees the mod's own particles were falling through open
-- black: Viridian Forest has walls of trees but no roof, because the 2D
-- game never needed one.  This grows one.  Every cell gets a leaf panel
-- at a hashed height between two limits, so the underside is stepped and
-- uneven rather than a flat lid, and the panels wear the wood's own
-- foliage art.  Roughly one cell in nine is left OPEN -- a gap in the
-- leaves -- which is where the daylight and the sun shafts come through,
-- and what stops it reading as a ceiling with a texture on it.
local CANOPY_LOW, CANOPY_HIGH = 40, 62
local CANOPY_GAP = 9        -- one cell in this many is a hole
local CANOPY_SKIRT = 6      -- how far a panel's rim hangs below it
local CANOPY_UPPER = 74     -- the solid layer above, seen through gaps
local CANOPY_HOLE = 5       -- cells cleared around the player in cutaway
-- THE EDGE OF THE WOOD.  A curtain hung on the map's rim reads as a wall
-- with leaves on it, because that is what it is.  Beyond the rim there
-- is now a RING of further trees -- trunks at varied heights under the
-- same canopy -- and the curtain moves out behind them.  You see wood
-- receding into wood, and the wall that stops you seeing further is
-- three trees away rather than one.
-- ------- VINES.
-- Strands hanging from the underside of the canopy: a couple of pixels
-- of stem with stubs off it, swaying on the same slow clock the grass
-- uses -- and swinging when you walk through them.
--
-- The swing is the interesting part.  A mesh is drawn with ONE matrix,
-- so a single vine cannot be moved without moving every vine with it.
-- The strands are therefore built into BLOCKS of eight cells square,
-- each its own mesh: walking through a block disturbs that block and
-- nothing else, which at this scale reads as "the vines you just pushed
-- through".  Distant wood keeps swaying gently.
--
-- The bend is a shear about the CANOPY rather than the ground -- vines
-- hang, so the free end is the bottom and the fixed end is the top.
local VINE_EVERY = 9        -- one leafy cell in this many grows a strand
local VINE_MIN, VINE_MAX = 7, 22
local VINE_LONG = 0.28      -- share of strands that run to the floor
local VINE_FLOOR = 3        -- how far above the ground a long one stops
local VINE_BLOCK = 8        -- cells per independently swinging block
local VINE_SWAY = 0.055     -- idle sway, as a fraction of length
local VINE_PUSH = 0.42      -- how far a brush throws them
local VINE_SETTLE = 1.9     -- seconds for a disturbed block to still
local VINE_REACH = 26       -- how close you must be to disturb one

-- x' = x + k*(top - y): the top stays put, the tail swings.
local function bend(kx, kz, top)
  return { 1, -kx, 0, kx * top,
           0, 1,   0, 0,
           0, -kz, 1, kz * top,
           0, 0,   0, 1 }
end

local CANOPY_RING = 4       -- cells of extra wood beyond the map
local RING_DENSITY = 0.62   -- how much of the ring is wood
local RING_LOW, RING_HIGH = 24, 44
local TREE_H = 16           -- the height the game draws its own trees at
local TALL_ODDS = 0.16      -- how often a ring tree grows a taller trunk
local CANOPY_GATE = 0.5     -- first-person blend above which the roof is whole


-- `mode` is "fp" (the whole roof) or "cutaway" (the diorama's view in):
-- leaves near the player are cleared and the near rim walls come down,
-- exactly as the interior ceiling opens up, so a wood can be looked into
-- from above instead of presenting a lid.
local function buildCanopy(map, tex, mode, pcx, pcy)
  if not (okTS and TileShape) then return nil, "no TileShape" end
  local okS, shapes = pcall(TileShape.forMap, map)
  if not (okS and shapes) then return nil, nil, "TileShape refused" end
  local wc, hc = map.widthCells or 0, map.heightCells or 0
  if wc == 0 or hc == 0 then return nil, nil, "map has no cells" end

  -- The wood's whole foliage palette, not just its commonest tile: every
  -- distinct tile the trees are drawn from, so the canopy can mix greens
  -- and browns the way a real one does instead of tiling one leaf.
  local tally, leafTile = {}, nil
  for cy = 0, hc - 1 do
    for cx = 0, wc - 1 do
      local okT, tile = pcall(function() return map:tileAt(cx * 2, cy * 2) end)
      if okT and tile then
        local okC, sh = pcall(TileShape.at, map, shapes, tile, cx * 2, cy * 2)
        local class = okC and sh and sh.class
        -- Gather BROADLY -- anything standing full height is a candidate
        -- -- and let the greenness measurement below decide what is
        -- actually foliage.  Restricting to class `tree` looked tidier
        -- and emptied the canopy completely: a wood's trees are not
        -- necessarily classed `tree` by the mesher.
        if class == "tree" or class == "wall" or class == "cliff"
           or (sh and (sh.h or 0) >= 16) then
          tally[tile] = (tally[tile] or 0) + 1
          if not leafTile or tally[tile] > tally[leafTile] then
            leafTile = tile
          end
        end
      end
    end
  end
  if not leafTile then
    return nil, nil, "no foliage found (no full-height cells on this map)"
  end

  -- the palette: greenest first where the atlas can be read, commonest
  -- first where it cannot, capped so one odd tile cannot dominate
  local palette = {}
  for tile in pairs(tally) do palette[#palette + 1] = tile end
  local green = tex and greenness(map, tex, palette) or nil
  if green then
    table.sort(palette, function(a, b)
      return (green[a] or -1) > (green[b] or -1)
    end)
    -- drop anything that is not actually foliage -- but never drop
    -- everything: if nothing clears the bar, the greenest two still
    -- make a canopy, because no canopy at all is the worse failure
    local keep = {}
    for _, t in ipairs(palette) do
      if (green[t] or -1) > 0.02 then keep[#keep + 1] = t end
    end
    if #keep == 0 then
      for i = 1, math.min(2, #palette) do keep[i] = palette[i] end
    end
    if #keep > 0 then palette = keep end
  else
    table.sort(palette, function(a, b) return tally[a] > tally[b] end)
  end
  while #palette > 5 do table.remove(palette) end
  if #palette == 0 then palette = { leafTile } end
  leafTile = palette[1]

  local verts, indexMap, quads, holes = {}, {}, 0, 0

  -- one vertex list per block of cells, so each can swing on its own
  local vineBlocks = {}
  local function vineBlock(cx, cy)
    local bx = math.floor(cx / VINE_BLOCK)
    local by = math.floor(cy / VINE_BLOCK)
    local key = bx .. ":" .. by
    local B = vineBlocks[key]
    if not B then
      B = { verts = {}, idx = {}, n = 0, key = key, top = 0 }
      vineBlocks[key] = B
    end
    return B
  end

  -- a strand: a stem hanging from the leaves with a few stubs off it,
  -- drawn as crossed quads so it reads from any angle
  local function hangVine(cx, cy, topY, tile)
    if math.floor(hash01(cx, cy, 163) * VINE_EVERY) ~= 0 then return end
    local B = vineBlock(cx, cy)
    -- most are short; a good few run the whole way down, which is what
    -- makes a canopy feel like something hanging over you rather than a
    -- ceiling with fringing
    local len
    if hash01(cx, cy, 229) < VINE_LONG then
      len = math.max(VINE_MIN, topY - VINE_FLOOR
                     - hash01(cx, cy, 233) * 4)
    else
      len = VINE_MIN + hash01(cx, cy, 167) * (VINE_MAX - VINE_MIN)
    end
    local x = cx * 16 + 3 + hash01(cx, cy, 173) * 10
    local z = cy * 16 + 3 + hash01(cy, cx, 179) * 10
    local w = 1.2 + hash01(cx, cy, 181) * 0.9
    local u0, u1, v0, v1 = uvFor(map, tile)
    local bottom = topY - len
    B.top = math.max(B.top, topY)
    local shade = 0.40 + hash01(cx, cy, 191) * 0.26
    for k = 0, 1 do
      local a = k * math.pi * 0.5 + hash01(cx, cy, 193) * math.pi
      local dx, dz = math.cos(a) * w, math.sin(a) * w
      B.verts[#B.verts + 1] = { x - dx, topY, z - dz, u0, v0, shade }
      B.verts[#B.verts + 1] = { x + dx, topY, z + dz, u1, v0, shade }
      B.verts[#B.verts + 1] = { x + dx, bottom, z + dz, u1, v1, shade * 0.8 }
      B.verts[#B.verts + 1] = { x - dx, bottom, z - dz, u0, v1, shade * 0.8 }
      Voxel3D.pushQuad(B.idx, B.n)
      B.n = B.n + 1
    end
    -- a stub or two, so a strand is not just a line
    local stubs = 1 + math.floor(hash01(cx, cy, 197) * 2)
    for sIdx = 1, stubs do
      local sy = bottom + len * (0.25 + 0.4 * hash01(cx + sIdx, cy, 199))
      local sd = (hash01(cx, cy + sIdx, 211) < 0.5) and -3.2 or 3.2
      B.verts[#B.verts + 1] = { x, sy + 1.6, z, u0, v0, shade }
      B.verts[#B.verts + 1] = { x + sd, sy + 1.6, z, u1, v0, shade }
      B.verts[#B.verts + 1] = { x + sd, sy, z, u1, v1, shade * 0.8 }
      B.verts[#B.verts + 1] = { x, sy, z, u0, v1, shade * 0.8 }
      Voxel3D.pushQuad(B.idx, B.n)
      B.n = B.n + 1
    end
  end
  local function panel(c1, c2, c3, c4, shade, tile)
    local u0, u1, v0, v1 = uvFor(map, tile or leafTile)
    verts[#verts + 1] = { c1[1], c1[2], c1[3], u0, v0, shade }
    verts[#verts + 1] = { c2[1], c2[2], c2[3], u1, v0, shade }
    verts[#verts + 1] = { c3[1], c3[2], c3[3], u1, v1, shade }
    verts[#verts + 1] = { c4[1], c4[2], c4[3], u0, v1, shade }
    Voxel3D.pushQuad(indexMap, quads)
    quads = quads + 1
  end

  -- which leaf a cell wears, and how deeply shaded: two independent
  -- hashes, so colour and depth do not correlate into visible banding
  local function leafOf(cx, cy)
    return palette[1 + math.floor(hash01(cx, cy, 23) * #palette) % #palette]
  end

  -- cleared: inside the cutaway's hole, where the camera needs to see
  local function cleared(cx, cy)
    if mode ~= "cutaway" or not pcx then return false end
    return math.max(math.abs(cx - pcx), math.abs(cy - pcy)) <= CANOPY_HOLE
  end

  local function heightAt(cx, cy)
    -- the ring counts: leaves carry on past the map's edge
    if cx < -CANOPY_RING or cy < -CANOPY_RING
       or cx >= wc + CANOPY_RING or cy >= hc + CANOPY_RING then
      return nil
    end
    if cleared(cx, cy) then return nil end
    if (math.floor(hash01(cx, cy, 5) * CANOPY_GAP)) == 0 then return nil end
    return CANOPY_LOW + hash01(cx, cy, 2) * (CANOPY_HIGH - CANOPY_LOW)
  end

  -- THE RING, built from the wood's OWN trees rather than invented ones.
  -- Each ring cell mirrors the nearest cell inside the map: if that cell
  -- is a solid tree, this one is a box of the same 16-pixel height
  -- wearing the same tile art the game draws it with, so the extra wood
  -- matches the wood you are standing in.  A few grow taller trunks for
  -- variety.  And every ring cell gets a FLOOR, because the ring used to
  -- hang over the void -- invisible behind the old curtain, obvious once
  -- the curtain moved back.
  local ring, ringFloor = 0, 0
  local groundTile = (map.tileset and map.tileset.grassTile) or leafTile

  local function sourceCell(cx, cy)
    local sx = math.max(0, math.min(wc - 1, cx))
    local sy = math.max(0, math.min(hc - 1, cy))
    return sx, sy
  end

  local function box(cx, cy, top, tile, inset)
    local x0, z0 = cx * 16 + inset, cy * 16 + inset
    local x1, z1 = (cx + 1) * 16 - inset, (cy + 1) * 16 - inset
    local base = -0.2
    local faces = {
      { { x0, top, z1 }, { x1, top, z1 }, { x1, base, z1 }, { x0, base, z1 },
        0.86 },
      { { x1, top, z0 }, { x0, top, z0 }, { x0, base, z0 }, { x1, base, z0 },
        0.58 },
      { { x1, top, z1 }, { x1, top, z0 }, { x1, base, z0 }, { x1, base, z1 },
        0.74 },
      { { x0, top, z0 }, { x0, top, z1 }, { x0, base, z1 }, { x0, base, z0 },
        0.66 },
      -- a top, so a tree seen from a rise is not an open tube
      { { x0, top, z1 }, { x1, top, z1 }, { x1, top, z0 }, { x0, top, z0 }, 1.0 },
    }
    for _, f in ipairs(faces) do
      panel(f[1], f[2], f[3], f[4], f[5], tile)
    end
  end

  local function ringTrunk(cx, cy)
    -- The floor sits a hair BELOW the world's own ground rather than
    -- level with it.  Dramatic Shape draws the neighbouring maps too, so
    -- out here our floor and a real one can occupy the same plane -- and
    -- two surfaces at identical depth flicker as the camera moves, which
    -- is the glitching.  Half a pixel down means real ground always
    -- wins and ours only shows where there is genuinely nothing.
    local x0, z0 = cx * 16, cy * 16
    panel({ x0, 0.05, z0 + 16 }, { x0 + 16, 0.05, z0 + 16 },
          { x0 + 16, 0.05, z0 }, { x0, 0.05, z0 }, 0.92, groundTile)
    ringFloor = ringFloor + 1

    if hash01(cx, cy, 149) > RING_DENSITY then return end

    -- mirror the nearest cell inside the map: its art, its solidity
    local sx, sy = sourceCell(cx, cy)
    local okT, srcTile = pcall(function() return map:tileAt(sx * 2, sy * 2) end)
    local okW, walk = pcall(function() return map:isWalkableCell(sx, sy) end)
    local solidSource = okW and not walk
    local tile = (okT and srcTile) or leafOf(cx, cy)

    if solidSource then
      -- a tree the size the game draws its trees
      box(cx, cy, TREE_H, tile, 0)
      -- and occasionally a taller one behind it, for a treeline
      if hash01(cx, cy, 151) < TALL_ODDS then
        box(cx, cy, RING_LOW + hash01(cx, cy, 157)
                    * (RING_HIGH - RING_LOW), leafOf(cx, cy), 3)
      end
    else
      -- open ground inside the map means open ground out here too,
      -- with the odd standing trunk to break the sightline
      if hash01(cx, cy, 163) < 0.30 then
        box(cx, cy, RING_LOW + hash01(cx, cy, 167)
                    * (RING_HIGH - RING_LOW), leafOf(cx, cy), 4)
      end
    end
    ring = ring + 1
  end

  -- the upper layer: solid, flat-ish, and lighter, so a gap in the lower
  -- leaves shows sunlit foliage above instead of black
  local upper = 0
  for cy = -CANOPY_RING, hc - 1 + CANOPY_RING do
    for cx = -CANOPY_RING, wc - 1 + CANOPY_RING do
      if not cleared(cx, cy) then
        local uh = CANOPY_UPPER + hash01(cx, cy, 61) * 6
        local x0, z0 = cx * 16, cy * 16
        panel({ x0, uh, z0 + 16 }, { x0 + 16, uh, z0 + 16 },
              { x0 + 16, uh, z0 }, { x0, uh, z0 },
              0.62 + hash01(cx, cy, 67) * 0.20, leafOf(cx, cy))
        upper = upper + 1
      end
    end
  end

  for cy = -CANOPY_RING, hc - 1 + CANOPY_RING do
    for cx = -CANOPY_RING, wc - 1 + CANOPY_RING do
      -- beyond the map body: more wood, not a wall
      local beyond = cx < 0 or cy < 0 or cx >= wc or cy >= hc
      if beyond and not cleared(cx, cy) then ringTrunk(cx, cy) end
      local h = heightAt(cx, cy)
      if not h then
        holes = holes + 1
      else
        local x0, z0 = cx * 16, cy * 16
        -- deeper leaves are darker: the canopy has its own shading
        -- height gives the base shade; a second hash mottles it, so the
        -- ceiling reads as leaves at many depths rather than a gradient
        local shade = 0.30 + (h - CANOPY_LOW)
                      / (CANOPY_HIGH - CANOPY_LOW) * 0.26
                      + hash01(cx, cy, 31) * 0.22
        local tile = leafOf(cx, cy)
        -- the underside, seen from below
        panel({ x0, h, z0 + 16 }, { x0 + 16, h, z0 + 16 },
              { x0 + 16, h, z0 }, { x0, h, z0 }, shade, tile)
        hangVine(cx, cy, h, tile)
        -- a skirt wherever the neighbour is lower or missing, so the
        -- canopy has thickness instead of being paper
        local sides = {
          { heightAt(cx, cy + 1), { x0, z0 + 16 }, { x0 + 16, z0 + 16 } },
          { heightAt(cx, cy - 1), { x0 + 16, z0 }, { x0, z0 } },
          { heightAt(cx + 1, cy), { x0 + 16, z0 + 16 }, { x0 + 16, z0 } },
          { heightAt(cx - 1, cy), { x0, z0 }, { x0, z0 + 16 } },
        }
        for _, side in ipairs(sides) do
          local nh = side[1]
          local drop = nh and math.max(0, h - nh) or CANOPY_SKIRT
          if drop > 0.5 then
            local a, b = side[2], side[3]
            panel({ a[1], h, a[2] }, { b[1], h, b[2] },
                  { b[1], h - drop, b[2] }, { a[1], h - drop, a[2] },
                  shade * 0.8, tile)
          end
        end
      end
    end
  end
  -- THE WALLS.  A canopy over an open-sided wood still shows black at
  -- the horizon: the leaves stop and the void begins.  Every cell on the
  -- map's rim grows a curtain of foliage from the ground to the canopy,
  -- so the wood closes on all four sides and reads as depth rather than
  -- as an edge.  Doorways out are warp cells and stay clear.
  local walls = 0

  local function curtain(cx, cy, side)
    -- in cutaway the near rim is what the camera looks over, so the
    -- south wall and anything level with or below the player melts away
    if mode == "cutaway" and pcy then
      if side == "s" then return end
      if cy >= pcy and (side == "e" or side == "w") then return end
    end
    local x0, z0 = cx * 16, cy * 16
    local topH = CANOPY_UPPER + 8
    local tile = leafOf(cx, cy)
    local okW, isWarp = pcall(function()
      return map.isDoorTileCell and map:isDoorTileCell(cx, cy)
    end)
    if okW and isWarp then return end
    local c1, c2, c3, c4
    if side == "s" then
      c1 = { x0, topH, z0 + 16 }; c2 = { x0 + 16, topH, z0 + 16 }
      c3 = { x0 + 16, 0, z0 + 16 }; c4 = { x0, 0, z0 + 16 }
    elseif side == "n" then
      c1 = { x0 + 16, topH, z0 }; c2 = { x0, topH, z0 }
      c3 = { x0, 0, z0 }; c4 = { x0 + 16, 0, z0 }
    elseif side == "e" then
      c1 = { x0 + 16, topH, z0 + 16 }; c2 = { x0 + 16, topH, z0 }
      c3 = { x0 + 16, 0, z0 }; c4 = { x0 + 16, 0, z0 + 16 }
    else
      c1 = { x0, topH, z0 }; c2 = { x0, topH, z0 + 16 }
      c3 = { x0, 0, z0 + 16 }; c4 = { x0, 0, z0 }
    end
    -- darker than the roof: this is the wood receding, not lit leaves
    panel(c1, c2, c3, c4, 0.30 + hash01(cx, cy, 41) * 0.14, tile)
    walls = walls + 1
  end

  local lo, hiX, hiY = -CANOPY_RING, wc - 1 + CANOPY_RING, hc - 1 + CANOPY_RING
  for cy = lo, hiY do
    for cx = lo, hiX do
      if cy == lo then curtain(cx, cy, "n") end
      if cy == hiY then curtain(cx, cy, "s") end
      if cx == lo then curtain(cx, cy, "w") end
      if cx == hiX then curtain(cx, cy, "e") end
    end
  end

  if quads == 0 then return nil, nil, "canopy came out empty" end
  local vines = {}
  for _, B in pairs(vineBlocks) do
    if B.n > 0 then
      local m = Voxel3D.newMesh(B.verts, B.idx)
      if m then
        vines[#vines + 1] = { mesh = m, key = B.key, top = B.top,
                              phase = hash01(#vines + 1, 7, 223) * 6.28 }
      end
    end
  end

  local mesh = Voxel3D.newMesh(verts, indexMap)
  if not mesh then return nil, "driver refused the canopy mesh" end
  return mesh, vines,
    ("canopy %d panels, %d gaps over %d upper, %d ring trees on %d floor, "
     .. "%d walls, %d leaf tiles")
    :format(quads, holes, upper, ring, ringFloor, walls, #palette)
end

-- ------- FORKED LIGHTNING, drawn into a few textures at load and picked
-- between, so a strike costs nothing at the moment it happens.  A bolt is
-- a jagged trunk that wanders as it descends with two or three forks
-- peeling off it, each thinner and shorter than the last -- which is what
-- makes it read as lightning rather than as a crack in the screen.

local function makeBolts()
  local out = {}
  for n = 1, 3 do
    local ok, img = pcall(function()
      local W, H = 64, 128
      local data = love.image.newImageData(W, H)
      for y = 0, H - 1 do
        for x = 0, W - 1 do data:setPixel(x, y, 1, 1, 1, 0) end
      end
      local function put(x, y, a)
        x, y = math.floor(x), math.floor(y)
        if x >= 0 and y >= 0 and x < W and y < H then
          data:setPixel(x, y, 1, 1, 0.96, dither(x, y, a))
        end
      end
      -- a single limb: walks downward, wandering, thinning as it goes
      local function limb(x, y, len, wide, spread)
        local seg = 0
        while seg < len and y < H - 1 do
          local run = 3 + math.random() * 5
          local dx = (math.random() - 0.5) * spread
          for i = 0, run do
            local px2 = x + dx * (i / run)
            local py2 = y + i
            for w = 0, math.max(0, math.floor(wide)) do
              put(px2 - w, py2, w == 0 and 1 or 0.45)
              put(px2 + w, py2, w == 0 and 1 or 0.45)
            end
            -- a faint halo so it does not look like a hairline
            put(px2 - wide - 1, py2, 0.16)
            put(px2 + wide + 1, py2, 0.16)
          end
          x, y = x + dx, y + run
          seg = seg + run
          wide = math.max(0, wide - 0.05)
        end
        return x, y
      end
      local tx, ty = W / 2 + (math.random() - 0.5) * 10, 0
      -- the trunk, then forks peeling off partway down
      local forks = 2 + (n % 2)
      for f = 0, forks do
        local startX = tx + (math.random() - 0.5) * 14
        local startY = (f == 0) and 0 or (18 + math.random() * 52)
        limb(startX, startY, (f == 0) and H or (26 + math.random() * 44),
             (f == 0) and 1.4 or 0.7, (f == 0) and 7 or 11)
      end
      local i = love.graphics.newImage(data)
      i:setFilter("nearest", "nearest")
      return i
    end)
    if ok and img then out[#out + 1] = img end
  end
  return (#out > 0) and out or nil
end

-- ------- VINES.
-- Strands hanging out of the canopy: a stem with leaf stubs, drawn as a
-- crossed pair so they read from any angle.  Two things move them.
--
-- IDLE is a slow sine, each strand on its own phase, applied as a SHEAR
-- so the anchor at the top stays put and the free end swings -- the same
-- trick the grass uses, and the reason this costs nothing.
--
-- BRUSH is the interesting half.  Walk into one and it takes a shove
-- away from you, proportional to how fast you were going, and then
-- springs back over a second or so with the overshoot damped out.  The
-- state is two numbers per strand, and only strands near the player are
-- updated at all, so a wood full of them costs the same as a few.
--
-- Inside the head or over the shoulder only: from the diorama you would
-- be looking down at the tops of them through the leaves.
local VINE_EVERY = 5          -- one canopy cell in this many
local VINE_MIN, VINE_MAX = 10, 26
local VINE_W = 5
local VINE_VIEW = 190         -- strands beyond this are neither drawn nor moved
local BRUSH_R = 17            -- how close counts as brushing past
local BRUSH_PUSH = 4.6        -- how hard a stride shoves one
local SPRING = 7.0            -- how sharply it returns
local DAMP = 3.6              -- and how quickly it stops arguing about it
-- How much of a shove reaches the shear.  At 0.08 a brushed strand swung
-- no further than the idle breeze did, which made the whole effect
-- invisible: being walked through has to read as bigger than weather.
local BRUSH_LEAN = 0.24
local VINE_SWAY = 0.055

local vineMesh, vineImg, vines = nil, nil, nil

-- a strand: two stem pixels with stubs off alternate sides
local function makeVine()
  local ok, img = pcall(function()
    local W, H = 8, 16
    local data = love.image.newImageData(W, H)
    for y = 0, H - 1 do
      for x = 0, W - 1 do data:setPixel(x, y, 0, 0, 0, 0) end
    end
    local function put(x, y, r, g, b)
      if x >= 0 and y >= 0 and x < W and y < H then
        data:setPixel(x, y, r, g, b, 1)
      end
    end
    for y = 0, H - 1 do
      put(3, y, 0.26, 0.54, 0.28)
      put(4, y, 0.16, 0.40, 0.20)
      -- a stub every few pixels, alternating sides
      if y % 5 == 2 then
        put(2, y, 0.34, 0.62, 0.34); put(1, y, 0.26, 0.54, 0.28)
      elseif y % 5 == 4 then
        put(5, y, 0.34, 0.62, 0.34); put(6, y, 0.26, 0.54, 0.28)
      end
    end
    local i = love.graphics.newImage(data)
    i:setFilter("nearest", "nearest")
    return i
  end)
  return ok and img or nil
end

-- one unit strand, hanging from the origin down to y = -1
local function makeVineMesh()
  local verts, indexMap, quads = {}, {}, 0
  for k = 0, 1 do
    local a = k * math.pi * 0.5
    local dx, dz = math.cos(a) * 0.5, math.sin(a) * 0.5
    verts[#verts + 1] = { -dx, 0, -dz, 0, 0, 1 }
    verts[#verts + 1] = { dx, 0, dz, 1, 0, 1 }
    verts[#verts + 1] = { dx, -1, dz, 1, 1, 1 }
    verts[#verts + 1] = { -dx, -1, -dz, 0, 1, 1 }
    Voxel3D.pushQuad(indexMap, quads)
    quads = quads + 1
  end
  return Voxel3D.newMesh(verts, indexMap)
end

-- ------- sun shafts: leaning slabs of pale light under the canopy
local function buildShafts()
  local verts, indexMap, quads = {}, {}, 0
  for i = 1, SHAFTS do
    local a = (i / SHAFTS) * math.pi * 2
    local r = 40 + (i % 3) * 34
    local x, z = math.cos(a) * r, math.sin(a) * r
    local w = 14 + (i % 4) * 5
    local lean = 26
    -- a slab from the canopy down to the floor, leaning with the sun
    local shade = 0.5 + (i % 3) * 0.12
    verts[#verts + 1] = { x - w, 120, z - w, 0.5, 0.5, shade }
    verts[#verts + 1] = { x + w, 120, z - w, 0.5, 0.5, shade }
    verts[#verts + 1] = { x + w + lean, 0, z + w + lean, 0.5, 0.5, shade * 0.3 }
    verts[#verts + 1] = { x - w + lean, 0, z + w + lean, 0.5, 0.5, shade * 0.3 }
    Voxel3D.pushQuad(indexMap, quads)
    quads = quads + 1
  end
  return Voxel3D.newMesh(verts, indexMap)
end

-- A plain white pixel.  Passing nil as a texture does NOT unbind the
-- last one: the draw simply keeps whatever was bound, which for anything
-- following the terrain is the map atlas -- and that is how a sun shaft
-- ends up as a floating ribbon of the whole tileset.  Every untextured
-- surface samples this instead.
local whiteImg = nil
local function white()
  if whiteImg then return whiteImg end
  local ok, img = pcall(function()
    local data = love.image.newImageData(2, 2)
    for y = 0, 1 do
      for x = 0, 1 do data:setPixel(x, y, 1, 1, 1, 1) end
    end
    local i = love.graphics.newImage(data)
    i:setFilter("nearest", "nearest")
    return i
  end)
  if ok then whiteImg = img end
  return whiteImg
end

-- ------- particle textures, generated once
local function makeTex()
  -- A mote is a SOLID little disc whose edge darkens, not a soft one
  -- whose edge fades.  Dithering an alpha falloff at this size produced a
  -- sparse stipple that read as noise rather than as light -- the whole
  -- point of a firefly is that it is a small bright dot.
  local function dot(r, g, b, soft)
    local ok, img = pcall(function()
      local S = 8
      local data = love.image.newImageData(S, S)
      for y = 0, S - 1 do
        for x = 0, S - 1 do
          local dx, dy = (x - 3.5) / 3.5, (y - 3.5) / 3.5
          local d = math.sqrt(dx * dx + dy * dy)
          local a, k = 0, 1
          if d < 0.45 then a, k = 1, 1            -- the core, full bright
          elseif d < 0.75 then a, k = 1, 0.72     -- a rim, dimmer
          elseif d < 0.95 then a, k = 1, 0.42     -- and a darker edge
          end
          data:setPixel(x, y, r * k, g * k, b * k, a)
        end
      end
      local i = love.graphics.newImage(data)
      i:setFilter("nearest", "nearest")
      return i
    end)
    return ok and img or nil
  end
  -- a leaf is a flat flake rather than a dot: four pixels wide, so it
  -- catches the eye as it tumbles
  local function flake(r, g, b)
    local ok, img = pcall(function()
      local S = 8
      local data = love.image.newImageData(S, S)
      for y = 0, S - 1 do
        for x = 0, S - 1 do
          local inLeaf = (y >= 3 and y <= 4 and x >= 1 and x <= 6)
                      or (y >= 2 and y <= 5 and x >= 2 and x <= 5)
          data:setPixel(x, y, r, g, b, inLeaf and 1 or 0)
        end
      end
      local i = love.graphics.newImage(data)
      i:setFilter("nearest", "nearest")
      return i
    end)
    return ok and img or nil
  end
  return {
    seed  = dot(0.55, 0.78, 0.35, false),
    drip  = dot(0.62, 0.78, 0.95, true),
    fly   = dot(1.0, 0.95, 0.45, true),
    leaf  = flake(0.78, 0.62, 0.22),
    -- the lifted trees drop GREEN leaves: fresh off a living crown,
    -- where the forest's amber ones have been down a while
    tleaf = flake(0.36, 0.66, 0.26),
    dust  = dot(0.95, 0.92, 0.80, true),
    foam  = dot(0.92, 0.96, 1.0, true),
    dropb = dot(0.55, 0.75, 0.95, true),  -- thrown water, not foam
    smoke = dot(0.72, 0.72, 0.70, true),
  }
end

local function makeQuad()
  local verts = {
    { -0.5, 0.5, 0, 0, 0, 1 }, { 0.5, 0.5, 0, 1, 0, 1 },
    { 0.5, -0.5, 0, 1, 1, 1 }, { -0.5, -0.5, 0, 0, 1, 1 },
  }
  local indexMap = {}
  Voxel3D.pushQuad(indexMap, 0)
  return Voxel3D.newMesh(verts, indexMap)
end

local function spawn(kind, x, y, z, vx, vy, vz, life, size)
  parts = parts or {}
  local slot = nil
  for i = 1, POOL do
    local p = parts[i]
    if not p or p.life <= 0 then slot = i; break end
  end
  if not slot then return end
  parts[slot] = { kind = kind, x = x, y = y, z = z, vx = vx, vy = vy,
                  vz = vz, life = life, max = life, size = size }
  -- returned so a caller can attach its own fields (a gnat's swarm and
  -- orbit) without hunting back through the pool for the one it just made
  return parts[slot]
end

-- ------- the map's features, found once: where smoke rises, where spray
-- lifts, where a rustle can happen.  A chimney is the north-west corner
-- of each roof cluster -- one per building, stable, and always the part
-- of a Gen 1 roof that reads as its top.
local function scanFeatures(map)
  local wc, hc = map.widthCells or 0, map.heightCells or 0
  local out = { chimneys = {}, shores = {}, grass = {} }
  local shapes = nil
  if okTS and TileShape then
    local ok, sh = pcall(TileShape.forMap, map)
    if ok then shapes = sh end
  end
  local roof, solidAt = {}, {}
  for cy = 0, hc - 1 do
    for cx = 0, wc - 1 do
      -- grass
      local okG, g = pcall(function() return map:isGrassCell(cx, cy) end)
      if okG and g then out.grass[#out.grass + 1] = { cx, cy } end
      -- shoreline: dry land touching water
      local okW, w = pcall(function() return map:isWaterCell(cx, cy) end)
      if okW and not w then
        for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
          local okN, nw = pcall(function()
            return map:isWaterCell(cx + d[1], cy + d[2])
          end)
          if okN and nw then
            out.shores[#out.shores + 1] = { cx, cy }
            break
          end
        end
      end
      -- Buildings, for chimneys.  Asking TileShape for class "roof"
      -- found NOTHING in the real game -- the same trap the canopy fell
      -- into with class "tree" -- so a building is identified by its
      -- shape instead: a solid block of unwalkable cells at least two by
      -- two.  Trees and fences are unwalkable too, but they are thin;
      -- almost nothing except a building is square and solid.
      local okW, walk = pcall(function() return map:isWalkableCell(cx, cy) end)
      if okW and not walk then solidAt[cy * wc + cx] = true end
      if shapes then
        local okT, tile = pcall(function()
          return map:tileAt(cx * 2, cy * 2)
        end)
        tile = okT and tile or nil
        if tile then
          local okS, sh = pcall(TileShape.at, map, shapes, tile,
                                cx * 2, cy * 2)
          if okS and sh and sh.class == "roof" then roof[cy * wc + cx] = true end
        end
      end
    end
  end
  -- Prefer the class where it exists.  Where it does not, a solid 2x2
  -- was the test -- and a solid 2x2 is also a clump of trees, a rock, a
  -- fence corner or a hedge, which is why smoke was rising off the
  -- scenery.  A BUILDING has a DOOR: find the doors, walk up from each
  -- into the solid block above it, and smoke THAT.  Nothing else counts.
  local body = roof
  if not next(body) then
    for cy = 0, hc - 1 do
      for cx = 0, wc - 1 do
        local okD, door = pcall(function()
          return map.isDoorTileCell and map:isDoorTileCell(cx, cy)
        end)
        if okD and door then
          -- the roof sits above the doorway: climb until the solid runs
          -- out, and put the chimney on the last solid cell
          local top = nil
          for up = 1, 4 do
            if solidAt[(cy - up) * wc + cx] then top = cy - up else break end
          end
          if top then body[top * wc + cx] = true end
        end
      end
    end
  end

  -- one chimney per cluster: the cell with nothing of the same kind to
  -- its west or north, so a building smokes once rather than per tile
  for key in pairs(body) do
    local cy = math.floor(key / wc)
    local cx = key % wc
    if not body[cy * wc + (cx - 1)] and not body[(cy - 1) * wc + cx] then
      out.chimneys[#out.chimneys + 1] = { cx, cy }
    end
  end
  return out
end

-- Each of these was inlined in Flora.draw until the closure hit
-- LuaJIT's 60-upvalue ceiling; they are lifted out so the draw stays
-- inside it, and so each effect can be read on its own.

local function drawRain(state, cfg, px, pz, yaw, t, dt, raining)
  -- ---------- rain, and the umbrellas that answer it
  local rainNote = ""
  if raining then
    dropImg = dropImg or makeDrop()
    umbrellaImg = umbrellaImg or makeUmbrella()
    partMesh = partMesh or makeQuad()
    drops = drops or {}
    if dropImg and partMesh then
      guarded(function()
        love.graphics.setDepthMode("lequal", false)
        -- drops live in a ring around the eye and recycle upward: the
        -- shower travels with you, which is what a shower looks like
        local count = storm and STORM_DROPS or RAIN_DROPS
        for i = 1, math.min(count, RAIN_DROPS * 2) do
          local d = drops[i]
          if not d then
            local a = math.random() * math.pi * 2
            d = { x = math.cos(a) * math.random() * RAIN_RADIUS,
                  z = math.sin(a) * math.random() * RAIN_RADIUS,
                  y = math.random() * RAIN_TOP, splash = 0 }
            drops[i] = d
          end
          if d.splash > 0 then
            d.splash = d.splash - dt
            if d.splash <= 0 then
              local a = math.random() * math.pi * 2
              d.x, d.z = math.cos(a) * math.random() * RAIN_RADIUS,
                         math.sin(a) * math.random() * RAIN_RADIUS
              d.y = RAIN_TOP
            end
          else
            d.y = d.y - RAIN_FALL * (storm and 1.35 or 1) * dt
            if d.y <= 1 then d.y, d.splash = 1, 0.10 end
          end
          local sx = d.splash > 0 and 3.5 or 1.6
          local sy = d.splash > 0 and 1.2 or 9
          Voxel3D.draw(partMesh, dropImg,
                       Mat4.mul(Mat4.mul(
                         Mat4.translate(px + d.x, d.y, pz + d.z),
                         Mat4.rotateY(-yaw)), Mat4.scale(sx, sy, 1)))
        end

        -- an umbrella over every NPC, bobbing with their step
        if umbrellaImg and cfg.umbrellas ~= false then
          local me = state.player
          for _, e in ipairs(state.entities or {}) do
            local human = true
            -- pokeballs, boulders, fossils and loose pokemon do not
            -- carry umbrellas (field report). The sprite def names the
            -- occupant; anything matching the non-human list stays
            -- rained on. Unknown or unnameable sprites keep the brolly
            -- -- a dry stranger beats a wet townsperson.
            local okP, sp = pcall(function() return e:pose() end)
            local nm = okP and sp and sp.def
                       and tostring(sp.def.name or sp.def.id or "") or ""
            if nm ~= "" then
              nm = nm:upper()
              for _, bad in ipairs({ "BALL", "BOULDER", "FOSSIL",
                  "AMBER", "PAPER", "CLIPBOARD", "BOOK", "SNORLAX",
                  "MONSTER", "SLOWBRO", "FEAROW", "PIDGEY", "SEEL",
                  "ODDISH", "MACHOP", "VOLTORB", "CUBONE",
                  "KANGASKHAN", "OMANYTE", "LAPRAS", "ZAPDOS",
                  "ARTICUNO", "MOLTRES", "MEWTWO", "MEW", "PIKACHU",
                  "CLEFAIRY", "JIGGLYPUFF", "MACHOKE", "GRIMER" }) do
                if nm:find(bad, 1, true) then human = false break end
              end
            end
            if human and e ~= me and e.px and e.py then
              local bob = math.sin((e.px + e.py) * 0.2 + t * 6) * 0.6
              Voxel3D.draw(partMesh, umbrellaImg,
                           Mat4.mul(Mat4.mul(
                             Mat4.translate(e.px + 8, UMBRELLA_H + bob,
                                            e.py + 8),
                             Mat4.rotateY(-yaw)), Mat4.scale(15, 15, 1)))
            end
          end
        end
        love.graphics.setDepthMode("lequal", true)
      end)
      rainNote = ", raining"
    end
  elseif drops then
    drops = nil
  end
  return rainNote
end

local function drawShafts(map, cfg, px, pz, t, raining)
  -- ---------- sun shafts under the canopy
  local shaftNote = ""
  if cfg.shafts ~= false and isCanopy(map) and not raining then
    shaftMesh = shaftMesh or buildShafts()
    if shaftMesh then
      guarded(function()
        love.graphics.setDepthMode("lequal", false)
        love.graphics.setColor(1, 0.98, 0.82, 0.16)
        -- the wood breathes: the shafts drift on a slow clock
        Voxel3D.draw(shaftMesh, white(),
                     Mat4.mul(Mat4.translate(px, 0, pz),
                              Mat4.rotateY(math.sin(t * 0.05) * 0.12)))
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setDepthMode("lequal", true)
      end)
      shaftNote = ", shafts"
    end
  end
  return shaftNote
end

local function drawFog(map, cfg, px, pz, dt)
  -- ---------- fog on the maps that deserve it -- EASED now, not
  -- switched. The envelope climbs over ~2.5s on entering a fog map
  -- and falls over ~4s on leaving, so the transition breathes instead
  -- of popping (issue #6). The lingering exit reads as walking OUT of
  -- fog. The same envelope is published for the veil pipeline, which
  -- is what actually dims the sprites: these world-space shells draw
  -- before the cast pass and can never cover a billboard.
  local fogNote = ""
  local mapId = map.def and (map.def.id or map.def.name)
  local want = (cfg.fog ~= false and mapId and FOG_MAPS[tostring(mapId)])
               and 1 or 0
  local env = MOUND.fogEnv or 0
  if want > env then env = math.min(want, env + (dt or 0) * 0.4)
  else env = math.max(want, env - (dt or 0) * 0.25) end
  MOUND.fogEnv = env
  _G.__ds_lavfog = env
  if env > 0.01 then
    shellMesh = shellMesh or buildShells()
    if shellMesh then
      guarded(function()
        love.graphics.setDepthMode("lequal", false)
        -- the same shells as the cave dark, but pale: distance whitens
        love.graphics.setColor(0.78, 0.76, 0.84, 0.55 * env)
        Voxel3D.draw(shellMesh, white(),
                     Mat4.mul(Mat4.translate(px, 0, pz),
                              Mat4.scale(1.6, 1, 1.6)))
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setDepthMode("lequal", true)
      end)
      fogNote = (", fog %.2f"):format(env)
    end
  end
  return fogNote
end

-- Lamplight: only where it is dark enough to matter -- after dark
-- outdoors, and in unlit caves at any hour.
local function drawLights(map, cfg, px, pz, yaw, t, outdoor, dark)
  if cfg.lights == false then return "" end
  local wantLight = dark or (outdoor and isNight())
  if not wantLight then return "" end
  if not lightCache or lightCache.map ~= map then
    if lightCache and lightCache.built and lightCache.built.mesh then
      pcall(lightCache.built.mesh.release, lightCache.built.mesh)
    end
    local built, n = buildLight(map)
    lightCache = { map = map, built = built, count = n or 0 }
  end
  if not (lightCache.built and lightCache.built.mesh) then return "" end
  local flicker = 0.94 + 0.06 * math.sin(t * 3.1)
  guarded(function()
    love.graphics.setDepthMode("lequal", false)
    -- additive, so lamplight lightens the rock instead of tinting it
    local okB = pcall(love.graphics.setBlendMode, "add")
    love.graphics.setColor(LIGHT_WARM[1] * 0.40 * flicker,
                           LIGHT_WARM[2] * 0.34 * flicker,
                           LIGHT_WARM[3] * 0.20 * flicker, 1.0)
    Voxel3D.draw(lightCache.built.mesh, white(), nil)
    if okB then pcall(love.graphics.setBlendMode, "alpha") end
    -- and the lamps themselves, so the light has a visible source: a
    -- small ROUND mote, not the square pane the windows used to use
    local lampImg = tex and tex.fly
    if partMesh and lampImg then
      for _, srcCell in ipairs(lightCache.built.sources) do
        local lx, lz = srcCell[1] * 16 + 8, srcCell[2] * 16 + 8
        if math.abs(lx - px) < 320 and math.abs(lz - pz) < 320 then
          love.graphics.setColor(1, 1, 1, 0.9 * flicker)
          Voxel3D.draw(partMesh, lampImg,
                       Mat4.mul(Mat4.mul(
                         Mat4.translate(lx, LAMP_HEIGHT, lz),
                         Mat4.rotateY(-yaw)), Mat4.scale(5, 5, 1)))
        end
      end
    end
  end)
  return (", %d lamps"):format(lightCache.count)
end

-- Everything the cave has that a room does not, drawn in one pass.
local function drawCave(map, cfg, px, pz, yaw, t, dt, dark, partMesh)
  if not dark then
    bats, batsAt = nil, nil
    return ""
  end
  local note = ""

  -- ---- still water
  if cfg.pools ~= false then
    if not poolCache or poolCache.map ~= map then
      if poolCache and poolCache.mesh then
        pcall(poolCache.mesh.release, poolCache.mesh)
      end
      local mesh, n = buildPools(map)
      poolCache = { map = map, mesh = mesh, count = n or 0 }
    end
    if poolCache.mesh then
      guarded(function()
        love.graphics.setDepthMode("lequal", false)
        love.graphics.setColor(0.52, 0.66, 0.86, 0.85)
        Voxel3D.draw(poolCache.mesh, white(), nil)
      end)
      note = note .. (", %d pools"):format(poolCache.count)
    end
  end

  -- ---- torches: a flame, and the light it throws on the rock
  if cfg.sconces ~= false and partMesh then
    if not sconceCache or sconceCache.map ~= map then
      sconceCache = { map = map, list = buildSconces(map) }
    end
    local lit = 0
    guarded(function()
      love.graphics.setDepthMode("lequal", false)
      for i, sc in ipairs(sconceCache.list) do
        if math.abs(sc[1] - px) < 240 and math.abs(sc[2] - pz) < 240 then
          -- each flame on its own guttering clock
          local f = 0.78 + 0.22 * math.sin(t * (5 + (i % 4)) + i)
          local sz = 6 + f * 2.5
          love.graphics.setColor(1.0, 0.72 + 0.12 * f, 0.34, 0.92)
          Voxel3D.draw(partMesh, tex and tex.fly or white(),
                       Mat4.mul(Mat4.mul(
                         Mat4.translate(sc[1], SCONCE_Y, sc[2]),
                         Mat4.rotateY(-yaw)), Mat4.scale(sz, sz * 1.5, 1)))
          lit = lit + 1
        end
      end
    end)
    if lit > 0 then note = note .. (", %d torches"):format(lit) end
  end

  -- ---- bats: roosting, then not
  if cfg.bats ~= false and partMesh and loadBatPics() then
    if not bats or batsAt ~= map or (t - (bats.born or 0)) > BAT_LIFE then
      bats = { born = t, list = {} }
      batsAt = map
      for r = 1, BAT_ROOSTS do
        local a = math.random() * math.pi * 2
        local rad = 90 + math.random() * 160
        local rx, rz = px + math.cos(a) * rad, pz + math.sin(a) * rad
        for _ = 1, BAT_PER_ROOST do
          bats.list[#bats.list + 1] = {
            x = rx + (math.random() - 0.5) * 34,
            z = rz + (math.random() - 0.5) * 34,
            y = BAT_Y - math.random() * 3,
            phase = math.random() * 6.28, up = false,
            vx = 0, vy = 0, vz = 0,
          }
        end
      end
    end
    local flying = 0
    guarded(function()
      love.graphics.setDepthMode("lequal", false)
      love.graphics.setColor(1, 1, 1, 1)
      for _, b in ipairs(bats.list) do
        local dx, dz = b.x - px, b.z - pz
        if not b.up and (dx * dx + dz * dz) < BAT_FLUSH * BAT_FLUSH then
          -- one bat waking wakes the roost
          for _, o in ipairs(bats.list) do o.up = true end
        end
        if b.up then
          if b.vy == 0 then
            local ang = math.atan2(b.z - pz, b.x - px)
                        + (math.random() - 0.5) * 1.6
            b.vx = math.cos(ang) * (46 + math.random() * 40)
            b.vz = math.sin(ang) * (46 + math.random() * 40)
            b.vy = -14 - math.random() * 10      -- they drop before they climb
          end
          b.x = b.x + b.vx * dt
          b.z = b.z + b.vz * dt
          b.y = b.y + b.vy * dt
          b.vy = b.vy + 34 * dt                  -- and then climb, hard
          -- an erratic flutter, because bats do not fly in lines
          b.x = b.x + math.sin(t * 9 + b.phase) * 14 * dt
          b.z = b.z + math.cos(t * 8 + b.phase) * 14 * dt
        else
          b.y = BAT_Y - 1.5 + math.sin(t * 1.4 + b.phase) * 0.6
        end
        if b.y > 4 and b.y < 90 then
          flying = flying + 1
          local beat = (t + b.phase) * 9
          local img = ((math.floor(beat) % 2) == 0) and batPics.a or batPics.b
          local size = b.up and 9 or 7
          Voxel3D.draw(partMesh, img,
                       Mat4.mul(Mat4.mul(Mat4.translate(b.x, b.y, b.z),
                                         Mat4.rotateY(-yaw)),
                                Mat4.scale(size, size, 1)))
        end
      end
    end)
    if flying > 0 then
      note = note .. (", %d bats%s"):format(flying,
                       bats.list[1] and bats.list[1].up and " UP" or "")
    end
  end
  return note
end

-- Puddles fill while it rains and dry slowly afterwards; the mesh itself
-- is built once per map and simply faded.
local function drawPuddles(map, cfg, raining, dt, atlasFor, outdoor)
  if cfg.puddles == false then return "" end
  -- Rain does not fall indoors, and neither should puddles lie there.
  -- The ground still dries while you are inside, so stepping out after a
  -- long visit finds the street drying rather than frozen wet.
  if not outdoor then
    wetness = math.max(0, wetness - dt / PUDDLE_DRY)
    return ""
  end
  wetness = math.max(0, math.min(1, wetness
    + (raining and (dt / PUDDLE_FILL) or -(dt / PUDDLE_DRY))))

  -- Built as soon as the map is known rather than at the moment the
  -- puddles first show: constructing a few hundred quads mid-walk is a
  -- hitch you can feel, and it landed exactly when they appeared.
  if not puddleCache or puddleCache.map ~= map then
    if puddleCache and puddleCache.mesh then
      for _, grp in ipairs(puddleCache.mesh) do
        pcall(grp.mesh.release, grp.mesh)
      end
    end
    local mesh, n = buildPuddles(map)
    puddleCache = { map = map, mesh = mesh, count = n or 0 }
  end
  if wetness <= 0.01 then return "" end
  if not puddleCache.mesh then return "" end
  local tx = nil
  if atlasFor then
    local okT, a = pcall(atlasFor, map)
    if okT then tx = a end
  end
  guarded(function()
    love.graphics.setDepthMode("lequal", false)
    for _, grp in ipairs(puddleCache.mesh) do
      -- each group eases in over its own quarter of the filling, so
      -- puddles gather across a street instead of appearing together
      local local_f = (wetness - grp.at) / (1 / PUDDLE_GROUPS)
      local f = math.max(0, math.min(1, local_f))
      if f > 0.01 then
        love.graphics.setColor(0.78, 0.86, 1.0, 0.72 * f)
        Voxel3D.draw(grp.mesh, tx or white(), nil)
      end
    end
  end)
  return (", %d puddles %.0f%%"):format(puddleCache.count, wetness * 100)
end

-- The storm: strikes far apart, a partial and gentle brightening, and
-- everything eased rather than cut.  See the constants above for why.
local function drawStorm(cfg, px, pz, yaw, t, dt, partMesh)
  local note = ""
  if not storm then
    flash = math.max(0, flash - dt / FLASH_FADE)
    bolts = nil
    return note
  end
  if cfg.lightning ~= false then
    boltImgs = boltImgs or makeBolts()
    bolts = bolts or {}
    -- a hard floor between strikes, then a modest chance beyond it
    if boltImgs and (not boltAt or (t - boltAt) > BOLT_GAP_MIN)
       and math.random() < BOLT_CHANCE * dt then
      boltAt = t
      local a = math.random() * math.pi * 2
      bolts[#bolts + 1] = {
        x = px + math.cos(a) * BOLT_DIST,
        z = pz + math.sin(a) * BOLT_DIST,
        img = boltImgs[math.random(#boltImgs)],
        life = BOLT_LIFE,
      }
      -- the brightening is a fraction of a white-out, and eases away
      flash = FLASH_MAX
    end
  end

  if bolts and #bolts > 0 and partMesh then
    guarded(function()
      love.graphics.setDepthMode("lequal", false)
      for i = #bolts, 1, -1 do
        local b = bolts[i]
        b.life = b.life - dt
        if b.life <= 0 then
          table.remove(bolts, i)
        else
          -- a bolt does not simply fade: it flickers down in two steps,
          -- which is what a real strike does and what stops it looking
          -- like a dissolve
          local f = b.life / BOLT_LIFE
          local a = (f > 0.75 and 1) or (f > 0.5 and 0.35)
                 or (f > 0.3 and 0.8) or f
          love.graphics.setColor(1, 1, 1, a)
          Voxel3D.draw(partMesh, b.img,
                       Mat4.mul(Mat4.mul(Mat4.translate(b.x, BOLT_Y, b.z),
                                         Mat4.rotateY(-yaw)),
                                Mat4.scale(190, 380, 1)))
          note = ", BOLT"
        end
      end
    end)
  end

  flash = math.max(0, flash - dt / FLASH_FADE)
  if flash > 0.001 and cfg.lightning ~= false then
    guarded(function()
      -- painted at the horizon rather than over the whole view: the sky
      -- lightens, the ground does not glare
      love.graphics.setDepthMode("lequal", false)
      love.graphics.setColor(1, 1, 1, flash)
      Voxel3D.draw(partMesh, white(), Mat4.mul(
        Mat4.mul(Mat4.translate(px, 260, pz), Mat4.rotateY(-yaw)),
        Mat4.scale(2400, 900, 1)))
    end)
  end
  return note .. (storm and ", STORM" or "")
end

-- Where the strands hang, worked out once per wood: under cells the
-- canopy actually covers, at the canopy's own height.
local function seedVines(map)
  local wc, hc = map.widthCells or 0, map.heightCells or 0
  local out = {}
  for cy = -CANOPY_RING, hc - 1 + CANOPY_RING do
    for cx = -CANOPY_RING, wc - 1 + CANOPY_RING do
      if math.floor(hash01(cx, cy, 191) * VINE_EVERY) == 0 then
        local hang = CANOPY_LOW + hash01(cx, cy, 193)
                     * (CANOPY_HIGH - CANOPY_LOW)
        out[#out + 1] = {
          x = cx * 16 + 3 + hash01(cx, cy, 197) * 10,
          z = cy * 16 + 3 + hash01(cy, cx, 199) * 10,
          y = hang - 1,
          len = VINE_MIN + hash01(cx, cy, 211) * (VINE_MAX - VINE_MIN),
          ang = hash01(cx, cy, 223) * math.pi,
          phase = hash01(cy, cx, 227) * 6.28,
          rate = 0.6 + hash01(cx, cy, 229) * 0.7,
          ox = 0, oz = 0, vx = 0, vz = 0,   -- brush state
        }
      end
    end
  end
  return out
end

-- The strands themselves: idle sway for all of them, a shove for any the
-- player walks through, and a spring back afterwards.
local function drawVines(map, cfg, px, pz, t, dt, sealed, moved)
  if cfg.vines == false or not sealed then return "" end
  if not isCanopy(map) then return "" end
  vineImg = vineImg or makeVine()
  vineMesh = vineMesh or makeVineMesh()
  if not (vineImg and vineMesh) then return "" end
  if not vines or vines.map ~= map then
    vines = seedVines(map)
    vines.map = map
  end

  local shown = 0
  guarded(function()
    love.graphics.setDepthMode("lequal", true)
    for _, v in ipairs(vines) do
      local dx, dz = v.x - px, v.z - pz
      local d2 = dx * dx + dz * dz
      if d2 < VINE_VIEW * VINE_VIEW then
        -- brushed: shoved away from the player, harder the faster you go
        if d2 < BRUSH_R * BRUSH_R and moved > 0.2 then
          local d = math.max(1, math.sqrt(d2))
          local push = BRUSH_PUSH * math.min(3, moved)
          v.vx = v.vx + (dx / d) * push
          v.vz = v.vz + (dz / d) * push
        end
        -- a damped spring back to hanging straight
        v.vx = v.vx + (-SPRING * v.ox - DAMP * v.vx) * dt
        v.vz = v.vz + (-SPRING * v.oz - DAMP * v.vz) * dt
        v.ox = v.ox + v.vx * dt
        v.oz = v.oz + v.vz * dt
        -- idle sway on top, each strand on its own clock
        local sway = math.sin(t * v.rate + v.phase) * VINE_SWAY
        -- the mesh hangs from 0 down to -1, so a shear displaces the free
        -- end and leaves the anchor where the canopy holds it
        local kx = sway + v.ox * BRUSH_LEAN
        local kz = sway * 0.6 + v.oz * BRUSH_LEAN
        local model = Mat4.mul(
          Mat4.mul(Mat4.translate(v.x, v.y, v.z), shear(-kx, -kz)),
          Mat4.mul(Mat4.rotateY(v.ang), Mat4.scale(VINE_W, v.len, 1)))
        Voxel3D.draw(vineMesh, vineImg, model)
        shown = shown + 1
      end
    end
  end)
  return (", %d vines"):format(shown)
end

-- Lifted out of Flora.draw, which sits at LuaJIT's 60-upvalue ceiling.
local function drawTufts(map, cfg, atlasFor, t, outdoor)
  -- ---------- tufts
  local tuftNote = "no tufts"
  local perCell = BLADES[cfg.grass or "SUBTLE"] or 2
  if perCell > 0 and outdoor then
    local key = tostring(perCell)
    if not tuftCache or tuftCache.map ~= map or tuftCache.key ~= key then
      if tuftCache and tuftCache.mesh then
        pcall(tuftCache.mesh.release, tuftCache.mesh)
      end
      local mesh, note = buildTufts(map, perCell)
      tuftCache = { map = map, key = key, mesh = mesh, note = note }
    end
    if tuftCache.mesh then
      local tx = nil
      if atlasFor then
        local okT, a = pcall(atlasFor, map)
        if okT then tx = a end
      end
      local amp = WIND[cfg.wind or "BREEZE"] or 0
      guarded(function()
        for _, part in ipairs(tuftCache.mesh) do
          local model = nil
          if amp > 0 then
            -- a gust is a slow wave plus a faster flutter, so the grass
            -- never settles into an obvious sine
            local w = math.sin(t * WIND_RATE + part.phase) * 0.75
                    + math.sin(t * WIND_RATE * 2.7 + part.phase * 1.9) * 0.25
            local k = amp * w
            model = shear(math.cos(WIND_DIR) * k, math.sin(WIND_DIR) * k)
          end
          Voxel3D.draw(part.mesh, tx, model)
        end
      end)
      tuftNote = tuftCache.note .. (amp > 0 and ", wind" or "")
    else
      tuftNote = tuftCache.note or "no tufts"
    end
  end

  if not featureCache or featureCache.map ~= map then
    local ok, f = pcall(scanFeatures, map)
    featureCache = ok and f or { chimneys = {}, shores = {}, grass = {} }
    featureCache.map = map
  end
  return tuftNote
end

-- Particles were the last big block left inside Flora.draw; lifting it
-- out keeps that function under LuaJIT's 60-upvalue ceiling as features
-- accumulate.
local function drawParticles(state, map, cfg, px, pz, yaw, t, dt, outdoor,
                             treeCells)
  local live = 0
  if cfg.particles ~= false then
    tex = tex or makeTex()
    partMesh = partMesh or makeQuad()
    if tex and partMesh then
      -- emit: seeds while moving through grass
      local moved = movedThisFrame or 0
      local onGrass = false
      if outdoor then
        local cx, cy = math.floor(px / 16), math.floor(pz / 16)
        local okG, g = pcall(function() return map:isGrassCell(cx, cy) end)
        onGrass = okG and g or false
      end
      if onGrass and moved > 0.2 and tex.seed then
        local n = SEED_RATE * dt
        while n > 0 do
          if n < 1 and math.random() > n then break end
          local a = math.random() * math.pi * 2
          spawn("seed", px + (math.random() - 0.5) * 14, 4 + math.random() * 8,
                pz + (math.random() - 0.5) * 14,
                math.cos(a) * 6, 10 + math.random() * 14, math.sin(a) * 6,
                0.5 + math.random() * 0.4, 1.6 + math.random())
          n = n - 1
        end
      end
      -- drips in caves
      local tid = map.def and map.def.tileset
                  or (map.tileset and map.tileset.id)
      if tid == "CAVERN" and tex.drip and math.random() < DRIP_RATE * dt then
        spawn("drip", px + (math.random() - 0.5) * 150, 30,
              pz + (math.random() - 0.5) * 150, 0, -46, 0, 1.6, 2.2)
      end
      -- fireflies after dark
      if outdoor and isNight() and tex.fly then
        local flies = 0
        for i = 1, POOL do
          local q = parts and parts[i]
          if q and q.life > 0 and q.kind == "fly" then flies = flies + 1 end
        end
        if flies < FLY_TARGET and math.random() < 4 * dt then
          local a = math.random() * math.pi * 2
          local r = 40 + math.random() * 110
          spawn("fly", px + math.cos(a) * r, 6 + math.random() * 14,
                pz + math.sin(a) * r, 0, 0, 0, 4 + math.random() * 4, 1.8)
        end
      end

      -- leaves under the canopy: spawned high, ahead and around
      if isCanopy(map) and tex.leaf and math.random() < LEAF_RATE * dt then
        local a = math.random() * math.pi * 2
        local r = math.random() * 130
        spawn("leaf", px + math.cos(a) * r, 34 + math.random() * 20,
              pz + math.sin(a) * r,
              (math.random() - 0.5) * 8, -7 - math.random() * 5,
              (math.random() - 0.5) * 8, 5.5, 2.6)
      end

      -- green leaves letting go of the lifted trees' crowns: pick a
      -- random stem cell; trees within reach shed, everything else is
      -- a miss (which is what keeps the shower gentle)
      if treeCells and #treeCells > 0 and tex.tleaf then
        local n = TLEAF_RATE * dt
        while n > 0 do
          if n < 1 and math.random() > n then break end
          local c = treeCells[math.random(#treeCells)]
          if c[3] == "t" and c[4] then
            local mx, mz = c[1] * 16 + 8, c[2] * 16 + 8
            if math.abs(mx - px) < 180 and math.abs(mz - pz) < 180 then
              spawn("tleaf", mx + (math.random() - 0.5) * 11,
                    c[4] + 3 + math.random() * 6,
                    mz + (math.random() - 0.5) * 11,
                    (math.random() - 0.5) * 7, -6 - math.random() * 4,
                    (math.random() - 0.5) * 7, 4.5, 3.6)
            end
          end
          n = n - 1
        end
      end

      -- dust turning in interior air: kept topped up rather than emitted
      if not outdoor and tex.dust then
        local motes = 0
        for i = 1, POOL do
          local q = parts and parts[i]
          if q and q.life > 0 and q.kind == "dust" then motes = motes + 1 end
        end
        if motes < DUST_TARGET and math.random() < 6 * dt then
          local a = math.random() * math.pi * 2
          local r = 10 + math.random() * 70
          spawn("dust", px + math.cos(a) * r, 4 + math.random() * 22,
                pz + math.sin(a) * r, 0, 1.2, 0,
                6 + math.random() * 5, 1.1)
        end
      end

      -- spray at the water's edge: from the nearest shoreline cells
      local shores = featureCache and featureCache.shores or {}
      if #shores > 0 and tex.foam and math.random() < FOAM_RATE * dt then
        local pick = shores[math.random(#shores)]
        local sx, sz = pick[1] * 16 + 8, pick[2] * 16 + 8
        if math.abs(sx - px) < 190 and math.abs(sz - pz) < 190 then
          spawn("foam", sx + (math.random() - 0.5) * 14, 2,
                sz + (math.random() - 0.5) * 14,
                (math.random() - 0.5) * 5, 12 + math.random() * 10,
                (math.random() - 0.5) * 5, 0.75, 2.0)
        end
      end

      -- and, less often, a proper SPLASH: one spot on the waterline
      -- throws a small fountain -- half foam-white, half water-blue,
      -- fanned in a ring and pulled straight back down by the same
      -- gravity the spray already obeys. (Rate inline: this chunk sits
      -- at Lua's 200-local cap, so no new constant local.)
      if outdoor and #shores > 0 and tex.foam
         and math.random() < 0.9 * dt then
        local pick = shores[math.random(#shores)]
        local sx, sz = pick[1] * 16 + 8, pick[2] * 16 + 8
        if math.abs(sx - px) < 190 and math.abs(sz - pz) < 190 then
          for j = 1, 5 + math.random(3) do
            local a = math.random() * math.pi * 2
            local sp = 6 + math.random() * 12
            spawn((j % 2 == 0) and "foam" or "dropb",
                  sx + (math.random() - 0.5) * 6, 2,
                  sz + (math.random() - 0.5) * 6,
                  math.cos(a) * sp, 22 + math.random() * 16,
                  math.sin(a) * sp, 0.7 + math.random() * 0.5, 1.6)
          end
        end
      end

      -- chimney smoke: one plume per building, thinning as it climbs
      local chimneys = featureCache and featureCache.chimneys or {}
      if #chimneys > 0 and tex.smoke then
        for _, c in ipairs(chimneys) do
          local sx, sz = c[1] * 16 + 8, c[2] * 16 + 8
          if math.abs(sx - px) < 260 and math.abs(sz - pz) < 260
             and math.random() < SMOKE_RATE * dt then
            spawn("smoke", sx + (math.random() - 0.5) * 4, 26,
                  sz + (math.random() - 0.5) * 4,
                  (math.random() - 0.5) * 3, 9 + math.random() * 4,
                  (math.random() - 0.5) * 3, 2.6, 2.4)
          end
        end
      end

      -- the rustle: a distant tuft shudders, with nothing in it
      local grass = featureCache and featureCache.grass or {}
      if outdoor and #grass > 0 and tex.seed
         and math.random() < RUSTLE_CHANCE * dt then
        local pick = grass[math.random(#grass)]
        local gx, gz = pick[1] * 16 + 8, pick[2] * 16 + 8
        local d = math.abs(gx - px) + math.abs(gz - pz)
        if d > 40 and d < 260 then
          for _ = 1, 5 do
            local a = math.random() * math.pi * 2
            spawn("seed", gx + (math.random() - 0.5) * 10, 5,
                  gz + (math.random() - 0.5) * 10,
                  math.cos(a) * 9, 16 + math.random() * 10, math.sin(a) * 9,
                  0.55, 1.7)
          end
        end
      end

      -- Footfall in the wet: walking through rain kicks a little water
      -- up off the ground, harder once the puddles have filled.  It is
      -- the small thing that ties the weather to you rather than to the
      -- scenery.
      if raining and tex.foam then
        local moved2 = movedThisFrame or 0
        if moved2 > 0.2 and math.random() < (10 + 14 * wetness) * dt then
          local a = math.random() * math.pi * 2
          spawn("foam", px + (math.random() - 0.5) * 7, 1,
                pz + (math.random() - 0.5) * 7,
                math.cos(a) * (7 + math.random() * 9),
                14 + math.random() * 12,
                math.sin(a) * (7 + math.random() * 9),
                0.36, 1.3 + math.random() * 0.7)
        end
      end

      -- Gnats: a swarm is a COLUMN of air that insects orbit, not a
      -- scatter of independent motes -- which is what makes a cloud of
      -- them read as one thing hanging over a patch of grass.  Over
      -- grass by day; under the canopy at any hour, where the light is
      -- doing something anyway.
      if cfg.insects ~= false and tex.fly
         and (isCanopy(map) or (outdoor and not isNight())) then
        local grassCells = featureCache and featureCache.grass or {}
        if not swarms or #swarms == 0 or math.random() < 0.15 * dt then
          swarms = {}
          for i = 1, SWARMS do
            local hx, hz
            if #grassCells > 0 then
              local pick = grassCells[math.random(#grassCells)]
              hx, hz = pick[1] * 16 + 8, pick[2] * 16 + 8
            else
              local a = math.random() * math.pi * 2
              local r = 40 + math.random() * SWARM_RANGE
              hx, hz = px + math.cos(a) * r, pz + math.sin(a) * r
            end
            swarms[i] = { x = hx, z = hz,
                          y = isCanopy(map) and (26 + math.random() * 16)
                              or (10 + math.random() * 10),
                          r = 5 + math.random() * 6 }
          end
        end
        for si, sw in ipairs(swarms) do
          if math.abs(sw.x - px) < 260 and math.abs(sw.z - pz) < 260 then
            local living = 0
            for i = 1, POOL do
              local q = parts and parts[i]
              if q and q.life > 0 and q.kind == "gnat" and q.swarm == si then
                living = living + 1
              end
            end
            if living < GNATS_PER_SWARM and math.random() < 8 * dt then
              local q = spawn("gnat", sw.x, sw.y, sw.z, 0, 0, 0,
                              3 + math.random() * 4, 0.9)
              if q then
                q.swarm = si
                q.phase = math.random() * 6.28
                q.orbit = sw.r * (0.4 + math.random() * 0.8)
                q.rate = 1.6 + math.random() * 2.4
              end
            end
          end
        end
      end

      -- integrate and draw
      guarded(function()
        love.graphics.setDepthMode("lequal", false)
        for i = 1, POOL do
          local q = parts and parts[i]
          if q and q.life > 0 then
            q.life = q.life - dt
            if q.kind == "seed" then
              q.vy = q.vy - 34 * dt
              q.x = q.x + q.vx * dt
              q.y = q.y + q.vy * dt
              q.z = q.z + q.vz * dt
              if q.y < 1 then q.y, q.vy = 1, 0 end
            elseif q.kind == "drip" then
              q.vy = q.vy - 40 * dt
              q.y = q.y + q.vy * dt
              if q.y <= 1 then
                -- the splash: a brief flat flare, then gone
                q.y, q.vy, q.life = 1, 0, math.min(q.life, 0.12)
                q.size = 3.2
              end
            elseif q.kind == "leaf" or q.kind == "tleaf" then
              -- tumbling fall: sideways drift reverses on its own clock
              local ph = i * 0.9
              q.x = q.x + (q.vx + math.sin(t * 1.4 + ph) * 9) * dt
              q.z = q.z + (q.vz + math.cos(t * 1.1 + ph) * 9) * dt
              q.y = q.y + q.vy * dt
              if q.y < 1 then q.life = 0 end
            elseif q.kind == "gnat" then
              -- a tight, fast orbit of its swarm column, on its own clock
              local sw = swarms and swarms[q.swarm or 0]
              if sw then
                local a = t * (q.rate or 2) + (q.phase or 0)
                q.x = sw.x + math.cos(a) * (q.orbit or 4)
                q.z = sw.z + math.sin(a * 1.3) * (q.orbit or 4)
                q.y = sw.y + math.sin(a * 2.1) * 3
              else
                q.life = 0
              end
            elseif q.kind == "dust" then
              local ph = i * 2.3
              q.x = q.x + math.sin(t * 0.35 + ph) * 3 * dt
              q.z = q.z + math.cos(t * 0.28 + ph) * 3 * dt
              q.y = q.y + q.vy * dt * 0.4
            elseif q.kind == "foam" or q.kind == "dropb" then
              q.vy = q.vy - 40 * dt
              q.x = q.x + q.vx * dt
              q.y = q.y + q.vy * dt
              q.z = q.z + q.vz * dt
              if q.y < 1 then q.life = 0 end
            elseif q.kind == "smoke" then
              -- rises, slows, and spreads as it goes
              q.vy = q.vy * (1 - 0.5 * dt)
              q.x = q.x + q.vx * dt
              q.y = q.y + q.vy * dt
              q.z = q.z + q.vz * dt
              q.size = q.size + 2.2 * dt
            else -- fly: a slow bob on its own clock
              local ph = i * 1.7
              q.x = q.x + math.sin(t * 0.7 + ph) * 8 * dt
              q.z = q.z + math.cos(t * 0.5 + ph) * 8 * dt
              q.y = q.y + math.sin(t * 1.9 + ph) * 5 * dt
            end
            if q.life > 0 then
              live = live + 1
              local fade = math.min(1, q.life / (q.max * 0.5))
              local s = q.size * (0.6 + 0.4 * fade)
              -- fireflies pulse; the others simply shrink as they die
              if q.kind == "fly" then
                s = q.size * (0.7 + 0.5 * math.abs(math.sin(t * 3 + i)))
              elseif q.kind == "smoke" or q.kind == "dust" then
                s = q.size    -- these thin out by growing, not by shrinking
              end
              local img = tex[q.kind] or (q.kind == "gnat" and tex.fly)
                       or tex.seed
              Voxel3D.draw(partMesh, img,
                           Mat4.mul(Mat4.mul(Mat4.translate(q.x, q.y, q.z),
                                             Mat4.rotateY(-yaw)),
                                    Mat4.scale(s, s, 1)))
            end
          end
        end
        love.graphics.setDepthMode("lequal", true)
      end)
    end
  end

  -- ---------- the weather clock: dry spells broken by showers
  local rainMode = cfg.rain or "SOMETIMES"
  local wantRain = false
  if rainMode == "ALWAYS" then
    wantRain = true
  elseif rainMode ~= "OFF" then
    if not dryUntil and not rainUntil then
      dryUntil = t + DRY_MIN + math.random() * (DRY_MAX - DRY_MIN)
    end
    if rainUntil then
      if t > rainUntil then
        rainUntil = nil
        dryUntil = t + DRY_MIN + math.random() * (DRY_MAX - DRY_MIN)
      else
        wantRain = true
      end
    elseif dryUntil and t > dryUntil then
      dryUntil = nil
      rainUntil = t + WET_MIN + math.random() * (WET_MAX - WET_MIN)
      wantRain = true
      -- a shower occasionally arrives as something bigger
      storm = math.random() < STORM_ODDS
    end
  end
  if rainMode == "ALWAYS" and not rainUntil then storm = storm end
  if not wantRain then storm = false end
  raining = wantRain and outdoor
  -- Published for the sky layer: a rainbow belongs to the moment a
  -- shower ENDS, and the weather clock lives here.
  local was = rawget(_G, "__ds_weather") or {}
  _G.__ds_weather = {
    raining = raining,
    storm = raining and storm or false,
    wetness = wetness,
    stoppedAt = (was.raining and not raining) and t or was.stoppedAt,
  }
  local rainNote = ""

  return live
end

-- ------- the draw
-- If the companion mod has been deleted, its config bridge is gone and
-- this module is an orphan: draw nothing. The ceiling module does the
-- actual clean-up; this just keeps quiet in the meantime.
local function abandoned()
  return rawget(_G, "__ds_ceiling_config") == nil
end


-- ------------------------------------------------------------------
-- AMBIENCE.  One looping bed per kind of place -- cave, forest, town,
-- route -- crossfaded as you move between them, silent indoors.  The
-- files ride the same pipeline as the poster sheets: installed into
-- Dramatic Shape's lib folder and streamed from there, so a missing
-- file costs its bed and nothing else.
--
-- WHICH BED a map wants is decided the way the rest of this module
-- decides everything: tileset first (CAVERN and FOREST are authored),
-- then the map's own id for the outdoor split -- TOWN/CITY ids get the
-- town bed, everything else outdoors is a route.  Interiors fade all
-- four out rather than stopping dead, so walking into a Mart sounds
-- like a door closing behind you.
--
-- THE WATCHDOG.  Flora.draw only runs while a voxel rung is live, so
-- dropping to 2D (or the mode failing) would strand the beds playing
-- forever.  A once-only wrap of love.update watches for the heartbeat
-- Flora.draw leaves each frame and fades everything out when it stops.
-- zero new top-level locals: this main chunk sits exactly at Lua's
-- 200-local cap, so the whole feature hangs off MOUND, which exists
MOUND.AMB = { srcs = {}, beat = -1e9,
              FILES = { cave = "amb-cave.mp3", forest = "amb-forest.mp3",
                        town = "amb-town.mp3", route = "amb-route.mp3",
                        g1 = "sfx-grass1.mp3", g2 = "sfx-grass2.mp3",
                        door = "sfx-door.mp3",
                        shopdoor = "sfx-shopdoor.mp3",
                        cstep = "sfx-cavestep.mp3",
                        wstep = "sfx-woodstep.mp3",
                        water = "amb-water.mp3",
                        night = "amb-night.mp3",
                        rain = "amb-rain.mp3" },
              -- the beds loop; the steps and doors are one-shots.
              -- water is a bed apart: its volume follows the shore
              -- rather than the crossfade, lapping louder the closer
              -- the player stands to the waterline
              LOOPS = { cave = true, forest = true,
                        town = true, route = true, water = true,
                        night = true, rain = true },
              -- named volumes for the AMBIENT SOUND row; MID is the
              -- default and noticeably hotter than 1.51.0's fixed 0.35,
              -- which playtested too quiet under the game's own music
              VOLS = { LOW = 0.35, MID = 0.62, HIGH = 0.92 },
              STEP_VOL = 0.85,        -- the grass steps, over the bed
              UP = 0.30, DOWN = 0.55 } -- volume per second, in and out

function MOUND.AMB.src(k)
  local got = MOUND.AMB.srcs[k]
  if got ~= nil then return got or nil end
  -- every plausible home for the file, tried in order; the error from
  -- the last attempt is kept and surfaced on the debug line, because a
  -- silent pcall was how 1.51.0 shipped a feature nobody could hear
  local dirs = {}
  local pd = rawget(_G, "__ds_posters_dir")
  if pd then dirs[#dirs + 1] = pd end
  local bp = rawget(_G, "__ds_backdrop_path")
  if type(bp) == "string" then
    local d = bp:match("^(.*/)[^/]+$")
    if d then dirs[#dirs + 1] = d end
  end
  dirs[#dirs + 1] = "mods/DRAMATIC_SHAPE/lib/"
  dirs[#dirs + 1] = "mods/BATTLE_ART_VOXEL_FORK/lib/"
  dirs[#dirs + 1] = "mods/DRAMALESS_SHAPE/lib/"
  dirs[#dirs + 1] = "mods/TERRARIUM/lib/"
  local src, err = nil, "no directories to try"
  for _, dir in ipairs(dirs) do
    for _, kind in ipairs({ "stream", "static" }) do
      local ok, got2 = pcall(function()
        local sc = love.audio.newSource(dir .. MOUND.AMB.FILES[k], kind)
        sc:setLooping(MOUND.AMB.LOOPS[k] and true or false)
        sc:setVolume(MOUND.AMB.LOOPS[k] and 0 or MOUND.AMB.STEP_VOL)
        return sc
      end)
      if ok and got2 then src = got2 break end
      err = tostring(got2)
    end
    if src then break end
  end
  MOUND.AMB.err = MOUND.AMB.err or {}
  MOUND.AMB.err[k] = (not src) and err or nil
  MOUND.AMB.srcs[k] = src or false
  return src
end

function MOUND.AMB.keyOf(map, outdoor)
  local def = (map and map.def) or {}
  local tid = tostring(def.tileset
              or (map and map.tileset and map.tileset.id) or "")
  if tid == "CAVERN" then return "cave" end
  if tid == "FOREST" then return "forest" end
  if not outdoor then return nil end
  local id = tostring((map and map.id) or def.id or "")
  if id:find("TOWN") or id:find("CITY") then return "town" end
  return "route"
end

-- THE LENS. Two per-frame writes into machinery the engine already
-- owns, which is why neither needs a splice. FOV: the rig folds
-- FirstPerson.FOV into its orbit blend every frame, so assigning it is
-- the entire feature. DEPTH BLUR: TiltShift is a finished
-- worldPresent depth-of-field pass the engine runs on the voxel
-- canvas; in first person its geometry happens to be exactly right --
-- the sharp mid-band holds the played space while the far top and
-- near ground soften -- so this borrows it by forcing its level while
-- the FP blend is up, remembering the engine's own level and handing
-- it back the moment first person ends or the row turns OFF.
function MOUND.applyLens(cfg)
  if not (FirstPerson and FirstPerson.FOV) then
    local ok, fp = pcall(V.require, "FirstPerson")
    if ok and fp and fp.FOV then FirstPerson = fp end
  end
  if FirstPerson and FirstPerson.FOV then
    local deg = ({ NARROW = 55, NORMAL = 65,
                   WIDE = 75, ULTRA = 85 })[cfg.fpfov or "NORMAL"] or 65
    FirstPerson.FOV = math.rad(deg)
  end
  if not MOUND.TSinit then
    MOUND.TSinit = true
    local ok, ts = pcall(V.require, "TiltShift")
    MOUND.TS = ok and ts or nil
  end
  local ts = MOUND.TS
  if not ts then return end
  local lvl = tonumber(cfg.dof) or 0
  local fp = 0
  pcall(function() fp = FirstPerson.blendEased() or 0 end)
  -- forcing ts.level directly lost every frame to the engine, whose
  -- pipeline record re-asserts the persisted option through update().
  -- So go through the front door instead: Pipelines.setLevel is the
  -- documented engine API the T-SHIFT row itself uses. Called only on
  -- transitions, with the player's own setting remembered and restored.
  if not MOUND.PLinit then
    MOUND.PLinit = true
    local ok, pl = pcall(require, "src.render.Pipelines")
    MOUND.PL = ok and pl or nil
  end
  local wantLvl = (lvl > 0 and fp > 0.5) and lvl or nil
  if wantLvl and ts.level ~= wantLvl then
    if MOUND.TSheld == nil then MOUND.TSheld = ts.level or 0 end
    if MOUND.PL and MOUND.PL.setLevel then
      pcall(MOUND.PL.setLevel, "tiltshift", wantLvl)
    end
    ts.level = wantLvl          -- belt and braces for this frame
  elseif not wantLvl and MOUND.TSheld ~= nil then
    if MOUND.PL and MOUND.PL.setLevel then
      pcall(MOUND.PL.setLevel, "tiltshift", MOUND.TSheld)
    end
    ts.level = MOUND.TSheld
    MOUND.TSheld = nil
  end
end

-- one line of truth for the whole lens-and-bob chain, on the FLOR note
function MOUND.lensNote(cfg)
  local real = (FirstPerson and FirstPerson.FOV) and "rig" or "STUB"
  local fp = 0
  pcall(function() fp = FirstPerson.blendEased() or 0 end)
  local jn = rawget(_G, "__ds_jump_note") or "jump:silent"
  return (", lens:%s fov:%s dof:%s ts:%s fp:%.2f %s"):format(
    real, tostring(cfg.fpfov), tostring(cfg.dof),
    MOUND.TS and "ok" or "nil", fp, jn)
end

function MOUND.AMB.tick(map, outdoor, cfg, dt, px, pz, shoreF)
  MOUND.AMB.beat = now()
  -- the watchdog reads THROUGH the global so a module reload (new
  -- MOUND, new srcs) hands it the live state instead of a dead capture
  _G.__ds_amb_state = MOUND.AMB
  if not rawget(_G, "__ds_amb_hooked") then
    _G.__ds_amb_hooked = true
    pcall(function()
      local prev = love.update
      love.update = function(...)
        if prev then prev(...) end
        local st = rawget(_G, "__ds_amb_state")
        if st and love.timer.getTime() - st.beat > 0.5 then
          for k2, sc in pairs(st.srcs) do
            if sc and st.LOOPS and st.LOOPS[k2] then
              pcall(function()
                local v = sc:getVolume()
                if v > 0.01 then sc:setVolume(v * 0.92)
                elseif sc:isPlaying() then sc:stop() end
              end)
            end
          end
        end
      end
    end)
  end
  -- the row is a CHOICE now (OFF/LOW/MID/HIGH); pre-1.52 saves may
  -- still hold a boolean, and both readings are honoured
  local lvl = cfg.ambience
  if lvl == true or lvl == nil then lvl = "MID" end
  if lvl == false then lvl = "OFF" end
  MOUND.AMB.VOL = MOUND.AMB.VOLS[lvl] or MOUND.AMB.VOLS.MID
  local want = (lvl ~= "OFF") and MOUND.AMB.keyOf(map, outdoor) or nil
  -- ONE-SHOTS. steps by surface on cell ENTRY (the same edge the
  -- encounter system rolls on), and a door on crossing a threshold.
  -- Cell ENTRY is the trigger (not per-frame presence), which is the
  -- same edge the encounter system rolls on, so it sounds like what
  -- it is: a step into the grass.
  local tidNow = tostring(((map and map.def) or {}).tileset
                 or (map and map.tileset and map.tileset.id) or "")
  local function oneShot(k, vol)
    local sc = MOUND.AMB.src(k)
    if sc then
      pcall(function()
        sc:stop()
        sc:setVolume(vol or MOUND.AMB.STEP_VOL)
        sc:play()
      end)
    end
  end
  if px then
    local cx, cy = math.floor(px / 16), math.floor(pz / 16)
    local ck = cx .. "|" .. cy
    if ck ~= MOUND.AMB.lastCell then
      MOUND.AMB.lastCell = ck
      local okG, g = pcall(function() return map:isGrassCell(cx, cy) end)
      if okG and g and cfg.grasssfx ~= false then
        -- the two grass takes alternate so back-and-forth pacing
        -- never stutters one sample
        MOUND.AMB.stepFlip = not MOUND.AMB.stepFlip
        oneShot(MOUND.AMB.stepFlip and "g1" or "g2")
      elseif cfg.stepsfx ~= false then
        -- surface steps: rock underfoot in the caves and tunnels,
        -- boards in every built interior. Outdoor non-grass stays
        -- silent -- dirt paths have no take, and silence beats a
        -- wrong sound on every step of a journey
        if tidNow == "CAVERN" or tidNow == "UNDERGROUND" then
          oneShot("cstep", 0.55)
        elseif not outdoor and tidNow ~= "FOREST" then
          oneShot("wstep", 0.5)
        end
      end
    end
  end
  -- DOORS on the threshold: the outdoor flag flipping across a map
  -- change is a doorway crossed in either direction. Marts, Centres
  -- and lobbies ring the shop bell; caves, tunnels and the forest
  -- have no door to sound; every other interior gets the house door.
  -- The interior side of the crossing names the sound, whichever way
  -- the player is going.
  local rkNow = (map and map.id) or (map and map.def and map.def.id)
                or tostring(map)
  if MOUND.AMB.prevRk ~= nil and rkNow ~= MOUND.AMB.prevRk
     and cfg.doorsfx ~= false
     and MOUND.AMB.prevOut ~= nil and outdoor ~= MOUND.AMB.prevOut then
    local inTid = outdoor and (MOUND.AMB.prevTid or "") or tidNow
    if inTid == "MART" or inTid == "POKECENTER" or inTid == "LOBBY" then
      oneShot("shopdoor", 0.8)
    elseif inTid ~= "CAVERN" and inTid ~= "UNDERGROUND"
           and inTid ~= "FOREST" then
      oneShot("door", 0.8)
    end
  end
  if rkNow ~= MOUND.AMB.prevRk then
    MOUND.AMB.prevRk, MOUND.AMB.prevTid = rkNow, tidNow
  end
  MOUND.AMB.prevOut = outdoor
  if want then MOUND.AMB.src(want) end   -- lazy: a bed loads when first wanted
  -- the water bed rises with the shoreline: full a stride from the
  -- waterline, gone past earshot, and never keyed to the crossfade
  MOUND.AMB.waterT = 0
  if lvl ~= "OFF" and outdoor and (shoreF or 0) > 0.03 then
    MOUND.AMB.waterT = MOUND.AMB.VOL * 0.9 * math.min(1, shoreF)
    MOUND.AMB.src("water")
  end
  -- crickets after dark, OUTSIDE ONLY and only where the outdoor beds
  -- play (towns, cities, routes): `want` is already exactly that test,
  -- so night rides on top of whichever of the two is up
  MOUND.AMB.nightT = 0
  if lvl ~= "OFF" and outdoor and isNight()
     and (want == "town" or want == "route") then
    MOUND.AMB.nightT = MOUND.AMB.VOL * 0.85
    MOUND.AMB.src("night")
  end
  -- rain, whenever it rains where you can hear it (the same flag the
  -- droplets and puddles run on), a shade over the bed so weather
  -- reads over place
  MOUND.AMB.rainT = 0
  if lvl ~= "OFF" and outdoor and raining then
    MOUND.AMB.rainT = MOUND.AMB.VOL * 1.05
    MOUND.AMB.src("rain")
  end
  if want and MOUND.AMB.srcs[want] == false then
    local e = (MOUND.AMB.err or {})[want] or "unknown"
    MOUND.AMB.note = (", amb:%s FAIL %s"):format(want, e:sub(-60))
  elseif want then
    local sc0 = MOUND.AMB.srcs[want]
    local okV, v0 = pcall(function() return sc0:getVolume() end)
    MOUND.AMB.note = (", amb:%s %.2f"):format(want, okV and v0 or -1)
  else
    MOUND.AMB.note = ", amb:off"
  end
  for k, sc in pairs(MOUND.AMB.srcs) do
    if sc and MOUND.AMB.LOOPS[k] then
      pcall(function()
        local target = (k == want) and MOUND.AMB.VOL or 0
        if k == "water" then target = MOUND.AMB.waterT or 0 end
        if k == "night" then target = MOUND.AMB.nightT or 0 end
        if k == "rain" then target = MOUND.AMB.rainT or 0 end
        local v = sc:getVolume()
        if v < target then v = math.min(target, v + MOUND.AMB.UP * dt)
        elseif v > target then v = math.max(target, v - MOUND.AMB.DOWN * dt) end
        sc:setVolume(v)
        if v > 0.004 then
          if not sc:isPlaying() then sc:play() end
        elseif sc:isPlaying() and target == 0 then
          sc:stop()
        end
      end)
    end
  end
  return want
end

function Flora.draw(state, atlasFor)
  if abandoned() then return end
  local cfg = config()
  local map = state and state.map
  if not map then return end
  local p = state.player
  local px = (p and p.px or 0) + 8
  local pz = (p and p.py or 0) + 8
  local t = now()
  local dt = lastT and math.min(0.1, t - lastT) or 0
  lastT = t
  local outdoor = isOutdoor(map)
  local shoreF = 0
  if featureCache and featureCache.shores then
    for i = 1, #featureCache.shores do
      local sh = featureCache.shores[i]
      local dx = sh[1] * 16 + 8 - px
      local dz = sh[2] * 16 + 8 - pz
      local d = math.sqrt(dx * dx + dz * dz)
      local f = 1 - d / 130
      if f > shoreF then shoreF = f end
    end
  end
  pcall(MOUND.AMB.tick, map, outdoor, cfg, dt, px, pz, shoreF)
  pcall(MOUND.applyLens, cfg)
  local yaw = (FirstPerson and FirstPerson.yaw) or 0

  -- Are we in the world at eye level -- inside the head, or on the boom
  -- just behind it?  Vines want that view and no other: from the diorama
  -- you would be looking down at the tops of them.
  -- How far the player moved this frame.  This used to be worked out
  -- inside the particle pass, which meant that turning PARTICLES off
  -- silently stopped the vines noticing anyone walking through them.
  local movedNow = wasX and (math.abs(px - wasX) + math.abs(pz - wasZ)) or 0
  movedThisFrame = movedNow
  wasX, wasZ = px, pz

  local okBlend, headBlend = pcall(FirstPerson.blendEased)
  headBlend = (okBlend and headBlend) or 0
  local canopySealed = headBlend > CANOPY_GATE

  local tuftNote = drawTufts(map, cfg, atlasFor, t, outdoor)

  -- ---------- the forest canopy
  local canopyNote = ""
  if cfg.canopy ~= false and isCanopy(map) then
    -- the same gate the interior ceiling uses: whole roof inside the
    -- head, opened up for the diorama so the wood can be seen into
    local okB, blend = pcall(FirstPerson.blendEased)
    blend = (okB and blend) or 0
    -- the same three cases the interior ceiling answers: inside the
    -- head, boomed out in 3RD, or the diorama
    local mode
    if blend > CANOPY_GATE and not boomedOut() then
      mode = "fp"
    elseif blend > CANOPY_GATE then
      local want = cfg.third or "CUTAWAY"
      if want == "FULL" then mode = "fp"
      elseif want == "CUTAWAY" then mode = "cutaway"
      else
        canopyNote = ", canopy off in 3RD"
        mode = nil
      end
    else
      mode = "cutaway"
    end
    local pcx, pcy
    if mode == nil then
      -- 3RD with the canopy switched off: no leaves at all
      if canopyCache and canopyCache.mesh then
        pcall(canopyCache.mesh.release, canopyCache.mesh)
      end
      canopyCache = nil
    end
    if mode == "cutaway" then
      pcx = math.floor(px / 16)
      pcy = math.floor(pz / 16)
    end
    local ckey = table.concat({ mode or "off", pcx or "-", pcy or "-" }, ":")
    if mode and (not canopyCache or canopyCache.map ~= map
                 or canopyCache.key ~= ckey) then
      if canopyCache and canopyCache.mesh then
        pcall(canopyCache.mesh.release, canopyCache.mesh)
      end
      local tx0 = nil
      if atlasFor then
        local okA, a = pcall(atlasFor, map)
        if okA then tx0 = a end
      end
      local mesh, vines, note = buildCanopy(map, tx0, mode, pcx, pcy)
      canopyCache = { map = map, key = ckey, mesh = mesh, note = note,
                      vines = vines }
    end
    if canopyCache and canopyCache.mesh then
      local tx = nil
      if atlasFor then
        local okT, a = pcall(atlasFor, map)
        if okT then tx = a end
      end
      guarded(function()
        Voxel3D.draw(canopyCache.mesh, tx, nil)

        -- the strands: each block swings on its own, and remembers being
        -- walked through for a couple of seconds
        if cfg.vines ~= false and canopyCache.vines then
          local pcx2 = math.floor(px / 16)
          local pcy2 = math.floor(pz / 16)
          local hereKey = math.floor(pcx2 / VINE_BLOCK) .. ":"
                          .. math.floor(pcy2 / VINE_BLOCK)
          if movedThisFrame > 0.2 then
            vineHits[hereKey] = { x = px, z = pz, at = t }
          end
          for _, blk in ipairs(canopyCache.vines) do
            -- idle: a slow wave, offset per block
            local w = math.sin(t * 0.62 + blk.phase) * 0.7
                    + math.sin(t * 1.31 + blk.phase * 2.1) * 0.3
            local kx = math.cos(WIND_DIR) * VINE_SWAY * w
            local kz = math.sin(WIND_DIR) * VINE_SWAY * w
            -- brushed: thrown away from where you pushed through, easing
            -- back over a second or two
            local hit = vineHits[blk.key]
            if hit then
              local age = t - hit.at
              if age > VINE_SETTLE then
                vineHits[blk.key] = nil
              else
                local f = 1 - age / VINE_SETTLE
                -- a swing back and forth as it settles, not a slump
                local swing = f * f * math.cos(age * 7.5)
                -- away from the point you pushed through
                local ang = math.atan2(pz - hit.z, px - hit.x)
                if math.abs(px - hit.x) < 0.01
                   and math.abs(pz - hit.z) < 0.01 then
                  ang = WIND_DIR
                end
                kx = kx + math.cos(ang) * VINE_PUSH * swing
                kz = kz + math.sin(ang) * VINE_PUSH * swing
              end
            end
            Voxel3D.draw(blk.mesh, tx, bend(kx, kz, blk.top))
          end
        end
      end)
      canopyNote = ", " .. tostring(canopyCache.note)
      if cfg.vines ~= false and canopyCache.vines then
        canopyNote = canopyNote
                     .. (", %d vine blocks"):format(#canopyCache.vines)
      end
    end
  end

  local live = drawParticles(state, map, cfg, px, pz, yaw, t, dt, outdoor,
                             (MOUND.TRUNK.cache[map] or {}).cells)
  local rainNote = drawRain(state, cfg, px, pz, yaw, t, dt, raining)
  local puddleNote = drawPuddles(map, cfg, raining, dt, atlasFor, outdoor)
  local stormNote = drawStorm(cfg, px, pz, yaw, t, dt,
                              partMesh or makeQuad())
  -- ---------- the same features, on the maps either side of you
  local nbNote = ""
  if outdoor and state.neighbors then
    MOUND.seen = {}
    local drawnNb = 0
    for _, nb in ipairs(state.neighbors) do
      if nb.map then MOUND.seen[nb.map] = true end
    end
    guarded(function()
      for _, nb in ipairs(state.neighbors) do
        local nmap, ox, oy = nb.map, nb.ox or 0, nb.oy or 0
        if nmap then
          local model = Mat4.translate(ox, 0, oy)
          -- how far the middle of that map is from you, for the haze
          local mx = ox + (nmap.widthCells or 0) * 8
          local mz = oy + (nmap.heightCells or 0) * 8
          local d = math.sqrt((mx - px) ^ 2 + (mz - pz) ^ 2)
          local hr, hg, hb = MOUND.haze(d)
          local tx = nil
          if atlasFor then
            local okA, a = pcall(atlasFor, nmap)
            if okA then tx = a end
          end

          -- MOUNTAIN PEAKS across the boundary. The massif looked
          -- superb where you stood and went flat two maps over -- the
          -- most immersive feature undoing itself at every seam. Each
          -- neighbour's peaks are built from ITS OWN cells (same gates,
          -- same builder, cached per map id) and drawn at the
          -- neighbour's offset under the same haze as its grass, so a
          -- ridge runs on into the distance instead of vanishing.
          if cfg.peaks ~= false then
            local rk2 = nmap.id or (nmap.def and nmap.def.id) or nmap
            local pslot = MOUND.PEAK.cache[rk2]
            if not pslot then
              local mesh, n = MOUND.buildPeaks(nmap)
              pslot = { mesh = mesh, count = n or 0 }
              MOUND.PEAK.cache[rk2] = pslot
            end
            if pslot.mesh then
              love.graphics.setColor(hr, hg, hb, 1)
              Voxel3D.draw(pslot.mesh, tx, model)
              love.graphics.setColor(1, 1, 1, 1)
            end
          end

          -- TRUNKS across the boundary, same cure as the peaks: the
          -- neighbour's rounds are drawn lifted (its own mesh bakes the
          -- lifts) but stems were built for the CURRENT map only, so a
          -- route's trees floated in the distance until you crossed
          -- over. Each neighbour's stems now build from ITS OWN
          -- registry (same gates, same builder, cached per map id) and
          -- draw at the neighbour's offset under its haze. The BASE
          -- GATE does the seam hygiene for free here too: a neighbour
          -- is meshed body-only, whose build skips every ring stamp
          -- before expansion, so its ring cells never earn base entries
          -- and no stem grows outside the neighbour's body.
          if cfg.talltrees ~= false then
            local rkT = nmap.id or (nmap.def and nmap.def.id) or nmap
            local regN2, baseN2 = 0, 0
            local rbT = rawget(_G, "__ds_round_base") or {}
            for key in pairs((rawget(_G, "__ds_round_cells") or {})[rkT]
                             or {}) do
              regN2 = regN2 + 1
              local kx, ky = key:match("^(-?%d+)|(-?%d+)$")
              if kx and rbT[rkT .. ":" .. (tonumber(kx) * 16 + 8) .. "|"
                           .. (tonumber(ky) * 16 + 8)] ~= nil then
                baseN2 = baseN2 + 1
              end
            end
            local tslot = MOUND.TRUNK.nbcache[rkT]
            if not tslot or tslot.n ~= regN2 or tslot.baseN ~= baseN2
               or tslot.bt ~= (cfg.bouldertrees == true) then
              if tslot then
                if tslot.trunks then
                  pcall(tslot.trunks.release, tslot.trunks)
                end
                if tslot.stones then
                  pcall(tslot.stones.release, tslot.stones)
                end
                if tslot.hoods then
                  pcall(tslot.hoods.release, tslot.hoods)
                end
              end
              local tm2, sm2, _, hm2 = MOUND.buildTrunks(nmap, nil)
              tslot = { trunks = tm2, stones = sm2, hoods = hm2,
                        n = regN2, baseN = baseN2,
                        bt = (cfg.bouldertrees == true) }
              MOUND.TRUNK.nbcache[rkT] = tslot
            end
            if tslot.trunks or tslot.stones or tslot.hoods then
              love.graphics.setColor(hr, hg, hb, 1)
              if tslot.trunks and MOUND.barkImg() then
                Voxel3D.draw(tslot.trunks, MOUND.barkImg(), model)
              end
              if tslot.stones and MOUND.stoneImg() then
                Voxel3D.draw(tslot.stones, MOUND.stoneImg(), model)
              end
              if tslot.hoods and MOUND.leafyImg() then
                Voxel3D.draw(tslot.hoods, MOUND.leafyImg(), model)
              end
              love.graphics.setColor(1, 1, 1, 1)
            end
          end

          -- grass
          local gkey = cfg.grass or "SUBTLE"
          local per = BLADES[gkey] or 2
          if per and per > 0 then
            local slot = MOUND.tufts[nmap]
            if not slot or slot.key ~= gkey then
              if slot and slot.mesh then
                for _, part in ipairs(slot.mesh) do
                  pcall(part.mesh.release, part.mesh)
                end
              end
              local mesh = buildTufts(nmap, per)
              slot = { mesh = mesh, key = gkey }
              MOUND.tufts[nmap] = slot
            end
            if slot.mesh then
              love.graphics.setColor(hr, hg, hb, 1)
              for _, part in ipairs(slot.mesh) do
                Voxel3D.draw(part.mesh, tx, model)
              end
              drawnNb = drawnNb + 1
            end
          end
        end
      end
      love.graphics.setColor(1, 1, 1, 1)
    end)
      MOUND.trim(MOUND.tufts, 8)
    if drawnNb > 0 then
      nbNote = (", %d neighbour draws"):format(drawnNb)
    end
  end

  -- ---------- trunks under the lifted trees
  local trunkNote = ""
  if outdoor and cfg.talltrees ~= false then
    local regN, baseN = 0, 0
    local rk2 = map.id or (map.def and map.def.id) or map
    local rb0 = rawget(_G, "__ds_round_base") or {}
    for key in pairs((rawget(_G, "__ds_round_cells") or {})[rk2] or {}) do
      regN = regN + 1
      -- how many of THIS map's registry cells the mesher has confirmed
      -- (base entries land as the async full build expands each stamp);
      -- a change means stems are ready to grow or ghosts to retire
      local kx, ky = key:match("^(-?%d+)|(-?%d+)$")
      if kx and rb0[rk2 .. ":" .. (tonumber(kx) * 16 + 8) .. "|"
                   .. (tonumber(ky) * 16 + 8)] ~= nil then
        baseN = baseN + 1
      end
    end
    -- the mesher's neighbour-body rects, rebuilt from the same offsets
    -- the scene draws with, so the mask gate answers as the mesher did
    local nbRects = {}
    for _, nb in ipairs(state.neighbors or {}) do
      if nb.map and nb.map.def then
        nbRects[#nbRects + 1] = { nb.ox or 0, nb.oy or 0,
                                  (nb.ox or 0) + nb.map.def.width * 32,
                                  (nb.oy or 0) + nb.map.def.height * 32 }
      end
    end
    local slot = MOUND.TRUNK.cache[map]
    if not slot or slot.n ~= regN or slot.baseN ~= baseN
       or slot.nbN ~= #nbRects
       or slot.bt ~= (cfg.bouldertrees == true)
       or slot.sh ~= (cfg.shadows ~= false) then
      if slot then
        if slot.trunks then pcall(slot.trunks.release, slot.trunks) end
        if slot.stones then pcall(slot.stones.release, slot.stones) end
        if slot.hoods then pcall(slot.hoods.release, slot.hoods) end
        if slot.shadows then
          pcall(slot.shadows.release, slot.shadows)
        end
      end
      local tm, sm, n, hm, shm = MOUND.buildTrunks(map, nbRects)
      slot = { trunks = tm, stones = sm, hoods = hm, shadows = shm,
               count = n or 0,
               n = regN,
               baseN = baseN, nbN = #nbRects,
               bt = (cfg.bouldertrees == true),
               sh = (cfg.shadows ~= false),
               tN = MOUND.TRUNK.tN, bN = MOUND.TRUNK.bN,
               cells = MOUND.TRUNK.cells }
      MOUND.TRUNK.cache[map] = slot
    end
    local drew = false
    if slot.trunks and MOUND.barkImg() then
      guarded(function() Voxel3D.draw(slot.trunks, MOUND.barkImg(), nil) end)
      drew = true
    end
    if slot.stones and MOUND.stoneImg() then
      guarded(function() Voxel3D.draw(slot.stones, MOUND.stoneImg(), nil) end)
      drew = true
    end
    if slot.hoods and MOUND.leafyImg() then
      guarded(function() Voxel3D.draw(slot.hoods, MOUND.leafyImg(), nil) end)
      drew = true
    end
    if slot.shadows and MOUND.shadowImg() then
      guarded(function()
        Voxel3D.draw(slot.shadows, MOUND.shadowImg(), nil)
      end)
      drew = true
    end
    if drew then
      local near = ""
      local pl = state and state.player
      if pl and slot.cells and #slot.cells > 0 then
        local px = (pl.px or 0) / 16
        local py = (pl.py or 0) / 16
        table.sort(slot.cells, function(a, b)
          local da = (a[1] - px) ^ 2 + (a[2] - py) ^ 2
          local db = (b[1] - px) ^ 2 + (b[2] - py) ^ 2
          return da < db
        end)
        local bits = {}
        for i = 1, math.min(3, #slot.cells) do
          local c = slot.cells[i]
          bits[#bits + 1] = c[1] .. "|" .. c[2] .. c[3]
        end
        near = " near:" .. table.concat(bits, " ")
      end
      trunkNote = (", %d trunks (%dt/%db%s)")
                  :format(slot.count, slot.tN or 0, slot.bN or 0, near)
    end
  end

  -- ---------- mountain peaks over the clustered rock
  local peakNote = ""
  if outdoor and cfg.peaks ~= false then
    local rk0 = map.id or (map.def and map.def.id) or map
    local slot = MOUND.PEAK.cache[rk0]
    if not slot then
      local mesh, n = MOUND.buildPeaks(map)
      slot = { mesh = mesh, count = n or 0 }
      MOUND.PEAK.cache[rk0] = slot
    end
    if slot.mesh then
      local tx6 = nil
      if atlasFor then
        local okA6, a6 = pcall(atlasFor, map)
        if okA6 then tx6 = a6 end
      end
      -- FADE IN over ~half a second on map entry, the same colour+alpha
      -- path the fog uses -- a massif materialising beats one teleporting
      MOUND.PEAK.f = (MOUND.PEAK.f or 0) + 1
      if slot.born == nil then slot.born = MOUND.PEAK.f end
      local a = math.min(1, (MOUND.PEAK.f - slot.born) / 30)
      guarded(function()
        love.graphics.setColor(1, 1, 1, a)
        Voxel3D.draw(slot.mesh, tx6, nil)
        love.graphics.setColor(1, 1, 1, 1)
      end)
      peakNote = (", peaks %d"):format(slot.count)
    end
  end

  -- ---------- the apron: the world continued past its own rim
  local apronNote = ""
  if outdoor and cfg.apron ~= false then
    local slot = MOUND.APRON.cache[map]
    if not slot then
      local mesh, n = MOUND.buildApron(map)
      slot = { mesh = mesh, count = n or 0 }
      MOUND.APRON.cache[map] = slot
    end
    if slot.mesh then
      local tx5 = nil
      if atlasFor then
        local okA5, a5 = pcall(atlasFor, map)
        if okA5 then tx5 = a5 end
      end
      guarded(function()
        Voxel3D.draw(slot.mesh, tx5, nil)
      end)
      apronNote = (", apron %d"):format(slot.count)
    end
  end

  -- ---------- the backs of buildings, in plain wall
  local backNote = ""
  if outdoor and cfg.backs ~= false then
    local slot = MOUND.BACKS.cache[map]
    if not slot then
      local mesh, n = MOUND.buildBacks(map)
      slot = { mesh = mesh, count = n or 0 }
      MOUND.BACKS.cache[map] = slot
    end
    if slot.mesh then
      local tx4 = nil
      if atlasFor then
        local okA, a = pcall(atlasFor, map)
        if okA then tx4 = a end
      end
      guarded(function()
        Voxel3D.draw(slot.mesh, tx4, nil)
      end)
      backNote = (", %d backs"):format(slot.count)
    end
  end

  local isDark = darkness(map).dark
  local lightNote = drawLights(map, cfg, px, pz, yaw, t, outdoor, isDark)
  local caveNote = drawCave(map, cfg, px, pz, yaw, t, dt, isDark,
                            partMesh or makeQuad())
  local vineNote = drawVines(map, cfg, px, pz, t, dt, canopySealed,
                             movedThisFrame or 0)
  local shaftNote = drawShafts(map, cfg, px, pz, t, raining)
  local fogNote = drawFog(map, cfg, px, pz, dt)


  -- CAVE DARKNESS removed. It drew nested shells to close the walls in,
  -- exactly as the Lavender fog does -- but the fog sets a colour with
  -- ALPHA before drawing and this never did, so the shells came out
  -- fully opaque: a cave of flat slabs with the clear colour showing
  -- through wherever they cut the room. It was wrong every time it was
  -- switched on, which is worse than not existing.
  local darkNote = ""

  local f = featureCache or {}
  status(("%s, %d particles, %d chimneys, %d shore%s%s%s"):format(tuftNote,
         live, #(f.chimneys or {}), #(f.shores or {}),
         isNight() and ", night" or "",
         canopyNote .. rainNote .. puddleNote .. stormNote
           .. peakNote .. trunkNote .. apronNote .. backNote .. nbNote .. lightNote .. caveNote .. vineNote
           .. shaftNote .. fogNote .. (MOUND.AMB.note or "")
           .. (MOUND.lensNote and MOUND.lensNote(cfg) or ""),
         darkNote))
end

function Flora.invalidate()
  if tuftCache and tuftCache.mesh then
    for _, part in ipairs(tuftCache.mesh) do
      pcall(part.mesh.release, part.mesh)
    end
  end
  if partMesh then pcall(partMesh.release, partMesh) end
  if shellMesh then pcall(shellMesh.release, shellMesh) end
  if shaftMesh then pcall(shaftMesh.release, shaftMesh) end
  if vineMesh then pcall(vineMesh.release, vineMesh) end
  vineMesh, vines = nil, nil
  swarms = nil
  if puddleCache and puddleCache.mesh then
    for _, grp in ipairs(puddleCache.mesh) do
      pcall(grp.mesh.release, grp.mesh)
    end
  end
  if lightCache and lightCache.built and lightCache.built.mesh then
    pcall(lightCache.built.mesh.release, lightCache.built.mesh)
  end
  lightCache = nil
  if poolCache and poolCache.mesh then
    pcall(poolCache.mesh.release, poolCache.mesh)
  end
  -- batPics too: a reload should look for the derived frames again
  -- rather than remember that they were missing last time
  for _, slot in pairs(MOUND.BACKS.cache) do
    if slot.mesh then pcall(slot.mesh.release, slot.mesh) end
  end
  MOUND.BACKS.cache = {}
  for _, slot in pairs(MOUND.APRON.cache) do
    if slot.mesh then pcall(slot.mesh.release, slot.mesh) end
  end
  MOUND.APRON.cache = {}
  for _, slot in pairs(MOUND.TRUNK.cache) do
    if slot.trunks then pcall(slot.trunks.release, slot.trunks) end
    if slot.stones then pcall(slot.stones.release, slot.stones) end
  end
  MOUND.TRUNK.cache = {}
  for _, slot in pairs(MOUND.TRUNK.nbcache) do
    if slot.trunks then pcall(slot.trunks.release, slot.trunks) end
    if slot.stones then pcall(slot.stones.release, slot.stones) end
    if slot.hoods then pcall(slot.hoods.release, slot.hoods) end
  end
  MOUND.TRUNK.nbcache = {}
  for _, slot in pairs(MOUND.PEAK.cache) do
    if slot.mesh then pcall(slot.mesh.release, slot.mesh) end
  end
  MOUND.PEAK.cache = {}
  poolCache, sconceCache, bats, batsAt, batPics =
    nil, nil, nil, nil, nil
  puddleCache, bolts, boltAt, flash, wetness = nil, nil, nil, 0, 0
  if canopyCache and canopyCache.mesh then
    pcall(canopyCache.mesh.release, canopyCache.mesh)
  end
  canopyCache = nil
  tuftCache, partMesh, shellMesh, parts = nil, nil, nil, nil
  shaftMesh, drops, rainUntil, dryUntil = nil, nil, nil, nil
  featureCache = nil
  for _, sc in pairs(MOUND.AMB.srcs) do
    if sc then pcall(sc.stop, sc) end
  end
  MOUND.AMB.srcs = {}
end

-- THE SUN SEES THE STEMS. Called from a small splice inside the sun
-- pass: every mesh this module stands up -- trunks, stone stacks,
-- leafy hoods, current map and neighbours -- is drawn into the shadow
-- map, so raised trees now CAST like the terrain does instead of only
-- receiving a blob.
function Flora.castShadows(state, ShadowMap, Mat4x)
  local map = state and state.map
  if not map then return end
  local slot = MOUND.TRUNK.cache[map]
  if slot then
    for _, k in ipairs({ "trunks", "stones", "hoods" }) do
      if slot[k] then
        pcall(ShadowMap.draw, slot[k], MOUND.barkImg(), nil)
      end
    end
  end
  for _, nb in ipairs(state.neighbors or {}) do
    local rkT = (nb.map and (nb.map.id or (nb.map.def and nb.map.def.id)))
                or nb.map
    local ts = MOUND.TRUNK.nbcache[rkT]
    if ts then
      local model = Mat4x.translate(nb.ox or 0, 0, nb.oy or 0)
      for _, k in ipairs({ "trunks", "stones", "hoods" }) do
        if ts[k] then
          pcall(ShadowMap.draw, ts[k], MOUND.barkImg(), model)
        end
      end
    end
  end
end

-- THE STEMS STAND IN BATTLE. The battle scene draws the host map's
-- terrain -- lifted rounds baked in -- but never ran this module, so
-- every raised tree floated for the length of a fight. Called from a
-- splice after the battle's terrain draw; the caches are the same ones
-- the overworld built moments before the fight, so this costs nothing
-- to assemble.
function Flora.battleProps(host, neighbors)
  local slot = MOUND.TRUNK.cache[host]
  if slot then
    if slot.trunks and MOUND.barkImg() then
      pcall(Voxel3D.draw, slot.trunks, MOUND.barkImg(), nil)
    end
    if slot.stones and MOUND.stoneImg() then
      pcall(Voxel3D.draw, slot.stones, MOUND.stoneImg(), nil)
    end
    if slot.hoods and MOUND.leafyImg() then
      pcall(Voxel3D.draw, slot.hoods, MOUND.leafyImg(), nil)
    end
    if slot.shadows and MOUND.shadowImg() then
      pcall(Voxel3D.draw, slot.shadows, MOUND.shadowImg(), nil)
    end
  end
  for _, nb in ipairs(neighbors or {}) do
    local rkT = (nb.map and (nb.map.id or (nb.map.def and nb.map.def.id)))
                or nb.map
    local ts = MOUND.TRUNK.nbcache[rkT]
    if ts then
      local model = Mat4.translate(nb.ox or 0, 0, nb.oy or 0)
      if ts.trunks and MOUND.barkImg() then
        pcall(Voxel3D.draw, ts.trunks, MOUND.barkImg(), model)
      end
      if ts.stones and MOUND.stoneImg() then
        pcall(Voxel3D.draw, ts.stones, MOUND.stoneImg(), model)
      end
      if ts.hoods and MOUND.leafyImg() then
        pcall(Voxel3D.draw, ts.hoods, MOUND.leafyImg(), model)
      end
    end
  end
end

-- live registration: the installer hot-swaps refreshed modules
-- into the running session through this table, killing the
-- boot-twice ritual (see main.lua, hotSwap)
_G.__ds_live = rawget(_G, "__ds_live") or {}
_G.__ds_live.Flora = Flora
_G.__ds_live.V = _G.__ds_live.V or V

return Flora
