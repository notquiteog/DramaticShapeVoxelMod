-- Native Ditto Transform ownership for Battle Art.
--
-- The engine swaps battler.sprite but intentionally leaves mon.species as
-- DITTO. A renderer which selects art every frame therefore needs the copied
-- species recorded at the same instant as that swap. With animations enabled
-- this is SE_TRANSFORM_MON; with animations disabled no animation event runs,
-- so the move-effect record is the fallback seam.

local V = ...

local BattleArt = V.require("BattleArt")
local AnimatedBattleArt = V.require("AnimatedBattleArt")
local Compat = {}

local function mark(user, target)
  local species = target and target.mon and target.mon.species
  if not (user and species) then return false end
  BattleArt.markTransformed(user, species)
  AnimatedBattleArt.abandonForTransform(user)
  return true
end
Compat.mark = mark

local function animationsOff(battle)
  return type(battle) == "table"
     and type(battle.animationsOn) == "function"
     and not battle:animationsOn()
end

function Compat.install()
  local okBS, BattleState = pcall(require, "src.battle.BattleState")
  if not (okBS and BattleState) then return false end

  -- BattleState dispatches deep-copied effect records, so wrapping the module's
  -- original TRANSFORM_EFFECT alone cannot cover normal battles.
  if not V.require("Generation").isGen2() and type(BattleState.effectRecord) == "function"
      and not BattleState.__battleArtTransformRecordHook then
    BattleState.__battleArtTransformRecordHook = true
    local innerEffectRecord = BattleState.effectRecord
    function BattleState:effectRecord(effect)
      local record = innerEffectRecord(self, effect)
      if effect == "TRANSFORM_EFFECT" and record
          and type(record.run) == "function"
          and not record.__battleArtTransformRun then
        record.__battleArtTransformRun = true
        local innerRun = record.run
        record.run = function(ctx)
          local out = innerRun(ctx)
          if ctx and animationsOff(ctx.battle) then
            mark(ctx.user, ctx.target)
          end
          return out
        end
      end
      return record
    end
  end

  -- With animations enabled, defer ownership until the transform square hits;
  -- marking at move-effect time would reveal the copied species too early.
  if type(BattleState.applyAnimEffect) == "function"
      and not BattleState.__battleArtTransformAnimHook then
    BattleState.__battleArtTransformAnimHook = true
    local innerApplyAnimEffect = BattleState.applyAnimEffect
    function BattleState:applyAnimEffect(ev)
      local out = innerApplyAnimEffect(self, ev)
      if ev and ev.effect == "SE_TRANSFORM_MON"
          and type(self.animFxBattler) == "function" then
        mark(self:animFxBattler(false), self:animFxBattler(true))
      end
      return out
    end
  end

  return true
end

return Compat
