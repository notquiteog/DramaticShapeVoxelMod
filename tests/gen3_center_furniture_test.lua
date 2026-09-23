local F=dofile('lib/Gen3Furniture.lua')
local C=dofile('lib/Gen3CenterFurniture.lua')
local count=0
local list={};for _,r in ipairs(F.recipes)do if r.pair=='network'then list[#list+1]=r end end
for _,r in ipairs(list)do if r.pair=='network' then
 local cells={};for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
  cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,primary='building',secondary='pokemon_center',pair='network',ts={}}
 end end
 local props=F.extract(cells);assert(#props==1 and props[1].recipe==r,'bad complete match: '..r.name)
 local n,minY,maxY,minZ=0,999,-999,999
 F.append(props[1],function(p,uv)
  n=n+1;for i,v in ipairs(p)do
   minZ=math.min(minZ,v[3]);minY,maxY=math.min(minY,v[2]),math.max(maxY,v[2]);assert(v[2]==v[2])
   assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1,'out-of-tile UV')
  end
 end,function()return {{0,0},{1,0},{1,1},{0,1}}end)
 assert(n>0,r.name)
 if r.kind=='centerCounter' or r.kind=='centerUpperCounter'then
  assert(maxY<7.1,'counter hides staff torso')
  assert(minZ>=(r.kind=='centerCounter' and 9 or 25),'counter intersects rotating staff card')
 end
 if r.kind=='escalator'then assert(minY<0 and maxY<25,'unbounded escalator')
  if r.down then assert(maxY<8 and r.noGround,'down escalator is a raised staircase')end
 end
 count=count+1
end end
for mid,base in pairs({[0x30A]=0x2D0,[0x308]=0x2D0,[0x313]=0x2D9,[0x315]=0x2E4,[0x31C]=0x2EB})do
 assert(C.canonical(mid)==base,'animated escalator lost assembly')
end
local Room=assert(loadfile('lib/InteriorDiorama.lua'))({})
local p={bounds={0,0,64,64},height=40,openings={{16,16,32,48}}}
local v=Room.geometry(p,5)
for i=1,#v,4 do
 local q={v[i],v[i+1],v[i+2],v[i+3]}
 if q[1][2]==-.25 and q[2][2]==-.25 and q[3][2]==-.25 and q[4][2]==-.25 then
  local x,z=0,0;for _,a in ipairs(q)do x=x+a[1]/4;z=z+a[3]/4 end
  assert(not(x>16 and x<32 and z>16 and z<48),'plinth sealed descending flight')
 end
end
print('PASS '..count..' Center fixtures, animated escalator aliases and open diorama foundation')
