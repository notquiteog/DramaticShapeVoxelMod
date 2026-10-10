local Resolve=assert(loadfile('lib/Gen2FurnitureTemplates.lua'))()
local specs=assert(loadfile('data/gen2_depth_furniture.lua'))()
local Plant=assert(loadfile('lib/Gen2Planter.lua'))()
local count=0
for ts,list in pairs(specs) do
 local blocks={}
 for i=1,256 do blocks[i]={};for j=1,16 do blocks[i][j]=i*32+j end end
 local data={blocks=blocks}
 local seen={}
 for _,s in ipairs(list) do
  assert(not seen[s.id],'duplicate recipe');seen[s.id]=true
  local t=assert(Resolve.resolve(data,s))
  assert(#t.tiles==s.crop[4] and #t.tiles[1]==s.crop[3])
  assert(t.tiles[1][1]==blocks[s.block+1][s.crop[2]*4+s.crop[1]+1])
  assert(t.support<=8,'furniture support too high')
  assert(t.groundAligned,'floor pattern must retain world alignment')
  if t.model=='planter' then
   local floor={}
   for _,row in ipairs(t.groundTiles)do for _,tile in ipairs(row)do floor[tile]=true end end
   local q=Plant.build(t,{getPixel=function(_,x,y)
    if floor[math.floor(y/8)*16+math.floor(x/8)]then return .7,.7,.7,1 end
    if x%8>=2 and x%8<6 and y%8>=1 and y%8<7 then return .2,.6,.25,1 end
    return .7,.7,.7,1
   end},16,128,128)
   assert(#q>0 and #q<=280,'planter budget')
   for _,face in ipairs(q) do
    assert(type(face.shade)=='number')
    for i=1,4 do local p=face[i]
     assert(p[1]>=0 and p[1]<=#t.tiles[1]*8,'plant outside source width')
     assert(p[3]>=0 and p[3]<=#t.tiles*8,'plant outside source depth')
     assert(p[2]>=0 and p[2]<=#t.tiles*8+1,'plant height exceeds drawing')
    end
   end
  end
  count=count+1
 end
end
assert(not Resolve.resolve({blocks={}},specs.TILESET_FACILITY[1]),'missing metatile must not claim scenery')
local floor={};for i=1,16 do floor[i]=1 end
assert(not Resolve.resolve({blocks={[3]=floor,[4]=floor}},specs.TILESET_FACILITY[1]),'floor-only crop must not claim an object')
print(count..' source-crop recipes and bounded planter geometry passed')
-- The terminal drawing is part of a complete counter, not an isolated 2x2
-- monitor crop that a taller equipment recipe can claim first.
local desk,equipment
for i,s in ipairs(specs.TILESET_RADIO_TOWER)do
 if s.id=='crystal_depth_radio_desk_terminal' then desk=i;assert(s.crop[1]==0 and s.crop[3]==4)end
 if s.id=='crystal_depth_radio_equipment' then equipment=i end
end
assert(desk and equipment and desk<equipment,'reception desk lost its specific-match priority')
local V={};local cache={}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local n=0
for _,list in pairs(specs)do for _,s in ipairs(list)do
 local blocks={};for i=1,256 do blocks[i]={};for j=1,16 do blocks[i][j]=i*16+j end end
 local t=assert(Resolve.resolve({blocks=blocks},s))
 if t.design then
  local faces=V.require('Gen2DesignedFurniture').build(t,{},128,1024,1024);assert(#faces>20,s.id)
  for _,q in ipairs(faces)do for i=1,4 do
   assert(q[i][2]>=0 and q[i][2]==q[i][2],s.id)
   assert(q.uv[i][1]>=0 and q.uv[i][1]<=1 and q.uv[i][2]>=0 and q.uv[i][2]<=1,s.id)
  end end;n=n+1
 end
end end
print('PASS '..n..' shared furniture assemblies: geometry and native crop bounds')

for _,s in ipairs(specs.TILESET_BATTLE_TOWER_INSIDE)do assert(s.block~=28,'walkable Battle Tower floor ornament raised into furniture')end
