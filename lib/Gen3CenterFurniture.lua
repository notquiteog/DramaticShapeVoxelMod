-- Native Center fixtures; complete drawings own their wall/floor aprons.
local M={}
M.recipes={
 {name='center_escalator_up',rows={{0x2D0,0x2D1},{0x2D8,0x2D9},{0x2E0,0x2E1}},kind='escalator'},
 {name='center_escalator_down',rows={{0x2DB,0x2DC},{0x2E3,0x2E4},{0x2EB,0x2EC}},kind='escalator',down=true},
 {name='center_front_desk',rows={{0x2B9,0x2BC,0x2BC,0x298,0x2BC,0x2BC,0x2BD}},kind='centerCounter',h=7},
 {name='center_counter_left',rows={{0x2A9},{0x2B1}},kind='centerWing',h=7},
 {name='center_counter_right',rows={{0x2AD},{0x2B5}},kind='centerWing',h=7},
}
-- The upper floor shares the native wall and counter palette; keep every
-- whole desk in front of the wall, with its original screen and keypad art.
for _,a in ipairs({{0x284,0x28C},{0x2D6,0x2DE},{0x2D7,0x2DF},{0x284,0x2FE}})do
 M.recipes[#M.recipes+1]={name='center_wall_'..a[2],rows={{a[1]},{a[2]}},kind='centerWall'}
end
M.recipes[#M.recipes+1]={name='center_wall_upper',rows={{0x284}},kind='centerWall',upper=true}
M.recipes[#M.recipes+1]={name='center_2f_left_counter',rows={{0x2DA,0x328,0x327},{0x2E9,0x2E9,0x2F8}},kind='centerUpperCounter'}
M.recipes[#M.recipes+1]={name='center_2f_left_return',rows={{0x376},{0x37E}},kind='centerUpperCounter'}
for _,last in ipairs({0x366,0x367})do
 M.recipes[#M.recipes+1]={name='center_2f_link_counter_'..last,rows={{0x302,0x363,0x365},{0x303,0x2E9,last}},kind='centerUpperCounter'}
end
for _,a in ipairs({{0x326,0x62,0x2F6}})do
 M.recipes[#M.recipes+1]={name='center_2f_terminal_'..a[3],rows={{a[1]},{a[2]},{a[3]}},kind='centerUpperTerminal'}
end
M.recipes[#M.recipes+1]={name='center_2f_gate',rows={{0x2F9}},kind='centerGate'}
M.recipes[#M.recipes+1]={name='center_2f_plant',rows={{0x300},{0x301}},kind='plant',h=24,cutout=true}
for _,r in ipairs(M.recipes)do r.primary='building';r.pair='network';r.ground=0x281
 if r.kind=='escalator'then r.noGround=true end
end
local aliases={}
for _,a in ipairs({{0x2D0,0x30A,0x308},{0x2D1,0x30B,0x309},{0x2D8,0x312,0x310},
 {0x2D9,0x313,0x311},{0x2E3,0x316,0x314},{0x2E4,0x317,0x315},{0x2EB,0x31E,0x31C}})do
 for i=2,3 do aliases[a[i]]=a[1]end
end
function M.canonical(mid)return aliases[mid] or mid end
function M.append(p,source,box,sample,emit,uvFor)
 local r,x,z=p.recipe,p.cx*16,p.cy*16
 -- The generic furniture primitive predates orbit cameras and has five faces.
 -- Close only this adapter's solids; designed furniture closes its own boxes.
 local openBox=box
 box=function(a,b,c,d,e,f,t)
  openBox(a,b,c,d,e,f,t)
  emit({{a,b,f},{d,b,f},{d,b,c},{a,b,c}},t,.6)
 end
 local function prism(points,bottom,top,material)
  local cx,cz=0,0
  for _,v in ipairs(points)do cx=cx+v[1]/#points;cz=cz+v[2]/#points end
  for i,a in ipairs(points)do
   local b=points[i%#points+1]
   emit({{x+a[1],top,z+a[2]},{x+b[1],top,z+b[2]},
    {x+b[1],bottom,z+b[2]},{x+a[1],bottom,z+a[2]}},material,.72)
   emit({{x+cx,top,z+cz},{x+a[1],top,z+a[2]},
    {x+b[1],top,z+b[2]},{x+cx,top,z+cz}},material,.88)
   emit({{x+cx,bottom,z+cz},{x+b[1],bottom,z+b[2]},
    {x+a[1],bottom,z+a[2]},{x+cx,bottom,z+cz}},material,.6)
  end
 end
 local function bevel(a,b,c,d,cut,lo,hi,mat)
  prism({{a+cut,b},{c-cut,b},{c,b+cut},{c,d-cut},
   {c-cut,d},{a+cut,d},{a,d-cut},{a,b+cut}},lo,hi,mat)
 end
 if r.kind=='centerWall' then
  local front=z+(r.upper and 16.03 or 32.03)
  local bottom=r.upper and 16 or 0
  box(x,0,front-.1,x+16,32,front,sample(4,12))
  source(0,0,16,r.upper and 16 or 32,{x,32,front+.01},{x+16,32,front+.01},
   {x+16,bottom,front+.01},{x,bottom,front+.01})
  return true
 elseif r.kind=='centerUpperCounter' then
  -- Receptionists stand in the upper source row. Their rotating 16px cards
  -- reach eight pixels in front of that row's footline: start beyond it.
  local w=p.w;local frame=sample(math.min(8,w-1),24)
  box(x+.2,0,z+25,x+w-.2,5,z+31,frame)
  box(x+.2,5,z+25,x+w-.2,7,z+31,sample(math.min(8,w-1),17))
  source(0,14,w,7,{x,7.02,z+25},{x+w,7.02,z+25},{x+w,7.02,z+31},{x,7.02,z+31})
  source(0,21,w,6,{x,5,z+31.02},{x+w,5,z+31.02},{x+w,0,z+31.02},{x,0,z+31.02})
  if w>16 and r.rows[1][1]==0x302 then
   source(w-14,18,13,8,{x+w-14,7.06,z+25},{x+w-1,7.06,z+25},
    {x+w-1,7.06,z+31},{x+w-14,7.06,z+31})
  end
  return true
 elseif r.kind=='centerGate' then
  box(x+1,0,z+2,x+15,5,z+14,sample(2,12))
  box(x+1,5,z+2,x+15,7,z+14,sample(4,3))
  source(1,0,14,10,{x+1,7.02,z+2},{x+15,7.02,z+2},{x+15,7.02,z+14},{x+1,7.02,z+14})
  source(1,10,14,5,{x+1,5,z+14.02},{x+15,5,z+14.02},{x+15,0,z+14.02},{x+1,0,z+14.02})
  return true
 elseif r.kind=='centerUpperTerminal' then
  local frame=sample(2,20)
  box(x+1,0,z+21,x+15,12,z+37,frame)
  box(x+2,12,z+18,x+14,24,z+22,frame)
  source(1,12,14,15,{x+1,24,z+22.02},{x+15,24,z+22.02},{x+15,12,z+22.02},{x+1,12,z+22.02})
  source(1,27,14,8,{x+1,12.02,z+22},{x+15,12.02,z+22},{x+15,12.02,z+36},{x+1,12.02,z+36})
  return true
 elseif r.kind=='escalator' then
  local metal=sample(20,12);local tread=sample(12,24)
  local rail=sample(20,10);local trim=sample(20,9)
  local dark=sample(9,28)
  local floor=uvFor(p.ts,r.ground)
  -- Opening is restricted to the moving flight, never the adjacent floor.
  local function ground(a,b,c,d)
   emit({{x+a,0,z+b},{x+c,0,z+b},{x+c,0,z+d},{x+a,0,z+d}},floor,1)
  end
  ground(0,0,32,16);ground(0,40,32,48);ground(24,16,32,40)
  if r.family=='rse' then
   -- Hoenn's lower drawing row is walking floor, not flight depth.
   -- Keep the full native treads/rails inside the blocked/warp middle row.
   local originalBox=box
   local function depth(v)return z+16+(v-z-16)*2/3 end
   box=function(a,b,n,c,e,f,t)return originalBox(a,b,depth(n),c,e,depth(f),t)end
   ground(0,32,32,40)
  end
  local function height(u)return (r.down and -1 or 1)*math.max(0,(24-u)*.5)end
  for u=0,22,2 do
   local h=height(u+1)
   box(x+u,math.min(-14,h-2),z+20,x+u+2,h,z+37,tread)
   box(x+u,h,z+20,x+u+.35,h+.15,z+37,metal)
  end
  for _,zz in ipairs({17,38})do
   for u=0,30,2 do
    local h=height(u)
    box(x+u,math.min(0,h),z+zz,x+u+2,h+6,z+zz+2,metal)
    box(x+u,h+6,z+zz-.2,x+u+2,h+6.7,z+zz+2.2,trim)
    box(x+u,h+6.7,z+zz-.3,x+u+2,h+7.4,z+zz+2.3,rail)
   end
  end
  -- Recessed well stays closed in reverse and low-angle views.
  box(x,-15,z+19,x+.5,0,z+38,dark)
  return true
 elseif r.kind=='centerMedical' then
  if r.medicalHeadMid then
   -- Hoenn projects the head onto the monitor's lower-right source cell.
   -- Read that public atlas region without claiming the monitor or floor.
   local shell,dark=sample(12,3),sample(6,8)
   bevel(2,2,14,14,1,0,2,sample(6,11))
   box(x+5,2,z+4,x+13,14,z+12,shell)
   box(x+4,14,z+3,x+13,21,z+9,dark)
   local t=uvFor(p.ts,r.medicalHeadMid)
   local function uv(a,b)return {t[1][1]+(t[2][1]-t[1][1])*a/16,t[1][2]+(t[3][2]-t[1][2])*b/16}end
   emit({{x+5,21,z+9.02},{x+12,21,z+9.02},{x+12,15,z+9.02},{x+5,15,z+9.02}},
    {uv(6,10),uv(13,10),uv(13,16),uv(6,16)},1)
   source(6,0,7,2,{x+5,15,z+9.02},{x+12,15,z+9.02},{x+12,14,z+9.02},{x+5,14,z+9.02})
   box(x+2,3,z+4,x+4,12,z+11, sample(2,8))
   source(1,0,3,10,{x+2,12,z+11.02},{x+4,12,z+11.02},{x+4,3,z+11.02},{x+2,3,z+11.02})
   for _,xx in ipairs({8,10})do box(x+xx,2,z+12,x+xx+1,6,z+12.05,dark)end
   return true
  end
  -- The cross-marked medical pedestal is the inner device, not the outer
  -- red counter return (2AD/2B5). Keep the staff aisle behind it open.
  local shell,dark=sample(6,15),sample(5,24)
  bevel(3,18,14,30,1,0,2,sample(3,27))
  box(x+5,2,z+20,x+13,15,z+28,dark)
  box(x+4,14,z+19,x+13,20,z+25,shell)
  source(4,9,9,10,{x+4,20,z+25.02},{x+13,20,z+25.02},
   {x+13,14,z+25.02},{x+4,14,z+25.02})
  box(x+2,3,z+20,x+4,11,z+27,sample(1,22))
  source(0,16,4,10,{x+2,11,z+27.02},{x+4,11,z+27.02},
   {x+4,3,z+27.02},{x+2,3,z+27.02})
  return true
 elseif r.kind=='centerHealer' then
  local white,shadow=sample(r.family=='rse' and 6 or 26,r.family=='rse' and 16 or 19),sample(r.family=='rse' and 3 or 2,r.family=='rse' and 17 or 12)
  -- The short dark source strip is a foot/shadow, not a tall pedestal.
  -- Keep the tray at counter height; the recipe height is also the public
  -- healing-ball anchor, so its six balls follow this physical tray.
  local tray=r.h or 7
  bevel(3,10,29,30,3,0,1.5,shadow)
  bevel(2,9,30,30,3,1.5,tray-.2,white)
  box(x+5,tray-.2,z+12,x+27,tray,z+28,sample(15,15))
  for _,xx in ipairs({2,27})do
   box(x+xx,tray-.2,z+12,x+xx+3,tray+2,z+26,white)
   box(x+xx+.5,tray+2,z+13,x+xx+2.5,tray+2.4,z+17,sample(5,18))
  end
  bevel(4,8,28,12,1,tray,tray+7,white)
  source(4,0,24,9,{x+4,tray+7,z+12.02},{x+28,tray+7,z+12.02},
   {x+28,tray,z+12.02},{x+4,tray,z+12.02})
  source(7,9,18,17,{x+5,tray+.03,z+12},{x+27,tray+.03,z+12},
   {x+27,tray+.03,z+28},{x+5,tray+.03,z+28})
  source(5,26,22,5,{x+5,tray-.2,z+30.02},{x+27,tray-.2,z+30.02},
   {x+27,1.5,z+30.02},{x+5,1.5,z+30.02})
  return true
 elseif r.kind=='centerTable' then
  -- The glass tables have chamfered corners in both editions. Model the rim
  -- and underside around real glass, rather than painting corners on a box.
  local rim,glass=sample(3,13),sample(14,10)
  for _,a in ipairs({{5,5},{24,5},{5,23},{24,23}})do
   box(x+a[1],0,z+a[2],x+a[1]+2,5.5,z+a[2]+2,rim)
  end
  bevel(2,2,30,29,5,5,6.5,rim)
  bevel(3,3,29,28,4,6.5,7,glass)
  -- Preserve the central source reflection without duplicating its drawn
  -- beveled frame across the physical rim.
  source(7,5,18,19,{x+7,7.02,z+5},{x+25,7.02,z+5},
   {x+25,7.02,z+24},{x+7,7.02,z+24})
  return true
 elseif r.kind=='centerSeat' then
  local scale=r.walkablePad and .48 or 1
  local originalBox,originalSource=box,source
  box=function(a,b,c,d,e,f,t)return originalBox(a,b*scale,c,d,e*scale,f,t)end
  source=function(sx,sy,sw,sh,a,b,c,d)
   for _,q in ipairs({a,b,c,d})do q[2]=q[2]*scale end
   return originalSource(sx,sy,sw,sh,a,b,c,d)
  end
  local frame,cushion=sample(4,13),sample(8,5)
  box(x+3,0,z+3,x+13,.7,z+13,frame)
  box(x+2,.7,z+2,x+14,1.8,z+13,cushion)
  box(x+3,1.8,z+3,x+13,2.5,z+12,cushion)
  source(2,2,12,10,{x+3,2.52,z+3},{x+13,2.52,z+3},
   {x+13,2.52,z+12},{x+3,2.52,z+12})
  return true
 elseif r.kind=='centerCounter' then
  -- Nurse Joy's feet are at the previous cell boundary. Leave her complete
  -- camera-facing sprite clear, including at a side-on orbit.
  local frame=sample(24,12)
  bevel(1,9,p.w-1,15,2,0,5,frame)
  bevel(1,9,p.w-1,15,2,5,7,sample(24,3))
  -- Keep the central source service plate, without projecting the drawn
  -- curved front apron onto the horizontal cap a second time.
  source(p.w/2-7,0,14,9,{x+p.w/2-7,7.02,z+9},{x+p.w/2+7,7.02,z+9},
   {x+p.w/2+7,7.02,z+14},{x+p.w/2-7,7.02,z+14})
  source(3,9,p.w-6,6,{x+3,5,z+15.02},{x+p.w-3,5,z+15.02},
   {x+p.w-3,0,z+15.02},{x+3,0,z+15.02})
  return true
 elseif r.kind=='centerWing' then
  local cap=sample(8,15)
  box(x+1,0,z+12,x+15,5,z+41,sample(3,31))
  box(x+1,5,z+12,x+15,7,z+41,cap)
  if r.family=='rse' then
   -- Hoenn's rounded red desk ornament and dark pedestal.
   local right=r.rows[1][1]==0x249
   local dark=right and sample(14,22)or sample(3,28)
   local red=right and sample(4,28)or sample(8,26)
   bevel(3,30,13,39,2,7,9,dark)
   -- Lathed cap, not stacked square blocks; all rings close at the poles.
   local rings={{3.5,9},{5,10},{5,11},{4.3,13},{2.5,14.5},{0,15}}
   for k=1,#rings-1 do for i=0,11 do
    local a,b=i*math.pi/6,(i+1)*math.pi/6
    local r0,h0=rings[k][1],rings[k][2];local r1,h1=rings[k+1][1],rings[k+1][2]
    emit({{x+8+r1*math.cos(a),h1,z+34.5+r1*math.sin(a)},
     {x+8+r1*math.cos(b),h1,z+34.5+r1*math.sin(b)},
     {x+8+r0*math.cos(b),h0,z+34.5+r0*math.sin(b)},
     {x+8+r0*math.cos(a),h0,z+34.5+r0*math.sin(a)}},red,.88)
   end end
   for i=0,11 do
    local a,b=i*math.pi/6,(i+1)*math.pi/6
    emit({{x+8,9,z+34.5},{x+8+3.5*math.cos(b),9,z+34.5+3.5*math.sin(b)},
     {x+8+3.5*math.cos(a),9,z+34.5+3.5*math.sin(a)},{x+8,9,z+34.5}},dark,.6)
   end
  else
   -- FR/LG has a tan flowerpot with green leaves and blue/white/coral
   -- blossoms. Preserve that design instead of replacing it with a ball.
   bevel(4,31,12,39,1,7,11,sample(10,31))
   bevel(3,30,13,40,1,10,11.5,sample(5,31))
   for _,a in ipairs({{4,32},{10,32},{5,37},{10,37}})do
    box(x+a[1],11.5,z+a[2],x+a[1]+2,13,z+a[2]+2,sample(3,29))
   end
   local function petal(cx,cy,cz,rx,ry,rz,material)
    local function point(a,b)return {x+cx+rx*math.cos(b)*math.cos(a),cy+ry*math.sin(b),z+cz+rz*math.cos(b)*math.sin(a)}end
    for j=0,3 do for i=0,7 do
     local a,b=i*math.pi/4,(i+1)*math.pi/4;local lo,hi=-math.pi/2+j*math.pi/4,-math.pi/2+(j+1)*math.pi/4
     emit({point(a,hi),point(b,hi),point(b,lo),point(a,lo)},material,.9)
    end end
   end
   for _,a in ipairs({{5,32,14},{9,33,15},{6,36,15},{10,37,14}})do
    for i=0,3 do
     local angle=i*math.pi/2
     petal(a[1]+math.cos(angle),a[3],a[2]+math.sin(angle),1,.7,1,
      sample(5,i==0 and 22 or 23))
    end
    petal(a[1],a[3]+.6,a[2],.7,.5,.7,cap)
   end
  end
  return true
 end
 return false
end
return M
