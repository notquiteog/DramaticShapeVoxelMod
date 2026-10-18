local version='firered';package.loaded['src.core.GameVersion']={get=function()return version end}
local V,modules={},{}
function V.require(n)if not modules[n]then modules[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return modules[n]end
local Research=V.require('Gen3ResearchRooms');local F=V.require('Gen3Furniture')
local headers={oak_lab={0x29d,0x6d,0x6d,0x6e,0x69,0x69,0x28d,0x28d,0x98,0x6b,0x6c,0x6b,0x6c},
 ['building__lab']={0x210,0x211,0x208,0x212,0x213,0x208,0x208,0x209,0x209,0x208,0x208,0x208,0x208}}
package.loaded['src.import.gba.versions']={TILESET_PAIRS={oak_lab={primary='building',secondary='lab'}}}
local D=V.require('InteriorDiorama');local P=V.require('Gen3Tilesets')
for pair,header in pairs(headers)do
 local floor=pair=='oak_lab'and 0x289 or 0x202;local changed,opened=false,false
 local def={id='THIRD_PARTY_ROOM',mapType=8,width=13,height=8,warps={{x=6,y=7}},midLayout={pair=pair,
  midAt=function(_,x,y)return y==0 and(changed and x==3 and 0x777 or header[x+1])or floor end,
  collAt=function(_,x,y)return y<2 and not(opened and x==3 and y==0)and 7 or 0 end}}
 local room=assert(Research.profile(def,pair));assert(room.north<16)
 local p=assert(D.profile(def,3));assert(p.researchRoom and p.nativeWallFinish and p.noInteriorTrim and p.height==32)
 local north=p.bounds[2];D.setRecesses(p,{{16,32,1}});assert(p.bounds[2]==north,'furniture bent the wall')
 for side=1,4 do
  local vs=D.geometry(p,side,false);assert(#vs>0)
  for _,q in ipairs(vs)do
   if side==1 then assert(q[3]<=north,'trim projects through flat north wall')end
  end
 end
 changed=true;assert(not Research.profile(def,pair),'unknown header claimed');changed=false;opened=true
 assert(not Research.profile(def,pair),'new native walking lane enclosed');opened=false
 local alias='third_party_'..pair;assert(P.registerAlias(alias,pair));assert(Research.profile(def,P.canonical(alias)),'public tileset alias lost lab finish')
end
local tested=0
for _,r in ipairs(F.recipes)do if r.pair=='oak_lab'or r.secondary=='lab'or r.pair=='building__lab'then
 local pair=r.pair or'oak_lab';local permissions=Research.permissions(r,pair)
 if permissions then
  version=r.edition=='rs'and'ruby'or r.family=='rse'and'emerald'or'firered'
  local cells={}
  for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,collision=permissions[y][x],primary='building',pair=pair,secondary='lab',ts={}}end end
  local props=F.extract(cells);assert(#props==1 and props[1].recipe==r,r.name..' ownership')
  local p=props[1];p.researchWall=15.84
  if r.kind~='plant'then F.append(p,function(v)
   Research.attach(p,v)
   local l,n,rr,f,h=1e9,1e9,-1e9,-1e9,-1e9
   for _,q in ipairs(v)do
    assert(q[1]>=0 and q[1]<=p.w and q[3]>=0 and q[3]<=p.d,r.name..' escapes native extent')
    l=math.min(l,q[1]);rr=math.max(rr,q[1]);n=math.min(n,q[3]);f=math.max(f,q[3]);h=math.max(h,q[2])
   end
   if r.walkablePad then assert(h<1,'walkable seat became a solid backrest')
   elseif h>1.3 then
    for y=math.floor(n/16),math.min(#r.rows-1,math.floor(f/16))do for x=math.floor(l/16),math.min(#r.rows[1]-1,math.floor(rr/16))do
     assert(permissions[y+1][x+1]~=0 or l>=x*16+15.99 or rr<=x*16+.01 or n>=y*16+15.99 or f<=y*16+.01,r.name..' blocks native floor')
    end end
   end
  end,function()return{{0,0},{1,0},{1,1},{0,1}}end)end
  for _,c in pairs(cells)do c.prop=nil end
  cells['0:0'].collision=permissions[1][1]==0 and 7 or 0
  for _,p in ipairs(F.extract(cells))do assert(p.recipe~=r,r.name..' ignored changed native permissions')end
  tested=tested+1
 end
end end
assert(tested>=38)
print('PASS '..tested..' lab drawings, blocked footprints, attached notes, low seats, flat walls and custom-header/alias fallbacks')
-- Oak's native final row is black drawing padding around the mat footer.
-- It must neither enlarge the room nor erase a custom walkable extension.
local walkableFooter=false
local d={id='THIRD_PARTY_OAK_LAYOUT',mapType=8,width=13,height=14,warps={{x=6,y=12}},midLayout={pair='oak_lab',
 midAt=function(_,x,y)
  if y==0 then return headers.oak_lab[x+1]end
  if y==13 then return({[5]=0x298,[6]=0x299,[7]=0x29a})[x]or 8 end
  return 0x289
 end,
 collAt=function(_,x,y)if y<2 then return 7 end;if y==13 and not walkableFooter then return 7 end;return 0 end}}
local plan=assert(Research.profile(d,'oak_lab'));assert(plan.south==208,'black footer became an extra floor row')
local room=assert(D.forMap(d,3));assert(room.bounds[4]==208 and #room.doorways[3]==1,'native lab exit lost its boundary opening')
local b=room.bounds;plan.outline={{b[1],b[2]},{b[3],b[2]},{b[3],b[4]},{b[1],b[4]}}
local count=0;V.require('Gen3ServiceRooms').floor({cx=0,cy=13},plan,function()count=count+1 end,{{0,0},{1,0},{1,1},{0,1}})
assert(count==0,'padded footer emitted room floor')
V.require('Gen3ServiceRooms').floor({cx=0,cy=12},plan,function()count=count+1 end,{{0,0},{1,0},{1,1},{0,1}})
assert(count==2,'native south walking row lost its floor')
walkableFooter=true;assert(Research.profile(d,'oak_lab').south==224,'custom walkable extension was trimmed')
print('PASS Oak black-padding exclusion, full south floor, native exit opening and walkable extension fallback')

V.require('InteriorFurniture').draw('fr_lab_exit_mat',{sample=function()return{}end,box=function()end,source=function(x,y,w,h)assert(x>=11 and x+w<=37 and y>=4 and y+h<=20,'exit mat includes black source padding')end})
V.require('InteriorFurniture').draw('em_lab_wall_note',{sample=function()return{}end,box=function()end,source=function(x,y,w,h)
 assert(y>=7 and y+h<=16,'wall paper crop includes research desk pixels below it')
end})
print('PASS wall-note paper UVs exclude the separate desk drawing')
