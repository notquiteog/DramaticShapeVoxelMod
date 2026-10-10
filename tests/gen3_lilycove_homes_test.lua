local recipes={}
for _,r in ipairs(dofile('data/gen3_hoenn_exteriors.lua'))do if r.kind=='gabled_home'then recipes[#recipes+1]=r end end
assert(#recipes==5)
local C=assert(loadfile('lib/Gen3Civic.lua'))({require=function(n)
 if n=='BuildBudget'then return {tick=function()end,check=function()end}end
 if n=='ArchitecturalDetails'then return dofile('lib/ArchitecturalDetails.lua')end
 if n=='Gen3Hoenn'then return {active=function()return true end,exteriors=recipes}end
 error(n)
end})
for _,r in ipairs(recipes)do
 local cells={};local w=#r.rows[1]
 for iy,row in ipairs(r.rows)do for ix,mid in ipairs(row)do
  local x,y=ix-1,iy-1;cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=r.pair,primary='general',collision=iy==1 and 0 or 7,shape={kind='flat'},ts={}}
 end end
 local list=C.prepare(cells,{},{});assert(#list==1);local g=list[1];local faces=0
 C.append(g,function(v,uv)
  faces=faces+1;local low,high,back=math.huge,-math.huge,math.huge
  for i,q in ipairs(v)do
   assert(q[1]>=-2 and q[1]<=w*16+2 and q[3]>=-1 and q[3]<=65 and q[2]>=0,r.name..' bounds '..table.concat(q,','))
   low=math.min(low,q[2]);high=math.max(high,q[2]);back=math.min(back,q[3])
   assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1)
  end
  if high>1.5 and low<16 then assert(back>=16,r.name..' rear lane blocked')end
 end)
 assert(faces>70)
 local o=r.openings[1];local door=assert(C.doorSurface(g,math.floor(o[1]/16),3));assert(door.vertices[1][2]>20)
 for _,c in pairs(cells)do c.civic=nil end
 cells['1:1'].mid=1;assert(#C.prepare(cells,{}, {})==0)
end
print('Lilycove 5 complete gabled home patterns, native doors and clear rear walking lanes: PASS')
