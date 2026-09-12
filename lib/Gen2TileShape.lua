-- What a Gen 2 tile IS, so the mesher can build it as that thing.
--
-- TileShape resolves a tile to an extrusion shape from the hand-authored
-- groups in data/voxel_heights.lua, keyed by TILESET ID. Every id in that
-- file is a Gen 1 one -- OVERWORLD, GYM, CAVERN, FOREST, DOJO -- and Gold's
-- are TILESET_JOHTO, TILESET_FOREST, TILESET_TOWER, TILESET_DARK_CAVE and
-- friends. None of them match, so on a Gen 2 boot rule 1 never fires and
-- every tile falls through to the generic cell rules:
--
--   TileShape.at over a 16x16 patch of NEW_BARK_TOWN answered
--   ground=92 wall=164, and nothing else.
--
-- A tile classed `wall` is a 16px cube with art "upright" and, crucially,
-- `authored = false` -- and the mesher's whole structure-fold path is gated
-- on `s.authored` (ChunkMesher: `if s.art == "upright" and s.authored`).
-- Unauthored, the top face falls back to `s.topTile or tile`: the tile's OWN
-- front-facing drawing, laid flat on the roof. That is exactly the reported
-- symptom -- trees, buildings and fences all the same 16px box, wearing
-- their own facade art on top.
--
-- The fix is NOT to hand-author a second 8000-line profile. Gold already
-- carries the classification, in two places this mod can read:
--
--   the COLLISION byte  per 16x16 cell, the cart's own tile-type table
--                       (src/world/gen2/Permissions.lua): land, water,
--                       wall, tall grass, ledge + facing, cut tree,
--                       headbutt tree, counter, waterfall, warp carpet.
--
--   the PALETTE SLOT    per 8x8 tile, GSC's eight BG palettes
--                       (src/world/gen2/TileAttrs.lua). The slot is
--                       semantic, not decorative: PAL_BG_GREEN is
--                       foliage, PAL_BG_ROOF is a roof and nothing else
--                       (its colours are per map-group, which is why a
--                       Johto roof is red and a Kanto one is not),
--                       PAL_BG_WATER is water.
--
-- Crossed, they separate every solid this mod has a shape for. Measured
-- over four real maps (New Bark, Route 29, Violet, Ilex):
--
--   perm=WALL  pal=GREEN   409 cells   trees and bushes
--   perm=WALL  pal=ROOF     28 cells   roofs, and only roofs -- zero on routes
--   perm=WALL  pal=BROWN    68 cells   masonry, fences, rock faces
--   perm=LAND  coll=0x18    24 cells   tall grass
--   perm=LAND  coll=0xa0-5  14 cells   ledges, with their jump facing
--   perm=WATER coll=0x29   108 cells   water
--
-- So this reads as the Gen 2 counterpart of the authored profile rather
-- than as a heuristic: the same questions Gen 1 answers by hand, answered
-- from the data Gold ships. It also generalises -- a tileset nobody has
-- looked at classifies itself.
--
-- Shapes come back marked `authored = true`, which is the point: that flag
-- is what puts the mesher on its structure path, so a run of tree cells
-- folds as one drawing and a roof wears its own top row.

local V = ...
local Generation = V.require("Generation")

local Gen2TileShape = {}

-- GSC's eight BG palette slots, 1-based the way TileAttrs reports them
-- (constants/palette_constants.asm; PAL_BG_YELLOW is $04 and this engine
-- calls it slot 5 -- src/world/gen2/Palettes.lua:119).
local PAL_GRAY, PAL_RED, PAL_GREEN, PAL_WATER = 1, 2, 3, 4
local PAL_YELLOW, PAL_BROWN, PAL_ROOF, PAL_TEXT = 5, 6, 7, 8

Gen2TileShape.PAL = {
  GRAY = PAL_GRAY, RED = PAL_RED, GREEN = PAL_GREEN, WATER = PAL_WATER,
  YELLOW = PAL_YELLOW, BROWN = PAL_BROWN, ROOF = PAL_ROOF, TEXT = PAL_TEXT,
}

local function modules()
  local okP, Permissions = pcall(require, "src.world.gen2.Permissions")
  if not okP or type(Permissions) ~= "table" then return nil end
  local okT, TileAttrs = pcall(require, "src.world.gen2.TileAttrs")
  if not okT or type(TileAttrs) ~= "table" then return nil end
  return Permissions, TileAttrs
end

-- Does this map answer the two questions?  A stub map in a test, and a
-- Gen 1 map reached through some path that did not gate, both say no.
function Gen2TileShape.supports(map)
  if not Generation.isGen2() then return false end
  if type(map) ~= "table" then return false end
  if type(map.cellCollision) ~= "function" then return false end
  if type(map.tileAt) ~= "function" then return false end
  local tileset = map.tileset
  if type(tileset) ~= "table" then return false end
  return modules() ~= nil
end

-- The palette slot a tile wears, or nil when the tileset cannot say.
function Gen2TileShape.paletteOf(tileset, tileId)
  local _, TileAttrs = modules()
  if not (TileAttrs and tileId) then return nil end
  local ok, attr = pcall(TileAttrs.forTile, tileset, tileId)
  if not ok or type(attr) ~= "table" then return nil end
  return attr.palette
end

-- One shape object per class, shared across the map.
--
-- Shared deliberately: the mesher decides a structure's extent by walking
-- neighbours and comparing `bs.class == s.class`, so two cells of the same
-- class must compare equal for a building to fold as one building rather
-- than as a column of unrelated boxes.
local function classTable(shapes)
  local out = {}
  for class, shape in pairs(shapes.classes or {}) do
    -- copy, because shapes.classes entries are the UNAUTHORED canonical
    -- objects the Gen 1 cell rules hand out; marking those authored in
    -- place would put every fallback tile on the structure path
    out[class] = { class = shape.class, h = shape.h, art = shape.art,
                   flat = shape.flat, authored = true }
  end
  return out
end

-- A wall cell one cell thick, with open ground on both sides of it: a
-- fence or a railing rather than a building's flank.  Judged on the cell
-- grid because that is where Gold's collision lives.
local function thin(map, Permissions, cx, cy)
  local function solid(x, y)
    local ok, coll = pcall(map.cellCollision, map, x, y)
    if not ok then return true end
    return Permissions.of(tonumber(coll) or -1) == Permissions.WALL
  end
  local ns = (not solid(cx, cy - 1)) and (not solid(cx, cy + 1))
  local ew = (not solid(cx - 1, cy)) and (not solid(cx + 1, cy))
  return ns or ew
end

-- Fences and signs are an OUTDOOR reading, and the gate is not fussiness:
-- `thin` asks whether a solid has open ground on both sides, which is true
-- of a railing and equally true of a rock pillar in a cave or a pew in
-- Sprout Tower. Ungated it made 68 fences out of DARK CAVE's rock and 10
-- out of the tower's floor furniture. TOWN and ROUTE are the two
-- environments GSC itself treats as outside (Palettes.ROOF_ENVIRONMENTS).
local OUTDOOR = { TOWN = true, ROUTE = true }

local function outdoor(map)
  local def = map and map.def
  return def ~= nil and OUTDOOR[def.environment] == true
end

-- The class for one CELL.  Collision first -- it is the cart's own answer
-- and outranks anything read off the art -- then the palette for the
-- solids collision lumps together as WALL.
function Gen2TileShape.classAt(map, cx, cy, palTop, palBot)
  local Permissions = modules()
  if not Permissions then return nil end
  local ok, coll = pcall(map.cellCollision, map, cx, cy)
  coll = ok and tonumber(coll) or nil
  if coll == nil then return nil end

  local perm = Permissions.of(coll)

  if perm == Permissions.WATER then
    return Permissions.isWaterfall(coll) and "wall" or "water"
  end

  if perm ~= Permissions.WALL then
    -- walkable: the only shapes here are the ones that stand ON walkable
    -- ground.  Tall grass keeps its own class (flat base plus standing
    -- tufts); a ledge is the 6px lip you hop off.
    if Permissions.isGrass(coll) then return "grass" end
    if Permissions.isLedge(coll) then return "ledge" end
    return "ground"
  end

  -- solid.  Trees are named twice over: by collision when they are a CUT
  -- or HEADBUTT tree, and by palette otherwise -- and both agree, which is
  -- what makes the palette rule trustworthy for the plain ones.
  if Permissions.isCutTree(coll) or Permissions.isHeadbuttTree(coll) then
    return "tree"
  end
  if Permissions.isCounter(coll) then return "counter" end

  if palTop == PAL_ROOF or palBot == PAL_ROOF then return "roof" end
  if palTop == PAL_GREEN then return "tree" end
  -- deliberately NO palette rule for water. Collision already answers it
  -- (perm == WATER, above) and answers it authoritatively; adding
  -- `palTop == PAL_WATER` on top of that found five cells of water inside
  -- ELM'S LAB and one in the player's house, because indoors the slot is
  -- reused for whatever the room's blue thing is -- a TV, a machine, a
  -- poster. A palette says what something is COLOURED, and only the ones
  -- GSC reserves (ROOF) or paints one subject with (GREEN) survive that.

  -- A solid cell with open ground on both sides is not a building's
  -- flank: it is a fence, a railing or a sign standing on its own. GRAY
  -- separates the last of those -- GSC paints town signs and mailboxes
  -- PAL_BG_GRAY, and over the four sampled outdoor maps that pairing
  -- picked out four cells, every one of them a sign. The `thin` test
  -- carries the safety: a building cell has solid neighbours and can
  -- never reach either branch, so the worst a misread does here is make
  -- one post the wrong height.
  if outdoor(map) and thin(map, Permissions, cx, cy) then
    if palTop == PAL_GRAY then return "signpost" end
    return "fence"
  end
  return "wall"
end

-- Resolve one TILE position.  Returns a shape, or nil to let the caller
-- fall through to its own rules.
function Gen2TileShape.at(map, shapes, tile, tx, ty)
  local classes = shapes and shapes.gen2Classes
  if type(classes) ~= "table" then return nil end
  local cx, cy = math.floor(tx / 2), math.floor(ty / 2)
  local tileset = map.tileset
  local okT, top = pcall(map.tileAt, map, cx * 2, cy * 2)
  local okB, bot = pcall(map.tileAt, map, cx * 2, cy * 2 + 1)
  local palTop = okT and Gen2TileShape.paletteOf(tileset, tonumber(top)) or nil
  local palBot = okB and Gen2TileShape.paletteOf(tileset, tonumber(bot)) or nil
  local class = Gen2TileShape.classAt(map, cx, cy, palTop, palBot)
  if not class then return nil end
  return classes[class] or classes.wall
end

-- Attach the per-class table to a shapes record.  Called once per map from
-- TileShape.forMap, so the copies above are made once rather than per tile.
function Gen2TileShape.install(shapes, map)
  if not Gen2TileShape.supports(map) then return false end
  shapes.gen2Classes = classTable(shapes)
  return true
end

-- How many cells of each class this map resolves to.  Read by the test, so
-- "the classifier fired" is a measurement rather than an inference: a map
-- that answers only ground and wall is the bug this module exists for.
function Gen2TileShape.census(map, shapes, w, h)
  local out = {}
  if type(shapes) ~= "table" or type(shapes.gen2Classes) ~= "table" then
    return out
  end
  for cy = 0, (tonumber(h) or 0) - 1 do
    for cx = 0, (tonumber(w) or 0) - 1 do
      local okT, top = pcall(map.tileAt, map, cx * 2, cy * 2)
      local okB, bot = pcall(map.tileAt, map, cx * 2, cy * 2 + 1)
      local palTop = okT and Gen2TileShape.paletteOf(map.tileset, tonumber(top)) or nil
      local palBot = okB and Gen2TileShape.paletteOf(map.tileset, tonumber(bot)) or nil
      local class = Gen2TileShape.classAt(map, cx, cy, palTop, palBot) or "?"
      out[class] = (out[class] or 0) + 1
    end
  end
  return out
end

return Gen2TileShape
