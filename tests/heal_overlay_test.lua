-- The Pokemon Center heal overlay, placed against the machine it belongs to.
--
-- The engine draws the monitor tile and the party's Poke Balls
-- (PokeCenterOAMData) as ordinary 2D sprites at fixed screen offsets from
-- the cell the player healed on, and ctx.drawFx slides that whole block
-- rigidly onto ONE projected point -- the player's own feet
-- (OverworldController's `at(fxHeal, healAnim.px + 8, healAnim.py + 16)`).
-- The art it paints belongs about 60 world pixels north of there, on a
-- machine 17 voxels tall, so under a perspective camera the block floats off
-- the cabinet: measured against the machine's real surfaces it rides ~9px
-- high at the 35 degree rung and ~14px at 50, and the monitor and the balls
-- drift by different amounts, so no single offset can seat them both.
--
-- HealOverlay answers with world points instead of a screen slide: every
-- piece is placed on the SURFACE the drawing extrudes it onto, so the same
-- projection that draws the rest of the scene puts it there too.
--
-- These checks are pinned to data/voxel_heights.lua's own machine template
-- rather than to copied numbers -- if the cabinet's depth, its height or the
-- console's inset move, the overlay has to move with them.
--
--   luajit mods/BattleArtVoxelFork/tests/heal_overlay_test.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local MOD_PATH = os.getenv("DS_MOD_PATH") or "mods/BattleArtVoxelFork"
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

local HealOverlay = V.require("HealOverlay")

-- ------- the machine, as the mod actually voxelizes it

local function template(id)
  for _, t in ipairs(V.data("voxel_heights").buildings.POKECENTER) do
    if t.id == id then return t end
  end
end

local machine = template("center_heal_machine_w")
T.check(machine ~= nil,
  "the POKECENTER catalogue still carries center_heal_machine_w")

-- Buildings.deskSetModel's own arithmetic, restated: the cabinet's height is
-- its drawn base band plus its fascia, its box runs `depthPx` back from `z`,
-- and the console stands on the lid, `depth` deep from its own `z`.
local plane = (machine.desk.base[2] - machine.desk.base[1] + 1)
            + (machine.desk.fascia[2] - machine.desk.fascia[1] + 1)
local frontZ = machine.desk.z + machine.desk.depthPx      -- cabinet front plane
local console
for _, p in ipairs(machine.parts) do
  if p.kind == "upright" and p.inset then console = p end
end
local consoleZ = console.z + console.depth                -- console front plane
local groundRow = machine.desk.base[2]                    -- drawn row of the floor

T.eq(plane, 17, "the heal machine cabinet is 17 voxels tall")
T.eq(frontZ, 26, "its front face is the z=26 plane of the plot")
T.eq(consoleZ, 24, "the console's face stands 2px behind the cabinet's")

-- ------- the plot, found from the cell the player healed on

local ha = { px = 48, py = 48, balls = 3, lit = 3, visible = true }
local px0, py0 = HealOverlay.plot(ha)
T.eq(px0, 16, "the west machine's plot begins at world x 16")
T.eq(py0, 0, "...and at world y 0, the back row of the Center")

-- The plot origin is not a guess: the engine paints the monitor tile at flat
-- world (px - 20, py - 44), and the template puts that tile's lit rectangle
-- exactly on the console inset the drawing cuts at grid x 13..18.
T.eq(px0 + console.inset.x[1], ha.px - 20 + 1,
  "the monitor tile's lit rectangle starts on the console inset's first column")
T.eq(px0 + console.inset.x[2], ha.px - 20 + 6,
  "...and ends on its last")

-- ------- where each piece goes

local pieces = HealOverlay.points(ha)
local monitor, balls = nil, {}
for _, p in ipairs(pieces) do
  if p.kind == "monitor" then monitor = p else balls[#balls + 1] = p end
end

T.check(monitor ~= nil, "the overlay places the monitor")
T.eq(#balls, 3, "one ball per healed party member, and no more")

-- the monitor rides the console's face, centred on the inset the drawing cuts
if monitor then
  T.eq(monitor.z, py0 + consoleZ, "the monitor sits on the console's front face")
  T.eq(monitor.x, px0 + (console.inset.x[1] + console.inset.x[2] + 1) / 2,
    "...centred across the inset's columns")
  -- the front elevation extrudes drawn row r to height groundRow - r, which
  -- is what puts the fascia's first row at the lid and the base's last on
  -- the floor; the inset band is that same mapping over its own rows
  local top = groundRow - console.inset.rows[1]
  local bottom = groundRow - (console.inset.rows[2] + 1)
  T.check(monitor.h > bottom and monitor.h < top,
    ("the monitor's height lands inside the inset band %d..%d (got %s)")
      :format(bottom, top, tostring(monitor.h)))
  T.check(monitor.h > plane,
    "...which is above the cabinet lid, where the console actually stands")
end

-- the balls ride the cabinet's front panel, in the two columns the fascia
-- notches, and every one of them is ON the cabinet: no floor, no ceiling
local seenX = {}
for i, b in ipairs(balls) do
  T.eq(b.z, py0 + frontZ, ("ball %d sits on the cabinet's front panel"):format(i))
  T.check(b.x > px0 + machine.desk.x[1] and b.x < px0 + machine.desk.x[2] + 1,
    ("ball %d stands within the cabinet's own columns (got %s)")
      :format(i, tostring(b.x)))
  -- the group rides above the cabinet lid on purpose (see BALL_LIFT), so the
  -- bounds that matter are the panel below and the console screen above,
  -- both checked to the pixel further down
  T.check(b.h > 0,
    ("ball %d stands above the floor (got %s)"):format(i, tostring(b.h)))
  seenX[b.x] = true
end
local columns = 0
for _ in pairs(seenX) do columns = columns + 1 end
T.eq(columns, 2, "the balls fill two mirrored columns")

-- ------- and they sit ON the panel, not over the lip below it
--
-- The ball art's ink is 6 rows of its tile, so a ball reaches 3 either side
-- of the point it is centred on.  The dark front panel's last drawn row
-- extrudes to GROUND_ROW - 28, and rows 29..30 under it are the cream lip at
-- the machine's foot.  Unlifted, the lowest ball's ink lands one pixel into
-- that lip and hangs over the cabinet.
-- the OAM's own row pitch, which the lift must carry rather than squash
local BALLS_PITCH = 5

-- A FULL party, because the bottom row is the one at risk and a three-ball
-- fixture never lights it. `balls` above is deliberately a partial party, so
-- these bounds get their own six.
local full = {}
for _, p in ipairs(HealOverlay.points({ px = 48, py = 48, balls = 6, lit = 6 })) do
  if p.kind == "ball" then full[#full + 1] = p end
end
T.eq(#full, 6, "a full party lights all six for the bounds below")

local panelFloor = machine.desk.base[2] - HealOverlay.PANEL_ROWS[2]
local lowest = math.huge
for _, b in ipairs(full) do lowest = math.min(lowest, b.h) end
T.check(lowest - 3 >= panelFloor,
  ("the lowest ball's ink stays on the panel, whose last row stands at %d "
   .. "(ink reaches %d)"):format(panelFloor, lowest - 3))

-- The group travels as one, so the pitch the OAM sets is untouched: three
-- rows, evenly spaced, however far up they sit.
local seen = {}
for _, b in ipairs(full) do seen[b.h] = true end
local rows = {}
for h in pairs(seen) do rows[#rows + 1] = h end
table.sort(rows)
T.eq(#rows, 3, "a full party stands on three rows")
T.eq(rows[2] - rows[1], BALLS_PITCH, "evenly spaced, at the pitch the OAM sets")
T.eq(rows[3] - rows[2], BALLS_PITCH,
  "...and the lift carries the group without squashing it")

-- The ceiling: the console's screen is the inset drawn rows 6..8, and the
-- balls must stop under it.  Climbing into it would cover the very surface
-- the monitor tile is drawn on.
local screenFloor = machine.desk.base[2] - (console.inset.rows[2] + 1)
local highest = -math.huge
for _, b in ipairs(full) do highest = math.max(highest, b.h) end
T.check(highest + 3 < screenFloor,
  ("the top pair stays clear of the console screen, whose bottom edge is at "
   .. "%d (ink reaches %d)"):format(screenFloor, highest + 3))

-- and the flip survives: the right column is the left one's OAM_XFLIP
local flipped = 0
for _, b in ipairs(balls) do if b.flip then flipped = flipped + 1 end end
T.eq(flipped, 1, "with three balls lit, exactly one of them is the flipped column")

-- ------- the regression this exists to hold
--
-- Unaided, ctx.drawFx treats the whole overlay as flat art lying on the
-- ground plane at its drawn row (main.lua's `Voxel3D.project(wx, 0, wy)`).
-- Both of those are wrong here by a whole machine.
if monitor then
  local flatY = ha.py - 64 + 20 + 3.5     -- the lit rectangle's centre, flat
  T.check(monitor.h > plane,
    "the monitor is lifted onto the console instead of lying on the floor")
  T.check(monitor.z - flatY > 8,
    ("the monitor is set back onto the machine's face rather than left at its "
     .. "drawn row (face %s, drawn %s)")
      :format(tostring(monitor.z), tostring(flatY)))
end

-- ------- and how big it draws, which is a separate question
--
-- The orbit frames exactly `vh` world pixels, so the flat renderer's own
-- scale is very nearly right there.  1ST and 3RD ride a placed camera whose
-- framing comes from its fov and how far the eye stands, and a world pixel
-- draws about 3.8x and 1.45x bigger than that scale respectively -- which is
-- what shrank the balls and the monitor to a quarter and two thirds size on
-- those rungs.  `place` measures the size off the projection instead, so
-- these run it against projections that stand in for each case.

local target = HealOverlay.points(ha)[2]      -- a ball on the front panel

-- a camera that magnifies the world k times, whatever the flat scale says
local function magnify(k)
  return function(x, h) return x * k, (100 - h) * k end
end

local sx, sy, s = HealOverlay.place(magnify(4), target, 1)
T.eq(sx, target.x * 4, "the piece lands where the projection puts it")
T.eq(sy, (100 - target.h) * 4, "...on both axes")
T.eq(s, 4, "a world pixel is measured off the projection, not taken from the "
        .. "flat renderer's scale (the 1ST/3RD shrink)")
T.eq(select(3, HealOverlay.place(magnify(1), target, 1)), 1,
  "and a camera that agrees with the flat scale is left alone")

-- seen along the machine, the east step collapses but the up step does not
local function edgeOn(k)
  return function(x, h, z) return z * k, (100 - h) * k end
end
T.eq(select(3, HealOverlay.place(edgeOn(5), target, 1)), 5,
  "an edge-on view sizes off the up step rather than shrinking to nothing")

-- a projection with nothing to say about the neighbours still has to draw
local function centreOnly(p)
  return function(x, h)
    if x == p.x and h == p.h then return 10, 20 end
    return nil
  end
end
local cx, cy, cs = HealOverlay.place(centreOnly(target), target, 7)
T.eq(cx, 10, "a centre-only projection still places the piece")
T.eq(cs, 7, "...and falls back to the flat scale for its size")

T.eq(HealOverlay.place(function() return nil end, target, 1), nil,
  "a piece behind the camera is not drawn at all")

-- ------- the order they are painted in, which decides the overlap
--
-- The rows overlap by a pixel or two and nothing here writes depth, so which
-- ball wins is settled purely by draw order.  points() hands them back in
-- the OAM's own order, top row first, and draw walks that list with ipairs,
-- so the bottom row is painted last and sits in front with the upper rows
-- tucked behind it.  That is the reading the art wants: further up the
-- machine is further back.
--
-- Sorting these by projected depth would invert it.  On the orbit rungs the
-- eye is above the machine, and on a vertical panel that puts the TOP row
-- nearer the camera.  So the order has to stay the drawing's rather than the
-- camera's, and this is here to say so if anyone reaches for a sort.
local painted = {}
for _, p in ipairs(HealOverlay.points({ px = 48, py = 48, balls = 6, lit = 6 })) do
  if p.kind == "ball" then painted[#painted + 1] = p.h end
end
local descending = true
for i = 2, #painted do
  if painted[i] > painted[i - 1] then descending = false end
end
T.check(descending,
  "the balls are handed back top row first, so the bottom row paints last")
T.check(painted[#painted] < painted[1],
  ("the last ball painted is the lowest on the machine (%d against %d)")
    :format(painted[#painted], painted[1]))

-- ------- and whether it is behind something, which is a fourth question
--
-- The overlay composites flat with the depth test off, so it painted over
-- the counter the player is standing at.  It now tests each fragment against
-- the frame's own depth texture -- but a piece painted ON a face ties with
-- that face's depth, so the point the depth is taken at is nudged toward the
-- eye first, the way Voxel3D.draw's `pull` moves a character card off the
-- wall it leans over.

T.check(HealOverlay.PULL > 0, "the depth sample is pulled toward the eye")
T.check(HealOverlay.PULL < machine.desk.depthPx,
  ("...by less than the cabinet is deep (%d), so the pull can never carry a "
   .. "piece in front of something that genuinely stands nearer")
    :format(machine.desk.depthPx))

local onPanel = HealOverlay.points(ha)[2]

-- an eye due south of the machine, at counter height
local eye = { onPanel.x, onPanel.h, onPanel.z + 64 }
local dx, dy, dz = HealOverlay.depthPoint(onPanel, eye)
T.eq(dx, onPanel.x, "a head-on eye pulls the sample along z alone")
T.eq(dy, onPanel.h, "...on both of the other axes")
T.eq(dz, onPanel.z + HealOverlay.PULL,
  "...and exactly PULL toward it, off the face the piece is painted on")

-- and from anywhere else it is still exactly PULL, just along the sightline
local skew = { onPanel.x + 40, onPanel.h + 30, onPanel.z + 50 }
local sx2, sy2, sz2 = HealOverlay.depthPoint(onPanel, skew)
local moved = math.sqrt((sx2 - onPanel.x) ^ 2 + (sy2 - onPanel.h) ^ 2
                        + (sz2 - onPanel.z) ^ 2)
T.check(math.abs(moved - HealOverlay.PULL) < 1e-9,
  ("an off-axis eye pulls the same distance along its own sightline (got %.6f)")
    :format(moved))

T.eq(select(3, HealOverlay.depthPoint(onPanel, nil)), onPanel.z,
  "with no camera to pull toward, the piece's own point stands")
T.eq(select(3, HealOverlay.depthPoint(onPanel,
                                      { onPanel.x, onPanel.h, onPanel.z })),
  onPanel.z, "and an eye standing in the piece cannot divide by its own zero")

-- ------- and what colour it draws in, which is a fourth question
--
-- ADVANCED (RED++) bakes the OBP into every sprite sheet as it loads, so
-- ctx.spriteColors answers nil there.  The heal sheet is not a sprite def
-- and nothing bakes it, so it reached the canvas in raw DMG greys: grey
-- Poke Balls on a fully coloured machine.  objPalette picks the pack's own
-- OBJ palette for it.

-- an ENGINE file, so relative to the repo root this runs from, not to
-- ROOT, which is where the MOD lives and is not the same place
local pack = dofile(assert(os.getenv("ASTRA_ENGINE"), "ASTRA_ENGINE required") .. "/data/palettes_gbc.lua")
local palette, group = HealOverlay.objPalette(pack and pack.world)
T.check(palette ~= nil, "the ADVANCED pack yields an object palette")
T.eq(group, pack.world.spriteAssignment[0],
  "it is the pack's own OBJ group for sprite sheet 0, not a number picked here")

-- The ball art draws its outline on shade 3, its upper body on 2 and its
-- lower body on 1.  A palette that cannot answer those with black, a red and
-- something pale does not make a Poke Ball, whatever else it is.  Declining
-- to answer is the grey the overlay had, so a nil stands in as the DMG greys
-- and fails these rather than skipping them.
local pal = palette or { { 255, 255, 255 }, { 170, 170, 170 },
                         { 85, 85, 85 }, { 0, 0, 0 } }
local band, upper, lower = pal[4], pal[3], pal[2]
T.check(band[1] == 0 and band[2] == 0 and band[3] == 0,
  "shade 3 is black, for the ball's outline and its band")
T.check(upper[1] > 200 and upper[2] < 120 and upper[3] < 120,
  ("shade 2 is a red, for the ball's upper body (got %d,%d,%d)")
    :format(upper[1], upper[2], upper[3]))
T.check(lower[1] > 200 and lower[2] > 120,
  ("shade 1 is pale, for the ball's lower body (got %d,%d,%d)")
    :format(lower[1], lower[2], lower[3]))
T.neq(upper[1] == lower[1] and upper[2] == lower[2] and upper[3] == lower[3],
  true, "and the two halves of the ball are not the same colour")

T.eq(HealOverlay.objPalette(nil), nil, "no pack yields no palette")
T.eq(HealOverlay.objPalette({ spritePalettes = {}, spriteAssignment = {} }), nil,
  "and a pack with no group 0 is declined rather than guessed at")
T.eq(HealOverlay.objPalette({ spritePalettes = { [0] = { 1, 2, 3, 4 } },
                              spriteAssignment = { [0] = "random" } }), nil,
  "a randomized assignment is not a palette index and is declined too")

-- lit balls track the party, and nothing is drawn before the first one lights
T.eq(#HealOverlay.points({ px = 48, py = 48, balls = 6, lit = 0 }), 1,
  "before any ball lights, only the monitor is drawn")
T.eq(#HealOverlay.points({ px = 48, py = 48, balls = 6, lit = 6 }), 7,
  "a full party lights all six")
T.eq(#HealOverlay.points({ px = 48, py = 48, balls = 6, lit = 99 }), 7,
  "and a bad count cannot run off the end of the machine")

if T.failures > 0 then
  error(("heal overlay placement: %d failure(s)"):format(T.failures))
end
print(("PASS heal overlay placement (%d checks)"):format(T.checks))
