local enabled,staged=true,true
local events={};local function event(k)return function(...)events[#events+1]=k;return true end end
local scene={startNormalBall=event('start'),finishNormalBattleBall=event('finish'),normalBallAnimEvent=function(k)events[#events+1]=k end,normalBallTimedEvent=event('shake'),normalBallCaughtEvent=event('caught')}
local S={startBallAnim=function(self)self.anim={hooks={sound=event('nativeSound')}};return true end,pokeballWobble=function(self)self.calls=(self.calls or 0)+1;return self.result end,update=event('update')}
local View={present=event('nativeDraw'),drawObjects=event('nativeObjects')}
package.loaded['src.ui.gen2.BattleState']=S;package.loaded['src.ui.gen2.BattleAnimView']=View
local V={require=function(n)return ({BattleScene=scene,PokeballSettings={active=function()return enabled end},Gen2Battle={enabled=function()return true end,stagedMon=function()return staged end}})[n]end}
local M=assert(loadfile('lib/Gen2Capture.lua'))(V);assert(M.install())
local s=setmetatable({battle={wild=true},ballThrow={caught=true},activeMon=function()return {}end},{__index=S})
assert(s:startBallAnim(0,'POKE_BALL'));assert(events[1]=='start')
s.anim.hooks.sound('Sfx_BallPoof');assert(events[2]=='POOF_ANIM'and events[3]=='nativeSound')
s.result=0;assert(s:pokeballWobble()==0 and s.calls==1);assert(events[#events]=='shake')
s.result=1;assert(s:pokeballWobble()==1 and s.calls==2);assert(events[#events]=='caught')
local before=#events;View:drawObjects(s.anim);assert(#events==before)
local bg=0;View:present(s.anim,function()bg=bg+1 end);assert(bg==1)
enabled=false;View:present(s.anim,function()bg=bg+1 end);assert(bg==1 and events[#events]=='nativeDraw')
View:drawObjects(s.anim);assert(events[#events]=='nativeObjects')
s:update();assert(events[#events-1]=='finish');enabled=true
s.ballThrow.caught=false;s:startBallAnim(0,'GREAT_BALL');s.result=2;s:pokeballWobble();assert(events[#events]=='SHOWPIC_ANIM')
M.finish();staged=false;s:startBallAnim(0,'POKE_BALL');View:present(s.anim,function()error('not staged')end);assert(events[#events]=='nativeDraw')
staged=true;local prior=#events;s:startBallAnim(0,'LOVE_BALL');View:drawObjects(s.anim);assert(events[#events]=='nativeObjects'and #events==prior+1)
scene.startNormalBall=function()error('GPU unavailable')end
assert(s:startBallAnim(0,'POKE_BALL'))
View:drawObjects(s.anim);assert(events[#events]=='nativeObjects')
print('PASS Gen2 capture event order, one native RNG call, caught/escape, OFF and unavailable-stage fallback')
