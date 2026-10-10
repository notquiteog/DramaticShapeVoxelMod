local Urban=dofile('lib/Gen3UrbanBuilding.lua');local recipes={}
for _,r in ipairs(dofile('data/gen3_hoenn_exteriors.lua'))do if r.geometry=='urban'then recipes[#recipes+1]=r end end
assert(#recipes==7)
local V={require=function(n)
 if n=='BuildBudget'then return {tick=function()end,check=function()end}end
 if n=='ArchitecturalDetails'then return dofile('lib/ArchitecturalDetails.lua')end
 if n=='Gen3UrbanBuilding'then return Urban end
 if n=='Gen3Hoenn'then return {active=function()return true end,exteriors=recipes}end
 error(n)
end}
local C=assert(loadfile('lib/Gen3Civic.lua'))(V)
for _,r in ipairs(recipes)do
 local cells={};local w,h=#r.rows[1],#r.rows
 for iy,row in ipairs(r.rows)do for ix,mid in ipairs(row)do
  local x,y=ix-1,iy-1;cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=r.pair,primary='general',collision=iy==1 and 0 or 7,shape={kind='flat'},ts={}}
 end end
 local list=C.prepare(cells,{},{});assert(#list==1,r.name);local g=list[1];local p=C.profile(g)
 local n=0;local underside=false
 C.append(g,function(v,uv)
  n=n+1;local low,high=math.huge,-math.huge;local back=math.huge
  for i,q in ipairs(v)do
   assert(q[1]>=0 and q[1]<=w*16 and q[2]>=0 and q[3]>=0 and q[3]<=h*16,r.name..' bounds')
   assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1)
   low=math.min(low,q[2]);high=math.max(high,q[2]);back=math.min(back,q[3])
  end
  if high>1.5 and low<16 then assert(back>=16,r.name..' rear lane blocked')end
  if low==p.wall and high==p.wall and back==0 then underside=true end
 end)
 assert(n>40 and underside,r.name..' incomplete closed roof')
 for _,o in ipairs(r.openings or {})do
  local d=assert(C.doorSurface(g,math.floor(o[1]/16),h-1));assert(d.vertices[1][2]==20 and d.vertices[1][3]==h*16-1.95,r.name..' door misaligned')
 end
 if r.ground then assert(C.ground(cells['0:0'])==0x2bb,'native stone lane lost')end
 for _,c in pairs(cells)do c.civic=nil end
 cells['1:1'].mid=1;assert(#C.prepare(cells,{}, {})==0,r.name..' incomplete source claimed')
end
print('Rustboro 7 urban source families: matching, roof undersides, rear lanes, native doors and material bounds PASS')
