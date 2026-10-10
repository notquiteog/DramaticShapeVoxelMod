local beam,scale,suction,glow=1.55,1,true,1
local auraDraws,released=0,0
local draws=0;local loaded={};local V={}
function V.require(k)
 if k=='PokeballSettings'then return {active=function()return true end,captureDuration=function()return .5 end,beamMult=function()return beam end,fxScaleMult=function()return scale end,suctionEnabled=function()return suction end,pokemonGlowMult=function()return glow end}end
 if k=='q57/Material'then return {draw=function()draws=draws+1;return true end}end
 if k=='q57/Breakout'then return {clear=function()end}end
 if k=='q57/Release'then return {DURATION=1.35}end
 if k=='Voxel3D'then return {newMesh=function()return {setVertices=function()end,release=function()end}end}end
 if not loaded[k]then loaded[k]=assert(loadfile('lib/'..k..'.lua'))(V)end;return loaded[k]
end
local A=V.require('q57/Adapter');local P=V.require('q57/Plasma');local battle={}
local n={owner=battle,ball={mouth=function()return 0,2,0 end,drawCaptureAura=function(self,x,y,z,strength,pull,cache)auraDraws=auraDraws+1;cache[5]={mesh={release=function()released=released+1 end}};assert(x==x and y==y and z==z and strength>0)end},captureFxT=.25}
local arena={enemy={0,24},player={0,-24}}
A.prepare(battle,arena,0,n,{});local p=battle.legendaryQ57.enemy;assert(p.volumeScale==1)
local original=P.newGeometry();P.update(original,p)
beam=0;A.prepare(battle,arena,0,n,{});assert(A.draw(battle)and draws==0 and n.q57Used,'OFF must suppress fallback')
beam=1.55;suction=false;A.prepare(battle,arena,0,n,{});assert(A.draw(battle)and draws==0)
suction=true;scale=.5;glow=0;A.prepare(battle,arena,0,n,{});p=battle.legendaryQ57.enemy;assert(p.volumeScale==.5)
local small=P.newGeometry();P.update(small,p);local changed=false
for i,v in ipairs(small)do for j=1,3 do if math.abs(v[j]-original[i][j])>.0001 then changed=true end end end
assert(changed,'FX scale must alter actual emitted geometry');assert(A.draw(battle)and draws==1 and auraDraws==1)
assert(n.captureFxT==.25 and battle.player==nil,'capture logic changed')
A.clear();assert(released==1,"capture aura GPU cache not released");print('PASS shared Q57 default geometry, beam/suction OFF ownership, actual FX scale and immutable capture clock')
