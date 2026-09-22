local M=assert(loadfile('lib/TreeIllustrations.lua'))()
local data={pixels={}}
function data:getDimensions()return 20,20 end
function data:getPixel(x,y)return .5,.6,.2,self.pixels[y*20+x] or 0 end
function data:setPixel(x,y,r,g,b,a)self.pixels[y*20+x]=a end
for row=0,1 do for col=0,1 do
 for y=2,7 do for x=3,7 do data:setPixel(col*10+x,row*10+y,1,1,1,1)end end
 data:setPixel(col*10,row*10+3,1,1,1,1)
end end
M.isolate(data)
for row=0,1 do for col=0,1 do
 local _,_,_,a=data:getPixel(col*10,row*10+3);assert(a==0,'neighboring crown fragment survives')
 local _,_,_,b=data:getPixel(col*10+5,row*10+5);assert(b==1,'main illustration was damaged')
end end
local Trees=assert(loadfile('lib/Gen2Trees.lua'))()
local Leaves=assert(loadfile('lib/Gen2DepthTrees.lua'))()
local wood,wi,leaf,li={},{},{},{}
Trees.appendFlatTrunk(wood,wi,0,4,0,9,20,73)
Leaves.append(leaf,li,0,4,0,9,20,73,'broadleaf',true)
for _,v in ipairs(wood)do assert(v[7]==4 and v[8]==9 and v[9]==.001 and v[3]<9,'flat trunk lost common anchor or depth separation')end
for _,v in ipairs(leaf)do assert(v[7]==4 and v[8]==9 and v[9]==.001 and v[3]==9,'foliage is not in front of its flat trunk')end
print('PASS isolated foliage silhouettes and shared flat-trunk/card anchors with separated depth')
