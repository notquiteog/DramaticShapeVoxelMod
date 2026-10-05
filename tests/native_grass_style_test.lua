local active=false
local C=assert(loadfile('lib/SurfaceCraft.lua'))()
local V={require=function(name)
 if name=='CommunityVisuals'then return {customGrass=function()return active end}end
 if name=='SurfaceCraft'then return C end
 error(name)
end}
local M=assert(loadfile('lib/NativeGrassStyle.lua'))(V)
assert(M.transform(0,0,16)==nil,'default native grass changed')
active=true
for _,span in ipairs{8,16}do
 for x=-10,10 do for z=-10,10 do
  local f,anchor=M.transform(x*span,z*span,span)
  local repeatF=M.transform(x*span,z*span,span)
  for _,p in ipairs{{x*span,0,z*span},{(x+1)*span,4,z*span},{(x+1)*span,4,(z+1)*span},{x*span,0,(z+1)*span}}do
   local q,r=f(p),repeatF(p)
   assert(q[1]>=x*span and q[1]<=(x+1)*span and q[3]>=z*span and q[3]<=(z+1)*span,'tuft escaped its source footprint')
   assert(q[1]==r[1]and q[2]==r[2]and q[3]==r[3],'camera-independent placement was unstable')
  end
  local lo=f({x*span,0,z*span});local hi=f({x*span,4,z*span})
  assert(lo[1]==hi[1]and lo[3]==hi[3]and lo[2]==0,'grass leaned or floated')
  assert(anchor[1]>=x*span and anchor[1]<=(x+1)*span)
 end end
end
print('PASS native Legendary grass: default unchanged, stable source-footprint variation, upright/grounded GB and GBA cards')
