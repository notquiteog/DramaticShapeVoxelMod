-- Guard against floor-to-furniture false positives and atlas crop overflow.
local version='firered'
package.loaded['src.core.GameVersion']={get=function()return version end}
local V,cache={},{}
function V.require(n)
 if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end
 return cache[n]
end
local F=V.require('Gen3Furniture')
local floor={['0:0']={cx=0,cy=0,mid=0x2c0,pair='building__rom_082d4e6c',primary='building',ts={}}}
assert(#F.extract(floor)==0,'Celadon parquet became merchandise')
-- Native wall/floor IDs formerly assigned arbitrary beds or consoles.
for _,q in ipairs{{'building__rom_082d4fa4',0x14f},{'building__rom_082d4e24',0x14d},
 {'building__rom_082d4d1c',0x2ae},{'building__rom_082d4cbc',0x291},
 {'building__rom_082d4d4c',0x284},{'building__rom_082d4d7c',0x2b0},
 {'building__rom_082d4d34',0x2c8},{'building__rom_082d4d64',0x294}}do
 assert(#F.extract({['0:0']={cx=0,cy=0,mid=q[2],pair=q[1],primary='building',ts={}}})==0,'floor/wall became furniture')
end
local recipes={};V.require('Gen3DesignedFurniture').install(recipes)
local chosen={}
for _,r in ipairs(recipes)do if r.design and (r.name:find('department_',1,true)==1 or r.name:find('sevii_',1,true)==1 or r.name:find('corner_',1,true)==1 or r.name:find('vermilion_',1,true)==1 or r.name:find('saffron_',1,true)==1 or r.name:find('cinnabar_',1,true)==1 or r.name:find('condo_',1,true)==1 or r.name:find('lorelei_',1,true)==1 or r.name:find('hotel_lobby_',1,true)==1 or r.name:find('tanoby_masonry_',1,true)==1 or r.name:find('roof_room_',1,true)==1)then chosen[#chosen+1]=r end end
for _,r in ipairs(V.require('Gen3Hoenn').recipes)do if (r.name:find('hoenn_home_',1,true)==1 or r.name:find('hoenn_start_',1,true)==1) and r.design then chosen[#chosen+1]=r end end
local function geometry(r,w,h)
 local boxes,faces=0,0
 local function coord(x,y)assert(x>=0 and y>=0 and x<w and y<h,r.design..' source sample overflow')end
 assert(V.require('InteriorFurniture').draw(r.design,{
  width=w,height=h,recipe=r,
  face=function(q)
   faces=faces+1
   for _,p in ipairs(q)do assert(p[2]>=0 and p[2]==p[2])end
  end,
  sample=function(x,y)coord(x,y);return {}end,
  source=function(x,y,sw,sh,a,b,c,d)
   coord(x,y);coord(x+sw-1,y+sh-1);faces=faces+1
   for _,p in ipairs{a,b,c,d}do assert(p[2]>=0 and p[2]==p[2],r.design)end
  end,
  box=function(l,b,n,rr,t,s)
   assert(l<rr and b<t and n<s,r.design..' degenerate box')
   assert(b>=0,r.design..' below floor');boxes=boxes+1
  end,
 }),r.design)
 assert(boxes>=(r.design=='fr_saffron_telepad' and 1 or 3) and (faces>=1 or r.design=='fr_vermilion_gate'),r.design..' missing modeled components')
end
for _,r in ipairs(chosen)do
 geometry(r,#r.rows[1]*16,#r.rows*16)
 version=r.family=='rse' and 'emerald' or 'firered'
 local cells={}
 for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,pair=r.pair,primary='building',ts={}}end end
 local found=F.extract(cells);assert(#found==1 and found[1].recipe.name==r.name,r.name)
 if #r.rows>1 then
  for _,c in pairs(cells)do c.prop=nil end
  cells['0:0']=nil
  for _,p in ipairs(F.extract(cells))do assert(p.recipe.name~=r.name,'partial fixture claimed')end
 end
end
for _,r in ipairs(assert(loadfile('data/gen2_furniture.lua'))().TILESET_MART)do
 if r.id:find('crystal_department_',1,true)==1 then geometry(r,#r.tiles[1]*8,#r.tiles*8)end
end
print('PASS complete native furniture matches, parquet exclusion, source bounds and closed components')
