local Furniture=dofile('lib/Gen3Furniture.lua')
local cells={}
local function place(name,x,y)
 local r;for _,s in ipairs(Furniture.recipes)do if s.name==name then r=s end end
 assert(r,name)
 for dy,row in ipairs(r.rows)do for dx,mid in ipairs(row)do
  local cx,cy=x+dx-1,y+dy-1
  cells[cx..':'..cy]={cx=cx,cy=cy,mid=mid,primary='building',secondary='lab',pair='oak_lab',ts={}}
 end end
end
place('lab_pokemon_machine',1,3);place('lab_work_table',8,4);place('lab_pokedex_desk',4,1)
local props=Furniture.extract(cells);assert(#props==3)
assert(cells['2:5'].prop.recipe.name=='lab_pokemon_machine','machine drawing left on floor')
for _,x in ipairs({8,9,10})do assert(Furniture.support(cells,92,x*16,4*16)>9,'starter clipped into table')end
assert(Furniture.support(cells,94,64,16)>12,'Pokedex clipped into counter')
assert(Furniture.support(cells,72,128,64)==0,'human actor raised by prop rule')
assert(Furniture.support(cells,92,160,160)==0,'ground item raised')
local _,deskZ=Furniture.support(cells,94,64,16);assert(deskZ==5,'Pokedex intersects back wall')
local count,bounds=0,{math.huge,-math.huge}
local function uv(_,mid)return {{0,0},{1,0},{1,1},{0,1}}end
for _,p in ipairs(props)do if p.recipe.kind=='labMachine'then
 Furniture.append(p,function(v,t)
  count=count+1;for _,a in ipairs(v)do
   for _,n in ipairs(a)do assert(n==n and math.abs(n)<1000)end
   bounds[1]=math.min(bounds[1],a[2]);bounds[2]=math.max(bounds[2],a[2])
  end
 end,uv)
end end
assert(count>100 and bounds[1]==0 and bounds[2]>24,'missing round machine body or feet')
print('PASS full lab machine, supported starter/Pokedex props and grounded NPCs')

-- Native Oak layout: x8..10/y4 is blocked; y5 contains the perspective
-- apron and is used by starter scripts. Restore the top's depth without
-- reaching upright actors' feet at the SOUTH edge of that approach row.
local minZ,maxZ=math.huge,-math.huge
for _,p in ipairs(props)do if p.recipe.name=='lab_work_table'then
 Furniture.append(p,function(vertices)
  for _,a in ipairs(vertices)do
   minZ=math.min(minZ,a[3]);maxZ=math.max(maxZ,a[3])
  end
 end,uv)
end end
local _,ballZ=Furniture.support(cells,92,8*16,4*16)
local ballCenter=5*16+ballZ
assert(maxZ-minZ>=23,'starter table compressed to a narrow bench')
assert(math.abs((minZ+maxZ)/2-ballCenter)<.1,'starters sit at the edge instead of the center')
assert(ballCenter-6>minZ and ballCenter+6<maxZ,'rotating starter sprite overhangs the top')
assert(Furniture.support(cells,92,8*16,5*16)==0,'walkable apron incorrectly raises a ground item')
assert(6*16-6>maxZ,'table reaches upright actors in the approach row')
print('PASS full-depth lab table, centered starter sprites and clear native approach row')
