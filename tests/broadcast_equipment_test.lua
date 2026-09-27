local F=dofile('lib/Gen3Furniture.lua')
local G=dofile('lib/InteriorFurniture.lua')
local r
for _,v in ipairs(F.recipes)do if v.name=='rocket_processing_machine'then r=v end end
assert(r)
local function cells(pair,broken)
 local c={}
 for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
  local cx,cy=x-1,y-1;c[cx..':'..cy]={cx=cx,cy=cy,mid=mid,primary='building',pair=pair,ts={}}
 end end
 if broken then c['1:1'].mid=0x281 end
 return c
end
local c=cells(r.pair);local props=F.extract(c)
assert(#props==1 and props[1].recipe==r)
for _,v in pairs(c)do assert(v.prop==props[1])end
assert(#F.extract(cells('unrelated'))==0)
assert(#F.extract(cells(r.pair,true))==0,'partial machine consumed')
local function model(id,w,h,minSourceY)
 local boxes,feet,fins=0,0,0
 local function bounds(x,y)assert(x>=0 and x<w and y>=minSourceY and y<h,id..' samples floor/wall or out of bounds')end
 G.draw(id,{width=w,height=h,recipe=r,
  sample=function(x,y)bounds(x,y);return{}end,
  source=function(x,y,sw,sh)bounds(x,y);bounds(x+sw-.001,y+sh-.001)end,
  box=function(l,b,n,rr,hi,s)
   assert(rr>l and hi>b and s>n and b>=0,id..' inverted component')
   assert(l>=0 and rr<=w and n>=0 and s<=h,id..' exceeds its footprint')
   assert(hi<=37,id..' too tall');boxes=boxes+1;if b==0 then feet=feet+1 end
   if id=='fr_processing_machine' and b==23 and hi==31 then assert(rr-l==1);fins=fins+1 end
  end})
 assert(boxes>=8 and feet>=1,id..' lacks separate grounded components')
 return fins
end
assert(model('fr_processing_machine',48,48,8)==7,'radiator lost separated fins')
model('gb_broadcast_receiver',16,32,8)
model('gb_broadcast_studio',48,24,0)
model('gb_broadcast_desk',32,16,0)
model('gb_broadcast_mixer',32,16,0)
model('gb_broadcast_stool',16,16,0)
local specs=dofile('data/gen2_depth_furniture.lua').TILESET_RADIO_TOWER
local n=0;for _,s in ipairs(specs)do if s.design then n=n+1;assert(s.design:match('^gb_broadcast_'))end end
assert(n==5)
local Shapes=dofile('lib/Gen3TileShape.lua')
package.loaded['src.core.game3.collision']={isSurfable=function()return false end}
for _,mid in ipairs({0x289,0x28a,0x28b,0x291,0x292,0x293,0x299,0x29a,0x2b3,0x2b4,0x2de,0x2df,0x2e6,0x2e7,0x2ff})do
 local s=Shapes.of('building','rom_082d4ecc',mid,0,7)
 assert(s.kind=='roomWall' and s.ground==0x281,'Rocket partition lost its native floor')
 assert(Shapes.of('building','rom_082d4ecc',mid,0,0).kind~='roomWall','walkable copy raised')
end
assert(Shapes.of('building','rom_082d4ecc',0x330,0,7).ground==0x334,'Silph wall changed floor')
print('PASS complete machine, pair/partial isolation, native source bounds, grounded components and seven separate radiator fins')
