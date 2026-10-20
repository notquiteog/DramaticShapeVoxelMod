local S=dofile('lib/NativeWaterSurface.lua')
local function near(a,b,epsilon)assert(math.abs(a-b)<epsilon,tostring(a)..' ~= '..tostring(b))end
for _,t in ipairs{0,.13,12.5,40*math.pi-.01}do
 for x=-20,20,5 do for z=-20,20,5 do
  local h,dx,dz=S.sample(x,z,t)
  assert(h>=0 and h<=1 and math.abs((h-.5)*S.HEIGHT)<=.15)
  local epsilon=.001
  near(dx,(S.sample(x+epsilon,z,t)-S.sample(x-epsilon,z,t))/(epsilon*2),1e-6)
  near(dz,(S.sample(x,z+epsilon,t)-S.sample(x,z-epsilon,t))/(epsilon*2),1e-6)
  local wrapped,wx,wz=S.sample(x,z,t+40*math.pi)
  near(h,wrapped,1e-12);near(dx,wx,1e-12);near(dz,wz,1e-12)
  local far,fx,fz=S.sample(x,z,t,100,100)
  near(far,.5,1e-12);near(fx,0,1e-12);near(fz,0,1e-12)
 end end
end
local a=S.sample(22.7,45.2,1);local b=S.sample(22.7,45.2,1.1);assert(math.abs(a-b)>.0001,'continuous water phase is frozen')
print('PASS bounded shallow waves, analytic gradient against numerical derivatives, seamless phase wrap and distant anti-alias filtering')
