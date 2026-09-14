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

-- Named collision cells provide the foliage artwork vocabulary.
-- Palette GREEN alone also describes grass-topped rock, so it cannot identify
-- a tree. Read all blocks, including ones not placed on the current map.
local vocabularyCache = setmetatable({}, { __mode = "k" })
local function vocabulary(tileset, Permissions)
  if not (tileset and tileset.blocks and tileset.collision) then return nil end
  if vocabularyCache[tileset] then return vocabularyCache[tileset] end
  local out = { crowns = {}, roots = {} }
  for id, block in pairs(tileset.blocks) do
    local coll = tileset.collision[id]
    if coll then
      for cy = 0, 1 do for cx = 0, 1 do
        local i = cy * 8 + cx * 2 + 1
        local c = coll[cy * 2 + cx + 1]
        if c and block[i] and block[i+1] and block[i+4] and block[i+5] then
          if Permissions.isHeadbuttTree(c) then
            out.crowns[block[i] .. ":" .. block[i+1]] = true
            out.roots[block[i+4] .. ":" .. block[i+5]] = true
          end
        end
      end end
    end
  end
  vocabularyCache[tileset] = out
  return out
end

local function drawing(map, cx, cy)
  local ids = {}
  for dy = 0, 1 do for dx = 0, 1 do
    ids[#ids + 1] = map:tileAt(cx * 2 + dx, cy * 2 + dy)
  end end
  return ids
end

-- One shape object per class, shared across the map.
--
-- Shared deliberately: the mesher decides a structure's extent by walking
-- neighbours and comparing `bs.class == s.class`, so two cells of the same
-- class must compare equal for a building to fold as one building rather
-- than as a column of unrelated boxes.
-- Classes whose height is a property of the DRAWING, not of the class.
-- A house is as tall as its facade is deep; a tree mass is as tall as it
-- is drawn. Everything else here has a height because of what it is.
-- ...and only OUTDOORS, which is the other half of the same sentence.
--
-- A volume reading says "you are as tall as your drawing is deep", and that
-- is true of a house because a house's facade IS drawn going up the map.
-- It is not true of a room. Indoors every solid answers `wall` -- Gen 2 has
-- no profile to tell a table from a bookshelf from the back of the room --
-- so a lab's furniture and its walls are one region, and the region's
-- extent is however deep the furnished end of the room happens to be.
-- ELM'S LAB has three cells of solid across its top, so every table in it
-- became a 48px tower. Indoors the class height is the honest answer: one
-- cell, the height Gen 1 gives an unauthored interior wall.
local VOLUME_CLASSES = { wall = true, cliff = true }

-- Trees keep a one-cell footprint and use the Gen 1 carved round hull.
-- Border trees are twice the height of interactive cut/headbutt bushes;
-- neither joins the neighbouring forest into a volume.

-- How many rows at a run's north end are roof.
--
-- The volume builder asks this to decide where a structure's facade stops
-- and its roof slope begins. Gen 1 infers it from the art -- distinct top
-- rows mean a pitched roof, a repeated texture means a flat rooftop --
-- and on Johto that inference is worthless, because the brick repeats
-- everywhere and the answer comes back "no roof, and while we are here,
-- your house is 16px tall".
--
-- PAL_BG_ROOF answers it outright. GSC reserves the slot: its two colours
-- are rewritten per map group (Palettes.bgSet, `roofSlot`), which is the
-- whole reason a Johto roof is red and a Kanto one is not, and nothing
-- else in a tileset wears it.
--
-- Capped at 2 the way the Gen 1 reading is, and floored at 0 for a run
-- with no roof in it at all (a tree, a rock face, a fence post).
function Gen2TileShape.roofRowsFor(map, tx, north, front)
  if type(map) ~= "table" or type(map.tileAt) ~= "function" then return 0 end
  local tileset = map.tileset
  local rows = 0
  for ty = north, math.min(front, north + 1) do
    local ok, tile = pcall(map.tileAt, map, tx, ty)
    if not ok then break end
    if Gen2TileShape.paletteOf(tileset, tonumber(tile)) ~= PAL_ROOF then break end
    rows = rows + 1
  end
  return rows
end

local function classTable(shapes, outdoors)
  local out = {}
  for class, shape in pairs(shapes.classes or {}) do
    -- copy, because shapes.classes entries are the UNAUTHORED canonical
    -- objects the Gen 1 cell rules hand out; marking those authored in
    -- place would put every fallback tile on the structure path
    out[class] = { class = shape.class, h = shape.h, art = shape.art,
                   flat = shape.flat, authored = true,
                   -- Classified, not hand-pinned.
                   --
                   -- `authored` tells the mesher to fold this shape's art
                   -- properly, and it tells every DETECTOR in Structures to
                   -- keep its hands off -- because on Gen 1 an authored
                   -- shape is a human's decision and detection must not
                   -- overrule it. A Gen 2 shape is not that: it is
                   -- detection itself, and a more specific detector is
                   -- welcome to refine it. The door fold is the case that
                   -- found this -- it skips authored cells, so on Gen 2 it
                   -- never ran and every house wore a hole where its door
                   -- should be.
                   derived = true,
                   -- Whether Structures may region this into a VOLUME and
                   -- read its height off the drawing, rather than taking
                   -- the class height as final.
                   --
                   -- `authored` alone cannot express this. It means two
                   -- things at once -- "fold my art intelligently" to the
                   -- mesher, "do not volume me" to Structures -- and Gen 2
                   -- needs the first without the second. Marked true, a
                   -- Johto house was a 16px box with a slab on it; marked
                   -- false it stood up and lost its textures. This flag
                   -- splits them.
                   --
                   -- Only the classes whose real height IS how much of
                   -- them is drawn. A ledge is 6px because a ledge is
                   -- 6px, however many rows of it the map paints, and the
                   -- same goes for fences and signposts.
                   volume = (outdoors and VOLUME_CLASSES[class]) or nil }
  end
  out.tree.art, out.tree.h = "planter", 32
  out.foresttree = { class = "foresttree", art = "canopy", h = 40,
    authored = true, derived = true }
  out.roundtree = { class = "roundtree", art = "cylinder", h = 28,
    authored = true, derived = true }
  out.bush = { class = "bush", art = "cylinder", h = 16,
               authored = true, derived = true }
  out.rock = { class = "rock", art = "cylinder", h = 16,
               authored = true, derived = true }
  out.boulder = { class = "boulder", art = "canopy", h = 24,
                  authored = true, derived = true }
  out.oceanrock = { class = "oceanrock", art = "oceanrock", h = 4,
                    authored = true, derived = true }
  out.fence.art = "post"
  if not outdoors then
    -- Confine texture folding to the object's own 16px collision cell.
    -- Adjacent furniture and the back wall share a class indoors.
    out.wall.foldCell = true
    out.counter.foldCell = true
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
  return def ~= nil and (OUTDOOR[def.environment] == true
    or (map.tileset and map.tileset.id == "TILESET_FOREST"))
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

  local tsid=map.tileset and map.tileset.id
  if perm==Permissions.WALL and (tsid=="TILESET_FOREST" or tsid=="TILESET_PARK") then
    local grid={{12,13,14,15},{28,29,30,31},{44,45,46,47},{60,61,62,63}}
    local offsets={["12,13,28,29"]={0,0},["14,15,30,31"]={1,0},
      ["44,45,60,61"]={0,1},["46,47,62,63"]={1,1}}
    local off=offsets[table.concat(drawing(map,cx,cy),",")]
    if off then
      local whole=true
      for y=1,4 do for x=1,4 do
        if map:tileAt((cx-off[1])*2+x-1,(cy-off[2])*2+y-1)~=grid[y][x] then whole=false end
      end end
      if whole then return "foresttree" end
    end
  end
  if perm==Permissions.WALL and tsid=="TILESET_KANTO" then
    local sig=table.concat(drawing(map,cx,cy),",")
    if sig=="64,65,80,81" then return "roundtree" end
    if sig=="42,43,58,59" then return "rock" end
    if sig=="14,14,85,85" then return "fence" end
  end
  if map.tileset and (map.tileset.id == "TILESET_JOHTO" or map.tileset.id == "TILESET_JOHTO_MODERN") then
    local ids = drawing(map,cx,cy)
    if ids[1]==88 and ids[2]==88 and ids[3]==88 and ids[4]==88 then
      return "oceanrock"
    end
    -- Coastal boulders are complete 32px drawings, not four cliff corners.
    local grid={{43,44,44,45},{59,60,60,61},{59,60,60,61},{75,76,76,77}}
    local offsets={ ["43,44,59,60"]={0,0},["44,45,60,61"]={1,0},
                    ["59,60,75,76"]={0,1},["60,61,76,77"]={1,1} }
    local offset=offsets[table.concat(ids,",")]
    if offset then
      local matches=true
      for r=1,4 do for c=1,4 do
        if map:tileAt((cx-offset[1])*2+c-1,(cy-offset[2])*2+r-1)~=grid[r][c] then matches=false end
      end end
      if matches then return "boulder" end
    end
    if perm == Permissions.WALL then
      local edge={ [43]=true,[44]=true,[45]=true,[59]=true,[60]=true,
                   [61]=true,[75]=true,[76]=true,[77]=true }
      local found,compatible=false,true
      for _,id in ipairs(ids) do
        found=found or edge[id]
        compatible=compatible and (edge[id] or id==5 or id==6)
      end
      if found and compatible then return "ledge" end
    end
  end

  if perm == Permissions.WATER then
    return Permissions.isWaterfall(coll) and "wall" or "water"
  end

  if perm ~= Permissions.WALL then
    -- walkable: the only shapes here are the ones that stand ON walkable
    -- ground.  Tall grass keeps its own class (flat base plus standing
    -- tufts); a ledge is the 6px lip you hop off.
    if Permissions.isGrass(coll) then return "grass" end
    -- Johto draws the lip in the blocked cell beyond the hop trigger.
    -- Raising the trigger itself adds an entire extra cell of shelf.
    if Permissions.isLedge(coll) then
      return map.tileset and (map.tileset.id=="TILESET_JOHTO" or map.tileset.id=="TILESET_JOHTO_MODERN") and "ground" or "ledge"
    end
    return "ground"
  end

  -- solid.  Trees are named twice over: by collision when they are a CUT
  -- or HEADBUTT tree, and by palette otherwise -- and both agree, which is
  -- what makes the palette rule trustworthy for the plain ones.
  if Permissions.isCutTree(coll) or Permissions.isHeadbuttTree(coll) then
    return "bush"
  end
  if Permissions.isCounter(coll) then return "counter" end
  if map.def and map.def.environment == "CAVE" then
    local isolated = true
    for _, d in ipairs({ {0,-1}, {0,1}, {-1,0}, {1,0} }) do
      local okN, nc = pcall(map.cellCollision, map, cx+d[1], cy+d[2])
      if not okN or Permissions.of(tonumber(nc) or -1) == Permissions.WALL then
        isolated = false
        break
      end
    end
    if isolated then return "rock" end
  end

  -- A roof is NOT its own class here, and that is the opposite of the
  -- first cut. `roof` has art "top" and a fixed 28px height, which made
  -- every Johto house a green slab lying on a 16px box -- the "long, not
  -- tall" the bug report named.
  --
  -- A building's roof rows are the TOP of its drawing, and the volume
  -- builder already knows what to do with them: it splits a structure's
  -- drawn height into a vertical facade and a slope rising north to the
  -- drawn peak (Structures.buildVolume, `run.rise`). For that to happen
  -- the roof and the wall have to be ONE region, so both answer `wall`
  -- and the palette's testimony is handed over separately, through
  -- roofRowsFor below. What the slot buys is certainty about WHERE the
  -- roof starts: Gen 1 infers it from the art, which on Johto's repeating
  -- brick infers nothing.
  if palTop == PAL_ROOF or palBot == PAL_ROOF then return "wall" end
  if palTop == PAL_GREEN then
    local vocab = vocabulary(map.tileset, Permissions)
    if not vocab then return "tree" end -- limited metadata fallback
    local ids = drawing(map, cx, cy)
    if vocab.crowns[ids[1] .. ":" .. ids[2]]
        or vocab.roots[ids[3] .. ":" .. ids[4]] then return "tree" end
    -- Johto's grass-topped retaining edge uses these source tiles. The hop
    -- collision is on the plain ground BEFORE this blocked lip, so collision
    -- alone cannot find the visible six-pixel ledge (Route 29).
    if (map.tileset.id == "TILESET_JOHTO" or map.tileset.id == "TILESET_JOHTO_MODERN") then
      local edge = { [59]=true, [60]=true, [61]=true, [75]=true, [76]=true, [77]=true }
      local found, compatible = false, true
      for _, id in ipairs(ids) do
        found = found or edge[id]
        compatible = compatible and (edge[id] or id == 5 or id == 6)
      end
      if found and compatible then return "ledge" end
    end
    return "wall" -- grass-topped rock is not foliage or a timber fence
  end
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
  shapes.gen2Classes = classTable(shapes, outdoor(map))
  -- CPU-only support survives a warm terrain cache. It comes from the same
  -- complete recipes as the meshes, without building meshes in an actor draw.
  local ok,recipes=pcall(V.data,"gen2_furniture")
  local list=ok and recipes and recipes[map.tileset.id]
  if list then
    local supports={}
    local tw,th=map.def.width*4,map.def.height*4
    for _,t in ipairs(list) do
      local bh,bw=#t.tiles,#t.tiles[1]
      local x0,z0,x1,z1=math.huge,math.huge,-math.huge,-math.huge
      for _,p in ipairs(t.parts) do
        x0,x1=math.min(x0,p.x[1]),math.max(x1,p.x[2]+1)
        z0,z1=math.min(z0,p.z or 0),math.max(z1,(p.z or 0)+(p.depth or 0))
      end
      for ty=0,th-bh do for tx=0,tw-bw do
        if map:tileAt(tx,ty)==t.tiles[1][1] then
          local match=true
          for r=1,bh do for c=1,bw do
            if map:tileAt(tx+c-1,ty+r-1)~=t.tiles[r][c] then match=false end
          end end
          if match then
            for cy=math.floor(ty/2),math.floor((ty+bh-1)/2) do
              for cx=math.floor(tx/2),math.floor((tx+bw-1)/2) do
                local x,z=cx*16+8-tx*8,cy*16+8-ty*8
                supports[cy*4096+cx]=(x>=x0 and x<x1 and z>=z0 and z<z1)
                  and (t.support or 0) or 0
              end
            end
          end
        end
      end end
    end
    shapes.gen2FurnitureSupports=supports
  end
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
