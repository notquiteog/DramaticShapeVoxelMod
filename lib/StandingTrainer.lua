-- Shared option and native trainer handoff. Native intro sprites keep ownership;
-- compatible optional providers may keep the selected trainer on the field
-- after that intro. No simulation fields or source pictures are mutated.
local V=...
local M={setting=V.require('ModSetting').new('standingTrainer','STANDING TRAINER',
 {'stock','legendary'},{'STOCK','LEGENDARY'},1)}
local latched=setmetatable({},{__mode='k'})
function M.prepare(battle,generation,intro,special)
 local bridge=V.require('CharacterRenderers')
 if not battle or special or M.setting:get()~='legendary' then
  if battle then latched[battle]=nil end
  bridge.setBattle(false);return false
 end
 if intro then latched[battle]=true end
 local active=latched[battle]and not intro and bridge.has('drawBattleTrainer',generation)or false
 bridge.setBattle(active,battle,generation)
 return active
end
function M.draw(battle,generation,context,shadow)
 local bridge=V.require('CharacterRenderers')
 if not bridge.battleActive()or bridge.battleState()~=battle then return false end
 context.generation=generation;context.battle=battle
 context.setHandWorld=function(value)bridge.setBattleHand(value)end
 return bridge.first(shadow and 'drawBattleTrainerShadow'or 'drawBattleTrainer',context)
end
function M.clear()
 latched=setmetatable({},{__mode='k'});V.require('CharacterRenderers').setBattle(false)
end
return M
