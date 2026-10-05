local F=dofile('lib/InteriorFurniture.lua')
local footprints={em_lilycove_gallery={0,32,64,48},fr_bed={16,32,32,48},fr_lorelei_bed={16,16,32,32},fr_home_bookcase={0,16,32,32},fr_room_pc={0,16,32,32},fr_roof_room_desk={0,16,32,32},
 fr_office_table={0,0,32,32},fr_executive_table={0,16,48,32},fr_sofa={0,0,48,16},fr_museum_bookcase={0,16,32,32},fr_center_storage={0,16,32,32},fr_department_glass={0,16,32,48},fr_department_stock={0,16,32,64},fr_lab_free_books={0,16,32,32},fr_condo_sofa={0,0,64,16},
 fr_condo_workstation={0,16,48,32},em_start_pc_left={0,16,32,32},em_start_pc_right={0,16,32,32},
 em_start_dresser={0,16,16,32},em_start_console={0,0,16,16},
 em_start_tv={0,0,32,16},em_start_bed={16,32,32,48},em_lab_starter={0,16,32,32},em_museum_wall_case={0,16,32,32},em_museum_cylinder={0,16,16,32},em_office_computer={0,16,32,32},em_office_desk={0,16,32,32}}
for name,b in pairs(footprints)do
 local count=0
 assert(F.draw(name,{sample=function()return{}end,source=function()end,width=32,
 box=function(l,y,n,r,h,s)
  if h>1.5 then
   count=count+1
   assert(l>=b[1] and n>=b[2] and r<=b[3] and s<=b[4],name..' solid enters walking lane')
  end
 end}))
 assert(count>0)
end
-- Repeated shop/house/Center fixtures must stay in the native blocked row.
local firstRow={fr_room_dresser=true,fr_lab_pc=true,fr_lab_books=true,em_space_controls=true,em_home_sofa=true,em_home_appliance=true,em_fortree_drawers=true,em_lab_desk=true,em_home_sink=true,em_home_drawers=true,fr_kitchen=true}
for id in pairs(F.placement)do
 local seen=0;local limit=({fr_department_glass=48,fr_department_stock=64})[id] or (firstRow[id] and 16 or 32)
 assert(F.draw(id,{sample=function()return{}end,source=function()end,width=32,
 box=function(l,y,n,r,h,s)
  if h>1.5 then seen=seen+1;assert(s<=limit,id..' enters the front walking lane')end
 end}))
 assert(seen>0,id..' lost its solid model')
end
local blocked={'11111','10000','10000','11100','11111'}
assert(F.draw('em_truck_cargo',{sample=function()return{}end,source=function()end,width=32,
 box=function(l,y,n,r,h,s)
  for cy=math.floor(n/16),math.ceil(s/16)-1 do for cx=math.floor(l/16),math.ceil(r/16)-1 do
   assert(blocked[cy+1]:sub(cx+1,cx+1)=='1','cargo overlaps walkable tile')
  end end
 end}))
local Pairs=dofile('lib/Gen3Tilesets.lua')
package.loaded['src.import.gba.versions']={TILESET_PAIRS={network={primary='building',secondary='pokemon_center'}}}
local D=assert(loadfile('lib/InteriorDiorama.lua'))({require=function(n)assert(n=='Gen3Tilesets');return Pairs end})
for gen=1,3 do
 local d={id='TEST_HOME',tileset='HOUSE',environment='INDOOR',mapType=8,width=gen==3 and 8 or 4,height=gen==3 and 8 or 4,
  warps={{x=2,y=7},{x=3,y=7},{x=5,y=2}},midLayout={pair='network',midAt=function()return 0x281 end}}
 local p=assert(D.forMap(d,gen));assert(#p.doorways[3]==1,'adjacent exit must be a single frame')
 assert(p.doorways[3][1][1]==32 and p.doorways[3][1][2]==64)
 for _,opened in ipairs{false,true}do
  local v=D.geometry(p,3,opened);local frame=false
  for i=1,#v,4 do
   local x,y,z=0,0,0
   for j=i,i+3 do x=x+v[j][1]/4;y=y+v[j][2]/4;z=z+v[j][3]/4 end
   assert(not(x>32 and x<64 and y>0 and y<math.min(30,p.height-4)),'wall blocks exit')
   if y>=math.min(30,p.height-4)then frame=true end
  end
  assert(frame,'cutaway hid door frame')
 end
 assert(#p.doorways[1]==0,'interior stairs turned into perimeter door')
end
print('PASS starter solid footprints, native truck lanes, three-generation exit apertures/cutaway frames')

-- Recess only the fixture span; retain the rest of the north wall and rebuild
-- cached geometry exactly when the streamed fixture list actually changes.
local p={gen=3,bounds={0,32,160,128},height=48,meshes={},doorways={{},{},{},{}}}
local released=0;p.meshes.old={release=function()released=released+1 end}
local fixtures={{32,48,19},{48,64,19},{80,96,40}}
D.setRecesses(p,fixtures)
assert(p.bounds[2]==19 and #p.northRecesses==1 and p.northRecesses[1][2]==64)
assert(fixtures[1][2]==48,'recess merge mutated source fixtures')
assert(released==1)
p.meshes.kept={release=function()released=released+1 end}
D.setRecesses(p,{{48,64,19},{32,48,19}})
assert(released==1,'equivalent fixture order rebuilt all meshes')
local vertices=D.geometry(p,1,false);local recessed,normal=false,false
for _,v in ipairs(vertices)do
 if v[1]>32.5 and v[1]<63.5 then assert(v[3]<21,'wall masks recessed furniture')end
 if v[3]==19 then recessed=true end
 if v[3]==32 then normal=true end
end
assert(recessed and normal)
D.setRecesses(p,{})
assert(p.bounds[2]==32 and #p.northRecesses==0 and released==2,'removed fixture left stale bay')
print('PASS shared furniture footprints and north-wall recess cache/geometry')

-- Polygon tops count too: the native condo table's first row is walkable.
local faces=0
assert(F.draw('fr_condo_meeting_table',{sample=function()return{}end,
 box=function(l,b,n,r,h,s)assert(n>=16 and s<=64)end,
 source=function(x,y,w,h,...)for _,v in ipairs{...}do assert(v[3]>=16 and v[3]<=64)end end,
 face=function(vs)faces=faces+1;for _,v in ipairs(vs)do assert(v[3]>=16 and v[3]<=64)end end}))
assert(faces>0)
print('PASS FRLG lab, condo desks/sofas and polygon table walkspace')

assert(F.draw('fr_processing_machine',{sample=function()return{}end,source=function()end,
 box=function(l,b,n,r,h,s)assert(not(r>32 and s>32),'access fittings cross the native walkable corner')end}))
print('PASS machinery access fittings remain inside native L-shaped footprint')

for _,dy in ipairs{0,16}do
 assert(F.draw('fr_elite_column',{recipe={faceY=dy},sample=function()return{}end,source=function()end,
 box=function(l,b,n,r,h,f)assert(l>=0 and r<=16 and n>=0 and f<=32,'column protrudes from blocked rows')end}))
end
print('PASS freestanding and wall-column blocked footprints')

for _,id in ipairs{'fr_elite_ice','fr_elite_stone','fr_elite_horn'}do
 local n=0
 local function check(vs)for _,v in ipairs(vs)do assert(v[1]>=0 and v[1]<=16 and v[3]>=0 and v[3]<=32,id..' crosses native blocked rows');n=n+1 end end
 assert(F.draw(id,{recipe={},sample=function()return{}end,source=function(x,y,w,h,...)check({...})end,
 box=function(l,b,n,r,h,f)check{{l,b,n},{r,h,f}}end,face=check}))
 assert(n>0)
end
print('PASS League ice/stone solid and polygon footprints')

for _,fixture in ipairs{'ice','stone','column','horn'}do
 local count=0
 local function check(vs)for _,v in ipairs(vs)do
  assert(v[1]>=0 and v[1]<=16 and v[3]>=28 and v[3]<48,'League wall fixture crosses into walkable apron')
  count=count+1
 end end
 assert(F.draw('fr_elite_wall',{recipe={fixture=fixture},sample=function()return{}end,
  box=function(l,b,n,r,h,f)check{{l,b,n},{r,h,f}}end,
  source=function(x,y,w,h,...)check({...})end,face=check}))
 assert(count>0)
end
print('PASS complete League wall fixtures stop before the walkable apron')
