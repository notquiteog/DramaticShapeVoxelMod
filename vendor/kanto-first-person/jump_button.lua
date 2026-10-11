-- JUMP BUTTON -- Ledge Leap 1.0.1, incorporated.
--
-- Written as the standalone mod "Ledge Leap"; bundled here so the first-
-- person build carries its own jump key, with the author's design kept
-- intact: press Space (keyboard) or Y (pad) in free roam -- facing a
-- ledge tile, hop the two cells over it FROM ANY SIDE, exactly the way
-- the engine's own downhill hop moves; facing anything else, a small hop
-- on the spot that moves nothing. The cosmetic arc rides the engine's
-- hopFrames/hopTotal, which this mod's first-person camera already turns
-- into vertical lift -- so the button and the JUMP FEEL option compose
-- without either knowing about the other.
--
-- Built only on the documented mod surface (input.step, queueScript with
-- stock commands, one namespaced command, mod.options). If the standalone
-- Ledge Leap is also installed, set JUMP KEY and PAD BUTTON to OFF here
-- (or remove the standalone) -- two listeners means two hops per press.

local DX = { up = 0, down = 0, left = -1, right = 1 }
local DY = { up = -1, down = 1, left = 0, right = 0 }

return function(mod)
  -- Sets the cosmetic arc on the same tick the scripted walk begins, the
  -- way the engine's own ledge handler pairs them.
  mod.commands:register("ledge_leap_arc", function(ctx)
    local p = ctx.overworld and ctx.overworld.player
    if p then p.hopFrames, p.hopTotal = 32, 32 end
  end)

  local scriptRunning = false
  mod.events:on("script.started", function() scriptRunning = true end)
  mod.events:on("script.ended", function() scriptRunning = false end)

  -- Same occupancy rule as the engine's collision pass: an entity blocks
  -- from the cell it stands on and the cell it is stepping into, and
  -- passable entities (the companion) never block.
  local function occupied(entities, cx, cy, ignore)
    for _, e in ipairs(entities or {}) do
      if e ~= ignore and not e.passable then
        if (e.cellX == cx and e.cellY == cy)
           or (e.targetX == cx and e.targetY == cy) then
          return true
        end
      end
    end
    return false
  end

  -- Is the cell one ahead a ledge tile of this map's tileset? Facing
  -- direction on the ledge row is ignored on purpose: the button hops
  -- the tile from any side, which is what makes an upward jump possible.
  local function facingLedge(game, ow, p)
    local map = ow.map
    local dir = p.facing
    local fx, fy = p.cellX + DX[dir], p.cellY + DY[dir]
    if not map:inBounds(fx, fy) then return false end
    local front = map:cellTile(fx, fy)
    local tileset = map.def.tileset
    for _, l in ipairs(game.data.field.ledges or {}) do
      if (l.tileset or "OVERWORLD") == tileset and l.ledgeTile == front then
        return true, dir, fx, fy
      end
    end
    return false
  end

  local function tryJump(game)
    local ow = game.overworld
    if not ow or game.stack:top() ~= ow then return end  -- free roam only
    local p = ow.player
    if not p or p.moving or scriptRunning then return end
    if (p.hopFrames or 0) > 0 then return end            -- one hop at a time
    if p.surfing then return end

    local isLedge, dir, fx, fy = facingLedge(game, ow, p)

    -- Facing an NPC: leave the press to the engine. Space also carries
    -- the default A binding, and a chat beats a bounce.
    if not isLedge and occupied(ow.entities, p.cellX + DX[p.facing],
                                p.cellY + DY[p.facing], p) then
      return
    end

    if isLedge then
      local lx, ly = fx + DX[dir], fy + DY[dir]
      if ow.map:inBounds(lx, ly) and ow.map:isWalkableCell(lx, ly)
         and not occupied(ow.entities, lx, ly, p) then
        mod.world:queueScript({
          { "ledge_leap_arc" },
          { "play_sound", "Ledge" },
          { "move_player", dir, 2 },
        })
        return
      end
      -- landing blocked or off-map: fall through to the bounce
    end

    -- Everything else: a quick hop on the spot. Purely cosmetic.
    p.hopFrames, p.hopTotal = 16, 16
  end

  -- Our own edge latches; input.step runs once per fixed logic step,
  -- before the engine promotes queued button edges.
  local kbHeld, padHeld = false, false

  mod.hooks:wrap("input.step", function(next, game, dt)
    local key = mod.options:get("jumpkey")
    local pad = mod.options:get("jumppad")

    local kb = false
    if key ~= "off" and love and love.keyboard then
      kb = love.keyboard.isDown(key)
    end

    local pd = false
    if pad ~= "off" and love and love.joystick then
      for _, j in ipairs(love.joystick.getJoysticks()) do
        -- Select+face is the engine's display-chord namespace; a held
        -- Select hands the press back.
        if j:isGamepad() and j:isGamepadDown(pad)
           and not j:isGamepadDown("back") then
          pd = true
          break
        end
      end
    end

    local pressed = (kb and not kbHeld) or (pd and not padHeld)
    kbHeld, padHeld = kb, pd
    if pressed then tryJump(game) end
    return next(game, dt)
  end)
end
