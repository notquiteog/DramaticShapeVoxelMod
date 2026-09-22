-- Reviewed General outdoor metatiles. Geometry changes presentation only;
-- native map collision, ledge jumps and field interactions remain untouched.
local M={}
-- Each cutout keeps the palette of its actual ground. Saffron's board
-- spans shaded paving and pale paving, rather than the General grass swatch.
local plants={[4]=1,[5]=1,[0xD]=1,[0x160]=1,[0x168]=1,[0x304]=0x2E5,[0x30C]=0x2E9}
local function sub(uv,l,t,r,b)
 local function p(x,y)return {uv[1][1]+(uv[2][1]-uv[1][1])*x/16,uv[1][2]+(uv[3][2]-uv[1][2])*y/16}end
 return {p(l,t),p(r,t),p(r,b),p(l,b)}
end
function M.append(c,emit,uvFor)
 local s,x,z=c.shape,c.cx*16,c.cy*16
 local uv=assert(uvFor(c.ts,c.mid))
 local function box(x0,y0,z0,x1,y1,z1,tex)
  emit({{x0,y1,z0},{x1,y1,z0},{x1,y1,z1},{x0,y1,z1}},tex,1)
  emit({{x0,y1,z1},{x1,y1,z1},{x1,y0,z1},{x0,y0,z1}},tex,.85)
  emit({{x1,y1,z0},{x0,y1,z0},{x0,y0,z0},{x1,y0,z0}},tex,.72)
  emit({{x0,y1,z0},{x0,y1,z1},{x0,y0,z1},{x0,y0,z0}},tex,.78)
  emit({{x1,y1,z1},{x1,y1,z0},{x1,y0,z0},{x1,y0,z1}},tex,.9)
 end
 if s.kind=='sign' then
  local trim=sub(uv,3,3,4,4)
  box(x+6.7,0,z+7.3,x+9.3,6,z+9.3,trim)
  box(x+1,5,z+7.6,x+15,12,z+9.2,trim)
  emit({{x+1,12,z+9.23},{x+15,12,z+9.23},{x+15,5,z+9.23},{x+1,5,z+9.23}},sub(uv,1,2,15,12),1)
 elseif s.kind=='fence' then
  local vertical=s.axis and not s.turn
  local post=uvFor(c.ts,s.wood and 0xE6 or 0xE7) or uv
  local face,cap=sub(post,3,6,6,14),sub(post,3,3,6,6)
  local rail=sub(post,3,9,5,11)
  local function stake(px,pz)
   box(px-1.4,0,pz-1.4,px+1.4,10,pz+1.4,face)
   box(px-1.5,10,pz-1.5,px+1.5,10.6,pz+1.5,cap)
  end
  if vertical then
   for _,dz in ipairs(s.stop and {8} or {4,12})do stake(x+s.axis,z+dz)end
   for _,h in ipairs({3,7})do box(x+s.axis-.6,h,z,x+s.axis+.6,h+1,z+(s.stop and 8 or 16),rail)end
  else
   for _,dx in ipairs({4,12})do stake(x+dx,z+8)end
   for _,h in ipairs({3,7})do
    box(x,h,z+7.4,x+16,h+1,z+8.6,rail)
    if s.turn then box(x+s.axis-.6,h,z+(s.turn=='north' and 0 or 8),x+s.axis+.6,h+1,z+(s.turn=='north' and 8 or 16),rail)end
   end
  end
 elseif s.kind=='ledge' then
  -- A low turf mound with a thin exposed dirt edge, never a tall block.
  local ground=uvFor(c.ts,s.ground) or uv
  local function height(u,v)
   local endScale=(s.left and math.min(1,u/5) or s.right and math.min(1,(16-u)/5) or 1)
   return 2.5*math.sin(math.min(1,math.max(0,(v-9)/7))*math.pi*.5)*endScale
  end
  for ix=0,3 do for iz=0,2 do
   local a,b=ix*4,(ix+1)*4;local p,q=9+iz*7/3,9+(iz+1)*7/3
   emit({{x+a,height(a,p),z+p},{x+b,height(b,p),z+p},{x+b,height(b,q),z+q},{x+a,height(a,q),z+q}},sub(ground,a,p,b,q),1)
  end end
  for ix=0,3 do local a,b=ix*4,(ix+1)*4
   emit({{x+a,height(a,16),z+16},{x+b,height(b,16),z+16},{x+b,0,z+16},{x+a,0,z+16}},sub(uv,a,10,b,16),.85)
  end
  for _,u in ipairs({0,16})do
   emit({{x+u,0,z+9},{x+u,height(u,16),z+16},{x+u,0,z+16},{x+u,0,z+9}},sub(uv,2,10,5,16),.8)
  end
 elseif s.kind=='flowers' or s.kind=='grass' then
  -- Sloped rosettes retain their full silhouette from elevated views. Short
  -- upright crosses collapse into distracting plus signs in the static camera.
  local h=s.kind=='flowers' and 5 or 3.5
  emit({{x+1,h,z+2},{x+15,h,z+2},{x+15,.3,z+15},{x+1,.3,z+15}},uv,1)
 else
  -- Short crossed cutouts provide depth from every view. Only the native
  -- flower/leaf art survives the ground-colour mask; no square grass card.
  local h=s.height;local w=s.kind=='shrub' and 13 or 14
  for _,angle in ipairs({0,math.pi*.5})do
   local dx,dz=math.cos(angle)*w*.5,math.sin(angle)*w*.5
   emit({{x+8-dx,h,z+8-dz},{x+8+dx,h,z+8+dz},{x+8+dx,0,z+8+dz},{x+8-dx,0,z+8-dz}},uv,1)
  end
 end
end
-- Derive cutouts from the provider's composited art, removing exact colours
-- from its reviewed ground swatch. Never ship or read private imported pixels.
local images={}
function M.image(ts,frame)
 local old=images[ts.pair];if old and old.ts==ts and old.frame==frame then return old.image end
 if not ts.imageData then return end
 local data=ts.imageData:clone()
 local function pixel(x,y)
  local r,g,b,a=ts.imageData:getPixel(x,y)
  if ts.overImageData then local rr,gg,bb,aa=ts.overImageData:getPixel(x,y)
   r,g,b,a=rr*aa+r*(1-aa),gg*aa+g*(1-aa),bb*aa+b*(1-aa),aa+a*(1-aa)
  end
  return r,g,b,a
 end
 local function key(r,g,b)return math.floor(r*255+.5)*65536+math.floor(g*255+.5)*256+math.floor(b*255+.5)end
 local floors={}
 for mid,ground in pairs(plants)do
  local floor=floors[ground]
  if not floor then
   floor={};floors[ground]=floor
   local slot=ts.midToSlot[ground]
   if slot then for y=0,15 do for x=0,15 do
    local r,g,b=pixel(slot%ts.cols*16+x,math.floor(slot/ts.cols)*16+y);floor[key(r,g,b)]=true
   end end end
  end
  local at=ts.midToSlot[mid]
  if at then for y=0,15 do for x=0,15 do
   local px,py=at%ts.cols*16+x,math.floor(at/ts.cols)*16+y
   local r,g,b,a=pixel(px,py);if floor[key(r,g,b)] then a=0 end
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
