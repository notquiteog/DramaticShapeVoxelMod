local Urban=dofile('lib/Gen3UrbanBuilding.lua');local recipes={}
for _,r in ipairs(dofile('data/gen3_hoenn_exteriors.lua'))do if r.geometry=='urban'then recipes[#recipes+1]=r end end
assert(#recipes==7)
local rs=dofile('lib/Gen3RubySapphire.lua').exteriors(recipes)
assert(#rs==7)
for _,r in ipairs(rs)do recipes[#recipes+1]=r end
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
 local n=0;local underside=false;local frontPanes=0;local sides={}
 C.append(g,function(v,uv,shade)
  if shade==64.92 then
   local sameZ=v[1][3]==v[3][3]
   if sameZ and v[1][3]>h*16-3 then frontPanes=frontPanes+1 end
   if v[1][1]==v[3][1]then sides[v[1][1]<w*8 and "left" or "right"]=true elseif v[1][3]<20 then sides.back=true end
  end
  n=n+1;local low,high=math.huge,-math.huge;local back=math.huge
  for i,q in ipairs(v)do
   assert(q[1]>=0 and q[1]<=w*16 and q[2]>=0 and q[3]>=0 and q[3]<=h*16,r.name..' bounds')
   assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1)
   low=math.min(low,q[2]);high=math.max(high,q[2]);back=math.min(back,q[3])
  end
  if high>1.5 and low<16 then assert(back>=16,r.name..' rear lane blocked')end
  if low==p.wall and high==p.wall and (back==16 or r.blockedStart and math.abs(back-16.02)<.001) then underside=true end
 end)
 assert(n>40 and underside,r.name..' incomplete closed roof')
 local sourcePanes=0;for iy,row in ipairs(r.rows)do if iy>=4 then for _,mid in ipairs(row)do if mid==0x23a or mid==0x242 then sourcePanes=sourcePanes+1 end end end end
 assert(frontPanes==sourcePanes,r.name..' native front window count changed')
 assert(sides.left and sides.right and sides.back,r.name..' missing recessed side/rear windows')
 for _,o in ipairs(r.openings or {})do
  local d=assert(C.doorSurface(g,math.floor(o[1]/16),h-1));assert(d.vertices[1][2]==20 and d.vertices[1][3]==h*16-1.95,r.name..' door misaligned')
 end
 if r.ground then assert(C.ground(cells['0:0'])==0x2bb,'native stone lane lost')end
 for _,c in pairs(cells)do c.civic=nil end
 cells['1:1'].mid=1;assert(#C.prepare(cells,{}, {})==0,r.name..' incomplete source claimed')
end
print('Rustboro Emerald/RS urban variants: matching, roof undersides, rear lanes, native doors and material bounds PASS')
