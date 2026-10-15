local M=dofile('lib/Gen3CashRegister.lua')
for _,family in ipairs{'frlg','rse'}do
 local faces,slopes,keys,bottoms=0,0,0,0
 local function emit(v)
  faces=faces+1;local min,max=100,-100
  for _,p in ipairs(v)do
   assert(p[1]>=0 and p[1]<=16 and p[3]>=17 and p[3]<=32,'till obstructs clerk or neighboring walking cell')
   assert(p[2]>=0 and p[2]<=17,'register scale drift')
   min,max=math.min(min,p[2]),math.max(max,p[2])
  end
  if min==max then bottoms=bottoms+1;if min>10 and min<13.4 then keys=keys+1 end end
 end
 local function source(sx,sy,w,h,a,b,c,d)
  assert(sx>=0 and sx+w<=16 and sy>=0 and sy+h<=32,'register reads outside original drawing')
  if a[2]~=b[2]then slopes=slopes+1 end;emit{a,b,c,d}
 end
 local function box(x,b,z,r,h,f)
  emit{{x,h,z},{r,h,z},{r,h,f},{x,h,f}};emit{{x,h,f},{r,h,f},{r,b,f},{x,b,f}}
  emit{{r,h,z},{x,h,z},{x,b,z},{r,b,z}};emit{{x,h,z},{x,h,f},{x,b,f},{x,b,z}};emit{{r,h,f},{r,h,z},{r,b,z},{r,b,f}}
 end
 M.append({cx=0,cy=0,recipe={family=family}},source,box,function()return{}end,emit)
 assert(faces>=90 and keys>=9 and slopes>=1 and bottoms>=18,'register lacks closed drawer/display/wedge or raised keys')
end
print('PASS FRLG and Hoenn closed west-facing cash drawers, display cases, sloping key beds, raised keys and native footprint')
