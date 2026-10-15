local edition='firered'
package.loaded['src.core.GameVersion']={get=function()return edition end}
package.loaded['src.core.game3.collision']={isSurfable=function()return false end}
local F=dofile('lib/Gen3Furniture.lua')
local function fixture(ground,collision,pair)
 local c={}
 for y=-1,1 do for x=-1,1 do c[x..':'..y]={cx=x,cy=y,mid=ground,collision=0,
  pair=pair or 'general__rom_082d4b84',primary='general',shape={kind='flat',reviewedSurface=true}}end end
 c['0:0'].mid=0x2c6;c['0:0'].collision=collision;c['0:0'].shape={kind='flat'}
 return c
end
for _,ed in ipairs{'firered','leafgreen'}do
 edition=ed
 for _,ground in ipairs{0x28a,1}do local cells=fixture(ground,7);local props=F.extract(cells)
  assert(#props==1 and props[1].recipe.kind=='stoneBollard')
  assert(F.groundAt(cells['0:0'])==ground,'post ignored immediate native paving/grass')
 end
 assert(#F.extract(fixture(1,0))==0,'post occupied a walking tile')
 assert(#F.extract(fixture(1,7,'general__other'))==0,'post IDs leaked across secondary art')
end
edition='emerald';assert(#F.extract(fixture(1,7))==0,'Kanto post leaked into Hoenn')
local edges,n={},0
local function key(p)return ('%.6f/%.6f/%.6f'):format(unpack(p))end
local uv={{.5,.5},{.5,.5},{.5,.5},{.5,.5}}
dofile('lib/Gen3StoneBollard.lua').append({cx=0,cy=0},function(v,t,s)
 n=n+1;assert(s<64,'stone became emissive')
 for i,p in ipairs(v)do
  assert(p[1]>0 and p[1]<16 and p[3]>0 and p[3]<16 and p[2]>=0 and p[2]<=9.2,'post crossed native bounds')
  local a,b=key(p),key(v[i%4+1]);if a~=b then if a>b then a,b=b,a end;edges[a..':'..b]=(edges[a..':'..b]or 0)+1 end
 end
end,function()return uv end)
assert(n>50);for _,count in pairs(edges)do assert(count==2,'post shell has an open edge')end
local cache={TreePresentation={props={get=function()return 'modeled'end}}};local V={}
function V.require(name)if not cache[name]then cache[name]=assert(loadfile('lib/'..name..'.lua'))(V)end;return cache[name]end
local H,RS=V.require('Gen3Hoenn'),V.require('Gen3RubySapphire')
for _,ed in ipairs{'emerald','ruby','sapphire'}do edition=ed
 local shape=H.shape('general','lilycove',0xe0,0,7)
 assert(shape.kind=='rock' and shape.ground==1)
 assert(H.shape('general','lilycove',0xe0,0,0).kind~='rock','boulder occupied walking tile')
 assert(H.shape('building','generic_building',0xe0,0,7).kind~='rock','field boulder leaked indoors')
 local ts={cols=2,midToSlot={[0xe0]=0,[1]=1},imageData={getPixel=function(_,x,y)
  if x<16 and x>=1 and x<15 and y>=1 and y<15 then return .6,.4,.3,1 end
  return .2,.7,.4,1
 end}}
 local count=0
 V.require('Gen3Cave').rock({cx=0,cy=0,mid=0xe0,ts=ts,shape=shape},function(v,t,s,anchor)
  count=count+1;assert(not anchor,'default modeled boulder stayed a card')
  for _,p in ipairs(v)do assert(p[1]>=0 and p[1]<=16 and p[3]>=0 and p[3]<=16 and p[2]>=0 and p[2]<=16,'boulder crossed native cell')end
 end,function(_,mid)local a=mid==1 and .5 or 0;return {{a,0},{a+.5,0},{a+.5,1},{a,1}}end)
 assert(count>20,'boulder shell missing')
end
print('PASS FRLG closed non-emissive bollards, local ground, edition/permission veto; RSE bounded modeled field boulders')
