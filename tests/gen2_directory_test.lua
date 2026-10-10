local V,cache={},{}
function V.require(n)
 if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end
 return cache[n]
end
local recipe
for _,r in ipairs(assert(loadfile('data/gen2_furniture.lua'))().TILESET_MART)do
 if r.id=='crystal_department_directory' then recipe=r end
end
assert(recipe and recipe.tiles[1][1]==44 and recipe.tiles[2][2]==61)
local lettering=0
for _,q in ipairs(V.require('Gen2DesignedFurniture').build(recipe,nil,16,128,128))do
 for _,p in ipairs(q)do
  assert(p[1]>=0 and p[1]<=16 and p[3]>=0 and p[3]<=16,'directory enters adjacent stair/walking cell')
  assert(p[2]>=0 and p[2]<=24,'directory leaves room wall')
 end
 if math.abs(q[1][3]-14.52)<1e-6 then
  lettering=lettering+1
  for _,p in ipairs(q)do assert(math.abs(p[3]-14.52)<1e-6 and p[2]>=7-1e-6 and p[2]<=21+1e-6,'directory lettering not on its front')end
 end
end
assert(lettering==196,'directory native lettering crop incomplete')
print('PASS native directory: recessed lettering and bounded closed frame')
