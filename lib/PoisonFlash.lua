-- The original overworld poison step briefly pulses a translucent black
-- rectangle over the whole 160x144 frame.  That reads as a disruptive
-- full-screen blink once the world is rendered as a bright 3D scene.
--
-- Keep ApplyOutOfBattlePoisonDamage itself intact: it owns the four-step
-- counter, HP loss, sound, faint messages, Pikachu happiness and blackout.
-- The visual is conveniently represented by one field assigned at the end
-- of that routine, so clearing only that field after the original returns
-- removes the pulse without changing any poison gameplay.

-- Gen 1 only, because on a Gen 2 boot this patch would be taken and never
-- called.  src.world.OverworldController resolves to Gen2Compat's facade
-- there, and a facade over a live World dispatches back through exactly three
-- members -- `update`, `interact`, `talkTo` (src/mods/Gen2Compat.lua:1383).
-- `applyFieldPoison` is BACKED, so calling it forwards to Gold's world, but
-- assigning to it writes a function nothing reads: Gold's own step calls
-- World:applyFieldPoison directly.  The assignment would read back as ours and
-- the pulse would keep playing, which is the silent half-install this gate
-- exists to prevent.  Gold's field poison stays entirely the engine's.

local V = ...
local Generation = V.require("Generation")

local PoisonFlash = {}

function PoisonFlash.suppress(state)
  state.poisonFlash = nil
end

-- True when this build deliberately left the wrapper out.
PoisonFlash.skipped = nil

function PoisonFlash.install()
  if not Generation.isGen1() then
    PoisonFlash.skipped =
      "gen2 dispatches applyFieldPoison itself; a facade patch is never called"
    return
  end
  local OverworldState = require("src.world.OverworldController")
  if OverworldState.dramaticShapePoisonFlashHook then return end

  local inner = OverworldState.applyFieldPoison
  function OverworldState:applyFieldPoison(...)
    local stop = inner(self, ...)
    PoisonFlash.suppress(self)
    return stop
  end

  OverworldState.dramaticShapePoisonFlashHook = true
end

return PoisonFlash
