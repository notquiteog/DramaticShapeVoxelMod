-- Authored furniture components. Coordinates are local world pixels; artwork
-- rectangles refer to the complete native drawing, never a replacement atlas.
-- Both adapters use these closed components, preserving native palette/art.
local M={}
function M.draw(id,A)
 local B,S,T=A.box,A.source,A.sample
 local function front(r,l,b,rr,h,z)
  S(r[1],r[2],r[3],r[4],{l,h,z},{rr,h,z},{rr,b,z},{l,b,z})
 end
 local function top(r,l,n,rr,s,h)
  S(r[1],r[2],r[3],r[4],{l,h,n},{rr,h,n},{rr,h,s},{l,h,s})
 end
 local function desk(l,n,r,s,h,mat)
  B(l,h-1.2,n,r,h,s,mat)
  for _,x in ipairs({l+1,r-3})do for _,z in ipairs({n+1,s-3})do B(x,0,z,x+2,h-1.2,z+2,mat)end end
  B(l+1,h-3,n+1,r-1,h-1.2,n+2,mat)
 end
 -- The recessed face is inset behind a bevelled bezel, with a tapered CRT
 -- shell, pedestal, rear vents and a closed back visible in an orbit.
 local function crt(l,n,w,b,h,face,case,dark)
  local f=n+7
  B(l+1,b,n+1,l+w-1,h-1,f-1,case)
  B(l+2,h-1,n+2,l+w-2,h,f-1,case)
  B(l,b+1,f-1,l+1,h-1,f,case);B(l+w-1,b+1,f-1,l+w,h-1,f,case)
  B(l+1,b,f-1,l+w-1,b+1,f,case);B(l+1,h-1,f-1,l+w-1,h,f,case)
  front(face,l+1,b+1,l+w-1,h-1,f-.02)
  for y=b+2,h-3,2 do B(l+w-1.03,y,n+2,l+w-.97,y+.5,f-2,dark)end
  B(l+w*.36,b-1,n+3,l+w*.64,b,n+5,case)
  B(l+2,b-1.5,n+2,l+w-2,b-1,n+6,case)
 end
 local function keyboard(r,l,n,w,d,h,mat)
  B(l,h-.6,n,l+w,h,n+d,mat)
  -- Raised rear gives the keys a shallow typing angle.
  S(r[1],r[2],r[3],r[4],{l,h+.6,n},{l+w,h+.6,n},{l+w,h+.05,n+d},{l,h+.05,n+d})
 end
 local function shelves(l,n,w,d,h,rows,mat,dark)
  local f=n+d
  B(l,0,n,l+w,h,n+1,mat)
  B(l,0,n,l+1,h,f,mat);B(l+w-1,0,n,l+w,h,f,mat)
  B(l,0,n,l+w,1.5,f,mat);B(l,h-1,n,l+w,h,f+.3,mat)
  for _,q in ipairs(rows)do
   local y0,y1,rect=q[1],q[2],q[3]
   B(l+1,y0,n+1,l+w-1,y1,f-1.2,dark)
   front(rect,l+1,y0,l+w-1,y1,f-1.18)
   B(l+.5,y0-.7,n+1,l+w-.5,y0,f+.2,mat)
  end
 end
 local function cushion(l,n,w,d,rect,mat,edge)
  B(l+2,0,n+2,l+w-2,.7,n+d-2,edge)
  B(l+1,.7,n+1,l+w-1,1.8,n+d-1,mat)
  B(l+2,1.8,n+2,l+w-2,2.5,n+d-2,mat)
  top(rect,l+2,n+2,l+w-2,n+d-2,2.52)
 end
 local function console(l,n,rect,controller,mat,dark)
  B(l,0,n,l+11,1.4,n+6,mat);B(l+1,1.4,n,l+10,2,n+5,mat)
  top(rect,l+.5,n,l+10.5,n+5,2.02)
  B(l+1,0,n+9,l+7,.8,n+12,dark)
  top(controller,l+1,n+9,l+7,n+12,.82)
  -- The controller cable lies on the rug, with two right-angle bends.
  B(l+9,.04,n+5,l+9.3,.3,n+10,dark)
  B(l+6,.04,n+9.7,l+9.3,.3,n+10,dark)
 end
 if id=='fr_bed' then
  local metal,white=T(15,16),T(17,25)
  B(13,0,16,15,7,46,metal);B(33,0,16,35,7,46,metal)
  B(13,5,15,35,8,17,metal);B(13,0,44,35,3,46,metal)
  B(15,2,18,33,4.5,44,white)
  top({14,24,20,19},14,23,34,44,4.52)
  B(16,4.5,18,32,5.8,23,white)
  top({16,20,16,4},16,18,32,23,5.82)
 elseif id=='fr_room_pc' then
  local wood,case,dark=T(17,22),T(3,13),T(7,22)
  desk(1,32,31,44,7,wood)
  top({16,16,16,7},16,33,31,43,7.02)
  crt(1,31,14,9,21,{2,17,12,9},case,dark)
  keyboard({2,27,12,4},2,39,12,4,7.1,case)
  B(3,0,44,5,4,48,wood);B(11,0,44,13,4,48,wood)
  B(3,3,43,13,4,47,T(7,40));top({3,38,10,6},3,43,13,47,4.02)
  B(3,4,47,13,9,48,T(7,40))
 elseif id=='fr_wood_chair' then
  local wood=T(2,7)
  for _,x in ipairs({2,12})do for _,z in ipairs({19,26})do B(x,0,z,x+1,4,z+1,wood)end end
  B(2,3,18,13,4.5,27,wood);top({2,16,11,6},2,18,13,27,4.52)
  B(2,4,18,3,13,19,wood);B(12,4,18,13,13,19,wood)
  B(2,10,18,13,13,19,wood);front({2,8,11,4},2,10,13,13,19.02)
 elseif id=='fr_console' then
  local mat,dark=T(2,7),T(2,23)
  B(1,0,7,15,6,17,mat);front({1,17,14,6},1,0,15,6,17.02)
  crt(1,7,14,7.5,19,{2,8,12,8},mat,dark)
  console(2,25,{2,27,12,6},{2,36,6,3},T(5,29),dark)
 elseif id=='fr_television' then
  local case,dark=T(1,19),T(9,33)
  shelves(2,27,28,10,10,{{2,8,{3,34,26,6}}},case,dark)
  crt(2,26,28,12,29,{3,13,26,16},case,dark)
 elseif id=='fr_living_tv' then
  local case,dark=T(1,25),T(4,31)
  B(1,0,27,15,6,39,case);front({1,34,14,7},1,0,15,6,39.02)
  crt(1,27,14,7.5,20,{1,26,14,8},case,dark)
  -- Native wall note stays flat against the backing, above the television.
  front({8,9,7,8},8,23,15,31,31.85)
 elseif id=='fr_cupboard' then
  local wood,dark=T(2,14),T(4,37)
  shelves(1,28,22,11,25,{{3,9,{2,34,19,6}},{10,18,{2,25,19,8}}},wood,dark)
  front({2,12,19,12},2,18,22,28,39.02)
  -- Telephone is a separate handset and cradle beside the cabinet.
  B(25,0,31,31,7,39,wood);B(25,7,32,31,8,38,T(27,29))
  B(25,8,32,27,10,38,T(25,28));B(29,8,32,31,10,38,T(25,28))
  top({25,27,6,12},25,32,31,38,8.02)
 elseif id=='fr_kitchen' then
  local case=T(1,21);B(1,0,19,31,7,30,case);B(.5,7,18,31.5,8,30.5,T(3,4))
  front({1,17,30,10},1,0,31,7,30.52);top({1,1,30,15},1,18,31,30,8.02)
  B(22,8,18,23,12,19,T(21,5));B(22,11,18,26,12,19,T(21,5))
  for _,x in ipairs({18,28})do B(x,8,19,x+1,9,20,T(21,5))end
 elseif id=='fr_center_pc' or id=='fr_upper_pc' then
  local case,dark=T(2,20),T(4,28)
  B(3,0,29,13,2,42,dark);B(2,2,30,14,8,40,case)
  front({2,36,12,6},2,2,14,8,40.02)
  B(1,8,27,15,9.5,41,case)
  crt(1,26,14,11,24,{2,17,12,10},case,dark)
  keyboard({2,29,12,6},2,34,12,6,9.6,case)
 elseif id=='fr_lab_pc' then
  local case,dark,wood=T(1,3),T(6,8),T(2,20)
  desk(1,10,31,24,7,wood)
  crt(1,12,14,9,22,{2,4,11,8},case,dark)
  keyboard({2,13,12,3},2,17,12,6,7.1,case)
  B(16,7,10,22,22,19,case);front({16,0,6,16},16,7,22,22,19.02)
  top({23,6,8,11},23,11,31,23,7.04)
 elseif id=='fr_lab_terminal' then
  local case=T(1,22)
  B(1,0,29,15,10,41,case);front({1,30,14,10},1,0,15,10,41.02)
  B(1,10,27,15,16,29,case)
  S(1,19,14,11,{1,16,29},{15,16,29},{15,10,39},{1,10,39})
 elseif id=='fr_lab_server' then
  local case,dark=T(1,13),T(3,24)
  shelves(1,31,14,10,26,{{2,12,{1,29,14,13}},{14,24,{1,12,14,15}}},case,dark)
 elseif id=='fr_lab_books' then
  shelves(1,13,30,10,22,{{3,10,{2,12,28,6}},{12,19,{2,5,28,6}}},T(1,2),T(3,13))
 elseif id=='fr_mart_sidecase' then
  local case=T(10,14)
  B(3,0,14,15,6,59,case);B(12,6,11,15,12,60,case)
  for _,z in ipairs({16,39})do
   B(2,6,z,12,7,z+20,case);top({3,z+1,8,18},3,z+1,11,z+19,7.02)
   B(2,7,z,3,8.5,z+20,case)
  end
 elseif id=='fr_lab_free_books' then
  local G={sample=function(x,y)return T(x,y+16)end,
   box=function(l,b,n,r,h,f,uv)B(l,b,n+16,r,h,f+16,uv)end,
   source=function(x,y,w,h,a,b,c,d)
    for _,p in ipairs({a,b,c,d})do p[3]=p[3]+16 end
    S(x,y+16,w,h,a,b,c,d)
   end}
  return M.draw('fr_lab_books',G)
 elseif id=='fr_mart_cooler' then
  for j=0,1 do local x=j*24
   shelves(x+1,28,22,12,22,{{4,11,{x+3,29,18,6}},{12,19,{x+3,23,18,6}}},T(x+2,18),T(x+4,34))
   B(x+2,21,28,x+22,24,40,T(x+2,15))
   front({x+2,15,20,6},x+2,21,x+22,24,40.02)
   B(x+20,8,40,x+21,17,40.5,T(x+2,18))
  end
 elseif id=='fr_mart_island' then
  local case,dark=T(10,14),T(2,30)
  B(3,0,14,29,6,59,case);B(13,6,11,19,12,60,case)
  for _,q in ipairs({{2,8},{19,29}})do
   local l,r=q[1],q[2]
   for _,z in ipairs({16,39})do
    B(l,6,z,r,7,z+20,case);B(l+1,7,z+1,r-1,8,z+19,dark)
    top({l+1,z+1,r-l-2,18},l+1,z+1,r-1,z+19,8.02)
    B(l,7,z,l+1,8.5,z+20,case);B(r-1,7,z,r,8.5,z+20,case)
   end
  end
 elseif id=='gb_picture' then
  local frame=T(1,1)
  B(1,8,15.92,15,23,16.2,frame);front({2,2,12,12},2,9,14,22,16.22)
 elseif id=='gb_short_books' then
  shelves(1,6,14,9,13,{{2,10,{1,4,14,8}}},T(1,1),T(2,8))
 elseif id=='gb_link_controls' then
  local case,dark=T(1,1),T(4,8)
  B(1,0,16,31,7,25,case)
  keyboard({1,4,14,9},1,18,14,6,7.1,case)
  crt(17,16,14,9,21,{17,1,14,11},case,dark)
  front({1,12,14,4},1,3,15,7,25.02)
 elseif id=='gb_bed' then
  local case,linen=T(1,1),T(5,12)
  B(1,0,2,3,7,30,case);B(13,0,2,15,7,30,case)
  B(2,4,1,14,8,3,case);B(2,0,28,14,3,30,case)
  B(3,1.5,5,13,4,28,linen);top({2,9,12,17},2,7,14,28,4.02)
  B(4,4,4,12,5.5,8,linen);top({4,7,8,4},4,4,12,8,5.52)
 elseif id=='gb_counter' then
  local case=T(2,10)
  B(0,0,9,16,5.5,15,case);B(0,5.5,8.5,16,7,15.5,T(2,2))
  top({0,0,16,8},0,8.5,16,15.5,7.02);front({0,8,16,8},0,0,16,5.5,15.52)
 elseif id=='gb_desk' then
  local wood,case,dark=T(1,25),T(3,5),T(4,8)
  desk(0,13,32,26,6,wood)
  crt(1,12,14,8,20,{2,6,12,10},case,dark)
  keyboard({1,17,14,5},1,20,14,5,6.05,case)
  B(18,6,17,30,8,23,case);top({17,10,14,10},18,17,30,23,8.02)
  B(19,6,24,25,6.8,27,dark);top({18,18,8,4},19,24,25,27,6.82)
  B(28,6,22,28.3,6.3,26,dark);B(25,6,25.7,28.3,6.3,26,dark)
 elseif id=='gb_tv' then
  local case,dark=T(2,1),T(3,12)
  B(2,0,14,14,5,23,case);front({2,18,12,5},2,0,14,5,23.02)
  crt(1,13,14,6.5,20,{2,5,12,12},case,dark)
 elseif id=='gb_pc' then
  local case,dark=T(2,2),T(4,10)
  B(2,0,13,14,7,23,case);front({2,18,12,5},2,0,14,7,23.02)
  crt(1,10,14,8,21,{2,4,12,10},case,dark)
  keyboard({1,15,14,5},1,18,14,5,7.1,case)
 elseif id=='gb_lab_pc' then
  local case,dark,wood=T(1,1),T(4,8),T(1,17)
  desk(1,8,31,21,6,wood)
  crt(1,7,14,8,20,{2,3,12,10},case,dark)
  keyboard({2,14,12,3},2,15,12,5,6.1,case)
  B(18,6,9,30,8,18,case);top({17,2,14,13},18,9,30,18,8.02)
 elseif id=='gb_elm_desk' then
  local wood,case,dark=T(2,11),T(18,1),T(19,4)
  desk(1,13,31,24,6,wood);crt(17,10,14,8,19,{17,1,14,7},case,dark)
  top({2,10,13,8},2,14,15,22,6.02);keyboard({18,11,12,5},18,18,12,5,6.1,case)
  B(2,0,25,4,4,31,wood);B(12,0,25,14,4,31,wood)
  B(2,3,25,14,4,31,case);B(2,4,30,14,9,31,wood)
 elseif id=='gb_books' or id=='gb_mart_shelf' then
  shelves(1,20,14,10,26,{{3,12,{1,16,14,7}},{14,24,{1,7,14,7}}},T(1,1),T(2,15))
 elseif id=='gb_mart_cooler' then
  shelves(1,20,14,10,25,{{3,11,{1,21,14,8}},{13,22,{1,9,14,10}}},T(1,1),T(2,16))
  B(12,6,30,13,18,30.4,T(1,1))
 elseif id=='gb_mart_display' then
  local case=T(1,1)
  B(1,0,5,30,5,29,case);B(13,5,4,17,16,30,case)
  for _,q in ipairs({{1,12},{18,30}})do
   B(q[1],5,6,q[2],7,28,case);top({q[1],5,q[2]-q[1],22},q[1],6,q[2],28,7.02)
  end
 elseif id=='gb_seat' then cushion(1,1,14,13,{2,2,12,9},T(7,5),T(3,13))
 elseif id=='gb_receiver' then
  local case=T(1,9)
  B(3,0,13,13,7,23,case);B(2,7,12,14,13,22,case)
  B(4,13,13,12,16,21,case);B(6,16,14,10,17,20,case)
  front({3,8,10,10},3,6,13,14,22.02)
 elseif id=='gb_table' then
  desk(1,1,31,21,6,T(1,20));top({1,1,30,17},1,1,31,21,6.02)
 elseif id=='gb_kitchen' then
  local case=T(1,17)
  B(0,0,13,32,7,24,case);B(0,7,12,32,8,24,T(1,9))
  top({0,8,32,8},0,12,32,24,8.02);front({0,16,32,8},0,0,32,7,24.02)
  B(24,8,12,25,12,13,case);B(21,11,12,25,12,13,case)
  B(33,0,13,47,23,24,T(34,2));front({33,6,14,17},33,0,47,23,24.02)
  B(44,6,24,45,12,24.5,T(34,8))
 elseif id=='gb_healer' then
  local case=T(3,5)
  B(3,0,9,29,4,29,case);B(2,4,8,30,6,30,case)
  top({2,7,28,21},2,10,30,29,6.02)
  B(4,6,16,28,12,19,case);front({4,0,24,7},4,6,28,12,19.02)
 else return false end
 return true
end
return M
