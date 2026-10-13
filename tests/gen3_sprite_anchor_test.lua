local A=dofile('lib/Gen3SpriteAnchor.lua')
local pixels=0
local function quad(y)return {getViewport=function()return 0,y,16,16 end}end
local spr={quads={[0]=quad(0),[1]=quad(16),[2]=quad(32)},frameCount=3,imageData={}}
function spr.imageData:getPixel(x,y)
 pixels=pixels+1
 -- Standing bottom row13, walking row14, then an entirely blank frame.
 return 0,0,0,(x>=3 and x<=12 and(y>=5 and y<=13 or y>=21 and y<=30))and 1 or 0
end
assert(A.groundPadding(spr)==1,'union failed to use lowest visible animation baseline')
local reads=pixels;assert(A.groundPadding(spr)==1 and pixels==reads,'sprite anchor was not cached')
assert(16-1-13-A.groundPadding(spr)==1,'standing lift relative to walking was erased')
assert(16-1-14-A.groundPadding(spr)==0,'walking foot does not touch baseline')
assert(A.groundPadding({})==0,'provider without CPU pixels lost native anchor')
local readsCanvas,releases=0,0
local canvas={newImageData=function()
 readsCanvas=readsCanvas+1
 return {getPixel=function(_,x,y)return 0,0,0,y==11 and 1 or 0 end,release=function()releases=releases+1 end}
end}
local provider={image=canvas,quads={[0]=quad(0)},frameCount=1}
assert(A.groundPadding(provider)==4 and readsCanvas==1 and releases==1,'Canvas pixel snapshot missing or retained')
assert(A.groundPadding(provider)==4 and readsCanvas==1,'Canvas snapshot repeated per draw')
provider.groundPadding=0;assert(A.groundPadding(provider)==0,'authored zero baseline was ignored')
provider.groundPadding=2;assert(A.groundPadding(provider)==2,'masked provider did not retain original baseline')
provider.groundPadding=nil;provider.image={}
assert(A.groundPadding(provider)==0,'replacement provider image reused stale alpha bounds')
local blank={quads={[0]=quad(0)},imageData={getPixel=function()return 0,0,0,0 end}}
assert(A.groundPadding(blank)==0,'empty art must retain its native anchor')
-- Geometry only subtracts padding in local card space. Explicit world-space
-- jump/fly/support heights therefore survive, instead of being clamped to0.
local Mat=dofile('lib/Mat4.lua');local pad=A.groundPadding(spr)
for _,lift in ipairs({0,4,9.12,36,96})do
 local m=Mat.mul(Mat.translate(20,lift,30),Mat.rotateX(-.4))
 local visibleY=16-1-14-pad -- lowest opaque frame edge after union padding
 local height=m[6]*visibleY+m[8]
 assert(math.abs(height-lift)<.00001,'authored jump/ride/support height changed')
end
print('PASS animation-union anchors, Canvas snapshot/cache/release, authored baselines and explicit height offsets')
assert(A.playerLift({spriteYOffset=-7,jumpSpriteY=function()return -7 end})==7,'native jump lift counted twice')
assert(A.playerLift({spriteYOffset=0,jumpSpriteY=function()return -7 end})==0,'native resting offset must win')
assert(A.playerLift({jumpSpriteY=function()return -7 end})==7,'legacy jump-only provider lost its arc')
assert(A.playerLift({spriteYOffset=2})==-2,'surf bob may descend below baseline')
-- GPU-only LOVE Images have no newImageData method. Snapshot once into a
-- temporary Canvas; preserve graphics state and release both owned objects.
local copies,pushes,pops,freed,now=0,0,0,0,0
love={timer={getTime=function()return now end},graphics={}}
local gfx=love.graphics
for _,name in ipairs{'setCanvas','origin','setShader','setScissor','setColor','setBlendMode','clear','draw'}do gfx[name]=function()end end
gfx.push=function()pushes=pushes+1 end;gfx.pop=function()pops=pops+1 end
gfx.newCanvas=function()copies=copies+1;return {newImageData=function()return {getPixel=function(_,x,y)return 0,0,0,y%16==10 and 1 or 0 end,release=function()freed=freed+1 end}end,release=function()freed=freed+1 end}end
local gpu={image={getDimensions=function()return 16,32 end},quads={[0]=quad(0),[1]=quad(16)}}
assert(A.framePadding(gpu,1)==5,'GPU-only provider missing inferred frame padding')
assert(A.framePadding(gpu,1)==5 and copies==1 and freed==2 and pushes==pops,'readback must be cached and graphics state restored')
local attempts=0;gfx.newCanvas=function()attempts=attempts+1;error('stream not ready')end
local pending={image={getDimensions=function()return 16,16 end},quads={[0]=quad(0)}}
assert(A.framePadding(pending,0)==0 and A.framePadding(pending,0)==0 and attempts==1,'failed GPU readback needs debounce')
now=2;A.framePadding(pending,0);assert(attempts==2,'streaming failure was cached forever')
print('PASS GPU-only images, inferred frames, cached readback, retry debounce and single native jump arc')
