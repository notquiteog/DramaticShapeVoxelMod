local m=dofile('lib/ImportedOldaleSinkData.lua').oras_oldale_kitchen_sink
assert(#m.parts==2 and #m.parts[1].indices/3==484 and #m.parts[2].indices/3==86)
local tints={};local count=0
for _,p in ipairs(m.parts)do
 assert(p.alphaMode=='cutout'and p.texture=='assets/scenery/oras-oldale-sink/sink01.png')
 for i,c in ipairs(p.colors)do
  assert(c[4]==1 and math.max(c[1],c[2],c[3])<=1)
  if math.max(c[1],c[2],c[3])-math.min(c[1],c[2],c[3])<.001 then
   assert(c[1]==1 and c[2]==1 and c[3]==1,'baked grayscale sink shading returned')
  else tints[string.format('%.6f/%.6f/%.6f',c[1],c[2],c[3])]=true end
  count=count+1;assert(#p.vertices[i]==6)
 end
end
local n=0;for _ in pairs(tints)do n=n+1 end;assert(n==2,'original blue and warm ceramic cup tints changed')
assert(tints['0.881890/0.606299/0.503937']and tints['0.503937/0.795276/0.881890'])
local V={mod={read=function(path)local f=io.open(path,'rb');if not f then return end;local s=f:read('*a');f:close();return s end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}}
V.require=function(name)return assert(modules[name],name)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);assert(S.register('sink',m,{read=V.mod.read}))
local a=S.vertices('sink',{width=32,depth=16,height=32,rotation=1,padding=.25})
local b,fit=S.vertices('sink',{width=32,depth=16,height=32,rotation=1,padding=.25,groundInset=.025})
local contacts=0
for i,p in ipairs(b)do for j,v in ipairs(p.vertices)do local old=a[i].vertices[j]
 assert(v[1]==old[1]and v[3]==old[3]and v[1]>=.25 and v[1]<=31.75 and v[3]>=.25 and v[3]<=15.75,'source crosses native blocked body')
 if math.abs(old[2])<1e-7 then assert(v[2]==-.025);contacts=contacts+1 else assert(v[2]==old[2],'bottom recess moved upper source')end
end end
assert(contacts>0 and fit.bounds[2]==-.025 and fit.bounds[5]<14)
assert(math.abs((fit.bounds[4]-fit.bounds[1])/(fit.bounds[6]-fit.bounds[3])-52/16)<1e-6,'source proportions changed')
-- The joined countertop has one exposed underside ring and no second lid
-- covering the cabinet interior. Query ordinary off-edge points in source X/Z.
local function facesAt(x,z)
 local count=0
 local function side(a,b)return(b[1]-a[1])*(z-a[3])-(b[3]-a[3])*(x-a[1])end
 for _,p in ipairs(m.parts)do for i=1,#p.indices,3 do
  local a,b,c=p.vertices[p.indices[i]],p.vertices[p.indices[i+1]],p.vertices[p.indices[i+2]]
  if math.abs(a[2]-.9375)<1e-6 and math.abs(b[2]-.9375)<1e-6 and math.abs(c[2]-.9375)<1e-6 then
   local u,v,w=side(a,b),side(b,c),side(c,a)
   if(u>1e-9 and v>1e-9 and w>1e-9)or(u<-1e-9 and v<-1e-9 and w<-1e-9)then count=count+1 end
  end
 end end
 return count
end
assert(facesAt(.469,.113)==1 and facesAt(-.469,-.291)==1 and facesAt(.123,1.59)==1 and facesAt(-.219,-1.59)==1,'exposed counter underside is open or covered twice')
assert(facesAt(.131,.219)==0,'duplicate cabinet lid occupies the joined counter plane')
local f=assert(io.open(m.parts[1].texture,'rb'));assert(f:read(8)=='\137PNG\r\n\26\n');f:close()
print('PASS exact ORAS kitchen sink source, ceramic tints, unlit worktop, original basin/faucet, native blocked fit and recessed bottom')
