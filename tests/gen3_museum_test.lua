-- Architectural/material and retaining-terrace contracts, independent of ROM art.
local V,cache={},{}
package.loaded['src.core.GameVersion']={get=function()return'emerald'end}
function V.data(n)return dofile('data/'..n..'.lua')end
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local Museum=V.require('Gen3Museum');local Civic=V.require('Gen3Civic');local Terrain=V.require('Gen3Terrain')
local recipe
for _,r in ipairs(V.data('gen3_hoenn_exteriors'))do if r.landmark=='museum'then recipe=r end end
assert(recipe)
local function fixture(changed)
 local cells={};local g={cx=7,cy=0,width=10,depth=7,pair=recipe.pair,groundHeight=12}
 for y=0,11 do for x=4,20 do cells[x..':'..y]={cx=x,cy=y,mid=1,collision=0,pair=g.pair,shape={kind='flat'},base=12}end end
 for iy,row in ipairs(recipe.rows)do for ix,mid in ipairs(row)do
  local c=cells[(ix+6)..':'..(iy-1)];c.mid=mid;c.collision=recipe.permissions[iy][ix]
 end end
 local apron={{0x7c,0x79,0x79,0x219,0x21a,0x21b,0x21c,0x79,0x79,0x79},
  {0x89,0x23b,0x23b,0x221,0x222,0x223,0x224,0x22b,0x23b,0x23b}}
 for y,row in ipairs(apron)do for x,mid in ipairs(row)do local c=cells[(x+6)..':'..(y+6)];c.mid=mid
  c.collision=(y==1 and x~=5 and x~=6 or y==2 and(x==1 or x==4 or x==7))and 7 or 0
  if mid<0x200 then c.shape={kind='cliff',height=24}end
 end end
 local perimeter={{-2,1,0x68},{11,1,0x6a},{-2,7,0x78},{-1,7,0x7c},{10,7,0x79},{11,7,0x7a}}
 for y=2,6 do perimeter[#perimeter+1]={-2,y,0x70};perimeter[#perimeter+1]={11,y,0x72}end
 for _,p in ipairs(perimeter)do local c=cells[(g.cx+p[1])..':'..(g.cy+p[2])];c.mid=p[3];c.collision=7 end
 if changed=='art'then cells['10:8'].mid=1 elseif changed=='permission'then cells['10:8'].collision=0 elseif changed=='pair'then cells['10:8'].pair='general__third_party'end
 Museum.prepare(cells,g);return cells,g
end
for _,mutation in ipairs{'art','permission','pair'}do
 local cells=fixture(mutation);assert(not cells['9:7'].museumTerrace,'incomplete/changed native apron received terrace override')
 assert(Terrain.height(cells,152,120,24)==36,'unmatched cliff height changed')
end
local cells,g=fixture();assert(cells['9:7'].museumTerrace==g)
assert(Terrain.height(cells,152,120,24)==12,'museum retaining edge rises above landing')
assert(not cells['7:7'].museumTerrace and cells['11:7'].collision==0,'neighboring cliff or walking permission changed')
-- The authored atlas must work without native imageData, including on a
-- third-party exact recipe reuse. No source façade or downloaded art is read.
local pixels={};local w,h,released,filtered
love={image={newImageData=function(a,b)
 w,h=a,b;return{setPixel=function(_,x,y,r,g,b,a)
  assert(x>=0 and x<w and y>=0 and y<h and a==1);pixels[y*w+x]={r,g,b,a}
 end,release=function()released=true end}
end},graphics={newImage=function()return{setFilter=function(_,a,b)filtered=a=='nearest'and b=='nearest'end}end}}
local image,glow,reader=Museum.material(g)
assert(image and not glow and not reader and released and filtered)
assert(w==324 and h==112 and #pixels==w*h-1,'material atlas incomplete')
local white,blue,gold=pixels[12*w+108],pixels[12*w+80],pixels[12*w+140]
assert(white[1]>.9 and blue[3]>blue[1] and gold[1]>gold[3],'architectural materials lost their palette')
assert(pixels[2*w+80][2]>pixels[27*w+80][2],'glass has no vertical depth gradient')
print('Museum authored materials, exact apron guard, retaining height and unchanged walking/native cliff contracts PASS')
