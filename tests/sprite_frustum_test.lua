local C=dofile('lib/FrustumCull.lua')
local M=dofile('lib/Mat4.lua')
local S=assert(loadfile('lib/SpriteFrustum.lua'))({require=function(n)assert(n=='FrustumCull');return C end})
local planes=C.prepare(M.identity())
assert(S.visible(M.identity(),1,1,0,planes))
assert(not S.visible(M.translate(3,0,0),1,1,0,planes),'outside native card retained')
assert(S.visible(M.translate(1.5,0,0),1,1,0,planes),'edge contact rejected')
assert(S.visible(M.translate(0,3,0),1,3,3,planes),'transparent baseline padding ignored')
assert(not S.visible(M.translate(0,3,0),1,3,0,planes))
local mirrored=M.mul(M.translate(0,3,0),M.scale(1,-1,1))
assert(S.visible(mirrored,1,3,0,planes),'reflected card used upright bounds')
-- Camera/reflection planes are supplied independently, never cached by model.
local other=C.prepare(M.translate(-3,0,0))
assert(S.visible(M.translate(3,0,0),1,1,0,other),'current pass VP ignored')
assert(S.visible(M.translate(3,0,0),1,1,0,nil),'disabled/curved camera did not fail open')
local bad=M.identity();bad[1]=0/0;assert(S.visible(bad,1,1,0,planes))
bad=M.identity();bad[13]=.1;assert(S.visible(bad,1,1,0,planes))
assert(S.visible({},1,1,0,planes)and S.visible(M.identity(),-1,1,0,planes))
-- Compare against explicitly transformed four-corner bounds over moving,
-- yawed, leaned and mirrored poses. The caller's source matrix stays intact.
for i=1,400 do
 local model=M.mul(M.translate(math.sin(i)*4,math.cos(i)*3,math.sin(i*.7)*4),M.mul(M.rotateY(i*.13),M.scale(1,i%2==0 and -1 or 1,1)))
 model[2]=math.sin(i*.3)*.2;model[10]=math.cos(i*.3)*.3
 local w,h,p=1+i%4,1+i%5,(i%3)*.3
 local b={math.huge,math.huge,math.huge,-math.huge,-math.huge,-math.huge}
 for _,x in ipairs{-w/2,w/2}do for _,y in ipairs{-p,h-p}do
  for a=0,2 do local r=a*4+1;local v=model[r]*x+model[r+1]*y+model[r+3]
   b[a+1]=math.min(b[a+1],v);b[a+4]=math.max(b[a+4],v)
  end
 end end
 assert(S.visible(model,w,h,p,planes)==C.visible(planes,b),'transformed card extrema differ')
end
print('PASS sprite exact affine bounds:400poses, reflection/current camera, padding, edge contact and conservative invalid/deformed fallback')
