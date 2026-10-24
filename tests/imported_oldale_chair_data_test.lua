local model=dofile('lib/ImportedOldaleChairData.lua').oras_oldale_backed_chair
assert(#model.parts==11)
local total=0
for i,part in ipairs(model.parts)do
 total=total+#part.indices/3
 assert(part.texture=='assets/scenery/oras-oldale-chair/t102_chair.png'and part.alphaMode=='cutout')
 for _,color in ipairs(part.colors)do assert(color[1]==1 and color[2]==1 and color[3]==1 and color[4]==1,'source lighting returned')end
 if i<=4 then assert(#part.indices==60)end
end
assert(total==270 and #model.parts[11].indices==300)
local span=12.816390991210938;local ox,oz=-134.9999008178711,-169.8792953491211
local seatY=(7.500027656555176-1)/span
-- Read the original seat's actual bottom, rather than a rounded contact plane.
seatY=math.huge;for _,v in ipairs(model.parts[5].vertices)do seatY=math.min(seatY,v[2])end
for i=1,4 do for _,v in ipairs(model.parts[i].vertices)do assert(v[2]<=seatY+1e-12,'buried leg faces remain above the original seat joint')end end
local cap=model.parts[11];local area=0
for i=1,#cap.indices,3 do local a,b,c=cap.vertices[cap.indices[i]],cap.vertices[cap.indices[i+1]],cap.vertices[cap.indices[i+2]]
 if math.abs(a[2]-seatY)<1e-10 and math.abs(b[2]-seatY)<1e-10 and math.abs(c[2]-seatY)<1e-10 then area=area+math.abs((b[1]-a[1])*(c[3]-a[3])-(b[3]-a[3])*(c[1]-a[1]))/2 end
end
assert(math.abs(area*span*span-147.2210765244189)<1e-7,'seat cap did not subtract the four actual leg rims')
local function facesAt(sx,sz)
 local x,z=(sx-ox)/span,(sz-oz)/span;local n=0
 local function side(a,b)return(b[1]-a[1])*(z-a[3])-(b[3]-a[3])*(x-a[1])end
 for i=1,#cap.indices,3 do local a,b,c=cap.vertices[cap.indices[i]],cap.vertices[cap.indices[i+1]],cap.vertices[cap.indices[i+2]]
  if math.abs(a[2]-seatY)<1e-10 and math.abs(b[2]-seatY)<1e-10 and math.abs(c[2]-seatY)<1e-10 then
   local u,v,w=side(a,b),side(b,c),side(c,a);if(u>1e-10 and v>1e-10 and w>1e-10)or(u< -1e-10 and v< -1e-10 and w< -1e-10)then n=n+1 end
  end
 end
 return n
end
for _,q in ipairs{{-138.6,-166.2},{-130.5,-175.0},{-130.5,-166.2},{-138.8,-175.3}}do assert(facesAt(q[1],q[2])==0,'internal cap covers a leg join')end
assert(facesAt(-135.2,-170.1)==1,'exposed seat underside missing or doubled')
local V={mod={read=function(path)local f=io.open(path,'rb');if not f then return end;local s=f:read('*a');f:close();return s end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}};V.require=function(name)return assert(modules[name],name)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);assert(S.register('chair',model,{read=V.mod.read}))
for _,rotation in ipairs{1,3}do
 local a=S.vertices('chair',{width=16,depth=16,height=32,padding=.25,rotation=rotation})
 local b,fit=S.vertices('chair',{width=16,depth=16,height=32,padding=.25,rotation=rotation,groundInset=.025})
 local contacts=0
 for i,part in ipairs(b)do for j,v in ipairs(part.vertices)do local old=a[i].vertices[j]
  assert(v[1]==old[1]and v[3]==old[3]and v[1]>=.25-1e-8 and v[1]<=15.75+1e-8 and v[3]>=.25-1e-8 and v[3]<=15.75+1e-8,'chair crosses native walking cell')
  if math.abs(old[2])<1e-7 then assert(v[2]==-.025);contacts=contacts+1 else assert(v[2]==old[2],'floor inset translated upper chair')end
 end end
 assert(contacts>0 and fit.bounds[2]==-.025 and fit.bounds[5]>18 and fit.bounds[5]<19,'source height/proportions changed')
end
print('PASS genuine unlit chair, exact four-leg seat union, exposed-only caps, original proportions, native left/right one-cell bounds and floor-contact recess')
