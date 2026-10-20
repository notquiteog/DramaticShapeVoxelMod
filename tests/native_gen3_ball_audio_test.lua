local nativeCalls,events,serial=0,{},0
local nativeResult={};local Audio={_sfxVolume=.4,playSe=function(id,opts)nativeCalls=nativeCalls+1;return nativeResult,opts end}
local scene={ball={visible=true,frame=1,side='player'}}
local Anim={stage=function()return scene end}
local st={battlers={[0]={shiny=true},[1]={},[2]={}}};local active=true;local Battle={_st=st,isActive=function()return active end}
local capture=false;local Catch={busy=function()return capture end}
local Coords={idOf=function(key)return ({player=0,enemy=1})[key]end,battler=function(s,id)return s.battlers[id]end}
local Switch={_st=st,_steps={{kind='withdraw',data={id=2}}},_i=1}
Switch.update=function()Audio.playSe(1);return nil,'native',false end
local Intro={}
local SE={SE_BALL_OPEN=1};local enabled,staged,assets,plays=true,true,true,true
local master;local clears=0;local syncs=0;local raises=false;local groups={}
local V={require=function(name)return ({Gen3Battle={active=staged,enabled=function()return enabled end},
 PokeballSettings={active=function()return enabled end},BattleArt={isShiny=function(b)return b.shiny end},
 EmberLegacyAudio={nativeMaster=function(s,f)assert(s==st);master=f end,sync=function(s)syncs=syncs+1;return assets end,clear=function()clears=clears+1 end,
 play=function(...)if raises then error('decoder failed')end;events[#events+1]={...};return plays end,
 playSendoutGroup=function(index,variants)groups[#groups+1]={index,variants};return plays end}})[name]end}
for name,value in pairs({audio=Audio,se_ids=SE,['battle.anim']=Anim,['battle.anim_coords']=Coords,['battle.switch_seq']=Switch,['battle.intro_seq']=Intro,['battle.catch_seq']=Catch,battle=Battle})do package.loaded['src.core.game3.'..name]=value end
local originalSound,originalUpdate=Audio.playSe,Switch.update
local M=assert(loadfile('lib/NativeGen3BallAudio.lua'))(V);local undo=M.install()
assert(Audio.playSe(1)==true and nativeCalls==0 and events[1][1]=='sendout'and events[1][3]==true)
Intro._st=st;Intro._steps={{kind='player_throw',data={}}};Intro._i=1;scene.ball.frame=0
assert(Audio.playSe(1)==true and events[#events][1]=='sendout','initial throw-before-open cue lost')
Intro._steps=nil;scene.ball.frame=1
assert(master()==.4);Audio._sfxVolume=.15;assert(master()==.15)
local a,b,c=Switch.update();assert(a==nil and b=='native'and c==false and events[#events][1]=='recall')
local steps=Switch._steps;Switch._steps={{kind='sendout_player',data={id=2}}};st.battlers[2].shiny=true
Audio.playSe(1);assert(events[#events][1]=='sendout'and events[#events][3]==true,'second allied slot lost shiny identity')
Switch._steps=steps
-- Original audio and returns survive every unavailable/ambiguous/unrelated path.
local function native(opts)
 local n=nativeCalls;local a,b=Audio.playSe(1,opts)
 assert(a==nativeResult and b==opts and nativeCalls==n+1)
end
native({pan=.5,volume=.25})
capture=true;native();capture=false
active=false;native();active=true
staged=false;native();staged=true
enabled=false;native();enabled=true
assets=false;native();assets=true
plays=false;native();plays=true
raises=true;native();raises=false
Anim._headless=true;native();Anim._headless=false
scene.ball.visible=false;native();scene.ball.visible=true
Intro._steps={{kind='player_throw',data={ids={0,2}}}}
assert(Audio.playSe(1)==true and events[#events][3]==true,'shared shiny cue not consumed')
st.battlers[2].shiny=false;assert(Audio.playSe(1)==true and #groups==1)
assert(groups[1][2][1]==true and groups[1][2][2]==false,'mixed variants lost actor identity')
plays=false;native();plays=true
st.battlers[0].shiny=false
assert(Audio.playSe(1)==true and events[#events][3]==false,'shared normal cue not consumed')
Intro._steps[1].data.ids={0,9};native();Intro._steps[1].data.ids={};native()
st.battlers[0].shiny=true;Intro._steps=nil
scene.balls={[0]=scene.ball}
assert(Audio.playSe(1)==true,'aliased native ball appeared ambiguous');scene.balls=nil
scene.balls={[1]={visible=true,frame=1,battler=1}};assert(Audio.playSe(1)==true);scene.balls=nil
scene.ball.battler=3;st.battlers[3]={};Audio.playSe(1);assert(events[#events][3]==false)
local n=nativeCalls;Audio.playSe(7);assert(nativeCalls==n+1)
local prior=syncs;M.update();assert(syncs==prior+1,'playing sounds not synced to live master')
active=false;M.update();assert(clears==1,'battle exit retained sound owner');active=true
prior=syncs;M.update();assert(syncs==prior,'idle audio polled assets')
undo();assert(Audio.playSe==originalSound and Switch.update==originalUpdate)
-- A throwing native update must not leave the withdraw context installed.
Switch.update=function()error('native failure')end;undo=M.install()
assert(not pcall(Switch.update));Audio.playSe(1);assert(events[#events][1]=='sendout')
undo();print('PASS native sendout/recall audio, shiny/master, exact returns, capture isolation, missing/failed fallback and error restoration')
