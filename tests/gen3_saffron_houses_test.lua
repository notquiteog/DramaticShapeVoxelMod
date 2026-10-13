package.loaded['src.core.GameVersion']={get=function()return 'firered' end,generation=function()return 3 end}
local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local C=V.require('Gen3Civic')
local wanted={saffron_house=true,saffron_door_house=true,saffron_wide_door_house=true};local count=0
for _,r in ipairs(dofile('data/gen3_exteriors.lua'))do if wanted[r.name]then
 count=count+1
 local function fixture()
  local cells={}
  for yy,row in ipairs(r.rows)do for xx,mid in ipairs(row)do cells[(xx-1)..':'..(yy-1)]={cx=xx-1,cy=yy-1,mid=mid,pair=r.pair,primary='general',collision=yy==1 and 0 or 7,ts={}}end end
  return cells
 end
 local list=C.prepare(fixture(),{}, {r});assert(#list==1 and list[1].bodyBack==18)
 C.append(list[1],function(v,uv)
  for i,q in ipairs(v)do
   assert(q[3]>=14.5,'unbounded rear eave')
   if q[2]<16 then assert(q[3]>=17.5,'walking rear row obstructed')end
   assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1,'native UV bounds')
  end
 end)
 if r.openings then local tx=r.name=='saffron_door_house' and 1 or 2;local d=C.doorSurface(list[1],tx,4);assert(d and d.vertices[1][2]==20 and d.vertices[1][3]==78.05,'native door alignment')end
 local cells=fixture();cells['1:3'].mid=0;assert(#C.prepare(cells,{}, {r})==0,'partial house falsely consumed')
end end
assert(count==3)
print('PASS all three Saffron house variants: complete sources, rear walking lane, roof UVs and 20px door openings')
