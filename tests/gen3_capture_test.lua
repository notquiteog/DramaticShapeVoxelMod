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
local V={require=function(k)return ({BattleScene=scene,PokeballSettings={enabled={key='legendaryPokeballs'},size={key='pokeballSize'},captureSpeed={key='pokeballCaptureSpeed'},openTime={key='pokeballOpenTime'},preset={key='pokeballCapturePreset'},streamers={key='pokeballStreamers'},active=function()return active end},Gen3Battle={enabled=function()return true end}})[k]end}
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
for _,case in ipairs({{wild=false},{wild=true,double=true},{wild=true,safari=true},{wild=true,pokedude=true}})do Seq.begin(case,4,true,3,{});Audio.playSe(1);assert(starts==before)end
Seq.begin(st,6,true,3,{});Audio.playSe(1);assert(starts==before,'unmodeled ball lost native art')
assert(sounds>0);undo();print('PASS Gen3 native capture events, native returns/audio, zero-shake breakout, successful click, floor, OFF/specialty/tutorial/doubles fallback')
