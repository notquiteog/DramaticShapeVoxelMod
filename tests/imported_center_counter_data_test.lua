local model=dofile('lib/ImportedCenterCounterData.lua').oras_center_reception_counter
assert(#model.parts==8)
local count=0
for _,p in ipairs(model.parts)do count=count+#p.indices/3
 assert(p.texture=='assets/scenery/oras-center-counter/pc_uke01.png')
 for _,c in ipairs(p.colors)do assert(c[1]==1 and c[2]==1 and c[3]==1 and c[4]==1)end
end
assert(count==160)
local union=model.parts[8];local function areaAt(height)
 local area=0
 for i=1,#union.indices,3 do local a,b,c=union.vertices[union.indices[i]],union.vertices[union.indices[i+1]],union.vertices[union.indices[i+2]]
  if math.abs(a[2]-height/122)<1e-9 and math.abs(b[2]-height/122)<1e-9 and math.abs(c[2]-height/122)<1e-9 then
   area=area+math.abs((b[1]-a[1])*(c[3]-a[3])-(b[3]-a[3])*(c[1]-a[1]))/2*122*122
  end
 end
 return area
end
assert(math.abs(areaAt(14)-660)<1e-5,'underside includes internal base cap or loses exposed overhang')
assert(math.abs(areaAt(0)-1938)<1e-5,'floor cap crosses original U-shaped staff opening')
for i=2,4 do for _,v in ipairs(model.parts[i].vertices)do assert(v[2]<=14/122+1e-9,'buried base end retained')end end
for _,v in ipairs(model.parts[6].vertices)do assert(v[2]>18/122,'thin original plaque touches the counter top')end
local V={mod={read=function(path)local f=assert(io.open(path,'rb'));local s=f:read('*a');f:close();return s end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}}
V.require=function(name)return assert(modules[name],name)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);assert(S.register('counter',model,{read=V.mod.read}))
for _,width in ipairs{96,112}do
 local a=S.vertices('counter',{width=width,depth=48,height=32,padding=.25})
 local b,fit=S.vertices('counter',{width=width,depth=48,height=32,padding=.25,groundInset=.025})
 local contacts=0
 for i,p in ipairs(b)do
  for j,v in ipairs(p.vertices)do local old=a[i].vertices[j]
   assert(old[1]==v[1]and old[3]==v[3])
   if math.abs(old[2])<1e-7 then assert(v[2]==-.025);contacts=contacts+1 else assert(v[2]==old[2])end
  end
  -- Every triangle lies within the union of the two blocked arms and native
  -- front row. Sample its entire barycentric grid, including every edge.
  for k=1,#p.indices,3 do local q={p.vertices[p.indices[k]],p.vertices[p.indices[k+1]],p.vertices[p.indices[k+2]]}
   for u=0,20 do for v=0,20-u do local weights={u/20,v/20,1-(u+v)/20};local x,z=0,0
    for j,w in ipairs(weights)do x=x+q[j][1]*w;z=z+q[j][3]*w end
    assert(x>=.25-1e-7 and x<=width-.25+1e-7 and z>=.25-1e-7 and z<=47.75+1e-7)
    assert(z>=32-1e-7 or x<=16+1e-7 or x>=width-16-1e-7,'counter enters native staff lane')
   end end
  end
 end
 assert(contacts>0 and fit.bounds[2]==-.025)
 assert(math.abs(fit.bounds[5]-18.321500778198242*(width-.5)/122)<1e-7,'original counter proportions changed')
end
-- Contact union uses no underside across the source base cross-section.
local check=assert(loadfile('tests/imported_interior_surface_planes_test.lua'))('helper')
check(model,160)
print('PASS original U-counter, source proportions, full triangular blocked-footprint containment and single exposed surface owners')
