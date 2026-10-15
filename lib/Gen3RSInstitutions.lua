-- Independently reviewed Ruby/Sapphire institutional drawings. Native IDs and
-- permissions are source context; all artwork comes from the active atlas.
local M={recipes={}}
local function add(name,pair,rows,permissions,design,floor,extra)
 local r={name="rs_institution_"..name,family="rse",edition="rs",primary=pair:match("^(.-)__"),pair=pair,rows=rows,collisionRows=permissions,kind="rsInstitution",institutionDesign=design,ground=floor}
 for k,v in pairs(extra or{})do r[k]=v end
 M.recipes[#M.recipes+1]=r
end
add('gallery_picture_0','building__lilycove_museum',{{0x20b},{0x213}},{{0x7},{0x7}},'em_lilycove_picture_wall',0x203,{wallSample={0,2}})
add('gallery_picture_1','building__lilycove_museum',{{0x218,0x219},{0x220,0x221}},{{0x7,0x7},{0x7,0x7}},'em_lilycove_picture_wall',0x203,{wallSample={0,2}})
add('gallery_picture_2','building__lilycove_museum',{{0x21a,0x21b},{0x222,0x223}},{{0x7,0x7},{0x7,0x7}},'em_lilycove_picture_wall',0x203,{wallSample={0,2}})
add('gallery_picture_3','building__lilycove_museum',{{0x21c},{0x224}},{{0x7},{0x7}},'em_lilycove_picture_wall',0x203,{wallSample={0,2}})
add('gallery_picture_4','building__lilycove_museum',{{0x21d},{0x225}},{{0x7},{0x7}},'em_lilycove_picture_wall',0x203,{wallSample={0,2}})
add('gallery_picture_5','building__lilycove_museum',{{0x21e,0x21f},{0x226,0x227}},{{0x7,0x7},{0x7,0x7}},'em_lilycove_picture_wall',0x203,{wallSample={0,2}})
add('gallery_picture_6','building__lilycove_museum',{{0x22d,0x22e},{0x235,0x236}},{{0x7,0x7},{0x7,0x7}},'em_lilycove_picture_wall',0x203,{wallSample={0,2}})
add('gallery_picture_7','building__lilycove_museum',{{0x22f},{0x237}},{{0x7},{0x7}},'em_lilycove_picture_wall',0x203,{wallSample={0,2}})
add('gallery_return_north','building__lilycove_museum',{{0x211},{0x211},{0x204},{0x20c},{0x214}},{{0x7},{0x7},{0x90},{0x7},{0x7}},'em_lilycove_wall_return',0x203,{foot=0})
add('gallery_return_partition','building__lilycove_museum',{{0x212},{0x28b},{0x204},{0x20c},{0x214}},{{0x0},{0x7},{0x90},{0x7},{0x7}},'em_lilycove_wall_return',0x203,{foot=16})
add('gallery_stone','building__lilycove_museum',{{0x23a,0x23b,0x23b,0x23b,0x23c},{0x242,0x228,0x229,0x22a,0x244},{0x24a,0x230,0x231,0x232,0x24c},{0x252,0x253,0x253,0x253,0x254}},{{0x0,0x0,0x0,0x0,0x0},{0x7,0x7,0x7,0x7,0x7},{0x7,0x7,0x7,0x7,0x7},{0x7,0x90,0x90,0x90,0x7}},'em_lilycove_stone_display',0x202,nil)
add('gallery_counter','building__lilycove_museum',{{0x23a,0x23b,0x23b,0x23b,0x23b,0x23c},{0x248,0x253,0x241,0x253,0x240,0x249},{0x210,0x24d,0x23f,0x23f,0x23f,0x210},{0x238,0x234,0x23b,0x23b,0x23b,0x239},{0x252,0x253,0x253,0x253,0x253,0x254}},{{0x0,0x0,0x0,0x0,0x0,0x0},{0x7,0x90,0x90,0x90,0x90,0x7},{0x90,0x0,0x0,0x0,0x0,0x90},{0x90,0x0,0x0,0x0,0x0,0x90},{0x7,0x90,0x90,0x90,0x90,0x7}},'em_lilycove_counter',0x202,nil)
add('gallery_ball','building__lilycove_museum',{{0x22c}},{{0x7}},'em_lilycove_ball_sculpture',0x202,nil)
add('gallery_figure','building__lilycove_museum',{{0x22b},{0x233}},{{0x0},{0x7}},'figure_card',0x202,nil)
add('gallery_partition','building__lilycove_museum',{{0x264,0x265,0x266,0x267},{0x286,0x26e,0x26e,0x26f},{0x28e,0x258,0x259,0x277},{0x27c,0x27d,0x27e,0x27f}},{{0x0,0x0,0x0,0x0},{0x90,0x7,0x7,0x7},{0x7,0x7,0x7,0x7},{0x0,0x0,0x0,0x0}},'em_lilycove_gallery',0x268,{groundRows={{0x268,0x269,0x268,0x269},{0x269,0x268,0x269,0x268},{0x268,0x269,0x268,0x269},{0x269,0x268,0x269,0x268}}})
add('gallery_upper_rear','building__lilycove_museum',{{0x281},{0x289}},{{0x7},{0x7}},'em_lilycove_upper_wall',0x270,{corner=false})
add('gallery_upper_wing','building__lilycove_museum',{{0x279},{0x281},{0x289}},{{0x7},{0x7},{0x7}},'em_lilycove_upper_wall',0x270,{corner=false})
add('gallery_upper_left_corner','building__lilycove_museum',{{0x27a},{0x282},{0x28a}},{{0x7},{0x7},{0x7}},'em_lilycove_upper_wall',0x270,{corner=true})
add('gallery_upper_right_corner','building__lilycove_museum',{{0x278},{0x280},{0x288}},{{0x7},{0x7},{0x7}},'em_lilycove_upper_wall',0x270,{corner=true})
add('gallery_upper_figure_0','building__lilycove_museum',{{0x284},{0x28c}},{{0x7},{0x7}},'figure_card',0x270,nil)
add('gallery_upper_figure_1','building__lilycove_museum',{{0x285},{0x28d}},{{0x7},{0x7}},'figure_card',0x270,nil)
add('tall_case','building__oceanic_museum',{{0x226,0x227},{0x22e,0x22f},{0x236,0x237}},{{0x7,0x7},{0x7,0x7},{0x0,0x0}},'em_museum_wall_case',0x201,nil)
add('cylinder','building__oceanic_museum',{{0x220},{0x228}},{{0x0},{0x7}},'em_museum_cylinder',0x201,nil)
add('glass','building__oceanic_museum',{{0x221},{0x229}},{{0x0},{0x7}},'em_museum_glass',0x201,nil)
add('reception_left','building__oceanic_museum',{{0x222,0x223,0x223,0x224},{0x255,0x248,0x249,0x256},{0x23e,0x244,0x203,0x23e},{0x260,0x243,0x201,0x260}},{{0x0,0x0,0x0,0x0},{0x7,0x90,0x90,0x7},{0x90,0x0,0x0,0x90},{0x7,0x0,0x0,0x7}},'ocean_reception',0x201,nil)
add('reception_right','building__oceanic_museum',{{0x222,0x223,0x223,0x224},{0x255,0x249,0x233,0x256},{0x23e,0x244,0x203,0x23e},{0x260,0x243,0x201,0x260}},{{0x0,0x0,0x0,0x0},{0x7,0x90,0x90,0x7},{0x90,0x0,0x0,0x90},{0x7,0x0,0x0,0x7}},'ocean_reception',0x201,nil)
add('ocean_wall_diagram_0','building__oceanic_museum',{{0x212,0x213},{0x21a,0x21b}},{{0x7,0x7},{0x7,0x7}},'wall_diagram',0x201,nil)
add('ocean_wall_diagram_1','building__oceanic_museum',{{0x214,0x215},{0x21c,0x21d}},{{0x7,0x7},{0x7,0x7}},'wall_diagram',0x201,nil)
add('wall_case','building__oceanic_museum',{{0x208,0x209},{0x210,0x211},{0x218,0x219}},{{0x7,0x7},{0x7,0x7},{0x0,0x0}},'em_museum_wall_case',0x201,nil)
add('divider','building__oceanic_museum',{{0x225},{0x225},{0x22d},{0x235}},{{0x7},{0x7},{0x7},{0x7}},'em_museum_divider',0x201,nil)
add('terminal','building__oceanic_museum',{{0x253,0x254},{0x25b,0x25c}},{{0x0,0x0},{0x7,0x7}},'em_museum_terminal',0x201,nil)
add('terminal_wide','building__oceanic_museum',{{0x251,0x252},{0x259,0x25a}},{{0x0,0x0},{0x7,0x7}},'em_museum_terminal',0x201,nil)
add('ship','building__oceanic_museum',{{0x22a,0x230,0x231,0x22c},{0x232,0x233,0x233,0x234}},{{0x7,0x7,0x7,0x7},{0x7,0x90,0x90,0x7}},'em_museum_ship',0x201,nil)
add('parts','building__oceanic_museum',{{0x238,0x239,0x240,0x22c},{0x232,0x233,0x233,0x234}},{{0x7,0x7,0x7,0x7},{0x7,0x90,0x90,0x7}},'em_museum_parts',0x201,nil)
add('ocean_wall_diagram_2','building__oceanic_museum',{{0x216,0x217},{0x21e,0x21f}},{{0x7,0x7},{0x7,0x7}},'wall_diagram',0x201,nil)
add('space_controls','general__facility',{{0x2ba,0x2b8,0x2b9},{0x377,0x375,0x376}},{{0x7,0x7,0x7},{0x0,0x0,0x0}},'em_space_controls',0x2f0,nil)
add('space_controls_end','general__facility',{{0x2b9},{0x376}},{{0x7},{0x0}},'em_space_controls',0x2f0,nil)
add('space_computer','general__facility',{{0x363,0x364},{0x36b,0x36c}},{{0x0,0x0},{0x7,0x7}},'em_office_computer',0x2f0,nil)
add('space_plans','general__facility',{{0x368,0x369},{0x370,0x371}},{{0x7,0x7},{0x7,0x7}},'em_office_plans',0x2f0,nil)
add('space_stool','general__facility',{{0x361}},{{0x0}},'em_office_stool',0x2f0,{seat={height=5,hips=4,z=8}})
add('space_controls_pair','general__facility',{{0x2b8,0x2b9},{0x376,0x376}},{{0x7,0x7},{0x0,0x0}},'em_space_controls',0x2f0,nil)
add('space_desk','general__facility',{{0x362,0x364},{0x36a,0x36c}},{{0x0,0x0},{0x7,0x7}},'em_office_desk',0x2f0,nil)
add('devon_reception','general__facility',{{0x386,0x38d,0x38d,0x38d,0x387},{0x38e,0x39c,0x39c,0x39c,0x38f}},{{0x0,0x0,0x0,0x0,0x0},{0x90,0x90,0x90,0x90,0x90}},'devon_reception',0x380,nil)
add('devon_computer','general__facility',{{0x3a3,0x3a4},{0x3ab,0x3ac}},{{0x0,0x0},{0x7,0x7}},'em_office_computer',0x380,nil)
add('devon_plans','general__facility',{{0x3a5,0x3a6},{0x3ad,0x3ae}},{{0x7,0x7},{0x7,0x7}},'em_office_plans',0x380,nil)
add('devon_stool','general__facility',{{0x3a7}},{{0x0}},'em_office_stool',0x380,{seat={height=5,hips=4,z=8}})
add('devon_instrument','general__facility',{{0x39d}},{{0x7}},'devon_instrument',0x380,nil)
add('devon_meeting_island','general__facility',{{0x3b8,0x3b9,0x3b9,0x3b9,0x3ba},{0x3c0,0x3c1,0x3c1,0x3c1,0x3c2},{0x3bb,0x3bc,0x3bc,0x3bc,0x3bd},{0x3c3,0x3c4,0x3c4,0x3c4,0x3c5},{0x3be,0x3c6,0x3c6,0x3c6,0x3bf}},{{0x0,0x0,0x0,0x0,0x0},{0x7,0x7,0x7,0x7,0x7},{0x7,0x7,0x7,0x7,0x7},{0x7,0x7,0x7,0x7,0x7},{0x0,0x0,0x0,0x0,0x0}},'devon_meeting_island',0x380,nil)
add('devon_president_desk','general__facility',{{0x3b8,0x3ba},{0x3c0,0x3c2},{0x3bb,0x3bd},{0x3c3,0x3c5},{0x3be,0x3bf}},{{0x0,0x0},{0x7,0x7},{0x7,0x7},{0x7,0x7},{0x0,0x0}},'devon_meeting_island',0x380,nil)
add('devon_rear_bench','general__facility',{{0x349,0x34a,0x34b},{0x351,0x352,0x353}},{{0x7,0x7,0x7},{0x0,0x0,0x0}},'devon_rear_bench',0x380,nil)
add('devon_display_case','general__facility',{{0x2dd},{0x2e5}},{{0x0},{0x7}},'devon_display_case',0x380,nil)
add('devon_west_seat','general__facility',{{0x348},{0x350},{0x3a8}},{{0x0},{0x0},{0x0}},'devon_side_seat',0x380,{seat={height=5,hips=4,z=24}})
add('devon_east_seat','general__facility',{{0x2ff},{0x307},{0x3a9}},{{0x0},{0x0},{0x0}},'devon_side_seat',0x380,{seat={height=5,hips=4,z=24}})
add('devon_west_return','general__facility',{{0x39a},{0x398},{0x398},{0x3a0},{0x390}},{{7},{7},{7},{7},{7}},'devon_wall_return',0x380)
add('devon_east_return','general__facility',{{0x39b},{0x399},{0x399},{0x3a1},{0x390}},{{7},{7},{7},{7},{7}},'devon_wall_return',0x380)
for _,r in ipairs(M.recipes)do
 if r.name=='rs_institution_gallery_picture_3' or r.name=='rs_institution_gallery_picture_4'then r.wallSample={0,16}end
 if r.name=='rs_institution_gallery_picture_7'then r.wallSample={0,24}end
end
local V=...
function M.flatWalls(pair,mapId,optIn)
 local ed=V.require('Generation').version()
 local named=not mapId or mapId:find('DEVON_CORP',1,true)or mapId:find('SPACE_CENTER',1,true)or mapId:find('LILYCOVE_MUSEUM',1,true)or mapId:find('OCEANIC_MUSEUM',1,true)
 local known=pair=='general__facility' or pair=='building__facility' or pair=='building__lilycove_museum' or pair=='building__oceanic_museum'
 local custom=optIn==true and type(pair)=='string'and(pair:match('^building__')~=nil or pair:match('^general__')~=nil)
 return ((ed=='ruby' or ed=='sapphire')and named and known)or custom or false
end
function M.append(p,source,openBox,sample,emit)
 local r,x,z=p.recipe,p.cx*16,p.cy*16
 local function point(a)return{x+a[1],a[2],z+a[3]}end
 local function B(l,b,n,rr,h,f,mat)
  openBox(x+l,b,z+n,x+rr,h,z+f,mat)
  emit({{x+l,b,z+f},{x+rr,b,z+f},{x+rr,b,z+n},{x+l,b,z+n}},mat,.65)
 end
 local function S(sx,sy,w,h,a,b,c,d)source(sx,sy,w,h,point(a),point(b),point(c),point(d))end
 local function front(sx,sy,w,h,l,b,rr,t,f)
  -- The existing facade tag hides a front-only veneer from its reverse.
  -- Closed structural backs remain visible; paint cannot bleed through them.
  source(sx,sy,w,h,point{l,t,f},point{rr,t,f},point{rr,b,f},point{l,b,f},-1)
 end
 local function top(sx,sy,w,h,l,n,rr,f,y)S(sx,sy,w,h,{l,y,n},{rr,y,n},{rr,y,f},{l,y,f})end
 local id=r.institutionDesign
 if id=='em_lilycove_picture_wall'then
  local f=p.cy==0 and 4 or 31.8
  local mat=sample(unpack(r.wallSample or{0,2}))
  B(0,0,p.cy==0 and 3.9 or f-3.8,p.w,32,f,mat)
  front(0,0,p.w,32,0,0,p.w,32,f+.02)
 elseif id=='em_lilycove_upper_wall'then
  -- A single north plane crosses the whole room. Extra projected rows
  -- never push a wing or a corner into a separate wall face.
  local sy=(#r.rows-2)*16;local mat=sample(8,sy+8)
  B(0,0,3.9,p.w,32,4,mat)
  front(0,sy,16,32,0,0,16,32,4.02)
 elseif id=='em_lilycove_gallery'then
  -- Free-standing partitions occupy the native blocked base row only.
  local paint=sample(5,22)
  B(.2,0,44,63.8,32,47.8,paint)
  front(1,16,62,31,1,0,63,32,47.82)
 elseif id=='em_lilycove_wall_return'then
  local n=r.foot==0 and 4 or 16;local paint=sample(8,56)
  B(6,0,n,10,32,79.8,paint)
  B(6,0,n,10,2,79.8,sample(8,77))
  if r.foot~=0 then
   -- The gallery's horizontal wall terminates at this native column.
   -- Carry its flat face all the way across the T-junction; a centered
   -- return alone leaves six pixels of daylight at either side.
   B(0,0,44,16,32,47.8,paint)
   front(0,48,16,32,0,0,16,32,47.82)
  end
  front(6,48,4,32,6,0,10,32,79.82)
 elseif id=='em_museum_terminal'then
  local case,dark=sample(13,18),sample(3,24)
  B(2,0,17,30,8,31,case);B(1,8,16.5,31,9,31.5,dark)
  -- All of the monitor, stand and keys are over the blocked base row.
  B(5,9,18,12,10,23,case);B(4,10,17,14,21,23,case)
  B(5,11,22.5,13,20,23.2,dark)
  front(5,10,8,5,5,11,13,20,23.22)
  B(4,9,25,22,9.6,30,case);top(4,17,17,5,4,25,22,30,9.62)
 elseif id=='em_space_controls'then
  local case,dark=sample(math.min(20,p.w-2),17),sample(1,21)
  for panel=0,p.w/16-1 do local l=panel*16
   B(l+1,0,5,l+15,1.5,15.2,dark)
   B(l+.5,1.5,4.1,l+15.5,10,14.8,case)
   B(l+.5,10,4.1,l+15.5,17,6.1,case)
   B(l+.5,10,6.1,l+1.5,16,14.8,case)
   B(l+14.5,10,6.1,l+15.5,16,14.8,case)
   S(l+1,1,14,14,{l+1,17,6.2},{l+15,17,6.2},{l+15,10,14.8},{l+1,10,14.8})
   front(l+1,17,14,13,l+1,1.5,l+15,10,14.82)
  end
 elseif id:match('^em_')then
  return V.require('InteriorFurniture').draw(id,{box=B,source=S,sample=sample,width=p.w,height=p.d,recipe=r})
 elseif id=='wall_diagram'then
  local wall,trim=sample(1,28),sample(1,1)
  B(0,0,3.9,p.w,32,4,wall)
  front(0,0,p.w,32,0,0,p.w,32,4.02)
 elseif id=='ocean_reception'then
  local cream,trim=sample(3,20),sample(3,29)
  -- Three-sided desk, with an open staff lane. The projected cap is floor.
  for _,q in ipairs{{0,16,64,32},{0,32,16,64},{48,32,64,64}}do
   B(q[1]+.2,0,q[2]+.2,q[3]-.2,8,q[4]-.2,trim)
   B(q[1]+.1,8,q[2]+.1,q[3]-.1,9,q[4]-.1,cream)
  end
  top(1,15,62,10,1,17,63,31,9.02)
  -- Original little ledger remains on its original end of the counter.
  local ledger=r.name:find('left')and 16 or 32
  B(ledger,9,20,ledger+12,9.5,28,sample(ledger+4,22))
  top(ledger,16,12,10,ledger,20,ledger+12,28,9.52)
 elseif id=='devon_wall_return'then
  local paint,wood=sample(8,60),sample(8,73)
  B(6,0,4,10,32,79.8,paint)
  B(6,0,4,10,3,79.8,wood)
  B(6,30,4,10,32,79.8,sample(8,48))
  -- Native wallpaper and wainscot repeat along each flat side. The source
  -- wall cap is not wrapped around a corner or sampled as green plaster.
  for n=4,68,16 do local f=math.min(n+16,79.8)
   S(0,48,16,32,{5.98,32,f},{5.98,32,n},{5.98,0,n},{5.98,0,f})
   S(0,48,16,32,{10.02,32,n},{10.02,32,f},{10.02,0,f},{10.02,0,n})
  end
  -- Close the T-junction against the straight horizontal corridor wall.
  B(0,0,76,16,32,79.8,paint)
  front(0,48,16,32,0,0,16,32,79.82)
 elseif id=='devon_reception'then
  local wood,edge=sample(6,19),sample(6,28)
  B(.5,0,16.5,79.5,8,31.5,wood);B(.2,8,16.2,79.8,9,31.8,edge)
  top(1,2,78,12,1,17,79,31,9.02)
  front(1,20,78,10,1,0,79,8,31.82)
 elseif id=='devon_meeting_island'then
  local w=p.w;local leg,edge,wood=sample(5,30),sample(2,23),sample(7,21)
  -- Only the middle three native rows are blocked. Inset legs, chamfered
  -- corners and an actual apron retain the clear north/south approach rows.
  for _,xx in ipairs{4,w-8}do for _,zz in ipairs{20,58}do B(xx,0,zz,xx+4,8,zz+4,leg)end end
  B(2,7,18,w-2,9,62,wood)
  B(2,9,16.3,w-2,10,63.7,edge);B(.3,9,18,w-.3,10,62,edge)
  top(2,17,w-4,45,2,17,w-2,63,10.02)
  front(2,58,w-4,5,2,7,w-2,9,62.02)
 elseif id=='devon_rear_bench'then
  local dark,seat=sample(6,12),sample(6,4)
  B(2,0,3,p.w-2,4,14,dark);B(1,4,2,p.w-1,6,15,seat)
  B(1,6,1,p.w-1,13,3,dark)
  front(2,0,p.w-4,12,2,6,p.w-2,13,3.02)
 elseif id=='devon_display_case'then
  local foot,glass,edge=sample(2,24),sample(7,8),sample(4,14)
  B(1,0,17,15,4,31,foot)
  B(2,4,18,14,17,30,glass)
  B(1,17,17,15,18,31,edge)
  for _,xx in ipairs{1,14}do B(xx,4,17,xx+1,17,31,edge)end
  front(2,1,12,24,2,4,14,17,30.02)
 elseif id=='devon_side_seat'then
  -- Native side-facing seats are walkable. The public seat anchor keeps
  -- the actor above the low cushion while preserving the original lane.
  local dark,seat=sample(6,21),sample(7,26)
  B(3,0,18,13,1,30,dark);B(2,1,17,14,5,31,seat)
  top(2,14,12,18,2,17,14,31,5.02)
 elseif id=='devon_instrument'then
  local light,dark=sample(8,4),sample(3,12)
  B(2,0,2,14,2,14,dark);B(3,2,3,13,11,13,light)
  B(2,11,2,14,12,14,dark)
  top(2,1,12,12,2,2,14,14,12.02)
 elseif id=='figure_card'then
  -- Pokémon sculptures are still HD-2D artwork, with a separate 3D plinth.
  -- Remove only border-connected background; never turn the figure into a hull.
  B(.5,0,17,15.5,4,31,sample(3,28));B(.5,4,17,15.5,5,31,sample(3,25))
  if not p.ts.imageData then return end
  local pixels,edges={},{}
  local function key(a,b,c)return math.floor(a*255+.5)*65536+math.floor(b*255+.5)*256+math.floor(c*255+.5)end
  for yy=0,24 do for xx=0,15 do
   local mid=r.rows[math.floor(yy/16)+1][1];local slot=p.ts.midToSlot[mid]
   if not slot then return end
   local ax,ay=slot%p.ts.cols*16+xx,math.floor(slot/p.ts.cols)*16+yy%16
   local a,b,c,d=p.ts.imageData:getPixel(ax,ay)
   if p.ts.overImageData then local aa,bb,cc,dd=p.ts.overImageData:getPixel(ax,ay);a,b,c,d=aa*dd+a*(1-dd),bb*dd+b*(1-dd),cc*dd+c*(1-dd),dd+d*(1-dd)end
   pixels[yy*16+xx]={a,b,c,d}
  end;edges[yy]={[key(unpack(pixels[yy*16]))]=true,[key(unpack(pixels[yy*16+15]))]=true}end
  local mask=V.require('SceneryMask').mask(16,function(xx,yy)local c=pixels[yy*16+xx];return c[4]<.5 or edges[yy][key(unpack(c))]end,25)
  for yy=0,24 do for xx=0,15 do if mask[yy*16+xx]then
   local a,b,c,d={x+xx,30-yy,z+24},{x+xx+1,30-yy,z+24},{x+xx+1,29-yy,z+24},{x+xx,29-yy,z+24}
   local mat=sample(xx,yy);emit({a,b,c,d},mat,1);emit({b,a,d,c},mat,1)
  end end end
 else error('unhandled RS institution design '..id)end
end
return M
