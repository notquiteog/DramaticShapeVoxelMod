local recipe
for _,r in ipairs(dofile('data/gen3_exteriors.lua'))do if r.geometry=='cinnabar_lab'then recipe=r end end
assert(recipe)
local C=assert(loadfile('lib/Gen3Civic.lua'))({require=function(n)
 if n=='BuildBudget'then return {tick=function()end,check=function()end}end
 if n=='ArchitecturalDetails'then return dofile('lib/ArchitecturalDetails.lua')end
 if n=='Gen3CinnabarLab'then return dofile('lib/Gen3CinnabarLab.lua')end
 if n=='Gen3Hoenn'then return {active=function()return false end}end
 error(n)
end})
local cells={}
for iy,row in ipairs(recipe.rows)do for ix,mid in ipairs(row)do
 local x,y=ix-1,iy-1;cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=recipe.pair,primary='general',collision=(iy==1 or iy==5) and 0 or 7,shape={kind='flat'},ts={}}
end end
local list=C.prepare(cells,{}, {recipe});assert(#list==1);local g=list[1];local faces=0
C.append(g,function(v,uv)
 faces=faces+1;local low,high,back,front=math.huge,-math.huge,math.huge,-math.huge
 for i,q in ipairs(v)do
  assert(q[1]>=0 and q[1]<=112 and q[2]>=0 and q[2]<=54 and q[3]>=0 and q[3]<=64.1)
  assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1)
  low=math.min(low,q[2]);high=math.max(high,q[2]);back=math.min(back,q[3]);front=math.max(front,q[3])
 end
 if low<16 and high>1.5 then assert(back>=16 and front<=64.1,'laboratory blocks native walking rows')end
end)
assert(faces>220)
local door=assert(C.doorSurface(g,3,3));assert(door.w==16 and door.h==16 and door.vertices[1][2]==24)
for _,q in ipairs(recipe.groundPreserve)do local c=cells[q[1]..':'..q[2]];assert(C.ground(c)==c.mid)end
assert(C.ground(cells['4:4'])==8 and C.ground(cells['5:4'])==8,'projected sign not cleared')
for _,c in pairs(cells)do c.civic=nil end
cells['4:4'].mid=1;assert(#C.prepare(cells,{}, {recipe})==0,'partial source sign drawing claimed')
print('Cinnabar laboratory: complete pattern, closed bounded capsule, native door/shoreline and clear walking rows PASS')
