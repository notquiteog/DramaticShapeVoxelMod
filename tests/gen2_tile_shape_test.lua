-- Gen 2 tile shapes: every solid on a Gold map resolves to what it IS, and
-- not to the generic 16px box the Gen 1 profile leaves behind.
--
-- What this is guarding against is a silent fallback rather than a crash.
-- TileShape keys its hand-authored groups on TILESET ID, every id in
-- data/voxel_heights.lua is a Gen 1 one, and Gold's are different names. So
-- on a Gen 2 boot rule 1 never fires, every solid falls through to `wall`,
-- and the mod reports itself perfectly healthy while drawing a town as a
-- field of identical cubes wearing their own facade art on the roof.
--
-- Two properties make that failure invisible to a weaker test, and this file
-- is shaped around both:
--
-- 1. The wrong answer is a VALID answer. `wall` is a real class with a real
--    height and a real art mode; nothing raises, nothing logs. Only the
--    DISTRIBUTION gives it away, which is why the cases below asserts on the
--    class of specific cells rather than on "forMap returned a table".
--
-- 2. The load-bearing flag is `authored`. The mesher's whole structure-fold
--    path is gated on it (ChunkMesher: `if s.art == "upright" and
--    s.authored`), and an unauthored box tops itself with `s.topTile or
--    tile` -- the tile's own front-facing drawing, laid flat. A classifier
--    that named every cell correctly and left the flag false would fix the
--    shapes and leave the textures exactly as broken as they were, so the
--    flag is asserted separately from the class.
--
-- The collision bytes and palette slots below are not invented. They were
-- read off four real Crystal maps (NEW_BARK_TOWN, ROUTE_29, VIOLET_CITY,
-- ILEX_FOREST) with the engine's own Permissions and TileAttrs modules, and
-- the classifier is written against the same vocabulary.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local GameVersion = require("src.core.GameVersion")

-- Where this mod's files are, RELATIVE TO CWD.
--
-- Two callers run this file from two different directories -- the suite
-- runner from the mod's own root, a one-off from the engine root -- and the
-- SDK reads mod files through `mods/<basename>` under `opts.root`, which
-- defaults to ".". A hardcoded "mods/DramaticShapeVoxelMod" is therefore
-- right from one of those and finds nothing from the other, and "finds
-- nothing" is not an error here: loadMod hands back a run whose `mod` is nil
-- and whose error list is empty, so the case dies indexing it rather than
-- saying what went wrong. Derive it from this file's own path instead.
local function modPath()
  local env = os.getenv("DS_MOD_PATH")
  if env and env ~= "" then return env end
  local self = arg and arg[0]
  local root = self and self:match("^(.*)[/\\]tests[/\\][^/\\]+$")
  if root == nil or root == "" then return "." end
  return root
end

local MOD_PATH = modPath()
local MOD_ID = "BATTLE_ART_VOXEL_FORK"

-- GSC BG palette slots as TileAttrs reports them (1-based; PAL_BG_YELLOW is
-- $04 and this engine calls it slot 5 -- src/world/gen2/Palettes.lua:119).
local GRAY, RED, GREEN, WATER, YELLOW, BROWN, ROOF = 1, 2, 3, 4, 5, 6, 7

-- tile id -> palette slot, the way a real Johto tileset carries it
local PALETTE_OF = {
  [5]  = GREEN,   -- grass ground
  [6]  = GRAY,    -- the town's paving
  [30] = GREEN,   -- tree
  [16] = ROOF,    -- a roof
  [26] = BROWN,   -- masonry, railings, rock
  [78] = GRAY,    -- a town sign
  [20] = WATER,   -- water
}

-- Real GSC collision bytes (constants/collision_constants.asm, and the
-- permission table at src/world/gen2/Permissions.lua).
local LAND, WALL_C, TALL_GRASS = 0x00, 0x07, 0x18
local LEDGE_DOWN, WATER_C, HEADBUTT, CUT = 0xa3, 0x29, 0x15, 0x12

-- A map the classifier can answer for: the two questions it asks are
-- `cellCollision` and `tileAt`, plus the environment for the outdoor gate.
local function fakeMap(cells, environment)
  local tileset = { id = "TILESET_JOHTO", imageWidth = 128, imageHeight = 128,
                    tilesPerRow = 16, tilePalettes = {} }
  for tile, slot in pairs(PALETTE_OF) do
    tileset.tilePalettes[tile + 1] = slot
  end
  return {
    id = "FAKE_MAP",
    tileset = tileset,
    def = { id = "FAKE_MAP", environment = environment or "TOWN" },
    cellCollision = function(_, cx, cy)
      local row = cells[cy]
      local cell = row and row[cx]
      return cell and cell[1] or WALL_C
    end,
    tileAt = function(_, tx, ty)
      local cx, cy = math.floor(tx / 2), math.floor(ty / 2)
      local row = cells[cy]
      local cell = row and row[cx]
      return cell and cell[2] or 26
    end,
    isWaterCell = function() return false end,
    isWalkableCell = function() return false end,
    -- groundAt asks these two as well: the bounds check (so an entity
    -- mid seam-step is not hoisted onto the border block) and the cell's
    -- bottom-left tile, which is the one collision is judged by.
    inBounds = function(_, cx, cy)
      return cx >= 0 and cy >= 0 and cells[cy] ~= nil and cells[cy][cx] ~= nil
    end,
    cellTile = function(self, cx, cy) return self:tileAt(cx * 2, cy * 2 + 1) end,
  }
end

-- row y -> col x -> { collision, tile }
--
--   . open ground     T tree          R roof
--   G tall grass      L ledge         W water
--   F a railing with open ground north and south of it
--   S a sign, likewise isolated
--   M masonry with solid neighbours, so a building's flank
local GROUND, TREE = { LAND, 6 }, { WALL_C, 30 }
local ROOF_CELL, MASONRY = { WALL_C, 16 }, { WALL_C, 26 }
local FENCE_CELL, SIGN_CELL = { WALL_C, 26 }, { WALL_C, 78 }
local GRASS_CELL, LEDGE_CELL = { TALL_GRASS, 5 }, { LEDGE_DOWN, 5 }
local WATER_CELL = { WATER_C, 20 }
local HEADBUTT_CELL, CUT_CELL = { HEADBUTT, 30 }, { CUT, 30 }

-- The fence and the sign sit in a column with open ground north AND south of
-- them, because that is what `thin` asks: a railing has the world on both
-- sides of it, a building's flank does not. The masonry column has a solid
-- neighbour precisely so it stays a wall.
local CELLS = {
  [0] = { [0] = GROUND, GROUND,      GROUND,     GROUND,     GROUND },
  [1] = { [0] = GROUND, GROUND,      ROOF_CELL,  GRASS_CELL, WATER_CELL },
  [2] = { [0] = GROUND, FENCE_CELL,  MASONRY,    SIGN_CELL,  LEDGE_CELL },
  [3] = { [0] = GROUND, GROUND,      MASONRY,    GROUND,     HEADBUTT_CELL },
  [4] = { [0] = GROUND, TREE,        MASONRY,    GROUND,     CUT_CELL },
}

GameVersion.set("crystal")
local run = T.sdk.loadMod(MOD_PATH,
  { data = T.fixtures.fresh(), generation = 2 })
T.eq(run.mod and run.mod.state, "loaded", "the mod loads on Crystal")

local exports = run.loader.exports[MOD_ID]
T.check(exports and exports.lib and exports.lib.require,
  "the mod published its lib namespace")
local lib = exports.lib.require

local G2 = lib("Gen2TileShape")
T.check(type(G2) == "table", "Gen2TileShape loads")
for _, name in ipairs({ "supports", "classAt", "at", "install", "census",
                        "paletteOf" }) do
  T.eq(type(G2[name]), "function", "Gen2TileShape." .. name .. " exists")
end

-- ------- the classifier, cell by cell
--
-- classAt takes the palettes rather than reading them, so these cases pin
-- the DECISION and not the lookup; `at` below exercises the lookup.
local map = fakeMap(CELLS, "TOWN")
local function palAt(cx, cy)
  local top = map:tileAt(cx * 2, cy * 2)
  local bot = map:tileAt(cx * 2, cy * 2 + 1)
  return G2.paletteOf(map.tileset, top), G2.paletteOf(map.tileset, bot)
end
local function classOf(cx, cy)
  return G2.classAt(map, cx, cy, palAt(cx, cy))
end

T.eq(G2.paletteOf(map.tileset, 30), GREEN, "a tree tile reads as PAL_BG_GREEN")
T.eq(G2.paletteOf(map.tileset, 16), ROOF, "a roof tile reads as PAL_BG_ROOF")

T.eq(classOf(0, 0), "ground", "open paving is ground")
T.eq(classOf(1, 4), "tree", "a GREEN solid is a tree")
T.eq(classOf(2, 1), "wall",
  "a PAL_BG_ROOF solid is WALL, not a class of its own -- the roof is the "
    .. "top of the building's drawing and has to be in the same region for "
    .. "the volume builder's gable to find it")
T.eq(classOf(3, 1), "grass", "the tall-grass collision is grass")
T.eq(classOf(4, 1), "water", "the water collision is water")
T.eq(classOf(4, 2), "ledge", "a ledge collision is a ledge")
T.eq(classOf(2, 2), "wall", "masonry with solid neighbours is a wall")
T.eq(classOf(1, 2), "fence", "a BROWN solid open on both sides is a fence")
T.eq(classOf(3, 2), "signpost", "a GRAY solid open on both sides is a signpost")
T.eq(classOf(4, 3), "tree", "a HEADBUTT tree is a tree")
T.eq(classOf(4, 4), "tree", "a CUT tree is a tree")

-- ------- the two rules that were wrong the first time
--
-- Both were found by censusing INTERIORS, not by reading the code, and both
-- are the same mistake in different clothes: reading a palette as a subject
-- when it is only a colour.
local indoor = fakeMap(CELLS, "INDOOR")
local function indoorClass(cx, cy)
  local top = indoor:tileAt(cx * 2, cy * 2)
  local bot = indoor:tileAt(cx * 2, cy * 2 + 1)
  return G2.classAt(indoor, cx, cy,
    G2.paletteOf(indoor.tileset, top), G2.paletteOf(indoor.tileset, bot))
end
T.eq(indoorClass(1, 2), "wall",
  "indoors a thin solid is a wall, not a fence -- DARK CAVE's rock pillars "
    .. "made 68 fences before this gate")
T.eq(indoorClass(3, 2), "wall",
  "indoors a GRAY thin solid is a wall, not a signpost")

-- water is decided by COLLISION and never by the palette: indoors that slot
-- is whatever the room's blue thing is, and reading it as water put five
-- cells of water inside ELM'S LAB
local drySet = { [0] = { [0] = { WALL_C, 20 } } }
local dry = fakeMap(drySet, "INDOOR")
T.eq(G2.classAt(dry, 0, 0, G2.paletteOf(dry.tileset, 20),
     G2.paletteOf(dry.tileset, 20)), "wall",
  "a PAL_BG_WATER solid is NOT water -- collision is the only water rule")

-- ------- the flag the mesher actually reads
local TileShape = lib("TileShape")
local shapes = TileShape.forMap(map)
T.check(type(shapes.gen2Classes) == "table",
  "forMap installed the Gen 2 class table")

local function shapeAt(cx, cy)
  return TileShape.at(map, shapes, map:tileAt(cx * 2, cy * 2 + 1),
                      cx * 2, cy * 2 + 1)
end
for _, want in ipairs({ { 1, 4, "tree" }, { 2, 1, "wall" }, { 2, 2, "wall" },
                        { 4, 1, "water" }, { 4, 2, "ledge" } }) do
  local s = shapeAt(want[1], want[2])
  T.check(type(s) == "table", "TileShape.at answers a shape at "
    .. want[1] .. "," .. want[2])
  if type(s) == "table" then
    T.eq(s.class, want[3], "TileShape.at: " .. want[1] .. "," .. want[2]
      .. " is " .. want[3])
    T.eq(s.authored, true,
      "the " .. want[3] .. " shape is AUTHORED -- the flag the mesher's "
        .. "structure fold is gated on")
  end
end

-- and the distribution, which is what the bug looked like: a map that
-- answers only ground and wall is the unclassified fallback
local census = G2.census(map, shapes, 5, 5)
local kinds = 0
for _ in pairs(census) do kinds = kinds + 1 end
T.check(kinds > 2,
  "a Gen 2 map resolves to more than {ground, wall} -- got "
    .. (function()
         local o = {}
         for k, v in pairs(census) do o[#o + 1] = k .. "=" .. v end
         table.sort(o)
         return table.concat(o, " ")
       end)())

-- ------- the three flags, which are three different questions
--
-- These were one flag once (`authored`) and every one of the reported
-- symptoms came from that: houses 16px tall, doors punched out of their
-- own facades, and every character in Johto standing a block in the air.
do
  local g2wall = shapes.gen2Classes.wall
  local g2ledge = shapes.gen2Classes.ledge
  local g2tree = shapes.gen2Classes.tree

  T.eq(g2wall.authored, true,
    "authored: fold my art properly (the mesher reads this)")
  T.eq(g2wall.derived, true,
    "derived: I am detection, not a hand pin, so a better detector may "
      .. "refine me (the door fold reads this)")
  T.eq(g2wall.volume, true,
    "volume: read my height off the drawing (Structures reads this)")

  -- and the classes that must NOT be volumed, because their height is a
  -- property of what they are rather than of how much is drawn
  T.eq(g2ledge.volume, nil,
    "a ledge is 6px because a ledge is 6px, however many rows the map paints")
  T.eq(g2ledge.h, 6, "so it keeps its class height")
  T.eq(shapes.gen2Classes.fence.volume, nil, "same for a fence")
  T.eq(g2tree.volume, nil,
    "and a tree is as tall as a tree, not as tall as the forest is deep -- "
      .. "volumed, VIOLET_CITY's 174 contiguous tree cells became one "
      .. "stepped plateau with the camera inside it")
  T.eq(g2tree.h, 16,
    "a tree is one cell high, the class default -- the 32px override was an "
      .. "overcorrection: at the 35-degree camera a 32px box leans two cells "
      .. "of screen space over the ground in front of it, so a tree border "
      .. "along a path read as growing INTO the path, and every bush in "
      .. "Johto stood two storeys tall. Gen 1 draws Kanto's trees one cell "
      .. "high and they read correctly there")
end

-- ------- the outdoor gate: indoors nothing is a volume and nothing is a fence
--
-- Volumed indoors, every solid answers `wall` -- Gen 2 has no profile to tell
-- a table from a bookshelf from the back of the room -- so a lab's furniture
-- and its walls were one region, and every table in ELM'S LAB became a 48px
-- tower. And ungated, `thin` made fences out of DARK CAVE's rock and Sprout
-- Tower's floor furniture. TOWN and ROUTE are the only environments GSC
-- itself treats as outside.
do
  local Structures = lib("Structures")
  local indoor = fakeMap(CELLS, "INDOOR")
  local indoorShapes = { classes = shapes.classes }
  T.eq(G2.install(indoorShapes, indoor), true,
    "the classifier still installs on an indoor map")
  T.eq(indoorShapes.gen2Classes.wall.volume, nil,
    "indoors a wall is NOT a volume -- the class height is the honest answer")
  T.eq(indoorShapes.gen2Classes.tree.volume, nil, "and a tree never was")
  T.eq(Structures.volumeClaims(indoorShapes.gen2Classes.wall), false,
    "so Structures leaves every indoor solid at its class height -- the "
      .. "reading that made ELM'S LAB's tables 48px towers is gone")
  local function indoorPal(cx, cy)
    local top = indoor:tileAt(cx * 2, cy * 2)
    local bot = indoor:tileAt(cx * 2, cy * 2 + 1)
    return G2.paletteOf(indoor.tileset, top), G2.paletteOf(indoor.tileset, bot)
  end
  T.eq(G2.classAt(indoor, 1, 2, indoorPal(1, 2)), "wall",
    "an isolated solid stays a wall indoors -- the thin test is an OUTDOOR "
      .. "reading, and ungated it made furniture into fences")
  T.eq(G2.classAt(indoor, 3, 2, indoorPal(3, 2)), "wall",
    "a gray solid indoors is a wall too, not a signpost")
end

-- ------- what Structures DOES with those flags
--
-- Asserting the flag values alone was not enough, and a mutation run
-- proved it: flipping `structural` back to `not s.authored` and flipping
-- the door fold back to skipping every authored shape both left this case
-- fully green. The flags are only interesting through the two decisions
-- that read them, so those are named and asked directly.
do
  local Structures = lib("Structures")
  local g2 = shapes.gen2Classes

  T.eq(Structures.volumeClaims(g2.wall), true,
    "the volume builder claims a Gen 2 wall, so a house is as tall as its "
      .. "facade is deep instead of a flat 16px slab")
  T.eq(Structures.volumeClaims(g2.ledge), false,
    "and does NOT claim a ledge, whose 6px is a property of what it is")
  T.eq(Structures.volumeClaims(g2.tree), false, "nor a tree")
  T.eq(Structures.volumeClaims(shapes.classes.wall), true,
    "Gen 1's unauthored wall is claimed exactly as it always was")
  T.eq(Structures.volumeClaims({ art = "upright", authored = true }), false,
    "and a Gen 1 profile pin is still left alone -- that is the rule this "
      .. "flag had to be added WITHOUT breaking")
  T.eq(Structures.volumeClaims({ art = "flat" }), false, "flat art is never a volume")
  T.eq(Structures.volumeClaims(nil), false, "and an absent shape is not one either")

  T.eq(Structures.doorFoldClaims(g2.ground), true,
    "the door fold may replace a DERIVED classification, which is what "
      .. "puts a Johto door into its own facade")
  T.eq(Structures.doorFoldClaims({ authored = true }), false,
    "but never a hand pin -- Celadon Mansion's staircases are door tiles, "
      .. "and their profile pins have to survive this")
  T.eq(Structures.doorFoldClaims({ authored = false }), true,
    "an unauthored shape is claimed the way it always was")
  T.eq(Structures.doorFoldClaims(nil), true, "so is an empty cell")
end

-- ------- roofRowsFor: where a facade stops and a roof starts
--
-- Gen 1 infers this from the art -- distinct top rows mean a pitch, a
-- repeated texture means a flat rooftop -- and on Johto that inference is
-- worthless, because the brick repeats and the answer comes back "no roof".
do
  T.eq(G2.roofRowsFor(map, 4, 2, 5), 2,
    "two roof-palette rows at the run's north end are two roof rows")
  T.eq(G2.roofRowsFor(map, 2, 4, 9), 0,
    "a run that does not start in roof palette has no roof rows")
  -- the count starts at the run's NORTH end and stops at the first row
  -- that is not roof, so a run beginning below the roof has none -- which
  -- is what keeps a tree or a rock face from growing a gable
  T.eq(G2.roofRowsFor(map, 4, 4, 5), 0,
    "a run starting below the roof rows counts none")
  T.eq(G2.roofRowsFor(map, 4, 3, 5), 1,
    "and one starting on the roof's last row counts just that row")
end

-- ------- the support height, which is what put everyone in the air
--
-- VoxelScene.groundAt used to read the per-TILE table, and on Gen 2 that
-- table cannot answer: forMap fills it from map.walkable and
-- map.waterTiles, and Gold has neither, so every tile fell to the `wall`
-- fallback. Measured on a real Crystal boot before the fix, groundAt
-- answered 16px for every cell of every map.
do
  local VoxelScene = lib("VoxelScene")
  T.eq(type(VoxelScene.groundAt), "function", "groundAt is reachable")

  -- the per-tile table must no longer claim `wall` for a tile it cannot
  -- classify: that claim is what a naive reader believes
  local anyTile = shapes[6]
  T.check(anyTile ~= nil, "the per-tile table is still filled")
  T.eq(anyTile.class, "ground",
    "an unclassifiable Gen 2 tile defaults to flat ground, not to a 16px "
      .. "wall -- the wall default is what lifted every character")

  T.eq(VoxelScene.groundAt(map, 0, 0), 0, "open paving supports at 0")
  T.eq(VoxelScene.groundAt(map, 3, 1), 0, "so does tall grass")
  T.eq(VoxelScene.groundAt(map, 4, 2), 6,
    "a ledge supports at its own 6px, so standing on one is standing ON it")
  T.eq(VoxelScene.groundAt(map, 1, 4), 16,
    "and a tree reports its full height, which is what a shadow and a "
      .. "billboard behind it need")
end

-- ------- Gen 1 is untouched
--
-- The classifier must not exist on a Gen 1 boot at all: its whole job is to
-- stand where the authored profile stands, and a Gen 1 map HAS one.
run.release()
GameVersion.set("red")
local gen1 = T.sdk.loadMod(MOD_PATH, { data = T.fixtures.fresh(), generation = 1 })
T.eq(gen1.mod and gen1.mod.state, "loaded", "the mod still loads on Red")
local lib1 = gen1.loader.exports[MOD_ID].lib.require
local G2on1 = lib1("Gen2TileShape")
T.eq(G2on1.supports(map), false,
  "the Gen 2 classifier refuses a Gen 1 boot, so an authored profile is "
    .. "never overruled")
gen1.release()

T.finish("gen 2 tile shapes")
