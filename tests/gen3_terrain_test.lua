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
