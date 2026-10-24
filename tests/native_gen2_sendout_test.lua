local mon,enemy={},{};local enabled,capturing=true,false
local core={wild=true,player=mon,enemy=enemy};local s={battle=core,phase='anim',anim={animId='ANIM_SEND_OUT_MON'},activeMon=function(_,side)return core[side]end}
local stage={enabled=function()return enabled end}
local V={require=function(k)return({Gen2Staged={screenFor=function(g)return g.screen end},Gen2Battle=stage,
 Gen2Capture={active=function(screen,anim)assert(screen==s and anim==s.anim);return capturing end}})[k]end}
local M=assert(loadfile('lib/NativeGen2Sendout.lua'))(V);local game={screen=s}
assert(M.screen(game,s)==s and M.screen(game,core)==s and not M.screen(game,{}))
s.afterSendOut={side='player',mon=mon,shiny=true};local cue=s.afterSendOut
assert(M.cue(s,'player',mon)==cue and not M.cue(s,'enemy',enemy))
s.anim={animId='ANIM_SEND_OUT_MON'};cue.shiny=nil;assert(M.cue(s,'player',mon)==cue,'event identity changed');s.anim.param=1;assert(not M.cue(s,'player',mon),'shiny arm invented another cue');s.anim.param=0
s.afterSendOut={side='player',mon=mon};assert(M.cue(s,'player',mon)~=cue,'same battler resend reused token')
assert(not M.cue(s,'player',{}) and not M.cue(s,'other',mon))
s.afterSendOut={side='enemy',mon=enemy};assert(not M.cue(s,'enemy',enemy),'wild enemy ball invented')
core.wild=false;assert(M.cue(s,'enemy',enemy)==s.afterSendOut)
core.enemy={};assert(not M.cue(s,'enemy',enemy));core.enemy=enemy
s.anim=nil;assert(not M.cue(s,'enemy',enemy));s.anim={animId='ANIM_SEND_OUT_MON'}
s.afterSendOut=nil;assert(not M.cue(s,'enemy',enemy))
for _,phase in ipairs({'done','fadeout','evolving'})do s.phase=phase;assert(not M.screen(game,s))end
s.phase='anim';core.doubles=true;assert(not M.screen(game,s))
local provider=false;local oldRequire=V.require
V.require=function(k)if k=='StadiumModels'then return{active=function()return provider end}end;return oldRequire(k)end
s.nativeAnimationSlot=function()return s.afterSendOut and s.afterSendOut.side end
s.afterSendOut={side='enemy2',mon=enemy};core.enemy2=enemy
assert(M.screen(game,s)==s and M.cue(s,'enemy2',enemy)==s.afterSendOut,'partner release not recognized')
provider=true;assert(not M.screen(game,s));provider=false
s.legendaryModelRelease={};assert(not M.screen(game,s));s.legendaryModelRelease=nil
s.animPicState=function()return{size=5}end
assert(M.progress(s,'enemy2')==3/7,'partner uses wrong native size denominator')
s.animPicState=function()return{size=2}end
assert(M.progress(s,'player2')==1/3)
core.wild=true;assert(not M.cue(s,'enemy2',enemy),'wild partner ball invented');core.wild=false
core.doubles=false
capturing=true;assert(not M.screen(game,s));capturing=false
stage.sceneOverrideEnabled=false;assert(not M.screen(game,s));stage.sceneOverrideEnabled=nil
enabled=false;assert(not M.screen(game,s));enabled=true
game.screen=nil;assert(not M.screen(game,s))
print('PASS native GSC sendout identity, shiny dedupe, wild/trainer sides, capture, stage and lifecycle guards')
local native=0;local View={drawObjects=function(_,runner,battle,extra)native=native+1;return nil,extra end}
package.loaded['src.ui.gen2.BattleAnimView']=View
local requireOld=V.require;V.mod={game=game,world={}}
V.require=function(k)if k=='PokeballSettings'then return{active=function()return enabled end}end;return requireOld(k)end
M.install();local wrapped=View.drawObjects;M.install();assert(View.drawObjects==wrapped)
game.screen=s;s.afterSendOut={side='player',mon=mon};s.anim={animId='ANIM_SEND_OUT_MON',param=0}
local e={nativeCue=s.afterSendOut,battler=mon,q57Used=true};s.legendaryQ57={player={entry=e}}
View:drawObjects(s.anim,core);assert(native==0,'native normal particles doubled over shared release')
local function original()local before=native;local a,b=View:drawObjects(s.anim,core,'ok');assert(native==before+1 and a==nil and b=='ok')end
s.anim.param=1;original();s.anim.param=0
e.q57Used=false;original();e.q57Used=true
enabled=false;original();enabled=true
capturing=true;original();capturing=false
e.nativeCue={};original();e.nativeCue=s.afterSendOut
s.phase='done';original();s.phase='anim'
s.anim.animId='ANIM_RETURN_MON';original()
print('PASS successful shared release owns only normal objects; native shiny, failed geometry, OFF, capture and stale fallbacks retain returns')
