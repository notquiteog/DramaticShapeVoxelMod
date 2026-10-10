local mode='stock';local errors=0
local modules={ModSetting={new=function()return {get=function()return mode end}end}}
local V={mod={log={error=function()errors=errors+1 end}},require=function(k)return assert(modules[k],k)end}
local C=assert(loadfile('lib/CharacterRenderers.lua'))(V);modules.CharacterRenderers=C
local S=assert(loadfile('lib/StandingTrainer.lua'))(V)
local old=0;C.register({id='gen1',drawBattleTrainer=function()old=old+1;return true end})
assert(C.has('drawBattleTrainer')and not C.has('drawBattleTrainer',3))
local battle={};mode='legendary'
assert(not S.prepare(battle,3,true));assert(not S.prepare(battle,3,false))
local draw,shadow=0,0
local handle=C.register({id='native',battleGenerations={2,3},drawBattleTrainer=function(ctx)
 assert(ctx.generation==2 or ctx.generation==3);assert(ctx.battle==battle)
 draw=draw+1;ctx.setHandWorld({1,2,3});return true
end,drawBattleTrainerShadow=function()shadow=shadow+1;return true end})
assert(S.prepare(battle,3,false));assert(S.draw(battle,3,{},false));assert(S.draw(battle,3,{},true))
assert(draw==1 and shadow==1 and old==0 and C.battleHandWorld()[2]==2)
-- Native intro retains the native trainer; provider appears only after handoff.
assert(not S.prepare(battle,3,true));assert(not S.draw(battle,3,{},false))
assert(S.prepare(battle,3,false));mode='stock';assert(not S.prepare(battle,3,false))
assert(not C.battleHandWorld());mode='legendary';assert(not S.prepare(battle,3,false))
assert(not S.prepare(battle,2,true));assert(S.prepare(battle,2,false))
assert(S.draw(battle,2,{},false));assert(not S.prepare(battle,2,false,true))
-- No latch may leak into the next battle or survive teardown.
assert(not S.prepare({},3,false));S.prepare(battle,3,true);S.clear()
assert(not S.prepare(battle,3,false));S.prepare(battle,3,true);handle:release()
assert(not S.prepare(battle,3,false))
C.register({id='broken',battleGenerations={3},drawBattleTrainer=function()error('provider failure')end})
assert(S.prepare(battle,3,false));assert(not S.draw(battle,3,{},false));assert(errors==1)
C.setBattle(true,battle);assert(C.first('drawBattleTrainer',{}));assert(old==1)
print('PASS native standing trainer handoff, native intro, scoped provider generations, OFF, release, special battle and error fallback')
