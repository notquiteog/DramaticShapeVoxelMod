-- Whole-object recipes for the reviewed Building primary art. A sink, table
-- or bed consumes its entire drawing once; no cell is folded into a wall.
local V=...
local M={}
local recipes={
 {name='pallet_mailbox',primary='general',pair='pallet_outdoor',rows={{0x2A5},{0x2AD}},kind='mailbox',h=20,ground=0x296,depth=7},
 {name='saffron_mailbox',primary='general',pair='general__rom_082d4b9c',rows={{0x327},{0x32F}},kind='mailbox',h=20,ground=0x2E9,depth=7},
 {name='saffron_gym_notice_board',primary='general',scopeField='gymNotice',rows={{0x304},{0x30C}},kind='sign',h=19,ground=0x2E9,cutout=true},
 {name='gym_notice_board',primary='general',rows={{0x160},{0x168}},kind='sign',h=19,ground=1,cutout=true},
 {name='checked_table',rows={{0x4C,0x4D},{0x54,0x55}},kind='table',h=9,ground=0x45,top=26},
 {name='kitchen_sink_hob',rows={{0x31,0x32},{0x39,0x3A}},kind='counter',h=12,ground=1,top=16},
 {name='television',rows={{0x33,0x34},{0x3B,0x3C}},kind='cabinet',h=23,ground=1,depth=9},
 {name='cabinet',rows={{0x35},{0x3D}},kind='cabinet',h=24,ground=1,depth=10},
 {name='bed',secondary='pretty_petals_flower_shop',rows={{0x28C,0x28D},{0x294,0x295}},kind='bed',h=5,ground=1},
 {name='computer_desk',secondary='pretty_petals_flower_shop',rows={{0x35},{0x28E},{0x296}},kind='cabinet',h=28,ground=0x45,depth=12},
 {name='chair_back',rows={{0x4B}},kind='chair',h=6,ground=0x45},
 {name='chair_front',rows={{0x4E}},kind='chair',h=6,ground=0x45},
 {name='lab_wall_display',secondary='lab',rows={{0x28D},{0x295}},kind='cabinet',h=30,base=12,ground=0x289,depth=1.5,frontOffset=32.2,facade={1,9,14,22}},
 {name='lab_pokemon_machine',secondary='lab',rows={{0x2A3,0x2A4},{0x2AB,0x2AC},{0x2B3,0x2B4}},kind='labMachine',h=25,ground=0x289},
 {name='lab_server',secondary='lab',rows={{0x29D},{0x2AD},{0x2B5}},kind='cabinet',h=30,ground=0x289,depth=12,facade={0,10,15,36}},
 {name='lab_terminal',secondary='lab',rows={{0x06D},{0x2A6},{0x2B6}},kind='cabinet',h=25,ground=0x289,depth=12,facade={0,17,16,29}},
 {name='lab_side_terminal',secondary='lab',rows={{0x29F}},kind='cabinet',h=16,ground=0x289,depth=9,facade={1,0,12,16}},
 {name='lab_aquarium',secondary='lab',rows={{0x98},{0xA0}},kind='cabinet',h=28,ground=0x289,depth=11,frontOffset=34},
 {name='lab_books_left',secondary='lab',rows={{0x73},{0x283}},kind='cabinet',h=24,ground=0x289,depth=11,facade={1,0,14,27}},
 {name='lab_books_right',secondary='lab',rows={{0x74},{0x284}},kind='cabinet',h=24,ground=0x289,depth=11,facade={1,0,14,27}},
 {name='lab_books_free_left',secondary='lab',rows={{0x28B},{0x73},{0x283}},kind='cabinet',h=24,ground=0x289,depth=16,facade={1,16,14,27}},
 {name='lab_books_free_right',secondary='lab',rows={{0x28C},{0x74},{0x284}},kind='cabinet',h=24,ground=0x289,depth=16,facade={1,16,14,27}},
 {name='lab_books_free_corner',secondary='lab',rows={{0x2BA},{0x73},{0x287}},kind='cabinet',h=24,ground=0x289,depth=16,facade={1,16,14,27}},
 {name='lab_work_table',secondary='lab',rows={{0x2A8,0x2A9,0x2AA},{0x2B0,0x2B1,0x2B2}},kind='table',h=9,ground=0x289,top=20,footprintDepth=15,topRect={1,3,46,20},material={1,4},supportOffset=-3,supportRows=1},
 {name='lab_pokedex_desk',secondary='lab',rows={{0x85,0x86},{0x285,0x286}},kind='desk',h=12,ground=0x289},
 {name='lab_computer',secondary='lab',rows={{0x75,0x76},{0x285,0x286}},kind='cabinet',h=23,ground=0x289,depth=12,facade={1,3,30,24}},

}
-- Shops and Centers use their own secondary IDs, not the house vocabulary.
local function recipe(name,pair,rows,kind,h,ground,extra)
 local r={name=name,pair=pair,rows=rows,kind=kind,h=h,ground=ground,depth=11}
 for k,v in pairs(extra or {})do r[k]=v end
 recipes[#recipes+1]=r
end
local mart='building__rom_082d4bcc'
recipe('mart_rear_display',mart,{{0x287},{0x28F}},'cabinet',24,0x281,{facade={0,16,16,16}})
recipe('mart_rear_books',mart,{{0x292,0x293,0x294},{0x29A,0x29B,0x29C},{0x2A2,0x2A3,0x2A4}},'cabinet',30,0x281,{facade={0,16,48,32}})
recipe('mart_checkout',mart,{{0x2A8,0x2A9,0x2AA},{0x2B0,0x2B1,0x2B2}},'counter',12,0x281,{top=16})
recipe('mart_checkout_end',mart,{{0x2A5},{0x2AD}},'counter',12,0x281,{top=16})
recipe('mart_checkout_return',mart,{{0x295},{0x29D}},'cabinet',12,0x281,{depth=14})
for _,r in ipairs({{0x296,0x29E},{0x297,0x29F},{0x2A6,0x2AE},{0x2A7,0x2AF}})do
 recipe('mart_stock_'..r[1],mart,{{r[1]},{r[2]}},'cabinet',19,0x281,{depth=20,facade={0,0,16,29}})
end
recipe('mart_bench',mart,{{0x2B7,0x2BC},{0x2C1,0x2C2}},'table',6,0x281,{top=26})
local center='network'
recipe('center_vending',center,{{0x2C9,0x2CA},{0x2CB,0x2CC},{0x2CD,0x2CE}},'cabinet',29,0x281,{depth=13,facade={0,8,32,39}})
recipe('center_screen',center,{{0x286,0x287},{0x28E,0x28F}},'cabinet',28,0x281,{base=12,depth=1.5,frontOffset=32.2,facade={2,10,28,16}})
recipe('center_terminal',center,{{0x285},{0x62},{0x295}},'cabinet',28,0x281,{depth=11,facade={0,8,16,39}})
recipe('center_map',center,{{0x296,0x297},{0x29E,0x29F}},'cabinet',27,0x281,{base=11,depth=1.5,frontOffset=32.2,facade={0,13,32,17}})
recipe('center_healer',center,{{0x2AA,0x2AB},{0x2B2,0x2B3}},'centerHealer',13,0x281)
recipe('center_medical_cabinet',center,{{0x2AD},{0x2B5}},'cabinet',22,0x281,{facade={0,0,16,16},depth=10})
for _,mid in ipairs({0x2B9,0x2BC,0x298,0x2BD})do
 recipe('center_counter_'..mid,center,{{mid}},'counter',7,0x281,{top=10,depth=6,single=true})
end
recipe('center_table',center,{{0x29C,0x29D},{0x2A4,0x2A5}},'table',7,0x281,{top=26})
for _,mid in ipairs({0x2F5,0x2FD})do recipe('center_seat_'..mid,center,{{mid}},'centerSeat',6,0x281,{top=13})end
recipe('lab_plant_left','oak_lab',{{0x293},{0x29B}},'plant',26,0x289,{cutout=true})
recipe('lab_plant_right','oak_lab',{{0x294},{0x29C}},'plant',26,0x289,{cutout=true})
recipe('house_plant', 'player_house',{{0x47},{0x4F}},'plant',24,1,{cutout=true})
recipe('common_house_plant','house',{{0x47},{0x4F}},'plant',24,1,{cutout=true})
recipe('mart_plant',mart,{{0x2B5},{0x2B6}},'plant',24,0x281,{cutout=true})
recipe('center_plant',center,{{0x28D},{0x294}},'plant',26,0x281,{cutout=true})
local profiles=V and V.require('Gen3InteriorProfiles') or dofile((os.getenv('DS_MOD_PATH') or '.')..'/lib/Gen3InteriorProfiles.lua')
for secondary,p in pairs(profiles)do for _,prop in ipairs(p.props)do
 recipes[#recipes+1]={name=secondary..'_prop_'..prop[1],primary='building',secondary=secondary,
  rows={{prop[1]}},kind=prop[2],h=prop[3],ground=p.floor,depth=8}
end end
local additional=V and V.require('Gen3AdditionalFurniture') or dofile((os.getenv('DS_MOD_PATH') or '.')..'/lib/Gen3AdditionalFurniture.lua')
for _,r in ipairs(additional)do recipes[#recipes+1]=r end
local Center=V and V.require('Gen3CenterFurniture') or dofile((os.getenv('DS_MOD_PATH') or '.')..'/lib/Gen3CenterFurniture.lua')
for _,r in ipairs(Center.recipes)do recipes[#recipes+1]=r end
local function matched(mid,expected,r)
 return (r.kind=='escalator' and Center.canonical(mid) or mid)==expected
end
function M.extract(cells)
 local out,ordered={},{}
 for _,c in pairs(cells)do if c.primary=='building' or c.primary=='general' then ordered[#ordered+1]=c end end
 table.sort(ordered,function(a,b)return a.cy==b.cy and a.cx<b.cx or a.cy<b.cy end)
 -- Longest recipes win: the computer's top is also a cabinet top.
 table.sort(recipes,function(a,b)
  local aa,bb=#a.rows*#a.rows[1],#b.rows*#b.rows[1]
  if aa~=bb then return aa>bb end
  return a.name<b.name
 end)
 for _,c in ipairs(ordered)do if not c.prop and not c.stairs then
  for _,r in ipairs(recipes)do
   if c.primary==(r.primary or 'building') and matched(c.mid,r.rows[1][1],r) and (not r.scopeField or c[r.scopeField]) and (not r.secondary or r.secondary==c.secondary) and (not r.pair or r.pair==c.pair) then
    local match=true;local parts={}
    for dy,row in ipairs(r.rows)do for dx,mid in ipairs(row)do
     local n=cells[(c.cx+dx-1)..':'..(c.cy+dy-1)]
     if not n or n.prop or n.stairs or n.pair~=c.pair or not matched(n.mid,mid,r) then match=false else parts[#parts+1]=n end
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
    {tex(l,t),tex(rr,t),tex(rr,bb),tex(l,bb)},1,r.kind=='plant' and {x+p.w/2,z+p.d-6,.001} or nil)
  end end
 end
 local uv=uvFor(p.ts,r.rows[1][1]);local u,v=uv[1][1]+(uv[2][1]-uv[1][1])*.08,uv[1][2]+(uv[3][2]-uv[1][2])*.1
 -- Some complete drawings include wall above the object. Sample the frame
 -- itself for closed sides, rather than repeating that surrounding wall.
 if r.material then
  local sx,sy=r.material[1],r.material[2]
  local t=uvFor(p.ts,r.rows[math.floor(sy/16)+1][math.floor(sx/16)+1])
  u=t[1][1]+(t[2][1]-t[1][1])*(sx%16+.5)/16
  v=t[1][2]+(t[3][2]-t[1][2])*(sy%16+.5)/16
 end
 local solid={{u,v},{u,v},{u,v},{u,v}}
 local function box(x0,y0,z0,x1,y1,z1,material)
  material=material or solid
  emit({{x0,y1,z0},{x1,y1,z0},{x1,y1,z1},{x0,y1,z1}},material,.88)
  emit({{x0,y1,z1},{x1,y1,z1},{x1,y0,z1},{x0,y0,z1}},material,.72)
  emit({{x1,y1,z0},{x0,y1,z0},{x0,y0,z0},{x1,y0,z0}},material,.66)
  emit({{x0,y1,z0},{x0,y1,z1},{x0,y0,z1},{x0,y0,z0}},material,.7)
  emit({{x1,y1,z1},{x1,y1,z0},{x1,y0,z0},{x1,y0,z1}},material,.7)
 end
 local function sample(sx,sy)
  local t=uvFor(p.ts,r.rows[math.floor(sy/16)+1][math.floor(sx/16)+1])
  local u=t[1][1]+(t[2][1]-t[1][1])*(sx%16+.5)/16
  local v=t[1][2]+(t[3][2]-t[1][2])*(sy%16+.5)/16
  return {{u,v},{u,v},{u,v},{u,v}}
 end
 if Center.append(p,source,box,sample,emit,uvFor)then return end
 if r.kind=='relief' or r.kind=='bin' or r.kind=='plaque' then
  -- A closed relief follows the original pixel silhouette from every angle.
  -- Keep the source outline; never turn surrounding floor into its backing.
  local mask=V.require('Gen3Outdoor').mask(p.ts,r.rows[1][1],r.ground)
  if not mask then return end
  local function tex(px,py)
   local u=uv[1][1]+(uv[2][1]-uv[1][1])*(px+.5)/16
   local v=uv[1][2]+(uv[3][2]-uv[1][2])*(py+.5)/16
   return {{u,v},{u,v},{u,v},{u,v}}
  end
  local first,last
  for sy=0,15 do for sx=0,15 do if mask[sy*16+sx]then first=first or sy;last=sy end end end
  if not first then return end
  local rise=r.h/(last-first+1)
  for sy=first,last do for sx=0,15 do if mask[sy*16+sx]then
   local y0,y1=(last-sy)*rise,(last-sy+1)*rise
   local depth=r.kind=='plaque' and 2 or r.kind=='bin' and 7 or 5+3*math.sin((sy-first)/(last-first+1)*math.pi)
   box(x+sx,y0,z+8-depth/2,x+sx+1,y1,z+8+depth/2,tex(sx,sy))
  end end end
 elseif r.kind=='plant' then
  source(0,0,p.w,p.d,{x,r.h,z+p.d-6},{x+p.w,r.h,z+p.d-6},{x+p.w,0,z+p.d-6},{x,0,z+p.d-6})
 elseif r.kind=='mailbox' then
  -- The source mailbox spans two metatiles but only its bottom twenty
  -- drawing rows belong to the object. A closed, bevelled postal box keeps
  -- that rounded lid and front mail slot, without lifting the surrounding
  -- grass/paving into its sides. Feet sit in the lower native cell.
  local back,front=z+21,z+28
  local shell=uvFor(p.ts,r.rows[2][1]);local top=uvFor(p.ts,r.rows[1][1])
  local function sample(tex,px,py)
   local u=tex[1][1]+(tex[2][1]-tex[1][1])*px/16
   local v=tex[1][2]+(tex[3][2]-tex[1][2])*py/16
   return {{u,v},{u,v},{u,v},{u,v}}
  end
  local side,light,dark=sample(shell,5,5),sample(top,7,13),sample(shell,5,11)
  -- One enclosed six-sided profile, extruded along its native depth.
  local profile={{3,3},{13,3},{13,16},{10,20},{6,20},{3,16}}
  for i,a in ipairs(profile)do local b=profile[i%#profile+1]
   emit({{x+a[1],a[2],back},{x+b[1],b[2],back},{x+b[1],b[2],front},{x+a[1],a[2],front}},i>=3 and i<=5 and light or side,.86)
   emit({{x+8,10,back},{x+a[1],a[2],back},{x+b[1],b[2],back},{x+8,10,back}},side,.8)
  end
  -- The narrow front preserves the ROM's postal slot, trim and feet.
  for sy=12,28 do
   local inset=math.max(0,15-sy)
   local left,right=3+inset,13-inset
   source(left,sy,right-left,1,
    {x+left,32-sy,front+.015},{x+right,32-sy,front+.015},
    {x+right,31-sy,front+.015},{x+left,31-sy,front+.015})
  end
  box(x+4,0,back+1,x+6,3,front-1,dark)
  box(x+10,0,back+1,x+12,3,front-1,dark)
 elseif r.kind=='sign' then
  local board=uvFor(p.ts,r.rows[2][1])
  local bu,bv=board[1][1]+(board[2][1]-board[1][1])*.5,board[1][2]+(board[3][2]-board[1][2])*.5
  local frame={{bu,bv},{bu,bv},{bu,bv},{bu,bv}}
  box(x+6.5,0,z+23,x+9.5,7,z+26,frame)
  -- The native rounded board is a cutout, not an opaque rectangular slab.
  source(1,8,14,20,{x+1,r.h,z+25.53},{x+15,r.h,z+25.53},{x+15,5,z+25.53},{x+1,5,z+25.53})
 elseif r.kind=='reception' then
  local function sample(s)
   local t=uvFor(p.ts,r.rows[math.floor(s[2]/16)+1][math.floor(s[1]/16)+1])
   local u=t[1][1]+(t[2][1]-t[1][1])*(s[1]%16+.5)/16
   local v=t[1][2]+(t[3][2]-t[1][2])*(s[2]%16+.5)/16
   return {{u,v},{u,v},{u,v},{u,v}}
  end
  local wood=sample(r.trim)
  for _,s in ipairs(r.segments)do
   box(x+s[1],0,z+s[2],x+s[3],r.h-2,z+s[4],wood)
   box(x+s[1],r.h-2,z+s[2],x+s[3],r.h,z+s[4],solid)
   -- A recessed kickboard and narrow timber ribs read from both sides.
   for xx=s[1]+2,s[3]-2,4 do
    box(x+xx,2,z+s[2]-.08,x+xx+.6,r.h-3,z+s[4]+.08,wood)
   end
  end
 elseif r.kind=='displayCase' then
  -- The drawing's upper floor and lower cast shadow remain on the floor.
  -- Fossils stay under their native blue glass; frame and plinth have depth.
  local back,front=z+12,z+34
  box(x+2,0,back+2,x+p.w-2,4,front-2)
  box(x+1,4,back,x+p.w-1,6,front)
  box(x+1,6,back,x+p.w-1,r.h,front)
  source(1,12,p.w-2,15,{x+1,r.h+.02,back},{x+p.w-1,r.h+.02,back},
   {x+p.w-1,r.h+.02,front},{x+1,r.h+.02,front})
  source(1,27,p.w-2,10,{x+1,r.h,front+.02},{x+p.w-1,r.h,front+.02},
   {x+p.w-1,5,front+.02},{x+1,5,front+.02})
  -- Glass sides use a glass-only strip, never repeated fossil faces.
  source(2,20,1,7,{x+.98,r.h,back},{x+.98,r.h,front},{x+.98,6,front},{x+.98,6,back})
  source(p.w-3,20,1,7,{x+p.w-.98,r.h,front},{x+p.w-.98,r.h,back},
   {x+p.w-.98,6,back},{x+p.w-.98,6,front})
 elseif r.kind=='cabinet' then
  local front=z+(r.frontOffset or p.d-2);local back=front-r.depth
  box(x+1,r.base or 0,back,x+p.w-1,r.h,front)
  local f=r.facade or {1,0,p.w-2,p.d}
  source(f[1],f[2],f[3],f[4],{x+1,r.h,front+.02},{x+p.w-1,r.h,front+.02},{x+p.w-1,r.base or 0,front+.02},{x+1,r.base or 0,front+.02})
 elseif r.kind=='labMachine' then
  -- The native machine is a circular red platen, silver rim and blue drum
  -- on four feet. Its top-down shadow/floor is never part of the model.
  local function sample(sx,sy)
   local uv=uvFor(p.ts,r.rows[math.floor(sy/16)+1][math.floor(sx/16)+1])
   local u=uv[1][1]+(uv[2][1]-uv[1][1])*(sx%16+.5)/16
   local v=uv[1][2]+(uv[3][2]-uv[1][2])*(sy%16+.5)/16
   return {{u,v},{u,v},{u,v},{u,v}}
  end
  local silver,blue,dark=sample(7,12),sample(12,32),sample(9,38)
  local cx,cz=x+16,z+31
  local rings={{2,10},{5,12},{7,11},{18,11},{20,14},{22,14},{24,12}}
  for j=1,#rings-1 do
   local a,b=rings[j],rings[j+1]
   for i=0,15 do
    local t0,t1=i*math.pi/8,(i+1)*math.pi/8
    local function pt(r,t)return {cx+math.cos(t)*r[2],r[1],cz+math.sin(t)*r[2]}end
    emit({pt(b,t0),pt(b,t1),pt(a,t1),pt(a,t0)},j==3 and blue or silver,.78+.12*math.sin(t0))
   end
  end
  -- Map the original circular red top onto a horizontal disk, preserving
  -- the small white highlight instead of stretching it over a cylinder.
  for i=0,15 do
   local a,b=i*math.pi/8,(i+1)*math.pi/8
   emit({{cx,24,cz},{cx+12*math.cos(a),24,cz+12*math.sin(a)},
    {cx+12*math.cos(b),24,cz+12*math.sin(b)},{cx,24,cz}},silver,1)
  end
  for sy=0,13 do
   local dy=(sy-6.5)/7;local half=math.sqrt(math.max(0,1-dy*dy))*12
   source(16-half,12+sy,half*2,1,
    {cx-half,24.03,cz+(sy/7-1)*12},{cx+half,24.03,cz+(sy/7-1)*12},
    {cx+half,24.03,cz+((sy+1)/7-1)*12},{cx-half,24.03,cz+((sy+1)/7-1)*12})
  end
  for _,dx in ipairs({-11,8})do for _,dz in ipairs({-9,8})do box(cx+dx,0,cz+dz,cx+dx+3,6,cz+dz+4,silver)end end
  box(cx-5,2,cz+10,cx+5,11,cz+12,dark)
  source(12,37,8,8,{cx-4,10,cz+12.03},{cx+4,10,cz+12.03},{cx+4,3,cz+12.03},{cx-4,3,cz+12.03})
 elseif r.kind=='desk' then
  -- The Pokédex desk's native top occupies rows 6..16, not the wall
  -- above it or the floor below its feet. Model the frame independently.
  local back,front=z+17,z+30
  local function color(sx,sy)
   local t=uvFor(p.ts,r.rows[math.floor(sy/16)+1][math.floor(sx/16)+1])
   local u=t[1][1]+(t[2][1]-t[1][1])*(sx%16+.5)/16
   local v=t[1][2]+(t[3][2]-t[1][2])*(sy%16+.5)/16
   return {{u,v},{u,v},{u,v},{u,v}}
  end
  local frame,edge=color(2,21),color(1,17)
  box(x,10,back,x+p.w,12,front,frame)
  source(0,6,p.w,11,{x,12.03,back},{x+p.w,12.03,back},{x+p.w,12.03,front},{x,12.03,front})
  for _,dx in ipairs({2,p.w-4})do for _,dz in ipairs({back+1,front-3})do
   box(x+dx,0,dz,x+dx+2,10,dz+2,frame)
  end end
  -- Aprons and a real right-hand drawer leave an open knee space.
  box(x+2,8,back+1,x+p.w-2,10,back+2,edge)
  box(x+2,8,front-2,x+p.w-2,10,front-1,edge)
  box(x+2,8,back+1,x+3,10,front-1,edge)
  box(x+p.w-3,8,back+1,x+p.w-2,10,front-1,edge)
  box(x+20,3,back+2,x+30,10,front-1,frame)
  source(20,18,11,6,{x+20,10,front-.98},{x+30,10,front-.98},{x+30,3,front-.98},{x+20,3,front-.98})
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
  -- The source drawing can contain a walkable perspective apron. Its
  -- art is still consumed whole, but only the authored footprint is solid.
  local depth=r.footprintDepth or (r.kind=='counter' and math.min(22,p.d-2) or p.d-2)
  local z0,z1=z+1,z+depth
  box(x+inset,r.h-2,z0,x+p.w-inset,r.h,z1)
  for _,dx in ipairs({inset+1,p.w-inset-3})do for _,dz in ipairs({2,depth-3})do box(x+dx,0,z+dz,x+dx+2,r.h-2,z+dz+2)end end
  local top=r.top or p.d-2
  local t=r.topRect or {inset,0,p.w-inset*2,top}
  source(t[1],t[2],t[3],t[4],{x+inset,r.h+.02,z0},{x+p.w-inset,r.h+.02,z0},{x+p.w-inset,r.h+.02,z1},{x+inset,r.h+.02,z1})
  if r.kind=='counter' then
   source(0,r.single and 10 or 16,p.w,r.single and 6 or 16,{x,r.h,z1+.02},{x+p.w,r.h,z1+.02},{x+p.w,0,z1+.02},{x,0,z1+.02})
  elseif r.kind=='bed' then box(x+2,0,z,x+p.w-2,r.h+3,z+1)end
 end
end
-- Only stationary item props rest on furniture. Characters/NPCs retain
-- native ground and animation offsets; this never changes interaction cells.
function M.support(cells,gid,px,py)
 if tonumber(gid)~=92 and tonumber(gid)~=94 then return 0 end
 local c=cells and cells[math.floor(px/16)..':'..math.floor(py/16)]
 local p=c and c.prop;local r=p and p.recipe
 if r and (r.kind=='table' or r.kind=='counter' or r.kind=='desk') then
  if r.supportRows and math.floor(py/16)>=p.cy+r.supportRows then return 0 end
  return r.h+.12,r.supportOffset or (r.kind=='desk' and 5 or .4)
 end
 return 0
end
function M.cutouts(pair)
 local out={}
 for _,r in ipairs(recipes)do if r.kind=='plant' and r.pair==pair then
  for _,row in ipairs(r.rows)do for _,mid in ipairs(row)do out[mid]=r.ground end end
 end end
 return out
end
M.recipes=recipes
return M
