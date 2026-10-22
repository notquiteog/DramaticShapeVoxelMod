local active,on,stageActive=true,true,true
local st={};local actors={[0]={mon={}},[1]={mon={}},[2]={mon={}},[3]={mon={}}}
local busy=false;local observed;local M;local fail=false;local originalCalls=0
local B={_st=st,isActive=function()return active end}
local Ball={active=function()return busy end,start=function(id,x,y,item)originalCalls=originalCalls+1;busy=true;assert(x==17 and y==29 and item==4);return 7,nil,'native'end,
 startParticles=function()busy=true end,spawnSprite=function()busy=true end,reset=function()busy=false end,tick=function()return 'tick',nil end,
 draw=function()observed=M.owner(st);if fail then error('native draw error')end;return'native',nil,9 end}
package.loaded['src.core.game3.battle.ball_open']=Ball
package.loaded['src.core.game3.battle']=B
package.loaded['src.core.game3.battle.anim_coords']={fixedId=function(id)return type(id)=='number'and id or id=='player'and 0 or nil end,battler=function(_,id)return actors[id]end}
local modules={Gen3Battle={active=true,enabled=function()return on end},PokeballSettings={active=function()return on end}}
M=assert(loadfile('lib/NativeGen3ReleaseParticles.lua'))({require=function(name)return modules[name]end})
local frame={native={[3]={x=140,foot=83}},points={[3]={8,2,14}}}
local point,x,y=M.point(frame,{releaseOwner=3,ax=145,ay=50})
assert(point==frame.points[3]and x==5 and y==-33,'native particle anchor was distorted')
assert(not M.point(frame,{releaseOwner=3,ax=145,ay=50},true),'provider ownership ignored')
assert(not M.point(frame,{releaseOwner=2,ax=145,ay=50}),'missing native anchor guessed')
local original=Ball.draw;local undo=M.install()
local function begin(id)Ball.reset();return Ball.start(id or 0,17,29,4)end
local function draw(expected)local a,b,c=Ball.draw();assert(a=='native'and b==nil and c==9);assert(observed==expected);assert(M.owner(st)==nil,'owner escaped original draw')end
local a,b,c=begin('player');assert(a==7 and b==nil and c=='native');draw(0)
Ball.start(1,17,29,4);draw(nil);busy=false;Ball.tick();begin(3);draw(3)
Ball.startParticles();draw(nil);begin();Ball.spawnSprite();draw(nil)
begin();on=false;draw(nil);Ball.tick();on=true;draw(nil)
begin();local prior=actors[0];actors[0]={mon=prior.mon};draw(nil);actors[0]=prior
begin();local mon=actors[0].mon;actors[0].mon={};draw(nil);actors[0].mon=mon
begin();B._st={};draw(nil);B._st=st
begin();fail=true;assert(not pcall(Ball.draw));assert(M.owner(st)==nil);fail=false;draw(0)
begin();Ball.reset();draw(nil)
-- An already-active unobserved epoch cannot acquire ownership mid-animation.
busy=true;Ball.start(2,17,29,4);draw(nil)
-- Engines with a public exact-owner draw seam can resolve overlapping releases.
local current
Ball.currentParticleOwner=function()return current end
local function owned(id)return{state=st,id=id,actor=actors[id],mon=actors[id].mon}end
begin(0);Ball.start(1,17,29,4)
for id=0,3 do current=owned(id);draw(id)end
current=nil;draw(nil) -- Anonymous effects are never assigned to the last actor.
begin(0);current=owned(1);current.state={};draw(nil)
current=owned(1);current.actor={mon=actors[1].mon};draw(nil)
current=owned(1);current.mon={};draw(nil)
current=owned(1);current.id=4;draw(nil)
current=owned(1);on=false;draw(nil);on=true
current=nil;draw(0) -- Exclusive legacy epoch still works with anonymous output.
Ball.currentParticleOwner=function()error('unavailable')end;draw(nil)
Ball.currentParticleOwner=nil;draw(0)
undo();assert(Ball.draw==original and M.owner(st)==nil);assert(originalCalls>8)
print('PASS exclusive public release epoch, overlap/anonymous/stale/OFF/error/native-return fallbacks')
