-- Native Center fixtures; complete drawings own their wall/floor aprons.
local M={}
M.recipes={
 {name='center_escalator_up',rows={{0x2D0,0x2D1},{0x2D8,0x2D9},{0x2E0,0x2E1}},kind='escalator'},
 {name='center_escalator_down',rows={{0x2DB,0x2DC},{0x2E3,0x2E4},{0x2EB,0x2EC}},kind='escalator',down=true},
 {name='center_front_desk',rows={{0x2B9,0x2BC,0x2BC,0x298,0x2BC,0x2BC,0x2BD}},kind='centerCounter',h=7},
 {name='center_counter_left',rows={{0x2A9},{0x2B1}},kind='centerWing',h=7},
 {name='center_counter_right',rows={{0x2AC},{0x2B4}},kind='centerWing',h=7},
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
 if r.kind=='centerWall' then
  local front=z+32.03
  local bottom=r.upper and 16 or 0
  box(x,bottom,front-.1,x+16,32,front,sample(4,4))
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
 elseif r.kind=='centerHealer' then
  local white,shadow=sample(6,12),sample(4,23)
  box(x+3,0,z+10,x+29,6,z+30,shadow)
  box(x+2,6,z+9,x+30,13,z+30,white)
  box(x+4,13,z+8,x+28,20,z+12,white)
  source(4,0,24,9,{x+4,20,z+12.02},{x+28,20,z+12.02},{x+28,13,z+12.02},{x+4,13,z+12.02})
  source(3,9,26,17,{x+3,13.03,z+12},{x+29,13.03,z+12},{x+29,13.03,z+28},{x+3,13.03,z+28})
  source(3,26,26,5,{x+3,13,z+30.02},{x+29,13,z+30.02},{x+29,6,z+30.02},{x+3,6,z+30.02})
  return true
 elseif r.kind=='centerSeat' then
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
  box(x+1,0,z+9,x+p.w-1,5,z+15,frame)
  box(x+1,5,z+9,x+p.w-1,7,z+15,sample(24,3))
  source(1,0,p.w-2,9,{x+1,7.02,z+9},{x+p.w-1,7.02,z+9},{x+p.w-1,7.02,z+15},{x+1,7.02,z+15})
  source(1,9,p.w-2,6,{x+1,5,z+15.02},{x+p.w-1,5,z+15.02},{x+p.w-1,0,z+15.02},{x+1,0,z+15.02})
  return true
 elseif r.kind=='centerWing' then
  box(x+1,0,z+12,x+15,5,z+41,sample(5,29))
  box(x+1,5,z+12,x+15,7,z+41,sample(8,15))
  source(1,9,14,23,{x+1,7.02,z+12},{x+15,7.02,z+12},{x+15,7.02,z+41},{x+1,7.02,z+41})
  return true
 end
 return false
end
return M
