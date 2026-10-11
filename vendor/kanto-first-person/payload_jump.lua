-- The JUMP: what a ledge hop feels like from inside the head.
-- payload-version: 5
--
-- The engine already hops the player over a ledge, and Dramatic Shape's
-- first-person rig already carries the eye along that arc -- but the arc
-- was authored for a 16px sprite seen from outside, so from within the
-- head it reads as a polite shrug rather than a jump.
--
-- This adds three things to the eye, and nothing to the game:
--
--   BOOST    the existing hop arc, multiplied.  A vault instead of a
--            step, without touching where the player actually lands.
--   CROUCH   a dip just before the rise: the body loading the jump.
--   LAND     a damped settle on touchdown, two small bounces, so the
--            ground arrives with weight instead of stopping dead.
--
-- And the walk itself:
--
--   BOB      the eye rises and falls twice per step, driven by distance
--            travelled rather than by a clock, so it stops dead when you
--            do and never drifts out of phase with your feet
--   DOORSTEP a warp used to be an instant cut: one frame in the street,
--            the next inside a shop.  The engine still teleports -- that
--            is not ours to touch -- but the EYE now steps through: it
--            dips and pushes forward along the facing, then settles.  A
--            quarter of a second of movement is the difference between
--            arriving somewhere and being edited into it.
--
--   SWAY     a smaller lateral roll of the head, once per step and at
--            right angles to the way you are facing, which is what stops
--            a bob reading as a pogo stick
--
-- All of it is eye offset -- a number added to the camera's height.
-- Collision, ledge rules, where the hop ends and which cells are jumpable
-- are the engine's business and are not touched.  Nothing here can move
-- the player one pixel, which is exactly the point: a purely cosmetic
-- jump cannot desync a script, a save or a link battle.

local V = ...

-- FirstPerson is fetched LAZILY, never at load: the rig requires this
-- module from its own first lines, so requiring it back here would be a
-- circular load.  By the time a frame is drawn the rig exists and is
-- cached, and until then sway is simply zero.
local FP = nil
local function rig()
  if FP then return FP end
  local ok, mod = pcall(V.require, "FirstPerson")
  if ok and type(mod) == "table" then FP = mod end
  return FP
end

local Jump = {}

-- how much of the engine's own arc to add on top of it, per setting
local BOOST = { OFF = 0, SUBTLE = 0.6, BIG = 1.6 }

-- bob amplitudes in world pixels, per setting
local BOB = { OFF = 0, SUBTLE = 0.55, BIG = 1.25 }
local BOB_PER_PX = math.pi / 8   -- two bobs per 16px cell walked
local SWAY_RATIO = 0.6           -- lateral sway relative to vertical bob
local BOB_EASE = 6               -- how fast the bob settles when you stop

local CROUCH_DEPTH = 1.6      -- pixels dipped while loading
local CROUCH_TIME = 0.10      -- seconds of load before the rise
local LAND_DEPTH = 2.4        -- pixels dipped on touchdown
local LAND_TIME = 0.26        -- seconds to settle
local LAND_BOUNCES = 2

local prevLift, landAt, riseAt = 0, nil, nil
local walked, prevX, prevZ, moving = 0, nil, nil, 0
local stepAt = nil          -- when the last doorway step began
local STEP_TIME = 0.30      -- how long the step through a door takes
local STEP_DIP = 2.2        -- how far the eye dips crossing the threshold
local STEP_PUSH = 5.0       -- and how far forward it leans

local function now()
  local ok, t = pcall(function() return love.timer.getTime() end)
  return ok and t or 0
end

local function config()
  local pub = rawget(_G, "__ds_ceiling_config")
  if type(pub) == "function" then
    local ok, cfg = pcall(pub)
    if ok and type(cfg) == "table" then return cfg end
  end
  return {}
end

-- Distance walked, accumulated from the entity's own position.  Driving
-- the bob from DISTANCE rather than from time is what keeps it locked to
-- the feet: stand still and it stops mid-stride instead of bobbing on the
-- spot, and it cannot drift out of phase however the framerate wobbles.
local function advance(me)
  local x, z = (me and me.px) or 0, (me and me.py) or 0
  local step = 0
  if prevX then
    local dx, dz = x - prevX, z - prevZ
    step = math.sqrt(dx * dx + dz * dz)
    -- A warp jumps the player across the map.  That is not a stride --
    -- and it IS a doorway, which is the one moment worth animating.
    if step > 24 then
      step = 0
      local cfg = config()
      if cfg.doorstep ~= false then stepAt = now() end
    end
  end
  prevX, prevZ = x, z
  walked = walked + step
  -- how "in motion" we are, eased so the bob fades out rather than cuts
  local target = step > 0.05 and 1 or 0
  local t = now()
  local dt = 1 / 60
  moving = moving + (target - moving) * math.min(1, dt * BOB_EASE)
  return step
end

-- The eye offset for this frame, in world pixels.  Called from the rig's
-- head expression (lib/FirstPerson.lua) once per eye, so it must be cheap
-- and must never throw: a bad frame here would take the camera with it.
local bobT, bobEnv, bobPhase = nil, 0, 0
local BOB_AMP, BOB_HZ = 1.5, 2.1

function Jump.eyeOffset(me)
  local ok, offset = pcall(function()
    local cfg = config()
    -- JUMP FEEL scales the hop-derived motion only; the walk bob is a
    -- STANDALONE option now and runs even with the jump row OFF, so
    -- mult=0 no longer returns early -- it just zeroes the hop terms
    local mult = BOOST[cfg.jump or "SUBTLE"]
    if not mult or mult <= 0 then mult = 0 end

    local lift = (me and me.lift) or 0
    local t = now()
    advance(me)

    -- edges of the hop
    if lift > 0 and prevLift <= 0 then riseAt = t end
    if lift <= 0 and prevLift > 0 then landAt = t end
    prevLift = lift

    local off = lift * mult

    -- the load: a dip in the moments before the arc starts lifting.
    -- The engine gives no warning of a hop, so this reads the first
    -- frames of the arc itself and dips against them -- brief, and it
    -- resolves into the rise rather than fighting it.
    if riseAt and lift > 0 and mult > 0 then
      local age = t - riseAt
      if age < CROUCH_TIME then
        local k = 1 - age / CROUCH_TIME
        off = off - CROUCH_DEPTH * k * k
      end
    end

    -- THE WALK BOB: opt-in, OFF by default. Its removal was the single
    -- most complained-about thing this mod ever undid -- and its
    -- presence was the most complained-about thing it ever did. Both
    -- crowds were right about themselves, so it is a HEAD BOB toggle
    -- now: off, the camera responds only to events (hop, landing,
    -- doorway), which reads as weight; on, a gentle sine rides each
    -- step, eased in and out so starting and stopping never snap.
    if cfg.headbob == true then
      -- FIXED in 1.56.0: this block read `me.moving`, a field the
      -- rig's entity never carries in this engine -- always nil, so
      -- the toggle did nothing. The module has better sources of both
      -- facts, maintained by advance() right above: `moving` is the
      -- distance-driven ease (0..1, fading in over a stride and out
      -- over a quarter second), and `walked` is the odometer. Phase
      -- from DISTANCE, amplitude from the ease: locked to the feet,
      -- immune to framerate, stops mid-stride when you do -- which
      -- was this file's stated design all along.
      local env = (lift > 0) and 0 or (moving or 0)
      if env > 0.01 then
        off = off - math.sin(walked * 0.22) * BOB_AMP * env
      end
      _G.__ds_jump_note = ("bob:on env:%.2f walk:%.0f mult:%.1f")
                          :format(env, walked or 0, mult or -1)
    end
    if cfg.headbob ~= true then
      _G.__ds_jump_note = "bob:row-off"
    end

    -- the doorway step: a dip that eases back out, on its own clock
    if stepAt then
      local age = t - stepAt
      if age < STEP_TIME then
        local k = 1 - age / STEP_TIME
        off = off - STEP_DIP * k * math.sin(k * math.pi)
      else
        stepAt = nil
      end
    end

    -- the landing: a damped settle, decaying over LAND_TIME
    if landAt then
      local age = t - landAt
      if age < LAND_TIME then
        local k = 1 - age / LAND_TIME
        local osc = math.cos(age / LAND_TIME * math.pi * 2 * LAND_BOUNCES)
        off = off - LAND_DEPTH * k * k * osc * mult
      else
        landAt = nil
      end
    end

    return off
  end)
  return (ok and type(offset) == "number" and offset) or 0
end

-- Lateral sway, split into world X and Z so the rig can add it to the
-- head's position.  The sway is perpendicular to the way the camera is
-- looking and runs at HALF the bob's rate -- one lean per stride, not two
-- -- which is what reads as walking rather than as bouncing.
local function swayAmount()
  -- the walking sway went with the bob; the doorway push is all that
  -- moves the head laterally now
  return 0
end

local function swayAxis()
  local fp = rig()
  local yaw = (fp and fp.yaw) or 0
  -- right-hand perpendicular to the look direction
  return math.cos(yaw), -math.sin(yaw)
end

-- the doorway push, along the FACING rather than across it: the eye
-- leans through the threshold and eases back
local function stepPush()
  if not stepAt then return 0, 0 end
  local age = now() - stepAt
  if age >= STEP_TIME then return 0, 0 end
  local k = 1 - age / STEP_TIME
  local amount = STEP_PUSH * math.sin(k * math.pi)
  local fp = rig()
  local yaw = (fp and fp.yaw) or 0
  return math.sin(yaw) * amount, math.cos(yaw) * amount
end

function Jump.swayX(me)
  local ok, v = pcall(function()
    local ax = select(1, swayAxis())
    local sx = select(1, stepPush())
    return swayAmount() * ax + sx
  end)
  return (ok and type(v) == "number" and v) or 0
end

function Jump.swayZ(me)
  local ok, v = pcall(function()
    local az = select(2, swayAxis())
    local sz = select(2, stepPush())
    return swayAmount() * az + sz
  end)
  return (ok and type(v) == "number" and v) or 0
end

-- live registration: the installer hot-swaps refreshed modules
-- into the running session through this table, killing the
-- boot-twice ritual (see main.lua, hotSwap)
_G.__ds_live = rawget(_G, "__ds_live") or {}
_G.__ds_live.Jump = Jump
_G.__ds_live.V = _G.__ds_live.V or V

return Jump
