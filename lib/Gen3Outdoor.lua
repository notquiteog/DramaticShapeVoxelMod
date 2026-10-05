-- Reviewed General outdoor metatiles. Geometry changes presentation only;
-- native map collision, ledge jumps and field interactions remain untouched.
local V=...
local M={}
local Mask=V and V.require("SceneryMask") or assert(loadfile("lib/SceneryMask.lua"))()
-- Each cutout keeps the palette of its actual ground. Saffron's board
-- spans shaded paving and pale paving, rather than the General grass swatch.
local plants={[4]=1,[5]=1,[0xD]=1,[0x160]=1,[0x168]=1,[0x304]=0x2E5,[0x30C]=0x2E9}
local function sub(uv,l,t,r,b)
 local function p(x,y)return {uv[1][1]+(uv[2][1]-uv[1][1])*x/16,uv[1][2]+(uv[3][2]-uv[1][2])*y/16}end
 return {p(l,t),p(r,t),p(r,b),p(l,b)}
end
local function pixel(ts,x,y)
 local r,g,b,a=ts.imageData:getPixel(x,y)
 if ts.overImageData then local rr,gg,bb,aa=ts.overImageData:getPixel(x,y)
  r,g,b,a=rr*aa+r*(1-aa),gg*aa+g*(1-aa),bb*aa+b*(1-aa),aa+a*(1-aa)
 end
 return r,g,b,a
end
local function colorKey(r,g,b)return math.floor(r*255+.5)*65536+math.floor(g*255+.5)*256+math.floor(b*255+.5)end
function M.mask(ts,mid,ground)
 local floor={};local slot=ts.midToSlot[ground]
 if not slot then return end
 for y=0,15 do for x=0,15 do
  floor[colorKey(pixel(ts,slot%ts.cols*16+x,math.floor(slot/ts.cols)*16+y))]=true
 end end
 local at=ts.midToSlot[mid];if not at then return end
 return Mask.mask(16,function(x,y)
  local r,g,b,a=pixel(ts,at%ts.cols*16+x,math.floor(at/ts.cols)*16+y)
  return a==0 or floor[colorKey(r,g,b)]
 end)
end
function M.plant(c,emit,uv)
 -- One complete, flat native drawing. Shared canopy anchors preserve the
 -- authored angle in static views and face free/battle cameras without
 -- bending, inflating, or duplicating the artwork.
 local x,z=c.cx*16,c.cy*16
 if c.shape.kind=='shrub' and V.require('TreePresentation').props:get()=='modeled' then
  local mask=M.mask(c.ts,c.mid,c.shape.ground);local slot=c.ts.midToSlot[c.mid]
  if mask and slot then
   local faces=V.require('VoxelHull').build(16,16,function(px,py)
    local r,g,b,a=pixel(c.ts,slot%c.ts.cols*16+px,math.floor(slot/c.ts.cols)*16+py)
    local t=sub(uv,px+.5,py+.5,px+.5,py+.5)[1]
    return r,g,b,mask[py*16+px] and a or 0,t[1],t[2]
   end,1,0,nil,'bush')
   for _,q in ipairs(faces)do
    local p={};for _,v in ipairs(q)do p[#p+1]={x+8+v[1],v[2],z+8+v[3]}end
    local t={q.u,q.v};emit(p,{t,t,t,t},q.shade)
   end
   return true
  end
 end
 local h=c.shape.kind=='grass' and 4 or 16
 if c.shape.kind=='grass' then
  -- Keep the original patch spread across its full ground area; lowering
  -- only the upright card collapses a meadow into separated green stripes.
  emit({{x,.025,z},{x+16,.025,z},{x+16,.025,z+16},{x,.025,z+16}},uv,1)
 end
 local points={{x,h,z+8},{x+16,h,z+8},{x+16,.001,z+8},{x,.001,z+8}}
 local anchor={x+8,z+8,.001}
 if V and c.shape.kind=='grass'then
  local transform,center=V.require('NativeGrassStyle').transform(x,z,16)
  if transform then for i,p in ipairs(points)do points[i]=transform(p)end;anchor=center end
 end
 emit(points,uv,1,anchor)
 return true
end
function M.append(c,emit,uvFor)
 local s,x,z=c.shape,c.cx*16,c.cy*16
 local uv=assert(uvFor(c.ts,c.mid))
 if s.kind=='ledge' and s.direction and s.direction~='south' then
  local original=emit
  local function rotate(a,b)
   if s.direction=='east'then return b,16-a
   elseif s.direction=='west'then return 16-b,a
   else return 16-a,16-b end
  end
  emit=function(points,tex,shade)
   local q,t={},{}
   for i,p in ipairs(points)do
    local xx,zz=rotate(p[1]-x,p[3]-z);q[i]={x+xx,p[2],z+zz}
    local u=(tex[i][1]-uv[1][1])/(uv[2][1]-uv[1][1])*16
    local v=(tex[i][2]-uv[1][2])/(uv[3][2]-uv[1][2])*16
    u,v=rotate(u,v)
    t[i]={uv[1][1]+u/16*(uv[2][1]-uv[1][1]),uv[1][2]+v/16*(uv[3][2]-uv[1][2])}
   end
   original(q,t,shade)
  end
 end
 local function box(x0,y0,z0,x1,y1,z1,tex)
  emit({{x0,y1,z0},{x1,y1,z0},{x1,y1,z1},{x0,y1,z1}},tex,1)
  emit({{x0,y1,z1},{x1,y1,z1},{x1,y0,z1},{x0,y0,z1}},tex,.85)
  emit({{x1,y1,z0},{x0,y1,z0},{x0,y0,z0},{x1,y0,z0}},tex,.72)
  emit({{x0,y1,z0},{x0,y1,z1},{x0,y0,z1},{x0,y0,z0}},tex,.78)
  emit({{x1,y1,z1},{x1,y1,z0},{x1,y0,z0},{x1,y0,z1}},tex,.9)
 end
 if s.kind=='sign' then
  if V.require('NativeLegendarySigns').draw(c,emit,uv)then return true end
  if s.hoenn then
   local white,blue=sub(uv,3,6,3,6),sub(uv,5,8,5,8)
   for _,px in ipairs({2,12})do box(x+px,0,z+6,x+px+2,8,z+10,white)end
   box(x+1,5,z+6.5,x+15,12,z+9.5,white)
   box(x+3,6,z+6.45,x+13,10,z+6.5,blue)
   emit({{x+2,11,z+9.52},{x+14,11,z+9.52},{x+14,5,z+9.52},{x+2,5,z+9.52}},sub(uv,2,5,14,13),1)
   return true
  end
  local trim=sub(uv,3,3,4,4)
  box(x+6.7,0,z+7.3,x+9.3,6,z+9.3,trim)
  box(x+1,5,z+7.6,x+15,12,z+9.2,trim)
  emit({{x+1,12,z+9.23},{x+15,12,z+9.23},{x+15,5,z+9.23},{x+1,5,z+9.23}},sub(uv,1,2,15,12),1)
 elseif s.kind=='fence' then
  -- Fence drawings partially covered by a tree must keep their green
  -- ground artwork, without leaving a second flat metal fence underneath.
  if s.coveredGround and c.ts.imageData then
   local at,ref=c.ts.midToSlot[c.mid],c.ts.midToSlot[0xE7]
   if at and ref then
    local colors={}
    for py=0,15 do for px=0,15 do colors[colorKey(pixel(c.ts,ref%c.ts.cols*16+px,math.floor(ref/c.ts.cols)*16+py))]=true end end
    for py=0,15 do
     local start
     for px=0,16 do
      local keep=px<16 and not colors[colorKey(pixel(c.ts,at%c.ts.cols*16+px,math.floor(at/c.ts.cols)*16+py))]
      if keep and not start then start=px end
      if not keep and start then
       emit({{x+start,.015,z+py},{x+px,.015,z+py},{x+px,.015,z+py+1},{x+start,.015,z+py+1}},sub(uv,start,py,px,py+1),1)
       start=nil
      end
     end
    end
   end
  end
  local vertical=s.axis and not s.turn
  local post=uvFor(c.ts,s.material or (s.wood and 0xE6 or 0xE7)) or uv
  local face,cap=sub(post,3,6,6,14),sub(post,3,3,6,6)
  local rail=sub(post,3,9,5,11)
  if s.postSample then
   local px,py=unpack(s.postSample)
   face=sub(post,px,py,px+.1,py+.1);cap=face;rail=face
  end
  if s.postSamples then
   local function sample(p)return sub(post,p[1],p[2],p[1]+.1,p[2]+.1)end
   face=sample(s.postSamples.face);cap=sample(s.postSamples.cap);rail=sample(s.postSamples.rail)
  end
  local h=s.height or 10
  local half=(s.postWidth or 2.8)/2
  local function stake(px,pz)
   box(px-half,0,pz-half,px+half,h,pz+half,face)
   box(px-half-.1,h,pz-half-.1,px+half+.1,h+.6,pz+half+.1,cap)
  end
  if vertical then
   for _,dz in ipairs(s.stop and {8} or {4,12})do stake(x+s.axis,z+dz)end
   for _,h in ipairs(s.rails or {h*.3,h*.7})do box(x+s.axis-.6,h,z+(s.stop=='south' and 8 or 0),x+s.axis+.6,h+1,z+(s.stop and s.stop~='south' and 8 or 16),rail)end
  else
   for _,dx in ipairs({4,12})do stake(x+dx,z+8)end
   for _,h in ipairs(s.rails or {h*.3,h*.7})do
    box(x,h,z+7.4,x+16,h+1,z+8.6,rail)
    if s.turn then box(x+s.axis-.6,h,z+(s.turn=='north' and 0 or 8),x+s.axis+.6,h+1,z+(s.turn=='north' and 8 or 16),rail)end
   end
  end
 elseif s.kind=='ledge' then
  -- A low turf mound with a thin exposed dirt edge, never a tall block.
  -- The sand/grass transition is painted into each native cap. C0/C1
  -- and C8/C9 are material transitions along a continuous ledge, not ends.
  -- Keep those pixels on both the approach and the raised cap.
  emit({{x,.01,z},{x+16,.01,z},{x+16,.01,z+9},{x,.01,z+9}},sub(uv,0,0,16,7),1)
  local function height(u,v)
   local endScale=(s.left and math.min(1,u/5) or s.right and math.min(1,(16-u)/5) or 1)
   return 2.5*math.sin(math.min(1,math.max(0,(v-9)/7))*math.pi*.5)*endScale
  end
  for ix=0,3 do for iz=0,2 do
   local a,b=ix*4,(ix+1)*4;local p,q=9+iz*7/3,9+(iz+1)*7/3
   emit({{x+a,height(a,p),z+p},{x+b,height(b,p),z+p},{x+b,height(b,q),z+q},{x+a,height(a,q),z+q}},sub(uv,a,(p-9),b,(q-9)),1)
  end end
  for ix=0,3 do local a,b=ix*4,(ix+1)*4
   emit({{x+a,height(a,16),z+16},{x+b,height(b,16),z+16},{x+b,0,z+16},{x+a,0,z+16}},sub(uv,a,10,b,16),.85)
  end
  for _,u in ipairs({0,16})do
   emit({{x+u,0,z+9},{x+u,height(u,16),z+16},{x+u,0,z+16},{x+u,0,z+9}},sub(uv,2,10,5,16),.8)
  end
 elseif s.kind=='flowers' or s.kind=='grass' or s.kind=='shrub' then
  M.plant(c,emit,uv)
 end
end
-- Derive cutouts from the provider's composited art, removing exact colours
-- from its reviewed ground swatch. Never ship or read private imported pixels.
local images={}
function M.image(ts,frame)
 local old=images[ts.pair];if old and old.ts==ts and old.frame==frame then return old.image end
 if not ts.imageData then return end
 local data=ts.imageData:clone()
 local masks={}
 local artPair=V.require('Gen3Tilesets').canonical(ts.pair)
 masks=V.require('Gen3Furniture').cutouts(artPair)
 if not next(masks)then masks=V.require('Gen3Hoenn').active() and {[4]=1,[0xd]=1,[0x15]=1} or plants end
 for mid,ground in pairs(masks)do
  local mask=M.mask(ts,mid,ground)
  local at=ts.midToSlot[mid]
  if mask and at then for y=0,15 do for x=0,15 do
   local px,py=at%ts.cols*16+x,math.floor(at/ts.cols)*16+y
   local r,g,b,a=pixel(ts,px,py)
   if not mask[y*16+x]then a=0 end
   data:setPixel(px,py,r,g,b,a)
  end end end
 end
 local img=love.graphics.newImage(data);img:setFilter('nearest','nearest');data:release()
 if old then old.image:release()end;images[ts.pair]={ts=ts,image=img,frame=frame};return img
end
function M.release()
 for _,p in pairs(images)do p.image:release()end;images={}
end
return M
