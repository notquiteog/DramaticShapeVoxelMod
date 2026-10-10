local recipe
for _,r in ipairs(dofile('data/gen3_exteriors.lua'))do if r.geometry=='cinnabar_mansion'then recipe=r end end
assert(recipe)
local C=assert(loadfile('lib/Gen3Civic.lua'))({require=function(n)
 if n=='BuildBudget'then return {tick=function()end,check=function()end}end
 if n=='ArchitecturalDetails'then return dofile('lib/ArchitecturalDetails.lua')end
 if n=='Gen3CinnabarMansion'then return dofile('lib/Gen3CinnabarMansion.lua')end
 if n=='Gen3Hoenn'then return {active=function()return false end}end
 error(n)
end})
local cells={}
for iy,row in ipairs(recipe.rows)do for ix,mid in ipairs(row)do
 local x,y=ix-1,iy-1;cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=recipe.pair,primary='general',collision=7,shape={kind='flat'},ts={}}
end end
local list=C.prepare(cells,{}, {recipe});assert(#list==1);local g=list[1];local faces=0
C.append(g,function(v,uv)
 faces=faces+1;local low,high,back,front=math.huge,-math.huge,math.huge,-math.huge
 for i,q in ipairs(v)do
  assert(q[1]>=0 and q[1]<=112 and q[2]>=0 and q[2]<=102 and q[3]>=0 and q[3]<=64.1)
  assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1)
  low=math.min(low,q[2]);high=math.max(high,q[2]);back=math.min(back,q[3]);front=math.max(front,q[3])
 end
 if low<16 and high>1.5 then assert(back>=0 and front<=64.1,'laboratory blocks native walking rows')end
end)
assert(faces>170)
local door=assert(C.doorSurface(g,3,3));assert(door.w==16 and door.h==10 and door.vertices[1][2]==22.5)
assert(door.vertices[1][3]==51.05,'door not aligned with entrance recess')
for _,c in pairs(cells)do c.civic=nil end
cells['4:2'].mid=1;assert(#C.prepare(cells,{}, {recipe})==0,'partial mansion claimed')
print('Cinnabar mansion: complete drawing, bounded dormers/canopy and aligned recessed door PASS')
