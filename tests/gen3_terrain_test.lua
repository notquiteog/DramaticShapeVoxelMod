local Shapes=dofile('lib/Gen3TileShape.lua')
local T=dofile('lib/Gen3Terrain.lua')
local cells={}
for y=-2,3 do for x=-2,3 do
 cells[x..':'..y]={cx=x,cy=y,mid=1,shape=Shapes.of('general','town',1)}
end end
for y=0,1 do for x=0,1 do
 local c=cells[x..':'..y];c.mid=113;c.shape=Shapes.of('general','town',113)
end end
assert(T.height(cells,16,16)==32,'rock plateau was not raised')
assert(T.height(cells,0,8)==0,'outside cliff edge did not return to native ground')
assert(T.height(cells,2,8)==16,'cliff bevel is not continuous')
local uv={{.1,.1},{.2,.1},{.2,.2},{.1,.2}}
local left,right={},{}
local function collect(into)
 return function(v,tex)
  for i,p in ipairs(v)do
   assert(p[2]>=0 and p[2]<=32)
   assert(tex[i][1]>=.1 and tex[i][1]<=.2 and tex[i][2]>=.1 and tex[i][2]<=.2)
   if p[1]==16 then into[p[3]]=p[2]end
  end
 end
end
T.append(cells,cells['0:0'],collect(left),function()return uv end)
T.append(cells,cells['1:0'],collect(right),function()return uv end)
for z,h in pairs(left)do assert(right[z]==h,'adjacent terrain cells left an open seam')end
-- The square tower base occupies its footprint, but the consumed native dome
-- drawing behind it is ground again. Terrain must meet only the actual base.
local tower={cy=-8,northRows=8,custom={geometry='tower'}}
cells['2:0'].civic=tower
assert(T.height(cells,32,8)==32,'terrain bevel pulled away from tower base')
cells['2:0'].cy=-1
assert(T.height(cells,32,8)==0,'terrain hung over the consumed dome drawing')
assert(Shapes.of('building','lab',113).kind~='cliff','indoor metatile was raised as terrain')
assert(Shapes.of('general','town',0x87).kind=='ledge','small jump ledges became cliffs')
for _,c in pairs(cells)do assert(c.mid==1 or c.mid==113,'native tile was modified')end
print('PASS raised rock caps, shared boundary heights, tower contact, dome-ground exclusion and classifier isolation')

local height,calls=T.height,0
T.height=function(...)calls=calls+1;return height(...)end
T.append(cells,cells['0:0'],function()end,function()return uv end)
assert(calls==25,'cliff recomputed shared corner heights')
T.height=height
print('PASS cliff samples each of its 25 shared corners once')

-- Exact output across neighboring cells/profiles, plus fresh samplers after edits.
cells['2:0'].cy=0
local function mesh(c,sample)
 local out={}
 T.append(cells,c,function(v,tex,shade)
  for i,p in ipairs(v)do out[#out+1]=table.concat({p[1],p[2],p[3],tex[i][1],tex[i][2],shade},',')end
 end,function()return uv end,sample)
 return table.concat(out,';')
end
local sample=T.sampler(cells);calls=0
T.height=function(...)calls=calls+1;return height(...)end
for _,key in ipairs({'0:0','1:0','0:1','1:1'})do
 local expected=mesh(cells[key]);local before=calls
 assert(mesh(cells[key],sample)==expected,'shared sampler changed terrain mesh')
 assert(calls-before<=25)
end
local before=calls
mesh(cells['0:0'],sample);assert(calls==before,'shared samples were recomputed')
cells['0:0'].shape.height=16
assert(mesh(cells['0:0'],sample)==mesh(cells['0:0']),'wall profiles shared heights')
cells['-1:0'].base=7
assert(mesh(cells['0:0'],T.sampler(cells))==mesh(cells['0:0']),'new build retained stale heights')
T.height=height
print('PASS numeric terrain neighborhoods, shared scene corners, wall profiles and fresh edit sampling')

-- Flat caps have identical affine UVs and height everywhere with 1/16 the
-- triangles. Nonflat bevels retain the original topology and shading.
local count=0;local corners
T.append(cells,cells['0:0'],function(v,t,shade)count=count+1;corners=v;assert(t==uv and shade==1)end,function()return uv end,function()return 32 end)
assert(count==1 and corners[1][1]==0 and corners[3][1]==16 and corners[3][3]==16)
for _,p in ipairs(corners)do assert(p[2]==32)end
count=0
T.append(cells,cells['0:0'],function()count=count+1 end,function()return uv end,function(_,x,z)return x+z end)
assert(count==16,'nonflat cliff topology changed')
print('PASS coplanar cap reduction, exact source UV extent, unchanged beveled topology')

-- Compare cached support profiles with the direct sampler over sloping floors,
-- museum terraces and multiple wall heights, including negative/boundary cells.
cells['-1:0'].floor={high=12,low=4,reverse=true}
cells['-1:0'].floorHigh=19
cells['0:1'].museumTerrace={groundHeight=9}
local optimized=T.sampler(cells)
for _,h in ipairs({16,32,48})do
 for z=-24,56,2 do for x=-24,56,2 do
  assert(optimized(cells,x,z,h)==T.height(cells,x,z,h),'support-profile reuse changed terrain height')
 end end
end
print('PASS 5043 exact support-profile samples across slopes, terraces and boundaries')

-- Compact enclosure art must not flatten actual native stair/terrace support.
local terrace={}
for y=-2,3 do for x=-2,3 do terrace[x..':'..y]={cx=x,cy=y,base=x<1 and 0 or 6,shape={kind='flat'}}end end
for y=0,1 do for x=0,1 do terrace[x..':'..y].shape={kind='cliff',height=8}end end
local original={};for k,c in pairs(terrace)do original[k]=c.base end
assert(T.height(terrace,16,16,8)==6,'compact wall raised the existing upper terrace')
for _,c in pairs(terrace)do if c.shape.kind=='flat'then c.base=6 end end
assert(T.height(terrace,16,16,8)==14,'enclosure height is not relative to local land')
assert(T.height(terrace,16,16,24)==30,'explicit wall profile was globally capped')
for k,c in pairs(terrace)do if c.shape.kind=='cliff'then assert(c.base==original[k])end end
print('PASS compact enclosure profiles preserve native upper terraces and explicit wall heights')
