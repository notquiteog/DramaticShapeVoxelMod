-- Pure CPU equivalence: the shared shadow transform must retain every pose,
-- light change and bias change without sharing mutable return tables.
local Mat = dofile('lib/Mat4.lua')
local modules = {
 Mat4=Mat, DrawUniforms=dofile('lib/DrawUniforms.lua'), VoxelState={},
 Shadows={off=function() return false end}, CanopyBillboard={shader=''},
}
local Shadow = assert(loadfile('lib/ShadowMap.lua'))({require=function(name)
 return assert(modules[name], name)
end})
local function reference(model)
 local x,y,z=Shadow.KX,-1,Shadow.KZ
 local length=math.sqrt(x*x+y*y+z*z)
 local f={x/length,y/length,z/length}
 local s=-Shadow.slack*Shadow.SNUG
 return Mat.mul(Mat.translate(f[1]*s,f[2]*s,f[3]*s),model or Mat.identity())
end
local comparisons=0
local function check(model)
 local expected,actual=reference(model),Shadow.snug(model)
 for i=1,16 do
  assert(actual[i]==expected[i], 'shadow transform changed at element '..i)
 end
 comparisons=comparisons+1
 return actual
end
for step=1,2000 do
 Shadow.KX=math.sin(step*.013)*8
 Shadow.KZ=math.cos(step*.017)*8
 Shadow.slack=.5+step%19*.27
 Shadow.SNUG=step%10*.1
 check(nil)
 local model=Mat.billboard(step*.7,step*.3,step%25,step*.05,step*.003,step%2==0)
 local saved=check(model)
 local prior=saved[4]
 model[4]=model[4]+19
 check(model)
 assert(saved[4]==prior, 'later pose mutated earlier caster transform')
 local direction=Shadow.sunDir()
 direction[1]=999
 assert(Shadow.sunDir()[1]~=999, 'public ray exposed private cached state')
 -- Also retain translation of non-affine matrices, not just scene models.
 check(Mat.perspective(.8,1.6,.1,800))
end
print('PASS '..comparisons..' exact shadow transforms: moving poses, mutable models, sun, slack, snug and non-affine input')

if os.getenv('SHADOW_BENCH') then
 Shadow.KX,Shadow.KZ,Shadow.slack,Shadow.SNUG=-.85,-.55,2.4,.9
 local model=Mat.billboard(80,60,12,.3,.5,false)
 local function bench(fn)
  collectgarbage('collect')
  local start=os.clock();local sum=0;local retained={}
  for i=1,1000000 do
   model[4]=i%640
   local result=fn(model)
   retained[i%256+1]=result -- force owned matrices to escape the JIT trace
   sum=sum+result[4]
  end
  return os.clock()-start,sum
 end
 -- Warm both paths before timing; use the same mutable transform workload.
 bench(reference);bench(Shadow.snug)
 for run=1,3 do
  local old,a=bench(reference);local new,b=bench(Shadow.snug)
  assert(a==b)
  print(string.format('CPU snug million calls run %d: reference %.6fs optimized %.6fs (%.2fx)',run,old,new,old/new))
 end
end
