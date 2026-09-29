-- Closed native-art volumes for Crystal rocks, sculptures and narrow displays.
local V=...
local M={}
function M.build(t,data,pr,aw,ah)
 local w,h=#t.tiles[1]*8,#t.tiles*8
 local function key(r,g,b)return math.floor(r*255+.5)*65536+math.floor(g*255+.5)*256+math.floor(b*255+.5)end
 local function pixel(tile,x,y)
  local sx,sy=tile%pr*8+x,math.floor(tile/pr)*8+y
  return sx,sy,data:getPixel(sx,sy)
 end
 local votes,bg,best={},nil,0
 for _,row in ipairs(t.groundTiles)do for _,tile in ipairs(row)do for y=0,7 do for x=0,7 do
  local _,_,r,g,b=pixel(tile,x,y);local k=key(r,g,b);votes[k]=(votes[k]or 0)+1
  if votes[k]>best then bg,best=k,votes[k]end
 end end end end
 local function at(x,y)
  return pixel(t.tiles[math.floor(y/8)+1][math.floor(x/8)+1],x%8,y%8)
 end
 local mask=V.require('SceneryMask').mask(w,function(x,y)
  local _,_,r,g,b,a=at(x,y);return a==0 or key(r,g,b)==bg
 end,h)
 local bottom=h
 for y=0,h-1 do for x=0,w-1 do if mask[y*w+x] then bottom=math.min(bottom,h-y-1)end end end
 local H=V.require('VoxelHull')
 local cards=t.modelShape=="rock" and V.require("TreePresentation").props:get()=="cards"
 local H=V.require('VoxelHull')
 -- A plinth is two masses: the pedestal it stands on, and the orb above it,
 -- with the drawing's waist between them. One hull over the crop welds the two
 -- into a single slab. Carve each half from its own sub-mask, so the gap the
 -- drawing shows is a real gap and the orb keeps its own silhouette.
 if t.modelShape=='orb_plinth' then
  -- The waist is the row the mask is thinnest at: an empty row above the
  -- pedestal top and below the orb is exactly what a plinth looks like.
  local waist,thinnest=math.floor(h/2),math.huge
  for y=0,h-1 do
   local n=0
   for x=0,w-1 do if mask[y*w+x] then n=n+1 end end
   if n>0 and n<thinnest then thinnest=n;waist=y end
  end
  local function half(y0,y1)
   if y1<=y0 then return {} end
   local hh=y1-y0
   local sub=V.require('SceneryMask').mask(w,function(x,yy)
    local _,_,r,g,b,a=at(x,y0+yy)
    return not mask[(y0+yy)*w+x] or a==0 or key(r,g,b)==bg
   end,hh)
   local base=hh
   for yy=0,hh-1 do for x=0,w-1 do if sub[yy*w+x] then base=math.min(base,hh-yy-1)end end end
   local samp=function(x,yy)
    local sx,sy,r,g,b,a=at(x,y0+yy)
    return r,g,b,sub[yy*w+x]and a or 0,(sx+.5)/aw,(sy+.5)/ah
   end
   return H.build(w,hh,samp,1,base,t.modelDepth,t.modelShape)
  end
  -- The pedestal sits on the ground; the orb stands on the pedestal, so its
  -- hull is raised by however tall the pedestal came out.
  local lower=half(waist,h)
  local pedestalH=0
  for _,q in ipairs(lower)do
   for i=1,4 do pedestalH=math.max(pedestalH,q[i][2])end
  end
  local upper=half(0,waist)
  for _,q in ipairs(upper)do
   for i=1,4 do q[i][2]=q[i][2]+pedestalH end
  end
  local faces={}
  for _,q in ipairs(lower)do faces[#faces+1]=q end
  for _,q in ipairs(upper)do faces[#faces+1]=q end
  for _,q in ipairs(faces)do
   local uv={q.u,q.v};q.uv={uv,uv,uv,uv}
   for i=1,4 do q[i][1]=q[i][1]+w/2;q[i][3]=q[i][3]+h/2 end
  end
  return faces
 end
 local sample=function(x,y)
  local sx,sy,r,g,b,a=at(x,y)
  return r,g,b,mask[y*w+x]and a or 0,(sx+.5)/aw,(sy+.5)/ah
 end
 local faces=cards and H.card(w,h,sample,bottom) or H.build(w,h,sample,1,bottom,t.modelDepth,t.modelShape)
 for _,q in ipairs(faces)do
  local uv={q.u,q.v};q.uv={uv,uv,uv,uv}
  for i=1,4 do q[i][1]=q[i][1]+w/2;q[i][3]=q[i][3]+h/2 end
 end
 return faces
end
return M
