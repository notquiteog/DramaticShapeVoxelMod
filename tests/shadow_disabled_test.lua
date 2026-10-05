-- Direct native-adapter entry must honor OFF before touching GPU resources.
local modules={DrawUniforms=dofile('lib/DrawUniforms.lua'),Mat4=dofile('lib/Mat4.lua'),VoxelState={},Shadows={off=function()return true end},CanopyBillboard={shader=''}}
local V={require=function(name)return assert(modules[name],name)end}
love={graphics=setmetatable({},{__index=function(_,key)error('disabled shadow accessed GPU: '..key)end})}
local Shadow=assert(loadfile('lib/ShadowMap.lua'))(V)
assert(Shadow.begin(0,0,256,144)==false)
assert(not Shadow.active())
assert(Shadow.stats().allocations==0)
print('PASS disabled direct shadow pass performs no GPU work')
