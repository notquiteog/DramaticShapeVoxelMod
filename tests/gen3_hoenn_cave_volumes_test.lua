local Profiles=dofile('lib/Gen3CaveProfiles.lua')
local checks=0
local function check(v,m)assert(v,m);checks=checks+1 end
for _,s in ipairs({'cave','rusturf_tunnel'})do
 for _,mid in ipairs({0x208,0x209,0x210,0x211,0x212,0x218,0x219,0x21A,0x21B,0x21C,0x220,0x222})do
  check(Profiles.shape('general',s,mid,0,7).kind=='caveWall','native rock identity missing')
  for _,coll in ipairs({0,43,114,160,163})do check(not Profiles.shape('general',s,mid,0,coll),'walkable copy raised')end
 end
 for _,mid in ipairs({0x204,0x205,0x206,0x207,0x214,0x21F,0x23F,0x259,0x300})do
  if s=='cave'and mid==0x300 or s=='rusturf_tunnel'and(mid==0x204 or mid==0x205 or mid==0x206)then else
   check(not Profiles.shape('general',s,mid,0,7),'stairs/portal/unreviewed drawing raised')
  end
 end
end
check(not Profiles.shape('building','cave',0x219,0,7),'building vocabulary captured')
check(not Profiles.shape('general','mauville',0x219,0,7),'outdoor vocabulary captured')
for _,p in ipairs({{0x2D9,0x2D1},{0x2F8,0x2E8},{0x329,0x321},{0x389,0x381}})do
 local s=assert(Profiles.shape('general','cave',p[1],0,7));check(s.cap==p[2]and s.side==p[1],'native palette crossed')
end
for _,mid in ipairs({0x201,0x219,0x229,0x244,0x264,0x26C,0x274})do
 local r=Profiles.shape('general','meteor_falls',mid,0,7)
 check(r and r.kind=='caveWall'and r.cap==0x229,'Meteor Falls native rock profile missing')
 check(not Profiles.shape('general','meteor_falls',mid,8,43),'Meteor walkable cap raised')
end
check(Profiles.shape('general','meteor_falls',0x26C,0,7).side==0x26C,'golden column seam recolored')
check(not Profiles.shape('general','meteor_falls',0x254,0,7),'separate original pillar folded into rock wall')
local cells={}
for y=-2,2 do for x=-2,2 do cells[x..':'..y]={cx=x,cy=y,pair='general__cave',secondary='cave',mid=0x211,collision=7,shape=Profiles.shape('general','cave',0x211,8,7)}end end
local root=cells['0:0'];root.mid=0x202;root.shape=Profiles.shape('general','cave',root.mid,0,7)
check(Profiles.prepare(cells)==1 and root.shape.capRock and root.shape.kind=='caveWall','enclosed boulder carved cap well')
root.shape=Profiles.shape('general','cave',0x202,0,7);cells['0:1'].collision=43;cells['0:1'].shape={kind='flat'}
check(Profiles.prepare(cells)==0 and root.shape.kind=='rock','floor boulder raised to cap')
local Terrain=dofile('lib/Gen3Terrain.lua');local top=Terrain.height(cells,-8,-8,28);check(top==28,'connected mass cap not continuous')
local zeros,raised=0,0
local Cave=assert(loadfile('lib/Gen3Cave.lua'))({require=function(n)assert(n=='Gen3Terrain');return{append=function(_,_,emit)
 emit({{0,0,0},{4,0,0},{4,0,4},{0,0,4}}, {},1)
 emit({{4,0,0},{8,28,0},{8,28,4},{4,0,4}}, {},1)
 end}end})
Cave.wall({}, {shape={},base=0},function(v)if v[2][2]==0 then zeros=zeros+1 else raised=raised+1 end end,function()end)
check(zeros==0 and raised==1,'native floor has duplicate cave quad')
-- A one-cell native walking lane remains open on both sides. Shared cave
-- samples are exact at neighboring tile edges and never leave blocked cells.
local grid={}
for y=-2,2 do for x=-2,2 do grid[x..':'..y]={cx=x,cy=y,base=0,shape=x==0 and{kind='flat'}or{kind='caveWall',height=28,cap=1,side=2}}end end
for y=-1,1 do for x=-1,1 do if x~=0 then
 local c=grid[x..':'..y]
 Terrain.append(grid,c,function(v)
  for _,q in ipairs(v)do check(q[1]>=x*16 and q[1]<=x*16+16 and q[3]>=y*16 and q[3]<=y*16+16,'rock escaped native blocked footprint')end
 end,function()return{{0,0},{1,0},{1,1},{0,1}}end)
end end end
for z=-16,32,4 do check(Terrain.height(grid,0,z,28)==0 and Terrain.height(grid,16,z,28)==0,'native lane sealed')end
local version='emerald'
package.loaded['src.core.GameVersion']={get=function()return version end}
package.loaded['src.core.game3.collision']={isSurfable=function(b)return b==0x11 end}
local V,modules={},{}
function V.require(n)if not modules[n]then modules[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return modules[n]end
local S=V.require('Gen3TileShape')
for _,v in ipairs({'emerald','ruby','sapphire'})do version=v
 check(S.of('general','cave',0x219,0,7).kind=='caveWall','Hoenn flat fallback swallowed cave profile')
 check(S.of('general','rusturf_tunnel',0x219,0,7).kind=='caveWall','Rusturf profile not dispatched')
 check(S.of('general','cave',0x23F,0x61,114).kind=='ladder','native semantic ladder sealed')
 check(S.of('general','cave',0x211,8,43).kind=='flat','walkable cap lost floor')
 check(S.of('general','cave',0x2BE,0x11,41).kind=='water','native water flattened')
end
version='firered';check(S.of('general','rom_082d4bfc',0x291,8,7).kind=='caveWall','Kanto cave lost profile')
print('PASS '..checks..' native Hoenn cave volume, palette, cap union, footprint, portal and unique-floor contracts')
