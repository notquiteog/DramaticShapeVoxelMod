-- TEST135: rolling true-3D fog banks for Pokemon Tower.
-- TEST133 fixed the motion and colour cycling, but its individual radial
-- shells still read as circles. The floor body is now made from long,
-- serpentine open height-field ribbons that flow across the grave rows.
-- Live thickness and speed controls preserve TEST134's approved NORMAL look.

local V = ...
local Assets = require("src.render.Assets")
local Voxel3D = V.require("Voxel3D")
local Mat4 = V.require("Mat4")
local Structures = V.require("Structures")
local TowerFogSettings = V.require("TowerFogSettings")

local Mist = {}
local GROUPS, TAU = 6, math.pi * 2
local FORMAT = { {"VertexPosition","float",3}, {"VertexTexCoord","float",2},
  {"VertexShade","float",1}, {"MistGround","float",1} }
local cache = setmetatable({}, { __mode = "k" })
local texture, softShader
local shaderTried = false
local IDENTITY = Mat4.identity()
local animReal, animTime

local function isTower(map)
  return map and map.tileset and map.tileset.id == "CEMETERY"
    and tostring(map.id or ""):upper():match("^POKEMON_TOWER_[1-7]F$") ~= nil
end

local function keyOf(tx, ty) return (ty + 64) * 4096 + (tx + 64) end

local function hash01(x, z, salt)
  local n = (x * 73856093 + z * 19349663 + salt * 83492791) % 104729
  if n < 0 then n = n + 104729 end
  return n / 104729
end

local function mistTexture()
  if texture then return texture end
  local ok, img = pcall(function()
    local w, h = 128, 64
    local data = love.image.newImageData(w, h)
    for y = 0, h - 1 do
      local v = y / (h - 1)
      local edge = math.min(1, v / .20, (1 - v) / .20)
      edge = edge * edge * (3 - 2 * edge)
      for x = 0, w - 1 do
        local u = x / w
        local noise = .72
          + .13 * math.sin(u * TAU * 2.0 + v * 3.7)
          + .09 * math.sin(u * TAU * 5.0 - v * 8.1)
          + .055 * math.cos(u * TAU * 11.0 + v * 13.0)
        local alpha = edge * math.max(.42, math.min(1, noise))
        data:setPixel(x, y, .84, .87, .90, alpha)
      end
    end
    local made = love.graphics.newImage(data)
    made:setFilter("linear", "linear")
    made:setWrap("repeat", "clamp")
    return made
  end)
  if ok then texture = img end
  return texture
end

-- Voxel3D's shared world shader intentionally discards soft source alpha for
-- crisp sprite and atlas edges. Fog needs the opposite, so this small scoped
-- shader preserves the generated feather/noise alpha while reusing the live
-- camera, model transform, world curve and depth buffer.
local function fogShader()
  if shaderTried then return softShader end
  shaderTried = true
  local ok, made = pcall(love.graphics.newShader, [[
    uniform mat4 vp;
    uniform mat4 model;
    uniform vec3 eye;
    uniform float pull;
    uniform vec3 curve;
    #ifdef VERTEX
    attribute float MistGround;

    vec4 position(mat4 transform_projection, vec4 vertex_position) {
      vec4 w = model * vertex_position;
      // Thickness scales the bank above its floor, never the raised floor.
      w.y += MistGround * (1.0 - model[1][1]);
      if (curve.z > 0.0) {
        vec2 d = w.xz - curve.xy;
        w.y -= dot(d, d) * curve.z;
      }
      if (pull > 0.0) {
        w.xyz += normalize(eye - w.xyz) * pull;
      }
      return vp * w;
    }

    #endif

    #ifdef PIXEL
    vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
      vec4 p = Texel(tex, tc);
      if (p.a < 0.01) discard;
      return vec4(p.rgb * color.rgb, p.a * color.a);
    }
    #endif
  ]])
  if ok then softShader = made end
  return softShader
end

local function group()
  return { verts = {}, indices = {}, count = 0, sumX = 0, sumZ = 0 }
end

local function vertex(g, x, y, z, u, v)
  g.verts[#g.verts + 1] = {
    x, y, z, u or .5, v or .5, 1, 0
  }
  return #g.verts
end

local function tri(g, a, b, c)
  g.indices[#g.indices + 1] = a
  g.indices[#g.indices + 1] = b
  g.indices[#g.indices + 1] = c
end

-- One irregular outer surface gives each bank a cloud-like outline without
-- exposing a stack of internal transparent spheres.
local function cloudShell(g, cx, cy, cz, rx, ry, rz, yaw, seed)
  local segments = 16
  local rings = { -.82, -.54, -.20, .18, .52, .80 }
  local ringIds = {}
  local ca, sa = math.cos(yaw), math.sin(yaw)
  local p0 = hash01(seed, 0, 1409) * TAU
  local p1 = hash01(seed, 1, 1423) * TAU
  local lean = (hash01(seed, 2, 1433) - .5) * rx * .22

  local function point(a, ny, radius, ri)
    local broad = 1 + .13 * math.sin(a * 3 + p0)
      + .075 * math.sin(a * 5 + p1 + ri * .36)
    local crown = 1 + .045 * math.sin(a * 2 - p1 + ny * 2.7)
    local lx = math.cos(a) * radius * rx * broad + ny * lean
    local lz = math.sin(a) * radius * rz * crown
    return cx + lx * ca - lz * sa,
           cy + ny * ry,
           cz + lx * sa + lz * ca
  end

  local bottom = vertex(g, cx - lean, cy - ry, cz, 0, .01)
  for ri, ny in ipairs(rings) do
    local radius = math.sqrt(1 - ny * ny)
    ringIds[ri] = {}
    local stagger = (ri % 2 == 0) and math.pi / segments or 0
    for s = 0, segments - 1 do
      local a = TAU * s / segments + stagger
      local x, y, z = point(a, ny, radius, ri)
      ringIds[ri][s + 1] = vertex(
        g, x, y, z, s / segments * 2 + seed % 7, (ny + 1) * .5)
    end
  end
  local top = vertex(g, cx + lean, cy + ry, cz, 0, .99)

  for s = 1, segments do
    local n = s % segments + 1
    tri(g, bottom, ringIds[1][s], ringIds[1][n])
    for ri = 1, #rings - 1 do
      local a, b = ringIds[ri][s], ringIds[ri][n]
      local c, d = ringIds[ri + 1][n], ringIds[ri + 1][s]
      tri(g, a, c, b)
      tri(g, a, d, c)
    end
    tri(g, ringIds[#rings][s], top, ringIds[#rings][n])
  end
  g.count = g.count + 1
  g.sumX, g.sumZ = g.sumX + cx, g.sumZ + cz
end

-- One open, lumpy height-field surface stretched through a whole grave-row
-- run. There is no underside and no round end cap for the camera to reveal.
local function ribbonSurface(g, x0, z0, x1, z1, halfWidth, crestHeight,
                             seed, lateralOffset)
  local vx, vz = x1 - x0, z1 - z0
  local length = math.sqrt(vx * vx + vz * vz)
  if length < 4 then return end
  local nx, nz = -vz / length, vx / length
  local steps = math.max(5, math.ceil(length / 11))
  local lanes = { -1, -.72, -.38, -.08, .26, .61, 1 }
  local ridge = { .08, .43, .78, 1, .84, .48, .10 }
  local ids = {}
  local p0 = hash01(seed, 0, 1601) * TAU
  local p1 = hash01(seed, 1, 1607) * TAU
  lateralOffset = lateralOffset or 0

  for i = 0, steps do
    local u = i / steps
    local taper = .28 + .72 * math.sin(math.pi * u) ^ .38
    local meander = math.sin(u * TAU * 1.17 + p0) * 3.0
      + math.sin(u * TAU * 2.31 + p1) * 1.05
    local cx = x0 + vx * u + nx * meander
      + nx * lateralOffset
    local cz = z0 + vz * u + nz * meander
      + nz * lateralOffset
    local width = halfWidth * taper
      * (.82 + .18 * math.sin(u * TAU * 2.7 + p1))
    local height = crestHeight
      * (.84 + .18 * math.sin(u * TAU * 1.8 + p0))
    local crestShift = math.sin(u * TAU * 1.43 - p1) * width * .16
    ids[i + 1] = {}
    for lane = 1, #lanes do
      local side = lanes[lane] * width + crestShift * ridge[lane]
      local edgeNoise = math.sin(u * TAU * 3.1 + lane * 1.7 + p0) * .16
      local y = .42 + height * math.max(.045, ridge[lane] + edgeNoise)
      ids[i + 1][lane] = vertex(g, cx + nx * side, y, cz + nz * side,
        u * length / 44 + seed % 11, (lanes[lane] + 1) * .5)
    end
  end

  for i = 1, steps do
    for lane = 1, #lanes - 1 do
      local a, b = ids[i][lane], ids[i + 1][lane]
      local c, d = ids[i + 1][lane + 1], ids[i][lane + 1]
      tri(g, a, b, c)
      tri(g, a, c, d)
    end
  end
end

local function ribbonBank(g, x0, z0, x1, z1, halfWidth, height, seed)
  -- A broad shallow body supplies coverage; a narrower offset ridge gives the
  -- middle real opacity and height without stacking more floor footprints.
  ribbonSurface(g, x0, z0, x1, z1, halfWidth, height, seed, 0)
  ribbonSurface(g, x0, z0, x1, z1, halfWidth * .52,
                height * 1.30, seed + 83, halfWidth * .10)
  g.count = g.count + 1
  g.sumX = g.sumX + (x0 + x1) * .5
  g.sumZ = g.sumZ + (z0 + z1) * .5
end

local function build(map,layout)
  local banks, wisps = {}, {}
  for i = 1, GROUPS do banks[i], wisps[i] = group(), group() end

  local S = not layout and Structures.forMap(map)
  local wc = map.widthCells or ((map.def and map.def.width or 1) * 2)
  local hc = map.heightCells or ((map.def and map.def.height or 1) * 2)
  local graves, graveSet = {}, {}
  if layout then
    for _,point in ipairs(layout.anchors)do graves[#graves+1]=point;graveSet[point[2]*4096+point[1]]=true end
  else
  for cy = 0, hc - 1 do
    for cx = 0, wc - 1 do
      local found = false
      for dy = 0, 1 do
        for dx = 0, 1 do
          local s = S.shapeAt[keyOf(cx * 2 + dx, cy * 2 + dy)]
          if s and s.art == "post" then found = true end
        end
      end
      if found then
        graves[#graves + 1] = { cx, cy }
        graveSet[cy * 4096 + cx] = true
      end
    end
  end

  end

  local function walk(cx, cy)
    if layout then return layout.walk(cx,cy)end
    local ok, result = pcall(function() return map:isWalkableCell(cx, cy) end)
    return ok and result or false
  end
  local zoneSet = {}
  for cy = 0, hc - 1 do
    for cx = 0, wc - 1 do
      local nearest = math.huge
      for _, grave in ipairs(graves) do
        local dx, dz = cx - grave[1], cy - grave[2]
        nearest = math.min(nearest, dx * dx + dz * dz)
      end
      local key = cy * 4096 + cx
      if nearest <= 4.85 and (walk(cx, cy) or graveSet[key]) then
        zoneSet[key] = true
      end
    end
  end

  -- Primary east/west banks follow alternating contiguous grave-zone rows.
  -- Their 28-36px full widths overlap at most one neighbour, producing a
  -- connected blanket without a bright transparent lattice.
  for cy = 0, hc - 1 do
    local cx = 0
    while cx < wc do
      if zoneSet[cy * 4096 + cx] then
        local first = cx
        while cx + 1 < wc and zoneSet[cy * 4096 + cx + 1] do cx = cx + 1 end
        local last = cx
        if last - first >= 1 and cy % 2 == 0 then
          local seed = first * 97 + cy * 193 + last * 31
          local gi = 1 + math.floor(hash01(first, cy, 1709) * GROUPS)
          if gi > GROUPS then gi = GROUPS end
          local z = cy * 16 + 8 + (hash01(first, cy, 1721) - .5) * 4.5
          ribbonBank(banks[gi], first * 16 - 3, z,
            (last + 1) * 16 + 3, z,
            14.2 + hash01(first, cy, 1723) * 3.8,
            5.6 + hash01(last, cy, 1733) * 1.9, seed)
        end
      end
      cx = cx + 1
    end
  end

  -- Only a few compact upper wisps remain round; they are read in profile as
  -- evaporating crowns rather than repeated floor footprints.
  for _, grave in ipairs(graves) do
    local cx, cy = grave[1], grave[2]
    if hash01(cx, cy, 887) < .13 then
      local gi = 1 + math.floor(hash01(cx, cy, 773) * GROUPS)
      if gi > GROUPS then gi = GROUPS end
      local seed = cx * 97 + cy * 193
      local x = cx * 16 + 8 + (hash01(cx, cy, 907) - .5) * 8
      local z = cy * 16 + 8 + (hash01(cx, cy, 911) - .5) * 8
      cloudShell(wisps[gi], x, 6.8 + hash01(cx, cy, 919) * 3.8,
                 z, 4.1 + hash01(cx, cy, 929) * 2.2,
                 3.0 + hash01(cx, cy, 937) * 1.8,
                 3.8 + hash01(cx, cy, 941) * 2.0,
                 hash01(cx, cy, 947) * TAU, seed + 41)
    end
  end

  local out = { banks = {}, wisps = {}, centers = {}, count = #graves }
  for i = 1, GROUPS do
    if layout and layout.ground then
      for _,g in ipairs({banks[i],wisps[i]})do
        for _,v in ipairs(g.verts)do
          v[7]=layout.ground(v[1],v[3]);v[2]=v[2]+v[7]
        end
      end
    end
    out.banks[i] = Voxel3D.newMesh(banks[i].verts, banks[i].indices, FORMAT)
    out.wisps[i] = Voxel3D.newMesh(wisps[i].verts, wisps[i].indices, FORMAT)
    local n = math.max(1, banks[i].count)
    out.centers[i] = { banks[i].sumX / n, banks[i].sumZ / n }
  end
  return out
end

local function breathingModel(cx, cz, dx, dy, dz, scaleXZ, scaleY)
  return Mat4.mul(Mat4.translate(cx + dx, dy, cz + dz),
    Mat4.mul(Mat4.scale(scaleXZ, scaleY, scaleXZ),
             Mat4.translate(-cx, 0, -cz)))
end

local function drawFogMesh(mesh, img, model, pull, shader)
  if not mesh then return end
  if not shader then
    Voxel3D.draw(mesh, img, model, pull)
    return
  end
  pcall(mesh.setTexture, mesh, img)
  pcall(shader.send, shader, "model", "row", model or IDENTITY)
  pcall(shader.send, shader, "pull", pull or 0)
  love.graphics.draw(mesh)
end

-- Integrating elapsed time keeps the fog phase continuous when SPEED changes.
-- Multiplying the absolute timer would make every bank jump after a menu edit.
local function fogTime(now, speed)
  if not animReal then
    animReal, animTime = now, now
    return animTime
  end
  local dt = math.max(0, math.min(now - animReal, .25))
  animTime = animTime + dt * speed
  animReal = now
  return animTime
end

local function draw(map,layout)
  if not layout and not isTower(map) then return false end
  -- OFF must allocate no image, shader or map geometry on first use.
  if not TowerFogSettings.active() then return false end
  local img = mistTexture()
  if not img then return false end
  local slot = cache[map]
  if not slot then slot = build(map,layout); cache[map] = slot end

  local now = 0
  pcall(function() now = love.timer.getTime() end)
  local t = fogTime(now, TowerFogSettings.speedMultiplier())
  local alphaMult, heightMult =
    TowerFogSettings.thicknessMultipliers()
  local g = love.graphics
  local pushed = g and g.push and pcall(g.push, "all")
  local usedFallback = false
  pcall(function()
    local shader = fogShader()
    g.setDepthMode("lequal", false)
    g.setBlendMode("alpha", "alphamultiply")
    if g.setMeshCullMode then g.setMeshCullMode("none") end
    if shader then
      g.setShader(shader)
      pcall(shader.send, shader, "vp", "row", Voxel3D.vp)
      pcall(shader.send, shader, "eye", Voxel3D.eye)
      pcall(shader.send, shader, "curve", {
        Voxel3D.curveX or 0, Voxel3D.curveZ or 0, Voxel3D.curveK or 0
      })
    else
      usedFallback = true
      Voxel3D.seams(false)
      Voxel3D.glass(false)
      Voxel3D.lighting(false)
    end

    for i = 1, GROUPS do
      local phase = (i - 1) * TAU / GROUPS
      local dx = math.sin(t * .19 + phase) * 2.35
        + math.sin(t * .071 + phase * 1.7) * .70
      local dz = math.sin(t * .143 + phase * 1.31) * 1.85
        + math.cos(t * .061 + phase * .73) * .62
      local pulse = math.sin(t * .115 + phase)
      local c = slot.centers[i]
      local model = breathingModel(c[1], c[2], dx,
        .12 + math.sin(t * .13 + phase * 1.4) * .22, dz,
        1 + pulse * .038, (layout and not shader) and 1 or heightMult * (1 - pulse * .025))
      g.setColor(.94, .95, .96, .118 * alphaMult)
      drawFogMesh(slot.banks[i], img, model, 1.45, shader)

      local life = (t / 18.0 + (i - 1) / GROUPS) % 1
      local presence = math.sin(life * math.pi)
      presence = presence * presence
      if presence > .015 then
        g.setColor(.94, .95, .96, .108 * alphaMult * presence)
        drawFogMesh(slot.wisps[i], img,
          Mat4.translate(dx * .62, life * 8.5, dz * .62), 1.5, shader)
      end
    end
    Voxel3D.lighting(true)
    if usedFallback then
      Voxel3D.seams(true)
      Voxel3D.glass(true)
    end
    if g.setMeshCullMode then g.setMeshCullMode("none") end
  end)
  pcall(Voxel3D.lighting, true)
  if usedFallback then
    pcall(Voxel3D.seams, true)
    pcall(Voxel3D.glass, true)
  end
  if g and g.setMeshCullMode then pcall(g.setMeshCullMode, "none") end
  if pushed then pcall(g.pop) end
  return true
end

function Mist.draw(state) return draw(state and state.map) end
function Mist.drawBattle(map) return draw(map) end
function Mist.drawNative(map,layout) return layout and draw(map,layout) or false end

function Mist.invalidate()
  for _, slot in pairs(cache) do
    for _, set in ipairs({ slot.banks or {}, slot.wisps or {} }) do
      for _, mesh in pairs(set) do
        if mesh and mesh.release then pcall(mesh.release, mesh) end
      end
    end
  end
  cache = setmetatable({}, { __mode = "k" })
  if texture and texture.release then pcall(texture.release, texture) end
  texture = nil
  if softShader and softShader.release then pcall(softShader.release, softShader) end
  softShader, shaderTried = nil, false
end

Assets.register(Mist.invalidate)
return Mist
