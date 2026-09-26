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
local thin=H.build(8,8,function(x,y)return .4,.3,.2,1,.5,.5 end,1,0,3)
local near,far=math.huge,-math.huge
for _,f in ipairs(thin)do for _,p in ipairs(f)do near=math.min(near,p[3]);far=math.max(far,p[3])end end
assert(far-near==3,'narrow displays exceeded their authored depth after voxel rounding')
for _,kind in ipairs({'tree','rock'})do
 -- Even a narrow color source must make a complete 3D body, not extrude
 -- its front silhouette into a thin card. Native cards use a separate path.
 local body=H.build(32,48,function(x,y)return .2,.4,.1,(x==16 or x==17) and 1 or 0,.5,.5 end,2,0,nil,kind)
 local near,far,left,right=math.huge,-math.huge,math.huge,-math.huge
 for _,f in ipairs(body)do for _,p in ipairs(f)do
  near=math.min(near,p[3]);far=math.max(far,p[3]);left=math.min(left,p[1]);right=math.max(right,p[1])
  assert(p[2]>=0 and p[2]<=48,'organic body lost its ground/height bounds')
 end end
 assert(far-near>20 and right-left>20,kind..' collapsed into a slab')
 assert(#body<3000,'balanced organic volume exceeded mesh budget')
end
print('PASS closed grounded voxel volume, native contour, merged surfaces, depth cap and fixed orientation')
