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
