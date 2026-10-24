local Union=dofile('lib/Gen3BoxUnion.lua')
local check=assert(loadfile('tests/imported_interior_surface_planes_test.lua'))('helper')
local uv={{0,0},{1,0},{1,1},{0,1}}
local function model()
 local p={vertices={},indices={}};local area=0
 local function emit(q,t)
  local start=#p.vertices
  for _,v in ipairs(q)do p.vertices[#p.vertices+1]=v end
  for _,n in ipairs{1,2,3,1,3,4}do p.indices[#p.indices+1]=start+n end
  local a,b,c=q[1],q[2],q[4];local u,v={b[1]-a[1],b[2]-a[2],b[3]-a[3]},{c[1]-a[1],c[2]-a[2],c[3]-a[3]}
  area=area+math.sqrt((u[2]*v[3]-u[3]*v[2])^2+(u[3]*v[1]-u[1]*v[3])^2+(u[1]*v[2]-u[2]*v[1])^2)
  for _,a in ipairs(t)do assert(a[1]>=-1e-7 and a[1]<=1+1e-7 and a[2]>=-1e-7 and a[2]<=1+1e-7,'face clipping lost original UV bounds')end
 end
 return p,emit,function()return area end
end
for _,q in ipairs{{1,10},{.5,8},{0,6}}do
 local p,emit,area=model();Union.append({{lo={0,0,0},hi={1,1,1},uv=uv},{lo={q[1],0,0},hi={q[1]+1,1,1},uv=uv}},emit)
 assert(math.abs(area()-q[2])<1e-7);check({parts={p}},#p.indices/3)
end
local Designed=dofile('lib/Gen3DesignedFurniture.lua')
local p,emit=model();local count=0
assert(Designed.append({cx=0,cy=0,w=32,d=48,recipe={design='em_lab_free_books',joinedBoxes=true,groundInset=.025}},
 function(sx,sy,w,h,a,b,c,d)emit({a,b,c,d},uv)end,
 function()error('unjoined native box emission escaped')end,function()return uv end,emit))
for _,v in ipairs(p.vertices)do assert(v[1]>=1-1e-7 and v[1]<=31+1e-7 and v[2]>=-.025-1e-7 and v[2]<=31.6+1e-7 and v[3]>=17-1e-7 and v[3]<=47.3+1e-7);if v[2]==-.025 then count=count+1 end end
assert(count>0);check({parts={p}},#p.indices/3)
local archiveLo,archiveHi={math.huge,math.huge,math.huge},{-math.huge,-math.huge,-math.huge}
for _,v in ipairs(p.vertices)do if v[2]>26.5 then for k=1,3 do archiveLo[k]=math.min(archiveLo[k],v[k]);archiveHi[k]=math.max(archiveHi[k],v[k])end end end
assert(math.abs(archiveHi[2]-31.6)<1e-7 and archiveLo[2]>26.5 and math.abs(archiveHi[1]-archiveLo[1]-6.6)<1e-7 and math.abs(archiveHi[3]-archiveLo[3]-7.8)<1e-7,'independent archive fit lost uniform proportions or crossed native ceiling')
local old,oldEmit=model()
assert(Designed.append({cx=0,cy=0,w=32,d=48,recipe={design='em_lab_free_books',groundInset=.025}},
 function(sx,sy,w,h,a,b,c,d)oldEmit({a,b,c,d},uv)end,
 function(l,b,n,r,h,s,t)
  oldEmit({{l,h,n},{r,h,n},{r,h,s},{l,h,s}},t)
  oldEmit({{l,h,s},{r,h,s},{r,b,s},{l,b,s}},t)
  oldEmit({{r,h,n},{l,h,n},{l,b,n},{r,b,n}},t)
  oldEmit({{l,h,n},{l,h,s},{l,b,s},{l,b,n}},t)
  oldEmit({{r,h,s},{r,h,n},{r,b,n},{r,b,s}},t)
 end,function()return uv end,oldEmit))
assert(not pcall(check,{parts={old}},#old.indices/3),'original native overlapping planes were not reproduced')
local recipes=dofile('lib/Gen3Furniture.lua').recipes;local tagged=0
for _,r in ipairs(recipes)do if r.joinedBoxes then assert(r.name=='birch_free_books'or r.name=='birch_free_books_end');assert(r.groundInset==.025);tagged=tagged+1 end end
assert(tagged==2)
print('PASS exact native free-case box union: touching/overlapping/coincident solids, original UVs/bounds, recessed floor and zero coplanar faces including lids/archive box/shelf joints ('..(#p.indices/3)..' triangles)')
