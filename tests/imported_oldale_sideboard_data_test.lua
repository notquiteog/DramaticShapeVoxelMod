local model=dofile('lib/ImportedOldaleSideboardData.lua').oras_oldale_low_sideboard
assert(#model.parts==14)
local count=0
for _,p in ipairs(model.parts)do count=count+#p.indices/3
 assert(p.texture=='assets/scenery/oras-oldale-sideboard/t102_shelf01.png')
 for _,c in ipairs(p.colors)do assert(c[1]==1 and c[2]==1 and c[3]==1 and c[4]==1)end
end
assert(count==254 and #model.parts[1].indices==192 and #model.parts[14].indices==120)
local span=15.34869384765625
local function facesAt(part,sx,sz,height)
 local x,z=(sx+278.9488525390625)/span,(sz+180)/span;local y=(height-1)/span;local count=0
 local function side(a,b)return(b[1]-a[1])*(z-a[3])-(b[3]-a[3])*(x-a[1])end
 for i=1,#part.indices,3 do local a,b,c=part.vertices[part.indices[i]],part.vertices[part.indices[i+1]],part.vertices[part.indices[i+2]]
  if math.abs(a[2]-y)<1e-8 and math.abs(b[2]-y)<1e-8 and math.abs(c[2]-y)<1e-8 then
   local u,v,w=side(a,b),side(b,c),side(c,a)
   if(u>1e-10 and v>1e-10 and w>1e-10)or(u< -1e-10 and v< -1e-10 and w< -1e-10)then count=count+1 end
  end
 end
 return count
end
local wood,runner,cap=model.parts[5],model.parts[1],model.parts[13]
assert(facesAt(wood,-279.137,-185.23,18.51218032836914)==0,'buried wood plane retained below runner')
assert(facesAt(runner,-279.137,-185.23,19)==1,'original painted runner lost or duplicated')
assert(facesAt(wood,-286.2,-185.23,18.51218032836914)==1,'exposed original wood top lost')
assert(facesAt(cap,-280.13,-195.33,16.5)==0,'top underside closes internal side-post joint')
assert(facesAt(cap,-280.13,-180.33,16.5)==0,'top underside closes internal middle joint')
assert(facesAt(cap,-286.4,-185.23,16.5)==1,'original rear overhang missing')
assert(facesAt(cap,-280.13,-185.23,16.5)==1,'exposed inner top underside missing')
assert(facesAt(model.parts[8],-280.13,-180.33,3.5)==0,'lower board crosses internal separator contact')
for _,i in ipairs{2,6}do for _,v in ipairs(model.parts[i].vertices)do assert(v[2]<=(16.5-1)/span+1e-8,'buried original post end remains')end end
for _,v in ipairs(model.parts[14].vertices)do
 assert(v[2]>=(18.51218032836914-1)/span-1e-8 and v[2]<=(19-1)/span+1e-8,'runner rim changes original upper plane')
end
local V={mod={read=function(path)local f=assert(io.open(path,'rb'));local s=f:read('*a');f:close();return s end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}}
V.require=function(name)return assert(modules[name],name)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);assert(S.register('board',model,{read=V.mod.read}))
local a=S.vertices('board',{width=32,depth=16,height=32,rotation=1,padding=.25})
local b,fit=S.vertices('board',{width=32,depth=16,height=32,rotation=1,padding=.25,groundInset=.025})
local contacts=0
for i,p in ipairs(b)do for j,v in ipairs(p.vertices)do local old=a[i].vertices[j]
 assert(old[1]==v[1]and old[3]==v[3]and v[1]>=.25-1e-7 and v[1]<=31.75+1e-7 and v[3]>=.25-1e-7 and v[3]<=15.75+1e-7,'sideboard leaves blocked native first row')
 if math.abs(old[2])<1e-7 then assert(v[2]==-.025);contacts=contacts+1 else assert(v[2]==old[2],'bottom-only recess moved upper source')end
end end
assert(contacts>0 and fit.bounds[2]==-.025 and math.abs(fit.bounds[5]-16.2)<1e-6,'uniform source proportions changed')
print('PASS original sideboard runner/case/separator contact holes, exposed surfaces, source height and blocked-only fit')
