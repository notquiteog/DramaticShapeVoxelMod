local Cull=dofile('lib/FrustumCull.lua')
local prepared=0
local canvas={setFilter=function()end,setWrap=function()end}
local sh={send=function()end}
local function noop()end
love={graphics={newShader=function()return sh end,
 newCanvas=function()error('no calibration GPU')end,
 setCanvas=noop,clear=noop,setDepthMode=noop,setMeshCullMode=noop,
 setBlendMode=noop,setShader=noop,setColor=noop,getBlendMode=function()return 'alpha','alphamultiply'end}}
local modules={Mat4=dofile('lib/Mat4.lua'),DrawUniforms=dofile('lib/DrawUniforms.lua'),
 VoxelState={angle=.5,FOCAL=1},Shadows={off=function()return false end},CanopyBillboard={shader=''},
 PixelCanvas={new=function()return true,canvas end},Voxel3D={eye={0,20,30}},
 FrustumCull={prepare=function(vp)prepared=prepared+1;return Cull.prepare(vp)end}}
local S=assert(loadfile('lib/ShadowMap.lua'))({require=function(n)return assert(modules[n],n)end})
assert(S.frustum()==nil and prepared==0)
assert(S.begin(0,0,256,144));assert(prepared==0,'unused culling allocated planes')
local p=S.frustum();assert(p and prepared==1 and S.frustum()==p and prepared==1)
-- Planes are from the sun matrix, not from the unrelated visible camera.
local expected=Cull.prepare(S.clipVP)
for i=1,6 do for j=1,8 do assert(p[i][j]==expected[i][j])end end
S.finish('a');assert(S.frustum()==nil)
S.KX=.4;assert(S.begin(20,30,512,288))
local q=S.frustum();assert(q~=p and prepared==2)
local changed=false;for i=1,6 do for j=1,4 do if p[i][j]~=q[i][j]then changed=true end end end
assert(changed,'moving sun/camera retained stale light planes')
S.finish('b');S.invalidate();assert(S.frustum()==nil)
print('PASS lazy light-space planes, per-pass reuse, updated camera/sun and inactive fallback')
