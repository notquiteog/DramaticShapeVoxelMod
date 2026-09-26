local uploads=0
local function data(w,h)
 local pixels={}
 return {setPixel=function(_,x,y,r,g,b,a)pixels[y*w+x]={r,g,b,a}end,
 getPixel=function(_,x,y)return unpack(pixels[y*w+x] or {0,0,0,0})end}
end
love={image={newImageData=data},graphics={newImage=function(d)
 return {setFilter=function()end,replacePixels=function()uploads=uploads+1 end,data=d}
end}}
local Mask=dofile('lib/SceneryMask.lua')
local native=assert(loadfile('lib/NativeTreeArt.lua'))({require=function(n)if n=='VoxelHull'then return dofile('lib/VoxelHull.lua')end;if n=='CommunityVisuals'then return {treeDetail={get=function()return 'balanced'end}}end;assert(n=='SceneryMask');return Mask end})
local ts={cols=16,rows=3,midToSlot={}}
for _,id in ipairs({1,14,15,28,29,36,37})do ts.midToSlot[id]=id end
local reads=0
function tsPixel(_,x,y)
 reads=reads+1
 local mid=math.floor(y/16)*16+math.floor(x/16)
 if mid==1 then return .8,.9,.6,1 end
 -- Ground is connected to every border; enclosed bright highlights survive.
 if x%16==0 or y%16==0 or x%16==15 or y%16==15 then return .8,.9,.6,1 end
 if x%16==7 and y%16==7 then return .8,.9,.6,1 end
 return .1,.4,.1,1
end
ts.imageData={getPixel=tsPixel}
local c=native.gen3({ts=ts,mid=20,shape={ground=1}})
assert(c.w==32 and c.h==48,'complete tree lost its original cap/middle/base')
local image=native.image();local px,py=c.u0*2048,c.v0*2048
local _,_,_,a=image.data:getPixel(px,py);assert(a==0,'tree kept a square ground backing')
local _,_,_,inside=image.data:getPixel(px+7,py+7);assert(inside==1,'enclosed leaf highlight erased')
local v,i={},{};assert(native.append(c,v,i,0,12,3,18,true)==1)
assert(#v==4 and #i==6 and v[1][2]+c.bottom==3 and v[3][2]==51-c.bottom)
for _,p in ipairs(v)do assert(p[7]==12 and p[8]==18 and p[9]==3.001,'billboard lost its ground anchor')end
assert(native.gen3({ts=ts,mid=36,shape={ground=1}})==c,'dense cropped tree and complete tree used different art')
local old=reads;assert(native.gen3({ts=ts,mid=20,shape={ground=1}})==c)
assert(reads-old==256,'cached tree re-read its sprite pixels')
local copied={cols=16,rows=3,midToSlot=ts.midToSlot,imageData={getPixel=tsPixel}}
assert(native.gen3({ts=copied,mid=20,shape={ground=1}})==c,'identical maps consumed duplicate atlas slots')
native.image();assert(uploads==0,'identical source art forced an atlas upload')
local forestIds={1,641,648,649,650,656,657,658,672,673,674,675,676,677}
for _,id in ipairs(forestIds)do ts.midToSlot[id]=id end
local forest=native.gen3({ts=ts,mid=676,shape={ground=1,spacing=3}})
assert(forest~=c and forest.w==48 and forest.h==80,'forest lost its crown row or reused the general atlas key')
local fv,fi={},{};native.append(forest,fv,fi,0,0,0,0,true)
assert(fv[1][2]+forest.bottom==0,'transparent shadow padding made the tree float')
local mv,mi={},{};native.appendModel(c,mv,mi,0,12,3,18)
assert(#mv>24 and #mi>36,'native tree was left a card')
for _,p in ipairs(mv)do assert(p[9]==0,'voxel tree billboards');assert(p[2]>=3,'voxel tree below ground')end
print('PASS original tree proportions, transparent ground, preserved highlights, camera anchors and palette-content deduplication')
