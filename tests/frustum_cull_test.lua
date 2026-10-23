local C=dofile('lib/FrustumCull.lua')
local Mat=dofile('lib/Mat4.lua')
local identity=Mat.identity()
local planes=C.prepare(identity)
assert(C.visible(planes,{-1,-1,-1,1,1,1}))
assert(C.visible(planes,{1,-.5,-.5,2,.5,.5}),'touching edge culled')
assert(C.visible(planes,{1.00001,0,0,1.00002,.1,.1}),'float edge slack lost')
for axis=1,3 do for sign=-1,1,2 do
 local b={-.5,-.5,-.5,.5,.5,.5}
 b[axis],b[axis+3]=sign>0 and 2 or -3,sign>0 and 3 or -2
 assert(not C.visible(planes,b),'outside plane not rejected')
end end
assert(C.visible(planes,{2,0,0,1,1,1}),'invalid bounds must draw')
assert(C.visible(planes,{0/0,0,0,1,1,1}))
assert(C.visible(planes,{0,0,0,math.huge,1,1}))
assert(C.visible(nil,{2,2,2,3,3,3}))
assert(C.prepare({})==nil)
identity[4]=999
assert(C.visible(planes,{0,0,0,.5,.5,.5}),'prepared matrix was aliased')

-- Independent oracle transforms all eight corners through VP. Every rejected
-- box must have all corners outside the SAME plane; this also covers boxes
-- surrounding the eye and triangles crossing screen edges without a vertex in it.
local function outside(vp,b)
 local all={true,true,true,true,true,true}
 for xi=0,1 do for yi=0,1 do for zi=0,1 do
  local x,y,z=b[1+xi*3],b[2+yi*3],b[3+zi*3]
  local v={}
  for r=0,3 do v[r+1]=vp[r*4+1]*x+vp[r*4+2]*y+vp[r*4+3]*z+vp[r*4+4]end
  for axis=1,3 do
   if v[4]-v[axis]>=0 then all[axis*2-1]=false end
   if v[4]+v[axis]>=0 then all[axis*2]=false end
  end
 end end end
 for _,v in ipairs(all)do if v then return true end end
 return false
end
math.randomseed(4593)
local rejected=0
for camera=1,80 do
 local view=Mat.lookAt({math.random()*100,30+math.random()*100,math.random()*100},{0,0,0},{0,1,0})
 local projection=Mat.perspective(.4+math.random(),.7+math.random()*2,.1,800)
 local vp=Mat.mul(Mat.scale(1,-1,1),Mat.mul(projection,view))
 local p=C.prepare(vp)
 for sample=1,200 do
  local x,y,z=math.random()*1200-600,math.random()*400-200,math.random()*1200-600
  local b={x,y,z,x+math.random()*200,y+math.random()*200,z+math.random()*200}
  if not C.visible(p,b)then assert(outside(vp,b),'false frustum rejection');rejected=rejected+1 end
 end
 assert(C.visible(p,{-10000,-10000,-10000,10000,10000,10000}),'eye-containing world box culled')
end
assert(rejected>5000)
local perspective=C.prepare(Mat.perspective(1,1,1,100))
assert(C.visible(perspective,{-2,-2,-2,2,2,2}),'near-plane crossing lost')
assert(not C.visible(perspective,{-1,-1,2,1,1,3}),'box behind eye retained')
assert(C.visible(perspective,{-100,-100,-5,100,100,-4}),'screen-spanning box culled')
print('PASS six planes, edge/near/eye crossing, mutable VP, invalid fallback and 16000 camera/AABB oracle comparisons ('..rejected..' rejected)')
