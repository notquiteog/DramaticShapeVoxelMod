package.loaded['src.core.GameVersion']={get=function()return 'firered' end,generation=function()return 3 end}
local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local C=V.require('Gen3Civic');local r
for _,q in ipairs(dofile('data/gen3_exteriors.lua'))do if q.name=='silph_co' then r=q end end
assert(r and r.header==15)
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
  assert(q[1]>=0 and q[1]<=144 and q[3]>=16 and q[3]<=240,'Silph rear/facade bounds')
  if q[2]<16 then assert(q[3]>=17.5,'Silph rear walking strip blocked')end
  lo=math.min(lo,q[2]);hi=math.max(hi,q[2])
  assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1,'Silph invalid native UV')
 end
 soffit=soffit or lo==159 and hi==159
end)
assert(count>500 and soffit,'Silph closed roof missing')
local d=C.doorSurface(list[1],4,14);assert(d and d.w==16 and d.vertices[1][2]==20 and d.vertices[1][3]==238.05)
for _,q in ipairs{{4,4},{4,13},{7,10}}do local cells=fixture();cells[q[1]..':'..q[2]].mid=0;assert(#C.prepare(cells,{}, {r})==0,'partial Silph source matched')end
print('PASS complete Silph source, bounded rear walking row, closed roof, native UVs and recessed animated door')
