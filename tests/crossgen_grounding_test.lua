local A=dofile('lib/Gen3SpriteAnchor.lua')
local reads,released=0,0
local spr={frameCount=3,quads={}}
for f=0,2 do spr.quads[f]={getViewport=function()return 0,f*4,4,4 end}end
spr.image={newImageData=function()
 reads=reads+1
 return {getPixel=function(_,x,y)return 1,1,1,x==2 and y%4==({1,3,2})[math.floor(y/4)+1]and 1 or 0 end,release=function()released=released+1 end}
end}
for f=0,2 do assert(A.framePadding(spr,f)==({2,0,1})[f+1])end
assert(reads==1 and released==1,'per-frame anchors must share a single cached readback')
spr.groundPadding=0;assert(A.framePadding(spr,0)==0,'authored zero is intentional')
spr.groundPaddingByFrame={[0]=2};assert(A.framePadding(spr,0)==2,'masked art must retain original per-frame anchor')
local source={getDimensions=function()return 4,12 end,getPixel=function(_,x,y)return y%4==({1,3,2})[math.floor(y/4)+1]and 0 or 1,0,0,1 end}
package.loaded['src.render.Assets']={imageData=function()return source end,image=function()return source end,register=function()end}
local V={require=function()return{pushQuad=function()end,newMesh=function(v)return v end}end}
local B=assert(loadfile('lib/SpriteBillboards.lua'))(V)
local d={image='test',frameWidth=4,frameHeight=4}
for f=0,2 do
 local foot=({1,3,2})[f+1]+1
 assert(B.frameAnchor(d,f)==foot,'GB color-zero pixels must not set foot anchor')
 assert(B.mesh(d,f)[1][2]==foot-4,'GB mesh feet do not match native alpha/keyed footprint')
end
d.anchorY=4;assert(B.mesh(d,0)[1][2]==0,'authored provider anchor lost')
d.anchorY=nil;assert(B.mesh(d,0,3)[1][2]==-1,'furniture anchor lost')
print('PASS shared GB/native frame grounding, cache, masks, explicit anchors')
