local P=dofile('lib/Gen3CaveProfiles.lua');local checks=0
local function check(v,s)assert(v,s);checks=checks+1 end
for _,mid in ipairs{0x275,0x277,0x278,0x279,0x27A,0x27D,0x27E,0x27F,
 0x280,0x281,0x282,0x285,0x286,0x287,0x288,0x289,0x28A,0x28D,0x28E,0x293,0x294,0x29B,0x29C}do
 local s=P.shape('general','pacifidlog',mid,0,7)
 check(s and s.kind=='caveWall'and s.cap==0x279 and s.side==0x281,'native brown rock identity missing')
 for _,coll in ipairs{0,41,43,114,160,163}do check(not P.shape('general','pacifidlog',mid,0,coll),'walkable/current copy raised')end
 check(not P.shape('building','pacifidlog',mid,0,7),'building vocabulary claimed')
end
for _,mid in ipairs{0x170,0x181,0x190,0x192,0x26F,0x271,0x276,0x283,0x284,0x28B,0x28C,
 0x28F,0x290,0x291,0x292,0x295,0x296,0x297,0x298,0x299,0x29A,0x2C3,0x2C5}do
 check(not P.shape('general','pacifidlog',mid,0,7),'water/current/warp/unknown identity claimed')
end
for _,mid in ipairs{0x273,0x274}do check(P.shape('general','pacifidlog',mid,0,7).kind=='rock','native boulder missing')end
local version='emerald';package.loaded['src.core.GameVersion']={get=function()return version end}
package.loaded['src.core.game3.collision']={isSurfable=function(b)return b==0x11 or b==0x15 or b>=0x50 and b<=0x53 end}
local V,modules={},{};function V.require(n)if not modules[n]then modules[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return modules[n]end
local S=V.require('Gen3TileShape')
for _,ed in ipairs{'emerald','ruby','sapphire'}do version=ed
 check(S.of('general','pacifidlog',0x281,0,7).kind=='caveWall','regional flat fallback swallowed cavern')
 check(S.of('general','pacifidlog',0x279,8,43).kind=='flat','native island floor raised')
 check(S.of('general','pacifidlog',0x28B,0x51,41).kind=='water','native current changed')
 check(S.of('general','pacifidlog',0x291,0x60,114).kind=='flat','native warp presentation changed')
end
local F=dofile('lib/Gen3Furniture.lua')
local function arch(rows,collision,pair)
 local cells={};for x,mid in ipairs(rows)do cells[(x-1)..':0']={cx=x-1,cy=0,mid=mid,collision=collision[x],pair=pair or'general__pacifidlog',primary='general',ts={}}end
 return F.extract(cells),cells
end
for _,ed in ipairs{'emerald','ruby','sapphire'}do version=ed
 local p,cells=arch({0x290,0x291,0x292},{7,114,7});check(#p==1 and p[1].recipe.kind=='cavePortal','complete native north opening not claimed')
 check(cells['1:0'].collision==114,'native warp approach changed')
 check(#arch({0x290,0x291,0x292},{7,43,7})==0,'different walkable copy claimed')
 check(#arch({0x290,0x291,0x292},{0,114,7})==0,'arch jamb leaves blocked footprint')
 check(#arch({0x298,0x299,0x29A},{7,7,7})==1,'native south arch lost')
 check(#arch({0x298,0x299,0x29A},{7,43,7})==0,'walkable south copy claimed')
 check(#arch({0x298,0x299,0x271},{7,7,7})==1,'RS native south cap variant lost')
end
version='firered';check(#arch({0x290,0x291,0x292},{7,114,7})==0,'Kanto art claimed')
version='emerald'
local Portal=V.require('Gen3NavelPortal');local p,cells=arch({0x290,0x291,0x292},{7,114,7});p=p[1]
cells['1:-1']={cx=1,cy=-1,pair=p.pair,mid=0x289,collision=7,shape={kind='caveWall'}}
Portal.prepare(cells);check(cells['1:-1'].prop==p and cells['1:-1'].shape.kind=='flat'and p.tunnelBack==16,'native backing seals aperture')
local part={vertices={},indices={}};Portal.append(p,function(q)
 local first=#part.vertices;for _,v in ipairs(q)do part.vertices[#part.vertices+1]=v end
 for _,n in ipairs{1,2,3,1,3,4}do part.indices[#part.indices+1]=first+n end
end,function()return{{0,0},{1,0},{1,1},{0,1}}end)
assert(loadfile('tests/imported_interior_surface_planes_test.lua'))('helper')({parts={part}},#part.indices/3)
for i=1,#part.indices,3 do local x,y,z=0,0,0
 for j=0,2 do local v=part.vertices[part.indices[i+j]];x=x+v[1]/3;y=y+v[2]/3;z=z+v[3]/3 end
 check(not(x>16 and x<32 and y>=0 and y<24 and z>=-16 and z<=16),'native tunnel below lintel sealed')
end
local data={['0:1']={mid=0x290,coll=7},['1:1']={mid=0x291,coll=114},['2:1']={mid=0x292,coll=7},['1:0']={mid=0x289,coll=7}}
local def={width=3,height=4,warps={{x=1,y=1}},midLayout={pair='general__pacifidlog',cellAt=function(_,x,y)return data[x..':'..y]end}}
local passages=Portal.boundaryPassages(def);check(#passages==1 and passages[1].side==1 and passages[1][1]==16 and passages[1][2]==32 and passages[1][4]==24,'shell backing seals native tunnel')
def.warps={};check(#Portal.boundaryPassages(def)==0,'shell opening without native warp')
local shell=dofile('lib/Gen3CaveShell.lua');local vertices,indices=shell.geometry({bounds={0,0,48,48},height=64,passages={{{16,32,0,24}},{},{},{}}},1,false)
local joint=false
for _,v in ipairs(vertices)do
 if(v[1]==16 or v[1]==32)and v[2]>=0 and v[2]<=24 and v[3]==0 then joint=true end
end
check(joint,'portal rock relief leaves a gap at the native bounds')
for i=1,#indices,3 do local x,y,z=0,0,0
 for j=0,2 do local v=vertices[indices[i+j]];x=x+v[1]/3;y=y+v[2]/3;z=z+v[3]/3 end
 check(not(x>16+1e-7 and x<32-1e-7 and y>1e-7 and y<24-1e-7),'24px shell aperture sealed')
end
print('PASS '..checks..' Seafloor native rock identity, palette, current, floor and warp contracts')
