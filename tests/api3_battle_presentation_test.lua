local warnings=0
package.loaded['src.mods.Runtime']={wantsHook=function()return false end}
local V={mod={id='BATTLE_ART_VOXEL_FORK',log={warn=function()warnings=warnings+1 end}},require=function(n)
 if n=='UiBackplates'then return{uiHidden=function()return false end}end
 error(n)
end}
local M=assert(loadfile('lib/BattlePresentation.lua'))(V)
local calls={}
local old=M.registerSuppression('owner',function(r)calls[#calls+1]='old';return r.surface=='hud'end)
assert(M.suppressed('hud',{})and not M.suppressed('text',{}))
local fresh=M.registerSuppression('owner',function(r)calls[#calls+1]='new';return r.surface=='text'end)
old();assert(M.suppressed('text',{})and not M.suppressed('hud',{}),'stale unsubscribe removed new owner')
local bad=M.registerSuppression('bad',function()error('provider failure')end,10)
assert(M.suppressed('text',{})and warnings==1,'failed optional provider blocked next owner')
assert(M.suppressed('text',{})and warnings==1,'failed provider retried every draw')
fresh();bad();assert(not M.suppressed('text',{})and not M.suppressed('unknown',{}))
M.dispose();assert(not M.registerSuppression('late',function()return true end),'unloaded provider retained callbacks')
print('PASS API3 optional suppression ownership, replacement, failure isolation and unload without custom engine hooks')
