local recipes=dofile('data/gen2_furniture.lua')
assert(recipes.TILESET_PLAYERS_HOUSE[1].id=='crystal_kitchen')
assert(recipes.TILESET_HOUSE[#recipes.TILESET_HOUSE].id=='crystal_stool','inserting a kitchen changed the common-house stool')
local desk=recipes.TILESET_PLAYERS_ROOM[1]
assert(desk.model=='room_desk' and #desk.tiles==4 and #desk.tiles[1]==4)
local mesh=dofile('lib/Gen2RoomDesk.lua').build(desk,{},16,128,128)
local maxY=0
for _,q in ipairs(mesh)do for i=1,4 do
 local v=q[i];assert(v[1]>=0 and v[1]<=32 and v[3]>=8 and v[3]<=24,'desk spills into walking cells')
 maxY=math.max(maxY,v[2]);assert(v[2]>=0 and v[2]<=19.00001,'workstation became a room-height cabinet')
 assert(q.uv[i][1]>0 and q.uv[i][1]<1 and q.uv[i][2]>0 and q.uv[i][2]<1)
end end
assert(math.abs(maxY-19)<.00001)
local E=dofile('lib/RoofEaves.lua');local n=0
for _,dx in ipairs({-2,2})do for _,dz in ipairs({-1.5,1.5})do
 local faces={}
 E.corner({5,20,7},dx,dz,{{0,0},{1,0},{1,1},{0,1}},function(p)
  faces[#faces+1]=p
  for _,v in ipairs(p)do
   assert(v[1]>=math.min(5,5+dx) and v[1]<=math.max(5,5+dx))
   assert(v[3]>=math.min(7,7+dz) and v[3]<=math.max(7,7+dz))
   assert(v[2]>=19.39 and v[2]<=20.05)
  end
 end)
 assert(#faces==5,'corner missing top, soffit or fascia closure');n=n+#faces
end end
print('PASS bounded native Crystal desk and '..n..' roof corner faces')
