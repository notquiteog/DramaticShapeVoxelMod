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
   local q=Plant.build(t,{getPixel=function()return .5,.5,.5,1 end},16,128,128)
   assert(#q>0 and #q<=70,'planter budget')
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
