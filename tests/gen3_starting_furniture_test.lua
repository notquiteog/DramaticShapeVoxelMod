local F=dofile('lib/Gen3Furniture.lua')
local function claim(pair,rows)
 local cells={}
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do
  cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=pair,primary='building',secondary='pretty_petals_flower_shop',ts={}}
 end end
 return F.extract(cells)
end
local p=claim('player_house',{{0x35},{0x28e},{0x296}})
assert(#p==1 and p[1].recipe.design=='fr_console','generic cabinet swallowed the complete console')
for _,pair in ipairs({'player_house','house'})do
 for _,r in ipairs({{{0x2e,0x2f},{0x36,0x37},{0x3e,0x3f}},{{0x2d},{0x35},{0x3d}},{{0x2b,0x2c},{0x33,0x34},{0x3b,0x3c}}})do
  p=claim(pair,r);assert(#p==1 and p[1].recipe.design,'shared complete house appliance remained a slab')
 end
 for _,r in ipairs({{{0x57},{0x5f}},{{0x47},{0x4f}}})do
  p=claim(pair,r);assert(#p==1 and p[1].recipe.kind=='plant','house plant stayed flat on floor')
 end
end
p=claim('player_house',{{0x35},{0x28e},{1}})
for _,p in ipairs(p)do assert(p.recipe.design~='fr_console','incomplete console stole floor')end
p=claim('house',{{0x184},{0x185}})
assert(#p==1 and p[1].recipe.design=='fr_wall_picture','neighbor picture remained on the floor')
print('PASS specific model precedence, console ownership and complete neighboring-house furniture/plant claims')
