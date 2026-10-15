-- Complete tower reception drawings; only native blocked cells hold solids.
-- Furniture uses the active edition atlas, never packaged ROM textures.
local M={recipes={}}
local function add(name,pair,rows,kind,ground,extra)
 local r={name=name,pair=pair,rows=rows,kind=kind,ground=ground}
 for k,v in pairs(extra or{})do r[k]=v end
 M.recipes[#M.recipes+1]=r;return r
end
local fr='building__rom_082d5094'
local function counter(name,pair,rows,permissions,floor,extra)
 local r=add(name,pair,rows,'towerCounter',floor,extra)
 r.collisionRows=permissions;r.solids={};r.groundRows={}
 for y,row in ipairs(rows)do r.groundRows[y]={};for x,mid in ipairs(row)do
  local solid=permissions[y][x]~=0
  r.groundRows[y][x]=solid and floor or mid
  if solid then r.solids[#r.solids+1]={x-1,y-1}end
 end end
 return r
end
-- Native L-shaped reception surfaces, including their open clerk aisles.
counter('trainer_left_reception',fr,{
 {0x28f,0x2bd,0x2be,0x2d8,0x2d9,0x2bf,0x2a8,0x2a9},
 {0x295,0x2c5,0x2c6,0x2cc,0x296,0x2c7,0x377,0x2e8},
 {0x29d,0x29e,0x29e,0x2b6,0x29e,0x29e,0x29f,0x2f0}},
 {{144,7,7,7,7,7,7,144},{144,7,7,0,0,7,144,7},{144,144,144,144,144,144,144,7}},0x281,{red=true})
counter('trainer_right_reception',fr,{
 {0x2aa,0x2ab,0x291,0x291,0x291,0x2b5,0x2c2,0x2c3,0x2c4},
 {0x28e,0x376,0x2b2,0x296,0x2ae,0x2b9,0x2af,0x283,0x2b8},
 {0x286,0x29d,0x29e,0x29e,0x2b6,0x2c1,0x2b7,0x2b4,0x2c0}},
 {{144,7,7,7,7,7,7,114,7},{144,144,0,0,0,7,0,0,0},{0,144,144,144,144,7,144,7,144}},0x281,{red=true})
-- Only countertop art belongs to the desk. Wall/elevator/figure cells in
-- the complete match remain native and are not reinterpreted as cabinets.
local exclude={[0x2bd]=true,[0x2be]=true,[0x2c5]=true,[0x2c6]=true,[0x2d8]=true,[0x2d9]=true,[0x2bf]=true,[0x2a8]=true,[0x2a9]=true,[0x2aa]=true,[0x2ab]=true,[0x291]=true,[0x2b5]=true,[0x2c2]=true,[0x2c3]=true,[0x2c4]=true,[0x2b9]=true,[0x2e8]=true,[0x2f0]=true}
for _,r in ipairs(M.recipes)do
 local solids={};for _,q in ipairs(r.solids)do if not exclude[r.rows[q[2]+1][q[1]+1]]then solids[#solids+1]=q end end;r.solids=solids
 r.claimCells={};for _,q in ipairs(r.solids)do r.claimCells[(q[1]+1)..':'..(q[2]+1)]=true end
end
add('trainer_lobby_terminal',fr,{{0x2cb},{0x62}},'towerTerminal',0x281,{anchor=16,collisionRows={{7},{147}}})
add('trainer_lobby_screen',fr,{{0x2d0,0x2d1},{0x2d8,0x2d9}},'towerScreen',0x281,{blockedRows={[1]=true,[2]=true}})
add('trainer_battle_piers',fr,{{0x388},{0x388},{0x380}},'towerPiers',0x2ee,{blockedRows={[1]=true,[2]=true,[3]=true}})
add('trainer_elevator_door',fr,{{0x2ba,0x2bb,0x2bc},{0x2c2,0x2c3,0x2c4}},'towerDoor',0x281,{collisionRows={{7,7,7},{7,114,7}}})
add('trainer_lobby_stairs',fr,{{0x289,0x289,0x2d7},{0x2e0,0x2e1,0x2e2},{0x2e3,0x2e4,0x2e5},{0x2df,0x2e6,0x2e7}},'towerStairs',0x281,{mirror=true,start=16,collisionRows={{7,7,7},{7,7,7},{114,7,7},{0,7,7}}})
add('trainer_floor_down_stairs',fr,{{0x2e9,0x2e9,0x2e9},{0x30a,0x30b,0x30c},{0x30d,0x30e,0x30f},{0x310,0x311,0x312}},'towerStairs',0x2ee,{start=16,down=true,noGround=true,collisionRows={{7,7,7},{7,7,7},{7,7,114},{7,7,0}}})
add('trainer_floor_up_stairs',fr,{{0x308,0x2e9,0x2e9},{0x300,0x301,0x302},{0x303,0x304,0x305},{0x306,0x307,0x309}},'towerStairs',0x2ee,{start=16,collisionRows={{7,7,7},{7,7,7},{7,7,114},{7,7,0}}})
add('trainer_floor_wall_relief',fr,{{0x2eb,0x390,0x2ed},{0x2f3,0x398,0x2f5},{0x2fb,0x382,0x2fd}},'towerRelief',0x2ee,{blockedRows={[1]=true,[2]=true,[3]=true}})
add('trainer_center_battle_piers',fr,{{0x389},{0x388},{0x380}},'towerPiers',0x2ee,{blockedRows={[1]=true,[2]=true,[3]=true}})
add('trainer_floor_2_wall_relief',fr,{{0x2eb,0x390,0x2ed},{0x2f3,0x399,0x2f5},{0x2fb,0x382,0x2fd}},'towerRelief',0x2ee,{blockedRows={[1]=true,[2]=true,[3]=true}})
add('trainer_floor_3_wall_relief',fr,{{0x2eb,0x392,0x2ed},{0x2f3,0x399,0x2f5},{0x2fb,0x382,0x2fd}},'towerRelief',0x2ee,{blockedRows={[1]=true,[2]=true,[3]=true}})
add('trainer_floor_4_wall_relief',fr,{{0x2eb,0x393,0x2ed},{0x2f3,0x399,0x2f5},{0x2fb,0x382,0x2fd}},'towerRelief',0x2ee,{blockedRows={[1]=true,[2]=true,[3]=true}})
add('trainer_floor_5_wall_relief',fr,{{0x394,0x395,0x396},{0x2f3,0x399,0x2f5},{0x2fb,0x382,0x2fd}},'towerRelief',0x2ee,{blockedRows={[1]=true,[2]=true,[3]=true}})
add('trainer_floor_6_wall_relief',fr,{{0x394,0x395,0x396},{0x39c,0x39d,0x39e},{0x2fb,0x382,0x2fd}},'towerRelief',0x2ee,{blockedRows={[1]=true,[2]=true,[3]=true}})
add('trainer_floor_7_wall_relief',fr,{{0x397,0x393,0x39f},{0x39c,0x39d,0x39e},{0x2fb,0x382,0x2fd}},'towerRelief',0x2ee,{blockedRows={[1]=true,[2]=true,[3]=true}})
add('trainer_floor_8_wall_relief',fr,{{0x397,0x393,0x39f},{0x39a,0x399,0x39b},{0x2fb,0x382,0x2fd}},'towerRelief',0x2ee,{blockedRows={[1]=true,[2]=true,[3]=true}})
for _,r in ipairs(M.recipes)do if r.kind=='towerStairs'and r.start then
 r.claimCells={};for y=2,#r.rows do for x=1,#r.rows[y]do r.claimCells[x..':'..y]=true end end
 if r.mirror then r.claimCells['3:1']=true end
end end
local function hoenn(pair,edition)
 local flags={family='rse',edition=edition}
 for _,permission in ipairs{7,114}do
  add('tower_portal_'..edition..'_'..permission,pair,{{0x21e,0x206,0x21f},{0x226,0x20e,0x227}},'towerDoor',0x200,{family='rse',edition=edition,collisionRows={{7,7,7},{7,permission,7}}})
 end
 local r=add('tower_pc_'..edition,pair,{{0x280},{4},{0x281}},'towerTerminal',0x200,flags)
 r.anchor=16;r.collisionRows={{7},{147},{0}};r.groundRows={{0x209},{0x200},{0x281}}
 if edition=='rs'then
  counter('rs_tower_reception',pair,{
   {0x210,0x204,0x277,0x203,0x277,0x203,0x210},
   {0x210,0x20d,0x200,0x200,0x200,0x200,0x210},
   {0x218,0x282,0x20c,0x200,0x20a,0x20b,0x219},
   {0x220,0x213,0x214,0x200,0x212,0x213,0x221}},
   {{144,0,0,0,0,0,144},{144,0,0,0,0,0,144},{7,0,0,0,0,0,144},{7,144,144,0,144,144,7}},0x200,flags)
 else
  counter('em_tower_reception',pair,{
   {0x210,0x204,0x203,0x203,0x210,0x204,0x203,0x203,0x210,0x204,0x203,0x203,0x210,0x204,0x203,0x203,0x210},
   {0x210,0x20d,0x200,0x200,0x210,0x20d,0x200,0x200,0x210,0x20d,0x200,0x200,0x210,0x20d,0x200,0x200,0x210},
   {0x218,0x2de,0x200,0x2e6,0x218,0x2de,0x200,0x2e6,0x218,0x2de,0x200,0x2e6,0x218,0x2de,0x200,0x2e6,0x219},
   {0x220,0x214,0x200,0x212,0x29d,0x214,0x200,0x212,0x29d,0x214,0x200,0x212,0x29d,0x214,0x200,0x212,0x221}},{
   {144,0,0,0,144,0,0,0,144,0,0,0,144,0,0,0,144},
   {144,0,0,0,144,0,0,0,144,0,0,0,144,0,0,0,144},
   {7,0,0,0,7,0,0,0,7,0,0,0,7,0,0,0,144},
   {7,144,0,144,7,144,0,144,7,144,0,144,7,144,0,144,7}},0x200,flags)
  add('em_tower_information_console',pair,{{0x388,0x389,0x38a},{0x390,0x391,0x392},{0x398,0x399,0x39a}},'towerConsole',0x200,{family='rse',edition=edition,collisionRows={{7,7,7},{7,7,7},{0,0,0}},groundRows={{0x209,0x209,0x209},{0x200,0x200,0x200},{0x398,0x399,0x39a}}})
 end
end
hoenn('building__battle_frontier','emerald');hoenn('building__battle_tower','rs')
function M.append(p,source,openBox,sample,emit,uvFor)
 local r=p.recipe;local x,z=p.cx*16,p.cy*16
 local function box(l,b,n,rr,h,f,mat)
  openBox(x+l,b,z+n,x+rr,h,z+f,mat)
  emit({{x+l,b,z+f},{x+rr,b,z+f},{x+rr,b,z+n},{x+l,b,z+n}},mat,.65)
 end
 local function top(sx,sy,w,h,l,n,rr,f,y)
  source(sx,sy,w,h,{x+l,y,z+n},{x+rr,y,z+n},{x+rr,y,z+f},{x+l,y,z+f})
 end
 local function front(sx,sy,w,h,l,b,rr,t,f)
  source(sx,sy,w,h,{x+l,t,z+f},{x+rr,t,z+f},{x+rr,b,z+f},{x+l,b,z+f})
 end
 if r.kind=='towerStairs'then
  local l=r.mirror and 16 or 0;local n=r.start or 0;local f=p.d-.2
  local stone=r.mirror and sample(22,38)or sample(20,20);local rail=r.mirror and sample(43,43)or sample(18,18)
  -- Native directional stair warps run east/west. The raised flight must
  -- face that approach, not turn the original diagonal drawing northward.
  for i=0,7 do local a=l+i*4;local b=l+(i+1)*4;local h=r.mirror and(i+1)*3 or 24-i*3
   if r.down then h=-h end
   box(a+.05,r.down and -25 or 0,n+.4,b-.05,h,f-.2,stone)
  end
  for _,zz in ipairs{n+.4,f-1.1}do
   local h0,h1=r.mirror and 11 or 32,r.mirror and 32 or 11
   if r.down then h0,h1=-16,5 end
   local a,b,c,d={x+l+.2,h0,z+zz},{x+l+31.8,h1,z+zz},{x+l+31.8,h1,z+zz+.7},{x+l+.2,h0,z+zz+.7}
   emit({a,b,c,d},rail,1)
   emit({{a[1],a[2]-1,a[3]},{d[1],d[2]-1,d[3]},{c[1],c[2]-1,c[3]},{b[1],b[2]-1,b[3]}},rail,.65)
   emit({a,d,{d[1],d[2]-1,d[3]},{a[1],a[2]-1,a[3]}},rail,.8)
   emit({c,b,{b[1],b[2]-1,b[3]},{c[1],c[2]-1,c[3]}},rail,.8)
   emit({b,a,{a[1],a[2]-1,a[3]},{b[1],b[2]-1,b[3]}},rail,.8)
   emit({d,c,{c[1],c[2]-1,c[3]},{d[1],d[2]-1,d[3]}},rail,.8)
   box(l+.5,h0-8,zz,l+1.2,h0,zz+.7,rail);box(l+30.8,h1-8,zz,l+31.5,h1,zz+.7,rail)
  end
  if r.down then
   -- Keep the native approach column level beside the closed recessed well.
   local uv=assert(uvFor(p.ts,r.ground))
   for yy=n,p.d-1,16 do emit({{x+32,0,z+yy},{x+48,0,z+yy},{x+48,0,z+yy+16},{x+32,0,z+yy+16}},uv,1)end
   box(l,-25,n,l+.7,0,f,stone)
   box(l,-25,n,l+32,0,n+.35,stone);box(l,-25,f-.35,l+32,0,f,stone)
  end
 elseif r.kind=='towerRelief'then
  local wall=sample(3,18);box(.2,0,p.d-15.8,p.w-.2,32,p.d-.2,wall)
  front(0,0,p.w,p.d,.2,0,p.w-.2,32,p.d-.18)
 elseif r.kind=='towerDoor'then
  local wall=sample(2,12)
  box(.2,0,.2,16,32,31.8,wall);box(32,0,.2,47.8,32,31.8,wall)
  box(16,26,.2,32,32,31.8,wall)
  front(0,0,16,32,.2,0,15.9,32,31.82)
  front(32,0,16,32,32.1,0,47.8,32,31.82)
  front(16,0,16,32,16,0,32,26,30.7)
 elseif r.kind=='towerCounter'then
  for _,q in ipairs(r.solids)do local l,n=q[1]*16,q[2]*16
   local mat=sample(l+7,n+5);local trim=sample(l+3,n+14)
   box(l+.15,0,n+.15,l+15.85,7,n+15.85,trim)
   box(l+.05,7,n+.05,l+15.95,9,n+15.95,mat)
   top(l,n,16,8,l+.05,n+.05,l+15.95,n+15.95,9.02)
   front(l,n+8,16,8,l+.15,0,l+15.85,7,n+15.86)
  end
 elseif r.kind=='towerTerminal'or r.kind=='towerConsole'or r.kind=='towerScreen'then
  local wide=p.w;local anchor=r.anchor or 16
  local case=sample(math.min(wide-1,5),math.min(p.d-1,17));local dark=sample(math.min(wide-1,9),math.min(p.d-1,23))
  local base=r.kind=='towerScreen'and 11 or 0;local H=r.kind=='towerScreen'and 30 or 27
  box(1,base,anchor+1,wide-1,H,math.min(p.d-.3,anchor+14),case)
  box(2,base+2,anchor+13,wide-2,H-2,anchor+14,dark)
  front(0,0,wide,math.min(p.d,32),2,base+2,wide-2,H-2,anchor+14.02)
  for xx=5,wide-5,5 do box(xx,H-6,anchor+.8,xx+.6,H-2,anchor+1.1,dark)end
 elseif r.kind=='towerPiers'then
  local mat=sample(8,5);local edge=sample(3,14)
  for n=0,p.d-16,16 do
   local N=12;local function ring(y,radius)
    local ps={};for i=0,N-1 do local a=i*math.pi*2/N;ps[#ps+1]={x+8+math.cos(a)*radius,y,z+n+8+math.sin(a)*radius}end;return ps
   end
   local low,high=ring(1,6.5),ring(12,6.5)
   for i=1,N do local j=i%N+1;emit({high[i],high[j],low[j],low[i]},edge,.8)
    emit({{x+8,12,z+n+8},high[i],high[j],{x+8,12,z+n+8}},mat,1)
    emit({{x+8,1,z+n+8},low[j],low[i],{x+8,1,z+n+8}},edge,.65)
   end
   box(2,0,n+2,14,1,n+14,edge)
  end
 end
end
-- Animated native frames replace the static pane at the identical inset.
function M.doorSurface(p,tx,ty)
 if not p or p.recipe.kind~='towerDoor'or tx~=p.cx+1 or ty~=p.cy+1 then return end
 local x,z=p.cx*16,p.cy*16
 return {w=16,h=32,sourceX=x+16,sourceY=z,base=p.groundHeight or 0,
  vertices={{x+16,26,z+30.7},{x+32,26,z+30.7},{x+32,0,z+30.7},{x+16,0,z+30.7}}}
end
local frWalls={[0x288]=true,[0x289]=true,[0x28a]=true,[0x28b]=true,[0x28c]=true,[0x290]=true,[0x291]=true,[0x292]=true,[0x294]=true,[0x2e9]=true,[0x2ea]=true,[0x2eb]=true,[0x2ed]=true,[0x2f1]=true,[0x2f2]=true,[0x2f3]=true,[0x2f5]=true}
local hoennWalls={[0x209]=true,[0x211]=true}
local frFloors={[0x281]=true,[0x283]=true,[0x284]=true,[0x285]=true,[0x286]=true,[0x287]=true,[0x296]=true,[0x2b1]=true,[0x2b2]=true,[0x2cc]=true,[0x2cd]=true,[0x2cf]=true,[0x2d2]=true,[0x2d3]=true,[0x2d4]=true,[0x2d5]=true,[0x2d6]=true,[0x2da]=true,[0x2db]=true,[0x2dc]=true,[0x2ee]=true,[0x2ef]=true,[0x2f6]=true,[0x2f7]=true,[0x2fe]=true,[0x2ff]=true,[0x38a]=true}
local hoennFloors={[0x200]=true,[0x202]=true,[0x203]=true,[0x204]=true,[0x205]=true,[0x20d]=true,[0x229]=true,[0x277]=true,[0x281]=true}
-- All five native source families share these exact wall bands. Collision
-- still gates walls; floors, symbols, doors and puzzle cells stay native.
function M.shape(primary,secondary,mid,collision)
 if primary~='building'then return end
 local fr=secondary=='rom_082d5094'
 local hoenn=secondary=='battle_frontier'or secondary=='battle_tower'
 if not fr and not hoenn then return end
 local walls=fr and frWalls or hoennWalls
 if walls[mid]and collision==7 then return {kind='roomWall',ground=fr and(mid>=0x2e9 and 0x2ee or 0x281)or 0x200}end
 local floors=fr and frFloors or hoennFloors
 if floors[mid]and collision==0 then return {kind='flat',reviewedSurface=true}end
end
return M
