local data=dofile('lib/OrasBoatData.lua')
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}}
local S=assert(loadfile('lib/SceneryModels.lua'))({require=function(n)return assert(modules[n],n)end})
assert(S.register('oras_briney_boat',data,{read=function(path)local f=assert(io.open(path,'rb'));local s=f:read('*a');f:close();return s end}))
local info=S.info('oras_briney_boat');assert(info.parts==8 and info.bounds[2]==0)
assert(math.abs(info.bounds[3]+.5)<1e-7 and math.abs(info.bounds[6]-.5)<1e-7)
local source,closure,colors=0,0,0
for _,p in ipairs(data.parts)do
 assert(p.alphaMode=='cutout'and p.opacity==1 and p.wrapS=='repeat'and p.wrapT=='repeat')
 assert(not p.texture:find('hamon',1,true),'water/ripple sheet leaked into native actor')
 if p.authored then closure=closure+#p.indices/3;assert(p.name=='authored_keel_underside');for _,v in ipairs(p.vertices)do assert(v[2]==0,'closure left source keel plane')end
  for i=1,#p.indices,3 do local a,b,c=p.vertices[p.indices[i]],p.vertices[p.indices[i+1]],p.vertices[p.indices[i+2]]
   local normalY=(b[3]-a[3])*(c[1]-a[1])-(b[1]-a[1])*(c[3]-a[3]);assert(normalY<0,'keel cap winding must face below hull')
  end
 else source=source+#p.indices/3 end
 assert(#p.colors==#p.vertices);colors=colors+#p.colors
 for _,c in ipairs(p.colors)do assert(#c==4 and c[1]==1 and c[2]==1 and c[3]==1,'baked vertex AO remained');for _,v in ipairs(c)do assert(v>=0 and v<=1)end end
 for _,v in ipairs(p.vertices)do assert(v[2]>=0 and v[1]>=info.bounds[1]and v[1]<=info.bounds[4]and v[3]>=-.5000001 and v[3]<=.5000001)end
end
assert(source==936 and closure==16 and colors==930)
assert(info.anchors.bow[3]==.5 and info.anchors.stern[3]==-.5,'canonical bow+Z changed')
for rotation=0,3 do
 local parts,fit=assert(S.vertices('oras_briney_boat',{width=32,depth=32,padding=.25,rotation=rotation}))
 assert(math.abs(fit.scale-31.5)<1e-6)
 local water=fit.anchors.waterline;assert(math.abs(water[1]-16)<1e-6 and math.abs(water[3]-16)<1e-6)
 assert(water[2]>1.54 and water[2]<1.55,'source waterline lost')
 local lo,hi=math.huge,-math.huge
 for _,p in ipairs(parts)do for _,v in ipairs(p.vertices)do
  assert(v[1]>=.25-1e-7 and v[1]<=31.75+1e-7 and v[3]>=.25-1e-7 and v[3]<=31.75+1e-7,'native32x32 source footprint exceeded')
  lo=math.min(lo,v[2]-water[2]);hi=math.max(hi,v[2]-water[2])
 end end
 assert(lo<0 and hi>9 and hi<10,'source hull draft/cabin height changed')
end
print('PASS genuine ORAS boat936source+16keel triangles, RGBA/repeat UV data, bow+Z, waterline and all32x32 headings')
