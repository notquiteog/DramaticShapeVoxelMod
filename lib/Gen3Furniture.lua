-- Whole-object recipes for the reviewed Building primary art. A sink, table
-- or bed consumes its entire drawing once; no cell is folded into a wall.
local M={}
local recipes={
 {name='checked_table',rows={{0x4C,0x4D},{0x54,0x55}},kind='table',h=9,ground=0x45,top=26},
 {name='kitchen_sink_hob',rows={{0x31,0x32},{0x39,0x3A}},kind='counter',h=12,ground=1,top=16},
 {name='television',rows={{0x33,0x34},{0x3B,0x3C}},kind='cabinet',h=23,ground=1,depth=9},
 {name='cabinet',rows={{0x35},{0x3D}},kind='cabinet',h=24,ground=1,depth=10},
 {name='bed',secondary='pretty_petals_flower_shop',rows={{0x28C,0x28D},{0x294,0x295}},kind='bed',h=5,ground=1},
 {name='computer_desk',secondary='pretty_petals_flower_shop',rows={{0x35},{0x28E},{0x296}},kind='cabinet',h=28,ground=0x45,depth=12},
 {name='chair_back',rows={{0x4B}},kind='chair',h=6,ground=0x45},
 {name='chair_front',rows={{0x4E}},kind='chair',h=6,ground=0x45},
}
function M.extract(cells)
 local out,ordered={},{}
 for _,c in pairs(cells)do if c.primary=='building' then ordered[#ordered+1]=c end end
 table.sort(ordered,function(a,b)return a.cy==b.cy and a.cx<b.cx or a.cy<b.cy end)
 -- Longest recipes win: the computer's top is also a cabinet top.
 table.sort(recipes,function(a,b)return #a.rows>#b.rows end)
 for _,c in ipairs(ordered)do if not c.prop then
  for _,r in ipairs(recipes)do
   if c.mid==r.rows[1][1] and (not r.secondary or r.secondary==c.secondary) then
    local match=true;local parts={}
    for dy,row in ipairs(r.rows)do for dx,mid in ipairs(row)do
     local n=cells[(c.cx+dx-1)..':'..(c.cy+dy-1)]
     if not n or n.prop or n.pair~=c.pair or n.mid~=mid then match=false else parts[#parts+1]=n end
    end end
    if match then
     local p={recipe=r,cx=c.cx,cy=c.cy,pair=c.pair,ts=c.ts,w=#r.rows[1]*16,d=#r.rows*16}
     for _,n in ipairs(parts)do n.prop=p end
     out[#out+1]=p;break
    end
   end
  end
 end end
 return out
end
-- emit(vertices, UVs, shade). Source rectangles can span several metatiles;
-- split them at atlas boundaries, preserving their native pixels and layers.
function M.append(p,emit,uvFor)
 local r,x,z=p.recipe,p.cx*16,p.cy*16
 local function source(sx,sy,sw,sh,a,b,c,d)
  local xend,yend=sx+sw,sy+sh
  local function point(u,v)
   local q={};for k=1,3 do q[k]=(a[k]*(1-u)+b[k]*u)*(1-v)+(d[k]*(1-u)+c[k]*u)*v end;return q
  end
  for ty=math.floor(sy/16),math.ceil(yend/16)-1 do for tx=math.floor(sx/16),math.ceil(xend/16)-1 do
   local l,t=math.max(sx,tx*16),math.max(sy,ty*16)
   local rr,bb=math.min(xend,(tx+1)*16),math.min(yend,(ty+1)*16)
   local uv=uvFor(p.ts,r.rows[ty+1][tx+1]);assert(uv,'missing furniture source')
   local function tex(px,py)return {uv[1][1]+(uv[2][1]-uv[1][1])*(px-tx*16)/16,uv[1][2]+(uv[3][2]-uv[1][2])*(py-ty*16)/16}end
   emit({point((l-sx)/sw,(t-sy)/sh),point((rr-sx)/sw,(t-sy)/sh),point((rr-sx)/sw,(bb-sy)/sh),point((l-sx)/sw,(bb-sy)/sh)},
    {tex(l,t),tex(rr,t),tex(rr,bb),tex(l,bb)},1)
  end end
 end
 local uv=uvFor(p.ts,r.rows[1][1]);local u,v=uv[1][1]+(uv[2][1]-uv[1][1])*.08,uv[1][2]+(uv[3][2]-uv[1][2])*.1
 local solid={{u,v},{u,v},{u,v},{u,v}}
 local function box(x0,y0,z0,x1,y1,z1,material)
  material=material or solid
  emit({{x0,y1,z0},{x1,y1,z0},{x1,y1,z1},{x0,y1,z1}},material,.88)
  emit({{x0,y1,z1},{x1,y1,z1},{x1,y0,z1},{x0,y0,z1}},material,.72)
  emit({{x1,y1,z0},{x0,y1,z0},{x0,y0,z0},{x1,y0,z0}},material,.66)
  emit({{x0,y1,z0},{x0,y1,z1},{x0,y0,z1},{x0,y0,z0}},material,.7)
  emit({{x1,y1,z1},{x1,y1,z0},{x1,y0,z0},{x1,y0,z1}},material,.7)
 end
 if r.kind=='cabinet' then
  local front=z+p.d-2;local back=front-r.depth
  box(x+1,0,back,x+p.w-1,r.h,front)
  source(1,0,p.w-2,p.d,{x+1,r.h,front+.02},{x+p.w-1,r.h,front+.02},{x+p.w-1,0,front+.02},{x+1,0,front+.02})
 elseif r.kind=='chair' then
  -- The native chair drawing includes green carpet around its rounded back.
  -- Sample the upholstery/frame colours into real narrow parts, so that
  -- carpet never becomes an opaque upright rectangle at eye level.
  local chair=uvFor(p.ts,0x4B) or uv
  local function sample(px,py)
   local u=chair[1][1]+(chair[2][1]-chair[1][1])*px/16
   local v=chair[1][2]+(chair[3][2]-chair[1][2])*py/16
   return {{u,v},{u,v},{u,v},{u,v}}
  end
  local blue,frame=sample(8,5),sample(3,10)
  box(x+2,4,z+4,x+13,6,z+14,frame)
  box(x+3,6,z+5,x+12,6.8,z+13,blue)
  for _,dx in ipairs({3,11})do for _,dz in ipairs({5,12})do box(x+dx,0,z+dz,x+dx+1,5,z+dz+1,frame)end end
  local back=r.name=='chair_back' and z+4 or z+14
  box(x+2,6,back-.7,x+13,14,back+.7,frame)
  box(x+3,7,back-.8,x+12,13,back+.8,blue)
 else
  local inset=r.kind=='bed' and 2 or 1
  local depth=r.kind=='counter' and 22 or p.d-2
  local z0,z1=z+1,z+depth
  box(x+inset,r.h-2,z0,x+p.w-inset,r.h,z1)
  for _,dx in ipairs({inset+1,p.w-inset-3})do for _,dz in ipairs({2,depth-3})do box(x+dx,0,z+dz,x+dx+2,r.h-2,z+dz+2)end end
  local top=r.top or p.d-2
  source(inset,0,p.w-inset*2,top,{x+inset,r.h+.02,z0},{x+p.w-inset,r.h+.02,z0},{x+p.w-inset,r.h+.02,z1},{x+inset,r.h+.02,z1})
  if r.kind=='counter' then
   source(0,16,p.w,16,{x,r.h,z1+.02},{x+p.w,r.h,z1+.02},{x+p.w,0,z1+.02},{x,0,z1+.02})
  elseif r.kind=='bed' then box(x+2,0,z,x+p.w-2,r.h+3,z+1)end
 end
end
M.recipes=recipes
return M
