-- Native/provider frames share one visible ground baseline. Taking the union
-- preserves authored walk/hop deltas instead of pinning each frame separately.
local M={}
local cache=setmetatable({},{__mode='k'})
local function padding(data,q)
 local x,y,w,h=q:getViewport()
 for row=y+h-1,y,-1 do
  for col=x,x+w-1 do
   local _,_,_,alpha=data:getPixel(col,row)
   if alpha>0 then return y+h-1-row end
  end
 end
 -- Blank frames do not contribute to the animation's visible union.
 return nil
end
function M.groundPadding(spr)
 if not spr then return 0 end
 -- Providers with authored anchors or cropped/immersed variants can retain
 -- their original baseline explicitly, including an intentional zero.
 local authored=tonumber(spr.groundPadding)
 if authored and authored==authored and authored>=0 and authored<512 then return authored end
 local old=cache[spr]
 if old and old.image==spr.image and old.data==spr.imageData and old.quads==spr.quads then return old.padding end
 local data,owned=spr.imageData,false
 -- Native images already expose CPU pixels. Companion sheets can instead
 -- expose a Canvas; read it once through its public API, without asset paths.
 if not data and spr.image and spr.image.newImageData then
  local ok,result=pcall(spr.image.newImageData,spr.image)
  if ok then data,owned=result,true end
 end
 local bottom
 if data and spr.quads then
  for frame=0,math.max(0,math.min(512,tonumber(spr.frameCount)or 1)-1) do
   local q=spr.quads[frame]
   if q then
    local n=padding(data,q)
    if n and (not bottom or n<bottom) then bottom=n end
   end
  end
 end
 if owned and data.release then data:release() end
 bottom=bottom or 0
 cache[spr]={image=spr.image,data=spr.imageData,quads=spr.quads,padding=bottom}
 return bottom
end
return M
