local m=dofile('lib/ImportedFlowerBookcaseData.lua').oras_flower_bookcase
assert(#m.parts==4)
for i,n in ipairs{312,164,86,58}do assert(#m.parts[i].indices/3==n)end
for _,i in ipairs{1,3}do assert(m.parts[i].texture=='assets/scenery/oras-flower-bookcase/books02.png')end
for _,i in ipairs{2,4}do local p=m.parts[i];assert(p.texture=='assets/scenery/oras-flower-bookcase/bookshelf01.png')
 for _,c in ipairs(p.colors)do assert(c[1]==1 and c[2]==1 and c[3]==1 and c[4]==1,'wood vertex lighting returned')end
end
local edges={};local points={}
for _,i in ipairs{1,3}do local p=m.parts[i]
 for at=1,#p.indices,3 do local keys={}
  for k=0,2 do local v=p.vertices[p.indices[at+k]];keys[#keys+1]=string.format('%.7f/%.7f/%.7f',v[1],v[2],v[3])end
  for k=1,3 do local a,b=keys[k],keys[k%3+1];local key=a<b and a..':'..b or b..':'..a;edges[key]=(edges[key]or 0)+1 end
 end
end
for _,n in pairs(edges)do assert(n==2,'an original book cover has an exposed rim or duplicate cap')end
local V={mod={read=function(path)local f=assert(io.open(path,'rb'));local s=f:read('*a');f:close();return s end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}};V.require=function(name)return assert(modules[name],name)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);assert(S.register('bookcase',m,{read=V.mod.read}))
local a=S.vertices('bookcase',{width=32,depth=16,height=32,padding=.25,rotation=3})
local b,fit=S.vertices('bookcase',{width=32,depth=16,height=32,padding=.25,rotation=3,groundInset=.025});local contacts=0
for i,p in ipairs(b)do for j,v in ipairs(p.vertices)do local old=a[i].vertices[j]
 assert(v[1]==old[1]and v[3]==old[3]and v[1]>=.25 and v[1]<=31.75 and v[3]>=.25 and v[3]<=15.75)
 if math.abs(old[2])<1e-7 then assert(v[2]==-.025);contacts=contacts+1 else assert(v[2]==old[2])end
end end
assert(contacts>0 and fit.bounds[2]==-.025 and fit.bounds[5]>21 and fit.bounds[5]<23)
print('PASS twenty sealed original books, distinct wood/book closure materials, original proportions and cap-only native contact recess')
