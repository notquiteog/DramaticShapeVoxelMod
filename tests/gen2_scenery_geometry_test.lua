-- GPU-free dimensions and ownership checks; run from the mod directory.
local Rocks=assert(loadfile("lib/Gen2Rocks.lua"))({})
local Ledges=assert(loadfile("lib/Gen2Ledges.lua"))()
local checks=0
local function check(v,msg)checks=checks+1;assert(v,msg)end
local function key(x,y)return (y+64)*4096+x+64 end
for _,size in ipairs({{7,4,6},{14,12,12},{28,24,25}}) do
  local qs=Rocks.geometry(size[1],size[2],size[3],function()return .5,.5 end)
  local top,base,edges=0,0,{}
  local function pos(p)
    local function n(v)return math.abs(v)<.000001 and 0 or v end
    return ("%.5f,%.5f,%.5f"):format(n(p[1]),n(p[2]),n(p[3]))
  end
  for _,q in ipairs(qs) do
    for i=1,4 do
      local p=q[i]
      assert(p[2]>=0 and p[2]<=size[2]+.00001)
      assert(math.abs(p[1])<=size[1]*.53 and math.abs(p[3])<=size[3]*.53)
      if p[2]==0 then base=base+1 end
      top=math.max(top,p[2])
      local a,b=pos(p),pos(q[i%4+1])
      if a~=b then
        local k=a<b and a.."|"..b or b.."|"..a
        edges[k]=(edges[k] or 0)+1
      end
    end
  end
  check(math.abs(top-size[2])<.00001 and base>0,"rock must touch ground and have the requested height")
  for _,n in pairs(edges) do assert(n==2,"rock has an open seam or doubled edge")end
  check(true,"rock is a closed manifold")
end
local S={gen2=true,shapeAt={},tileAt={},skip={},ground={},objectQuads={}}
-- A southeast corner adjoining a south lip: the corner must occupy only
-- the east/south bands, with no cell-wide shelf and no internal side faces.
for x,t in ipairs({76,77}) do
  S.shapeAt[key(x-1,0)]={class="ledge",h=6}
  S.tileAt[key(x-1,0)]=t
end
Ledges.build(S,{tileset={id="TILESET_JOHTO",imageWidth=128,imageHeight=128}})
check(S.skip[key(0,0)] and S.skip[key(1,0)],"both the straight lip and its corner must be claimed")
check(S.ground[key(0,0)]==5 and S.ground[key(1,0)]==5,"lips reveal flat grass below")
local tops=0
local slopes=0
for _,q in ipairs(S.objectQuads) do
  local tile=math.floor(q.u*128/8)+math.floor(q.v*128/8)*16
  local isTop=tile==5
  if isTop then
    tops=tops+1
    if q[1][2]~=q[2][2] or q[1][2]~=q[3][2] then slopes=slopes+1 end
    local x,z=q[1][1]+.5,q[1][3]+.5
    assert(z>=5 or x>=13,"lip extends more than three pixels into the cell")
  end
end
check(tops==63,"corner should be a joined L, not a filled square")
check(slopes>0 and Ledges.height(4,5,{s=true})==0 and Ledges.height(4,8,{s=true})==6,
  "mound slopes to grass but retains the dirt-side crest")
for z=0,8 do
 assert(Ledges.height(8,z,{s=true})==Ledges.height(0,z,{s=true,e=true}),"ledge corner seam")
end
print(checks.." Gen 2 scenery geometry checks passed")
-- The coastal apron must not infer an ocean underneath a land rock merely
-- because one nearby cell is water. Ground comes from actual flat neighbours.
package.loaded['src.world.gen2.Permissions']={LAND=0,of=function(c)return c end,isWater=function(c)return c==1 end}
local map={tileset={id='TILESET_JOHTO'},cellCollision=function(_,x,y)return x==-1 and 1 or 0 end,
 tileAt=function(_,x)return x<0 and 20 or 6 end}
local ground,wet=Rocks.ground(map,0,0,1)
assert(ground==6 and not wet,'nearby water flooded a land rock')
map.cellCollision=function()return 1 end;map.tileAt=function()return 20 end
local ground,wet=Rocks.ground(map,0,0,2);assert(ground==20 and wet,'sea rock lost ocean ground')
local seen={}
for y=0,9 do for x=0,9 do
 local l=Rocks.shoreLayout(x,y);seen[l.seed]=true
 assert(l.width<8 and l.depth<8 and l.height>=2 and l.height<4.7)
 assert(math.abs(l.x)+l.width*.5<=4 and math.abs(l.z)+l.depth*.5<=4,'shore rock escapes collision tile')
end end
local n=0;for _ in pairs(seen) do n=n+1 end;assert(n>20,'shore repeats a small regular pattern')
print('land/coast ground continuity and varied bounded shoreline rock layouts passed')
local reef=assert(loadfile('lib/Gen2Rocks.lua'))({})
local counts={}
for y=0,12 do for x=0,12 do
 local layout=reef.shoreClusterLayout(x,y);counts[#layout]=true
 assert(#layout>=3 and #layout<=4)
 for _,s in ipairs(layout) do
  for _,q in ipairs(reef.geometry(s.width,s.height,s.depth,function()return 0,0 end,s.seed)) do
   for i=1,4 do
    assert(math.abs(q[i][1]+s.x)<=8 and math.abs(q[i][3]+s.z)<=8,'reef escapes collision footprint')
    assert(q[i][2]>=0 and q[i][2]<4.3,'reef too tall')
   end
  end
 end
end end
assert(counts[3] and counts[4],'reef repeats identical count')
print('unequal reef clusters stay short and inside their full collision cell')
