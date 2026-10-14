-- Hoenn sea rocks: complete blocked 2x2 drawings only, closed hull inside the footprint.
local version='emerald'
package.loaded['src.core.GameVersion']={get=function()return version end,generation=function()return 3 end}
local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local S=V.require('Gen3SeaRocks')
local checks=0
local function check(c,m)assert(c,m);checks=checks+1 end
-- Synthetic atlas: water slot 0, four rock slots. Rock is a brown disc with
-- a 1px pale-blue foam line crossing the water; the line must not be hulled.
local mids={0x170,0x175,0x176,0x17d,0x17e}
local slot={};for i,m in ipairs(mids)do slot[m]=i-1 end
local function colour(m,x,y)
 if m==0x170 then return .32,.42,.84,1 end
 local quad={[0x175]={0,0},[0x176]={16,0},[0x17d]={0,16},[0x17e]={16,16}}
 local gx,gy=quad[m][1]+x,quad[m][2]+y
 if gy==3 then return .6,.7,.95,1 end -- thin foam line
 if (gx-15.5)^2+(gy-17)^2<11^2 then return .55,.36,.3,1 end
 return .32,.42,.84,1
end
local img={getPixel=function(_,px,py)local s=math.floor(px/16);return colour(mids[s+1],px%16,py%16)end}
local ts={midToSlot=slot,cols=8,rows=1,imageData=img}
local function cells(collision)
 local out={}
 for y=-1,2 do for x=-1,2 do
  local mid=0x170
  if x>=0 and x<=1 and y>=0 and y<=1 then mid=({{0x175,0x176},{0x17d,0x17e}})[y+1][x+1] end
  out[x..':'..y]={cx=x,cy=y,mid=mid,pair='general__pacifidlog',primary='general',ts=ts,
   collision=mid==0x170 and 0 or collision(x,y),shape={kind=mid==0x170 and 'water' or 'flat'}}
 end end
 return out
end
local c=cells(function()return 7 end)
check(S.prepare(c)==1,'complete blocked stack claimed')
check(c['0:0'].shape.root and not c['1:1'].shape.root,'one hull root per group')
check(c['1:1'].shape.kind=='rock' and c['1:1'].shape.ground==0x170,'native water underlay')
local uvFor=function(t,m)local s=t.midToSlot[m];local l=s/8;return {{l,0},{l+1/8,0},{l+1/8,1},{l,1}}end
local n,minX,maxX,minZ,maxZ,top=0,1e9,-1e9,1e9,-1e9,0
S.append(c['0:0'],function(v)n=n+1;for _,p in ipairs(v)do
 minX,maxX=math.min(minX,p[1]),math.max(maxX,p[1]);minZ,maxZ=math.min(minZ,p[3]),math.max(maxZ,p[3]);top=math.max(top,p[2])
end end,uvFor)
check(n>20,'hull emitted')
check(minX>=0 and maxX<=32 and minZ>=0 and maxZ<=32,'hull stays inside the blocked 2x2 footprint')
check(top<=30.01 and top>20,'stack height')
check(minZ>4,'thin foam line excluded from the solid')
local d=cells(function(x,y)return (x==1 and y==0) and 0x18 or 7 end)
check(S.prepare(d)==0 and d['0:0'].shape.kind=='flat','walkable cell rejects the whole group')
local e=cells(function()return 7 end);e['1:1'].mid=0x170
check(S.prepare(e)==0,'partial drawing rejected')
version='firered'
check(S.prepare(cells(function()return 7 end))==0,'Kanto IDs never claimed')
print(('PASS %d Hoenn sea-rock checks'):format(checks))
