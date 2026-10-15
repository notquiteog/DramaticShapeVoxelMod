local edition='firered';local V,cache={},{}
package.loaded['src.core.GameVersion']={get=function()return edition end,generation=function()return 3 end}
function V.data(n)return dofile('data/'..n..'.lua')end
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local T=V.require('Gen3RSInstitutions');local F=V.require('Gen3Furniture');local count=0
for _,ed in ipairs{'ruby','sapphire'}do edition=ed
 for _,r in ipairs(T.recipes)do
  local active=r.edition=='rs'
  if active then
   local cells={};local function fixture()
    cells={};for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
     local coll=r.collisionRows and r.collisionRows[y][x]or 7
     cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,collision=coll,primary=r.primary,secondary=r.pair:match('__(.+)'),pair=r.pair,ts={}}
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
    for _,c in pairs(cells)do if c.collision==0 and not r.seat and not(b==0 and h==0)then
     assert(not(l<c.cx*16+15.99 and rr>c.cx*16+.01 and n<c.cy*16+15.99 and f>c.cy*16+.01),r.name..' blocks native walking cell')
    end end
   end,function()return{{0,0},{1,0},{1,1},{0,1}}end)
   assert(faces>=6 and bottoms>=1,'incomplete closed model '..r.name)
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
-- Wall seams must close at the native T-junction, while the staff/walk
-- clearance assertions above still reject a filler in any walking cell.
for _,r in ipairs(T.recipes)do
 if r.institutionDesign=='devon_wall_return' or r.name=='rs_institution_gallery_return_partition'then
  local p={recipe=r,cx=0,cy=0,w=#r.rows[1]*16,d=#r.rows*16,ts={}}
  local f=r.institutionDesign=='devon_wall_return'and 79.82 or 47.82;local upper,lower=false,false
  F.append(p,function(q)
   local l,rr,b,h=1e9,-1e9,1e9,-1e9;local plane=true
   for _,v in ipairs(q)do plane=plane and math.abs(v[3]-f)<.001;l=math.min(l,v[1]);rr=math.max(rr,v[1]);b=math.min(b,v[2]);h=math.max(h,v[2])end
   if plane and l==0 and rr==16 then
    if b<=0 and h>=16 then lower=true end
    if b<=16 and h>=32 then upper=true end
   end
  end,function()return{{0,0},{1,0},{1,1},{0,1}}end)
  assert(upper and lower,'gap at native wall junction: '..r.name)
 end
end
for _,ed in ipairs{'firered','leafgreen','emerald','ruby','sapphire'}do
 edition=ed
 assert(T.flatWalls('general__facility')==(ed=='ruby'or ed=='sapphire'))
 assert(not T.flatWalls('general__other'),'unrelated third-party atlas acquired wall planes')
end

assert(count==#T.recipes*2)
print('RS institution source/permission isolation, closed models, UVs and all-height walking clearance PASS ('..count..' fixtures)')
