local active=true;local events={};local starts=0
local scene={}
for _,k in ipairs({'finishNormalBattleBall','normalBallAnimEvent','normalBallTimedEvent','normalBallCaughtEvent','prepareNativeCapture','drawNativeCapture','castNativeCapture'})do
 scene[k]=function(...)events[#events+1]={k,...};return true end
end
scene.startNormalBall=function(...)starts=starts+1;events[#events+1]={'start',...};return true end
local Seq={};function Seq.reset()return 'reset'end
function Seq.begin(...)Seq.reset();return 'begin'end
local sounds=0;local Audio={playSe=function()sounds=sounds+1;return 'sound'end}
local SE={SE_BALL_THROW=1,SE_BALL_OPEN=2,SE_BALL=3,SE_BALL_CLICK=4}
package.loaded['src.core.game3.battle.catch_seq']=Seq;package.loaded['src.core.game3.audio']=Audio;package.loaded['src.core.game3.se_ids']=SE
local V={require=function(k)return ({BattleScene=scene,PokeballSettings={enabled={key='legendaryPokeballs'},size={key='pokeballSize'},captureSpeed={key='pokeballCaptureSpeed'},openTime={key='pokeballOpenTime'},preset={key='pokeballCapturePreset'},streamers={key='pokeballStreamers'},audio={key='emberLegacyAudio'},audioVolume={key='emberLegacyVolume'},active=function()return active end},Gen3Battle={enabled=function()return true end}})[k]end}
local M=assert(loadfile('lib/Gen3Capture.lua'))(V);local undo=M.install();assert(M.settings()[1].key=='legendaryPokeballs'and M.settings()[2].key=='pokeballSize'and M.settings()[3].key=='pokeballCaptureSpeed'and M.settings()[4].key=='pokeballOpenTime');assert(M.settings()[5].key=='pokeballCapturePreset'and M.settings()[6].key=='pokeballStreamers');local st={wild=true}
assert(Seq.begin(st,4,false,0,{})=='begin');assert(not M.active(st))
assert(Audio.playSe(1)=='sound'and starts==1 and M.active(st))
Audio.playSe(2);assert(events[#events][2]=='POOF_ANIM')
Audio.playSe(2);assert(events[#events][2]=='SHOWPIC_ANIM')
M.prepare({st=st,points={[0]={16,8,32},[1]={64,8,80}}},8)
assert(events[#events][1]=='prepareNativeCapture'and events[#events][4]==8)
M.draw(st);assert(events[#events][1]=='drawNativeCapture')
M.draw(st,{});assert(events[#events][1]=='castNativeCapture')
assert(Seq.reset()=='reset'and not M.active(st))
Seq.begin(st,1,true,3,{});Audio.playSe(1);Audio.playSe(2);Audio.playSe(3);assert(events[#events][1]=='normalBallTimedEvent');Audio.playSe(4);assert(events[#events][1]=='normalBallCaughtEvent')
active=false;Audio.playSe(3);assert(not M.active(st));local before=starts
Seq.begin(st,4,true,3,{});Audio.playSe(1);assert(starts==before)
active=true
for _,case in ipairs({{wild=false},{wild=true,double=true},{wild=true,double=true,safari=true}})do Seq.begin(case,4,true,3,{});Audio.playSe(1);assert(starts==before)end
Seq.begin(st,6,true,3,{});Audio.playSe(1);assert(starts==before,'unmodeled ball lost native art')
for _,case in ipairs({{wild=true,safari=true},{wild=true,oldManTutorial=true},{wild=true,pokedude=true},{wild=true,kinds={tutorial='wally'}}})do
 local item=case.safari and 5 or 4
 local count=starts;Seq.begin(case,item,true,3,{});assert(starts==count,'started before native throw cue')
 Audio.playSe(1);assert(starts==count+1 and M.active(case),'native Safari/tutorial throw not consumed')
 assert(events[#events][2]==(case.safari and 'SAFARI_BALL'or'POKE_BALL'))
 M.prepare({st=case,byId={[4]={}},points={[0]={16,8,32},[4]={8,8,24},[1]={64,8,80}}},8)
 local arena=events[#events][2];assert(arena.player[1]==8 and arena.player[2]==24,'visible trainer throw origin ignored')
 assert(events[#events][3]==case,'native state identity changed')
 Seq.reset();assert(not M.active(case))
end
for _,opts in ipairs({{headless=true},{ghostDodge=true},{target=3}})do
 local count=starts;Seq.begin(st,4,false,0,opts);Audio.playSe(1);assert(starts==count,'unsupported native sequence intercepted')
end
-- A failed prop cannot suppress the native capture or optional sound fallback.
local start=scene.startNormalBall;scene.startNormalBall=function()return false end
Seq.begin(st,5,true,3,{});local count=sounds;Audio.playSe(1);assert(not M.active(st)and sounds==count+1)
scene.startNormalBall=start
assert(sounds>0);undo();print('PASS Gen3 native capture events, native returns/audio, zero-shake breakout, successful click, floor, Safari/tutorial trainer origins, OFF/specialty/ghost/doubles fallback')
-- Only successfully played optional replacement sounds may suppress native SE.
local requireBefore=V.require;local available,played=true,true;local captured,volume={}
V.require=function(k)
 if k=='EmberLegacyAudio'then return {
  nativeMaster=function(_,read)volume=read()end,
  ready=function()return available end,
  capture=function(event,index)captured[#captured+1]={event,index};return played end,
 }end
 return requireBefore(k)
end
Audio._sfxVolume=.25;local restore=M.install()
Seq.begin(st,4,true,3,{});local prior=sounds
Audio.playSe(1);assert(sounds==prior and captured[#captured][1]=='throw'and volume==.25)
Audio.playSe(2);Audio.playSe(3);Audio.playSe(4)
assert(sounds==prior and captured[#captured][1]=='success')
available=false;Audio.playSe(3);assert(sounds==prior+1,'missing audio muted native sound')
available=true;played=false;Audio.playSe(3);assert(sounds==prior+2,'failed replacement muted native sound')
restore();print('PASS optional native capture audio ownership, master volume, absent/failed asset fallback')
-- Native-only props still share audio without claiming geometry ownership.
local sessions,cleared=0,0;local broken=false
V.require=function(k)
 if k=='EmberLegacyAudio'then return {
  nativeMaster=function(_,read)volume=read()end,sync=function()return active end,
  ready=function()return available end,beginCapture=function()sessions=sessions+1 end,
  capture=function(event,index)if broken then error('audio')end;captured[#captured+1]={event,index};return played end,
  clear=function()cleared=cleared+1 end,
 }end
 return requireBefore(k)
end
restore=M.install();active=true;available=true;played=true
for item=6,12 do
 local count=starts;local native=sounds;local n=#events;local captures=#captured
 Seq.begin(st,item,false,2,{});Audio.playSe(1);Audio.playSe(2);Audio.playSe(3);Audio.playSe(3);Audio.playSe(2)
 assert(starts==count and #events==n and not M.active(st),'native specialty geometry was claimed')
 assert(sounds==native and #captured==captures+5 and captured[#captured][1]=='breakout','native specialty audio route')
 assert(captured[#captured-1][2]==2,'shake index')
 Seq.reset()
end
assert(sessions==7 and cleared==7,'native-only audio lifecycle')
local prior=sounds;Seq.begin(st,4,false,0,{ghostDodge=true});Audio.playSe(1)
assert(sounds==prior and not M.active(st)and captured[#captured][1]=='throw','ghost throw audio/native pose')
played=false;Audio.playSe(2);assert(sounds==prior+1)
available=false;Audio.playSe(3);assert(sounds==prior+2)
available=true;played=true;broken=true;Audio.playSe(3);assert(sounds==prior+3)
broken=false;Audio.playSe(999,{pan=.2});assert(sounds==prior+4,'unrelated sound')
active=false;Audio.playSe(1);assert(sounds==prior+5 and not M.status().pending,'OFF cleanup')
active=true
for _,case in ipairs({{wild=true,double=true},{wild=false}})do
 Seq.begin(case,6,false,0,{});prior=sounds;Audio.playSe(1);assert(sounds==prior+1)
end
restore();assert(cleared==8,'ghost audio cleaned')
print('PASS seven native specialty balls and ghost-dodge audio, clocks/props untouched, exact failed/missing/error/OFF/unknown/doubles fallback and disposal')

-- Independent companion catch views may select either last surviving foe.
local live={wild=true,double=true,battlers={}}
local foes={[1]={hp=10},[3]={hp=0}}
package.loaded['src.core.game3.battle']={getState=function()return live end}
package.loaded['src.core.game3.battle.state']={battler=function(_,id)return foes[id]end,isAlive=function(_,id)return foes[id].hp>0 end}
V.require=requireBefore;restore=M.install()
for _,id in ipairs({1,3})do
 foes[id].hp=10;foes[id==1 and 3 or 1].hp=0
 local view={wild=true,double=true,battlers=live.battlers,enemy=foes[id]}
 local intake={active=true,color={1,0,0}};view.dramaticShape3DBallIntake=intake
 local count=starts
 assert(Seq.begin(view,4,false,0,{target=id})=='begin');Audio.playSe(1)
 assert(starts==count+1 and M.active(live)and M.active(view)and M.target(live)==id)
 assert(M.intake(live)==intake and live.dramaticShape3DBallIntake==nil)
 local points={[0]={16,8,32},[1]={64,8,80},[3]={96,8,80}}
 M.prepare({st=live,points=points},8)
 local e=events[#events];assert(e[1]=='prepareNativeCapture'and e[3]==view and e[2].enemy[1]==points[id][1])
 M.draw(live);assert(events[#events][3]==view,'live owner replaced detached native catch view')
 M.prepare({st={},points=points},8);assert(not M.active(live)and not M.intake(live),'departed live owner retained capture')
 Seq.reset();assert(not M.active(live)and not M.intake(live))
 for _,bad in ipairs({
  {view={wild=true,double=true,battlers={},enemy=foes[id]},target=id},
  {view=view,target=0},{view=view,target=id==1 and 3 or 1},
 })do
  count=starts;Seq.begin(bad.view,4,false,0,{target=bad.target});Audio.playSe(1)
  assert(starts==count and not M.active(live),'ambiguous view or target was intercepted')
 end
 foes[id==1 and 3 or 1].hp=10;count=starts
 Seq.begin(view,4,false,0,{target=id});Audio.playSe(1);assert(starts==count,'two living foes accepted')
end
restore()
print('PASS native last-foe capture views, both target IDs, public live identity, exact arena/intake owner, ambiguous/two-foe fallback and reset')
