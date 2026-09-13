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
for _,q in ipairs(S.objectQuads) do
  local isTop=true
  for i=1,4 do if q[i][2]~=6 then isTop=false end end
  if isTop then
    tops=tops+1
    local x,z=q[1][1]+.5,q[1][3]+.5
    assert(z>=5 or x>=13,"lip extends more than three pixels into the cell")
  end
end
check(tops==63,"corner should be a joined L, not a filled square")
print(checks.." Gen 2 scenery geometry checks passed")
