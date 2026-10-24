local function check(model,expected)
local triangles={}
local function cross(a,b)return{a[2]*b[3]-a[3]*b[2],a[3]*b[1]-a[1]*b[3],a[1]*b[2]-a[2]*b[1]}end
local function delta(a,b)return{a[1]-b[1],a[2]-b[2],a[3]-b[3]}end
local function dot(a,b)return a[1]*b[1]+a[2]*b[2]+a[3]*b[3]end
for _,part in ipairs(model.parts)do for i=1,#part.indices,3 do
 local q={};for j=0,2 do q[#q+1]=part.vertices[part.indices[i+j]]end
 local n=cross(delta(q[2],q[1]),delta(q[3],q[1]));local length=math.sqrt(dot(n,n));assert(length>1e-9,'degenerate source/closure furniture triangle')
 for k=1,3 do n[k]=n[k]/length end
 triangles[#triangles+1]={q=q,n=n,d=dot(n,q[1])}
end end
local function overlap(a,b)
 local axis=1;for k=2,3 do if math.abs(a.n[k])>math.abs(a.n[axis])then axis=k end end
 local dims={};for k=1,3 do if k~=axis then dims[#dims+1]=k end end
 local function point(v)return{v[dims[1]],v[dims[2]]}end
 local p={point(a.q[1]),point(a.q[2]),point(a.q[3])};local clip={point(b.q[1]),point(b.q[2]),point(b.q[3])}
 local function side(u,v,w)return(v[1]-u[1])*(w[2]-u[2])-(v[2]-u[2])*(w[1]-u[1])end
 local sign=side(clip[1],clip[2],clip[3])>0 and 1 or-1
 for i=1,3 do
  local u,v=clip[i],clip[i%3+1];local next={}
  for j,s in ipairs(p)do
   local t=p[j%#p+1];local ds,dt=side(u,v,s)*sign,side(u,v,t)*sign
   if ds>=-1e-10 then next[#next+1]=s end
   if(ds>0 and dt<0)or(ds<0 and dt>0)then local f=ds/(ds-dt);next[#next+1]={s[1]+(t[1]-s[1])*f,s[2]+(t[2]-s[2])*f}end
  end
  p=next;if #p<3 then return 0 end
 end
 local area=0;for i,v in ipairs(p)do local w=p[i%#p+1];area=area+v[1]*w[2]-w[1]*v[2]end
 return math.abs(area)/2
end
for i,a in ipairs(triangles)do for j=i+1,#triangles do local b=triangles[j]
 if math.abs(dot(a.n,b.n))>1-1e-8 then
  local same=true;for _,v in ipairs(b.q)do if math.abs(dot(a.n,v)-a.d)>1e-7 then same=false end end
  if same then assert(overlap(a,b)<1e-8,'source/cap furniture surfaces overlap on the same plane')end
 end
end end
assert(#triangles==expected)
end
if ...=='helper'then return check end
for _,q in ipairs{
 {'lib/ImportedOldaleSideboardData.lua','oras_oldale_low_sideboard',254},
 {'lib/ImportedOldaleDrawerData.lua','oras_oldale_drawer_chest',284},
 {'lib/ImportedCenterCounterData.lua','oras_center_reception_counter',160},
 {'lib/ImportedCenterBookcaseData.lua','oras_center_bookcase',224},
 {'lib/ImportedCenterHealerData.lua','oras_center_healer',550},
 {'lib/ImportedCenterTableData.lua','oras_center_glass_table',258},
 {'lib/ImportedOldaleChairData.lua','oras_oldale_backed_chair',270},
 {'lib/ImportedTrickCushionData.lua','oras_trick_house_floor_cushion',142},
 {'lib/ImportedBirchFreecaseData.lua','oras_birch_freestanding_case',1094},
 {'lib/ImportedBirchBookcaseData.lua','oras_birch_bookcase',412},
 {'lib/ImportedFlowerBookcaseData.lua','oras_flower_bookcase',620},
 {'lib/ImportedInstitutionServerData.lua','bdsp_galactic_server',42},
 {'lib/ImportedOldaleCupboardData.lua','oras_oldale_china_cupboard',346},
 {'lib/ImportedOldaleSinkData.lua','oras_oldale_kitchen_sink',570},
 {'lib/ImportedPyreMemorialData.lua','oras_pyre_memorial',203},
 {'lib/ImportedInteriorData.lua','oras_center_pc',202},
 {'lib/ImportedInteriorTVData.lua','oras_home_tv',104},
 {'lib/ImportedInteriorBedData.lua','oras_comfortable_bed',656},
 {'lib/ImportedHomeFurnitureData.lua','oras_littleroot_dining_table',190},
 {'lib/ImportedHomeFurnitureData.lua','oras_littleroot_fridge',106},
 {'lib/ImportedOldaleFurnitureData.lua','oras_oldale_checked_table',488},
 {'lib/ImportedOldaleFurnitureData.lua','oras_oldale_neighbor_table',488},
 {'lib/ImportedOldaleFridgeData.lua','oras_oldale_refrigerator',366},
}do check(dofile(q[1])[q[2]],q[3])end
print('PASS all twenty-three imported furniture models have zero positive-area coplanar source/closure overlaps')
