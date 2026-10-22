local edition='firered'
package.loaded['src.core.GameVersion']={get=function()return edition end}
local F=dofile('lib/Gen3Furniture.lua');local Frames=dofile('lib/Gen3PublicPCFrames.lua')
for _,version in ipairs{'firered','leafgreen','ruby','sapphire','emerald'}do
 edition=version;local hoenn=version~='firered'and version~='leafgreen'
 local name=hoenn and'hoenn_center_pc'or'center_terminal';local recipe
 for _,r in ipairs(F.recipes)do if r.name==name then recipe=r end end;assert(recipe)
 local off,on=hoenn and 4 or 0x62,hoenn and 5 or 0x63
 for _,mid in ipairs{off,on,off,on,off}do
  local cells={};for y,row in ipairs(recipe.rows)do for x,n in ipairs(row)do
   cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=y==2 and mid or n,collision=({7,0x93,0})[y],
    pair=recipe.pair,primary='building',secondary=hoenn and'pokemon_center'or'network',ts={}}
  end end
  local p=F.extract(cells)[1];assert(p and p.recipe==recipe,version..' powered extraction')
  assert(cells['0:1'].mid==mid and cells['0:1'].collision==0x93,'native animation/gameplay mutated')
  if mid==on then assert(p.nativeRows[2][1]==on)else assert(not p.nativeRows)end
  local seen={};F.append(p,function()end,function(_,nativeMid)seen[nativeMid]=true;return{{0,0},{1,0},{1,1},{0,1}}end)
  assert(seen[mid],version..' native fallback rendered wrong power frame')
 end
 assert(recipe.rows[2][1]==off,'shared recipe mutated')
 local changed={name='lab_terminal',pair=recipe.pair,family=recipe.family}
 assert(not Frames.matches(changed,on,off),'unrelated terminal was aliased')
 changed={name=recipe.name,pair='unrelated',family=recipe.family}
 assert(not Frames.matches(changed,on,off),'unrelated region was aliased')
end
print('PASS all-five public PC ON/OFF extraction, unchanged native cells, powered native fallback artwork and unrelated-family isolation')
