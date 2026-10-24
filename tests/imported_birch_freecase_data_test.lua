local m=dofile('lib/ImportedBirchFreecaseData.lua').oras_birch_freestanding_case
assert(#m.parts==5)
for i,n in ipairs{518,292,10,206,68}do local p=m.parts[i];assert(#p.indices/3==n)
 for _,c in ipairs(p.colors)do assert(c[1]==1 and c[2]==1 and c[3]==1 and c[4]==1,'source vertex lighting/alpha returned on opaque lab furniture')end
end
for _,i in ipairs{1,4}do assert(m.parts[i].texture=='assets/scenery/oras-birch-bookcase/t101r0301_book.png')end
for _,i in ipairs{2,5}do assert(m.parts[i].texture=='assets/scenery/oras-birch-bookcase/t101r0301_obj01.png')end
local edges={}
for _,i in ipairs{1,4}do local p=m.parts[i]
 for at=1,#p.indices,3 do local keys={}
  for k=0,2 do local v=p.vertices[p.indices[at+k]];keys[#keys+1]=string.format('%.7f/%.7f/%.7f',v[1],v[2],v[3])end
  for k=1,3 do local a,b=keys[k],keys[k%3+1];local key=a<b and a..':'..b or b..':'..a;edges[key]=(edges[key]or 0)+1 end
 end
end
for _,n in pairs(edges)do assert(n==2,'original lab book group has an exposed rim or duplicate cap')end
-- Outer case and drawer bins close at every original rim vertex,
-- including collinear rear seams and the original tilted drawer underside.
local function closed(ranges)
 local edges={}
 for _,r in ipairs(ranges)do local p=m.parts[r[1]]
  for at=(r[2]-1)*3+1,r[3]*3,3 do local keys={}
   for k=0,2 do local v=p.vertices[p.indices[at+k]];keys[#keys+1]=string.format('%.7f/%.7f/%.7f',v[1],v[2],v[3])end
   for k=1,3 do local a,b=keys[k],keys[k%3+1];local key=a<b and a..':'..b or b..':'..a;edges[key]=(edges[key]or 0)+1 end
  end
 end
 for _,n in pairs(edges)do assert(n==2,'case/bin exact-rim closure has an exposed or duplicate edge')end
end
closed{{2,1,124},{5,1,20}}
closed{{2,125,200},{5,21,40}}
closed{{2,201,276},{5,41,60}}
local box=m.parts[3];assert(box.texture=='assets/scenery/oras-birch-freecase/box01.png')
-- The original carton is open only at its four base edges; the original case
-- top is their support plane. A second carton cap here would overlap that top.
local edges,positions={},{}
for at=1,#box.indices,3 do local keys={}
 for k=0,2 do local v=box.vertices[box.indices[at+k]];local key=string.format('%.7f/%.7f/%.7f',v[1],v[2],v[3]);keys[#keys+1]=key;positions[key]=v end
 for k=1,3 do local a,b=keys[k],keys[k%3+1];local key=a<b and a..':'..b or b..':'..a;edges[key]=(edges[key]or 0)+1 end
end
local boundaries=0;local base=math.huge;local top=-math.huge
for _,v in ipairs(box.vertices)do base=math.min(base,v[2]);top=math.max(top,v[2])end
local caseTop=-math.huge
for _,v in ipairs(m.parts[2].vertices)do caseTop=math.max(caseTop,v[2])end
assert(math.abs(base-caseTop)<1e-8,'carton must rest exactly on the source case top')
for key,n in pairs(edges)do assert(n==1 or n==2);if n==1 then boundaries=boundaries+1;local a,b=key:match('([^:]+):(.+)');assert(math.abs(positions[a][2]-base)<1e-8 and math.abs(positions[b][2]-base)<1e-8,'carton exposed side/top seam')end end
assert(boundaries==4 and top>base)
local V={mod={read=function(path)local f=assert(io.open(path,'rb'));local s=f:read('*a');f:close();return s end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}};V.require=function(name)return assert(modules[name],name)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);assert(S.register('freecase',m,{read=V.mod.read}))
local a=S.vertices('freecase',{width=32,depth=32,height=32,padding=.25})
local b,fit=S.vertices('freecase',{width=32,depth=32,height=32,padding=.25,groundInset=.025});local contacts=0
for i,p in ipairs(b)do for j,v in ipairs(p.vertices)do local old=a[i].vertices[j]
 assert(v[1]==old[1]and v[3]==old[3]and v[1]>=.25 and v[1]<=31.75 and v[3]+16>=16 and v[3]+16<=48,'source body crossed native walkable front row')
 if math.abs(old[2])<1e-7 then assert(v[2]==-.025);contacts=contacts+1 else assert(v[2]==old[2])end
end end
assert(contacts>0 and fit.bounds[2]==-.025 and fit.bounds[5]>26 and fit.bounds[5]<27,'source carton clips the room ceiling')
assert(math.abs(fit.bounds[4]-fit.bounds[1]-31.5)<1e-7 and fit.bounds[6]-fit.bounds[3]>14)
local lo,hi=math.huge,-math.huge
for _,v in ipairs(b[3].vertices)do lo=math.min(lo,v[1]);hi=math.max(hi,v[1])end
assert(math.abs(hi-lo-10)<1e-7,'carton uniform authored fit changed')
print('PASS original 44 closed books, four closed bins, closed case, original carton support, blocked native footprint and cap-only floor recess')
