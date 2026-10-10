local V,cache={},{}
function V.require(n)
 if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end
 return cache[n]
end
local recipe
for _,r in ipairs(assert(loadfile('data/gen2_furniture.lua'))().TILESET_MART)do
 if r.id=='crystal_department_register' then recipe=r end
end
assert(recipe and #recipe.tiles==2 and #recipe.tiles[1]==2)
local quads=V.require('Gen2DesignedFurniture').build(recipe,nil,16,128,128)
local raised,sloped=false,false
for _,q in ipairs(quads)do
 for _,p in ipairs(q)do
  assert(p[1]>=0 and p[1]<=16 and p[3]>=0 and p[3]<=16,'register invades native adjacent cell')
  assert(p[2]>=0 and p[2]<=15,'register height invalid')
  if p[2]>12 then raised=true end
 end
 if q[1][2]~=q[3][2] and q[1][3]~=q[3][3] and q[1][1]~=q[3][1] then sloped=true end
end
assert(raised and sloped,'register became flat counter artwork')
print('PASS Gen2 register: bounded source assembly, raised display and inclined keypad')
