local edition='firered'
package.loaded['src.core.GameVersion']={get=function()return edition end}
local cache={BuildBudget={tick=function()end,check=function()end}};local V={}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
function V.data(n)return dofile('data/'..n..'.lua')end
local C=V.require('Gen3Civic')
local fr;for _,r in ipairs(V.data('gen3_exteriors'))do if r.store=='celadon'then fr=r end end
local function fixture(r,cx,cy)
 local cells={};cx,cy=cx or 0,cy or 0
 local ts={cols=16,midToSlot={},imageData={getPixel=function(_,x,y)return x/500,y/500,.4,1 end}}
 local slot=0
 for iy,row in ipairs(r.rows)do for ix,mid in ipairs(row)do
  if not ts.midToSlot[mid]then ts.midToSlot[mid]=slot;slot=slot+1 end
  local x,y=cx+ix-1,cy+iy-1
  cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=r.pair,primary='general',collision=iy<=r.blockedStart and 0 or 7,shape={kind='flat'},ts=ts}
 end end
 for _,o in ipairs(r.openings)do local x,y=cx+math.floor(o[1]/16),cy+#r.rows-1;cells[x..':'..y].collision=0x71 end
 local ground=r.store=='celadon'and 0x167 or 0x233
 cells[(cx+4)..':'..(cy+#r.rows)]={cx=cx+4,cy=cy+#r.rows,pair=r.pair,mid=ground,collision=0,shape={kind='flat'}}
 return cells,ts,ground
end
local function pointKey(p)return ('%.6f/%.6f/%.6f'):format(unpack(p))end
for _,ed in ipairs{'firered','leafgreen','emerald','ruby','sapphire'}do
 edition=ed
 local r=fr
 if ed~='firered'and ed~='leafgreen'then
  for _,a in ipairs(V.require('Gen3Hoenn').exteriorRecipes())do if a.store=='lilycove'then r=a end end
  assert(r.store=='lilycove');assert((r.squareWindows==true)==(ed~='emerald'))
 end
 local cells,ts,ground=fixture(r,10,12);local gs=C.prepare(cells,{},V.data('gen3_exteriors'))
 assert(#gs==1,ed..' source recipe missing');local g=gs[1];local p=C.profile(g)
 assert(C.ground(cells['14:12'])==ground,'reviewed local paving was replaced by grass')
 local count,glazing,frontGlass=0,0,0;local caps={};local edges={};local top=r.store=='celadon'and 98 or 113.2
 C.append(g,function(v,t,s)
  count=count+1;local lo,hi=math.huge,-math.huge
  local capTexture=false
  if r.store=='celadon'then capTexture=math.abs(t[1][1]-2.5/292)<1e-8 and math.abs(t[1][2]-68.5/160)<1e-8
  else capTexture=(math.abs(t[1][1]-19.5/292)<1e-8 and math.abs(t[1][2]-18.5/112)<1e-8)or(math.abs(t[1][1]-27.5/292)<1e-8 and math.abs(t[1][2]-35.5/112)<1e-8)end
  for i,q in ipairs(v)do
   assert(q[1]>160 and q[1]<160+p.w and q[3]>192+r.blockedStart*16 and q[3]<192+p.h,'model crossed its native solid bounds')
   assert(q[2]>=0 and q[2]<=p.wall+16,'unbounded store height')
   assert(t[i][1]>=0 and t[i][1]<=1 and t[i][2]>=0 and t[i][2]<=1,'UV outside native material')
   lo=math.min(lo,q[2]);hi=math.max(hi,q[2])
  end
  if s==64.92 then glazing=glazing+1;if v[1][3]>192+p.h-3 and v[1][3]==v[3][3]then frontGlass=frontGlass+1 end end
  if lo>=p.wall and hi<=top and capTexture and (hi>p.wall or pointKey(v[1])==pointKey(v[4])) then
   caps[#caps+1]=v
   for i,q in ipairs(v)do local a,b=pointKey(q),pointKey(v[i%4+1]);if a~=b then if a>b then a,b=b,a end;edges[a..':'..b]=(edges[a..':'..b]or 0)+1 end end
  end
  -- No opaque, coplanar front rectangle may cover an animated door.
  for _,o in ipairs(r.openings)do
   local xx,yy=160+(o[1]+o[3])/2,8;local z=192+p.h-1
   if s~=64.92 and v[1][3]==z and v[3][3]==z then
    local l,rr,b,h=math.huge,-math.huge,math.huge,-math.huge
    for _,q in ipairs(v)do l=math.min(l,q[1]);rr=math.max(rr,q[1]);b=math.min(b,q[2]);h=math.max(h,q[2])end
    assert(not(l<xx and rr>xx and b<yy and h>yy),'door covered by facade')
   end
  end
 end)
 assert(count>300 and glazing>30 and frontGlass>10,'missing surround architecture/glazing')
 assert(#caps==24,ed..' closed roof slab incomplete: '..#caps);for _,n in pairs(edges)do assert(n==2,'open roof edge')end
 for _,o in ipairs(r.openings)do
  local d=assert(C.doorSurface(g,10+math.floor(o[1]/16),12+#r.rows-1))
  assert(d.vertices[1][2]==16 and d.vertices[3][2]==0 and d.vertices[1][3]==192+p.h-1.95,'native animation aperture mismatch')
 end
 for _,n in pairs(cells)do n.civic=nil end
 cells['11:14'].collision=0;assert(#C.prepare(cells,{},V.data('gen3_exteriors'))==0,'third-party walking lane consumed')
 cells['11:14'].collision=7;cells['12:14'].mid=0x3ff;assert(#C.prepare(cells,{},V.data('gen3_exteriors'))==0,'incomplete native drawing consumed')
end
print('PASS five-edition department-store matching, native doors, local ground, tile bounds, surround glazing and manifold roof caps')
-- Material regression: moved artwork survives in the second native atlas
-- half, while its old facade projection becomes the reviewed blank cladding.
local function data(w,h)
 local d={pixels={}}
 function d:getDimensions()return w,h end
 function d:setPixel(x,y,r,g,b,a)self.pixels[y*w+x]={r,g,b,a}end
 function d:getPixel(x,y)return unpack(self.pixels[y*w+x]or{0,0,0,0})end
 function d:release()end
 return d
end
love={image={newImageData=data},graphics={newImage=function(d)return{data=d,setFilter=function()end}end}}
edition='emerald'
local r;for _,a in ipairs(V.require('Gen3Hoenn').exteriorRecipes())do if a.store=='lilycove'then r=a end end
local cells,ts=fixture(r);local g=C.prepare(cells,{}, {})[1]
local image=C.material(g);local atlas=image.data
local function original(x,y)
 local mid=g.rows[math.floor(y/16)+1][math.floor(x/16)+1];local slot=ts.midToSlot[mid]
 return {ts.imageData:getPixel(slot%ts.cols*16+x%16,math.floor(slot/ts.cols)*16+y%16)}
end
for _,p in ipairs(r.facadePatches)do for y=p[2],p[2]+p[4]-1 do for x=p[1],p[1]+p[3]-1 do
 local actual={atlas:getPixel(x,y)};local blank=original(16+x%16,16+y%16)
 local raised={atlas:getPixel(144+x,y)};local source=original(x,y)
 for k=1,4 do assert(actual[k]==blank[k],'duplicate artwork remained on front facade');assert(raised[k]==source[k],'raised native artwork was erased')end
end end end
print('PASS facade repair preserves original plaque/awning pixels in the separate native material half')
