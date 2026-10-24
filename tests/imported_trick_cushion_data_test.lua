local m=dofile('lib/ImportedTrickCushionData.lua').oras_trick_house_floor_cushion
assert(#m.parts==2 and #m.parts[1].indices/3==128 and #m.parts[2].indices/3==14)
for _,p in ipairs(m.parts)do assert(p.texture=='assets/scenery/oras-trick-house-cushion/cushions01.png');for _,c in ipairs(p.colors)do assert(c[1]==1 and c[2]==1 and c[3]==1 and c[4]==1)end end
local edges={}
for _,i in ipairs{1,2}do local p=m.parts[i]
 for at=1,#p.indices,3 do local keys={}
  for k=0,2 do local v=p.vertices[p.indices[at+k]];keys[#keys+1]=string.format('%.7f/%.7f/%.7f',v[1],v[2],v[3])end
  for k=1,3 do local a,b=keys[k],keys[k%3+1];local key=a<b and a..':'..b or b..':'..a;edges[key]=(edges[key]or 0)+1 end
 end
end
for _,n in pairs(edges)do assert(n==2,'original lab book group has an exposed rim or duplicate cap')end
local V={mod={read=function(path)local f=assert(io.open(path,'rb'));local s=f:read('*a');f:close();return s end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}};V.require=function(name)return assert(modules[name],name)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);assert(S.register('cushion',m,{read=V.mod.read}))
local a=S.vertices('cushion',{width=16,depth=16,height=4,padding=.25})
local b,fit=S.vertices('cushion',{width=16,depth=16,height=4,padding=.25,groundInset=.025});local contacts=0
for i,p in ipairs(b)do for j,v in ipairs(p.vertices)do local old=a[i].vertices[j]
 assert(v[1]==old[1]and v[3]==old[3]and v[1]>=.25 and v[1]<=15.75 and v[3]>=.25 and v[3]<=15.75)
 if math.abs(old[2])<1e-7 then assert(v[2]==-.025);contacts=contacts+1 else assert(v[2]==old[2])end
end end
assert(contacts>0 and fit.bounds[2]==-.025 and fit.bounds[5]>3.4 and fit.bounds[5]<3.5)
assert(math.abs(fit.bounds[4]-fit.bounds[1]-15.5)<1e-7 and fit.bounds[6]-fit.bounds[3]>15.49,'source proportions changed')
print('PASS original closed low cushion, sixteen exact underside vertices, native walking-cell fit and cap-only floor recess')
