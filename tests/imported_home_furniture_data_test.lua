local data=dofile('lib/ImportedHomeFurnitureData.lua')
local V={mod={read=function(path)local f=io.open(path,'rb');if not f then return end;local s=f:read('*a');f:close();return s end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}}
V.require=function(name)return assert(modules[name],name)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V)
local expected={oras_littleroot_dining_table={100,190,32,32},oras_littleroot_fridge={92,106,16,16}}
for name,q in pairs(expected)do
 local m=assert(data[name]);local n=0;local edges={}
 assert(#m.parts[1].indices/3==q[1],'source triangles changed')
 for _,p in ipairs(m.parts)do
  n=n+#p.indices/3
  for _,c in ipairs(p.colors)do assert(c[1]==1 and c[2]==1 and c[3]==1 and c[4]==1,'baked source vertex lighting returned')end
  for i=1,#p.indices,3 do
   local points={}
   for j=0,2 do local v=p.vertices[p.indices[i+j]];points[#points+1]=string.format('%.4f/%.4f/%.4f',v[1],v[2],v[3])end
   for j=1,3 do local a,b=points[j],points[j%3+1];local k=a<b and a..':'..b or b..':'..a;edges[k]=(edges[k]or 0)+1 end
  end
  local f=assert(io.open(p.texture,'rb'));assert(f:read(8)=='\137PNG\r\n\26\n');f:close()
 end
 assert(n==q[2],'source closure topology changed')
 for _,count in pairs(edges)do assert(count==2,'source furniture has an open or nonmanifold surface')end
 assert(S.register(name,m,{read=V.mod.read}))
 local vs,fit=S.vertices(name,{width=q[3],depth=q[4],height=32,padding=.25})
 for _,part in ipairs(vs)do for _,v in ipairs(part.vertices)do
  assert(v[1]>=.25-1e-6 and v[1]<=q[3]-.25+1e-6)
  assert(v[3]>=.25-1e-6 and v[3]<=q[4]-.25+1e-6)
  assert(v[2]>=-1e-6 and v[2]<=32+1e-6)
 end end
 assert(fit.bounds[4]-fit.bounds[1]>q[3]*.9,'source proportions underfill blocked footprint')
end
print('PASS original ORAS home source topology, closed undersides, renderer-owned vertex lighting and uniform native-footprint fit')
