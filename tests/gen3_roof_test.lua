local Shapes=assert(loadfile('lib/Gen3TileShape.lua'))()
local Roof=assert(loadfile('lib/Gen3RoofDetails.lua'))()
local c={roofType='flat',height=32,back=0,front=80,roofs=3,roofInset=12}
for z=20,80 do assert(Roof.height(c,z)==32,'lab roof acquired a pitch')end
c.roofType='gable';c.roofInset=0
assert(Roof.height(c,0)==32 and Roof.height(c,40)==45 and Roof.height(c,80)==32)
assert(Roof.height(c,20)==38.5,'gable was rounded into a barrel')
assert(Shapes.of('general','pallet_town',0x2B1).roofType=='flat')
assert(Shapes.of('general','pallet_town',0x28A).roofType=='gable')
local cells={}
for y,row in ipairs({{0x2BD,0x2B5},{0x2B3,0x2B4},{0x2BB,0x2BC}})do for x,mid in ipairs(row)do
 cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,pair='pallet_outdoor',secondary='pallet_town',column={roofType='flat',height=32}}
end end
local chimneys=Roof.prepare(cells);assert(#chimneys==1)
assert(cells['0:1'].roofMid==0x2B1 and cells['1:2'].roofMid==0x2B9,'chimney drawing remains stamped on roof')
local faces,minY,maxY=0,math.huge,0
Roof.appendChimney(chimneys[1],function(vertices)
 faces=faces+1
 for _,v in ipairs(vertices)do
  minY=math.min(minY,v[2]);maxY=math.max(maxY,v[2])
  assert(v[1]>=2 and v[1]<=19 and v[3]>=21 and v[3]<=39,'chimney escaped reviewed footprint')
 end
end,function()return {{0,0},{1,0},{1,1},{0,1}}end)
assert(faces>20 and minY==32 and maxY==52,'chimney is not grounded on the flat roof')
cells['1:2'].mid=1
assert(#Roof.prepare(cells)==0,'partial chimney match modified a floor')
local col={height=32,front=80,back=0,roofType='flat',roofInset=12,roofs=3}
local shell={['0:0']={cx=0,cy=0,pair='pallet',column=col},['1:0']={cx=1,cy=0,pair='pallet',column=col}}
assert(not Roof.sideVisible(shell,shell['0:0'],1),'internal wall fin survives')
assert(Roof.sideVisible(shell,shell['0:0'],-1),'outer wall disappeared')
shell['1:0'].column={height=48}
assert(Roof.sideVisible(shell,shell['0:0'],1),'stepped building side left open')
print('PASS flat lab, straight gables, complete chimney matching, separate shaft/cap/flue and roof grounding')
