local P=dofile('lib/Gen3CaveProfiles.lua');local checks=0
local function check(v,s)assert(v,s);checks=checks+1 end
for _,q in ipairs{
 {0x211,0x219,{0x210,0x212,0x218,0x219,0x21A,0x21B,0x21C,0x247,0x2D0,0x2D2,0x2D3,0x2D4,0x2DC,0x2E0,0x2E1,0x2E2}},
 {0x371,0x361,{0x350,0x352,0x358,0x35A,0x370,0x372,0x3A0,0x3A2,0x3B8,0x3BA,0x3C1}},
 {0x364,0x36C,{0x343,0x344,0x345,0x346,0x347,0x34C,0x35B,0x35C,0x35D,0x363,0x364,0x365,0x36B,0x36C,0x36D,0x373,0x374,0x388,0x38A,0x393,0x394,0x39B,0x39C,0x3A3,0x3A4,0x3AB,0x3AC}}
}do for _,mid in ipairs(q[3])do
 local s=P.shape('general','navel_rock',mid,0,7);check(s and s.kind=='caveWall'and s.height==28 and s.cap==q[1]and s.side==q[2],'Navel native rock paint changed')
 for _,coll in ipairs{0,41,43,114,160,163}do check(not P.shape('general','navel_rock',mid,0,coll),'walkable/semantic copy raised')end
 check(not P.shape('building','navel_rock',mid,0,7),'building art raised')
end end
for _,mid in ipairs{0x201,0x204,0x207,0x20F,0x211,0x217,0x23F,0x258,0x259,0x25A,0x2D9,0x33C,0x351,0x366,0x37B,0x381,0x383,0x38B,0x147}do
 check(not P.shape('general','navel_rock',mid,0,7),'native floor/sky/stair/ladder/water identity claimed')
end
for _,mid in ipairs{0x203,0x2D5,0x33D,0x33E}do check(P.shape('general','navel_rock',mid,0,7).kind=='rock','native boulder missing')end
local version='emerald';package.loaded['src.core.GameVersion']={get=function()return version end}
package.loaded['src.core.game3.collision']={isSurfable=function()return false end}
local V,modules={},{};function V.require(n)if not modules[n]then modules[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return modules[n]end
local S=V.require('Gen3TileShape')
check(S.of('general','navel_rock',0x219,0,7).kind=='caveWall','regional flat fallback swallowed cave')
check(S.of('general','navel_rock',0x23F,0x61,114).kind=='ladder','native ladder changed')
check(S.of('general','navel_rock',0x33C,0,7).kind=='flat','summit sky raised')
check(S.of('general','navel_rock',0x364,0,0).kind=='flat','Lugia platform raised')
local Portal=V.require('Gen3NavelPortal');local parts={vertices={},indices={}}
Portal.append({cx=0,cy=0,ts={}},function(q,t)
 for _,v in ipairs(q)do check(v[1]>=0 and v[1]<=48 and v[3]>=0 and v[3]<=16,'arch outside native blocked cells')end
 local first=#parts.vertices;for _,v in ipairs(q)do parts.vertices[#parts.vertices+1]=v end
 for _,i in ipairs{1,2,3,1,3,4}do parts.indices[#parts.indices+1]=first+i end
end,function()return{{0,0},{1,0},{1,1},{0,1}}end)
assert(loadfile('tests/imported_interior_surface_planes_test.lua'))('helper')({parts={parts}},#parts.indices/3)
local area,volume=0,0
local function cross(a,b)return{a[2]*b[3]-a[3]*b[2],a[3]*b[1]-a[1]*b[3],a[1]*b[2]-a[2]*b[1]}end
local function sub(a,b)return{a[1]-b[1],a[2]-b[2],a[3]-b[3]}end
local function dot(a,b)return a[1]*b[1]+a[2]*b[2]+a[3]*b[3]end
for i=1,#parts.indices,3 do
 local a,b,c=parts.vertices[parts.indices[i]],parts.vertices[parts.indices[i+1]],parts.vertices[parts.indices[i+2]]
 local n=cross(sub(b,a),sub(c,a));area=area+math.sqrt(dot(n,n))/2;volume=volume+dot(a,cross(b,c))/6
end
check(math.abs(area-5123.2)<1e-6,'arch exposed union surface missing or duplicated')
check(math.abs(math.abs(volume)-15372.8)<1e-6,'arch closed union volume changed')
-- No face crosses the interior of the native one-cell aperture below24px.
for i=1,#parts.indices,3 do
 local x,y,z=0,0,0;for j=0,2 do local v=parts.vertices[parts.indices[i+j]];x=x+v[1]/3;y=y+v[2]/3;z=z+v[3]/3 end
 check(not(x>16+1e-7 and x<32-1e-7 and y>=0 and y<24-1e-7),'arch centre sealed')
end
local F=dofile('lib/Gen3Furniture.lua')
local function fixture(collision,pair,complete)
 local cells={};for x,mid in ipairs{0x258,0x259,complete==false and 0x201 or 0x25A}do cells[(x-1)..':0']={cx=x-1,cy=0,mid=mid,collision=collision,pair=pair or'general__navel_rock',primary='general',ts={}}end
 return F.extract(cells)
end
local p=fixture(7);check(#p==1 and p[1].recipe.kind=='cavePortal','exact arch not claimed once')
check(#fixture(43)==0 and #fixture(7,nil,false)==0 and #fixture(7,'general__cave')==0,'incomplete/walkable/different arch claimed')
version='firered';check(#fixture(7)==0,'Kanto art claimed as Hoenn arch')
print('PASS '..checks..' Navel Rock native art, palette, solid footprint, sky, floor and ladder contracts')
