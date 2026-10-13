local version='emerald'
package.loaded['src.core.GameVersion']={get=function()return version end,generation=function()return 3 end}
local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local C,H=V.require('Gen3Civic'),V.require('Gen3Hoenn')
for _,game in ipairs{'emerald','ruby','sapphire'}do
 version=game;local r;for _,q in ipairs(H.exteriorRecipes())do if q.name=='slateport_oceanic_museum'then r=q end end
 assert(r and (r.squareRoofLights==true)==(game~='emerald'))
 local function fixture()
  local c={};for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do c[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,pair=r.pair,primary='general',collision=y==5 and (x==3 or x==4) and 113 or 7,ts={}}end end
  for x=0,5 do c[x..':5']={cx=x,cy=5,mid=0x330+x,pair=r.pair,primary='general',collision=0,ts={}}end
  return c
 end
 local c=fixture();local g=C.prepare(c,{}, {r})[1];assert(g)
 local n,soffit=0,false
 C.append(g,function(v,uv)
  n=n+1;local lo,hi=math.huge,-math.huge
  for i,q in ipairs(v)do assert(q[1]>=0 and q[1]<=96 and q[3]>=8 and q[3]<=80,'native steps/footprint obstructed');assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1,'UV bounds');lo=math.min(lo,q[2]);hi=math.max(hi,q[2])end
  soffit=soffit or lo==40 and hi==40
 end)
 assert(n>100 and soffit);assert(not c['2:5'].civic,'native steps claimed')
 for _,x in ipairs{2,3}do local d=C.doorSurface(g,x,4);assert(d and d.w==32 and d.vertices[1][2]==30 and d.vertices[1][3]==78.05)end
 c=fixture();c['3:2'].mid=0;assert(#C.prepare(c,{}, {r})==0,'partial museum matched')
end
print('PASS Oceanic Museum complete edition sources, steps preserved, closed roof and wide native entrance')
