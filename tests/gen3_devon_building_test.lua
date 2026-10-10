local Devon=dofile('lib/Gen3DevonBuilding.lua');local recipe
for _,r in ipairs(dofile('data/gen3_hoenn_exteriors.lua'))do if r.geometry=='devon'then recipe=r end end
assert(recipe and #recipe.rows==9)
local V={require=function(n)
 if n=='BuildBudget'then return {tick=function()end,check=function()end}end
 if n=='ArchitecturalDetails'then return dofile('lib/ArchitecturalDetails.lua')end
 if n=='Gen3DevonBuilding'then return Devon end
 if n=='Gen3Hoenn'then return {active=function()return true end,exteriors={recipe}}end
 error(n)
end}
local C=assert(loadfile('lib/Gen3Civic.lua'))(V)
local cells={}
for iy,row in ipairs(recipe.rows)do for ix,mid in ipairs(row)do
 local x,y=ix-1,iy-1
 cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=recipe.pair,primary='general',collision=iy==9 and (ix<=3 or ix>=8)and 0 or 7,shape={kind='flat'},ts={}}
end end
local list=C.prepare(cells,{},{});assert(#list==1);local g=list[1];local faces=0
C.append(g,function(v,uv)
 faces=faces+1
 local l,r,n,s,h,b=math.huge,-math.huge,math.huge,-math.huge,math.huge,-math.huge
 for i,q in ipairs(v)do
  l=math.min(l,q[1]);r=math.max(r,q[1]);n=math.min(n,q[3]);s=math.max(s,q[3]);h=math.min(h,q[2]);b=math.max(b,q[2])
  assert(q[1]>=0 and q[1]<=160 and q[2]>=0 and q[2]<125 and q[3]>=0 and q[3]<=145)
  assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1)
 end
 if h<16 and b>1.5 and (l<48 or r>112)then assert(s<=128,'Devon wings fill native front walking strip')end
end)
assert(faces>200)
for _,x in ipairs({0,1,2,7,8,9})do local c=cells[x..':8'];assert(C.ground(c)==c.mid,'native front pavement replaced');assert(c.collision==0)end
for _,x in ipairs({4,5})do
 local d=assert(C.doorSurface(g,x,8));assert(d.w==16 and d.h==24 and d.vertices[1][2]==28 and d.vertices[1][3]==142.05)
end
assert(not C.doorSurface(g,3,8))
for _,c in pairs(cells)do c.civic=nil end
cells['3:4'].mid=1;assert(#C.prepare(cells,{}, {})==0,'partial Devon drawing claimed')
print('Devon complete pattern, native pavement, front walking strips, dual doorway and volume bounds: PASS')
