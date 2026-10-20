local checks=0;local function check(v,msg)checks=checks+1;assert(v,msg)end
local native,events,begins,clears=0,{},0,0
local enabled,hasStage,available,plays,raises,owned=true,true,true,true,false,false
local master;local lastWild=false
local S={animForId=function()return false end,update=function()return nil,'tick'end,finishBattle=function()return 'finish'end}
S.startBallAnim=function(self,param,item)
 self.anim={hooks={sound=function(name,x)native=native+1;return nil,name,x end}}
 return true,nil,item
end
package.loaded['src.ui.gen2.BattleState']=S
local A={nativeMaster=function(_,fn)master=fn end,sync=function()return available end,
 ready=function()return available end,beginCapture=function()begins=begins+1 end,
 capture=function(e,i)if raises then error('audio failure')end;events[#events+1]={e,i};return plays end,
 clear=function()clears=clears+1 end}
local V={require=function(n)return({Gen2Battle={enabled=function()return enabled end},
 PokeballSettings={active=function()return enabled end},OverworldBattle={shot=function()return hasStage and{canvas={}}end},
 EmberLegacyAudio=A,Gen2Capture={active=function()return owned end,targetReady=function()return lastWild end}})[n]end}
local M=assert(loadfile('lib/Gen2BallAudio.lua'))(V);check(M.install(),'installed')
local s=setmetatable({battle={wild=true},game={options={sfxVol=4}},phase='menu'},{__index=S})
local function start(item,param)
 local a,b,c=s:startBallAnim(param or 1,item);check(a==true and b==nil and c==item,'native returns retained')
 return s.anim.hooks.sound
end
local sound=start('LOVE_BALL');sound('Sfx_ThrowBall');sound('Sfx_BallPoof');sound('Sfx_BallBounce');sound('Sfx_BallWobble');sound('Sfx_BallWobble');sound('Sfx_BallPoof')
check(native==0 and begins==1 and #events==6,'specialty native cues replaced once')
check(events[1][1]=='throw'and events[2][1]=='open'and events[3][1]=='land'and events[4][2]==1 and events[5][2]==2 and events[6][1]=='breakout','native event order/indices')
check(master()==4/7,'native master');s.game.options.sfxVol=0;check(master()==0,'live native mute')
local function fallback(f,name)
 local before=native;local a,b,c=f(name or'Sfx_ThrowBall','extra')
 check(native==before+1 and a==nil and b==(name or'Sfx_ThrowBall')and c=='extra','native fallback/tuple')
end
fallback(sound,'Sfx_CaughtMon');fallback(sound,'Sfx_Cry')
owned=true;fallback(sound);owned=false
enabled=false;fallback(sound);enabled=true
hasStage=false;fallback(sound);hasStage=true
available=false;fallback(sound);available=true
plays=false;fallback(sound);plays=true
raises=true;fallback(sound);raises=false
local old=sound;sound=start('PARK_BALL');fallback(old)
s.contest=true;sound('Sfx_ThrowBall');check(events[#events][1]=='throw'and begins==2,'contest uses native throw audio')
s.contest=nil;s.battle.wild=false;sound=start('POKE_BALL',0);sound('Sfx_ThrowBall');fallback(sound,'Sfx_Peck')
check(begins==3 and events[#events][1]=='throw','trainer-blocked throw retains native impact')
s.battle.doubles=true;fallback(sound);s.battle.wild=true;lastWild=true
sound=start('LOVE_BALL');local oldCount=#events;sound('Sfx_ThrowBall');check(#events==oldCount+1,'last-wild specialty cue')
owned=true;fallback(sound);owned=false;lastWild=false;s.battle.doubles=nil
local a,b=s:update();check(a==nil and b=='tick','update returns')
s.phase='done';s:update();check(clears==1,'native-only voices clean up')
check(s:finishBattle()=='finish','finish return')
s.phase='menu';sound=start('LOVE_BALL');sound('Sfx_ThrowBall')
local originalBattle=s.battle;s.battle={wild=true};fallback(sound)
local oldClears=clears;s:update();check(clears==oldClears+1,'replaced capture battle clears voices')
s.battle=originalBattle;sound=start('LOVE_BALL');s.phase='done';fallback(sound)
s.phase='fadeout';fallback(sound);s.phase='evolving';fallback(sound)
-- Exercise production install order with the real outer capture adapter.
local modules={Gen2Battle={enabled=function()return enabled end,stagedMon=function()return true end},
 PokeballSettings={active=function()return enabled end},OverworldBattle={shot=function()return{canvas={}}end},EmberLegacyAudio=A,
 BattleScene={startNormalBall=function()A.beginCapture();return true end,finishNormalBattleBall=function()end,normalBallAnimEvent=function()end}}
V.require=function(n)return modules[n]end
package.loaded['src.ui.gen2.BattleAnimView']={present=function()end,drawObjects=function()end}
S.pokeballWobble=function()return 0 end
S.activeMon=function()return{}end
local capture=assert(loadfile('lib/Gen2Capture.lua'))(V);modules.Gen2Capture=capture
check(capture.install(),'outer capture installed')
s.phase='menu';s.battle.wild=true;s.ballThrow={caught=false}
check(s:startBallAnim(1,'POKE_BALL')==true and capture.active(s,s.anim),'3D owns supported runner')
local count=#events;local before=native;s.anim.hooks.sound('Sfx_ThrowBall')
check(#events==count+1 and native==before,'one successful outer playback')
plays=false;count=#events;s.anim.hooks.sound('Sfx_ThrowBall')
check(#events==count+1 and native==before+1,'failed outer playback falls back without inner retry')
plays=true;capture.finish();check(not capture.active(s,s.anim),'ownership clears')
print('PASS '..checks..' native-only Gen2 capture audio checks')
