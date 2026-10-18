-- Complete native Hoenn field fixtures. Source IDs and permission guards only;
-- the active atlas supplies every pixel and native interactions remain owners.
local M={recipes={}}
local function add(name,rows,permissions,variant,extra)
 local r={name=name,primary='general',pair='general__petalburg',family='rse',earlyHoenn=true,
  rows=rows,collisionRows=permissions,kind='earlyHoennProp',variant=variant,ground=1}
 for k,v in pairs(extra or{})do r[k]=v end
 M.recipes[#M.recipes+1]=r
end
add('hoenn_field_garden_troughs',{{7}},{{7}},'gardenTroughs')
add('hoenn_field_gym_notice',{{0x130},{0x131}},{{0},{7}},'gymNotice')
add('hoenn_berry_soil_28d',{{0x28d}},{{7}},'berrySoil',{soilStart=3})
add('hoenn_berry_soil_14c',{{0x14c}},{{7}},'berrySoil',{soilStart=3})
function M.active(r,edition)
 return r.earlyHoenn and(edition=='emerald'or edition=='ruby'or edition=='sapphire')
end
-- The complete 2x2 sea rocks remain owned by Gen3SeaRocks. These four
-- native shoreline corners belong to the adjoining island enclosure instead.
local shoreCorners={[0x164]=true,[0x165]=true,[0x16c]=true,[0x16d]=true}
function M.shape(primary,secondary,mid,collision,edition)
 if primary=='general'and secondary=='petalburg'and collision==7 and shoreCorners[mid]
  and(edition=='emerald'or edition=='ruby'or edition=='sapphire')then
  return{kind='cliff',height=16,ground=0x170,cap=0x6c,side=0x71}
 end
end
function M.append(p,source,box,sample,emit,uvFor)
 if p.recipe.kind~='earlyHoennProp'then return false end
 local r,x,z=p.recipe,p.cx*16,p.cy*16
 local function B(l,b,n,rr,h,f,tex)
  tex=tex or sample(8,20)
  box(x+l,b,z+n,x+rr,h,z+f,tex)
  emit({{x+l,b,z+n},{x+l,b,z+f},{x+rr,b,z+f},{x+rr,b,z+n}},tex,.65)
 end
 if r.variant=='gymNotice'then
  local metal=sample(2,16);local leg=sample(8,29)
  B(6,0,22.2,10,9,25,leg)
  -- The complete native board has two clipped upper corners, real depth and
  -- a closed back. Its original GYM mark remains one continuous front plane.
  local poly={{3,9},{13,9},{15,13},{15,27},{1,27},{1,13}}
  local function point(q,depth)return{x+q[1],36-q[2],z+depth}end
  local function solid(v,shade)emit(v,metal,shade)end
  local center={8,18}
  for i,a in ipairs(poly)do local b=poly[i%#poly+1]
   solid({point(a,22),point(b,22),point(b,25),point(a,25)},.78)
   solid({point(center,22),point(b,22),point(a,22),point(a,22)},.68)
  end
  local function tex(mid,sx,sy)
   local uv=assert(uvFor(p.ts,mid),'missing native notice source')
   return{uv[1][1]+(uv[2][1]-uv[1][1])*sx/16,
    uv[1][2]+(uv[3][2]-uv[1][2])*sy/16}
  end
  local top={{3,9},{13,9},{15,13},{15,16},{1,16},{1,13}};local c={8,13}
  for i,a in ipairs(top)do local b=top[i%#top+1]
   emit({point(c,25.02),point(a,25.02),point(b,25.02),point(b,25.02)},
    {tex(0x130,c[1],c[2]),tex(0x130,a[1],a[2]),tex(0x130,b[1],b[2]),tex(0x130,b[1],b[2])},1)
  end
  source(1,16,14,11,point({1,16},25.02),point({15,16},25.02),point({15,27},25.02),point({1,27},25.02),1)
 elseif r.variant=='gardenTroughs'then
  local wood=sample(2,4);local rim=sample(2,1);local dark=sample(6,7)
  for _,n in ipairs{0,9}do
   B(.5,0,n+.25,15.5,3.8,n+6.7,wood)
   B(1.8,3.8,n+1.2,14.2,3.9,n+5.6,dark)
   -- Separate wooden lips, closed outside walls and a recessed planting bed.
   B(.5,3.8,n+.25,15.5,4.4,n+1.15,rim)
   B(.5,3.8,n+5.8,15.5,4.4,n+6.7,rim)
   B(.5,3.8,n+1.15,1.4,4.4,n+5.8,rim)
   B(14.6,3.8,n+1.15,15.5,4.4,n+5.8,rim)
  end
  -- Keep the native greenery/buds as flat HD-2D artwork above each trough.
  -- Pixel cards have no solid foliage hull and remain inside this one cell.
  local ts=p.ts
  if ts.imageData and ts.midToSlot and ts.cols then
   local slot=ts.midToSlot[7];local groundSlot=ts.midToSlot[1]
   local function key(rr,gg,bb)return math.floor(rr*255+.5)*65536+math.floor(gg*255+.5)*256+math.floor(bb*255+.5)end
   local function pixel(s,px,py)
    local ax,ay=s%ts.cols*16+px,math.floor(s/ts.cols)*16+py
    local rr,gg,bb,aa=ts.imageData:getPixel(ax,ay)
    if ts.overImageData then local r2,g2,b2,a2=ts.overImageData:getPixel(ax,ay)
     rr,gg,bb,aa=r2*a2+rr*(1-a2),g2*a2+gg*(1-a2),b2*a2+bb*(1-a2),a2+aa*(1-a2)
    end
    return rr,gg,bb,aa
   end
   local floor={}
   if groundSlot then for py=0,15 do for px=0,15 do floor[key(pixel(groundSlot,px,py))]=true end end end
   if slot then for _,n in ipairs{0,9}do for py=0,5 do for px=1,14 do
    local rr,gg,bb,aa=pixel(slot,px,py+n)
    if aa>.5 and gg>rr+.02 and gg>bb+.02 and not floor[key(rr,gg,bb)]then
     local h=10-py;local depth=z+n+3.8;local tex=sample(px,py+n)
     local q={{x+px,h,depth},{x+px+1,h,depth},{x+px+1,h-1,depth},{x+px,h-1,depth}}
     emit(q,tex,1);emit({q[4],q[3],q[2],q[1]},tex,1)
    end
   end end end end
  end
 elseif r.variant=='berrySoil'then
  -- A shallow earth edge provides depth beneath the native berry object.
  -- No crop, flower, actor or planting/harvest behavior is generated here.
  local n=r.soilStart or 3;local dirt=sample(8,8)
  B(0,0,n,16,.55,16,dirt)
  source(0,n,16,16-n,{x,.57,z+n},{x+16,.57,z+n},{x+16,.57,z+16},{x,.57,z+16},1)
 else return false end
 return true
end
return M
