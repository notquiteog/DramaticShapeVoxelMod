-- Rejected shader variants must retain a useful error without per-frame retry.
local calls=0
love={graphics={newShader=function()calls=calls+1;error('fixture GLES link failure')end,
 getSupported=function()return {shaderderivatives=true}end}}
local real={Mat4=true,CanopyBillboard=true,BattleOcclusion=true,DrawUniforms=true}
local R=assert(loadfile('lib/Voxel3D.lua'))({require=function(name)
 if real[name]then return assert(loadfile('lib/'..name..'.lua'))()end
 return {}
end})
assert(R.shader()==nil)
local attempts=calls;assert(attempts>=1 and attempts<=2)
assert(R.lastShaderError:find('fixture GLES link failure',1,true))
for _=1,10 do assert(R.shader()==nil)end
assert(calls==attempts,'unavailable shader retried on each frame')
assert(R.unlitShader()==nil)
local unlitAttempts=calls
for _=1,10 do assert(R.unlitShader()==nil)end
assert(calls==unlitAttempts,'unavailable card shader retried on each frame')
print('Scene shader error reporting and retry cache PASS')
