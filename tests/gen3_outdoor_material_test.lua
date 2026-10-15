local made,uploads,released,dataMade,dataReleased=0,0,0,0,0
local function data(w,h)
 dataMade=dataMade+1
 local d={w=w,h=h,px={}}
 function d:getDimensions()return self.w,self.h end
 function d:getPixel(x,y)local p=self.px[y*self.w+x];if p then return unpack(p)end;return .2,.3,.2,1 end
 function d:setPixel(x,y,r,g,b,a)self.px[y*self.w+x]={r,g,b,a}end
 function d:paste(src,dx,dy,sx,sy,sw,sh)
  for y=0,sh-1 do for x=0,sw-1 do self:setPixel(dx+x,dy+y,src:getPixel(sx+x,sy+y))end end
 end
 function d:clone()local n=data(self.w,self.h);n:paste(self,0,0,0,0,self.w,self.h);return n end
 function d:release()assert(not self.dead);self.dead=true;dataReleased=dataReleased+1 end
 return d
end
love={graphics={newImage=function(d)
 made=made+1;local image={}
 local function copy(src)local r,g,b,a=src:getPixel(16,0);image.corner={r,g,b,a};r,g,b,a=src:getPixel(18,2);image.center={r,g,b,a}end
 copy(d)
 function image:replacePixels(src)assert(not self.dead);uploads=uploads+1;copy(src)end
 function image:setFilter()end
 function image:release()assert(not self.dead);self.dead=true;released=released+1 end
 return image
end}}
local V={require=function(n)
 if n=='SceneryMask'then return dofile('lib/SceneryMask.lua')
 elseif n=='Gen3Tilesets'then return {canonical=function(p)return p end}
 elseif n=='Gen3Furniture'then return {cutouts=function()return {[1]=0}end}end
 error(n)
end}
local O=assert(loadfile('lib/Gen3Outdoor.lua'))(V)
local ts={pair='test',cols=2,rows=1,midToSlot={[0]=0,[1]=1},imageData=data(32,16)}
ts.imageData:setPixel(18,2,.8,.1,.1,1)
local image=O.image(ts,0)
assert(image.center[4]==1 and image.corner[4]==0 and made==1)
assert(O.image(ts,0)==image and uploads==0)
-- Repaint in-place, including a previously removed corner. Reusing scratch
-- pixels must not carry the preceding frame's transparency into this one.
ts.imageData:setPixel(16,0,.8,.1,.1,1);ts.imageData:setPixel(18,2,.2,.3,.2,1)
assert(O.image(ts,1)==image and uploads==1 and made==1)
assert(image.corner[4]==1 and image.center[4]==0,'animated material kept old alpha')
for frame=2,60 do assert(O.image(ts,frame)==image)end
assert(made==1 and dataMade==2,'animation allocated new atlases')
-- Source replacement in the same time step still invalidates the material.
ts.imageData=data(32,16);local nextImage=O.image(ts,60)
assert(nextImage~=image and image.dead and dataReleased==1)
nextImage.replacePixels=function()error('unsupported backend')end
local fallback=O.image(ts,61);assert(fallback~=nextImage and nextImage.dead)
O.release();O.release();assert(fallback.dead and released==made and dataReleased==2)
print('PASS animated pixels/alpha, 60-frame GPU/CPU reuse, provider replacement, upload fallback and exact cleanup')
