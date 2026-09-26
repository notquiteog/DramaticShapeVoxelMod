local H=dofile('lib/VoxelHull.lua')
local calls=0
local q=H.build(8,8,function(x,y)
 calls=calls+1
 local solid=y>0 and y<7 and x>=2 and x<=5
 return .2,.4,.2,solid and 1 or 0,(x+.5)/8,(y+.5)/8
end,1,1)
assert(calls==64 and #q>=6 and #q<40,'hull did not greedily merge coplanar faces')
local seen={};local minY,maxY,maxZ=math.huge,-math.huge,0
for _,face in ipairs(q)do
 for _,p in ipairs(face)do
  minY=math.min(minY,p[2]);maxY=math.max(maxY,p[2]);maxZ=math.max(maxZ,math.abs(p[3]))
  assert(p[1]>=-2 and p[1]<=2,'square support outside silhouette')
 end
 local a,b,c=face[1],face[2],face[3]
 local n={(b[2]-a[2])*(c[3]-a[3])-(b[3]-a[3])*(c[2]-a[2]),(b[3]-a[3])*(c[1]-a[1])-(b[1]-a[1])*(c[3]-a[3]),(b[1]-a[1])*(c[2]-a[2])-(b[2]-a[2])*(c[1]-a[1])}
 for i,v in ipairs(n)do if v~=0 then seen[i..':'..(v>0 and '+'or '-')]=true end end
end
assert(minY==0 and maxY==6 and maxZ>=1,'volume lost grounded depth')
local sides=0;for _ in pairs(seen)do sides=sides+1 end;assert(sides==6,'hull missing side, back, top or underside')
local v,i={},{};H.append(q,v,i,0,10,4,20)
assert(#v==#q*4 and #i==#q*6)
for _,p in ipairs(v)do assert(p[9]==0,'solid geometry would rotate toward camera')end
print('PASS closed grounded voxel volume, native contour, merged surfaces and fixed orientation')
