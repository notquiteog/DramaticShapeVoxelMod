-- Read native encounter identity without changing the core battle or screen.
local V = ...
local M = {}

function M.core(battle)
  if not V.require('Generation').isGen2() or type(battle) ~= 'table' then return nil end
  return type(battle.battle) == 'table' and battle.battle or battle
end

function M.trainer(battle)
  local core = M.core(battle)
  if not core or core.wild or core.link or battle.link then return nil end
  local trainer = core.trainer
  local class = trainer and (trainer.classId or trainer.class)
  if type(class) ~= 'string' then return nil end
  -- Gen2 uses LT_SURGE (not a numeric object-event class or display name).
  return 'OPP_' .. class
end

function M.fishing(battle)
  local core = M.core(battle)
  if not core or not core.wild then return false end
  local Battle = require('src.battle.gen2.Battle')
  return core.battleType == Battle.BATTLETYPE_FISH
end

function M.species(battle)
  local core = M.core(battle)
  if not core or not core.wild or core.link or battle.link then return nil end
  local mon = core.enemy
  local species = mon and mon.species
  if type(species) == 'number' then species = V.data('battle_species_dex_386')[species] end
  return type(species) == 'string' and species:upper() or nil
end

return M
