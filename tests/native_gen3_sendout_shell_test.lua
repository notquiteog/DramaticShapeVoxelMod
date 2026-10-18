local n=0;local function check(v,msg)n=n+1;assert(v,msg)end
local active,enabled,catching,scale=true,true,false,1
local ball={visible=true,x=72,y=104,ballId=0,frame=0,rot=.3};local stage={ball=ball}
package.loaded['src.core.game3.battle.anim']={stage=function()return stage end}
package.loaded['src.core.game3.battle.catch_seq']={busy=function()return catching end}
local draws,casts=0,0;local failure=false
local V={require=function(name)return({PokeballSettings={active=function()return active end,scale=function()return scale end},
 Gen3Battle={enabled=function()return enabled end},Pokeball={R=2.2,new=function(kind)return{ball=kind,
 drawShell=function()draws=draws+1;if failure then error('draw')end;return true end,
 cast=function(_,shadow)casts=casts+1;check(shadow=='sun','shadow provider')end}end}})[name]end}
local M=assert(loadfile('lib/NativeGen3SendoutShell.lua'))(V)
-- A native 240x160 canvas billboard whose ball centre maps to (10,20,30).
local c={ball=true,ax=72,ay=104,radius=1.5,model={60,0,0,22,0,40,0,6,0,0,1,30,0,0,0,1}}
local st={};local shell=M.shell(st,c)
check(shell and shell.ball=='POKE_BALL','supported shell')
check(shell.pos[1]==10 and math.abs(shell.pos[2]-20.7)<1e-9 and shell.pos[3]==30,'native projected centre and grounded radius')
check(shell.rollAngle==-.3 and shell.lid==0,'native flight rotation')
for id,name in pairs({[0]='POKE_BALL','GREAT_BALL','SAFARI_BALL','ULTRA_BALL','MASTER_BALL'})do
 ball.ballId=id;ball.frame=2;shell=M.shell(st,c);check(shell.ball==name and shell.lid==1,'native type/open frame')
end
scale=2;shell=M.shell(st,c);check(shell.scale==2 and math.abs(shell.pos[2]-22.9)<1e-9,'live size keeps native bottom')
check(M.draw(st,c)and draws==1,'lit replacement');check(M.draw(st,c,'sun')and casts==1,'same shell shadow')
failure=true;check(not M.draw(st,c),'failed draw returns native');failure=false
for _,field in ipairs({'darken','flash','blend'})do ball[field]=1;check(not M.shell(st,c),'native effect fallback');ball[field]=nil end
ball.alpha=.5;check(not M.shell(st,c),'alpha fallback');ball.alpha=nil
ball.ballId=5;check(not M.shell(st,c),'specialty art native');ball.ballId=0
catching=true;check(not M.shell(st,c),'capture isolation');catching=false
st.double=true;check(not M.shell(st,c),'double native');st.double=nil
active=false;check(not M.shell(st,c),'OFF');active=true
enabled=false;check(not M.shell(st,c),'native stage off');enabled=true
stage.balls={ball};check(not M.shell(st,c),'ambiguous coincident ball');stage.balls=nil
ball.x=73;check(not M.shell(st,c),'unrelated card');ball.x=72
ball.visible=false;check(not M.shell(st,c),'hidden native ball');ball.visible=true
local prior=M.shell(st,c);M.clear();check(M.shell(st,c)~=prior,'clear releases instance references')
check(ball.frame==2 and ball.rot==.3 and c.ax==72 and c.radius==1.5,'native state untouched')
print('PASS '..n..' native sendout shell contracts')
