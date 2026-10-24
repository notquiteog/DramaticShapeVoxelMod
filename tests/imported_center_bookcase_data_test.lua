local model=dofile('lib/ImportedCenterBookcaseData.lua').oras_center_bookcase
assert(#model.parts==3)
local count=0
for i,p in ipairs(model.parts)do
 count=count+#p.indices/3
 assert(p.texture=='assets/scenery/oras-center-bookcase/pc_hon01.png')
 for _,c in ipairs(p.colors)do assert(c[1]==1 and c[2]==1 and c[3]==1 and c[4]==1,'source lighting returned')end
 assert(#p.indices==({600,48,24})[i],'reviewed source/contact/closure count changed')
end
assert(count==224)
-- Original lower books touch the case wall and both book rows sit on existing
-- shelves. There must be one plane owner at each of these source contacts.
local function planarArea(axis,source,part)
 local area=0;local value=(source-({-90,1,-99})[axis])/34
 for i=1,#part.indices,3 do local q={}
  for j=0,2 do q[#q+1]=part.vertices[part.indices[i+j]]end
  if math.abs(q[1][axis]-value)<1e-9 and math.abs(q[2][axis]-value)<1e-9 and math.abs(q[3][axis]-value)<1e-9 then
   local dims={};for k=1,3 do if k~=axis then dims[#dims+1]=k end end
   local x,z=dims[1],dims[2]
   area=area+math.abs((q[2][x]-q[1][x])*(q[3][z]-q[1][z])-(q[2][z]-q[1][z])*(q[3][x]-q[1][x]))/2*34*34
  end
 end
 return area
end
assert(planarArea(2,3.75,model.parts[3])==0 and planarArea(2,13.25,model.parts[3])==0,'book bottom cap duplicates shelf')
assert(planarArea(1,-105.75,model.parts[3])==0 and planarArea(1,-74.25,model.parts[3])==0,'book side cap duplicates case')
assert(math.abs(planarArea(2,1,model.parts[2])-33.75)<1e-6,'feet underside bridges original gap')
assert(math.abs(planarArea(2,2.5,model.parts[2])-425.25)<1e-6,'bottom board underside changed')
assert(math.abs(planarArea(3,-105.75,model.parts[2])-692.25)<1e-6,'concave case rear fills foot gap')
local V={mod={read=function(path)local f=io.open(path,'rb');if not f then return end;local s=f:read('*a');f:close();return s end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}}
V.require=function(name)return assert(modules[name],name)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);assert(S.register('case',model,{read=V.mod.read}))
local a=S.vertices('case',{width=32,depth=16,height=32,padding=.25})
local b,fit=S.vertices('case',{width=32,depth=16,height=32,padding=.25,groundInset=.025})
local contacts=0
for i,p in ipairs(b)do for j,v in ipairs(p.vertices)do local old=a[i].vertices[j]
 assert(v[1]==old[1] and v[3]==old[3] and v[1]>=.25-1e-8 and v[1]<=31.75+1e-8
  and v[3]>=.25-1e-8 and v[3]<=15.75+1e-8,'bookcase leaves native blocked footprint')
 if math.abs(old[2])<1e-7 then assert(v[2]==-.025);contacts=contacts+1 else assert(v[2]==old[2],'contact recess moves original upper geometry')end
end end
assert(contacts>0 and fit.bounds[2]==-.025 and math.abs(fit.bounds[5]-23.131799697875977*31.5/34)<1e-7,'source proportions changed')
print('PASS original Center bookcase, exact exposed feet/rear/book ends, single contact owners and native uniform bounds')
