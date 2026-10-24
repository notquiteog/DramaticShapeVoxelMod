local model=dofile('lib/ImportedCenterHealerData.lua').oras_center_healer
assert(#model.parts==3 and #model.parts[1].indices==444*3 and #model.parts[2].indices==30 and #model.parts[3].indices==96*3)
for _,p in ipairs(model.parts)do for _,c in ipairs(p.colors)do assert(c[1]==1 and c[2]==1 and c[3]==1 and c[4]==1,'source lighting returned')end end
local V={mod={read=function(self,path)
 path=path or self;local f=io.open(path,'rb');if not f then return end;local s=f:read('*a');f:close();return s
end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end},Gen3PublicPCFrames={},ImportedCenterHealerData={oras_center_healer=model}}
V.require=function(name)return assert(modules[name],name)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
assert(S.register('oras_center_healer',model,{read=function(path)return V.mod:read(path)end}))
local I=assert(loadfile('lib/Gen3ImportedInteriors.lua'))(V)
local native=S.vertices('oras_center_healer',{width=32,depth=32,height=28,padding=.25})
local inset,fit=S.vertices('oras_center_healer',{width=32,depth=32,height=28,padding=.25,groundInset=.025})
for i,p in ipairs(inset)do for j,v in ipairs(p.vertices)do local old=native[i].vertices[j]
 assert(v[1]==old[1]and v[3]==old[3]and v[1]>=.25-1e-8 and v[1]<=31.75+1e-8 and v[3]>=.25-1e-8 and v[3]<=31.75+1e-8)
 assert(math.abs(old[2])<1e-7 and v[2]==-.025 or old[2]==v[2],'contact recess moved upper source')
end end
assert(fit.bounds[2]==-.025 and fit.bounds[5]>24 and fit.bounds[5]<25,'source proportions changed')
local Balls=dofile('lib/Gen3HealingBalls.lua')
for _,pair in ipairs{'building__pokemon_center','network'}do
 local p={cx=5,cy=1,groundHeight=8,pair=pair,recipe={name='center_healer'}}
 assert(not I.healingSurface(p),'failed/unmarked upload exposed source animation')
 p.importedInterior='oras_center_healer';local surface=assert(I.healingSurface(p))
 local v=surface.vertices;local radius=surface.balls.radius
 assert(#v==4 and #surface.balls.centers==6 and radius>1.5 and radius<1.6)
 assert(v[1][2]>26 and v[1][2]<27 and v[1][1]>80 and v[2][1]<112 and v[1][3]>16 and v[3][3]<48)
 for _,c in ipairs(surface.balls.centers)do
  assert(c[1]-radius>v[1][1]and c[1]+radius<v[2][1]and c[3]-radius>v[1][3]and c[3]+radius<v[3][3],'ball crosses original flat tray')
  assert(math.abs(c[2]-radius-v[1][2])<1e-8,'sphere floats above or intersects source tray')
 end
 for count=0,6 do
  local pixels={}
  for i=0,count-1 do local col,row=i%2,math.floor(i/2)
   for y=1,6 do for x=1,6 do pixels[(9+col*6+x)..':'..(4+row*4+y)]=true end end
  end
  local data={getPixel=function(_,x,y)return 1,1,1,pixels[x..':'..y]and 1 or 0 end};local quads=0
  local n=Balls.append(data,80,7.18,16,function(q)
   quads=quads+1
   for _,a in ipairs(q)do assert(a[1]>v[1][1]and a[1]<v[2][1]and a[3]>v[1][3]and a[3]<v[3][3]and a[2]>=v[1][2]-1e-8,'native palette sphere escaped source tray')end
  end,surface.balls)
  assert(n==count and quads==count*48,'native timing/count lost with source layout')
 end
 p.pair='unrelated';assert(not I.healingSurface(p))
end
print('PASS exact original healer, uniform bounds/contact recess, upload-owned source surface and native zero-to-six ball layouts')
