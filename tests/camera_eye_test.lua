local E=dofile('lib/CameraEye.lua')
assert(E.height(1,16,16)==12 and E.height(2,16,16)==12,'GB eyes must be below the hat')
assert(E.height(3,32,31)==13.5,'FRLG transparent padding must not raise the camera')
assert(E.height(2,32,32)==24,'larger provider art must scale its eye row')
assert(E.height(3,32,30,20)==10,'authored eye row/foot anchor ignored')
local A=dofile('lib/Gen3SpriteAnchor.lua');local reads=0
local spr={frameCount=2,quads={
 [0]={getViewport=function()return 0,0,16,32 end},
 [1]={getViewport=function()return 0,32,16,32 end}},imageData={getPixel=function(_,x,y)
 reads=reads+1;return 0,0,0,(y==30 or y==60)and 1 or 0 end}}
assert(A.eyeHeight(spr)==13.5);local n=reads
for i=1,60 do assert(A.eyeHeight(spr)==13.5)end
assert(reads==n,'eye placement rescanned art every frame')
spr.firstPersonEyeRow=20;assert(A.eyeHeight(spr)==11)
print('PASS GB/FRLG eyes, padded feet, provider eye row and stable cached placement')
