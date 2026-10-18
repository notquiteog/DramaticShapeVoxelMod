local V={};local modules={}
function V.require(n)if not modules[n]then modules[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return modules[n]end
local K=V.require('Gen3KantoHomes');local F=V.require('Gen3Furniture')
local d={width=3,height=4};local mids={{0x20,0x21,0x22},{0x28,0x29,0x2a},{1,1,1},{1,1,1}}
local opened=false
d.midLayout={midAt=function(_,x,y)return mids[y+1][x+1]end,collAt=function(_,x,y)return opened and x==1 and y==0 and 0 or y<2 and 7 or 0 end}
assert(K.profile(d,'house').north<19)
opened=true;assert(not K.profile(d,'house'),'custom walkable header must keep its renderer');opened=false
mids[1][1]=0x777;assert(not K.profile(d,'house'),'unknown custom header claimed');mids[1][1]=0x20
assert(not K.profile(d,'unrelated'))
local tested=0
for _,r in ipairs(K.recipes)do
 local cells={}
 for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,collision=r.collisionRows[y][x],pair=r.pair,primary='building',secondary='',ts={}}end end
 local props=F.extract(cells);assert(#props==1 and props[1].recipe==r,r.name..' ownership')
 local p=props[1];p.homeWall=15.84
 if r.kind~='plant'then F.append(p,function(v)
  K.attach(p,v)
  for _,q in ipairs(v)do
   assert(q[1]>=0 and q[1]<=p.w and q[3]>=0 and q[3]<=p.d,r.name..' outside source extent')
   if r.walkablePad then assert(q[2]<1,r.name..' blocks a walking lane')
   elseif q[2]>1.3 then
    local col=r.collisionRows[math.min(#r.rows,math.floor(q[3]/16)+1)][math.min(#r.rows[1],math.floor(q[1]/16)+1)]
    assert(col~=0,r.name..' blocks native walking row')
   end
  end
 end,function()return{{0,0},{1,0},{1,1},{0,1}}end)end
 local c=cells['0:0'];c.collision=c.collision==0 and 7 or 0;c.prop=nil
 for _,n in pairs(cells)do n.prop=nil end
 for _,p in ipairs(F.extract(cells))do assert(p.recipe~=r,r.name..' claimed changed permission')end
 tested=tested+1
end
-- A generic native drawing with a new walking lane must not become an
-- elevated tabletop simply because its metatile IDs match a known house.
local cells={};for y,row in ipairs{{0x4c,0x4d},{0x54,0x55}}do for x,mid in ipairs(row)do cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,pair='house',primary='building',collision=x==1 and y==1 and 0 or 7,ts={}}end end
assert(#F.extract(cells)==0,'changed table collision was ignored')
local St=V.require('Gen3HouseStairs');local count=0
for _,down in ipairs{false,true}do
 local g={cx=0,cy=0,homeWall=18.84,ts={},r={down=down,rows={{1,1,1},{1,1,1},{1,1,1}}}}
 St.append(g,function(v)for _,q in ipairs(v)do if q[2]>1.3 or q[2]<-.1 then assert(q[3]>=16 and q[3]<=32,'stair solid crosses a walking row')end end;count=count+1 end,function()return{{0,0},{1,0},{1,1},{0,1}}end)
end
assert(count>100)
print('PASS '..tested..' Kanto recipes, native walking permissions, low seats, flat-header fallback and stair footprints')
