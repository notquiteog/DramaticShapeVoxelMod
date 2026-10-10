-- Native MART panes must remain recessed wall fixtures, never glass roofs.
local V,cache={},{}
function V.require(n)
 if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end
 return cache[n]
end
local recipe
for _,r in ipairs(assert(loadfile('data/gen2_furniture.lua'))().TILESET_MART)do
 if r.id=='crystal_department_window' then recipe=r end
end
assert(recipe and #recipe.tiles==2 and #recipe.tiles[1]==2)
assert(recipe.tiles[1][1]==14 and recipe.tiles[1][2]==15 and recipe.tiles[2][1]==28 and recipe.tiles[2][2]==29)
local q=V.require('Gen2DesignedFurniture').build(recipe,nil,16,128,128)
local recessed=0
for _,face in ipairs(q)do
 for _,p in ipairs(face)do
  assert(p[1]>=0 and p[1]<=16 and p[3]>=0 and p[3]<=16,'window invades neighboring native cell')
  assert(p[2]>=0 and p[2]<=24,'window exceeds room wall')
 end
 if math.abs(face[1][3]-14.02)<.001 then
  recessed=recessed+1
  for _,p in ipairs(face)do assert(p[3]==face[1][3],'native glass projected onto horizontal roof')end
 end
end
assert(recessed==14*14,'native glass crop incomplete')
print('PASS Crystal department panes: whole pattern, native glass plane and blocked-cell bounds')
local elevator
for _,r in ipairs(assert(loadfile('data/gen2_furniture.lua'))().TILESET_MART)do
 if r.id=='crystal_department_elevator' then elevator=r end
end
assert(elevator and #elevator.tiles[1]==4 and #elevator.tiles==2)
local doors=V.require('Gen2DesignedFurniture').build(elevator,nil,16,128,128)
for _,face in ipairs(doors)do
 local x0,x1,y0,y1,z0,z1=math.huge,-math.huge,math.huge,-math.huge,math.huge,-math.huge
 for _,p in ipairs(face)do
  x0=math.min(x0,p[1]);x1=math.max(x1,p[1]);y0=math.min(y0,p[2]);y1=math.max(y1,p[2]);z0=math.min(z0,p[3]);z1=math.max(z1,p[3])
  assert(p[1]>=0 and p[1]<=32 and p[3]>=0 and p[3]<=16.03,'elevator outside native two-cell footprint')
 end
 assert(not(x1>1 and x0<15 and z1>.6 and z0<16 and y0<23 and y1>0),'elevator closes walkable native warp approach')
end
print('PASS elevator approach clear below lintel; closed door at rear plane')
local overlap
for _,r in ipairs(assert(loadfile('data/gen2_furniture.lua'))().TILESET_MART)do
 if r.id=='crystal_department_counter_window' then overlap=r end
end
assert(overlap and overlap.tiles[2][1]==42 and overlap.tiles[2][2]==43)
local pane,worktop=0,0
for _,face in ipairs(V.require('Gen2DesignedFurniture').build(overlap,nil,16,128,128))do
 for _,p in ipairs(face)do assert(p[1]>=0 and p[1]<=16 and p[3]>=0 and p[3]<=16,'counter/window outside blocked source cell')end
 if face[1][3]==14.02 then
  pane=pane+1
  assert(face[1][2]~=face[3][2],'glass became a counter roof')
 elseif face[1][2]==10.02 then
  worktop=worktop+1
  assert(face[1][3]~=face[3][3],'countertop became a vertical wall')
 end
end
assert(pane==98 and worktop==112,'overlapping drawing lost glass or counter surface')
print('PASS overlapping counter and window separated into horizontal and vertical surfaces')
