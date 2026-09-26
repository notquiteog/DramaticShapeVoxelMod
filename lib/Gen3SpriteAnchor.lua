-- Ground visible feet in each frame. Gameplay supplies jumps/flight separately;
-- transparent animation padding is not a world-space height.
local V=...
local Eye=V and V.require('CameraEye') or dofile((os.getenv('DS_MOD_PATH')or '.')..'/lib/CameraEye.lua')
local M={}
local cache=setmetatable({},{__mode='k'})
local function padding(data,q)
 local x,y,w,h=q:getViewport()
 for row=y+h-1,y,-1 do
  for col=x,x+w-1 do
   local _,_,_,alpha=data:getPixel(col,row)
   if alpha>=.5 then return y+h-1-row end
  end
 end
 -- Blank frames do not contribute to the animation's visible union.
 return nil
end
local function scan(spr)
 if not spr then return {padding=0,frames={}} end
 local old=cache[spr]
 if old and old.image==spr.image and old.data==spr.imageData and old.quads==spr.quads then return old end
 local data,owned=spr.imageData,false
 -- Native images already expose CPU pixels. Companion sheets can instead
 -- expose a Canvas; read it once through its public API, without asset paths.
 if not data and spr.image and spr.image.newImageData then
  local ok,result=pcall(spr.image.newImageData,spr.image)
  if ok then data,owned=result,true end
 end
 local bottom,frames=nil,{}
 if data and spr.quads then
  for frame=0,math.max(0,math.min(512,tonumber(spr.frameCount)or 1)-1) do
   local q=spr.quads[frame]
   if q then
    local n=padding(data,q)
    frames[frame]=n
    if n and (not bottom or n<bottom) then bottom=n end
   end
  end
 end
 if owned and data.release then data:release() end
 bottom=bottom or 0
 cache[spr]={image=spr.image,data=spr.imageData,quads=spr.quads,padding=bottom,frames=frames}
 return cache[spr]
end
local function valid(n)
 n=tonumber(n);return n and n==n and n>=0 and n<512 and n or nil
end
function M.groundPadding(spr)
 return valid(spr and spr.groundPadding) or scan(spr).padding
end
function M.framePadding(spr,frame)
 local authored=spr and spr.groundPaddingByFrame
 local n=authored and valid(authored[frame])
 if n then return n end
 n=valid(spr and spr.groundPadding);if n then return n end
 local entry=scan(spr)
 return entry.frames[frame] or entry.padding
end
function M.eyeHeight(spr)
 local q=spr and spr.quads and spr.quads[0]
 local h=32
 if q then local _,_,_,height=q:getViewport();h=height end
 -- Frame-zero anchoring remains stable
 -- through running, turns and attack/field poses. No extra pixel readback.
 return Eye.height(3,h,h-M.framePadding(spr,0),spr and spr.firstPersonEyeRow)
end
return M
