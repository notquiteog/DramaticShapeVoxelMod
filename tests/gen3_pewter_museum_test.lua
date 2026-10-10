package.loaded['src.core.GameVersion']={get=function()return 'firered' end,generation=function()return 3 end}
local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local C=V.require('Gen3Civic');local r
for _,q in ipairs(dofile('data/gen3_exteriors.lua'))do if q.name=='pewter_museum' then r=q end end
assert(r and r.header==#r.rows)
local function fixture()
 local cells={}
 for yy,row in ipairs(r.rows)do for xx,mid in ipairs(row)do
  local x,y=xx-1,yy-1
  cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=r.pair,primary='general',collision=(y==1 and x>=11 and x<=14) and 0 or 7,ts={}}
 end end
 return cells
end
local cells=fixture();local list=C.prepare(cells,{}, {r});assert(#list==1)
local claimed=0
for _,c in pairs(cells)do
 local span=r.claimRanges[c.cy+1];local expected=c.cx>=span[1] and c.cx<=span[2]
 assert((c.civic~=nil)==expected,'museum consumed surrounding native scenery')
 assert(c.mid==r.rows[c.cy+1][c.cx+1],'source ID mutated')
 if c.civic then claimed=claimed+1 end
end
assert(claimed==89)
local count=0
C.append(list[1],function(v,uv)
 count=count+1
 for i,q in ipairs(v)do
  assert(q[1]>=0 and q[1]<=256 and q[3]>=8 and q[3]<112,'museum escaped footprint')
  if q[2]<16 and q[1]>176 then assert(q[3]>=32 and q[3]<80,'wing blocks native roof walking strip')end
  if q[2]<16 and q[3]>=96 then assert(q[1]>=63.7 and q[1]<=112,'museum occupies hedge strip')end
  assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1)
 end
end)
assert(count>200)
for _,q in ipairs{{5,6,110.05},{13,4,78.05}}do
 local d=C.doorSurface(list[1],q[1],q[2]);assert(d and d.w==16 and d.h==16)
 assert(d.vertices[1][2]==24 and d.vertices[3][2]==0 and d.vertices[1][3]==q[3])
end
assert(not C.doorSurface(list[1],4,6))
for _,q in ipairs{{3,2},{11,0},{1,6}}do
 cells=fixture();cells[q[1]..':'..q[2]].mid=0
 assert(#C.prepare(cells,{}, {r})==0,'partial museum drawing matched')
end
print('PASS complete museum source, 89 bounded claims, native wing/rear lanes, scenery exclusion and both door planes')
