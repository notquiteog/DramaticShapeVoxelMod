local edition='firered';local V,cache={},{}
package.loaded['src.core.GameVersion']={get=function()return edition end,generation=function()return 3 end}
function V.data(n)return dofile('data/'..n..'.lua')end
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local T=V.require('Gen3TowerInteriors');local F=V.require('Gen3Furniture');local count=0
for _,ed in ipairs{'firered','leafgreen','emerald','ruby','sapphire'}do edition=ed
 for _,r in ipairs(T.recipes)do
  local active=(ed=='firered'or ed=='leafgreen')and not r.family or ed=='emerald'and r.edition=='emerald'or(ed=='ruby'or ed=='sapphire')and r.edition=='rs'
  if active then
   local cells={};local function fixture()
    cells={};for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
     local coll=r.collisionRows and r.collisionRows[y][x]or 7
     cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,collision=coll,primary='building',secondary=r.pair:match('__(.+)'),pair=r.pair,ts={}}
    end end;return F.extract(cells)
   end
   local p;for _,q in ipairs(fixture())do if q.recipe==r then p=q end end
   assert(p,'complete tower drawing not recognized: '..r.name..'/'..ed)
   local faces,bottoms=0,0
   F.append(p,function(v,uv)
    faces=faces+1;local l,n,rr,f,b,h=1e9,1e9,-1e9,-1e9,1e9,-1e9
    for i,q in ipairs(v)do
     assert(q[1]>=0 and q[1]<=p.w and q[3]>=0 and q[3]<=p.d,r.name..' exceeds source bounds')
     assert(q[2]>=(r.down and -25 or 0)and q[2]<=32,r.name..' height')
     assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1,'native UV exceeds atlas')
     l=math.min(l,q[1]);rr=math.max(rr,q[1]);n=math.min(n,q[3]);f=math.max(f,q[3]);b=math.min(b,q[2]);h=math.max(h,q[2])
    end
    if b==h then bottoms=bottoms+1 end
    for _,c in pairs(cells)do if c.collision==0 and not(b==0 and h==0)then
     assert(not(l<c.cx*16+15.99 and rr>c.cx*16+.01 and n<c.cy*16+15.99 and f>c.cy*16+.01),r.name..' blocks native walking cell')
    end end
   end,function()return{{0,0},{1,0},{1,1},{0,1}}end)
   assert(faces>=6 and bottoms>=1,'incomplete closed model '..r.name)
   if r.kind=='towerStairs'then
    fixture();for _,c in pairs(cells)do c.prop=nil end
    local flights=F.extract(cells,'towerStairs');assert(#flights==1,'specific flight preclaim failed')
    V.require('Gen3Stairs').prepare(cells)
    for _,c in pairs(cells)do if c.prop==flights[1]then assert(not c.stairs,'generic stair claimed authored flight')end end
    for _,q in ipairs(fixture())do if q.recipe==r then p=q end end
   end
   if r.kind=='towerDoor'then
    local door=assert(T.doorSurface(p,1,1));assert(door.sourceX==16 and door.sourceY==0 and door.w==16 and door.h==32)
    assert(door.vertices[1][2]==26 and door.vertices[1][3]==30.7,'animated pane drifted')
    assert(not T.doorSurface(p,0,1),'adjacent source became animated door')
   end
   if r.claimCells then
    -- Earlier source rows may already own a screen/portal appearing only
    -- as match context. It must not prevent the later counter assembly.
    fixture();for _,c in pairs(cells)do if not r.claimCells[(c.cx+1)..':'..(c.cy+1)]then c.prop={context=true}else c.prop=nil end end
    local recognized=false;for _,q in ipairs(F.extract(cells))do if q.recipe==r then recognized=true end end
    assert(recognized,'preclaimed context prevents counter model')
    for _,q in ipairs(fixture())do if q.recipe==r then p=q end end
   end
   if r.claimCells then
    for _,c in pairs(cells)do assert((c.prop==p)==(r.claimCells[(c.cx+1)..':'..(c.cy+1)]==true),'drawing context stolen from another model')end
   end
   fixture();cells['0:0'].mid=0x7fff
   for _,q in ipairs(F.extract(cells))do assert(q.recipe~=r,'partial drawing matched')end
   if r.collisionRows then
    fixture();local c=cells['0:0'];c.prop=nil;c.collision=c.collision==0 and 7 or 0
    for _,q in ipairs(F.extract(cells))do assert(q.recipe~=r,'third-party permission mismatch still modeled')end
   end
   count=count+1
  end
 end
end
assert(count==49,'edition model inventory changed: '..count)
assert(T.shape('building','rom_082d5094',0x289,7).kind=='roomWall')
assert(T.shape('building','battle_tower',0x209,7).kind=='roomWall')
assert(not T.shape('building','battle_frontier',0x209,0),'walkable wall art gained geometry')
assert(T.shape('general','battle_tower',0x209,7)==nil)
assert(T.shape('building','other',0x209,7)==nil)
print('Five edition tower interior recipes: complete source/permissions, native walking and staff clearance, partial claims, closed shells, UVs and edition isolation PASS ('..count..' fixtures)')
