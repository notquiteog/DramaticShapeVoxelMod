local Mat4=dofile('lib/Mat4.lua')
local Pair=assert(loadfile('lib/NativeGen2PairCards.lua'))({require=function()return Mat4 end})
local function canvas(w,h)return{getWidth=function()return w end,getHeight=function()return h end}end
local function near(a,b)assert(math.abs(a-b)<1e-8,tostring(a)..' ~= '..tostring(b))end
local tex={canvas=canvas(200,180),actors={}}
local model=Mat4.mul(Mat4.translate(24,6,50),Mat4.mul(Mat4.rotateY(.7),Mat4.scale(-57,51,1)))
local actors={{},{}};local cue={}
for i=1,2 do
 tex.actors[i]={slot=i==1 and'player'or'player2',x=i==1 and-12 or 38,y=16,
 card={canvas=canvas(160,144),ax=80,ay=143,contentWidth=50,contentHeight=56,actorMon=actors[i],
 releaseCanvas=i==2 and canvas(160,144)or nil,releaseCue=i==2 and cue or nil}}
end
local cards=assert(Pair.split(tex,{side='player',model=model}))
assert(#cards==2 and not cards[1].releaseCanvas and cards[2].releaseCanvas)
for i,card in ipairs(cards)do
 for _,point in ipairs({{0,0},{160,144},{80,143},{80,100}})do
  local world=Pair.point(card,unpack(point));local actor=tex.actors[i]
  local old=Pair.point({tex=tex.canvas,model=model},point[1]+actor.x,point[2]+actor.y)
  for j=1,3 do near(world[j],old[j])end
 end
end
local draws={};local available=true;local enabled=true
local modules={Mat4=Mat4,NativeGen2PairCards=Pair,
 PokeballSettings={active=function()return enabled end},
 Voxel3D={newMesh=function()return{setVertices=function()end,release=function()end}end},
 ['q57/Plasma']={newGeometry=function()return{},{}end,update=function()end},
 ['q57/Material']={draw=function(_,mesh,texture,m,pull,pose,subject)
  draws[#draws+1]={texture=texture,model=m,subject=subject,pose=pose};return available
 end},['q57/Breakout']={clear=function()end}}
modules['q57/Release']={DURATION=1.35,pose=function(age,source,mouth,width,height,yaw)
 return{timer=age,source=source,mouth=mouth,width=width,height=height,yaw=yaw,fade=1,pull=.4,release=true}
end}
local A=assert(loadfile('lib/q57/Adapter.lua'))({require=function(name)return assert(modules[name],name)end})
local shells=0
local shell={scale=1,mouth=function(self)return unpack(self.pos)end,drawShell=function()shells=shells+1 end}
local e={nativePair=true,battler=actors[2],nativeCue=cue,shell=shell,age=.45}
local battle={};local arena={player={1,2},enemy={3,4}}
A.prepare(battle,arena,6,nil,{player2=e},cards)
local p=assert(battle.legendaryQ57.player2)
assert(not battle.legendaryQ57.player,'partner energy leaked to lead')
local foot=Pair.point(cards[2],80,143)
near(shell.pos[1],foot[1]);near(shell.pos[2],foot[2]+2.2);near(shell.pos[3],foot[3])
A.draw(battle);assert(#draws==0,'paired energy painted again in ordinary pass')
assert(A.draw(battle,true));assert(shells==1)
assert(not A.subject(battle,cards[1],{},1.5),'teammate became release subject')
assert(A.subject(battle,cards[2],{},1.5)and e.q57Used)
assert(draws[#draws].texture==cards[2].releaseCanvas and draws[#draws].model==cards[2].model,
 'native body transform/texture replaced or combined')
available=false;A.prepare(battle,arena,6,nil,{player2=e},cards)
assert(not A.draw(battle,true)and shells==1,'failed material left an independent shell')
assert(not A.subject(battle,cards[2],{},1.5)and not e.q57Used,'failed draw claimed native body')
available=true;e.battler={};A.prepare(battle,arena,6,nil,{player2=e},cards)
assert(not battle.legendaryQ57.player2,'replacement actor inherited release')
e.battler=actors[2];e.nativeCue={};A.prepare(battle,arena,6,nil,{player2=e},cards)
assert(not battle.legendaryQ57.player2,'replacement event inherited release')
e.nativeCue=cue;enabled=false;A.prepare(battle,arena,6,nil,{player2=e},cards)
assert(not next(battle.legendaryQ57),'OFF retained paired energy')
A.clear();assert(not battle.legendaryQ57)
print('PASS exact paired pixel/world matrices, separate native subjects, event/actor ownership, material failure and OFF cleanup')
