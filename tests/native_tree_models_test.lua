local Trees=dofile('lib/NativeTreeModels.lua')
local Hull=dofile('lib/VoxelHull.lua')
local function radius(family,y)
 local r=0
 for x=0,.5,.005 do if Trees.part(family,x,y,0)=='foliage'then r=x end end
 return r
end
assert(radius('conifer',.22)>radius('conifer',.7)*1.7,'conifer lost pointed skirts')
assert(radius('tiered',.24)>radius('tiered',.43)*1.3,'Viridian lower canopy lost its waist')
assert(radius('broad',.75)>.45 and not Trees.part('broad',.3,.3,0),'broad crown covers original exposed trunk')
assert(Trees.part('broad',.13,.05,0)=='wood','broad native roots missing')
assert(radius('round',.5)>radius('round',.9)*1.5,'Kanto border lost round outline')
local function sample(x,y)
 if y>=26 then return .4,.25,.1,1,(x+.5)/32,(y+.5)/32 end
 return .15,.3+math.floor(y/5)*.1,.1,1,(x+.5)/32,(y+.5)/32
end
for _,family in ipairs({'conifer','tiered','broad','round','sapling'})do
 for _,step in ipairs({1,2,4})do
  local faces=Hull.build(32,32,sample,step,0,nil,'tree',family)
  assert(#faces>6 and #faces<8000,family..' mesh budget')
  local span={math.huge,-math.huge,math.huge,-math.huge};local sides={}
  for _,q in ipairs(faces)do
   for _,p in ipairs(q)do
    assert(p[1]>=-16 and p[1]<=16 and p[2]>=0 and p[2]<=32 and p[3]>=-16 and p[3]<=16)
    span[1]=math.min(span[1],p[1]);span[2]=math.max(span[2],p[1]);span[3]=math.min(span[3],p[3]);span[4]=math.max(span[4],p[3])
   end
   local a,b,c=q[1],q[2],q[3]
   local n={(b[2]-a[2])*(c[3]-a[3])-(b[3]-a[3])*(c[2]-a[2]),(b[3]-a[3])*(c[1]-a[1])-(b[1]-a[1])*(c[3]-a[3]),(b[1]-a[1])*(c[2]-a[2])-(b[2]-a[2])*(c[1]-a[1])}
   for axis,v in ipairs(n)do if v~=0 then sides[axis..':'..(v>0 and '+' or '-')]=true end end
  end
  assert(span[2]-span[1]>=24 and span[4]-span[3]>=20,family..' became a flat extrusion')
  local count=0;for _ in pairs(sides)do count=count+1 end;assert(count==6,'open hull')
 end
end
print('PASS five native tree families, full 3D depth, closed faces and three detail levels')
