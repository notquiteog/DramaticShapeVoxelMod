-- Reviewed opaque Lilycove sculptures, carved from their complete native art.
-- Border-connected background is removed without erasing enclosed highlights.
local V=...
local M={}
local templates=setmetatable({},{__mode='k'})
local function key(r,g,b)return math.floor(r*255+.5)*65536+math.floor(g*255+.5)*256+math.floor(b*255+.5)end
function M.append(p,emit,uvFor,box,sample)
 local ts,r=p.ts,p.recipe
 if not ts.imageData then return end
 local byDrawing=templates[ts]or{};templates[ts]=byDrawing
 local id=table.concat({r.rows[1][1],r.rows[2][1]},':')
 local faces=byDrawing[id]
 if not faces then
  local pixels,edges={},{}
  for y=0,24 do
   for x=0,15 do
    local mid=r.rows[math.floor(y/16)+1][1];local slot=ts.midToSlot[mid]
    if not slot then return end
    local ax,ay=slot%ts.cols*16+x,math.floor(slot/ts.cols)*16+y%16
    local rr,gg,bb,aa=ts.imageData:getPixel(ax,ay)
    if ts.overImageData then
     local r2,g2,b2,a2=ts.overImageData:getPixel(ax,ay)
     rr,gg,bb,aa=r2*a2+rr*(1-a2),g2*a2+gg*(1-a2),b2*a2+bb*(1-a2),a2+aa*(1-a2)
    end
    local uv=uvFor(ts,mid)
    pixels[y*16+x]={rr,gg,bb,aa,uv[1][1]+(uv[2][1]-uv[1][1])*(x+.5)/16,
     uv[1][2]+(uv[3][2]-uv[1][2])*(y%16+.5)/16}
   end
   edges[y]={[key(unpack(pixels[y*16]))]=true,[key(unpack(pixels[y*16+15]))]=true}
  end
  local background
  if r.backgroundMids then
   background={}
   for _,mid in ipairs(r.backgroundMids)do
    local slot=ts.midToSlot[mid]
    if slot then for py=0,15 do for px=0,15 do
     background[key(ts.imageData:getPixel(slot%ts.cols*16+px,math.floor(slot/ts.cols)*16+py))]=true
    end end end
   end
  end
  local mask=V.require('SceneryMask').mask(16,function(x,y)
   local c=pixels[y*16+x];return c[4]<.5 or (background or edges[y])[key(unpack(c))]
  end,25)
  faces=V.require('VoxelHull').build(16,25,function(x,y)
   local c=pixels[y*16+x];return c[1],c[2],c[3],mask[y*16+x]and c[4]or 0,c[5],c[6]
  end,1,0,8)
  byDrawing[id]=faces
 end
 local x,z=p.cx*16,p.cy*16
 box(x+.5,0,z+17,x+15.5,4,z+31,sample(3,28))
 box(x+.5,4,z+17,x+15.5,5,z+31,sample(3,25))
 local base=sample(3,28)
 emit({{x+.5,0,z+31},{x+15.5,0,z+31},{x+15.5,0,z+17},{x+.5,0,z+17}},base,.65)
 for _,q in ipairs(faces)do
  local points={};for i,v in ipairs(q)do points[i]={x+8+v[1],5+v[2],z+24+v[3]}end
  local uv={q.u,q.v};emit(points,{uv,uv,uv,uv},q.shade)
 end
end
return M
