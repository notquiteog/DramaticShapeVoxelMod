local R=assert(loadfile('lib/Gen2RoofShell.lua'))()
local runs={}
local function key(x,z)return x..','..z end
local function at(x,z)return runs[key(x,z)] end
local function h(x,z)return at(x,z) and at(x,z).h or 0 end
local run={h=24,rise=24,extent=8,front=7}
for x=0,5 do for z=0,7 do runs[key(x,z)]=run end end
local count=0
for x=0,5 do for z=0,7 do
  local c=R.corners(run,x,z,h)
  R.append(run,x,z,c,at,h,function(p,uv)
    count=count+1
    assert(x==0 or x==5,'shared roof interior should not emit walls')
    for _,v in ipairs(p) do assert(v[2]>=24 and v[2]<=48) end
    assert(p[1][2]==24 and p[2][2]==24,'gable must meet the facade')
    -- Every emitted top endpoint coincides with the roof at that position.
    local heights={[key(x*8,(z+1)*8)]=c[1],[key((x+1)*8,(z+1)*8)]=c[2],
      [key((x+1)*8,z*8)]=c[3],[key(x*8,z*8)]=c[4]}
    for i=3,4 do assert(p[i][2]==heights[key(p[i][1],p[i][3])]) end
  end,function()return 0,1,0,1 end,27)
end end
assert(count>0,'roof flanks remain open')
-- A lower adjoining building hides only the portion it actually covers.
runs[key(1,3)]={h=24,rise=8,extent=8,front=7}
local seam=0
R.append(run,0,3,R.corners(run,0,3,h),at,h,function(p)
  if p[1][1]==8 and p[2][1]==8 then
    seam=seam+1
    assert(p[1][2]==32 and math.abs(p[2][2]-30)<1e-6,'adjoining straight roof edge mismatch')
  end
end,function()return 0,1,0,1 end,27)
assert(seam==1,'different roof heights leave an open step')
print('roof shell meets facade and slope; shared faces culled; stepped roof sealed')

local courseCount,minRelief,maxRelief=0,math.huge,0
R.courses({24,24,32,32},0,0,function(p,uv)
 courseCount=courseCount+1
 for i,v in ipairs(p) do
  local base=32-v[3]
  assert(v[2]>=base-1e-6 and v[2]<=base+.621,'roof relief exceeded ceramic tile thickness')
  if v[2]>base+.001 then minRelief=math.min(minRelief,v[2]-base) end
  maxRelief=math.max(maxRelief,v[2]-base)
  assert(v[1]>=0 and v[1]<=8 and v[3]>=0 and v[3]<=8,'roof altered footprint')
  assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1)
 end
end,function()return 0,1,0,1 end,13,true,true)
assert(courseCount<=80,'ceramic tile detail exceeded the per-cell budget')
assert(maxRelief-minRelief>.05,'tiles lost their shallow overlap')
print('thin tile courses follow base slope with bounded relief and closed ends')

local middle=R.corners(run,2,5,h)
assert(middle[1]==36,'roof should retain a straight slope')
local function checkTrim(x,z)
 local n,cap,eave=0,false,false
 R.trim(run,x,z,R.corners(run,x,z,h),at,function(p,uv)
  n=n+1
  for i,v in ipairs(p) do
   assert(v[1]>=x*8 and v[1]<=(x+1)*8,'trim spread into adjacent building')
   assert(v[2]>=run.h-.251 and v[2]<=run.h+run.rise+1.241)
   assert(v[3]>=z*8-1.151 and v[3]<=(z+1)*8+1.151)
   assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1)
   cap=cap or v[2]>run.h+run.rise
   eave=eave or v[3]<0 or v[3]>64
  end
 end,function()return 0,1,0,1 end,14)
 return n,cap,eave
end
assert(checkTrim(2,1)==0,'internal slope acquired a false eave or ridge')
local n,cap=checkTrim(2,4)
assert(n>0 and cap,'ridge is uncapped')
assert(checkTrim(2,3)==0,'ridge emitted twice')
local _,_,frontEave=checkTrim(2,7)
local _,_,backEave=checkTrim(2,0)
assert(frontEave and backEave,'front/back ceramic eaves missing')
print('straight slope, small ridge and bounded front/back eaves pass')

-- Check visible face winding: backface culling must not eat the reverse
-- eave, reverse-slope lips or the top of the ridge in first person.
local function normal(p)
 local a,b={},{}
 for j=1,3 do a[j]=p[2][j]-p[1][j];b[j]=p[3][j]-p[1][j] end
 return {a[2]*b[3]-a[3]*b[2],a[3]*b[1]-a[1]*b[3],a[1]*b[2]-a[2]*b[1]}
end
for _,south in ipairs({true,false}) do
 local c=south and {24,24,32,32} or {32,32,24,24}
 R.courses(c,0,0,function(p,uv,shade)
  local n=normal(p)
  if shade==.96 then assert(n[2]>0,'tile pan faces into the roof') end
  if shade==.82 and math.abs(n[3])>0 and math.abs(n[1])<.001 then assert(n[3]*(south and 1 or -1)>0,'tile lip faces inward') end
 end,function()return 0,1,0,1 end,14,true,true)
end
for _,z in ipairs({0,4,7}) do
 R.trim(run,2,z,R.corners(run,2,z,h),at,function(p,uv,shade)
  local n=normal(p)
  if shade==.88 or shade==.90 then assert(n[2]>0,'ridge/eave top faces inward') end
  if shade==.48 then assert(n[2]<0,'soffit faces into roof') end
  if shade==.67 then assert(n[3]*(z==0 and -1 or 1)>0,'eave fascia faces inward') end
 end,function()return 0,1,0,1 end,14)
end
print('front/back tile lips, eaves, soffits and ridge have outward winding')
local Materials=assert(loadfile('lib/Gen2Materials.lua'))({})
assert(Materials.roofTile('TILESET_JOHTO')==14)
assert(Materials.roofTile('TILESET_JOHTO_MODERN')==14)
assert(Materials.roofTile('TILESET_KANTO')==5)
assert(Materials.roofTile('OVERWORLD')==nil and Materials.roofTile('TILESET_LAB')==nil,
 'ceramic roof material leaked into another generation or interior')
for y=0,31 do for x=0,31 do
 local r,g,b=Materials.color('roof',x,y,.4,.8,.3,1)
 assert(r>=0 and g<=1 and b>=0,'invalid ceramic glaze color')
end end
print('ceramic material covers Johto/Kanto pitched roofs without Gen1/interior override')
