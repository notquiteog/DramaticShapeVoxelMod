-- The cave ladders must be ladders, not staircases.
--
-- Gen 1 draws both cave ladder graphics from ABOVE, as a shaft with two
-- rails and rungs between them, and the warp table says which is which:
-- across all nineteen cave maps every one of the 37 $08 cells warps to a
-- lower floor and every one of the 40 $0A cells to a higher one, 77 cells
-- with no exceptions.
--
-- They used to be pinned `stair_e` / `stair_down_e`.  A staircase runs
-- along an AXIS, so that threw a four-step stepped wedge across a cell
-- whose drawing is a ladder lying in it -- the profile's own note conceded
-- the flight was only "as close to a drawn ladder as stepped geometry
-- gets".  They are a standee pool now: the same per-pixel object pass that
-- builds signs, posts and bicycles stands the drawing up and voxelizes it.
--
-- There is no ladder-specific builder, by design, so the whole fix is
-- vocabulary and a pin -- which is exactly what can be silently undone.
-- A pin naming a class TileShape does not know is DEAD (heights() drops it
-- and the tile falls through to detection saying nothing), and an `art`
-- that is not "billboard" would route these cells to the box builder and
-- render a wall wearing ladder art.  Both are checked here.
--
--   DS_MOD_PATH=mods/BattleArtVoxelFork \
--     luajit mods/BattleArtVoxelFork/tests/cave_ladder_test.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local MOD_PATH = os.getenv("DS_MOD_PATH") or "mods/DramaticShapeVoxelMod"
local ROOT = os.getenv("DS_REPO_ROOT") or "."
local base = ROOT .. "/" .. MOD_PATH
local modules, dataFiles = {}, {}
local V = {}
function V.require(name)
  if modules[name] ~= nil then return modules[name] end
  local value = assert(loadfile(base .. "/lib/" .. name .. ".lua"))(V)
  modules[name] = value
  return value
end
function V.data(name)
  if dataFiles[name] ~= nil then return dataFiles[name] end
  local value = assert(loadfile(base .. "/data/" .. name .. ".lua"))(V)
  dataFiles[name] = value
  return value
end

local TileShape = V.require("TileShape")
local Structures = V.require("Structures")
local spec = V.data("voxel_heights")

-- PINNED_DEPTH is a file local, and the function that reads it is a local
-- too, so no exported function closes over it directly -- an exported one
-- closes over the LOCAL FUNCTION, which closes over the table.  Walk the
-- upvalue graph rather than naming a function that happens to reach it
-- today, and identify the table by its shape so a rename does not blind
-- the check.
local function findDepthTable(root)
  local seen = {}
  local function walk(fn, depth)
    if depth > 4 or seen[fn] then return nil end
    seen[fn] = true
    for i = 1, 200 do
      local name, value = debug.getupvalue(fn, i)
      if not name then break end
      if type(value) == "table" and type(value.bike) == "number"
         and type(value.billboard) == "number" then
        return value
      end
      if type(value) == "function" then
        local hit = walk(value, depth + 1)
        if hit then return hit end
      end
    end
    return nil
  end
  for _, v in pairs(root) do
    if type(v) == "function" then
      local hit = walk(v, 1)
      if hit then return hit end
    end
  end
  return nil
end

-- ---- the class exists and is a standee ----

local heights = TileShape.heights()
T.eq(heights.ladder, 16, "a ladder stands the height of the rock band")
T.eq(heights.ladder_up, 16, "a warp-up ladder shaft stands the rock band")
T.eq(heights.ladder_down, 16, "a warp-down ladder shaft stands the rock band")

local cavern = spec.tilesets.CAVERN
-- The pins are `ladder_up` / `ladder_down`, not one `ladder` class, as of
-- c22a6a6 (1.24.0-test.1). The split is not cosmetic: a warp ladder is a
-- SHAFT with a rim and a direction, so Structures.buildStairs reads
-- `s.class == "ladder_down"` to decide the cell is the hole rather than a
-- riser, and hands it to CaveLadders instead of a stair builder. This test
-- still asserted the pre-split single class, so it had been failing since.
T.eq(table.concat(cavern.ladder_up or {}, ","), "10,11,26,27",
  "the cells that warp UP pin `ladder_up`: $0A/$0B over $1A/$1B")
T.eq(table.concat(cavern.ladder_down or {}, ","), "8,9,24,25",
  "the cells that warp DOWN pin `ladder_down`: $08/$09 over $18/$19")
T.check(cavern.ladder == nil,
  "and no cell is still pinned to the undivided `ladder` standee class")
T.check(cavern.stair_e == nil and cavern.stair_down_e == nil,
  "and nothing in the caves is pinned to a staircase any more")

-- ---- it reaches the shaft builder, not the box builder ----

local shapes = TileShape.forMap({
  tileset = { id = "CAVERN", image = "gfx/tilesets/ds_cave.png",
              tilesPerRow = 16, imageWidth = 128, imageHeight = 48,
              blocks = {}, grassTile = -1 },
})
-- art must be "stair": that is what routes the cell to
-- Structures.buildStairs -> CaveLadders.build, which voxelises the source
-- rails and rungs and cuts the hole. art "billboard" would stand the drawing
-- up as a flat card over a solid floor, and art "upright" would box it.
local WANT = {
  [10] = "ladder_up", [11] = "ladder_up", [26] = "ladder_up",
  [27] = "ladder_up", [8] = "ladder_down", [9] = "ladder_down",
  [24] = "ladder_down", [25] = "ladder_down",
}
for tile, cls in pairs(WANT) do
  local s = shapes[tile]
  T.check(s ~= nil and s.class == cls,
    ("tile %d resolves to `%s`"):format(tile, cls))
  T.check(s ~= nil and s.art == "stair",
    ("tile %d reaches the shaft builder, not the box builder"):format(tile))
  T.check(s ~= nil and s.authored == true,
    ("tile %d is authored, so detection cannot overrule it"):format(tile))
  T.eq(s and s.h, 16, ("tile %d stands the full rock band"):format(tile))
end

-- ---- and it carves at the thickness that keeps the rungs apart ----

-- A ladder is mostly the air between its rungs, and that negative space is
-- what makes it read as a ladder from anywhere but dead-on.  At the 10 the
-- default standee pool gives, the side faces of neighbouring rungs close
-- every gap off-axis and the drawing silts up into a plate.  Two is the
-- `bike` figure and it is here for the same reason a bicycle needs it.
--
-- This used to assert PINNED_DEPTH.ladder == 2.  Since the pins split into
-- ladder_up/ladder_down (c22a6a6) the ladder is art=="stair", not
-- art=="billboard", so PINNED_DEPTH was never consulted for it and the entry
-- was dead -- the standee pass could not reach it.  CaveLadders carves the
-- rails and rungs two voxels deep in its own fill calls, so the thickness
-- guarantee survives; it is asserted on the builder now instead of on a
-- table that no longer participates.
local depth = findDepthTable(Structures)
T.check(depth ~= nil, "the standee depth table is reachable to check")
if depth then
  T.eq(depth.ladder, nil,
    "the standee table carries no ladder depth: a warp ladder is not a standee")
  T.eq(depth.bike, 2, "and the two-voxel figure it borrowed is still `bike`")
end
-- The shaft builder must still carve two voxels deep, or the rungs fuse into
-- a plate. Asserted by BUILDING one, not by reading its source: a stub scene
-- collects the quads CaveLadders emits and the distinct z values they span
-- must be exactly two.
do
  local CaveLadders = V.require("CaveLadders")
  local Budget = V.require("BuildBudget")
  Budget.tick = function() end
  Budget.check = function() end
  local zseen = {}
  -- CaveLadders reads the scene's own tile grid (S.tileAt), the same grid the
  -- mesher filled, keyed by key(z+64)*4096+x+64. Populate the ladder cell and
  -- its neighbours with the CAVERN ladder tiles so the source lookup resolves.
  local S = {
    tileAt = {},
    objectQuads = {},
    skip = {},
    ground = {},
  }
  for z = -4, 8 do for x = -4, 8 do
    S.tileAt[(z + 64) * 4096 + x + 64] = 22
  end end
  -- The ladder cell itself, at the tile the builder will read back:
  -- key(cx*2+dx, cy*2+dy) with cx=cy=2 spans x,z in 4..5.
  for z = 4, 5 do for x = 4, 5 do
    S.tileAt[(z + 64) * 4096 + x + 64] = 10
  end end
  -- CaveLadders.rim asks TileShape for each neighbouring cell's shape, so the
  -- stub map needs the same surface a real one has: a tileset with a blocks
  -- table, a width, and tileAt that answers inside it.
  local map = {
    tileset = { id = "CAVERN", imageWidth = 128, imageHeight = 48,
                tilesPerRow = 16, blocks = {}, grassTile = -1 },
    id = "LADDER_FIXTURE",
    widthCells = 6, heightCells = 6,
    inBounds = function(_, x, y) return x >= 0 and y >= 0 and x < 6 and y < 6 end,
    cellCollision = function() return nil end,
    tileAt = function(_, tx, ty)
      if tx < 0 or ty < 0 or tx > 11 or ty > 11 then return 22 end
      return 22
    end,
  }
  -- A ladder_up cell sits on walkable ground to the south.
  map.isWalkableCell = function(_, x, y) return y > 0 end
  local ok, err = pcall(CaveLadders.build, S, map, {}, 2, 2, { class = "ladder_up" })
  T.check(ok, "CaveLadders builds an up-shaft without error: " .. tostring(err))
  T.check(#S.objectQuads > 0, "and it emits geometry")
  for _, q in ipairs(S.objectQuads) do
    for i = 1, 4 do
      local p = q[i]
      if type(p) == "table" and type(p[3]) == "number" then
        zseen[math.floor(p[3])] = true
      end
    end
  end
  local zs = 0
  for _ in pairs(zseen) do zs = zs + 1 end
  T.check(zs > 0 and zs <= 2,
    ("the shaft stays two voxels thick, keeping the rungs apart (saw %d z planes)")
      :format(zs))
end

-- ---- no dead pins anywhere in the profile ----

-- This has already cost this profile once: Celadon's four staircases were
-- pinned onto door tiles and silently did nothing.  A tileset entry holds
-- class pins alongside its own settings (`heights`, `figures`,
-- `when_above`, ...), and the two are told apart by SHAPE rather than by a
-- list of reserved names a later setting would fall off of -- a class pin
-- is an array of tile NUMBERS, every setting is keyed by tile or is an
-- array of tables.
local dead = {}
for setId, entry in pairs(spec.tilesets) do
  for class, tiles in pairs(entry) do
    if class ~= "sapling_tiles" -- explicit detector metadata, not a shape pin
       and type(tiles) == "table" and type(tiles[1]) == "number"
       and heights[class] == nil then
      dead[#dead + 1] = setId .. "." .. class
    end
  end
end
table.sort(dead)
T.eq(#dead, 0, "every class the profile pins is one TileShape resolves: "
  .. table.concat(dead, ", "))

if T.failures > 0 then
  error(("cave ladders: %d failure(s)"):format(T.failures))
end
print(("PASS cave ladders (%d checks)"):format(T.checks))
