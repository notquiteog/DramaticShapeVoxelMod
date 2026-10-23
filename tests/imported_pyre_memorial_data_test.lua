local m=dofile('lib/ImportedPyreMemorialData.lua').oras_pyre_memorial
assert(#m.parts==4 and #m.parts[1].indices/3==72 and #m.parts[2].indices/3==36 and #m.parts[3].indices/3==16 and #m.parts[4].indices/3==79)
for _,p in ipairs(m.parts)do
 assert(p.texture=='assets/scenery/oras-pyre-memorial/d108_obj1.png'and p.alphaMode=='cutout')
 for _,c in ipairs(p.colors)do assert(c[1]==1 and c[2]==1 and c[3]==1 and c[4]==1,'source lighting returned')end
end
local function edges(parts)
 local out={}
 for _,entry in ipairs(parts)do local p=entry[1]
  for i=entry[2]or 1,entry[3]or #p.indices,3 do
   local ps={};for j=0,2 do local v=p.vertices[p.indices[i+j]];ps[#ps+1]={key=string.format('%.7f/%.7f/%.7f',v[1],v[2],v[3]),v=v}end
   for j=1,3 do local a,b=ps[j],ps[j%3+1];local key=a.key<b.key and a.key..':'..b.key or b.key..':'..a.key
    local r=out[key]or{count=0,a=a.v,b=b.v};r.count=r.count+1;out[key]=r
   end
  end
 end
 return out
end
-- Omitted original back follows the actual stepped rear silhouette, and the
-- closed underside joins every original base boundary edge exactly once.
for _,e in pairs(edges{{m.parts[2]},{m.parts[4],1,22*3}})do assert(e.count==2,'base has an open or duplicate closure')end
-- Remaining attachment rim edges terminate inside existing source surfaces.
-- No second horizontal/plaque-back cap duplicates those original faces.
local top=(16.014989852905273-.5162001252174377)/14.719207763671875
local count=0
for _,e in pairs(edges{{m.parts[1]},{m.parts[4],22*3+1,55*3}})do
 assert(e.count<=2)
 if e.count==1 then count=count+1;assert(math.abs(e.a[2]-top)<1e-7 and math.abs(e.b[2]-top)<1e-7,'arch joint has an exposed rim')end
end
assert(count==5)
count=0
local front=(105.99829864501953-100.01578521728516)/14.719207763671875
for _,e in pairs(edges{{m.parts[3]},{m.parts[4],55*3+1}})do
 assert(e.count<=2)
 if e.count==1 then count=count+1;assert(math.abs(e.a[3]-front)<1e-7 and math.abs(e.b[3]-front)<1e-7,'plaque joint has an exposed rim')end
end
assert(count==6)
local V={mod={read=function(path)local f=io.open(path,'rb');if not f then return end;local s=f:read('*a');f:close();return s end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}};V.require=function(name)return assert(modules[name],name)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);assert(S.register('grave',m,{read=V.mod.read}))
local a=S.vertices('grave',{width=16,depth=16,height=17,padding=.25})
local b,fit=S.vertices('grave',{width=16,depth=16,height=17,padding=.25,groundInset=.025});local contacts=0
for i,p in ipairs(b)do for j,v in ipairs(p.vertices)do local old=a[i].vertices[j]
 assert(v[1]==old[1]and v[3]==old[3]and v[1]>=.25 and v[1]<=15.75 and v[3]>=.25 and v[3]<=15.75)
 if math.abs(old[2])<1e-7 then assert(v[2]==-.025);contacts=contacts+1 else assert(v[2]==old[2],'floor contact moved original upper geometry')end
end end
assert(contacts>0 and fit.bounds[2]==-.025 and math.abs(fit.bounds[5]-17)<1e-7)
assert(fit.bounds[4]-fit.bounds[1]>12 and fit.bounds[6]-fit.bounds[3]>12,'source is undersized inside native blocked grave cell')
print('PASS original memorial arch/base/plaque, exact angled closures, sealed attachment joints, native fit and floor recess')
