local native,events,clears,syncs=0,{},0,0
local enabled,canvas,assets,plays,raises=true,true,true,true,false
local master;local mon={shiny=true};local s={battle={},game={options={sfxVol=4}},phase='menu'}
local S={activeMon=function()return mon end}
S.animForId=function(self,id,side,param)
 self.anim={hooks={sound=function(name,extra)native=native+1;return nil,name,extra end}}
 return true,nil,'original'
end
S.update=function()return nil,'updated'end
S.finishBattle=function(self)self.phase='fadeout';return 'finished'end
setmetatable(s,{__index=S});package.loaded['src.ui.gen2.BattleState']=S
local stage={enabled=function()return enabled end}
local A={nativeMaster=function(b,f)assert(b==s.battle);master=f end,sync=function()syncs=syncs+1;return assets end,
 play=function(...)if raises then error('missing decoder')end;events[#events+1]={...};return plays end,clear=function()clears=clears+1 end}
local V={require=function(name)return({Gen2Battle=stage,PokeballSettings={active=function()return enabled end},
 OverworldBattle={shot=function()return canvas and{canvas={}}end},EmberLegacyAudio=A,BattleArt={isShiny=function(m)return m.shiny end}})[name]end}
local M=assert(loadfile('lib/Gen2BallAudio.lua'))(V);assert(M.install()and M.install())
local function start(id,param)
 local a,b,c=s:animForId(id or'ANIM_SEND_OUT_MON','player',param)
 assert(a==true and b==nil and c=='original');return s.anim.hooks.sound
end
local sound=start();sound('Sfx_BallPoof');assert(native==0 and #events==1 and events[1][1]=='sendout'and events[1][3])
assert(master()==4/7);s.game.options.sfxVol=2;assert(master()==2/7)
local function fallback(f,name)
 local n=native;local a,b,c=(f or sound)(name or'Sfx_BallPoof','extra')
 assert(native==n+1 and a==nil and b==(name or'Sfx_BallPoof')and c=='extra')
end
fallback(nil,'Sfx_Cry')
enabled=false;fallback();enabled=true
stage.sceneOverrideEnabled=false;fallback();stage.sceneOverrideEnabled=nil
canvas=false;fallback();canvas=true
assets=false;fallback();assets=true
plays=false;fallback();plays=true
raises=true;fallback();raises=false
fallback(start(nil,1));fallback(start(nil,2));fallback(start('ANIM_THROW_POKE_BALL'))
sound=start();local previous=sound;start();fallback(previous)
sound=start();mon={shiny=false};fallback();sound=start();sound('SFX_BALL_POOF');assert(events[#events][3]==false)
local before=syncs;local a,b=s:update();assert(a==nil and b=='updated'and syncs==before+1)
canvas=false;s:update();assert(clears==1);canvas=true
before=syncs;s:update();assert(syncs==before,'idle audio polled assets')
sound('Sfx_BallPoof');assert(s:finishBattle()=='finished'and clears==2)
M.finish();assert(clears==2)
print('PASS Gen2 normal sendout audio, shiny-arm/capture isolation, live master, exact returns, failure/OFF/stale fallback and lifecycle')
