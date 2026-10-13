local version='emerald'
package.loaded['src.core.GameVersion']={get=function()return version end,generation=function()return 3 end}
local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local C,H=V.require('Gen3Civic'),V.require('Gen3Hoenn')
for _,game in ipairs{'emerald','ruby','sapphire'}do
 version=game;local r;for _,q in ipairs(H.exteriorRecipes())do if q.name=='slateport_shipyard'then r=q end end;assert(r)
 local function fixture()
  local c={};for y,row in ipairs(r.rows)do assert(#row==8);for x,mid in ipairs(row)do c[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,pair=r.pair,primary='general',collision=(y==1 or y==6 and x==3) and 0 or y==7 and x==3 and 113 or 7,ts={}}end end;return c
 end
 local c=fixture();local g=C.prepare(c,{}, {r})[1];assert(g and g.bodyBack==18)
 local n,soffit=0,false
 C.append(g,function(v,uv)
  n=n+1;local lo,hi,l,r,b,f=math.huge,-math.huge,math.huge,-math.huge,math.huge,-math.huge
  for i,q in ipairs(v)do assert(q[1]>=0 and q[1]<=128 and q[3]>=16 and q[3]<=112);assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1);lo=math.min(lo,q[2]);hi=math.max(hi,q[2]);l=math.min(l,q[1]);r=math.max(r,q[1]);b=math.min(b,q[3]);f=math.max(f,q[3])end
  if lo<16 and hi>1.5 then assert(not(l<44 and r>36 and b<92 and f>84),'walkable inner entrance obstructed');assert(b>=17.5,'rear walking row obstructed')end
  soffit=soffit or lo==40 and hi==40
 end)
 assert(n>45 and soffit)
 local d=C.doorSurface(g,2,6);assert(d and d.w==16 and d.vertices[1][2]==24 and d.vertices[1][3]==110.05)
 c=fixture();c['3:3'].mid=0;assert(#C.prepare(c,{}, {r})==0,'incomplete source consumed')
end
print('PASS shipyard source match, rear/inner walking cells, closed roof and native door alignment across RSE')
