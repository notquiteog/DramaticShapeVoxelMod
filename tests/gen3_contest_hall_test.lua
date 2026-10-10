local Hall=dofile('lib/Gen3ContestHall.lua');local recipe
for _,r in ipairs(dofile('data/gen3_hoenn_exteriors.lua'))do if r.geometry=='contest_hall'then recipe=r end end
assert(recipe and #recipe.rows==7 and #recipe.rows[1]==7)
local C=assert(loadfile('lib/Gen3Civic.lua'))({require=function(n)
 if n=='BuildBudget'then return {tick=function()end,check=function()end}end
 if n=='ArchitecturalDetails'then return dofile('lib/ArchitecturalDetails.lua')end
 if n=='Gen3ContestHall'then return Hall end
 if n=='Gen3Hoenn'then return {active=function()return true end,exteriors={recipe}}end
 error(n)
end})
local cells={}
for iy,row in ipairs(recipe.rows)do for ix,mid in ipairs(row)do
 local x,y=ix-1,iy-1;cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=recipe.pair,primary='general',collision=iy==1 and 0 or 7,shape={kind='flat'},ts={}}
end end
local list=C.prepare(cells,{},{});assert(#list==1);local g=list[1];local faces,studs,soffit=0,0,false
C.append(g,function(v,uv)
 faces=faces+1;local low,high,back=math.huge,-math.huge,math.huge
 for i,q in ipairs(v)do
  assert(q[1]>=0 and q[1]<=112 and q[2]>=0 and q[2]<=39 and q[3]>=0 and q[3]<=112)
  assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1)
  low=math.min(low,q[2]);high=math.max(high,q[2]);back=math.min(back,q[3])
 end
 if low<16 and high>1.5 then assert(back>=16,'hall blocks native rear walking row')end
 if low==38.7 and high==38.7 then studs=studs+1 end
 if low==32 and high==32 and back==16 then soffit=true end
end)
assert(faces>1500 and studs>500 and soffit,'roof fasteners/closed soffit missing')
local door=assert(C.doorSurface(g,3,6));assert(door.w==16 and door.h==20 and math.abs(door.vertices[1][2]-80/3)<.001)
assert(door.vertices[1][3]==110.05)
for _,c in pairs(cells)do c.civic=nil end
cells['3:3'].mid=1;assert(#C.prepare(cells,{}, {})==0,'partial hall claimed')
print('Contest hall complete source, native rear lane/door, bounded shell and faceted rivets: PASS')
