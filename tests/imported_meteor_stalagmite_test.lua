local model=dofile('lib/ImportedMeteorStalagmiteData.lua').oras_meteor_stalagmite
local checks=0
local function check(v,s)assert(v,s);checks=checks+1 end
check(#model.parts==2 and #model.parts[1].indices==60 and #model.parts[2].indices==24,'source/closure ownership')
local edges={}
local function key(v)return string.format('%.8f:%.8f:%.8f',v[1],v[2],v[3])end
for _,p in ipairs(model.parts)do
 check(p.texture=='assets/scenery/oras-meteor-stalagmite/d101r_gake01.png','original rock paint')
 for _,c in ipairs(p.colors)do check(c[1]==1 and c[2]==1 and c[3]==1 and c[4]==1,'baked vertex light')end
 for i=1,#p.indices,3 do
  local q={};for j=0,2 do q[#q+1]=key(p.vertices[p.indices[i+j]])end
  for j=1,3 do local a,b=q[j],q[j%3+1];local k=a<b and a..'/'..b or b..'/'..a;edges[k]=(edges[k]or 0)+1 end
 end
end
for _,n in pairs(edges)do check(n==2,'source spike rear/foot rim is not closed exactly once')end
local V={mod={read=function(path)local f=assert(io.open(path,'rb'));local s=f:read('*a');f:close();return s end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}}
V.require=function(name)return assert(modules[name],name)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);check(S.register('spike',model,{read=V.mod.read}))
local a=S.vertices('spike',{width=16,depth=16,height=32,padding=.25})
local b,fit=S.vertices('spike',{width=16,depth=16,height=32,padding=.25,groundInset=.025})
local contacts=0
for i,p in ipairs(b)do for j,v in ipairs(p.vertices)do local old=a[i].vertices[j]
 check(v[1]>=.25 and v[1]<=15.75 and v[3]>=.25 and v[3]<=15.75,'rock leaves blocked foot cell')
 check(old[1]==v[1]and old[3]==v[3],'contact recess moved footprint')
 if math.abs(old[2])<1e-7 then check(v[2]==-.025);contacts=contacts+1 else check(v[2]==old[2],'contact recess moved upper source')end
end end
check(contacts>0 and fit.bounds[2]==-.025 and math.abs(fit.bounds[5]-32)<1e-8,'source height/contact')
check(math.abs((fit.bounds[4]-fit.bounds[1])/32-16/46)<1e-8 and math.abs((fit.bounds[6]-fit.bounds[3])/32-14/46)<1e-8,'nonuniform original proportions')
local available=false;local submitted
modules.SceneryModels={info=function()return true end,register=function()return true end,
 buildBatches=function(list,mesh,opts)submitted=list;if not available then return nil,'missing source paint'end;return opts.parts end}
modules.Gen3PublicPCFrames=dofile('lib/Gen3PublicPCFrames.lua');modules.ImportedMeteorStalagmiteData={oras_meteor_stalagmite=model}
local I=assert(loadfile('lib/Gen3ImportedInteriors.lua'))(V)
local Columns=assert(loadfile('lib/Gen3CaveColumns.lua'))(V)
local r=Columns.recipes[1];local p={cx=4,cy=8,w=16,d=32,pair=r.pair,recipe=r,groundHeight=0}
local cells={};for row=1,2 do cells['4:'..(7+row)]={mid=r.rows[row][1],collision=7,primary='general',pair=r.pair,prop=p,base=0}end
check(I.eligible(p,cells),'exact native spike not eligible')
for _,field in ipairs{'mid','collision','primary','pair','prop','base','boundary','stageHidden','stairs','civic'}do
 local c=cells['4:9'];local old=c[field];c[field]=field=='base'and 1 or field=='mid'and 0x255 or false
 if field=='boundary'or field=='stageHidden'or field=='stairs'or field=='civic'then c[field]=true end
 check(not I.eligible(p,cells),'incorrect native '..field..' accepted');c[field]=old
end
local original=r.kind;r.kind='wall';check(not I.eligible(p,cells),'wall substitutes for independent spike');r.kind=original
local parts={};check(not I.build(cells,function()end,parts)and not p.importedInterior,'failed upload hides native spike')
available=true;local result,err,count=I.build(cells,function()end,parts)
check(result==parts and not err and count==1 and p.importedInterior=='oras_meteor_stalagmite','successful atomic ownership')
local item=submitted[1];check(item.x==64 and item.z==144 and item.y==0 and item.fit.groundInset==.025,'source misplaced from last blocked foot row')
modules.SceneryModels=S;modules.Gen3ImportedInteriors={register=function()return true end}
local C=assert(loadfile('lib/Gen3CaveColumns.lua'))(V);C.id='spike'
local emitted=0;C.append(p,function(q,uv,shade)
 emitted=emitted+1;check(q[4]==q[3]and shade==1,'fallback source triangle changed')
 for _,v in ipairs(q)do check(v[1]>=64.25 and v[1]<=79.75 and v[3]>=144.25 and v[3]<=159.75,'fallback leaves native foot')end
end,function(x,y)check(x==7 and y>=0 and y<=31,'fallback samples outside native gold art');return{}end)
check(emitted==28,'missing-paint fallback is not a closed source-volume spike')
local edition='emerald';package.loaded['src.core.GameVersion']={get=function()return edition end}
local F=dofile('lib/Gen3Furniture.lua')
local function extract(first,second,pair)
 return F.extract({['2:3']={cx=2,cy=3,mid=0x254,collision=first,primary='general',pair=pair or r.pair,ts={}},
 ['2:4']={cx=2,cy=4,mid=0x25C,collision=second,primary='general',pair=pair or r.pair,ts={}}})
end
for _,ed in ipairs{'emerald','ruby','sapphire'}do edition=ed;local props=extract(7,7);check(#props==1 and props[1].recipe.name==r.name,'edition lost exact complete spike')end
for _,coll in ipairs{0,43}do check(#extract(coll,7)==0 and #extract(7,coll)==0,'walkable native spike copy claimed')end
check(#extract(7,7,'general__cave')==0,'different cave family claimed')
for _,ed in ipairs{'firered','leafgreen'}do edition=ed;check(#extract(7,7)==0,'Kanto art mistaken for Meteor spike')end
print('PASS Meteor source closed edges, uniform fit, bottom-only contact, native identity and atomic source/native fallback '..checks..' contracts')
