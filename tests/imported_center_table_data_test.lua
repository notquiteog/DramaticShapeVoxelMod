local model=dofile('lib/ImportedCenterTableData.lua').oras_center_glass_table
assert(#model.parts==10)
local count=0
for i,p in ipairs(model.parts)do
 count=count+#p.indices/3
 assert(p.texture=='assets/scenery/oras-center-table/pc_tbl01.png')
 for _,c in ipairs(p.colors)do assert(c[1]==1 and c[2]==1 and c[3]==1 and c[4]==1,'source lighting returned')end
 if i>=6 and i<=9 then assert(#p.indices==54,'buried leg clipping changed')end
end
assert(count==258 and #model.parts[10].indices==276)
local span=31.5;local seat=(7.616489887237549-1.5)/span
for i=6,9 do for _,v in ipairs(model.parts[i].vertices)do assert(v[2]<=seat+1e-9,'buried table leg remains')end end
-- Four reflection ribbons preserve the original clearance above the glass.
for i=2,5 do for _,v in ipairs(model.parts[i].vertices)do assert(math.abs(v[2]-9.5/span)<1e-9)end end
local cap=model.parts[10];local area=0
local function triangles(callback)
 for i=1,#cap.indices,3 do local a,b,c=cap.vertices[cap.indices[i]],cap.vertices[cap.indices[i+1]],cap.vertices[cap.indices[i+2]]
  if math.abs(a[2]-seat)<1e-9 and math.abs(b[2]-seat)<1e-9 and math.abs(c[2]-seat)<1e-9 then callback(a,b,c)end
 end
end
triangles(function(a,b,c)area=area+math.abs((b[1]-a[1])*(c[3]-a[3])-(b[3]-a[3])*(c[1]-a[1]))/2 end)
assert(math.abs(area*span*span-909.9299112078988)<1e-6,'exposed underside area changed')
local function facesAt(sx,sz)
 local x,z=(sx-92.25)/span,(sz-15.75)/span;local count=0
 local function side(a,b)return(b[1]-a[1])*(z-a[3])-(b[3]-a[3])*(x-a[1])end
 triangles(function(a,b,c)local u,v,w=side(a,b),side(b,c),side(c,a)
  if(u>1e-10 and v>1e-10 and w>1e-10)or(u< -1e-10 and v< -1e-10 and w< -1e-10)then count=count+1 end
 end)
 return count
end
for _,q in ipairs{{103.5,4.5},{81,4.5},{103.5,27},{81,27}}do assert(facesAt(q[1],q[2])==0,'cap crosses internal leg joint')end
assert(facesAt(92.1,15.9)==1,'exposed table underside missing or duplicated')
local V={mod={read=function(path)local f=io.open(path,'rb');if not f then return end;local s=f:read('*a');f:close();return s end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}}
V.require=function(name)return assert(modules[name],name)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);assert(S.register('table',model,{read=V.mod.read}))
local a=S.vertices('table',{width=32,depth=32,height=16,padding=.25})
local b,fit=S.vertices('table',{width=32,depth=32,height=16,padding=.25,groundInset=.025})
local contacts=0
for i,p in ipairs(b)do for j,v in ipairs(p.vertices)do local old=a[i].vertices[j]
 assert(v[1]==old[1]and v[3]==old[3]and v[1]>=.25-1e-8 and v[1]<=31.75+1e-8 and v[3]>=.25-1e-8 and v[3]<=31.75+1e-8,'table crosses native blocked cells')
 if math.abs(old[2])<1e-7 then assert(v[2]==-.025);contacts=contacts+1 else assert(v[2]==old[2],'contact recess moved upper source')end
end end
assert(contacts>0 and fit.bounds[2]==-.025 and math.abs(fit.bounds[5]-9.5)<1e-7,'original proportions changed')
print('PASS original Center table, exact exposed leg union, reflection clearance, uniform native bounds and contact-only recess')
