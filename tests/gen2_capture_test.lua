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
local previous=V.require;local available=true;local played=true;local master
V.require=function(k)
 if k=='EmberLegacyAudio'then return {
  nativeMaster=function(_,f)master=f end,
  ready=function()return available end,
  capture=function(event)events[#events+1]='ember:'..event;return played end,
 }end
 return previous(k)
end
scene.startNormalBall=event('start');s.game={options={sfxVol=2}}
s:startBallAnim(0,'POKE_BALL');assert(master()==2/7)
s.anim.hooks.sound('SFX_THROW_BALL');assert(events[#events]=='ember:throw')
s.anim.hooks.sound('SFX_BALL_POOF');assert(events[#events]=='ember:open')
s.anim.hooks.sound('Sfx_BallWobble');assert(events[#events]=='ember:shake')
s.anim.hooks.sound('Sfx_BallBounce');assert(events[#events]=='ember:land')
available=false;s.anim.hooks.sound('SFX_BALL_POOF');assert(events[#events]=='nativeSound')
available=true;played=false;s.anim.hooks.sound('SFX_BALL_POOF');assert(events[#events]=='nativeSound')
s.game.options.sfxVol=0;assert(master()==0)
print('PASS Crystal optional audio master and native fallback on missing/failed playback')
-- Tutorial capture owns no player Pokemon or inventory. Its original script
-- supplies the same caught/wobble events; contest's separate Park Ball stays native.
M.finish();s.tutorial=true;s.battle.player=nil;s.ballThrow.caught=true
local prior=#events;s:startBallAnim(0,'POKE_BALL');assert(events[prior+1]=='start')
s.result=1;s:pokeballWobble();assert(events[#events]=='caught')
M.finish();s.contest=true;prior=#events;s:startBallAnim(0,'PARK_BALL')
View:drawObjects(s.anim);assert(#events==prior+1 and events[#events]=='nativeObjects')
print('PASS native tutorial events with empty player party and native contest fallback')

M.finish();s.contest=nil;s.tutorial=nil
local lead,partner={hp=15},{hp=0};s.battle={wild=true,doubles={},enemy=lead,enemy2=partner}
s.activeMon=function(_,side)return side=='enemy'and lead or partner end
assert(M.targetReady(s));s:startBallAnim(0,'POKE_BALL');assert(M.active(s,s.anim))
s.anim=nil;s:update();assert(events[#events-1]=='finish','departed runner retained capture')
M.finish();partner.hp=10;assert(not M.targetReady(s));s:startBallAnim(0,'POKE_BALL');assert(not M.active(s,s.anim))
partner.hp=0;s.battle.enemy={hp=15};assert(not M.targetReady(s),'core identity replaced queued shown target')
s.battle.enemy=lead;s.activeMon=function()error('unavailable native slot')end;assert(not M.targetReady(s))
s.activeMon=function(_,side)return side=='enemy'and lead or partner end;s.battle.wild=false;assert(not M.targetReady(s))
s.battle.wild=true;lead.hp=0;assert(not M.targetReady(s))
lead.hp=15;enabled=false;s:startBallAnim(0,'POKE_BALL');assert(not M.active(s,s.anim));enabled=true
print('PASS native promoted last-wild target, two-foe/queued identity/reader failure/dead/OFF safeguards')
