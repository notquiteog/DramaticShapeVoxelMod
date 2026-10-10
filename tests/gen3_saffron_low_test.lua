package.loaded['src.core.GameVersion']={get=function()return 'firered' end,generation=function()return 3 end}
local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local C=V.require('Gen3Civic');local r
for _,q in ipairs(dofile('data/gen3_exteriors.lua'))do if q.name=='saffron_low_house' then r=q end end
assert(r and r.header==4 and r.ground==0x2e5)
local cells={}
for yy,row in ipairs(r.rows)do for xx,mid in ipairs(row)do cells[(xx-1)..':'..(yy-1)]={cx=xx-1,cy=yy-1,mid=mid,pair=r.pair,primary='general',collision=yy==1 and 0 or 7,ts={}}end end
local list=C.prepare(cells,{}, {r});assert(#list==1 and list[1].bodyBack==18)
local n=0
C.append(list[1],function(v,uv)
 n=n+1
 for i,q in ipairs(v)do
  assert(q[3]>=14.5,'roof exceeds bounded rear eave')
  if q[2]<16 then assert(q[3]>=17.5,'low wall blocks rear lane')end
  assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1,'source UV escaped')
 end
end)
assert(n>25)
print('PASS short Saffron complete pattern, native rear clearance and roof UVs')
