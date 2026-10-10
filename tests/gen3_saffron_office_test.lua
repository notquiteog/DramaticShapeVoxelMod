package.loaded['src.core.GameVersion']={get=function()return 'firered' end,generation=function()return 3 end}
local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local C=V.require('Gen3Civic');local r
for _,q in ipairs(dofile('data/gen3_exteriors.lua'))do if q.name=='saffron_tall_house' then r=q end end
assert(r and r.header==6 and #r.rows[1]==5)
local function fixture()
 local cells={}
 for yy,row in ipairs(r.rows)do for xx,mid in ipairs(row)do cells[(xx-1)..':'..(yy-1)]={cx=xx-1,cy=yy-1,mid=mid,pair=r.pair,primary='general',collision=yy==1 and 0 or 7,ts={}}end end
 return cells
end
local list=C.prepare(fixture(),{}, {r});assert(#list==1 and list[1].bodyBack==18)
local count,soffit=0,false
C.append(list[1],function(v,uv)
 count=count+1;local lo,hi=math.huge,-math.huge
 for i,q in ipairs(v)do
  assert(q[1]>=0 and q[1]<=80 and q[3]>=16 and q[3]<=96,'office native footprint bounds')
  if q[2]<16 then assert(q[3]>=17.5,'office rear walking strip blocked')end
  lo=math.min(lo,q[2]);hi=math.max(hi,q[2])
  assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1,'invalid native UV')
 end
 soffit=soffit or lo==63 and hi==63
end)
assert(count>90 and soffit,'closed office roof missing')
for _,q in ipairs{{2,2},{4,4},{3,5}}do local cells=fixture();cells[q[1]..':'..q[2]].mid=0;assert(#C.prepare(cells,{}, {r})==0,'partial office drawing matched')end
print('PASS complete office source, native walking row, closed roof/equipment and bounded UVs')
