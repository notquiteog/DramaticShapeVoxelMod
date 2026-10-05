local V={};local mods={}
function V.require(n)if not mods[n]then mods[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return mods[n]end
local S=V.require('Gen3Statue')
local samples=0
local ts={cols=2,rows=1,midToSlot={[0x240]=0},imageData={},overImageData={}}
function ts.overImageData:getPixel(x,y)
 samples=samples+1
 -- Narrow native upper-layer figure surrounded by opaque UNDER-layer floor.
 return .6,.6,.7,(x>=4 and x<=11 and y>=2) and 1 or 0
end
local p={cx=3,cy=7,ts=ts,recipe={rows={{0x240},{0x249}}}}
local function uv()return{{0,0},{.5,0},{.5,1},{0,1}}end
local n,high=0,0
local function emit(vs)
 for _,v in ipairs(vs)do
  assert(v[1]>=48 and v[1]<=64 and v[3]>=129 and v[3]<=143,'statue entered native walkable top row or neighboring aisle')
  if v[2]>11 then assert(v[1]>=52 and v[1]<=60 and v[3]>=132 and v[3]<=140,'floor leaked into sculpture')end
  high=math.max(high,v[2])
 end
 n=n+1
end
local function box(l,b,n,r,h,f)emit{{l,b,n},{r,h,f}}end
local function source(x,y,w,h,...)emit({...})end
S.append(p,emit,uv,box,source,uv)
assert(n>10 and high>20,'figure or plinth missing')
local first=samples;S.append(p,emit,uv,box,source,uv)
assert(samples==first,'repeated statue rebuilt its native voxel template')
local F=V.require('Gen3Furniture')
local cells={['3:7']={cx=3,cy=7,mid=0x240,collision=0,primary='building',pair='building__rom_082d50c4'},
 ['3:8']={cx=3,cy=8,mid=0x249,collision=7,primary='building',pair='building__rom_082d50c4'}}
local props=F.extract(cells);assert(#props==1 and props[1].recipe.kind=='statue')
assert(cells['3:7'].collision==0 and cells['3:8'].collision==7,'changed native collision')
cells['3:7'].prop=nil;cells['3:8'].prop=nil;cells['3:8'].mid=0x284
assert(#F.extract(cells)==0,'partial statue stole the boundary wall')
cells['3:8'].mid=0x249;cells['3:8'].collision=0
assert(#F.extract(cells)==0,'statue placed on a native walkable base')
print('PASS native upper-layer statue volume, blocked footprint, reusable mesh and incomplete drawing isolation')
local boundary={};for row,mid in ipairs{0x241,0x290,0x286,0x287}do
 boundary['0:'..(row-1)]={cx=0,cy=row-1,mid=mid,collision=row==1 and 0 or 7,primary='building',pair='building__rom_082d50c4',ts=ts}
end
ts.midToSlot[0x241]=0
local complete=F.extract(boundary);assert(#complete==1 and complete[1].recipe.baseMid==0x249,'boundary assembly incomplete')
local count=0
F.append(complete[1],function(vs)
 for _,v in ipairs(vs)do
  assert(v[1]>=0 and v[1]<=16 and ((v[3]>=17 and v[3]<=31) ), 'boundary statue or wall escaped blocked cells')
 end
 count=count+1
end,uv)
assert(count>20,'sculpture absent')
assert(not boundary['0:2'].prop and not boundary['0:3'].prop,'statue claimed neighboring wall')
for _,c in pairs(boundary)do c.prop=nil end
boundary['0:1'].collision=0
assert(#F.extract(boundary)==0,'boundary statue occupied a walkable cap')
print('PASS boundary statue isolation and native plinth reuse')
