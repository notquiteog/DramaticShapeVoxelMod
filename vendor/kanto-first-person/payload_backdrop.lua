-- The BACKDROP: a distant horizon for the outdoor world.
-- payload-version: 5
--
-- Dramatic Shape's outdoor maps end where their meshes end -- past the
-- last connected map is sky meeting nothing.  This hangs a painted
-- panorama around the world at a great radius: hills, forest, mountains,
-- a lighthouse headland and a walled town, wrapped 360 degrees and
-- centred on the player, so it reads as distance rather than as scenery.
--
-- Centred on the player is the whole trick.  A cylinder that follows you
-- never gets closer, which is exactly how a horizon behaves: it turns
-- with the camera and refuses to be approached.  A slow drift of the
-- texture against world position adds the last touch -- walk east far
-- enough and the mountains slide across the sky -- without ever letting
-- the player reach them.
--
-- Drawn after the sky and before the terrain, with depth writes off, so
-- every piece of real world draws over it and it never occludes anything.
-- Interiors and canopy maps skip it: the ceiling module owns those.

local V = ...

local Voxel3D = V.require("Voxel3D")
local Mat4 = V.require("Mat4")
local okDN, DayNight = pcall(V.require, "DayNight")

local Backdrop = {}

local RADIUS = 900        -- far enough to read as distance, inside far plane
local SEGMENTS = 64       -- around the full circle
local Y_BOTTOM = -1       -- the illustration's foot meets the world's
                          -- ground plane (community request): painted
                          -- ranges stand ON the ground instead of
                          -- sinking past it; the deep skirt still
                          -- seals everything below
-- and a DEEP skirt below that, for the diorama and 3RD rungs. Looking at
-- the world from above and outside, the eye clears the map's own edge and
-- sees under it -- where the painted band simply stopped and the void
-- began, which is the horizon "cutting off" people report. This continues
-- the panorama's BOTTOM ROW of pixels straight down: the same colour the
-- land ends in, carried far enough below the map that nothing can see
-- past it, at no cost in texture or detail.
local Y_DEEP = -1400
-- a floor across the middle, in that same bottom-row colour, so the gap
-- is closed from directly overhead as well as from the side
local FLOOR_RINGS = 3
local Y_TOP = 300         -- headroom above it
local DRIFT = 1 / 24000   -- texture drift per world pixel walked

local mesh, image, failed = nil, nil, false
local underMesh, whiteImg = nil, nil
local groundColor = { 0.62, 0.60, 0.48 }   -- until the art is read

local function white()
  if whiteImg ~= nil then return whiteImg or nil end
  local ok, img = pcall(function()
    local d = love.image.newImageData(1, 1)
    d:setPixel(0, 0, 1, 1, 1, 1)
    local i = love.graphics.newImage(d)
    i:setFilter("nearest", "nearest")
    return i
  end)
  whiteImg = (ok and img) or false
  return whiteImg or nil
end

local function status(s) _G.__ds_backdrop_status = s end
status("loaded; awaiting the first outdoor frame")

-- interiors and canopy maps belong to the ceiling, not the horizon

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

local OPEN_AIR_TILESETS = {
  OVERWORLD = true, FOREST = true, PLATEAU = true, SHIP_PORT = true,
}

local function isOutdoor(map)
  local def = map and map.def
  if not def then return false end
  if okDN and DayNight and DayNight.isCanopy then
    local okC, canopy = pcall(DayNight.isCanopy, map)
    if okC and canopy then return false end
  end
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

-- the cylinder, built once: a ring of quads facing inward, uv running
-- once around the circumference
local function build()
  local verts, indexMap, quads = {}, {}, 0
  for i = 0, SEGMENTS - 1 do
    local a0 = (i / SEGMENTS) * math.pi * 2
    local a1 = ((i + 1) / SEGMENTS) * math.pi * 2
    local x0, z0 = math.cos(a0) * RADIUS, math.sin(a0) * RADIUS
    local x1, z1 = math.cos(a1) * RADIUS, math.sin(a1) * RADIUS
    local u0, u1 = i / SEGMENTS, (i + 1) / SEGMENTS
    -- wound so the painted face looks INWARD at the player
    verts[#verts + 1] = { x1, Y_TOP, z1, u1, 0, 1 }
    verts[#verts + 1] = { x0, Y_TOP, z0, u0, 0, 1 }
    verts[#verts + 1] = { x0, Y_BOTTOM, z0, u0, 1, 1 }
    verts[#verts + 1] = { x1, Y_BOTTOM, z1, u1, 1, 1 }
    Voxel3D.pushQuad(indexMap, quads)
    quads = quads + 1
  end
  return Voxel3D.newMesh(verts, indexMap)
end

-- the skirt and floor live on their own mesh, textured by the white
-- pixel and tinted with the panorama's own ground colour: one flat tone
local function buildUnder()
  local verts, indexMap, quads = {}, {}, 0
  for i = 0, SEGMENTS - 1 do
    local a0 = (i / SEGMENTS) * math.pi * 2
    local a1 = ((i + 1) / SEGMENTS) * math.pi * 2
    local x0, z0 = math.cos(a0) * RADIUS, math.sin(a0) * RADIUS
    local x1, z1 = math.cos(a1) * RADIUS, math.sin(a1) * RADIUS
    verts[#verts + 1] = { x1, Y_BOTTOM, z1, 0.5, 0.5, 1 }
    verts[#verts + 1] = { x0, Y_BOTTOM, z0, 0.5, 0.5, 1 }
    verts[#verts + 1] = { x0, Y_DEEP, z0, 0.5, 0.5, 1 }
    verts[#verts + 1] = { x1, Y_DEEP, z1, 0.5, 0.5, 1 }
    Voxel3D.pushQuad(indexMap, quads)
    quads = quads + 1
    for r = 1, FLOOR_RINGS do
      local o = (r - 1) / FLOOR_RINGS
      local n = r / FLOOR_RINGS
      local ro, rn = RADIUS * (1 - o), RADIUS * (1 - n)
      verts[#verts + 1] = { math.cos(a1) * ro, Y_DEEP, math.sin(a1) * ro,
                            0.5, 0.5, 1 }
      verts[#verts + 1] = { math.cos(a0) * ro, Y_DEEP, math.sin(a0) * ro,
                            0.5, 0.5, 1 }
      verts[#verts + 1] = { math.cos(a0) * rn, Y_DEEP, math.sin(a0) * rn,
                            0.5, 0.5, 1 }
      verts[#verts + 1] = { math.cos(a1) * rn, Y_DEEP, math.sin(a1) * rn,
                            0.5, 0.5, 1 }
      Voxel3D.pushQuad(indexMap, quads)
      quads = quads + 1
    end
  end
  return Voxel3D.newMesh(verts, indexMap)
end

-- the panorama itself, written next to this module by the companion mod
local function texture()
  if image or failed then return image end
  local ok, img = pcall(function()
    local path = rawget(_G, "__ds_backdrop_path")
                 or "mods/DRAMATIC_SHAPE/lib/backdrop.png"
    -- THE GROUND COLOUR, read once from the art itself: the average of
    -- the panorama's bottom row is the colour its land ends in, and the
    -- skirt and floor are painted in that single flat tone. Stretching
    -- the bottom ROW downward smeared every colour in it -- trees,
    -- fields, shore -- into vertical taffy; a plain of one colour reads
    -- as distant ground.
    pcall(function()
      local data = love.image.newImageData(path)
      local w, h = data:getWidth(), data:getHeight()
      local r, g, b, n = 0, 0, 0, 0
      for x = 0, w - 1, 8 do
        local pr, pg, pb, pa = data:getPixel(x, h - 1)
        if pa > 0.5 then r, g, b, n = r + pr, g + pg, b + pb, n + 1 end
      end
      if n > 0 then
        groundColor = { r / n, g / n, b / n }
      end
      data:release()
    end)
    local i = love.graphics.newImage(path)
    i:setWrap("repeat", "clamp")
    i:setFilter("nearest", "nearest")
    return i
  end)
  if ok and img then
    image = img
  else
    failed = true
    status("backdrop.png missing or unreadable")
  end
  return image
end

-- If the companion mod has been deleted, its config bridge is gone and
-- this module is an orphan: draw nothing. The ceiling module does the
-- actual clean-up; this just keeps quiet in the meantime.
local function abandoned()
  return rawget(_G, "__ds_ceiling_config") == nil
end

function Backdrop.draw(state)
  if abandoned() then return end
  local cfg = {}
  local pub = rawget(_G, "__ds_ceiling_config")
  if type(pub) == "function" then
    local okCfg, c = pcall(pub)
    if okCfg and type(c) == "table" then cfg = c end
  end
  if cfg.backdrop == false then
    status("backdrop switched off")
    return
  end

  local map = state and state.map
  if not map then return end
  if not isOutdoor(map) then
    status("indoors -- the ceiling owns this map")
    return
  end

  local tex = texture()
  -- the chosen panorama can change while the game is running, so notice
  -- when the published path is not the one we loaded
  local want = rawget(_G, "__ds_backdrop_path")
  if tex and want and want ~= texPath then tex = nil end
  if not tex then
    texPath = want return end
  if not mesh then
    mesh = build()
    if not mesh then
      failed = true
      status("driver refused the backdrop mesh")
      return
    end
  end

  local p = state.player
  local px = (p and p.px) or 0
  local pz = (p and p.py) or 0

  -- drift: the horizon slides slowly against the world, so walking a long
  -- way east moves the mountains, but never brings them closer
  local okShift = pcall(function()
    tex:setWrap("repeat", "clamp")
  end)

  local drew = true
  guarded(function()
    -- behind everything: test against depth but never write to it, so no
    -- real geometry can ever be occluded by the painting
    love.graphics.setDepthMode("lequal", false)
    -- the solid ground first, so the painted band draws over its top edge
    underMesh = underMesh or buildUnder()
    local wp = white()
    if underMesh and wp then
      love.graphics.setColor(groundColor[1], groundColor[2],
                             groundColor[3], 1)
      Voxel3D.draw(underMesh, wp, Mat4.translate(px, 0, pz))
      love.graphics.setColor(1, 1, 1, 1)
    end
    Voxel3D.draw(mesh, tex, Mat4.translate(px, 0, pz))
  end)
  if drew then
    status(("drawn at r=%d, drift %.3f"):format(RADIUS, (px * DRIFT) % 1))
  else
    status("draw failed")
  end
end

function Backdrop.invalidate()
  -- Host switches panorama choices live; release retained texture resources.
  if image then pcall(image.release, image) end
  if whiteImg then pcall(whiteImg.release, whiteImg) end
  image, whiteImg, failed = nil, nil, false
  if mesh then pcall(mesh.release, mesh) end
  mesh = nil
  if underMesh then pcall(underMesh.release, underMesh) end
  underMesh = nil
end

-- live registration: the installer hot-swaps refreshed modules
-- into the running session through this table, killing the
-- boot-twice ritual (see main.lua, hotSwap)
_G.__ds_live = rawget(_G, "__ds_live") or {}
_G.__ds_live.Backdrop = Backdrop
_G.__ds_live.V = _G.__ds_live.V or V

return Backdrop
