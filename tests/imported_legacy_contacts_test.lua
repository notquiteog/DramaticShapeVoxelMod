local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function(path)local f=assert(io.open(path,'rb'));local s=f:read('*a');f:close();return s end}}
V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V)
for _,q in ipairs{
 {'lib/ImportedInteriorData.lua','oras_center_pc',16,16,24,0},
 {'lib/ImportedInteriorTVData.lua','oras_home_tv',16,16,17,6},
 {'lib/ImportedInteriorBedData.lua','oras_comfortable_bed',32,32,18,0},
}do
 local model=dofile(q[1])[q[2]];assert(S.register(q[2],model,{read=V.mod.read}))
 local a=S.vertices(q[2],{width=q[3],depth=q[4],height=q[5],padding=.25})
 local b,fit=S.vertices(q[2],{width=q[3],depth=q[4],height=q[5],padding=.25,groundInset=.025})
 local contacts=0
 for i,p in ipairs(model.parts)do for j,v in ipairs(p.vertices)do
  local before,after=a[i].vertices[j],b[i].vertices[j]
  assert(before[1]==after[1]and before[3]==after[3],'contact repair changed original XZ proportions')
  if math.abs(v[2])<1e-6 then
   assert(after[2]+q[6]==q[6]-.025,'physical bottom remains coplanar with native floor/cabinet')
   contacts=contacts+1
  else assert(before[2]==after[2],'contact repair moved upper source geometry')end
 end end
 assert(contacts>0 and fit.bounds[2]==-.025)
end
print('PASS original PC, TV/cabinet and bed contacts recess only physical bottom vertices')
