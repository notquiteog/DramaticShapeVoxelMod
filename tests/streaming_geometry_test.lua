-- Budget checkpoints may change scheduling, never the generated surfaces.
local now=0
love={timer={getTime=function()now=now+.0001;return now end}}
local B=dofile('lib/BuildBudget.lua')
local H=assert(loadfile('lib/VoxelHull.lua'))({require=function(n)
 if n=='BuildBudget'then return B end
 assert(n=='NativeTreeModels');return dofile('lib/NativeTreeModels.lua')
end})
local function build()
 local q=H.build(32,48,function(x,y)return .2,.5,.1,1,(x+.5)/32,(y+.5)/48 end,2,0,nil,'tree','broad')
 local v,i={},{};H.append(q,v,i,0,10,2,30);return {quads=q,vertices=v,indices=i}
end
local baseline=build();local result
local co=coroutine.create(function()result=build()end);local slices=0
repeat
 B.begin(co,.0002,4);local ok,err=coroutine.resume(co);B.finish();assert(ok,err)
 slices=slices+1;assert(slices<10000)
until coroutine.status(co)=='dead'
local function same(a,b)
 assert(type(a)==type(b))
 if type(a)~='table'then assert(a==b);return end
 for k,v in pairs(a)do same(v,b[k])end
 for k in pairs(b)do assert(a[k]~=nil)end
end
same(baseline,result);assert(slices>10,'hull stayed monolithic')
print('PASS sliced and synchronous hull vertices, indices, native UVs and shading identical:',slices,'slices')
