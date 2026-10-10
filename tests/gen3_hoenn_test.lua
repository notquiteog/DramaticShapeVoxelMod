local version='emerald'
package.loaded['src.core.GameVersion']={get=function()return version end,generation=function()return 3 end}
package.loaded['src.core.game3.collision']={isSurfable=function(b)return b==0x10 end}
local V,cache={},{}
function V.require(name)if not cache[name]then cache[name]=assert(loadfile('lib/'..name..'.lua'))(V)end;return cache[name]end
local H=V.require('Gen3Hoenn');local S=V.require('Gen3TileShape');local F=V.require('Gen3Furniture')
assert(H.active());assert(S.of('general','petalburg',0x1dc,0,1).root)
assert(S.of('general','petalburg',0x14,0,1).kind=='flat','FRLG tree number must not leak into Emerald')
assert(S.of('general','petalburg',1,0x10,0).kind=='water')
for _,mid in ipairs({0x3c9,0x3d1})do
 assert(S.of('building','generic_building',mid,0,7).kind=='roomWall')
 assert(S.of('building','generic_building',mid,0,0).kind=='flat','walkable Fortree tile folded')
 assert(S.of('building','shop',mid,0,7).kind=='flat','Fortree siding leaked to shop')
end
for _,mid in ipairs({0x268,0x269,0x26a,0x270,0x272,0x278,0x27a})do
 local cliff=S.of('general','fallarbor',mid,0,7)
 assert(cliff.kind=='cliff' and cliff.ground==0x279 and cliff.height==32)
 assert(S.of('general','fallarbor',mid,0,0).kind=='flat','walkable native floor raised')
 assert(S.of('general','petalburg',mid,0,7).kind=='flat','Fallarbor art leaked to another atlas')
end
for _,mid in ipairs({0x277,0x279,0x2fd,0x2c7})do
 assert(S.of('general','fallarbor',mid,0,7).kind=='flat','sand/decorations became rock wall')
end
local tree=S.of('general','petalburg',0x1dc,0,1)
assert(#tree.treeRows==2 and #tree.treeRows[1]==2 and tree.treeFamily=='round')
local count=0
for _,r in ipairs(H.recipes)do
 local cells={};for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
  cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,pair=r.pair,primary=r.primary or 'building',ts={}}
 end end
 local props=F.extract(cells);assert(#props==1 and props[1].recipe==r,r.name)
 if r.collisionRows then
  local exact={};for key,c in pairs(cells)do local q={};for k,v in pairs(c)do if k~='prop'then q[k]=v end end;q.collision=r.collisionRows[q.cy+1][q.cx+1];exact[key]=q end
  assert(#F.extract(exact)==1,r.name..' native footprint rejected')
  for _,c in pairs(exact)do c.prop=nil end
  local changed=false;for _,c in pairs(exact)do if c.collision~=0 then c.collision=0;changed=true;break end end;assert(changed)
  assert(#F.extract(exact)==0,r.name..' placed over walking lane')
 end
 if r.design=='em_lilycove_gallery' then
  local blocked={};for key,c in pairs(cells)do local q={};for k,v in pairs(c)do if k~='prop'then q[k]=v end end;q.collision=q.cy==2 and 7 or 0;blocked[key]=q end
  assert(#F.extract(blocked)==1,'complete gallery lost its blocked base')
  for _,c in pairs(blocked)do c.prop=nil end
  blocked['2:2'].collision=0
  assert(#F.extract(blocked)==0,'gallery occupied native walking space')
 end
 if r.design=='em_fortree_support'then
  assert(#r.rows==4 and #r.rows[1]==2 and r.ground==0x3d9,'support lost its full native drawing')
  local missing={};for key,c in pairs(cells)do
   local copy={};for k,v in pairs(c)do if k~='prop'then copy[k]=v end end
   missing[key]=copy
  end
  missing['1:3']=nil
  assert(#F.extract(missing)==0,'partial support became a truncated tree')
 end
 version='firered';assert(#F.extract(cells)==0,'Hoenn recipe claimed FRLG art: '..r.name);version='emerald'
 count=count+1
end
cache.BuildBudget={tick=function()end,check=function()end}
local Civic=V.require('Gen3Civic')
for _,r in ipairs(H.exteriors)do
 local cells={};for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
  cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,pair=r.pair,primary='general',ts={}}
 end end
 local found=Civic.prepare(cells,{},{});assert(#found==1 and found[1].family==r.name,r.name)
 local p=Civic.profile(found[1]);assert(p.wall>0 and p.wallBottom<=#r.rows*16,'roof/wall extent includes outside ground')
 if r.kind=='center' or r.kind=='mart' then
  assert((r.centerRoof or r.martRoof) and r.bodyBack==16,r.name..' missing authored roof/rear walking lane')
  local badge,thickness,roof=0,false,{}
  Civic.append(found[1],function(v,t)
   for _,q in ipairs(v)do
    if q[2]<p.wall then assert(q[3]>=16 and q[3]<64,'Center body occupies rear/front walking row')end
    if q[3]==14 then roof[q[1]]=math.max(roof[q[1]] or 0,q[2])end
   end
   -- Badge triangles use the untouched facade half, above the eave.
   if v[1][1]==32 and v[1][2]==31.5 and v[2][3]==61.46 then
    badge=badge+1
    for _,q in ipairs(v)do assert(q[3]==61.46 and q[2]>=23,'badge detached from front fascia')end
   end
   if v[1][3]==61 and v[2][3]==61.46 then thickness=true end
  end)
  assert(badge==32 and thickness,'native roof badge has no closed depth')
  if r.kind=='center' then
   assert(roof[8]==roof[12] and roof[12]==roof[16],'native lower roof shoulders lost')
   assert(roof[32]-roof[16]>=10,'distinct raised middle hump flattened into one barrel')
  else
   assert(roof[8]==roof[32] and roof[32]==roof[56],'Mart plateau acquired a Center hump or house gable')
   assert(roof[8]>roof[0],'Mart rolled roof edges flattened')
  end
  -- Closest native paving/sand underlay must replace the hardcoded lawn.
  for _,c in pairs(cells)do c.civic=nil end
  cells['1:4']={cx=1,cy=4,mid=0x777,pair=r.pair,collision=0,shape={kind='flat'}}
  cells['2:4']={cx=2,cy=4,mid=0x778,pair=r.pair,collision=7,shape={kind='flat'}}
  local floor=Civic.prepare(cells,{},{})[1]
  assert(floor and Civic.ground(cells['2:3'])==0x777,'Center/Mart underlay ignored native ground or used solid decoration')
 end
 if r.openings and (r.name:match('^petalburg_city_.*home$') or r.name:match('^dewford_town_.*home$') or r.name=='dewford_town_hall' or r.name=='lavaridge_town_home') then
  local g=found[1];local faces={}
  Civic.append(g,function(v)faces[#faces+1]=v end)
  local relief=0
  for _,face in ipairs(faces)do for _,v in ipairs(face)do
   if v[3]>p.front and v[2]<p.wall-2 then
    assert(v[3]<g.depth*16,'timber post protrudes into path')
    local inside=false
    for _,post in ipairs(r.facadePosts or {})do inside=inside or v[1]>=post[1] and v[1]<=post[3]end
    assert(inside,'relief escaped native timber stiles');relief=relief+1
   end
  end end
  assert(relief>0,'native timber posts stayed flat')
  for _,o in ipairs(r.openings)do
   local pane=false
   for _,v in ipairs(faces)do
    if v[1][1]==o[1] and v[2][1]==o[3] and v[1][2]==p.wallBottom-o[2]
      and v[3][2]==p.wallBottom-o[4] and v[1][3]==p.front-1 and v[3][3]==p.front-1 then pane=true end
   end
   assert(pane,r.name..' aperture has no recessed native pane')
   if o.door then
    local surface=Civic.doorSurface(g,math.floor(o[1]/16),3)
    assert(surface and surface.w==o[3]-o[1] and surface.h==o[4]-o[2],r.name..' animated door lost source crop')
    assert(surface.vertices[1][3]<p.front,'door animation floats in front of facade')
   end
  end
 end
 if r.bodyBack==18 then
  Civic.append(found[1],function(vertices)
   for _,v in ipairs(vertices)do
    if v[2]<16 then assert(v[3]>=16,r.name..' body intrudes into walkable rear roof-art row')end
   end
  end)
 end
 if r.profile=='hoenn_gym' then
  local g=found[1];local front,door=0,false;local solidCheeks,canopyRims=0,0;local squareTop,closedSoffit=false,false
  Civic.append(g,function(vertices,tex)
   local a,b=vertices[1],vertices[2]
   if a[2]==26 and a[1]==41 and a[3]==64 then
    assert(b[1]==71 and vertices[3][1]==71 and vertices[4][1]==41,'gym canopy tapers instead of retaining square corners')
    squareTop=true
   end
   if a[2]==24 and a[1]==40 and a[3]==79 and b[1]==72 and vertices[3][3]==64 then closedSoffit=true end
   if a[2]==22 and b[2]==22 and a[3]==64 and b[3]==79 then
    assert(math.abs(tex[2][1]-tex[1][1])<.001,'gym cheek repeats projected diagonal artwork')
    solidCheeks=solidCheeks+1
   end
   if a[2]==25.2 and b[2]==25.2 and vertices[3][2]==24 then canopyRims=canopyRims+1 end
   for _,v in ipairs(vertices)do
    assert(v[2]>=0 and v[2]<=28.1,'gym height escaped flat roof profile')
    -- Native last-row side cells are walkable. Body geometry must stop at
    -- their northern edge; only the blocked middle vestibule may project.
    local sign=r.gymSign and v[1]>=81 and v[1]<=95 and v[3]>=73 and v[3]<=77.05
    if v[2]<24 and not sign then
     if v[1]<32 or v[1]>80 then assert(v[3]<=64,'gym wing intrudes into native walking strip')end
     if v[3]>64 then assert(v[1]>=32 and v[1]<=80,'porch escaped its blocked cells')end
    end
    if v[2]<24 and r.bodyBack==16 then assert(v[3]>=16,'rear wall/window intrudes into native walking row')end
    front=math.max(front,v[3])
   end
  end)
  assert(squareTop and closedSoffit,'rectangular gym canopy must have a closed underside')
  assert(solidCheeks==2 and canopyRims==4,'gym vestibule needs two solid cheeks and closed canopy rim')
  local surface=Civic.doorSurface(g,3,4)
  assert(surface and surface.w==14 and surface.h==16,'gym native door animation missing')
  assert(p.front==64 and front<=79 and p.wallBottom==71,'native ground cropped or footprint shifted')
 end

end
version='leafgreen';assert(not H.active());assert(S.of('general','pallet_town',0x14,0,1).kind=='tree')
print('PASS '..count..' native Hoenn furniture recipes, family isolation and four-cell tree artwork')

version='emerald'
assert(S.of('general','mauville',0x288,0,7).kind=='fence')
assert(S.of('general','petalburg',0x288,0,7).kind=='flat','secondary fence alias leaked')
assert(S.of('general','petalburg',0xc5,0x10,7).kind=='rock','ocean rock swallowed by surfable water')
assert(S.of('general','petalburg',0xc5,0x10,0).kind=='water','walkable water blocked by scenery')
assert(S.of('general','petalburg',0x85,0x39,7).direction=='west')
assert(S.of('general','petalburg',0x86,0x38,7).direction=='east')
assert(S.of('general','petalburg',0x71,0xc,7).kind=='cliff')
assert(S.of('general','petalburg',0x71,0xc,0).kind=='flat','walkable floor became a cliff')
local F=V.require('Gen3Furniture')
local carpet={recipe={ground=1,groundRows={{2,3},{4,5}}},cx=8,cy=9}
assert(F.groundAt({prop=carpet,cx=9,cy=10})==5,'carpet border lost beneath fixture')
print('PASS Hoenn scenery scope, water/rock ownership, native ledge directions and carpet underlays')

local fence=S.of('general','verdanturf',0x34d,0,7)
assert(fence.kind=='fence' and fence.postWidth==5.8 and #fence.rails==1)
assert(S.of('general','mossdeep',0x34d,0,7).kind=='flat','Verdanturf fence borrowed another town tile')
print('PASS '..#H.exteriors..' complete Hoenn exterior patterns and native Verdanturf fence scope')

for _,id in ipairs{0x64,0x65,0x6d,0x6e,0x6f,0x7f,0x8f}do
 assert(S.of("general","mossdeep",id,0,7).kind~="cliff","ground or house became a cliff")
end
assert(S.of("general","mossdeep",0x9e,0,7).cap==0x6c,"cliff cap borrowed a grassy slope")

for _,id in ipairs{0xaf,0xcf}do
 assert(S.of('general','mossdeep',id,0,0).kind=='steps','Hoenn normal-behavior stairs flattened')
end
assert(S.of('general','sootopolis',0x244,0,0).kind=='steps')
assert(S.of('general','lavaridge',0x2af,0,0).kind=='steps')
assert(S.of('general','mossdeep',0x244,0,0).kind~='steps','local stair ID leaked')
assert(S.of('general','mossdeep',0xcf,0,7).kind=='tree','blocked tree artwork became stairs')
assert(S.of('general','mossdeep',0x100,0x2a,0).kind~='steps','Emerald seaweed became stairs')

assert(S.of('general','meteor_falls',0x202,8,43).kind=='steps','cave encounter stairs flattened')
assert(S.of('general','mossdeep',0x202,8,43).kind~='steps','Meteor Falls stairs leaked')

for _,primary in ipairs({'general','building'})do
 for _,mid in ipairs({0x2f8,0x300,0x388,0x389,0x390,0x391})do
  assert(S.of(primary,'facility',mid,0,7).kind=='roomWall')
  assert(S.of(primary,'facility',mid,0,0).kind=='flat','walkable wallpaper folded up')
  assert(S.of(primary,'generic_building',mid,0,7).kind~='roomWall','facility wall alias leaked')
 end
 for _,mid in ipairs({0x373,0x374})do
  assert(S.of(primary,'facility',mid,0,7).kind=='fence')
  assert(S.of(primary,'generic_building',mid,0,7).kind~='fence','facility railing alias leaked')
 end
end
print('PASS science-room wall/fence scope and walkable artwork exclusions')

for _,mid in ipairs({0x204,0x20c})do
 assert(S.of('building','oceanic_museum',mid,0,7).kind=='roomWall')
 assert(S.of('building','oceanic_museum',mid,0,0).kind=='flat','walkable museum copy folded up')
 assert(S.of('building','generic_building',mid,0,7).kind=='flat','museum wall escaped atlas scope')
end

local museumFaces=0
V.require('InteriorFurniture').draw('em_museum_wall_case',{
 box=function()end,sample=function()return{}end,
 source=function(x,y,w,h)assert(y+h<=40,'museum carpet wrapped onto upright glass cabinet');museumFaces=museumFaces+1 end})
assert(museumFaces>0)

for _,mid in ipairs{0x222,0x244}do
 assert(H.shape('building','shop',mid,0,7).kind=='roomWall','clock wallpaper became a floor prop')
 assert(H.shape('building','shop',mid,0,0).kind=='flat','walkable clock alias became solid')
end
for _,r in ipairs(H.recipes)do assert(r.name~='hoenn_mart_return','wallpaper/floor claimed as checkout')end

do
 local rows={{0x302,0x303,0x304},{0x30a,0x30b,0x30c},{0x312,0x313,0x314}}
 local function fixture()
  local cells={}
  for y,row in ipairs(rows)do for x,mid in ipairs(row)do
   cells[x..':'..y]={cx=x,cy=y,mid=mid,primary='general',secondary='mossdeep',pair='general__mossdeep',collision=y==3 and 7 or 0,shape={kind='flat'}}
  end end
  return cells
 end
 local c=fixture();assert(H.prepareTrees(c)==1)
 local roots=0
 for _,v in pairs(c)do assert(v.shape.kind=='tree');if v.shape.root then roots=roots+1;assert(v.cx==2 and v.cy==3 and v.collision==7);assert(v.shape.anchorX==8 and v.shape.anchorZ==8)end end
 assert(roots==1 and c['2:3'].shape.treeFamily=='mossdeep')
 c=fixture();c['1:1'].mid=0x2fa;assert(H.prepareTrees(c)==0,'partial cliff-composite tree consumed terrain')
 c['2:1'].mid=0x2fb;assert(H.prepareTrees(c)==1)
 assert(c['1:1'].collision==0 and c['1:1'].shape.kind=='tree' and not c['1:1'].shape.root and c['1:1'].shape.retaining==0x71,'walkable corner raised or terrain material lost')
 c=fixture();c['2:3'].collision=0;assert(H.prepareTrees(c)==0,'trunk placed on walking lane')
 c=fixture();c['1:1']=nil;assert(H.prepareTrees(c)==0,'partial drawing consumed')
end
print('PASS complete Mossdeep tree group and blocked trunk anchor')

local models=V.require('NativeTreeModels')
for y=0,16 do for x=-24,24 do for z=-24,24 do
 if models.part('mossdeep',x/48,y/48,z/48) then
  assert(math.abs(x)<8 and math.abs(z)<8,'Mossdeep low trunk extends outside blocked center cell')
 end
end end end

do
 local rows={{0x2f2,0x2f3,0x2f4},{0x301,0x30b,0x305},{0x312,0x313,0x314}}
 local cells={}
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do
  cells[x..':'..y]={cx=x,cy=y,mid=mid,primary='general',secondary='mossdeep',pair='general__mossdeep',collision=y==2 and 0 or 7,shape={kind='flat'}}
 end end
 assert(H.prepareTrees(cells)==1)
 for x=1,3 do assert(cells[x..':1'].shape.retaining==0x71 and cells[x..':1'].shape.ground==0x6c and not cells[x..':1'].shape.root,'north cliff erased by tree');assert(cells[x..':2'].shape.kind=='tree' and not cells[x..':2'].shape.root)end
 assert(cells['2:3'].shape.root)
 cells['2:1'].collision=0
 assert(H.prepareTrees(cells)==0,'walkable cliff composite raised')
end
print('PASS north-cliff Mossdeep trees preserve blocked terrain band')
