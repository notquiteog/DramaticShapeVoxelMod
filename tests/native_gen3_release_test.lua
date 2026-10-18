local enabled,catching,failure=true,false,false
local ball={battler=0,frame=1};local stage={balls={[0]=ball}}
local present={visible=true,scale=.58};local native={x=72,y=80,foot=112}
local card={id=0,tex={},model={}};local sourceCard={ball=true}
local st={};local frame={st=st,cards={sourceCard},byId={[0]=card},native={[0]=native},points={[0]={10,3,20}},PIXEL=.25}
package.loaded['src.core.game3.battle.anim']={stage=function()return stage end,present=function(id)assert(id==0);return present end}
package.loaded['src.core.game3.battle.catch_seq']={busy=function()return catching end}
local released,uploads,draws=0,0,{}
local shell={yaw=.2,mouth=function()return 10,5,20 end}
local R={newMesh=function()if failure then error('GPU limit')end;return{release=function()released=released+1 end,setVertices=function()uploads=uploads+1 end}end}
local modules={Voxel3D=R,Gen3Battle={enabled=function()return enabled end},PokeballSettings={active=function()return enabled end},
 NativeGen3SendoutShell={shell=function()return shell,ball end},
 ['q57/Release']={DURATION=1.35,pose=function(t,source,mouth,w,h,yaw,purpose)
  assert(math.abs(t-.675)<1e-9 and source[1]==10 and source[2]==11 and source[3]==20 and mouth[2]==5 and purpose=='battle')
  return{timer=t,source=source,mouth=mouth,pull=.5,fade=1}
 end},['q57/Plasma']={newGeometry=function()return{},{}end,update=function()end},
 ['q57/Material']={draw=function(r,mesh,texture,model,pull,pose,subject)
  assert(r==R and pull==0);draws[#draws+1]={texture,model,subject};return not failure
 end}}
local V={require=function(k)return assert(modules[k],k)end}
local M=assert(loadfile('lib/NativeGen3Release.lua'))(V)
M.prepare(frame);assert(frame.releasePose and frame.releasePose.native==ball)
assert(M.draw(frame));assert(M.subject(frame,card,{}));assert(draws[2][1]==card.tex and draws[2][2]==card.model and draws[2][3],'native transform/texture replaced')
assert(not M.subject(frame,{id=1},{}));M.prepare(frame);assert(M.draw(frame)and uploads==1,'mesh was not reused')
local before=present.scale;failure=true;assert(not M.draw(frame)and not M.subject(frame,card,{}));failure=false
assert(present.scale==before and native.foot==112 and ball.frame==1,'native reveal changed')
local function absent()M.prepare(frame);assert(not frame.releasePose and not M.draw(frame)and not M.subject(frame,card,{}))end
present.scale=1;absent();assert(released==1);present.scale=.58
present.visible=false;absent();present.visible=true
ball.frame=0;absent();ball.frame=1
stage.balls={};absent();stage.balls={[0]=ball}
frame.byId={};absent();frame.byId={[0]=card}
frame.cards={sourceCard,sourceCard};absent();frame.cards={sourceCard}
catching=true;absent();catching=false
st.double=true;absent();st.double=nil
st.legendaryModelRelease={};absent();st.legendaryModelRelease=nil
enabled=false;absent();enabled=true
M.prepare(frame);failure=true;assert(not M.draw(frame),'GPU allocation failure should retain native');failure=false
M.clear();assert(released==1,'failed allocation invented mesh')
M.prepare(frame);M.draw(frame);M.clear();assert(released==2)
print('PASS native release event/actor ownership, native scale clock, exact subject card, reusable GPU volume, failure/OFF/capture/provider/doubles and cleanup')
