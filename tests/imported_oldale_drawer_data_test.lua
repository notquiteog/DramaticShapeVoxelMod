local model=dofile('lib/ImportedOldaleDrawerData.lua').oras_oldale_drawer_chest
assert(#model.parts==19)
local count=0
for _,p in ipairs(model.parts)do count=count+#p.indices/3
 assert(p.texture=='assets/scenery/oras-oldale-drawers/t102_shelf04.png')
 for _,c in ipairs(p.colors)do assert(c[1]==1 and c[2]==1 and c[3]==1 and c[4]==1)end
end
assert(count==284)
local floor=(3.5000059604644775-1)/16
local cap=model.parts[19]
local function facesAt(sx,sz,plane)
 local x,z=(sx+171)/16,(sz+279)/16;local count=0
 local function side(a,b)return(b[1]-a[1])*(z-a[3])-(b[3]-a[3])*(x-a[1])end
 for i=1,#cap.indices,3 do local q={};local same=true
  for j=0,2 do local v=cap.vertices[cap.indices[i+j]];q[#q+1]=v
   if math.abs(v[2]-plane(v[3]))>1e-8 then same=false end
  end
  if same then local a,b,c=side(q[1],q[2]),side(q[2],q[3]),side(q[3],q[1])
   if(a>1e-10 and b>1e-10 and c>1e-10)or(a< -1e-10 and b< -1e-10 and c< -1e-10)then count=count+1 end
  end
 end
 return count
end
local function bottom()return floor end
assert(facesAt(-177.1,-285.1,bottom)==0 and facesAt(-177.1,-273.1,bottom)==0,'internal foot cap returned')
assert(facesAt(-170.73,-280.46,bottom)==1,'exposed underside missing/duplicated')
assert(facesAt(-176.25,-271.9,bottom)==1,'exposed original foot overhang missing')
local function ceiling(z)
 local sourceZ=z*16-279
 return(27.49843978881836+(sourceZ+287)*.0030498504638671875/16-1)/16
end
assert(facesAt(-177.3,-280.13,ceiling)==0,'top underside includes internal case cap')
assert(facesAt(-170.73,-280.46,ceiling)==1,'original inner ceiling missing/duplicated')
assert(facesAt(-170.73,-272.8059,ceiling)==0,'top underside includes internal drawer cap')
assert(facesAt(-178.8,-280.13,ceiling)==1,'original outer top overhang missing')
-- Each front is cut around its actual hexagonal knob contact. Source-painted
-- thin backs are separate, while contact sides belong to the existing case.
for panel=9,11 do local p=model.parts[panel];local knob=model.parts[panel-8]
 local x,y=0,0;local n=0
 for _,v in ipairs(knob.vertices)do if math.abs(v[3]-(-272.6763916015625+279)/16)<1e-8 then x=x+v[1];y=y+v[2];n=n+1 end end
 x,y=x/n,y/n;assert(n==6)
 for i=1,#p.indices,3 do local a,b,c=p.vertices[p.indices[i]],p.vertices[p.indices[i+1]],p.vertices[p.indices[i+2]]
  local function side(u,v)return(v[1]-u[1])*(y-u[2])-(v[2]-u[2])*(x-u[1])end
  local u,v,w=side(a,b),side(b,c),side(c,a)
  assert(not((u>1e-10 and v>1e-10 and w>1e-10)or(u< -1e-10 and v< -1e-10 and w< -1e-10)),'panel crosses buried knob contact')
 end
end
local V={mod={read=function(path)local f=assert(io.open(path,'rb'));local s=f:read('*a');f:close();return s end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}}
V.require=function(name)return assert(modules[name],name)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);assert(S.register('chest',model,{read=V.mod.read}))
local a=S.vertices('chest',{width=16,depth=16,height=32,padding=.25})
local b,fit=S.vertices('chest',{width=16,depth=16,height=32,padding=.25,groundInset=.025})
local contacts=0
for i,p in ipairs(b)do for j,v in ipairs(p.vertices)do local old=a[i].vertices[j]
 assert(old[1]==v[1]and old[3]==v[3]and v[1]>=.25-1e-7 and v[1]<=15.75+1e-7 and v[3]>=.25-1e-7 and v[3]<=15.75+1e-7,'source enters native walking apron')
 if math.abs(old[2])<1e-7 then assert(v[2]==-.025);contacts=contacts+1 else assert(v[2]==old[2],'bottom-only recess changed upper source')end
end end
assert(contacts>0 and fit.bounds[2]==-.025 and math.abs(fit.bounds[5]-28.49995994567871*15.5/16)<1e-7,'source proportions changed')
print('PASS original drawer chest, exact foot/ceiling/knob contacts, no internal caps, one-cell blocked fit and source proportions')
