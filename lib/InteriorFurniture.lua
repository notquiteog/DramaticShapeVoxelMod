-- Authored furniture components. Coordinates are local world pixels; artwork
-- rectangles refer to the complete native drawing, never a replacement atlas.
-- Both adapters use these closed components, preserving native palette/art.
local M={}
-- Authored placements: ROM front/shadow rows are not extra floor depth.
-- Move whole component assemblies; keep all source crops and proportions.
M.placement={
 fr_room_dresser={z=-16,back=0},fr_room_pc={z=0,back=18},
 fr_home_bookcase={z=0,back=18},fr_sevii_wardrobe={z=-10,back=17},fr_lorelei_display={z=-9,back=5},
 fr_department_glass={z=9,back=17},fr_department_stock={z=9,back=17},
 em_space_controls={z=-16,back=0},em_home_sofa={z=-14,back=0},
 em_museum_glass={z=2,back=16},
 em_home_appliance={z=-16,back=1},em_fortree_drawers={z=-15,back=0},
 em_lab_books={z=-8,back=18},em_lab_computer={z=-11,back=15},
 em_lab_desk={z=-11,back=0},em_lab_server={z=-9,back=18},
 fr_mart_cooler={z=-13,back=19},
 fr_lab_pc={z=-9,back=1},fr_lab_terminal={z=-10,back=17},
 fr_lab_server={z=-10,back=21},fr_lab_books={z=-8,back=5},
 fr_condo_books={z=-9,back=18},
 em_home_tv={z=-8,back=16},em_home_books={z=-8,back=16},
 em_home_fridge={z=-8,back=16},em_home_rustic_books={z=-8,back=16},
 em_home_glass_tall={z=-8,back=15},em_home_drawers={z=-14,back=0},
 em_home_sink={z=-14,back=0},em_center_medicine={z=-8,back=20},
 em_mart_stock={z=-10,back=19},em_mart_glass={z=-9,back=20},
 fr_center_pc={z=-11,back=15},fr_upper_pc={z=-11,back=15},
 fr_cupboard={z=-8,back=20},
 fr_living_tv={z=-8,back=19},fr_kitchen={z=-15,back=3},
}
function M.draw(id,A)
 local B,S,T=A.box,A.source,A.sample
 local placement=M.placement[id]
 if placement then
  local box,source=B,S;local z=placement.z
  B=function(l,b,n,r,h,s,uv)return box(l,b,n+z,r,h,s+z,uv)end
  S=function(x,y,w,h,a,b,c,d)
   local function move(p)return{p[1],p[2],p[3]+z}end
   return source(x,y,w,h,move(a),move(b),move(c),move(d))
  end
 end
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
 local function shelves(l,n,w,d,h,rows,mat,dark,items)
  items=items or id:find('books',1,true) or id=='gb_mart_shelf'
  local f=n+d
  B(l,0,n,l+w,h,n+1,mat)
  B(l,0,n,l+1,h,f,mat);B(l+w-1,0,n,l+w,h,f,mat)
  B(l,0,n,l+w,1.5,f,mat);B(l,h-1,n,l+w,h,f+.3,mat)
  for _,q in ipairs(rows)do
   local y0,y1,rect=q[1],q[2],q[3]
   if items then
    -- Separate contents with visible tops/sides and empty shelf space.
    -- Each spine retains its own portion of the original shelf artwork.
    local count=math.max(2,math.floor((w-2)/3));local span=(w-2)/count
    for j=0,count-1 do
     local x=l+1+j*span;local height=y1-((j%3)*.35)
     local face=f-1-(j%3)*.65;local sx=rect[1]+rect[3]*j/count
     local sw=rect[3]/count
     B(x,y0,n+2,x+span-.3,height,face,T(sx+sw/2,rect[2]+rect[4]/2))
     front({sx,rect[2],sw,rect[4]},x,y0,x+span-.3,height,face+.02)
    end
   else
    B(l+1,y0,n+2,l+w-1,y1,f-3.2,dark)
    front(rect,l+1,y0,l+w-1,y1,f-3.18)
   end
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
 -- Raised stock has independent fronts, tops and sides, including on islands.
 local function stock(rect,l,n,w,d,b,h,columns)
  columns=columns or 4
  local rows=math.max(1,math.ceil(d/4.5))
  for row=0,rows-1 do for j=0,columns-1 do
   local span,depth=w/columns,d/rows
   local x,z=l+j*span,n+row*depth
   local sw,sh=rect[3]/columns,rect[4]/rows
   local sx,sy=rect[1]+sw*j,rect[2]+sh*row
   local mat=T(sx+sw*.5,sy+sh*.5)
   local tall=h-((j+row)%3)*.35
   B(x+.25,b,z+.25,x+span-.3,tall,z+depth-.4,mat)
   front({sx,sy,sw,sh},x+.25,b,x+span-.3,tall,z+depth-.38)
   top({sx,sy,sw,sh},x+.25,z+.25,x+span-.3,z+depth-.4,tall+.02)
  end end
 end
 if id=='fr_hotel_table' then
  local wood=T(4,18)
  desk(2,5,30,26,6,wood);top({2,2,28,23},2,5,30,26,6.02)
 elseif id=='fr_hotel_sofa' then
  local frame,cloth=T(2,16),T(6,18)
  B(2,1,9,14,4,44,frame);B(3,4,10,13,6,43,cloth)
  B(1,3,8,3,11,44,frame);B(1,3,8,15,8,10,frame);B(1,3,42,15,8,44,frame)
  top({3,12,10,29},3,10,13,42,6.02)
  for _,z in ipairs{10,40}do B(11,0,z,13,2,z+2,frame)end
 elseif id=='fr_tanoby_masonry' then
  local stone=T(7,9)
  B(0,0,12,16,15,28,stone);B(0,15,11,16,17,29,T(6,2))
  top({0,0,16,12},0,11,16,29,17.02)
  front({0,16,16,16},0,0,16,15,28.02)
  -- Recessed mortar and a raised lintel emphasize the carved frieze.
  B(0,2,28,16,3,28.3,T(7,26));B(0,12,28,16,13,28.3,T(7,20))
 elseif id=='fr_roof_room_books' then
  shelves(1,26,30,13,24,{{3,11,{2,32,28,8}},{13,21,{2,23,28,8}}},T(1,21),T(3,31),true)
 elseif id=='fr_roof_room_desk' then
  local wood=T(2,16)
  desk(1,17,31,31,6,wood);top({1,16,30,9},1,17,31,31,6.02)
  B(4,6,18,14,7.4,27,T(6,20));top({4,17,10,7},4,18,14,27,7.42)
 elseif id=='fr_roof_room_stool' then
  local wood=T(4,12)
  desk(2,5,14,17,4,wood);top({2,3,12,9},2,5,14,17,4.02)
 elseif id=='fr_condo_meeting_table' then
  local wood=T(12,25)
  local points={{15,17},{49,17},{62,27},{62,49},{49,62},{15,62},{2,49},{2,27}}
  -- An eight-sided table, with a continuous top and closed bevel/fascia.
  for j,a in ipairs(points)do
   local b=points[j%#points+1]
   A.face({{32,8,32},{a[1],8,a[2]},{b[1],8,b[2]},{32,8,32}},wood,1)
   A.face({{a[1],6.5,a[2]},{b[1],6.5,b[2]},{b[1],8,b[2]},{a[1],8,a[2]}},wood,.85)
  end
  for _,x in ipairs{13,47}do for _,z in ipairs{18,43}do B(x,0,z,x+3,6.5,z+3,wood)end end
  top({14,17,36,30},14,18,50,56,8.02)
 elseif id=='fr_condo_workstation' then
  local wood,case,dark=T(2,27),T(8,12),T(11,15)
  desk(1,18,46,31,8,wood)
  crt(7,16,15,11,24,{8,10,13,10},case,dark)
  keyboard({9,21,13,4},9,25,13,5,8.1,case)
  B(2,8,19,6,20,28,case);front({2,10,4,14},2,8,6,20,28.02)
  B(31,8,23,43,9.6,31,T(35,21));top({31,16,12,14},31,23,43,31,9.62)
 elseif id=='fr_condo_sofa' then
  local w=A.width;local cloth,frame=T(8,17),T(1,15)
  B(3,1,3,w-3,4,15,frame);B(3,4,3,w-3,6,15,cloth)
  B(2,4,0,w-2,12,3,frame)
  front({3,10,w-6,8},3,6,w-3,11,3.02)
  top({3,18,w-6,7},3,3,w-3,15,6.02)
  B(1,1,1,3,8,16,frame);B(w-3,1,1,w-1,8,16,frame)
  for _,x in ipairs{3,w-5}do B(x,0,12,x+2,2,15,frame)end
 elseif id=='fr_condo_books' then
  shelves(1,27,30,13,26,{{3,10,{2,34,28,7}},{12,19,{2,25,28,7}}},T(2,20),T(4,33),true)
  B(1,20,27,31,28,40,T(1,14));front({1,11,30,10},1,20,31,28,40.02)
 elseif id=='fr_lorelei_table' then
  local wood=T(2,24)
  desk(2,2,30,28,7,wood);top({2,1,28,25},2,2,30,28,7.02)
 elseif id=='fr_lorelei_display' then
  local frame=T(1,20)
  B(1,0,14,31,3,40,frame);B(2,3,15,30,15,39,T(8,18))
  for _,x in ipairs{1,29}do B(x,3,14,x+2,16,40,frame)end
  B(1,15,14,31,16,16,frame);B(1,15,38,31,16,40,frame)
  top({2,11,28,29},2,16,30,38,15.02)
 elseif id=='fr_sevii_books' then
  local wood=T(1,16)
  shelves(1,24,30,12,21,{{2,8,{2,31,28,7}},{10,16,{2,24,28,6}}},wood,T(3,30),true)
  B(1,20,24,31,27,36,wood);front({2,11,28,10},2,21,30,27,36.02)
 elseif id=='fr_sevii_wardrobe' then
  -- Three low cupboard doors over three drawers, exactly as the native
  -- picture: not a tall two-door wardrobe with wallpaper on its front.
  local wood=T(4,20)
  B(0,0,28,48,2,41,wood);B(0,2,28,48,15,40,wood)
  B(0,15,27,48,16,41,wood)
  for x=0,32,16 do
   B(x+.5,7,40,x+15.5,15,41,wood)
   front({x,17,16,14},x+.5,7,x+15.5,15,41.02)
   B(x+.5,2,40,x+15.5,6.5,41,wood)
   front({x,31,16,9},x+.5,2,x+15.5,6.5,41.02)
  end
 elseif id=='fr_sevii_chair' then
  local wood=T(7,9)
  for _,x in ipairs{4,10}do for _,z in ipairs{4,10}do B(x,0,z,x+2,4,z+2,wood)end end
  B(3,4,3,13,5,13,wood);top({4,6,8,7},3,3,13,13,5.02)
  local x=A.recipe.east and 11 or 3
  B(x,5,3,x+2,10,13,wood)
 elseif id=='fr_tower_reception' then
  local gold,trim=T(8,16),T(8,12)
  B(1,0,13,96,1,31,T(1,28));B(0,1,12,96,7,32,trim)
  B(0,7,12,96,8,32,gold)
  top({0,12,96,12},0,12,96,32,8.02)
 elseif id=='fr_tower_reception_return' then
  local gold,trim=T(7,24),T(2,24)
  B(1,0,0,13,1,63,T(7,63));B(0,1,0,14,7,64,trim)
  B(0,7,0,14,8,64,gold)
  top({0,0,14,64},0,0,14,64,8.02)
 elseif id=='fr_saffron_column' then
  local stone=T(7,12)
  B(2,0,4,14,3,16,T(7,40));B(4,3,6,12,30,14,stone)
  B(2,30,4,14,32,16,stone)
  front({4,4,8,36},4,3,12,30,14.02)
  for _,x in ipairs{5,8,11}do B(x,3,14,x+.4,30,14.4,T(5,16))end
 elseif id=='fr_saffron_telepad' then
  -- Preserve the square concentric native graphic on a nearly flush plate.
  B(1,.01,1,15,.35,15,T(1,1))
  top({1,1,14,14},1,1,15,15,.36)
 elseif id=='fr_cinnabar_quiz' then
  local white,gray=T(7,8),T(2,16)
  B(2,0,15,25,2,30,gray);B(3,2,16,24,14,29,white)
  B(3,14,17,15,23,25,white);B(4,15,24,14,22,25,gray)
  front({4,7,10,11},4,15,14,22,25.05)
  B(3,12,26,24,14,30,white)
  top({3,18,21,7},3,26,24,30,14.03)
  for _,x in ipairs{17,20}do B(x,14,27,x+1.5,15,28.5,T(x,21))end
 elseif id=='fr_vermilion_bin' then
  -- Eight closed metal panels, a recessed dark mouth, bright rolled lip and
  -- external ribs. The art's gray opening is not stretched down a cube.
  local shell,lip,dark=T(3,10),T(3,3),T(8,5)
  local function ring(radius,y,i)
   local a=(i-.5)*math.pi/4;return {8+radius*math.cos(a),y,8+radius*math.sin(a)}
  end
  for i=0,7 do
   local a,b=ring(5.2,.5,i),ring(5.2,.5,i+1)
   local c,d=ring(5.8,8,i+1),ring(5.8,8,i)
   A.face({a,b,c,d},shell,.85)
   A.face({d,c,ring(4,8,i+1),ring(4,8,i)},lip,1)
   A.face({ring(4,8,i),ring(4,8,i+1),ring(4,5,i+1),ring(4,5,i)},shell,.65)
   A.face({{8,.5,8},b,a,{8,.5,8}},shell,.6)
   A.face({{8,5,8},ring(4,5,i),ring(4,5,i+1),{8,5,8}},dark,.65)
   local q=ring(5.3,0,i+.5)
   B(q[1]-.35,1,q[3]-.35,q[1]+.35,7,q[3]+.35,lip)
  end
 elseif id=='fr_vermilion_gate' then
  local metal,gold,cyan,core=T(1,3),T(2,12),T(40,10),T(40,11)
  for _,x in ipairs{0,73}do
   B(x,0,6,x+7,22,15,metal);B(x,2,6,x+7,17,15,gold)
   B(x,21,5,x+7,23,16,metal)
  end
  for _,h in ipairs{7,14}do
   B(7,h-1,9,73,h+1,11,cyan)
   B(7,h-.3,10.9,73,h+.3,11.1,core)
   for _,x in ipairs{6,71}do B(x,h-2,8,x+3,h+2,12,cyan)end
  end
 elseif id=='fr_corner_half_east' or id=='fr_corner_half_west' then
  local east=id=='fr_corner_half_east'
  local l,r=east and 0 or 4,east and 12 or 16
  local inner,outer=east and 4 or 12,east and 12 or 4
  local sx=east and 11 or 1
  local wood,gold=T(east and 3 or 11,8),T(east and 1 or 13,5)
  B(l,0,1,r,2,15,wood);B(l,2,1,r,11,15,wood)
  B(east and 0 or 13,11,1,east and 3 or 16,19,15,wood)
  B(east and 0 or 12,19,1,east and 4 or 16,20,15,gold)
  S(sx,0,4,8,{inner,18,2},{inner,18,14},{outer,11,14},{outer,11,2})
  S(sx,8,4,5,{outer,10,2},{outer,10,14},{outer,6,14},{outer,6,2})
 elseif id=='gb_corner_pair' or id=='gb_corner_cap' then
  -- Crystal's two cabinets have a dark central seam, red shells and pale
  -- outer control strips. Keep its pink/yellow panels on the sloped faces,
  -- rather than using a pink screen pixel for every structural surface.
  local red,trim,dark=T(14,8),T(3,8),T(15,8)
  B(1,0,0,31,2,16,dark)
  B(2,2,0,30,10,16,red)
  B(14,10,0,18,18,16,dark)
  for _,east in ipairs{false,true}do
   local outer,inner=east and 30 or 2,east and 18 or 14
   local sx=east and 17 or 2
   S(sx,1,13,14,{inner,18,0},{inner,18,16},{outer,11,16},{outer,11,0})
   B(math.min(outer,inner),10,0,math.max(outer,inner),11,16,trim)
   local faceX=outer+(east and .02 or -.02)
   S(east and 26 or 3,2,3,12,{faceX,10,0},{faceX,10,16},{faceX,5,16},{faceX,5,0})
  end
  -- Closed end cheeks avoid a hollow triangle when looking along the row.
  for _,z in ipairs{0,16}do
   A.face({{2,10,z},{14,18,z},{18,18,z},{30,10,z}},red)
  end
 elseif id=='gb_corner_end' then
  local red,yellow=T(2,8),T(8,4)
  B(1,0,1,31,2,15,red);B(2,2,2,30,17,14,red)
  B(3,17,2,29,19,14,yellow)
  front({1,0,30,15},1,2,31,18,14.02)
  top({1,0,30,3},1,1,31,15,19.02)
 elseif id=='fr_corner_pair' or id=='fr_corner_pair_end' then
  local endcap=id=='fr_corner_pair_end'
  local wood,gold=T(11,8),T(13,5)
  B(4,0,1,28,2,15,wood);B(5,2,1,27,11,15,wood)
  B(13,11,1,19,19,15,wood);B(12,18,1,20,20,15,gold)
  for _,east in ipairs{false,true}do
   local outer,inner=east and 28 or 4,east and 20 or 12
   local sx=east and 27 or 1
   -- Native pale metal/green display strips face their respective stools.
   S(sx,0,4,8,{inner,18,2},{inner,18,14},{outer,11,14},{outer,11,2})
   B(math.min(inner,outer),10,1,math.max(inner,outer),11,15,gold)
   S(sx,8,4,5,{outer,10,2},{outer,10,14},{outer,6,14},{outer,6,2})
  end
  if endcap then
   B(4,0,15,28,2,19,wood);B(5,2,14,27,11,16,wood)
   front({5,12,22,4},5,3,27,10,16.02)
  end
 elseif id=='fr_corner_stool' then
  local metal,blue=T(5,13),T(8,7)
  B(5,0,5,11,1,11,metal);B(7,1,7,9,4,9,metal)
  B(4,4,4,12,5,12,metal);B(4.5,5,4.5,11.5,6,11.5,blue)
  top({5,5,6,5},4.5,4.5,11.5,11.5,6.02)
 elseif id=='fr_corner_chair' then
  -- Original blue swivel chair: a metal foot, upholstered seat and side
  -- backrest facing the neighboring machine, not a round backless stool.
  local metal,blue=T(5,13),T(8,7)
  B(5,0,5,11,1,11,metal);B(7,1,7,9,4,9,metal)
  B(3,4,3,13,5,13,metal);B(3.5,5,3.5,12.5,6,12.5,blue)
  top({4,6,8,6},3.5,3.5,12.5,12.5,6.02)
  local x=A.recipe.backEast and 12 or 2
  B(x,5,3,x+2,11,13,metal);B(x+.2,6,3.5,x+1.8,11.5,12.5,blue)
 elseif id=='em_start_window' then
  local frame,sill=T(0,8),T(2,19)
  -- Keep the window attached to the wall face, not hovering over the aisle.
  B(0,19,16,15,20,17.5,sill)
  B(0,20,16,1,30,17,frame);B(14,20,16,15,30,17,frame)
  B(1,29,16,14,30,17,frame)
  B(1,20,16,14,29,16.1,frame)
  front({1,9,13,9},1,20,14,29,16.12)
  B(7,20,16.12,8,29,17,T(7,10))
 elseif id=='em_start_seat_pad' then
  B(2,0,3,14,.6,14,T(6,10))
  top({2,3,12,11},2,3,14,14,.62)
 elseif id=='em_start_picture' then
  local frame=T(1,11)
  B(1,18,15,15,27,16,frame)
  B(1,18,16,2,27,16.5,frame);B(14,18,16,15,27,16.5,frame)
  B(2,18,16,14,19,16.5,frame);B(2,26,16,14,27,16.5,frame)
  front({2,11,12,8},2,19,14,26,16.2)
 elseif id=='em_start_clock' then
  local rim=T(7,8)
  B(4,15,15,12,29,16,rim);B(2,17,15,14,27,16,rim)
  B(1,20,15,15,24,16,rim)
  front({2,9,12,13},2,16,14,28,16.02)
 elseif id=='em_truck_cargo' then
  local metal,edge=T(3,20),T(1,28)
  local function cargo(l,n,r,z,h,rect)
   B(l,0,n,r,h,z,metal)
   B(l,h-1,n,r,h,n+1,edge);B(l,h-1,z-1,r,h,z,edge)
   front(rect,l+.4,1,r-.4,h-.5,z+.01)
  end
  -- Every solid base is inside the original blocked cells. Perspective
  -- fronts from the ROM become vertical faces, never obstacles on the floor.
  for z=0,64,16 do
   cargo(.2,z+.2,15.8,z+15.8,20+(z%32==0 and 2 or 0),{0,0,16,32})
  end
  cargo(16,.2,31.8,15.8,17,{16,16,16,16})
  cargo(32,.2,79.8,15.8,20,{32,16,32,16})
  for x=16,64,16 do cargo(x+.2,64,x+15.8,79.8,17,{16,64,16,16})end
  cargo(16,48,31.8,63.8,10,{16,48,16,16})
  cargo(32,48,47.8,63.8,22,{32,48,16,32})
 elseif id=='em_start_bed' then
  local wood,cloth=T(14,20),T(20,31)
  -- Only the centre foot cell is impassable. The apparent long head in the
  -- ROM is perspective; keep the complete 3D bed inside that native cell.
  for _,x in ipairs{16.3,29.7}do for _,z in ipairs{32.3,45.7}do B(x,0,z,x+1.8,4,z+1.8,wood)end end
  B(16.2,3,32.2,31.8,5,47.8,wood);B(17,5,33,31,7,47,cloth)
  top({14,23,20,21},17,36,31,47,7.02)
  B(17,7,33,31,8.3,36,T(20,21));top({15,19,18,5},17,33,31,36,8.32)
  B(16.2,3,32.2,31.8,11,33,wood);front({13,16,22,5},16.2,7,31.8,11,33.02)
  B(16.2,3,47,31.8,6,47.8,wood)
 elseif id=='em_start_table' then
  local wood=T(5,34)
  desk(1,1,31,30,7,wood);top({1,0,30,28},1,1,31,30,7.02)
 elseif id=='em_start_dresser' then
  local case,trim=T(2,19),T(1,28)
  B(1,0,17,15,23,31,case);B(2,23,18,14,25,30,case)
  front({1,17,14,15},1,10,15,23,31.02)
  for _,x in ipairs{2,8}do
   B(x,1,31,x+5,9,31.5,trim)
   front({x,32,5,9},x,1,x+5,9,31.52)
  end
 elseif id=='em_start_pc_left' or id=='em_start_pc_right' then
  local right=id=='em_start_pc_right';local x=right and 16 or 0
  local wood,case,dark=T(x+2,30),T(x+1,13),T(x+5,20)
  desk(0,17,32,31,8,wood)
  crt(x+1,17,14,10,26,{x+2,17,12,8},case,dark)
  keyboard({x+2,26,12,4},x+2,25,12,5,8.1,case)
  local book=right and 0 or 16
  B(book+2,8,21,book+14,11,29,T(book+4,25))
  top({book+2,22,12,9},book+2,21,book+14,29,11.02)
  -- Walkable seating is a low pad, not a waist-high solid chair.
  B(x+2,0,39,x+14,.5,47,T(x+8,36))
  top({x+2,32,12,12},x+2,39,x+14,47,.52)
 elseif id=='em_start_console' then
  local case,dark=T(6,14),T(4,21)
  B(3,0,1,12,9,15,case);B(4,9,2,11,10,14,case)
  front({3,10,9,12},3,1,12,9,15.02)
  B(5,0,26,13,1,30,dark);top({5,24,8,6},5,26,13,30,1.02)
  B(4,.1,22,4.4,.5,28,dark);B(4,.1,27.6,6,.5,28,dark)
 elseif id=='em_start_fridge' then
  local case,edge=T(4,9),T(1,17)
  B(1,0,13,15,27,29,case);front({1,1,14,29},1,1,15,26,29.02)
  B(1,17,29,15,17.5,29.2,edge)
  B(3,11,29,4,15,29.5,edge)
 elseif id=='em_start_kitchen' then
  local wood,metal,dark=T(4,26),T(6,15),T(5,18)
  B(0,0,14,32,8,30,wood);front({0,25,32,6},0,1,32,8,30.02)
  B(0,8,13,32,9,16,metal);B(0,8,26,32,9,31,metal)
  B(0,8,16,2,9,26,metal);B(14,8,16,32,9,26,metal)
  B(2,6,16,14,6.6,26,dark)
  B(2,6.6,16,3,9,26,metal);B(13,6.6,16,14,9,26,metal)
  B(3,6.6,16,13,9,17,metal);B(3,6.6,25,13,9,26,metal)
  top({17,16,13,8},17,17,30,26,9.02)
  B(7,9,14,8,14,15,metal);B(7,13,14,8,14,20,metal)
 elseif id=='em_start_cabinet' then
  local wood,dark=T(2,7),T(4,25)
  B(1,0,14,25,27,28,wood)
  front({1,13,23,17},1,1,25,24,28.02)
  B(12,1,28,13,24,28.3,wood)
  B(3,5,28,10,6,28.6,dark);B(15,5,28,22,6,28.6,dark)
 elseif id=='em_start_tv' then
  local wood,case,dark=T(3,24),T(1,3),T(3,17)
  B(1,0,1,31,6,15,wood);front({1,18,30,8},1,1,31,6,15.02)
  crt(1,1,30,8,24,{2,1,28,14},case,dark)
 elseif id=='fr_daycare_cushion' then
  -- Walkable native floor seat: keep its tuft and stitched edge on a low pad.
  B(2,0,4,14,.45,14,T(3,12));B(3,.45,4,13,.8,13,T(6,6))
  top({2,4,12,10},2,4,14,14,.82)
 elseif id=='fr_department_glass' then
  local case=T(1,18)
  B(1,0,8,31,2,37,case);B(2,2,9,30,11,36,T(4,24))
  for _,x in ipairs{1,15,29}do B(x,2,8,x+2,12,37,case)end
  B(1,11,8,31,12,10,case);B(1,11,35,31,12,37,case)
  top({2,16,28,23},2,10,30,35,11.5)
  front({1,40,30,5},1,2,31,4,37.02)
 elseif id=='fr_department_stock' then
  local case=T(2,20)
  B(1,0,8,31,2,54,case);B(15,2,8,17,17,54,case)
  for _,x in ipairs{2,18}do
   B(x,2,9,x+12,4,53,case)
   stock({x,16,12,38},x+.4,10,11.2,42,4,12,3)
  end
 elseif id=='gb_station_seat' then
  local yellow,edge=T(7,6),T(1,10)
  -- One molded yellow chair per original 16-pixel seat, including its low
  -- cushion, curved shoulder steps, rear shell and four metal feet.
  for _,x in ipairs{3,11}do for _,z in ipairs{5,12}do
   B(x,0,z,x+2,3.5,z+2,edge)
  end end
  B(1,3,5,15,4,15,edge);B(2,4,5,14,5,14,yellow)
  top({2,8,12,5},2,5,14,14,5.02)
  B(2,4,3,14,9,5,yellow);B(3,9,3,13,10,5,yellow)
  front({2,2,12,6},2,5,14,9,5.02)
  B(1,4,5,2,6,12,edge);B(14,4,5,15,6,12,edge)
 elseif id=='gb_station_fence' then
  local metal,dark=T(3,8),T(2,9)
  -- Native pair of slim uprights per eight-pixel strip, with open gaps.
  for _,x in ipairs{1,5}do
   B(x,0,12,x+1.5,8,14,metal)
   B(x-.2,7.8,11.8,x+1.7,8.4,14.2,metal)
  end
  B(0,2,12.5,8,3,13.5,dark);B(0,6,12.5,8,7,13.5,metal)
 elseif id=='gb_station_entry' then
  local case,edge=T(5,6),T(1,8)
  B(3,0,1,13,2,31,edge);B(4,2,2,12,10,30,case)
  B(3,10,1,13,11,31,edge)
  top({3,1,10,29},3,1,13,31,11.02)
  for _,x in ipairs{3,12}do B(x,0,28,x+1,10,31,edge)end
 elseif id=='gb_warehouse_crate' then
  local wood,edge,brace=T(5,3),T(1,1),T(3,10)
  B(2,0,2,14,12,14,wood)
  -- Four closed corner posts and rails carry the source's framed box shape.
  for _,x in ipairs{1,13}do for _,z in ipairs{1,13}do B(x,0,z,x+2,12,z+2,edge)end end
  for _,y in ipairs{0,10}do
   B(1,y,1,15,y+2,2,wood);B(1,y,14,15,y+2,15,wood)
   B(1,y,2,2,y+2,14,wood);B(14,y,2,15,y+2,14,wood)
  end
  top({1,0,14,8},1,1,15,15,12.02)
  -- Reuse the native X-board front on each unseen side, never on the lid.
  for turn=0,3 do
   local function rotate(p)
    local x,y,z=p[1],p[2],p[3]
    for _=1,turn do x,z=16-z,x end
    return {x,y,z}
   end
   S(2,8,12,8,rotate({2,11,14.02}),rotate({14,11,14.02}),rotate({14,1,14.02}),rotate({2,1,14.02}))
   local function beam(x0,y0,x1,y1)
    local dx,dy=x1-x0,y1-y0;local n=math.sqrt(dx*dx+dy*dy)
    local px,py=-dy/n*.6,dx/n*.6
    local ring={{x0+px,y0+py},{x1+px,y1+py},{x1-px,y1-py},{x0-px,y0-py}}
    local f,b={},{}
    for i,p in ipairs(ring)do f[i]=rotate({p[1],p[2],14.6});b[i]=rotate({p[1],p[2],14.1})end
    A.face({f[4],f[3],f[2],f[1]},brace,.95);A.face(b,brace,.7)
    for i=1,4 do local j=i%4+1;A.face({b[j],b[i],f[i],f[j]},brace,.82)end
   end
   beam(4,8.5,12,2);beam(4,2,12,8.5)
  end
 elseif id=='gb_underground_stall_counter' then
  -- A complete long stall has one green top and a rounded, fluted end.
  -- Close the underside and the perimeter without enlarging its three cells.
  local material=T(7,8)
  local rim={{1,0},{15,0},{15,43},{13,47},{3,47},{1,43}}
  for i,a in ipairs(rim)do
   local b=rim[i%#rim+1]
   A.face({{b[1],0,b[2]},{a[1],0,a[2]},{a[1],8,a[2]},{b[1],8,b[2]}},material,.8)
  end
  B(1,0,0,15,.5,43,material)
  A.face({{1,0,43},{15,0,43},{13,0,47},{3,0,47}},material,.65)
  top({1,0,14,40},1,0,15,43,8)
  S(2,39,12,2,{1,8,43},{15,8,43},{13,8,47},{3,8,47})
  front({2,41,12,6},3,0,13,7.8,47.01)
  local flute=T(3,45)
  for z=1,41,2 do
   B(.75,0,z,1.15,7.8,z+.5,flute)
   B(14.85,0,z,15.25,7.8,z+.5,flute)
  end
 elseif id=='gb_department_directory' then
  -- Native background event identifies this as the floor directory, not a
  -- cupboard. The original lettering belongs only on its recessed front.
  local wall,frame=T(15,15),T(1,1)
  B(0,0,0,16,24,14,wall)
  B(0,6,14,16,22,14.5,frame)
  B(0,6,14.5,1,22,15.5,frame);B(15,6,14.5,16,22,15.5,frame)
  B(1,6,14.5,15,7,15.5,frame);B(1,21,14.5,15,22,15.5,frame)
  front({1,1,14,14},1,7,15,21,14.52)
 elseif id=='gb_department_register' then
  local counter,case,dark=T(2,1),T(7,2),T(3,4)
  -- The 16px native drawing combines countertop, display, keys and printer.
  -- Stand the equipment on its counter instead of printing it on the lid.
  B(0,0,0,16,6,16,counter);B(0,6,0,16,7,16,counter)
  B(3,7,3,13,9,13,dark)
  B(3,9,2,9,15,6,case)
  front({3,1,6,4},3.5,10,8.5,14,6.02)
  B(10,9,3,13,13,7,case)
  front({10,1,3,4},10,9,13,13,7.02)
  -- Closed sloped keypad: its source pixels remain on the inclined face.
  S(3,7,6,5,{3,11,7},{9,11,7},{9,9.5,12},{3,9.5,12})
  A.face({{3,9,7},{3,11,7},{3,9.5,12},{3,9,12}},case,.78)
  A.face({{9,9,12},{9,9.5,12},{9,11,7},{9,9,7}},case,.84)
  A.face({{9,9,7},{9,11,7},{3,11,7},{3,9,7}},case,.72)
  A.face({{3,9,12},{3,9.5,12},{9,9.5,12},{9,9,12}},case,.86)
 elseif id=='gb_department_counter_window' then
  -- The lower half of this drawing is the reception counter overlapping a
  -- window. Separate the horizontal countertop from the upright rear pane.
  local frame,case=T(0,0),T(4,10)
  B(0,10,0,16,24,14,frame)
  B(0,10,14,1,24,15.5,frame);B(15,10,14,16,24,15.5,frame)
  B(1,23,14,15,24,15.5,frame)
  front({1,1,14,7},1,10,15,23,14.02)
  B(0,0,8,16,9,16,case)
  B(0,9,7,16,10,16,case)
  top({0,9,16,7},0,7,16,16,10.02)
 elseif id=='gb_department_elevator' then
  -- The door cell is a native walkable warp. Put the closed door at its rear
  -- plane, with open approach space between the narrow jambs and lintel.
  local frame,wall=T(1,1),T(31,9)
  B(0,0,0,16,24,.5,frame)
  front({1,1,14,14},1,0,15,23,.52)
  B(0,0,.5,1,24,16,frame);B(15,0,.5,16,24,16,frame)
  B(0,23,.5,16,24,16,frame)
  B(16,0,0,32,24,16,wall)
  front({16,0,16,16},16,0,32,24,16.02)
 elseif id=='gb_department_window' then
  -- The diagonal stripes are native glass reflections, not a sloping roof.
  -- Keep the entire wall and sill within its original blocked 16px cell.
  local frame,wall=T(0,0),T(0,15)
  B(0,0,0,16,24,14,wall)
  B(0,7,14,1,24,15.5,frame);B(15,7,14,16,24,15.5,frame)
  B(1,23,14,15,24,15.5,frame)
  B(0,7,14,16,8,16,frame)
  front({1,1,14,14},1,8,15,23,14.02)
 elseif id=='gb_department_bench' then
  local edge,cloth=T(1,1),T(6,6)
  B(2,0,3,4,3,29,edge);B(12,0,3,14,3,29,edge)
  for _,z in ipairs{0,16}do
   B(1,2,z+1,15,3,z+15,edge)
   B(2,3,z+2,14,4,z+14,cloth)
   top({2,z+2,12,11},2,z+2,14,z+14,4.02)
  end
 elseif id=='gb_department_vending' then
  local case,dark=T(1,1),T(4,10)
  B(1,0,17,15,26,30,case)
  front({1,7,14,23},1,1,15,25,30.02)
  B(3,2,30.05,13,5,30.2,dark)
  B(11,12,30.05,13,14,30.4,case)
 elseif id=='fr_department_game_demo' then
  local case,dark=T(3,16),T(35,14)
  desk(1,13,111,30,7,case)
  top({1,14,110,9},1,13,111,30,7.02)
  for _,x in ipairs{16,64}do
   crt(x+16,13,15,9,21,{x+17,11,13,11},T(x+17,10),dark)
   B(x+1,7,18,x+13,10,26,T(x+2,14))
   top({x+1,10,12,6},x+1,18,x+13,26,10.02)
   B(x+2,7,27,x+9,8,30,case)
   top({x+2,21,7,3},x+2,27,x+9,30,8.02)
  end
 elseif id=='em_game_corner_machine' then
  local shell,dark=T(2,8),T(1,12)
  -- Independent cabinet, upper lightbox, recessed display and coin tray.
  -- The cloud wallpaper above the source cabinet is deliberately excluded.
  B(.5,0,17,15.5,1,31,dark)
  B(1,1,17.5,15,26,30.5,shell)
  B(.5,24,18,15.5,27,31,dark)
  front({1,3,14,6},1,21,15,26,31.02)
  B(1,12,30.5,2,21,31,dark);B(14,12,30.5,15,21,31,dark)
  B(2,12,30.5,14,13,31,dark);B(2,20,30.5,14,21,31,dark)
  front({2,10,12,7},2,13,14,20,30.62)
  front({1,18,14,13},1,1,15,12,30.52)
  B(4,3,30.5,12,3.7,31.5,shell)
 elseif id=='em_game_corner_bin' then
  local metal,rim,dark=T(5,11),T(5,3),T(7,7)
  -- Faceted can with an actual recessed opening and raised rim.
  B(4,0,3,12,8,13,metal);B(3,1,4,13,8,12,metal)
  B(4,8,4,12,8.3,12,dark)
  B(4,8,3,12,9,4.2,rim);B(4,8,11.8,12,9,13,rim)
  B(3,8,4,4.2,9,12,rim);B(11.8,8,4,13,9,12,rim)
  front({5,10,6,5},4,1,12,7,13.02)
 elseif id=='em_slot_bank' then
  local case,dark,trim=T(10,12),T(15,12),T(9,3)
  -- Four back-to-back cabinet pairs. Projected top art in the first row
  -- never becomes a solid: each pair occupies its native blocked row.
  for i=0,3 do
   local n,s=16+i*16,32+i*16
   for _,east in ipairs{false,true}do
    local l,r=east and 17 or .5,east and 31.5 or 15
    B(l+1,0,n+1,r-1,2,s-1,dark)
    B(l,2,n+.5,r,6,s-.5,case)
    local upperL,upperR=east and l or l+2,east and r-2 or r
    B(upperL,6,n+.5,upperR,14,s-.5,case)
    B(l,6,n+.5,r,7,s-.5,trim)
    B(upperL,14,n+.5,upperR,15,s-.5,trim)
    top({east and 18 or 8,3+i*16,6,9},upperL+.5,n+1,upperR-.5,s-1,15.02)
    local face=east and upperR or upperL
    local lo,hi=east and face-.1 or face-.25,east and face+.25 or face+.1
    B(lo,7.5,n+1,hi,13.5,s-1,dark)
    -- Separate coin-return opening beneath the controls.
    B(east and r-.1 or l-.1,3,n+5,east and r+.1 or l+.1,4,s-5,dark)
    -- The native side-facing panel is rotated onto the cabinet front;
    -- source X describes height, while source Y runs along the bank.
    local x=east and upperR+.27 or upperL-.27
    if east then
     S(26,8+i*16,6,14,{x,13,n+1.5},{x,8,n+1.5},{x,8,s-1.5},{x,13,s-1.5})
    else
     S(0,8+i*16,6,14,{x,8,n+1.5},{x,13,n+1.5},{x,13,s-1.5},{x,8,s-1.5})
    end
   end
  end
 elseif id=='em_roulette_table' then
  local wood,edge,gold=T(3,20),T(1,1),T(8,7)
  -- Four separate legs and an apron support the native felt/number layout.
  -- The source's bottom carpet/shadow strip is not part of the table.
  for _,x in ipairs{2,26}do for _,z in ipairs{3,39}do B(x,0,z,x+4,7,z+4,wood)end end
  B(1,5,1,31,7,44,wood)
  B(.5,7,.5,31.5,8,44.5,edge)
  top({1,1,30,39},1,1,31,44,8.02)
  -- Raised octagonal roulette rim and recessed native wheel face.
  B(4,8,3,12,8.7,15,gold);B(2,8,5,14,8.7,13,gold)
  top({2,2,12,12},2,3,14,15,8.72)
  B(7,8.72,8,9,9.3,10,T(7,7))
 elseif id=='em_lilycove_ball_sculpture' then
  local base,light,dark=T(3,14),T(7,2),T(7,0)
  -- A low separate plinth supports the original green stone Poké Ball.
  -- Voxel slices form a sphere in all three axes, not an extruded sprite.
  B(.5,0,1,15.5,2,15,base)
  B(.5,2,1,15.5,3,15,T(3,11))
  for y=0,10 do for z=0,10 do
   local dy,dz=y-5,z-5
   local half=math.sqrt(math.max(0,5.5*5.5-dy*dy-dz*dz))
   local radius=math.floor(half)
   if dy*dy+dz*dz<=5.5*5.5 then
    local material=(y==5)and dark or(y>5 and light or base)
    B(8-radius-.5,3+y,8+z-5-.5,8+radius+.5,4+y,8+z-5+.5,material)
   end
  end end
  B(6,7,12.8,10,11,13.7,dark)
  B(7,8,13.7,9,10,14,light)
 elseif id=='em_lilycove_wall_return' then
  local foot=A.recipe and A.recipe.foot or 16
  local wall,cap,trim=T(8,56),T(8,34),T(8,77)
  B(0,0,foot,16,30,79.8,wall)
  B(0,0,foot,16,2,79.8,trim)
  B(0,30,foot,16,31,79.8,cap)
  front({0,48,16,32},0,0,16,30,79.82)
 elseif id=='em_lilycove_stone_display' then
  local body,cap,stone=T(8,56),T(8,44),T(36,20)
  -- The projected upper row is floor. Chamfered plinth and a freestanding
  -- stepped stone slab occupy only the three native blocked rows below it.
  B(2,0,16,78,6,64,body);B(0,0,18,80,6,62,body)
  B(2,6,16,78,7,64,cap);B(0,6,18,80,7,62,cap)
  B(16,7,30,63,9,43,T(20,37))
  B(17,9,31,62,11,42,T(20,35))
  -- Each band samples the corresponding native face without its background.
  -- Closed rear and side faces use the same carved green stone palette.
  for _,r in ipairs{{16,28,64,34},{16,27,63,28},{17,26,60,27},{20,23,60,26},{21,22,60,23},{24,21,60,22},{27,20,59,21},{28,19,58,20},{29,18,56,19},{30,17,54,18}}do
   local l,y,rr,b=r[1],r[2],r[3],r[4]
   B(l,11+34-b,33,rr,11+34-y,40,stone)
   front({l,y,rr-l,b-y},l,11+34-b,rr,11+34-y,40.02)
  end
 elseif id=='em_lilycove_counter' then
  local case,lip=T(8,73),T(8,67)
  -- Closed ring, assembled within the native counter cells. The two-row
  -- staff lane is empty, including the apparent front cap projected onto it.
  for _,r in ipairs{{0,16,96,32},{0,32,16,64},{80,32,96,64},{0,64,96,80}}do
   B(r[1],0,r[2],r[3],6,r[4],case)
   B(r[1],6,r[2],r[3],7,r[4],lip)
  end
  top({3,16,90,7},1,17,95,31,7.02)
  top({2,32,12,28},1,32,15,64,7.02)
  top({82,32,12,28},81,32,95,64,7.02)
  top({3,63,90,7},1,65,95,79,7.02)
  front({1,72,94,7},1,0,95,6,79.98)
 elseif id=='em_lilycove_picture_wall' then
  local w=A.width
  local spot=A.recipe and A.recipe.wallSample or {0,2}
  local wall,trim=T(spot[1],spot[2]),T(w-1,28)
  B(0,0,16,w,30,31.8,wall)
  B(0,0,16,w,2,31.8,trim)
  B(0,30,16,w,31,31.8,wall)
  front({0,0,w,32},0,0,w,30,31.82)
 elseif id=='em_lilycove_upper_wall' then
  local rows=A.recipe and #A.recipe.rows or 2
  local sourceY=(rows-2)*16
  local south=rows*16-.2
  local north=(A.recipe and A.recipe.corner)and 16 or (rows-1)*16
  local green,cap,trim=T(8,sourceY+8),T(8,2),T(8,rows*16-3)
  B(0,0,north,16,27,south,green)
  B(0,0,north,16,2,south,trim)
  B(0,27,north,16,28,south,cap)
  front({0,sourceY,16,32},0,0,16,27,south+.02)
 elseif id=='em_lilycove_gallery' then
  local green,cap,edge=T(5,22),T(20,11),T(2,15)
  -- Back, sides and recessed front retain the native green display wall.
  -- The apparent cap row and cast-shadow row are floor, never solid depth.
  B(.2,0,32.2,63.8,2,47.8,edge)
  B(.5,2,32.5,63.5,27,47.5,green)
  B(.2,27,32.2,63.8,28,47.8,cap)
  B(.2,2,47,1.2,27,47.8,edge);B(62.8,2,47,63.8,27,47.8,edge)
  front({1,16,62,31},1,2,63,27,47.82)
  -- The native gold picture frame is a shallow raised rim, not a flat label.
  local gold=T(17,33)
  B(17,3.6,47.82,47,4.4,47.98,gold);B(17,12.5,47.82,47,13.3,47.98,gold)
  B(17,4.4,47.82,17.8,12.5,47.98,gold);B(46.2,4.4,47.82,47,12.5,47.98,gold)
 elseif id=='em_museum_wall_case' then
  -- The source is a rounded glass vessel, plus eight pixels of wallpaper
  -- at its right. Neither that wallpaper nor the carpet is cabinet skin.
  local cream,blue,gold=T(8,2),T(4,20),T(8,37)
  local function drum(b,h,mat,inset)
   inset=inset or 0
   for _,q in ipairs{{0,21,24,27},{1,19,23,29},{3,17,21,31}}do
    B(q[1]+inset,b,q[2]+inset,q[3]-inset,h,q[4]-inset,mat)
   end
  end
  drum(0,4,gold);drum(4,5,cream);drum(5,29,blue,.7)
  drum(29,31,cream);drum(31,32,cream,1)
  front({3,8,18,27},3,5,21,29,30.32)
  for _,x in ipairs{2,21}do B(x,5,29,x+1,29,30,cream)end
 elseif id=='em_museum_divider' then
  local paint,trim=T(8,20),T(1,48)
  B(4,0,0,12,28,62,paint)
  B(3.5,0,0,12.5,3,62.5,trim)
  B(3.5,27,0,12.5,28,62.5,paint)
 elseif id=='em_museum_cylinder' then
  local cream,blue,glass=T(8,3),T(3,17),T(8,16)
  local function drum(b,h,mat,inset)
   inset=inset or 0
   for _,r in ipairs({{3,18,13,30},{2,20,14,28},{4,17,12,31}})do
    B(r[1]+inset,b,r[2]+inset,r[3]-inset,h,r[4]-inset,mat)
   end
  end
  drum(0,2,blue);drum(2,3,cream);drum(3,19,glass,.7)
  drum(19,20,blue);drum(20,22,cream)
  for _,x in ipairs({3,12})do B(x,3,28,x+1,19,29,cream)end
  front({4,10,8,16},4,3,12,19,30.32)
 elseif id=='em_museum_glass' then
  local case=T(3,25)
  B(1,0,14,15,1.5,28,case);B(2,1.5,15,14,21,27,T(8,12))
  front({2,2,12,25},2,1.5,14,21,27.02)
  for _,x in ipairs({1,14})do B(x,1.5,14,x+1,22,28,case)end
  B(1,21,14,15,22,28,case)
 elseif id=='em_museum_terminal' then
  local case,dark=T(13,18),T(3,24)
  B(3,0,12,25,2,28,dark);B(4,2,13,24,9,27,case)
  B(3,9,12,25,10,28,case)
  crt(5,11,12,11,21,{5,10,8,5},case,dark)
  keyboard({4,17,17,5},4,21,18,5,10.1,case)
 elseif id=='em_museum_ship' or id=='em_museum_parts' then
  local cream,edge=T(8,14),T(3,24)
  -- The artwork has rounded display islands, never tall storage cabinets.
  B(3,0,9,61,7,28,edge);B(1,7,9,63,9,27,cream)
  B(3,7,7,61,9,29,cream)
  if id=='em_museum_ship' then
   local hull,blue=T(25,6),T(18,7)
   B(18,9,14,44,10.5,23,blue)
   B(16,10.5,15,47,12,22,hull);B(19,12,15,43,13,22,hull)
   B(22,13,16,38,16,21,hull);B(24,16,16,36,17,21,hull)
   for x=23,36,4 do B(x,14,21,x+2,15,21.2,blue)end
   B(27,17,17,29,19,19,blue);B(32,17,17,34,19,19,blue)
  else
   local white,blue=T(18,7),T(12,8)
   for _,a in ipairs({{18,18,8},{37,18,4}})do
    local x,z,r=a[1],a[2],a[3]
    B(x-r,9,z-r*.6,x+r,10,z+r*.6,blue)
    B(x-r*.75,10,z-r*.7,x+r*.75,12,z+r*.7,white)
    B(x-r*.4,12,z-r*.4,x+r*.4,14,z+r*.4,blue)
   end
  end
 elseif id=='em_space_controls' then
  local case,dark=T(math.min(20,A.width-2),17),T(1,21)
  -- Three inclined instrument panels, with closed rear shells, plinths,
  -- and separate native switches instead of a vertical texture extrusion.
  for panel=0,A.width/16-1 do local x=panel*16
   B(x+1,0,17,x+15,1.5,31,dark)
   B(x+.5,1.5,16,x+15.5,10,30,case)
   B(x+.5,10,16,x+15.5,17,18,case)
   B(x+.5,10,18,x+1.5,16,29,case)
   B(x+14.5,10,18,x+15.5,16,29,case)
   S(x+1,1,14,14,{x+1,17,18},{x+15,17,18},{x+15,10,30},{x+1,10,30})
   front({x+1,17,14,13},x+1,1.5,x+15,10,30.02)
  end
 elseif id=='em_office_computer' or id=='em_office_desk' or id=='em_office_plans' then
  local case,dark=T(22,15),T(1,27)
  -- Computer/empty desks have a walkable perspective row above their
  -- blocked base. Plans tables use both blocked rows and keep their depth.
  local plans=id=='em_office_plans'
  local back,frontZ=plans and 7 or 16,plans and 26 or 31
  desk(1,back,31,frontZ,9,case)
  B(1,8,back,31,9,frontZ,T(22,15))
  front({1,24,30,3},1,7.6,31,9,frontZ+.02)
  if id=='em_office_computer' then
   top({17,12,13,11},17,17,30,30,9.03)
   crt(2,17,13,10.5,21,{2,9,11,9},case,dark)
   keyboard({2,20,12,4},2.5,25,12,5,9.1,case)
  elseif plans then
   top({2,2,28,20},2,8,30,25,9.03)
  else top({2,12,28,11},2,17,30,30,9.03)end
 elseif id=='em_office_stool' then
  local metal,dark,seat=T(8,10),T(4,13),T(8,4)
  -- Bevelled circular cushion, central pedestal and a broad low foot.
  B(4,0,5,12,.8,11,dark);B(5,0,4,11,.8,12,dark)
  B(6.5,.8,6.5,9.5,3.7,9.5,metal)
  for _,r in ipairs({{3,5,13,11},{4,4,12,12},{5,3,11,13}})do
   B(r[1],3.7,r[2],r[3],4.5,r[4],metal)
   B(r[1]+.4,4.5,r[2]+.4,r[3]-.4,5,r[4]-.4,seat)
  end
 elseif id=='em_home_tunnel_entrance' then
  -- Authored pixel steps follow the native broken plaster opening. Each
  -- strip has real jamb depth; the dark tunnel mouth is six pixels behind.
  local plaster=T(2,12)
  B(0,19,26,48,32,32,plaster)
  front({0,0,48,13},0,19,48,32,32.02)
  local bands={{13,14,24,26},{14,15,21,28},{15,16,15,30},
   {16,17,18,32},{17,18,17,34},{18,19,17,33},{19,20,17,31},
   {20,21,16,31},{21,23,16,30},{23,24,16,31},{24,25,17,31},
   {25,26,17,30},{26,32,18,30}}
  for _,q in ipairs(bands)do
   local y,yy,l,r=q[1],q[2],q[3],q[4]
   B(0,32-yy,26,l,32-y,32,plaster)
   B(r,32-yy,26,48,32-y,32,plaster)
   front({0,y,l,yy-y},0,32-yy,l,32-y,32.02)
   front({r,y,48-r,yy-y},r,32-yy,48,32-y,32.02)
   front({l,y,r-l,yy-y},l,32-yy,r,32-y,26.02)
  end
 elseif id=='em_home_round_window' or id=='em_home_wallpaper' then
  local plaster,trim=T(1,13),T(1,27)
  B(0,0,28,16,32,31,plaster)
  -- Full-height sides and back are closed, including behind the window.
  B(0,0,31,16,3,32,trim);B(0,29,31,16,32,32,T(1,3))
  if id=='em_home_wallpaper'then
   front({0,0,16,32},0,0,16,32,32.02)
  else
   -- Native circular window occupies x2..14 / y10..22 in the source.
   -- Keep it recessed; crop surrounding wallpaper into four solid panels.
   B(0,22,31,16,29,32,plaster);B(0,3,31,16,10,32,plaster)
   B(0,10,31,2,22,32,plaster);B(14,10,31,16,22,32,plaster)
   front({0,0,16,10},0,22,16,32,32.02)
   front({0,22,16,10},0,0,16,10,32.02)
   front({0,10,2,12},0,10,2,22,32.02)
   front({14,10,2,12},14,10,16,22,32.02)
   front({2,10,12,12},2,10,14,22,31.03)
   local frame=T(8,15)
   -- Narrow casement bars project from the pane, leaving the original
   -- glass pixels visible on all four sides.
   B(7.5,11,31.05,8.5,21,31.7,frame)
   B(3,15.5,31.05,13,16.5,31.7,frame)
  end
 elseif id=='em_fortree_support' then
  -- Closed, faceted trunk at the native footprint. Its far side has bark
  -- too; the tall source band is not laid flat beneath the column.
  local cx,cz,r,h=16,49,14,44
  for i=0,11 do
   local a,b=i*math.pi/6,(i+1)*math.pi/6
   local x,z=cx+math.cos(a)*r,cz+math.sin(a)*r
   local xx,zz=cx+math.cos(b)*r,cz+math.sin(b)*r
   S(3+(i%4)*6,0,6,52,{x,h,z},{xx,h,zz},{xx,0,zz},{x,0,z})
   S(6,12,6,6,{cx,h,cz},{xx,h,zz},{x,h,z},{cx,h,cz})
   S(6,12,6,6,{cx,0,cz},{x,0,z},{xx,0,zz},{cx,0,cz})
  end
 elseif id=='em_fortree_drawers' then
  local wood,edge=T(3,14),T(1,18)
  B(1,0,16,15,13,30,wood)
  B(0,13,15,16,14,31,wood)
  for i=0,1 do
   front({2,8+i*9,12,8},2,6.5-i*5,14,12-i*5,30.02)
   B(6,8.5-i*5,30,10,9-i*5,30.6,edge)
  end
 elseif id=='em_fortree_cabinet' or id=='em_fortree_counter' then
  local w=id=='em_fortree_counter' and 48 or 32
  local wood=T(6,17)
  B(1,0,17,w-1,8,29,wood)
  B(0,8,15,w,9.5,31,wood)
  top({1,7,w-2,12},1,16,w-1,30,9.52)
  front({1,22,w-2,7},1,1,w-1,8,29.02)
 elseif id=='em_home_rustic_books' then
  shelves(1,24,30,14,27,{{3,10,{2,34,28,6}},{13,24,{2,18,28,11}}},T(1,18),T(4,20),true)
 elseif id=='em_home_glass_low' or id=='em_home_glass_tall' then
  local tall=id=='em_home_glass_tall'
  local h,n=tall and 14 or 10,tall and 24 or 14
  local wood=T(3,tall and 32 or 26)
  B(1,0,n,31,h-1,n+14,wood)
  B(0,h-1,n-1,32,h,n+15,wood)
  top({1,tall and 10 or 1,30,tall and 8 or 13},1,n,31,n+14,h+.02)
  front({1,tall and 18 or 16,30,tall and 21 or 14},1,1,31,h-1,n+14.02)
  -- Door divider and feet retain real depth from side/rear views.
  B(15.5,1,n+14,16.5,h-1,n+14.4,wood)
  for _,x in ipairs({2,27})do B(x,0,n+1,x+3,2,n+13,wood)end
 elseif id=='em_home_appliance' then
  local case,edge=T(7,4),T(2,14)
  B(1,0,17,15,25,30,case)
  B(2,25,18,14,26,29,case)
  front({1,0,14,24},1,1,15,25,30.02)
  B(2,9,30,14,9.5,30.3,edge)
  B(3,15,30,4,19,30.7,edge)
 elseif id=='em_home_tv' then
  local wood,case,dark=T(4,34),T(1,18),T(4,22)
  -- Low closed media cabinet with a full-depth CRT above it.
  B(1,0,24,31,7,38,wood);front({1,32,30,7},1,1,31,7,38.02)
  crt(1,25,30,9,23,{2,20,28,10},case,dark)
 elseif id=='em_home_books' then
  shelves(1,25,30,13,27,{{3,10,{2,33,28,6}},{12,18,{2,25,28,6}},{20,25,{2,18,28,5}}},T(1,18),T(4,24),true)
 elseif id=='em_home_fridge' then
  local case,edge=T(5,18),T(1,24)
  B(1,0,24,15,29,38,case)
  front({1,14,14,26},1,1,15,28,38.02)
  B(1,19,38,15,19.5,38.2,edge)
  B(3,13,38.1,4,17,38.6,edge);B(3,22,38.1,4,25,38.6,edge)
 elseif id=='em_home_drawers' then
  local wood=T(2,22)
  B(1,0,14,15,9,29,wood);B(0,9,13,16,10,30,T(3,11))
  for i=0,1 do
   B(2,1+i*4,29,14,4.5+i*4,29.5,wood)
   front({2,18+(1-i)*5,12,5},2,1+i*4,14,4.5+i*4,29.52)
   B(6,2.5+i*4,29.5,10,3+i*4,30,T(3,19))
  end
 elseif id=='em_home_sink' then
  local case,metal,dark=T(2,24),T(9,11),T(10,13)
  B(0,0,15,32,9,29,case)
  front({0,19,32,9},0,1,32,9,29.02)
  -- Recessed basin, solid worktop rim and a raised tap; no open shell.
  B(0,9,14,32,10,17,metal);B(0,9,26,32,10,30,metal)
  B(0,9,17,3,10,26,metal);B(14,9,17,32,10,26,metal)
  B(3,7,17,14,7.6,26,dark)
  B(3,7.6,17,4,10,26,metal);B(13,7.6,17,14,10,26,metal)
  B(4,7.6,17,13,10,18,metal);B(4,7.6,25,13,10,26,metal)
  top({17,9,13,8},17,17,30,26,10.02)
  B(8,10,14,9,14,15,metal);B(8,13,14,9,14,20,metal)
 elseif id=='em_home_sofa' then
  local frame,cloth=T(1,15),T(10,8)
  -- Low seat, upholstered back and separate arms; solid underneath and
  -- behind, so orbit and first-person views do not expose a folded card.
  B(2,1,15,30,4,29,frame)
  B(3,4,17,29,5.5,28,cloth)
  top({4,7,24,12},3,17,29,28,5.52)
  B(2,3,14,30,13,17,cloth)
  front({4,3,24,5},3,6,29,12,17.02)
  B(1,2,16,4,8,30,cloth);B(28,2,16,31,8,30,cloth)
  for _,x in ipairs({3,26})do for _,z in ipairs({16,26})do B(x,0,z,x+3,2,z+3,frame)end end
 elseif id=='em_home_wide_table' then
  local wood=T(3,9)
  desk(2,3,46,29,8,wood)
  top({2,2,44,25},2,3,46,29,8.02)
 elseif id=='em_home_table' then
  local wood=T(2,8)
  desk(2,3,30,29,8,wood)
  top({2,2,28,25},2,3,30,29,8.02)
 elseif id=='em_home_chair_left' or id=='em_home_chair_right' then
  local wood,cloth=T(4,6),T(8,8)
  desk(4,5,12,13,4,wood)
  B(3,4,4,13,5,13,cloth);top({3,4,10,9},3,4,13,13,5.02)
  local x=id=='em_home_chair_left' and 2 or 12
  B(x,0,3,x+2,10,5,wood);B(x,0,12,x+2,10,14,wood)
  B(x,7,3,x+2,10,14,wood)
 elseif id=='em_home_cushion' then
  cushion(2,2,12,12,{2,2,12,12},T(5,5),T(2,2))
 elseif id=='em_lab_books' then
  -- A freestanding double shelf: solid back and end panels, individually
  -- raised books and readable native spines on both open tiers.
  shelves(1,26,30,13,25,{{3,11,{2,29,28,7}},{14,22,{2,20,28,7}}},T(1,20),T(4,28),true)
  B(1,25,26,31,26.5,39,T(3,18));top({1,17,30,2},1,26,31,39,26.52)
 elseif id=='em_lab_computer' then
  local case,dark,wood=T(13,16),T(12,12),T(26,24)
  desk(1,27,31,42,8,wood)
  crt(8,26,15,11,26,{10,8,12,9},case,dark)
  keyboard({9,23,13,5},9,34,13,6,8.1,case)
  B(2,8,28,7,22,37,case);front({2,9,5,16},2,8,7,22,37.02)
 elseif id=='em_lab_desk' then
  local wood=T(4,16)
  desk(0,11,64,26,8,wood);top({0,8,64,11},0,11,64,26,8.02)
  -- Separate research books/papers above the continuous desk surface.
  for _,q in ipairs({{18,2,11,10},{34,2,10,10},{49,3,10,9}})do
   local x,y,w,d=unpack(q);B(x,8.05,12,x+w,9.4,12+d,T(x+3,y+3))
   top(q,x,12,x+w,12+d,9.42)
  end
 elseif id=='em_lab_starter' then
  local wood,dark=T(3,17),T(17,25)
  -- Upper source row is bare floor; the cupboards occupy row two.
  B(2,0,18,30,1,31,dark);B(1,1,17,31,8,31,wood)
  B(0,8,16,32,9,32,wood);top({1,16,30,3},1,17,31,31,9.02)
  front({1,19,30,11},1,1,31,8,31.02)
  B(15.6,1,31,16.4,8,31.2,dark)
 elseif id=='em_lab_server' then
  local case,dark=T(2,20),T(5,28)
  B(1,0,27,15,25,40,case)
  front({1,7,14,30},1,1,15,24,40.02)
  for y=4,21,4 do B(2,y,26.95,14,y+.6,27,dark)end
 elseif id=='em_mart_stock' then
  local case,dark=T(2,16),T(4,29)
  shelves(1,29,30,12,26,{{3,12,{2,33,28,10}},{14,23,{2,20,28,11}}},case,dark,true)
  B(1,26,29,31,28,41,case);front({1,10,30,8},1,22,31,28,41.04)
 elseif id=='em_mart_glass' then
  -- The wall lies at z=32: inset glass still needs to sit in front of it.
  local case,dark=T(1,12),T(7,24)
  B(1,0,29,47,27,30,case);B(1,0,29,47,2,39,case)
  for j=0,2 do local x=j*16
   B(x+1,2,29,x+2,27,39,case);B(x+14,2,29,x+15,27,39,case)
   B(x+2,2,30,x+14,26,38,T(x+7,18))
   front({x+2,10,12,18},x+2,2,x+14,26,38.8)
   B(x+1,26,29,x+15,28,39,case)
   B(x+12,9,39,x+13,18,39.5,dark)
  end
 elseif id=='em_mart_island' or id=='em_mart_sidecase' then
  local w=A.width;local case,dark=T(3,42),T(4,25)
  B(2,0,4,w-2,2,46,dark);B(2,2,3,w-2,4,45,case)
  local spine=w==32 and 15 or 13
  B(spine,4,4,spine+2,16,44,case)
  for side=0,(w==32 and 1 or 0)do
   local l,rr=side==0 and 2 or 18,side==0 and 13 or 30
   for row=0,1 do local z=7+row*18
    B(l,4,z,rr,5,z+15,case)
    stock({l,5+row*18,rr-l,13},l+.6,z+1,rr-l-1.2,10,5,11,3)
    B(l,5,z+14,rr,6.2,z+15,case)
   end
  end
 elseif id=='em_center_medicine' then
  local case,dark=T(2,15),T(3,35)
  shelves(1,28,30,11,23,{{3,11,{2,33,28,7}},{13,20,{2,23,28,7}}},case,dark,true)
  B(1,23,28,31,25,39,case)
 elseif id=='em_center_terminal' then
  local case,dark=T(8,6),T(4,13)
  B(2,0,5,14,7,14,case);crt(2,4,12,8,18,{3,1,10,10},case,dark)
  keyboard({3,11,10,4},3,11,10,4,7.1,case)
 elseif id=='fr_processing_machine' then
  local metal,light,dark=T(7,28),T(7,20),T(25,26)
  local brass,red=T(22,18),T(8,25)
  -- Closed stepped cylinders, rather than the original perspective drawing
  -- stretched across a box. The vessel and its controls share one chassis.
  local function drum(cx,cz,b,h,r,mat)
   for _,band in ipairs({{-1,-.7,.45},{-.7,-.4,.8},{-.4,.4,1},{.4,.7,.8},{.7,1,.45}})do
    B(cx-r*band[3],b,cz+r*band[1],cx+r*band[3],h,cz+r*band[2],mat)
   end
  end
  for _,x in ipairs({3,27})do for _,z in ipairs({23,40})do B(x,0,z,x+4,3,z+4,dark)end end
  B(2,3,22,32,5,45,metal)
  B(3,5,23,17,14,42,metal);B(17,5,23,32,17,44,metal)
  B(18,17,23,31,21,34,light);B(18,17,34,31,19,42,light)
  front({18,32,12,12},18,6,30,17,44.02)
  for _,y in ipairs({8,11,14})do B(18,y,44,30,y+.6,44.4,dark)end
  for _,x in ipairs({21,27})do B(x,12,44.4,x+1.5,13.2,44.8,T(22,40))end
  drum(10,30,13,16,7,metal);drum(10,30,16,19,5.5,red)
  drum(10,30,19,31,4.5,light);drum(10,30,31,33,4,metal)
  drum(10,30,33,36,5,red);drum(10,30,36,37,4,dark)
  front({8,10,5,4},7.5,34,12.5,36,35.02)
  -- Separate fins have open spaces between them and a closed manifold.
  B(19,21,25,32,23,32,dark);B(19,31,25,32,32,32,dark)
  for x=19,31,2 do B(x,23,25,x+1,31,32,brass)end
  B(14,26,28,19,28,30,metal)
  -- Side pipe and two round access fittings, all inside the native footprint.
  B(32,9,29,36,11,32,metal);B(34,5,29,36,11,32,metal)
  drum(36,29,4,7,3,metal);drum(36,29,7,8,2,light)
  drum(5,41,5,8,3,metal);drum(5,41,8,9,2,light)
  front({8,33,4,10},8,5,12,13,42.02)
  for z=26,39,3 do B(1.8,6,z,2.02,11,z+.7,dark)end
 elseif id=='gb_broadcast_stool' then
  local dark,red,pink=T(4,9),T(8,8),T(6,5)
  for _,x in ipairs({4,10})do for _,z in ipairs({5,11})do B(x,0,z,x+2,2.5,z+2,dark)end end
  B(3,2,4,13,3,14,red);B(2,2,6,14,3,12,red)
  B(4,3,5,12,4,13,pink);B(3,3,7,13,4,11,pink)
 elseif id=='gb_broadcast_receiver' then
  -- These 16x32 crops contain eight pixels of floor/wall above the unit.
  -- Sample only equipment, and leave that source apron on the ground.
  local shell,dark,trim=T(2,12),T(4,14),T(2,10)
  B(2,0,17,14,2,31,dark)
  B(1,2,17,15,23,30,shell);B(1,23,17,15,24,30,trim)
  for _,bay in ipairs({{3,11,24},{13,22,8}})do
   B(2,bay[1],29,14,bay[2],30.4,dark)
   front({1,bay[3],14,8},2,bay[1]+.5,14,bay[2]-.5,30.42)
   B(1,bay[1]-1,17,15,bay[1],31,trim)
   for _,x in ipairs({3,11})do B(x,bay[1]+2,30.4,x+1,bay[1]+3,31,trim)end
  end
  for z=19,27,2 do B(.8,5,z,1.02,20,z+.6,dark);B(14.98,5,z,15.2,20,z+.6,dark)end
 elseif id=='gb_broadcast_studio' then
  local shell,dark,trim=T(2,4),T(5,5),T(3,3)
  -- Two stacked receivers at the desk's left, not a third monitor/table.
  B(1,0,9,15,2,23,dark);B(1,2,9,15,22,22,shell)
  for _,bay in ipairs({{3,11,16},{12,21,0}})do
   front({1,bay[3],14,8},2,bay[1],14,bay[2],22.02)
   B(1,bay[1]-1,9,15,bay[1],23,trim)
   B(12,bay[1]+2,22,13,bay[1]+3,22.8,trim)
  end
  B(1,22,9,15,23,23,trim)
  desk(15,9,47,23,7,shell)
  top({16,8,32,8},15,9,47,23,7.02)
  front({16,16,32,8},15,5,47,7,23.02)
  -- Native yellow mic/control at the right of the work surface.
  B(43,7,11,46,7.6,14,dark);B(44,7.6,11.8,44.7,10,12.5,dark)
  B(43.5,10,11,45.5,11,13,T(43,10))
 elseif id=='gb_broadcast_desk' or id=='gb_broadcast_mixer' then
  local shell,dark=T(2,3),T(2,12)
  desk(1,2,31,15,7,shell)
  top({0,0,32,8},1,2,31,14,7.02)
  front({0,8,32,8},1,5,31,7,15.02)
  if id=='gb_broadcast_desk' then
   B(18,7,3,30,14,10,shell)
   front({16,0,16,16},18,7,30,14,10.02)
   for x=20,27,3 do B(x,8,10,x+1,9,10.6,dark)end
  else
   -- A slim microphone and base above the original mixing surface.
   B(22,7,4,26,7.7,7,dark);B(23.5,7.7,5,24.2,11,5.7,dark)
   B(22.5,11,4.5,25.5,12,6,T(20,2))
  end
 elseif id=='fr_industrial_drums' then
  -- Stepped circular sections form closed solid drums, including their
  -- undersides. Each source lid owns one fourteen-pixel footprint.
  local function band(z,b,h,r,mat)
   for _,row in ipairs({{-7,-5,3},{-5,-3,5},{-3,3,7},{3,5,5},{5,7,3}})do
    B(8-row[3]*r/7,b,z+row[1]*r/7,8+row[3]*r/7,h,z+row[2]*r/7,mat)
   end
  end
  for i=0,A.height/16-2 do
   local sy,z=i*16,16+i*16
   local shell,rim,lid=T(11,sy+24),T(2,sy+17),T(7,sy+15)
   band(z,0,12,6.5,shell);band(z,0,1,7,rim)
   band(z,12,13,7,rim);band(z,13,13.4,6,lid)
   B(8.5,13.4,z-2,10,13.8,z-.5,T(7,sy+17))
   front({5,sy+23,6,6},5,3,11,10,z+6.52)
  end
 elseif id=='fr_industrial_rubble' then
  local stone,light,dark=T(5,7),T(4,10),T(2,9)
  -- Unequal fragments follow the pile's native footprint. There is no
  -- rectangular plinth or repeated row of equally sized round boulders.
  local function fragment(base,shoulder,peak)
   local center={peak[1],0,peak[3]}
   for i,a in ipairs(base)do
    local j=i%#base+1;local b,u,v=base[j],shoulder[i],shoulder[j]
    A.face({a,b,v,u},stone,.72+(i%3)*.08)
    A.face({u,v,peak,peak},light,.86+(i%2)*.1)
    A.face({b,a,center,center},dark,.65)
   end
  end
  fragment({{1,0,7},{3,0,4},{7,0,4},{9,0,8},{7,0,13},{2,0,12}},
   {{2,3,7},{4,4,5},{6,4,5},{8,3,8},{6,3,11},{3,3,11}},{5,4,8})
  fragment({{6,0,2},{9,0,1},{12,0,4},{10,0,8},{7,0,7}},
   {{7,2,3},{9,3,2},{11,2,4},{9,2,6},{8,2,6}},{9,3,4})
  fragment({{8,0,8},{11,0,6},{15,0,8},{14,0,12},{10,0,14},{7,0,12}},
   {{9,3,9},{11,3,7},{13,2,9},{12,3,11},{10,2,12},{8,2,11}},{11,3.2,10})
 elseif id=='gb_facility_rack' then
  local frame,dark,cap=T(1,10),T(3,10),T(3,2)
  B(1,0,15,15,2,31,dark);B(1,2,15,15,29,30,frame)
  B(1,29,15,15,31,30,cap)
  B(2,24,30,14,29,31,cap);front({2,1,12,6},2,24,14,29,31.02)
  for _,bay in ipairs({{3,12,16},{14,23,8}})do
   B(2,bay[1],29,14,bay[2],30.6,dark)
   front({2,bay[3],12,8},2,bay[1]+1,14,bay[2]-1,30.62)
   B(1,bay[1],30,15,bay[1]+1,31,frame)
   for _,x in ipairs({4,10})do B(x,bay[1]+4,30.6,x+2,bay[1]+5.5,31.2,T(x,10))end
  end
  for _,z in ipairs({18,21,24,27})do
   B(.8,5,z,1.02,23,z+.7,dark);B(14.98,5,z,15.2,23,z+.7,dark)
  end
 elseif id=='gb_facility_cable_tray' then
  local dark,red,pink,clip=T(5,2),T(1,2),T(13,2),T(0,4)
  B(0,0,0,16,.15,16,dark)
  for _,x in ipairs({1,9})do for z=0,15,2 do
   local dx=(math.floor(z/2)%4==1 or math.floor(z/2)%4==2)and 1 or 0
   B(x+dx,.15,z,x+dx+2,.65,z+2,red)
   B(x+dx,.65,z,x+dx+.6,.8,z+2,pink)
  end end
  for _,z in ipairs({4,12})do B(0,.15,z,16,.9,z+.7,clip)end
 elseif id=='fr_generator' then
  local shell,dark,metal=T(12,18),T(22,38),T(9,11)
  local grating=A.recipe.generatorGrating
  -- A curved turbine housing on four feet, with its own access platform.
  -- The complete 3x4 drawing owns the original shadow and platform pixels.
  if grating then B(1,0,13,47,1.5,63,metal)end
  for _,x in ipairs({4,37})do for _,z in ipairs({18,50})do B(x,grating and 1.5 or 0,z,x+7,5,z+7,dark)end end
  B(3,5,17,45,12,57,metal)
  for _,q in ipairs({{4,44,20},{7,41,24},{11,37,27},{16,32,29},{20,28,30}})do
   B(q[1],12,17,q[2],q[3],55,shell)
  end
  -- Separate rear ribs, raised central vent and deeply inset front grille.
  for _,z in ipairs({19,27,35,43,51})do
   B(3.5,12,z,5,19,z+1,metal);B(43,12,z,44.5,19,z+1,metal)
  end
  B(19,29,19,29,30.5,49,metal);B(21,30.5,20,27,30.7,48,dark)
  for z=21,46,3 do B(21,30.7,z,27,31.1,z+1,shell)end
  B(7,5,55,41,17,56,dark)
  front({5,34,38,18},7,5,41,17,56.02)
  B(21,8,56,27,14,58,metal);B(23,10,58,25,12,58.7,dark)
  for _,x in ipairs({8,35})do B(x,5,56,x+5,9,59,metal)end
  for _,x in ipairs(grating and {2,18,34} or {})do
   B(x,1.5,58,x+12,2,62,dark)
   for z=58,61,1.5 do B(x,2,z,x+12,2.3,z+.6,shell)end
  end
 elseif id=='gb_facility_generator' or id=='gb_facility_generator_end' then
  local pipe=id=='gb_facility_generator' and 16 or 8
  local frame,dark,light,brass=T(2,5),T(0,0),T(4,14),T(pipe+2,14)
  B(1,0,6,31,2,31,dark);B(1,2,7,31,20,30,frame)
  B(2,20,8,30,22,29,frame)
  -- Raised top cooling ribs and separate recessed equipment bays.
  for x=3,28,4 do B(x,22,10,x+1,23,27,dark)end
  for _,span in ipairs({{1,pipe},{pipe+8,31}})do
   local l,r=span[1],span[2]
   if r-l>2 then
    B(l,3,29,r,18,30.2,dark)
    front({l,16,r-l,14},l,3,r,18,30.22)
    B(l,2,30,r,3,31,light);B(l,18,30,r,19,31,light)
   end
  end
  -- A substantial vertical conduit with collars and a pale access panel.
  B(pipe+1,2,27,pipe+7,24,31.5,dark)
  for _,h in ipairs({3,7,18,22})do B(pipe+.5,h,26.5,pipe+7.5,h+1,32,brass)end
  B(pipe+1.5,11,31.5,pipe+6.5,16,32,brass)
 elseif id=='gb_tower_timber' then
  local wood,dark,edge=T(10,33),T(12,12),T(3,4)
  -- One substantial octagonal column, mortised bands and a spreading foot.
  -- Its complete six-row drawing owns the floor, so no flat core remains.
  B(1,0,21,31,2,47,dark);B(3,2,23,29,4,45,wood)
  B(6,4,25,26,37,43,wood);B(4,4,28,28,37,40,wood)
  for _,h in ipairs({5,29,36})do
   B(4,h,24,28,h+2,44,edge);B(3,h,27,29,h+2,41,edge)
  end
  for _,x in ipairs({8,15,23})do B(x,8,42.9,x+.55,28,43.2,dark);B(x,8,24.8,x+.55,28,25.1,dark)end
  B(2,38,22,30,40,46,wood)
 elseif id=='gb_lighthouse_beacon' then
  local frame,lens,dark=T(1,3),T(16,25),T(2,2)
  local glint=T(14,21)
  B(2,0,14,30,3,46,dark);B(3,3,15,29,5,45,frame)
  for _,x in ipairs({3,27})do for _,z in ipairs({16,42})do B(x,5,z,x+2,29,z+2,frame)end end
  B(3,28,15,29,30,45,frame);B(6,30,18,26,32,42,frame)
  B(9,5,24,23,8,38,dark);B(12,8,27,20,12,35,frame)
  -- Closed octagonal Fresnel discs avoid overlapping coplanar box faces.
  -- Sample the actual bright lamp, not the surrounding tabletop background.
  B(13,10,28,19,25.5,34,glint)
  for _,ring in ipairs({{12,5},{15,7},{18,8},{21,7},{24,5}})do
   local y,r=ring[1],ring[2]
   local function p(i,h)local a=(i+.5)*math.pi/4;return{16+math.cos(a)*r,h,31+math.sin(a)*r}end
   for i=0,7 do
    A.face({p(i+1,y),p(i,y),p(i,y+2),p(i+1,y+2)},lens,.88)
    A.face({{16,y+2,31},p(i+1,y+2),p(i,y+2),{16,y+2,31}},glint,1)
    A.face({{16,y,31},p(i,y),p(i+1,y),{16,y,31}},lens,.65)
   end
  end
  B(15,10,17,17,28,19,dark);B(15,25,18,17,27,31,dark)
  B(10,5,44,22,8,46,frame);front({8,40,16,7},10,5,22,8,46.02)
 elseif id=='gb_ship_dining_table' then
  local edge,wood=T(28,36),T(1,3)
  -- One tabletop shell: the generic desk cap overlapped this apron.
  for _,x in ipairs{2,28}do for _,z in ipairs{14,43}do B(x,0,z,x+2,6.5,z+2,wood)end end
  B(2,5,14,30,6.5,15,wood)
  B(1,6.5,13,31,8,46,edge)
  top({1,1,30,37},1,13,31,46,8.02)
 elseif id=='gb_ship_square_table' then
  local edge,wood,ceramic=T(28,22),T(10,28),T(9,10)
  for _,x in ipairs{2,28}do for _,z in ipairs{8,27}do B(x,0,z,x+2,6.5,z+2,wood)end end
  B(2,5,8,30,6.5,9,wood)
  B(1,6.5,7,31,8,30,edge)
  -- Partition the cloth around the original cup mark: no duplicate flat cup
  -- or coplanar overlay remains beneath the closed cup and open handle.
  for _,r in ipairs{{1,1,6,22},{17,1,14,22},{7,1,10,6},{7,17,10,6}}do
   top(r,r[1],7+(r[2]-1)*23/22,r[1]+r[3],7+(r[2]+r[4]-1)*23/22,8.02)
  end
  top({20,10,1,1},7,7+6*23/22,17,7+16*23/22,8.02)
  B(10,8.04,15,14,10.5,19,ceramic)
  top({11,10,1,1},10.7,15.7,13.3,18.3,10.52)
  B(14,9.5,16,16,10.1,18,ceramic);B(14,8.4,16,16,9,18,ceramic)
  B(15.4,9,16,16,9.5,18,ceramic)
 elseif id=='gb_ship_banquet_table' then
  local edge,wood,ceramic=T(28,68),T(10,76),T(9,10)
  local function depth(y)return 13+(y-1)*65/69 end
  for _,x in ipairs{2,28}do for _,z in ipairs{14,44,75}do B(x,0,z,x+2,6.5,z+2,wood)end end
  B(2,5,14,30,6.5,15,wood);B(2,5,45,30,6.5,46,wood)
  B(1,6.5,13,31,8,78,edge)
  -- Keep native cloth/meal drawings; partition only the two cup marks.
  for y=1,69 do
   local l,r
   if y>=7 and y<17 then l,r=7,17 elseif y>=31 and y<41 then l,r=15,25 end
   if l then
    top({1,y,l-1,1},1,depth(y),l,depth(y+1),8.02)
    top({27,10,1,1},l,depth(y),r,depth(y+1),8.02)
    top({r,y,31-r,1},r,depth(y),31,depth(y+1),8.02)
   else top({1,y,30,1},1,depth(y),31,depth(y+1),8.02)end
  end
  for _,cup in ipairs{{12,11},{20,35}}do
   local x,z=cup[1],depth(cup[2])
   B(x-2,8.02,z-2,x+2,10.5,z+2,ceramic)
   top({11,10,1,1},x-1.3,z-1.3,x+1.3,z+1.3,10.52)
   B(x+2,9.5,z-1,x+4,10.1,z+1,ceramic);B(x+2,8.4,z-1,x+4,9,z+1,ceramic)
   B(x+3.4,9,z-1,x+4,9.5,z+1,ceramic)
  end
  -- Thin closed stepped platters lift the original circular meal art.
  for _,cy in ipairs{24,56}do for row=-6,5 do
   local half=math.floor(math.sqrt(36-(row+.5)^2))+.5
   local l,r=16-half,16+half;local sy=cy+row
   B(l,8.02,depth(sy),r,8.55,depth(sy+1),T(12,cy-5))
   top({l,sy,r-l,1},l,depth(sy),r,depth(sy+1),8.57)
  end end
 elseif id=='gb_ship_captain_desk' then
  local edge,wood,dark,paper=T(44,22),T(10,28),T(18,8),T(19,10)
  for _,x in ipairs{1,33}do
   B(x,0,8,x+14,6.5,29,wood)
   front({x,24,14,8},x,0,x+14,6.5,29.02)
  end
  B(1,6.5,7,47,8,30,edge)
  -- Preserve the border, replacing only the old book mark with table cloth.
  for _,r in ipairs{{1,1,15,22},{32,1,15,22},{16,1,16,6},{16,17,16,6}}do
   top(r,r[1],7+(r[2]-1)*23/22,r[1]+r[3],7+(r[2]+r[4]-1)*23/22,8.02)
  end
  top({38,10,1,1},16,7+6*23/22,32,7+16*23/22,8.02)
  -- Closed cover and two shallow page wedges retain the native printed lines.
  B(16,8.04,14,32,8.5,23,dark)
  for _,leaf in ipairs{{17,23.7,9.5,8.9,17},{24.3,31,8.9,9.5,24}}do
   local l,r,lh,rh,sx=unpack(leaf)
   B(l,8.5,14.5,r,8.8,22.5,paper)
   S(sx,9,7,6,{l,lh,14.5},{r,rh,14.5},{r,rh,22.5},{l,lh,22.5})
   A.face({{l,lh,14.5},{r,rh,14.5},{r,8.8,14.5},{l,8.8,14.5}},paper,.75)
   A.face({{r,rh,22.5},{l,lh,22.5},{l,8.8,22.5},{r,8.8,22.5}},paper,.85)
   A.face({{l,lh,22.5},{l,lh,14.5},{l,8.8,14.5},{l,8.8,22.5}},paper,.8)
   A.face({{r,rh,14.5},{r,rh,22.5},{r,8.8,22.5},{r,8.8,14.5}},paper,.8)
  end
  B(23.7,8.5,14.5,24.3,8.9,22.5,dark)
 elseif id=='gb_ship_captain_chair' then
  local wall,frame,blue,red,dark=T(0,0),T(2,28),T(5,13),T(8,25),T(3,10)
  -- The projected backrest shares a source cell with the cabin wall.
  B(0,0,0,16,16,15.8,wall)
  for _,x in ipairs{2,12}do for _,z in ipairs{18,28}do B(x,0,z,x+2,4.5,z+2,frame)end end
  B(2,3.8,18,14,4.5,30,red);B(3,4.5,18,13,5.5,29,blue)
  top({3,19,10,5},3,19,13,29,5.52)
  B(2,4.5,16,14,14,19,dark)
  front({4,9,8,9},3,6,13,13.5,19.02)
  for _,x in ipairs{1,13}do
   B(x,4.5,21,x+2,7.5,28,frame);B(x,7.5,20,x+2,8.1,29,blue)
  end
 elseif id=='gb_ship_bin' then
  local red,cream,dark=T(7,7),T(8,10),T(8,5)
  local function p(r,y,i)local a=i*math.pi/5;return{8+r*math.cos(a),y,8+r*math.sin(a)}end
  for i=0,9 do
   local j=i+1;local body=(i==0 or i==3 or i==5 or i==8)and red or cream
   A.face({p(4.8,0,j),p(4.8,0,i),p(5,1,i),p(5,1,j)},dark,.7)
   A.face({p(5,1,j),p(5,1,i),p(6,6,i),p(6,6,j)},body,.85)
   A.face({p(6,6,j),p(6,6,i),p(6.5,9,i),p(6.5,9,j)},red,.9)
   -- Thick lip, recessed inner walls, inside floor and closed underside.
   A.face({p(5.2,9,i),p(5.2,9,j),p(6.5,9,j),p(6.5,9,i)},red,1)
   A.face({p(5.2,9,j),p(5.2,9,i),p(3.6,2,i),p(3.6,2,j)},dark,.7)
   A.face({{8,2,8},p(3.6,2,j),p(3.6,2,i),{8,2,8}},dark,.6)
   A.face({{8,0,8},p(4.8,0,i),p(4.8,0,j),{8,0,8}},dark,.6)
  end
 elseif id=='gb_ship_sideboard' then
  local wall,rim,wood,edge,ceramic=T(0,0),T(6,0),T(4,28),T(1,9),T(9,18)
  -- Restore the porthole wall independently above the low cabinet.
  B(0,0,0,32,16,15.2,wall)
  front({0,0,1,1},0,0,32,16,15.22)
  for y=0,7 do
   local inset=(y==0 or y==7)and 2 or((y==1 or y==6)and 1 or 0)
   local x,w=4+inset,8-inset*2
   B(x,15-y,15.2,x+w,16-y,15.98,rim)
   front({x,y,w,1},x,15-y,x+w,16-y,15.99)
  end
  B(1,0,16,31,6.5,31,wood);front({1,24,30,8},1,0,31,6.5,31.02)
  B(1,6.5,16,31,8,31,edge)
  local function depth(y)return 16+(y-8)*15/16 end
  for y=8,23 do
   if y>=15 then
    top({1,y,6,1},1,depth(y),7,depth(y+1),8.02)
    top({24,y,1,1},7,depth(y),17,depth(y+1),8.02)
    top({17,y,14,1},17,depth(y),31,depth(y+1),8.02)
   else top({1,y,30,1},1,depth(y),31,depth(y+1),8.02)end
  end
  local z=depth(19)
  B(10,8.02,z-2,14,10.5,z+2,ceramic)
  top({11,18,1,1},10.7,z-1.3,13.3,z+1.3,10.52)
  B(14,9.5,z-1,16,10.1,z+1,ceramic);B(14,8.4,z-1,16,9,z+1,ceramic)
  B(15.4,9,z-1,16,9.5,z+1,ceramic)
 elseif id=='gb_gate_terminal' then
  local blue,cream,dark=T(4,26),T(4,9),T(4,13)
  -- Original gate header remains on its own wall behind the lower-cell PC.
  -- Inset the shell from the outer room plane so orbit views retain its side.
  B(.05,0,.05,15.95,16,15.8,blue);front({0,0,16,8},0,8,16,16,15.82)
  B(1,0,17,15,6,30,blue)
  front({2,28,12,4},2,1,14,5.5,30.02)
  B(2,5.5,17,14,6.5,30,cream)
  crt(2,17,12,8,19,{3,12,10,7},cream,dark)
  front({3,19,10,4},3,7,13,8,24.02)
  keyboard({2,24,12,4},2,25,12,4,6.6,cream)
 elseif id=='gb_traditional_shop_shelf' then
  local frame,shelf,dark=T(1,31),T(1,8),T(4,9)
  B(.5,0,19.5,31.5,24.6,20.5,dark)
  B(.5,0,20.5,1.5,24.6,30.5,frame);B(30.5,0,20.5,31.5,24.6,30.5,frame)
  for _,y in ipairs{0,6,12,18,24}do B(1.5,y,20.5,30.5,y+.6,30.5,shelf)end
  -- Four source tiers contain distinct packets, tins and narrow packages.
  -- Preserve those groups instead of inventing evenly spaced book spines.
  local tiers={
   {18,{{2,1,6,5},{10,1,6,5},{18,1,6,5},{27,1,3,5}}},
   {12,{{3,11,4,3},{9,10,4,4},{17,10,4,4},{24,11,5,3}}},
   {6,{{3,19,4,3},{8,18,3,4},{11,17,4,5},{19,17,4,5},{27,18,3,4}}},
   {0,{{3,25,3,5},{9,26,4,4},{17,26,4,4},{25,26,4,4}}},
  }
  for _,tier in ipairs(tiers)do for i,r in ipairs(tier[2])do
   local l,w,b=r[1],r[3],tier[1]+.6;local h=b+r[4]*.88;local z=29.6-(i%2)*.35
   B(l,b,22,l+w,h,z,T(l+1,r[2]+1))
   front(r,l,b,l+w,h,z+.02)
  end end
 elseif id=='gb_radio_books' then
  local frame,shelf,dark,cap=T(1,10),T(4,8),T(2,9),T(4,2)
  B(.5,0,19.5,15.5,24.6,20.5,dark)
  B(.5,0,20.5,1.5,24.6,30.5,frame);B(14.5,0,20.5,15.5,24.6,30.5,frame)
  for _,y in ipairs{0,8,16}do B(1.5,y,20.5,14.5,y+.6,30.5,shelf)end
  B(1.5,23.4,20.5,14.5,24.6,30.5,cap)
  front({1,1,14,6},1.5,23.4,14.5,24.6,30.52)
  local function volume(x,w,sy,sh,b,h,z)
   B(x,b,23.5,x+w,h-.3,z,T(x,sy+1))
   B(x,h-.3,23.5,x+w,h,z,T(x,sy))
   front({x,sy,w,sh},x,b,x+w,h,z+.02)
  end
  for _,tier in ipairs{{16.6,10},{8.6,18}}do
   for i,book in ipairs{{3,1},{5,1},{7,1},{9,2},{12,1}}do
    volume(book[1],book[2],tier[2],3,tier[1],tier[1]+4.2,29.6-(i%2)*.25)
   end
  end
  for i,book in ipairs{{3,2},{6,2},{9,4}}do volume(book[1],book[2],26,4,.6,6.2,29.6-(i%2)*.25)end
 elseif id=='fr_space_exhibit' then
  local white,edge,dark,stand=T(19,8),T(13,7),T(13,12),T(6,23)
  B(2,0,3,46,2,30,stand);B(4,2,5,44,3,28,edge)
  for _,x in ipairs({14,34})do B(x,3,17,x+3,9,20,dark)end
  -- Closed fuselage, stepped pointed nose, paired swept wings and tail fin.
  B(7,10,15,40,14,23,white);B(10,14,16,39,16,22,white)
  B(4,11,17,10,14,21,white);B(2,11.5,18,5,13,20,edge)
  B(10,15.8,16.8,16,16.5,21.2,dark)
  for i=0,5 do
   local x=20+i*2
   B(x,10.5,14-i*1.6,x+3,12.3,24+i*1.6,white)
  end
  B(36,13,9,42,14.5,29,white)
  B(36,14,18,41,22,20,white);B(38,22,18,41,24,20,edge)
  for _,z in ipairs({16,20})do B(40,10.5,z,43,13.5,z+2,dark)end
  front({10,27,28,4},11,1,37,3,30.02)
 elseif id=='fr_stool' then
  local mat,dark=T(6,6),T(4,12)
  for _,x in ipairs({4,10})do for _,z in ipairs({4,10})do B(x,0,z,x+2,4,z+2,dark)end end
  B(3,3,3,13,4.5,13,mat);top({3,2,10,8},3,3,13,13,4.52)
 elseif id=='fr_sofa' then
  local mat,dark=T(8,17),T(3,26)
  for _,x in ipairs{3,42}do for _,z in ipairs{2,12}do B(x,0,z,x+3,3,z+3,dark)end end
  B(2,3,1,46,5,15,dark);B(2,5,0,46,16,3,mat)
  B(1,5,1,5,11,16,mat);B(43,5,1,47,11,16,mat)
  for i=0,2 do
   local l=5+i*12.6
   B(l,5,3,l+12,8,15,mat);top({4+i*13,16,12,10},l,3,l+12,15,8.02)
   front({4+i*13,3,12,12},l,8,l+12,15,3.02)
  end
 elseif id=='fr_office_table' then
  local w=A.width;local mat=T(12,20)
  desk(2,1,w-2,31,9,mat)
  top({2,3,w-4,27},2,1,w-2,31,9.02)
 elseif id=='fr_executive_table' then
  local mat,case,dark=T(12,20),T(39,22),T(44,23)
  desk(2,17,46,31,9,mat)
  top({2,16,30,13},2,17,33,31,9.02)
  -- Native terminal at the right end has its own closed shell and screen.
  crt(34,18,11,11,22,{38,19,8,8},case,dark)
  keyboard({35,27,10,3},34,27,11,3,9.1,case)
 elseif id=='fr_round_table' then
  local w=A.width;local cx=w/2
  local mat,dark=T(cx,11),T(8,54)
  B(cx-3,0,31,cx+3,8,37,dark);B(cx-14,0,32,cx+14,1,36,dark);B(cx-2,0,21,cx+2,1,47,dark)
  -- Oval source drawing, with a closed curved edge and no square base.
  for row=-21,20 do
   local half=(w/2-2)*math.sqrt(1-((row+.5)/22)^2)
   B(cx-half,8,34+row,cx+half,9,35+row,mat)
  end
  B(cx-4,9,29,cx+4,9.4,37,T(cx,28));B(cx-2,9.4,31,cx+2,12.4,35,T(cx,25))
  B(cx-1,12.4,32,cx+1,13,34,dark);B(cx+2,10,32,cx+4,11,33,T(cx,25))
 elseif id=='fr_ship_bin' or id=='fr_ship_barrel' then
  local mat,dark=T(7,9),T(4,12)
  -- Bevelled body, separate bottom, raised rim and inset lid.
  B(4,0,4,12,1,12,dark);B(3,1,4,13,10,12,mat);B(4,1,3,12,10,13,mat)
  B(3,10,3,13,11,13,dark);B(4,11,4,12,11.5,12,mat)
  top({3,1,10,6},3,3,13,13,11.52)
  for x=4,11,3 do B(x,2,12,x+.5,9,12.3,dark)end
 elseif id=='fr_ship_porthole' then
  local rim=T(6,5)
  B(0,0,12,16,32,15,T(0,12))
  for _,q in ipairs({{3,11,14,13,13,16},{3,13,14,5,22,16},{11,13,14,13,22,16},{5,22,14,11,24,16}})do
   B(q[1],q[2],q[3],q[4],q[5],q[6],rim)
  end
  B(5,13,14,11,22,15.7,T(7,8));front({4,3,8,11},4,12,12,23,15.72)
 elseif id=='fr_ship_bed' then
  local frame,linen=T(15,14),T(24,18)
  for _,x in ipairs({14,32})do for _,z in ipairs({4,28})do B(x,0,z,x+2,4,z+2,frame)end end
  B(14,3,3,34,4,30,frame);B(15,4,4,33,5.5,29,linen)
  B(14,4,2,34,8,4,frame);B(14,4,28,34,6,30,frame)
  top({14,14,20,16},15,12,33,28,5.52)
  B(16,5.5,5,32,6.5,11,linen);top({16,4,16,7},16,5,32,11,6.52)
 elseif id=='fr_ship_chair' then
  local frame,seat=T(4,13),T(8,6);local reverse=A.recipe.reverse
  for _,x in ipairs({3,11})do for _,z in ipairs({3,11})do B(x,0,z,x+2,5,z+2,frame)end end
  B(2,4,2,14,5.5,14,seat);top({4,4,8,8},2,2,14,14,5.52)
  local l=reverse and 2 or 12
  B(l,5.5,2,l+2,15,14,frame);B(l-.05,7,3,l+2.05,14,13,seat)
 elseif id=='fr_ship_table' then
  local mat=T(4,7);desk(1,3,47,27,7,mat)
  top({1,3,46,22},1,3,47,27,7.02)
  -- Raised plate and cup preserve the original table's place setting.
  B(20,7,9,28,7.5,17,T(24,7));B(22,7.5,11,26,9,15,T(24,11))
 elseif id=='fr_ship_side_table' then
  local mat=T(12,24);desk(1,17,31,43,7,mat)
  top({1,17,30,22},1,17,31,43,7.02)
  B(22,7,28,28,8,34,T(26,26));B(23,8,29,27,11,33,T(26,24))
 elseif id=='fr_ship_rail' then
  local metal,dark=T(7,5),T(7,12)
  for _,x in ipairs({1,13})do B(x,0,11,x+2,13,13,metal)end
  B(0,11,10,16,13,14,metal);B(0,5,11,16,6.5,13,dark)
 elseif id=='fr_tower_grave' then
  local stone,dark,cap=T(6,4),T(3,10),T(7,1)
  -- A low foot, recessed upright inscription and stepped stone crown.
  -- Closed backs and undersides remain visible from first-person/orbit views.
  B(2,0,4,14,1.5,15,dark)
  B(3,1.5,6,13,10.5,13,stone)
  B(4,10.5,7,12,12,12,cap)
  B(3.5,1.5,12.8,12.5,2.5,13.3,dark)
  front({3,2,10,11},3,2.5,13,10.5,13.02)
 elseif id=='fr_museum_bookcase' then
  -- The white header is a single panel, not part of each book spine.
  local frame,dark=T(1,22),T(4,25)
  shelves(1,20,30,11,27,{{8,13,{3,28,26,4}},{16,21,{3,22,26,4}}},frame,dark,true)
  B(2,21,21,30,26,30.5,T(5,15))
  front({2,12,28,9},2,21,30,26,30.52)
  B(2,1,21,30,7,30.5,frame);front({2,32,28,6},2,1,30,7,30.52)
 elseif id=='fr_center_storage' or id=='fr_home_bookcase' then
  local frame,dark=T(2,22),T(6,29)
  shelves(1,18,30,13,29,{{3,8,{3,32,26,4}},{11,16,{3,25,26,4}}},frame,dark,true)
  B(2,17,19,30,28,30.5,T(7,16))
  front({2,12,28,12},2,17,30,28,30.52)
 elseif id=='fr_native_books' or id=='fr_native_monitor' or id=='fr_native_rack' then
  local r=A.recipe;local w,h=A.width,A.height;local face=r.facade or {0,0,w,h}
  local z=r.frontOffset or h-1;local height=r.h or h-2;local rear=z-(r.depth or 11)
  local mat=T((r.material or {1,1})[1],(r.material or {1,1})[2]);local dark=T(face[1]+1,face[2]+face[4]-.5)
  if id=='fr_native_books' then
   local half=face[4]/2
   shelves(1,rear,w-2,z-rear,height,{{2,height/2-1,{face[1],face[2]+half,face[3],half}},
    {height/2+1,height-2,{face[1],face[2],face[3],half}}},mat,dark,true)
  elseif id=='fr_native_monitor' then
   B(2,0,rear,w-2,5,z,mat)
   crt(1,rear,w-2,7,height,{face[1]+1,face[2],face[3]-2,face[4]*.65},mat,dark)
   keyboard({face[1]+1,face[2]+face[4]*.65,face[3]-2,face[4]*.35},2,z-3,w-4,3,5.1,mat)
  else
   B(1,0,rear,w-1,height,rear+1,mat)
   B(1,0,rear,2,height,z,mat);B(w-2,0,rear,w-1,height,z,mat)
   local count=height>25 and 3 or 2;local span=(height-2)/count
   for j=0,count-1 do
    local base=1+j*span;local f=z-1.5-(j%2)*.7
    B(2,base,rear+1,w-2,base+span-1,f,mat)
    front({face[1],face[2]+face[4]*(count-j-1)/count,face[3],face[4]/count},2,base,w-2,base+span-1,f+.02)
    B(w-4,base+1,f,w-3,base+2,f+.8,dark)
   end
   B(1,height-1,rear,w-1,height,z,mat)
  end
 elseif id=='fr_native_cabinet' then
  local r=A.recipe;local w,h=A.width,A.height
  local face=r.facade or {0,0,w,h}
  local z=r.frontOffset or h-1
  local height=r.h or h-2;local base=r.base or 0
  local depth=r.depth or 11;local rear=z-depth
  local mat=T((r.material or {1,1})[1],(r.material or {1,1})[2])
  -- Complete native facade inset into a closed cabinet, with real side
  -- panels, a raised cornice, kickboard and recessed front equipment.
  B(1,base,rear,w-1,height,rear+1,mat)
  B(1,base,rear,2,height,z,mat);B(w-2,base,rear,w-1,height,z,mat)
  B(1,height-1,rear,w-1,height,z,mat);B(1,base,rear,w-1,base+1.5,z,mat)
  B(2,base+1.5,rear,w-2,height-1,z-1,mat)
  -- Thin wall displays cannot use a cabinet-depth recess: it puts the
  -- picture behind the room's wallpaper, leaving an apparently blank frame.
  front(face,2,base+1.5,w-2,height-1,z-(depth<=2 and .08 or .98))
  -- Wide shelves retain every item in the source facade while central
  -- uprights divide physically separate storage bays.
  if w>=32 then for x=16,w-8,16 do B(x-.4,base+1.5,z-.8,x+.4,height-1,z,mat)end end
 elseif id=='gb_mansion_workstation' or id=='gb_facility_workstation' then
  local wood,case,dark=T(2,2),T(23,3),T(21,7)
  desk(1,1,31,15,7,wood)
  -- Original papers and desk objects stay on the left working surface.
  -- The projected monitor at right becomes a separate complete CRT.
  top({1,1,18,14},1,1,19,15,7.02)
  keyboard({4,8,12,6},4,8,12,6,7.1,case)
  local rim={{4,7.7,8},{16,7.7,8},{16,7.15,14},{4,7.15,14}}
  for i,a in ipairs(rim)do local b=rim[i%4+1]
   A.face({a,b,{b[1],7.1,b[3]},{a[1],7.1,a[3]}},case,.82)
  end
  crt(19,2,11,8,17,{22,7,1,1},case,dark)
  -- Native display is a parallelogram across contiguous atlas quadrants.
  A.face({{20,16,8.99},{29,16,8.99},{29,9,8.99},{20,9,8.99}},
   {T(21,5)[1],T(25,7)[1],T(25,10)[1],T(21,8)[1]},1)
 elseif id=='gb_ship_porthole' then
  -- Closed wall with the native eight-pixel circular rim standing proud of it.
  -- Stepped ring rows omit the source's square cream corners; no glass on top.
  local wall,rim=T(0,0),T(6,0)
  B(0,0,0,16,16,15.2,wall)
  front({0,0,1,1},0,8,16,16,15.22)
  B(0,0,15.2,16,8,15.98,wall)
  front({0,8,16,8},0,0,16,8,15.99)
  for y=0,7 do
   local inset=(y==0 or y==7) and 2 or ((y==1 or y==6) and 1 or 0)
   local x,w=4+inset,8-inset*2
   B(x,15-y,15.2,x+w,16-y,15.98,rim)
   front({x,y,w,1},x,15-y,x+w,16-y,15.99)
  end
 elseif id=='gb_mansion_bed' or id=='gb_cabin_bed' then
  -- Original head/foot boards stand upright; bedding occupies the mattress.
  -- Both native cells are blocked, including the projected head of the bed.
  local cabin=id=='gb_cabin_bed'
  local crystal=cabin and A.recipe and A.recipe.tiles[3][1]==131
  local frame,cloth,edge=T(cabin and 6 or 2,cabin and 4 or 3),T(7,15),T(1,15)
  local foot=cabin and T(6,27) or frame
  for _,x in ipairs{1,13}do for _,z in ipairs{1,28}do
   B(x,0,z,x+2,z==1 and 10 or 7,z+2,z==1 and frame or foot)
   B(x,z==1 and 10 or 7,z,x+2,z==1 and 10.5 or 7.5,z+2,T(1,1))
  end end
  B(2,2,2,14,4,30,frame)
  B(2,4,4,14,5.5,28,edge)
  B(3,5.5,9,13,6,27,cloth)
  top({3,cabin and 10 or 8,10,cabin and 12 or 16},3,9,13,27,6.02)
  B(3,5.5,4,13,6.5,8,cloth)
  top(crystal and {4,7,8,2} or {5,cabin and 5 or 6,6,1},3,4,13,8,6.52)
  B(3,4,1,13,9,3,frame)
  B(3,2,28,13,6.5,30,foot)
  front(cabin and {3,3,10,3} or {1,1,14,2},3,4,13,9,3.02)
  front(cabin and {3,25,10,5} or {1,25,14,2},3,2,13,6.5,30.02)
 elseif id=='gb_facility_sofa' then
  -- Separate the projected blue seat and tufted back from their floor corners.
  -- Closed upholstery and stepped shoulders preserve the native rounded form.
  local blue,cloth,dark=T(15,7),T(15,10),T(4,8)
  for _,x in ipairs{3,27}do for _,z in ipairs{3,12}do B(x,0,z,x+2,2,z+2,dark)end end
  B(2,1.5,2,30,4.5,15,blue)
  B(4,4.5,5,28,5.5,14.5,cloth)
  top({5,8,22,6},4,5,28,14.5,5.52)
  B(3,4,1,29,11,4.5,blue)
  B(4,11,1.5,28,12,4,blue)
  front({4,1,24,5},4,6,28,11,4.52)
  for _,x in ipairs{1,28}do
   B(x,3,4,x+3,7,14,blue)
   B(x+.5,7,5,x+2.5,8,13,cloth)
  end
  top({1,8,3,5},1.5,5,3.5,13,8.02)
  top({28,8,3,5},28.5,5,30.5,13,8.02)
 elseif id=='gb_cabin_books' then
  local wood,dark=T(4,4),T(2,10)
  B(1,0,20,15,24,21,wood)
  B(1,0,21,2,24,30,wood);B(14,0,21,15,24,30,wood)
  B(2,0,21,14,8,30,wood)
  front({1,24,14,8},1,0,15,8,30.02)
  for _,tier in ipairs{{8,19},{16,11}}do
   local base,sy=tier[1],tier[2]
   B(2,base-1,21,14,base,30,wood)
   B(2,base,21,14,base+7,22,dark)
   -- Four short native groups, with the second/fourth spines one pixel taller.
   for _,book in ipairs{{3,2,2},{6,2,3},{9,1,2},{11,2,3}}do
    local x,w,h=book[1],book[2],book[3]
    B(x,base,22,x+w,base+h,29.5,T(x,sy))
    front({x,sy,w,h},x,base,x+w,base+h,29.52)
   end
  end
  B(.5,23,19.5,15.5,24.5,30.5,wood)
  top({1,1,14,6},.5,19.5,15.5,30.5,24.52)
 elseif id=='gb_facility_books' or id=='gb_facility_books_open' then
  local wood,dark=T(4,4),T(2,10)
  local open=id=='gb_facility_books_open'
  B(1,0,20,15,24,21,wood)
  B(1,0,21,2,24,30,wood);B(14,0,21,15,24,30,wood)
  B(2,0,21,14,open and 1 or 8,30,wood)
  if not open then front({1,24,14,8},1,0,15,8,30.02)end
  local tiers=open and {{1,25},{8,17},{16,9}} or {{8,17},{16,9}}
  for _,tier in ipairs(tiers)do
   local base,sy=tier[1],tier[2]
   B(2,math.max(0,base-1),21,14,base,30,wood)
   B(2,base,21,14,base+7,22,dark)
   for _,book in ipairs({{3,2},{6,1},{8,2},{11,2}})do
    local x,w=book[1],book[2]
    B(x,base,22,x+w,base+6,29.5,T(x,sy+1))
    front({x,sy,w,6},x,base,x+w,base+6,29.52)
   end
  end
  B(.5,23,19.5,15.5,24.5,30.5,wood)
  top({1,1,14,6},.5,19.5,15.5,30.5,24.52)
 elseif id=='gb_mansion_books' then
  -- Blank wall and projected lid occupy the upper half of this drawing.
  -- Its lower half is one low book rack over two storage panels.
  local wood,dark=T(4,12),T(2,17)
  B(1,0,20,15,16,21,wood)
  B(1,0,21,2,16,30,wood);B(14,0,21,15,16,30,wood)
  B(2,0,21,14,7,30,wood)
  front({1,24,14,8},1,0,15,8,30.02)
  B(2,7,21,14,8,30,wood);B(2,8,21,14,15,22,dark)
  for _,book in ipairs({{3,2},{6,1},{8,2},{11,2}})do
   local x,w=book[1],book[2]
   B(x,8,22,x+w,14,29.6,T(x,19))
   front({x,17,w,6},x,8,x+w,14,29.62)
  end
  B(.5,15,19.5,15.5,16.5,30.5,wood)
  top({1,9,14,6},.5,19.5,15.5,30.5,16.52)
 elseif id=='gb_mansion_clock' then
  -- The upper eight native rows are the projected crown; the remaining
  -- twenty-four rows form one clock face/case, never two book shelves.
  local wood,dark=T(4,4),T(2,10)
  B(1,0,20,15,24,29.45,wood)
  B(1,0,29.45,4,24,30,wood);B(12,0,29.45,15,24,30,wood)
  B(4,0,29.45,12,10,30,wood);B(4,22,29.45,12,24,30,wood)
  front({1,8,14,2},1,22,15,24,30.02)
  front({1,10,3,12},1,10,4,22,30.02)
  front({12,10,3,12},12,10,15,22,30.02)
  front({1,22,14,10},1,0,15,10,30.02)
  -- Preserve the original dial/pendulum pixels in a shallow glazed recess.
  front({4,10,8,12},4,10,12,22,29.47)
  B(3.8,10,29.45,4,22,30,dark);B(12,10,29.45,12.2,22,30,dark)
  B(4,9.8,29.45,12,10,30,dark);B(4,22,29.45,12,22.2,30,dark)
  B(.5,24,19.5,15.5,25.5,30.5,wood)
  top({1,1,14,6},.5,19.5,15.5,30.5,25.52)
 elseif id:match('^gb_native_') then
  local w,h=A.width,A.height
  local mat,dark=T(1,1),T(math.min(3,w-1),math.min(8,h-1))
  local rear=math.max(1,h-13);local f=h-1
  if id=='gb_native_cabinet' then
   -- Source upper and lower racks occupy distinct recessed shelves.
   shelves(1,rear,w-2,11,h-2,{{2,h/2-1,{1,h/2,w-2,h/2-1}},
    {h/2+1,h-3,{1,1,w-2,h/2-2}}},mat,dark,true)
  elseif id=='gb_native_machine' then
   B(2,0,rear,w-2,5,f,mat)
   front({1,h-6,w-2,5},2,0,w-2,5,f+.02)
   local topHeight=math.max(12,h-3)
   crt(1,rear-1,w-2,6,topHeight,{2,2,w-4,math.max(4,h-11)},mat,dark)
   keyboard({1,h-9,w-2,3},2,f-3,w-4,3,5.1,mat)
  elseif id=='gb_native_seat' then
   desk(2,math.max(1,h-11),w-2,h-2,3,mat)
   B(1,3,h-12,w-1,4,h-1,mat)
   top({1,math.max(0,h-10),w-2,8},1,h-11,w-1,h-1,4.02)
   B(1,4,h-12,w-1,9,h-10,mat)
   front({1,0,w-2,5},1,4,w-1,9,h-9.98)
  elseif id=='gb_native_bed' then
   desk(1,2,w-1,h-1,4,mat)
   B(1,4,2,w-1,6,h-1,mat);top({1,2,w-2,h-4},1,2,w-1,h-1,6.02)
   B(1,4,1,w-1,8,3,mat)
   B(3,6,4,w-3,7,9,mat);top({3,3,w-6,5},3,4,w-3,9,7.02)
  elseif id=='gb_native_table' then
   desk(1,1,w-1,h-1,6,mat);top({1,1,w-2,h-2},1,1,w-1,h-1,6.02)
  else
   desk(1,1,w-1,h-1,6,mat)
   keyboard({0,0,w,h-3},1,1,w-2,h-4,6.1,mat)
   front({0,h-3,w,3},1,4,w-1,6,h-1.01)
  end
 elseif id=='fr_bed' or id=='fr_lorelei_bed' then
  -- The upper drawing is projected height: only the centre foot cell is
  -- blocked in either native room. Keep rails, pillow and mattress there.
  local lorelei=id=='fr_lorelei_bed'
  local z=lorelei and 16 or 32
  local frame,cloth=T(lorelei and 14 or 15,lorelei and 6 or 16),T(lorelei and 21 or 17,lorelei and 20 or 25)
  for _,x in ipairs{16.3,29.9}do for _,dz in ipairs{.3,13.9}do B(x,0,z+dz,x+1.8,3,z+dz+1.8,frame)end end
  B(16.2,2,z+.2,31.8,4,z+15.8,frame)
  B(17,4,z+1.2,31,5.5,z+14.8,cloth)
  top(lorelei and {14,10,20,17} or {14,24,20,19},17,z+4.8,31,z+14.8,5.52)
  B(17.5,5.5,z+1.3,30.5,6.6,z+4.8,T(lorelei and 20 or 17,lorelei and 8 or 25))
  top(lorelei and {15,5,18,5} or {16,20,16,4},17.5,z+1.3,30.5,z+4.8,6.62)
  B(16.2,2,z+.2,31.8,8,z+1,frame)
  B(16.2,2,z+15,31.8,5,z+15.8,frame)
  for _,x in ipairs{16.2,31}do B(x,2,z+1,x+.8,5,z+15,frame)end
 elseif id=='fr_room_pc' then
  local wood,case,dark=T(17,22),T(3,13),T(7,22)
  desk(1,19,31,31,7,wood)
  top({16,16,16,7},16,20,31,30,7.02)
  crt(1,18,14,9,21,{2,17,12,9},case,dark)
  keyboard({2,27,12,4},2,26,12,4,7.1,case)
  -- The native blue floor seat stays low in the walkable approach row.
  B(3,0,35,13,.6,45,T(7,40));top({3,38,10,6},3,35,13,45,.62)
 elseif id=='fr_room_dresser' then
  local wood,dark=T(3,12),T(2,24)
  for _,x in ipairs({2,12})do for _,z in ipairs({18,28})do B(x,0,z,x+2,3,z+2,dark)end end
  B(1,2,17,15,15,30,wood)
  B(1,15,16,15,16.2,31,wood);top({3,3,10,7},2,17,14,30,16.22)
  for _,q in ipairs({{3,8,19},{9,14,12}})do
   B(3,q[1],29.6,13,q[2],30.4,dark)
   front({4,q[3],8,5},3.4,q[1]+.3,12.6,q[2]-.3,30.42)
   B(7,(q[1]+q[2])/2,30.4,9,(q[1]+q[2])/2+.7,31,dark)
  end
 elseif id=='fr_console' then
  local mat,dark=T(2,7),T(2,23)
  B(1,0,7,15,6,17,mat);front({1,17,14,6},1,0,15,6,17.02)
  crt(1,7,14,7.5,19,{2,8,12,8},mat,dark)
  console(2,25,{2,27,12,6},{2,36,6,3},T(5,29),dark)
 elseif id=='fr_television' then
  local case,dark=T(1,19),T(9,33)
  shelves(2,27,28,10,10,{{2,8,{3,34,26,6}}},case,dark)
  crt(2,26,28,12,29,{3,13,26,16},case,dark)
 elseif id=='fr_wall_picture' then
  B(1,9,31.92,15,23,32.6,T(1,9))
  local rim=T(2,10)
  B(1,9,32.6,2,23,32.9,rim);B(14,9,32.6,15,23,32.9,rim)
  B(2,9,32.6,14,10,32.9,rim);B(2,22,32.6,14,23,32.9,rim)
  front({2,10,12,12},2,10,14,22,32.62)
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
 elseif id=='fr_mart_sidecase' or id=='fr_mart_island' then
  -- Native islands are cream-sided, double-sided racks. Product labels
  -- belong on the outward faces, never stretched across the stock's lids.
  local wide=id=='fr_mart_island'
  local case,trim=T(14,23),T(10,53)
  local spine=wide and 16 or 14
  B(2,0,14,wide and 30 or 15,2,60,trim)
  B(spine-1,2,12,spine+1,15,60,case)
  for _,side in ipairs(wide and {-1,1} or {-1})do
   local l,r=side<0 and 2 or spine+1,side<0 and spine-1 or 30
   for row=0,1 do
    local z=16+row*23
    B(l,2,z,r,4,z+20,case)
    B(l,4,z,l+1,10,z+20,case);B(r-1,4,z,r,10,z+20,case)
    for j=0,2 do
     local n=z+2+j*5.5;local sx=side<0 and 4 or 24
     local sy=(row==0 and {19,22,27} or {37,40,44})[j+1]
     local mat=T(sx+2,sy+1)
     B(l+1.2,4,n,r-1.2,9,n+4.5,mat)
     local face=side<0 and l+1.18 or r-1.18
     S(sx,sy,3,2,{face,9,n},{face,9,n+4.5},{face,4,n+4.5},{face,4,n})
    end
   end
  end
 elseif id=='fr_lab_free_books' then
  local G={sample=function(x,y)return T(x,y+16)end,
   box=function(l,b,n,r,h,f,uv)B(l,b,n+16,r,h,f+16,uv)end,
   source=function(x,y,w,h,a,b,c,d)
    for _,p in ipairs({a,b,c,d})do p[3]=p[3]+16 end
    S(x,y+16,w,h,a,b,c,d)
   end}
  return M.draw('fr_lab_books',G)
 elseif id=='fr_mart_counter' or id=='fr_mart_counter_end' then
  local long=id=='fr_mart_counter'
  local w=long and 48 or 16
  local n=long and 23 or 0
  local case=T(long and 2 or 1,28)
  -- Continuous closed cabinetry; the source floor above the horizontal
  -- glass case must not become a deep tabletop in the clerk's aisle.
  B(0,0,n+.5,w,6.2,31,case)
  B(0,6.2,n,w,7,32,T(long and 1 or 0,17))
  if long then
   top({0,17,48,10},0,n,48,32,7.02)
   front({0,27,48,5},0,0,48,6.2,32.02)
   cushion(1,1,14,14,{0,0,16,16},T(4,4),T(1,1))
  else
   top({0,0,16,24},0,0,16,32,7.02)
   front({0,26,16,6},0,0,16,6.2,32.02)
  end
 elseif id=='fr_mart_register' then
  local case,dark=T(11,18),T(5,21)
  -- A full counter pedestal supports the till, display and sloped keypad.
  B(1,0,17,15,6,31,case);B(0,6,16,16,7,32,case)
  B(3,7,19,14,9,29,dark)
  B(8,9,18,14,16,22,case)
  front({8,12,6,7},8.5,10,13.5,15,22.02)
  B(3,9,22,14,10,29,case)
  S(2,18,7,10,{3,12,22},{8,12,22},{8,10.02,29},{3,10.02,29})
  front({4,28,10,2},3,7.5,14,9,29.02)
 elseif id=='fr_mart_cooler' then
  -- The first source row is wallpaper. Keep it on the room wall; the
  -- cabinets stand in front of that wall with cream tops and closed backs.
  for j=0,1 do local x=j*24
   local case=T(x+2,18)
   shelves(x+1,32,22,12,25,{{4,12,{x+3,29,18,6}},{14,22,{x+3,23,18,6}}},case,T(x+4,34),true)
   B(x+1,24,32,x+23,25,44,case)
   front({x+2,37,20,6},x+2,0,x+22,4,44.02)
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
 elseif id=='gb_radio' then
  local case,wood,dark=T(1,3),T(2,20),T(5,7)
  B(2,0,14,14,5,23,wood);front({2,18,12,5},2,0,14,5,23.02)
  B(1,5,14,15,16,22,case);B(2,16,15,14,17,21,case)
  front({1,3,14,13},1,5,15,16,22.02)
  B(11,7,22,13,9,22.6,dark);B(3,6,22,8,6.6,22.4,dark)
 elseif id=='gb_traditional_picture' then
  -- Kurt's framed picture belongs to the upper wall. The former low-table
  -- crop laid this art on the floor. Keep its backing and frame entirely
  -- inside the two native blocked northern cells, above the clear apron.
  local wood,gilt=T(1,5),T(4,2)
  B(0,16,0,32,32,1,wood)
  front({0,0,32,16},0,16,32,32,1.02)
  B(2,17,1.02,3,31,1.5,gilt);B(29,17,1.02,30,31,1.5,gilt)
  B(3,17,1.02,29,18,1.5,gilt);B(3,30,1.02,29,31,1.5,gilt)
 elseif id=='gb_traditional_table' then
  desk(1,7,31,38,5,T(1,20));top({1,1,30,30},1,7,31,38,5.02)
 elseif id=='gb_traditional_hutch' or id=='gb_traditional_drawers' then
  local wood,dark=T(2,2),T(3,10);local n,f=21,31
  B(1,0,n,15,2,f,wood);B(1,2,n,2,27,f,wood);B(14,2,n,15,27,f,wood)
  B(1,2,n,15,27,n+1,wood);B(1,27,n,15,29,f,wood)
  if id=='gb_traditional_hutch' then
   B(2,10,n+1,14,26,f-1,dark);front({2,9,12,14},2,10,14,26,f-.98)
   B(2,2,n+1,14,9,f,wood);front({2,25,12,6},2,2,14,9,f+.02)
   B(1,9,n,15,10,f+.3,wood)
  else
   for i=0,2 do
    local bottom=2+i*8;local sy=24-i*8
    B(2,bottom,n+1,14,bottom+7,f,wood);front({2,sy+1,12,6},2,bottom,14,bottom+7,f+.02)
    B(7,bottom+3,f,9,bottom+4,f+.65,dark)
   end
  end
 elseif id=='gb_traditional_tall_books' then
  -- Kurt's tall rack: two tiers of five original spines over storage doors.
  -- The top source row is the polished projected lid, not another shelf.
  local wood,dark=T(4,4),T(2,10)
  B(1,0,20,15,24,21,wood)
  B(1,0,21,2,24,30,wood);B(14,0,21,15,24,30,wood)
  B(2,0,21,14,8,30,wood);front({1,24,14,8},1,0,15,8,30.02)
  for _,tier in ipairs({{8,18},{16,10}})do
   local base,sy=tier[1],tier[2]
   B(2,base-1,21,14,base,30,wood)
   B(2,base,21,14,base+7,22,dark)
   for _,book in ipairs({{3,1},{5,1},{7,1},{9,2},{12,1}})do
    local x,w=book[1],book[2]
    B(x,base,22,x+w,base+6,29.5,T(x,sy))
    front({x,sy,w,5},x,base,x+w,base+6,29.52)
   end
  end
  B(.5,23,19.5,15.5,24.5,30.5,wood)
  top({1,1,14,6},.5,19.5,15.5,30.5,24.52)
 elseif id=='gb_traditional_books' then
  shelves(1,13,14,10,21,{{9,18,{1,9,14,6}}},T(1,1),T(3,12),true)
  B(2,2,14,14,8,23,T(1,1));front({1,17,14,6},2,2,14,8,23.02)
 elseif id=='gb_traditional_cupboard' then
  local mat=T(1,1);B(1,0,13,15,20,23,mat);B(1,20,13,15,21,24,mat)
  front({1,9,14,14},2,1,14,19,23.02)
  B(7.7,1,23,8.3,19,23.3,T(3,12))
 elseif id=='gb_traditional_radio' then
  local mat,dark=T(2,4),T(8,10)
  B(1,0,6,15,10,14,mat);B(2,10,7,14,11,13,mat)
  front({1,1,14,14},1,0,15,10,14.02)
  B(10,3,14,12,5,14.6,dark)
 elseif id=='gb_battle_elevator_entry' then
  local wall,frame=T(2,9),T(17,9)
  -- Only the upper-left native cell is blocked. Its projected front/shadow
  -- folds back onto that cell; the lower row and door approach stay clear.
  B(0,0,0,16,16,15.9,wall)
  front({0,8,16,16},0,0,16,16,15.92)
  top({0,0,16,8},0,0,16,16,16.02)
  B(16,0,0,32,16,.5,frame)
  front({17,9,14,14},17,0,31,15,.52)
  B(16,0,.5,17,16,16,frame);B(31,0,.5,32,16,16,frame)
  B(16,15,.5,32,16,16,frame)
  top({16,0,16,8},16,0,32,16,16.02)
 elseif id=='gb_battle_tower_door' then
  local frame=T(1,1)
  -- Native warp or inactive door cells remain open up to the rear plane.
  -- The control panel is part of that rear face, not a box in the approach.
  B(0,0,0,16,16,.5,frame)
  front({1,1,14,14},1,0,15,15,.52)
  B(0,0,.5,1,16,16,frame);B(15,0,.5,16,16,16,frame)
  B(0,15,.5,16,16,16,frame)
 elseif id=='gb_battle_tower_pc' then
  local case,dark=T(1,3),T(5,12)
  -- This is the complete integrated blue kiosk: projected lid, upright
  -- display, lower controls and pedestal are distinct native surfaces.
  B(2,0,19,14,7,30,case);front({1,26,14,6},2,0,14,7,30.02)
  B(2,7,17,14,21,28,case)
  B(1,9,28,3,21,29,case);B(13,9,28,15,21,29,case)
  B(3,9,28,13,10,29,case);B(3,20,28,13,21,29,case)
  front({3,11,10,8},3,10,13,20,28.98)
  B(1,21,17,15,22,29,case);B(2,22,18,14,23,28,case)
  top({2,1,12,6},2,18,14,28,23.02)
  B(1,7,26,15,8,31,case)
  S(2,21,12,5,{2,9,26},{14,9,26},{14,8.05,31},{2,8.05,31})
  A.face({{2,8,26},{2,8,31},{2,8.05,31},{2,9,26}},case,.78)
  A.face({{14,8,31},{14,8,26},{14,9,26},{14,8.05,31}},case,.78)
  A.face({{2,8,31},{14,8,31},{14,8.05,31},{2,8.05,31}},case,.85)
  A.face({{14,8,26},{2,8,26},{2,9,26},{14,9,26}},case,.7)
  for y=11,17,2 do B(13.98,y,19,14.02,y+.5,25,dark)end
 elseif id=='gb_rocket_terminal' then
  local case,dark=T(4,11),T(1,24)
  -- A working surface with knee space, a drawer pedestal and one desktop
  -- monitor/mouse. The projected monitor is no longer repeated on the lid.
  desk(1,16,31,31,7,case)
  B(17,0,18,30,5.8,30,dark)
  front({17,24,14,7},17,0,30,5.8,30.02)
  crt(17,17,13,9,19,{21,15,1,1},case,dark)
  -- Unproject the original parallelogram display; its atlas region spans
  -- contiguous78/79 and94/95 tiles, so these four source corners stay native.
  A.face({{18,18,23.99},{29,18,23.99},{29,10,23.99},{18,10,23.99}},
   {T(20,13)[1],T(24,15)[1],T(24,18)[1],T(20,16)[1]},1)
  B(7,7,25,12,7.7,29,dark)
  B(8,7.7,25.5,11,8.6,28.5,case)
  top({8,18,5,5},7.5,25,11.5,29,8.62)
  -- The mouse lead follows the original unobtrusive dark desktop palette.
  B(9,7.04,23,9.25,7.25,25,dark)
  B(9,7.04,23,18,7.25,23.25,dark)
 elseif id=='gb_rocket_books' then
  local wood,dark=T(1,9),T(3,10)
  shelves(1,20,14,10,26,{},wood,dark)
  -- The native artwork has three spines per tier. Integer crops preserve
  -- each spine instead of splitting pixel columns between arbitrary books.
  for _,row in ipairs({{9,16},{17,8}})do
   B(1.5,row[1]-.7,21,14.5,row[1],30.2,wood)
   for _,book in ipairs({{3,2,5},{6,2,5},{10,3,6}})do
    local x,w,h=book[1],book[2],book[3]
    B(x,row[1],22,x+w,row[1]+h,29,T(x,row[2]+1))
    front({x,row[2]+1,w,h},x,row[1],x+w,row[1]+h,29.02)
   end
  end
  B(2,1.5,21,14,8,29,wood)
  front({1,24,14,7},2,1.5,14,8,29.02)
  top({1,1,14,6},1,20,15,30,26.02)
 elseif id=='gb_house_tall_books' then
  shelves(1,21,14,10,24,{{3,11,{1,17,14,6}},{13,22,{1,9,14,6}}},T(1,1),T(3,12))
 elseif id=='gb_house_books' then
  shelves(1,13,14,10,21,{{2,9,{1,9,14,6}},{11,19,{1,1,14,6}}},T(1,1),T(3,8))
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
  shelves(1,20,14,10,25,{{3,11,{1,21,14,8}},{13,22,{1,9,14,10}}},T(1,1),T(2,16),true)
  B(12,6,30,13,18,30.4,T(1,1))
 elseif id=='gb_mart_display' then
  local case=T(1,1)
  B(1,0,5,30,5,29,case);B(13,5,4,17,16,30,case)
  for _,q in ipairs({{1,12},{18,30}})do
   B(q[1],5,6,q[2],7,28,case);stock({q[1],5,q[2]-q[1],22},q[1]+.5,7,q[2]-q[1]-1,18,7,11,3)
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
  B(4,6,8,28,12,11,case);front({4,0,24,7},4,6,28,12,11.02)
  for _,x in ipairs({2,28})do B(x,6,10,x+2,7.2,29,case)end
  B(3,1,29,29,3,29.5,T(7,27))
elseif id=='fr_lab_centrifuge' then
  -- Oak's lab bank: a 3x2 cabinet run whose six source cells are each half a
  -- machine, so it is built as real geometry rather than one stretched drawing.
  -- Blue case, recessed orange canister, a lit control strip and a plinth, all
  -- inside the native footprint.
  local case,shade,orange,glass=T(6,10),T(6,18),T(9,3),T(4,14)
  B(1,0,4,46,3,20,T(3,20))
  B(2,3,5,45,5,19,case)
  B(3,5,6,44,20,18,shade)
  -- three canisters across the top course
  for _,x in ipairs({4,18,32})do
   B(x,8,7,x+11,17,15,case)
   B(x+1.5,9.5,7.4,x+9.5,15.5,8.2,orange)
   B(x+2,11,7.2,x+9,14,8,orange)
  end
  -- lower course: doors and a lit strip
  for _,x in ipairs({4,18,32})do
   B(x,4.5,7,x+11,7.5,15,glass)
   B(x+1,5,6.6,x+10,7.2,15.6,case)
  end
  B(3,17.5,6,44,18.5,18,orange)
  for x=5,42,3 do B(x,18.6,6.4,x+1.2,19.6,17.6,case)end
  front({2,6,44,12},2,0,45,3,20.02)
  B(2,19.5,5,44,21,19,case)
  top({2,5,44,14},2,4,45,20,21.02)
elseif id=='fr_rocket_hazard_cabinet' then
  -- Naval Rock's striped machinery: a chamfered steel cabinet with a
  -- hazard-striped mid band and a recessed control face. Closed solids with a
  -- real bevel, so it catches light on the edges instead of reading as a decal.
  local steel,shade,dark,stripe=T(6,9),T(6,15),T(3,13),T(10,4)
  B(2,0,3,30,3,17,dark)
  B(3,3,4,29,15,16,steel)
  B(3,15,4,29,15,16,shade)
  -- hazard band: alternating blocks, not a printed stripe
  for x=3,28,4 do
   B(x,11,3.4,x+1.8,15,16.4,stripe)
   B(x+2,11,3.4,x+3.6,15,16.4,shade)
  end
  B(3,10.6,3,29,11,16.6,dark)
  B(3,15,3,29,15,16.6,dark)
  -- recessed control face with three lamps
  B(8,15,3.2,24,15,4.2,shade)
  B(9,15,3,23,15,3.4,dark)
  for _,x in ipairs({11,16,21})do B(x,15,2.8,x+1.6,15,3.2,stripe)end
  front({3,10,13,5},3,17,29,21,16.02)
  B(2,0,3,3,15,17,shade);B(29,0,3,30,15,17,shade)
  top({3,4,13,11},2,3,30,17,23.02)
elseif id=='fr_rocket_console' then
  -- The blue-topped console beside it: angled desk, sloped screen bank and a
  -- keyboard shelf, so the row of them reads as workstations.
  local body,shade,screen,dark=T(6,12),T(6,15),T(4,7),T(3,13)
  B(2,0,3,30,2,17,dark)
  B(3,2,4,29,9,16,body)
  B(3,9,4,29,10,16,shade)
  B(4,10,5,28,15,15,body)
  for _,x in ipairs({7,14,21})do B(x,13,4.6,x+5,15,5.2,shade)end
  B(5,11,4.4,26,12.6,15.2,screen)
  B(3,15,4,29,15,16,shade)
  top({3,5,13,9},2,3,30,17,18.02)
elseif id=='fr_elite_horn' then
  local dy=A.recipe.faceY or 0
  local gold,pink,stone=T(7,dy+(A.recipe.single and 12 or 22)),T(7,dy+(A.recipe.single and 6 or 17)),T(8,dy+(A.recipe.single and 1 or 7))
  -- Gold socket and pink collar support a curved, tapered stone horn.
  -- The source's final foot/shadow row stays entirely walkable.
  B(3,0,3,13,2,29,T(5,dy+28));B(2,2,2,14,5,30,gold)
  B(4,5,4,12,9,28,pink)
  local sign=A.recipe.mirror and -1 or 1
  local rings={{8,9,5,11},{8,13,5,10},{8+sign,19,4,7},{8+sign*3,24,2,3},{8+sign*2,28,0,0}}
  local function point(r,k)local a=k*math.pi/4;return{r[1]+math.cos(a)*r[3],r[2],16+math.sin(a)*r[4]}end
  for j=1,#rings-1 do for k=0,7 do
   A.face({point(rings[j],k),point(rings[j],k+1),point(rings[j+1],k+1),point(rings[j+1],k)},stone,.72+.28*(k%4)/3)
  end end
  for k=0,7 do A.face({{8,9,16},point(rings[1],k+1),point(rings[1],k),{8,9,16}},pink,1)end
elseif id=='fr_elite_wall' then
  -- Closed wall and its original two-row panel, aligned with adjacent bays.
  B(0,0,28,16,32,32,T(4,5))
  front({0,0,16,32},0,0,16,32,32.01)
  local function move(p)return{p[1],p[2],32+p[3]*.5}end
  M.draw('fr_elite_'..A.recipe.fixture,{
   recipe={faceY=32,single=true,mirror=A.recipe.mirror},
   sample=T,
   box=function(l,b,n,r,h,f,uv)B(l,b,32+n*.5,r,h,32+f*.5,uv)end,
   source=function(x,y,w,h,a,b,c,d)S(x,y,w,h,move(a),move(b),move(c),move(d))end,
   face=function(vs,uv,shade)local out={};for i,p in ipairs(vs)do out[i]=move(p)end;A.face(out,uv,shade)end,
  })
elseif id=='fr_elite_ice' then
  local dy=(A.recipe or {}).faceY or 0
  local blue,edge=T(7,dy+10),T(6,dy+2)
  -- Two separate bevelled blocks retain the native blue/white ice faces.
  for i=0,((A.recipe or {}).single and 0 or 1) do
   local y=i*13;local sy=dy+((A.recipe or {}).single and 0 or (i==0 and 16 or 0))
   B(3,y,3,13,y+1,29,edge);B(2,y+1,2,14,y+11,30,blue)
   B(3,y+11,3,13,y+13,29,edge)
   front({1,sy+2,14,12},2,y+1,14,y+11,30.02)
   top({2,sy,12,3},3,3,13,29,y+13.02)
  end
elseif id=='fr_elite_stone' then
  -- Hand-shaped, closed faceted stones; no box of floor art underneath.
  local outline={{-4,-13},{4,-13},{7,-8},{6,9},{3,13},{-4,12},{-7,7},{-6,-8}}
  for i=0,((A.recipe or {}).single and 0 or 1) do
   local base=i*13;local sy=((A.recipe or {}).faceY or 0)+((A.recipe or {}).single and 0 or (i==0 and 16 or 0))
   local rings={{.68,0},{1,3},{.92,10},{.48,13}}
   for j=1,#rings-1 do
    local lo,hi=rings[j],rings[j+1]
    for k,p in ipairs(outline)do local q=outline[k%#outline+1]
     A.face({{8+p[1]*lo[1],base+lo[2],16+p[2]*lo[1]},
      {8+q[1]*lo[1],base+lo[2],16+q[2]*lo[1]},
      {8+q[1]*hi[1],base+hi[2],16+q[2]*hi[1]},
      {8+p[1]*hi[1],base+hi[2],16+p[2]*hi[1]}},T(6+(k%3),sy+4+j*2),1)
    end
   end
   for _,r in ipairs{rings[1],rings[#rings]}do
    for k,p in ipairs(outline)do local q=outline[k%#outline+1]
     A.face({{8,base+r[2],16},{8+p[1]*r[1],base+r[2],16+p[2]*r[1]},
      {8+q[1]*r[1],base+r[2],16+q[2]*r[1]},{8,base+r[2],16}},T(7,sy+3),1)
    end
   end
  end
elseif id=='fr_elite_column' then
  -- Purple shell, gold inset flutes and pale stepped foot from the native
  -- complete drawing. Both blocked rows carry the closed column footprint.
  local dy=A.recipe.faceY or 0
  local purple,gold,foot=T(2,dy+9),T(7,dy+9),T(5,dy+28)
  B(2,0,2,14,2,31,foot);B(3,2,3,13,4,30,foot)
  B(3,4,3,13,27,29,purple)
  B(4,27,4,12,30,28,purple);B(5,30,5,11,31,27,purple)
  B(2,4,4,4,26,28,purple);B(12,4,4,14,26,28,purple)
  B(4,4,29,12,26,30,gold)
  front({4,dy+3,8,20},4,4,12,26,30.02)
  for _,x in ipairs{5,8,11}do B(x,4,30,x+.5,26,30.5,T(6,dy+10))end
elseif id=='fr_room_bed' then
  -- A room bed seen end-on. First authored for the Celadon Condominiums and
  -- reused by the Celadon Hotel, which draws the same furniture. Base, mattress with a raised
  -- pillow end, a folded blanket band and side rails, so the silhouette has a
  -- head and a foot instead of one slab.
  local frame,mattress,blanket,pillow,dark=T(6,10),T(7,13),T(8,15),T(9,5),T(3,15)
  B(2,0,3,14,3,13,dark)
  B(2.6,3,3.6,13.4,4.2,12.4,frame)
  B(3,4.2,4,13,6.2,12,mattress)
  B(3,6.2,4,13,7.4,12,blanket)
  B(3.6,7.4,4.6,12.4,7.8,11.4,mattress)
  -- head end with a raised pillow
  B(3,4.2,4,13,6.6,5.4,pillow)
  B(2,4.2,4,3,6.6,12,frame)
  B(13,4.2,4,14,6.6,12,frame)
  top({3,4,10,8},3,4,13,12,7.82)
  front({3,8,10,4},3,4,13,7.6,12.01)
elseif id=='fr_condo_wardrobe' then
  -- A tall case with two doors, a moulded cornice and a plinth. Built as
  -- separate door leaves so the centre split survives an orbit.
  local wood,shade,panel,dark=T(6,8),T(6,15),T(8,12),T(3,14)
  B(2,0,3,14,1.4,13,dark)
  B(2.6,1.4,3.6,13.4,2.4,12.4,shade)
  B(3,2.4,4,13,12.6,12,wood)
  for _,x in ipairs({3.2,8.4})do
   B(x,3,4.2,x+4.4,11.4,11.6,panel)
   B(x+.2,3.4,4,x+4.2,11,11.4,wood)
  end
  B(2.6,12.6,3.6,13.4,13.6,12.4,shade)
  B(2,13.6,3,14,14.6,12,wood)
  for _,x in ipairs({6.6,7.2})do B(x,5,4,x+.4,5.6,4.4,dark)end
  top({3,4,10,8},2,3,14,12,14.62)
elseif id=='fr_condo_kitchen' then
  -- Counter run: worktop, plinth, a sink recess and an upper shelf. The
  -- yellow worktop edge is picked out so it reads as a counter, not a wall.
  local cab,work,sink,shade,dark=T(6,11),T(9,4),T(8,15),T(6,15),T(3,13)
  B(2,0,3,14,2.4,13,dark)
  B(2.6,2.4,3.6,13.4,4.2,12.4,cab)
  B(2,4.2,2.6,14,5,13.4,work)
  B(3.4,2.8,4.6,12.6,4.4,12.8,sink)
  B(3.8,4.4,5,12.2,4.6,12.6,work)
  for _,x in ipairs({4,9})do
   B(x,2.6,4.2,x+3,4,4.4,dark)
   B(x+.3,2.9,4.2,x+2.7,3.8,4.3,shade)
  end
  B(3,9.4,4.4,13,10,12,shade)
  B(3,10,4.2,13,13.4,11.8,cab)
  top({3,4,10,8},2,2.6,14,13.4,5.02)
  front({3,10,10,3},3,5,13,13.4,11.81)
elseif id=='fr_condo_plant' then
  -- A potted plant for the condo corners: tapered pot, soil, and three offset
  -- foliage tiers so the crown is a volume rather than a card.
  local pot,soil,leaf,leaf2=T(7,13),T(4,15),T(6,5),T(9,10)
  B(6,0,6,10,1.4,10,pot)
  B(5.4,1.4,5.6,10.6,3.6,10.4,pot)
  B(5.2,3.6,5.4,10.8,4.2,10.6,soil)
  B(6,4.2,6,10,6,10,leaf)
  B(4.6,6,4.8,11.4,8.4,10.2,leaf2)
  B(6.2,8.4,5,9.8,10.4,10,leaf)
  B(6.4,4.2,6.2,9.6,5,9.8,soil)
  top({5,6,6,5},5,5,11,11,10.42)
elseif id=='fr_slot_machine' then
  -- A slot machine: a plinth, a canted cabinet, a deep bezel around the reels
  -- and a lit crown marquee. The reels sit back inside the bezel so the screen
  -- reads as a recess rather than a decal on the front.
  local body,shade,reel,marquee,dark=T(6,10),T(6,15),T(9,4),T(9,7),T(3,12)
  B(2,0,4,14,1.6,12,dark)
  B(2.6,1.6,4.6,13.4,2.4,11.4,shade)
  B(3,2.4,4.6,13,10.6,11,body)
  -- bezel and the recessed screen
  B(3.6,4,5,12.4,4.6,10.4,shade)
  B(4.2,4.6,4.8,11.8,8.6,5.2,dark)
  -- three reels inside the recess
  for i=0,2 do
   local x=4.6+i*2.4
   B(x,5,4.6,x+1.8,8.2,5.4,reel)
   B(x+.2,6.2,4.4,x+1.6,7.6,4.9,shade)
  end
  -- crown marquee
  B(3,10.6,4.6,13,11.4,11,marquee)
  B(3.4,11.4,5,12.6,12,10.6,body)
  B(2.6,12,4.6,13.4,12.8,11.4,shade)
  -- lever on the right cheek
  B(13.4,5.4,6.6,14.2,8.6,7.4,dark)
  B(13.6,8.2,6.8,14.4,9,7.6,marquee)
elseif id=='fr_lab_machine' then
  -- A single-cell lab machine: plinth, canted body, a lit panel recessed into
  -- the face and a vent bank along the top. One 16px cell, so it can be placed
  -- anywhere -- unlike fr_lab_centrifuge, which samples its second row and
  -- therefore needs a two-row recipe.
  local body,shade,panel,vent,dark=T(7,9),T(7,15),T(9,4),T(6,12),T(3,13)
  B(2,0,3,14,1.6,13,dark)
  B(2.6,1.6,3.6,13.4,2.6,12.4,shade)
  B(3,2.6,4,13,11.6,12,body)
  B(4,3.6,3.8,12,8.6,4.2,shade)
  B(4.6,4.2,3.6,11.4,7.6,4,panel)
  for y=4.4,7,1.2 do B(5,y,3.4,11,y+.6,3.8,dark)end
  -- vent bank along the top
  for x=4,12,2 do B(x,8.8,4,x+1.2,10.2,11.4,vent)end
  B(3,10.4,4,13,11.6,12,shade)
  B(3,11.6,3.6,13,12.6,12.4,body)
  B(2,12.6,3.4,14,13.4,12.6,shade)
elseif id=='fr_gym_plant' then
  -- A gym's potted tree: a deep trough, a soil bed and three offset canopy
  -- tiers so the crown has volume and a silhouette.
  local trough,soil,leaf,leaf2,dark=T(7,12),T(4,15),T(6,5),T(9,10),T(3,14)
  B(2,0,5,14,1.6,11,dark)
  B(2.4,1.6,5.4,13.6,2.4,10.6,trough)
  B(3,2.4,5.8,13,3,10.2,soil)
  B(6,3,5.6,10,4.4,10.4,dark)
  B(5,4.4,4.8,11,7,11.2,leaf)
  B(3.6,7,4.4,12.4,9.4,11.6,leaf2)
  B(5.4,9.4,4.8,10.6,11.6,11.2,leaf)
  B(4.2,11.6,5,11.8,11.4,11,leaf2)
elseif id=='fr_gym_plant_rack' then
  -- A gym's plant rack: an open frame of two decks with planted trays, which
  -- is how the native art draws it -- plants on shelves, not a painted panel.
  local frame,tray,soil,leaf,dark=T(6,8),T(7,13),T(4,15),T(6,5),T(3,12)
  B(2,0,4,3,11,12,frame)
  B(13,0,4,14,11,12,frame)
  for _,y in ipairs({1.2,6.2})do
   B(2,y,4,14,y+1,12,tray)
   B(3,y+1,4.6,13,y+1.6,11.4,soil)
   for x=3.4,12.4,3 do
    B(x,y+1.6,5.2,x+2.2,y+3.4,10.8,leaf)
   end
  end
  B(2,11,4,14,12,12,frame)
elseif id=='fr_gym_switch_panel' then
  -- The gym switch panel: a canted console on a plinth, with a grid of
  -- individually raised buttons and a lamp strip above them. The native art is
  -- a flat panel of squares; the raised buttons and the raked face are what
  -- make it read as a console.
  local body,shade,button,dark,lamp=T(6,10),T(6,15),T(9,4),T(3,12),T(9,8)
  B(2,0,4,14,2,12,dark)
  B(2.6,2,4.6,13.4,3,11.4,shade)
  B(3,3,4.6,13,4.6,10.8,body)
  -- raked face carrying a 3x4 button grid
  B(3,4.6,4.4,13,8,10.6,shade)
  for row=0,2 do for col=0,3 do
   local x=3.8+col*2.3; local y=5+row*1.1
   B(x,y,4.2,x+1.7,y+.7,4.6,button)
  end end
  B(3,8,4.6,13,8.8,10.8,body)
  -- lamp strip along the top edge
  B(3.2,8.8,4.8,12.8,9.4,10.6,lamp)
  B(2,9.4,4.4,14,10.4,11.4,shade)
  B(3,10.4,4.8,13,11.2,11,body)
elseif id=='fr_gym_disc' then
  -- A low round plinth: stepped drum base, a capped shaft and a dark top
  -- face, built as concentric closed steps rather than a stretched circle.
  local stone,shade,dark,cap=T(8,10),T(8,15),T(3,11),T(6,6)
  B(4,0,4,12,1.4,12,dark)
  B(4.6,1.4,4.6,11.4,2.2,11.4,stone)
  B(5,2.2,5,11,2.8,11,shade)
  B(5.2,2.8,5.2,10.8,6.4,10.8,stone)
  B(5,6.4,5,11,7,11,shade)
  B(4.6,7,4.6,11.4,7.8,11.4,stone)
  B(4,7.8,4,12,8.6,12,dark)
  B(5,8.6,5,11,9,11,cap)
elseif id=='fr_roof_ac_unit' then
  -- Rooftop plant: a housing on a curb, a louvred grille and a recessed fan
  -- behind it, with a conduit running down the back. The native drawing is a
  -- frontal box, so the grille blades and fan hub are what make it read.
  local shell,shade,grille,dark,hub=T(7,9),T(7,15),T(5,12),T(3,11),T(9,6)
  B(1,0,3,15,1.6,13,dark)
  B(1.8,1.6,3.6,14.2,2.6,12.4,shade)
  B(2.6,2.6,4,13.4,10.6,12,shell)
  -- recessed grille bay
  B(3.4,3.6,3.6,12.6,9.4,4.2,shade)
  -- louvre blades, spaced so air reads between them
  for y=4,9,1.6 do B(3.6,y,3.4,12.4,y+.8,4.4,grille)end
  -- fan hub behind the grille
  B(6,5,3.6,10,8,4.0,hub)
  B(7,6,3.5,9,7,3.9,dark)
  B(2,10.6,3.6,14,11.4,12.4,shade)
  B(2.6,11.4,4,13.4,12,12,shell)
  -- conduit down the back
  B(12.6,0,4.4,14,10.6,5.6,dark)
  B(12.8,1,4.6,13.8,2,5.4,shell)
  B(12.8,3,4.6,13.8,4,5.4,shell)
elseif id=='fr_store_shelf' then
  -- Store racking: an upright frame carrying four decks, each stocked with
  -- offset blocks so the front reads as goods on shelves rather than one
  -- printed plane. A price rail runs along the front edge of every deck.
  local frame,deck,goods1,goods2,dark=T(6,8),T(8,14),T(9,4),T(7,6),T(3,12)
  for _,x in ipairs({2,12.6})do B(x,0,4,x+1.4,14,5,dark)end
  for _,y in ipairs({0,3.4,6.8,10.2,13.4})do
   B(2,y,4,14,y+1,12.4,deck)
   B(2,y,11.9,14,y+.5,12.4,dark)
  end
  for _,y in ipairs({1,4.4,7.8,11.2})do
   for x=2.6,12,2 do
    local h=1.6+((x*5+y*3)%3)*.4
    B(x,y,4.6,x+1.7,y+h,11.6,(x%4<2) and goods1 or goods2)
   end
  end
  B(1.6,0,3.6,14.4,14.4,5.4,frame)
elseif id=='fr_store_goods_rack' then
  -- The orange display unit: a low plinth with tiered racks of colour, which
  -- is how the native art presents it -- a front of merchandise, not a box.
  local plinth,rack,goods1,goods2,dark=T(8,15),T(6,9),T(9,5),T(7,3),T(3,11)
  B(2,0,4,14,2,12,plinth)
  B(2.4,2,4.4,13.6,2.6,11.6,dark)
  for _,y in ipairs({2.6,5.2,7.8})do B(3,y,4.8,13,y+.7,11.2,rack)end
  for i,yy in ipairs({2.6,5.2,7.8})do
   for x=3.4,11.4,2 do
    local h=1.4+((x*7+yy*3)%3)*.5
    B(x,yy+.7,5.2,x+1.6,yy+.7+h,10.8,((i+x)%2==0) and goods1 or goods2)
   end
  end
  B(3,10.4,5,13,11.2,10.8,rack)
  B(2,11.2,4.4,14,12.4,11.6,plinth)
elseif id=='fr_house_table' then
  -- A wooden table seen at a shallow angle: splayed legs, an apron and a
  -- thick top, so the underside reads from a low camera instead of being a
  -- floating slab.
  local top,apron,leg,dark=T(8,6),T(7,11),T(6,15),T(3,12)
  for _,x in ipairs({2.5,10.5})do for _,z in ipairs({3,9})do
   B(x,0,z,x+3,6,z+3,leg)
  end end
  B(2,5,3,14,6.4,12.4,apron)
  B(1.6,6.4,2.6,14.4,7.8,12.8,top)
  B(2.2,7.8,3.2,13.8,8,12.2,dark)
elseif id=='fr_ruins_shelf' then
  -- Tanoby Ruins shelving: a tall case with three decks of individually offset
  -- spines and an open band, so the front never reads as one printed plane.
  local wood,spine,spine2,dark=T(6,9),T(7,13),T(9,15),T(3,14)
  B(2,0,4,14,1.5,12,dark)
  B(2.5,1.5,4.5,13.5,2.4,11.5,wood)
  B(2,12,4,14,13.4,12,wood)
  B(2,13.4,4,14,15,12,wood)
  for _,y in ipairs({2.4,6.2,10})do
   B(3,y,5,13,y+1,11,wood)
   for x=3.5,12,1.8 do
    local h=2.2+((x*7+y*3)%4)*.5
    B(x,y+1,5.4,x+1.4,y+1+h,10.6,(x%3.6<1.8) and spine2 or spine)
   end
  end
  top({3,5,10,6},2,4,14,12,15.02)
  front({3,3,10,10},2,2.4,14,13.4,12.01)
 elseif id=='fr_gym_pillar' then
  -- A gym column: stepped plinth, fluted shaft, banded capital. Closed solids
  -- with real steps rather than one stretched texture, so the silhouette reads
  -- from any orbit the way the native drawing's does head-on.
  local stone,shade,dark=T(9,12),T(9,20),T(4,26)
  B(6,0,6,26,4,26,dark);B(7,4,7,25,6,25,stone);B(8,6,8,24,7,24,dark)
  for x=9,23,3 do B(x,7,8.2,x+1,28,8.6,shade)end
  for x=9,22,3 do B(x,28,7.4,x+1.6,29.4,8.6,shade)end
  B(9,29,7,23,30,9,stone)
  B(7,30,6,25,32,10,shade);B(8,32,7,24,33,9,dark)
  B(8,0,6,24,33,7,shade);B(8,0,6,7,33,26,dark);B(25,0,6,26,33,26,dark)
  top({8,8,16,16},8,6,24,26,33.02)
 elseif id=='fr_gym_platform' then
  -- The raised battle floor: two treads and a matted top, with the nosing
  -- picked out so the step edge survives a flat-lit scene.
  local deck,lip,dark=T(12,10),T(12,22),T(6,26)
  B(1,0,1,30,3,22,dark);B(1,3,1,30,5,20,lip)
  B(2,5,2,29,7,19,deck)
  top({2,8,27,17},2,2,29,19,7.02)
  B(1,7,1,2,7.4,20,lip);B(29,7,1,30,7.4,20,lip)
 elseif id=='fr_vending_machine' then
  -- Cabinet, recessed glass with three product shelves, a lit header band and
  -- the dispenser tray at the foot. The glass is a single dark inset so the
  -- products inside read as depth rather than a printed panel.
  local case,dark,glass=T(5,8),T(3,14),T(2,20)
  local hdr=T(6,3)
  B(3,0,5,29,3,19,dark);B(4,3,6,28,5,18,case)
  B(5,5,7,27,22,8,glass)
  for _,y in ipairs({8,13,18})do B(5,y,6.4,27,y+.8,7.6,case)end
  -- products: staggered blocks on each shelf, not a printed row
  for _,y in ipairs({8,13,18})do for x=6,25,3 do
   local h=(x%2==0) and 2.4 or 1.6
   B(x,y,6.6,x+2,y+h,7.4,hdr)
  end end
  front({5,10,22,12},5,5,27,22,8.02)
  B(4,25,6,28,28,18,hdr)
  front({4,28,24,4},4,25,28,28,18.02)
  B(8,3,19,24,5,19.4,dark);front({8,24,16,3},8,3,24,5,19.42)
 elseif id=='fr_mart_shelf_rack' then
  -- Goods racking. Uprights, three decks and individually offset stock, so the
  -- shelf front never reads as one repeated wallpaper plane.
  local frame,deck,goods=T(7,9),T(7,20),T(9,3)
  for _,x in ipairs({2,30})do B(x,0,4,x+2,26,18,frame)end
  B(2,0,4,32,1.2,5,deck);B(2,0,17,32,18.2,18,deck)
  for _,y in ipairs({1.2,9.4,17})do
   B(3,y,5,31,y+1,17,deck)
   for x=4,29,3 do
    local h=((x+y)%3==0) and 3.2 or 2.2
    B(x,y+1,6,x+2,y+h,16,goods)
   end
  end
  top({2,5,30,12},2,4,32,18,26.02)
 elseif id=='fr_cafe_table' then
  -- Round cafe table: pedestal column, splayed foot, rimmed top.
  local top_m,stem,dark=T(11,9),T(9,16),T(5,20)
  B(7,0,7,25,2,25,dark)
  for _,d in ipairs({0,1})do B(10+d*3,2,10+d*3,22-d*3,3,22-d*3,dark)end
  B(14,2,14,18,9,18,stem)
  B(11,9,11,21,11,21,top_m)
  top({10,10,12,12},11,11,21,21,11.02)
  B(10,10.4,13,22,11,17,stem)
 elseif id=='fr_office_chair' then
  -- Swivel chair: five-star base, gas column, contoured seat and a padded back
  -- that leans away from the seat rather than standing vertical behind it.
  local frame,seat,dark=T(6,8),T(9,11),T(4,19)
  for i=0,4 do
   local a=i*(math.pi*2/5)
   local cx,cz=16+math.cos(a)*7,16+math.sin(a)*7
   B(cx-1.6,.6,cz-1.6,cx+1.6,2.4,cz+1.6,frame)
  end
  B(14.5,2,14.5,17.5,8,17.5,dark)
  B(9,8,9,23,10.6,23,seat)
  B(10,10.6,12,22,12,21,seat)
  top({10,13,12,8},10,9,22,23,12.02)
  B(10,12,22,25,23,seat)
  B(9.4,14,22.2,25,23,frame)
 elseif id=='fr_potted_plant' then
  -- Tapering pot, a soil lip, and three offset foliage tiers so the crown is a
  -- volume with a silhouette instead of a card.
  local pot,soil,leaf,leaf2=T(8,14),T(4,20),T(6,4),T(9,9)
  B(9,0,9,23,2,23,pot)
  B(8,2,8,24,7,24,pot)
  B(7.6,7,7.6,24.4,8,24.4,soil)
  B(8,6.6,8,24,7.6,24,soil)
  B(10,8,10,22,12,22,leaf)
  B(7,11,7,25,15,25,leaf2)
  B(9,14,9,23,17,23,leaf)
  B(11,8.6,11,21,9.4,21,soil)
  top({8,9,16,13},8,8,24,24,17.02)
 elseif id=='fr_bookshelf_tall' then
  -- Full-height case with four decks and individually offset spines, and an
  -- open shelf band so it does not read as one solid slab.
  local wood,spine,dark=T(5,7),T(8,12),T(3,18)
  B(2,0,4,32,1.6,18,dark);B(2,0,4,3.4,32,18,wood);B(30.6,0,4,32,32,18,wood)
  B(2,32,4,32,33.6,18,wood);B(2,0,4,32,33.6,5.6,wood)
  for _,y in ipairs({1.6,10,18.4,26.8})do
   B(3.4,y,5,30.6,y+1,17,wood)
   for x=4,29,2 do
    local h=2+((x*7+y*3)%5)
    B(x,y+1,5.4,x+1.6,y+1+h,16.6,spine)
   end
  end
  B(2,0,4,32,33.6,18,wood)
  top({3,5,29,12},2,4,32,18,33.62)
 else return false end
 return true
end
return M
