local version='firered';local V,cache={},{}
package.loaded['src.core.GameVersion']={get=function()return version end,generation=function()return 3 end}
function V.data(n)return dofile('data/'..n..'.lua')end
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local C=V.require('Gen3Civic');local total=0
for _,edition in ipairs{'firered','leafgreen','emerald','ruby','sapphire'}do
 version=edition
 local recipes=edition=='firered'or edition=='leafgreen'
 recipes=recipes and V.data('gen3_exteriors')or V.require('Gen3Hoenn').exteriorRecipes()
 for _,r in ipairs(recipes)do if r.geometry=='landmark'then
  total=total+1;local cells={};local ox,oy=20,18
  local function fixture()
   cells={}
   for iy,row in ipairs(r.rows)do for ix,mid in ipairs(row)do
    local x,y=ox+ix-1,oy+iy-1
    cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=r.pair,primary='general',collision=r.permissions[iy][ix],shape={kind='flat'},ts={}}
   end end
   return cells
  end
  local list=C.prepare(fixture(),{},recipes);assert(#list==1,r.name..' did not translate')
  local g=list[1];local faces,panes,bottoms=0,0,0
  local minx,minz,maxx,maxz=ox*16,oy*16,(ox+#r.rows[1])*16,(oy+#r.rows)*16
  C.append(g,function(v,uv)
   faces=faces+1;local l,n,b,rr,f,t=math.huge,math.huge,math.huge,-math.huge,-math.huge,-math.huge
   for i,q in ipairs(v)do
    assert(q[1]>=minx and q[1]<=maxx and q[3]>=minz and q[3]<=maxz,'landmark exceeds native footprint')
    assert(q[2]>=0 and q[2]<130,'invalid landmark height')
    assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1,'invalid native UV')
    l=math.min(l,q[1]);rr=math.max(rr,q[1]);n=math.min(n,q[3]);f=math.max(f,q[3]);b=math.min(b,q[2]);t=math.max(t,q[2])
   end
   if b==0 and t==0 then bottoms=bottoms+1 end
   for _,o in ipairs(r.openings)do
    local front=minz+(r.landmark=='museum'and 95 or #r.rows*16-1)
    local dh=r.landmark=='rs_devon'and 28 or r.landmark=='museum'and 24 or 16
    local center=minx+(o[1]+o[3])/2
    if l<center+2 and rr>center-2 and b<dh-3 and t>.1 and f>front-1.05 then
     assert(math.abs(f-n)>.01 or rr-l<.01,'opaque face across native portal '..r.name)
    end
   end
   -- All heights, including eaves: a thin projected roof still must not
   -- occupy even the edge of a native walkable source cell.
   for _,cell in pairs(cells)do if cell.collision==0 then
    local x,z=cell.cx*16,cell.cy*16
    assert(not(l<x+16-.01 and rr>x+.01 and n<z+16-.01 and f>z+.01),r.name..' overlaps walking cell '..cell.cx..':'..cell.cy)
   end end
   if t>b and math.abs(f-n)<.01 and r.landmark~='museum'and math.abs(f-(maxz-2.1))<.02 then panes=panes+1 end
  end)
  assert(faces>150 and bottoms>=1,'incomplete shell '..r.name)
  if r.landmark~='museum'then assert(panes>=1,'no recessed door '..r.name)end
  for _,o in ipairs(r.openings)do
   local door=assert(C.doorSurface(g,ox+math.floor(o[1]/16),oy+math.floor(o[2]/16)))
   assert(door.sourceX==minx+o[1]and door.sourceY==minz+o[2],'native door source moved')
   local expected=r.landmark=='museum'and minz+93.9 or maxz-2.1
   assert(math.abs(door.vertices[1][3]-expected)<.001,'animated door floats off inset')
  end
  if r.landmark=='museum'then
   for _,q in ipairs{{4,6},{5,6}}do local cell=cells[(ox+q[1])..':'..(oy+q[2])];assert(C.ground(cell)==cell.mid,'museum stair landing lost its native floor')end
  end
  if r.claimRanges then
   for _,cell in pairs(cells)do local range=r.claimRanges[cell.cy-oy+1];local xx=cell.cx-ox
    local extra=false;for _,q in ipairs(r.claimExtras or {})do if xx==q[1]and cell.cy-oy==q[2]then extra=true end end
    assert((cell.civic~=nil)==(extra or xx>=range[1]and xx<=range[2]),'landscaping source claimed')
   end
  end
  -- Identical source art is not sufficient when native permissions change.
  fixture();cells[(ox+3)..':'..(oy+3)].collision=0
  assert(#C.prepare(cells,{},recipes)==0,'third-party walking lane gained solid geometry')
  fixture();cells[(ox+3)..':'..(oy+3)].mid=0x7fff
  assert(#C.prepare(cells,{},recipes)==0,'partial landmark art claimed')
 end end
end
assert(total==9,'expected two League, three museums, two Devon and two Space Center placements')
print('Nine edition landmarks: translated matching, exact native permissions, HD-2D landscaping exclusions, closed shells, recessed doors, all-height walkable bounds and UVs PASS')
