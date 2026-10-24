local m=dofile('lib/ImportedOldaleCupboardData.lua').oras_oldale_china_cupboard
assert(#m.parts==2 and #m.parts[1].indices/3==242 and #m.parts[2].indices/3==104)
local tints={};local count=0
for _,p in ipairs(m.parts)do
 assert(p.alphaMode=='cutout'and p.texture=='assets/scenery/oras-oldale-cupboard/t102_shelf02.png')
 for i,c in ipairs(p.colors)do
  assert(c[4]==1 and math.max(c[1],c[2],c[3])<=1)
  if math.max(c[1],c[2],c[3])-math.min(c[1],c[2],c[3])<.001 then
   assert(c[1]==1 and c[2]==1 and c[3]==1,'baked grayscale cupboard shading returned')
  else tints[string.format('%.6f/%.6f/%.6f',c[1],c[2],c[3])]=true end
  count=count+1;assert(#p.vertices[i]==6)
 end
end
local n=0;for _ in pairs(tints)do n=n+1 end;assert(n==3,'original pink dish and red/blue cup tints changed')
assert(tints['1.000000/0.661417/1.000000']and tints['1.000000/0.488189/0.488189']and tints['0.417323/0.464567/0.826772'])
local V={mod={read=function(path)local f=io.open(path,'rb');if not f then return end;local s=f:read('*a');f:close();return s end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}}
V.require=function(name)return assert(modules[name],name)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);assert(S.register('cupboard',m,{read=V.mod.read}))
local a=S.vertices('cupboard',{width=32,depth=16,height=32,padding=.25})
local b,fit=S.vertices('cupboard',{width=32,depth=16,height=32,padding=.25,groundInset=.025})
local contacts=0
for i,p in ipairs(b)do for j,v in ipairs(p.vertices)do local old=a[i].vertices[j]
 assert(v[1]==old[1]and v[3]==old[3]and v[1]>=.25 and v[1]<=31.75 and v[3]>=.25 and v[3]<=15.75,'source crosses native blocked body')
 if math.abs(old[2])<1e-7 then assert(v[2]==-.025);contacts=contacts+1 else assert(v[2]==old[2],'bottom recess moved upper source')end
end end
assert(contacts>0 and fit.bounds[2]==-.025 and fit.bounds[5]<32)
assert(math.abs((fit.bounds[4]-fit.bounds[1])/(fit.bounds[6]-fit.bounds[3])-32/14)<1e-6,'source proportions changed')
local f=assert(io.open(m.parts[1].texture,'rb'));assert(f:read(8)=='\137PNG\r\n\26\n');f:close()
print('PASS exact ORAS cupboard source, ceramic tints, unlit wood, cutout doors, native blocked fit and recessed bottom')
