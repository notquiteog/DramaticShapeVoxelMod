local data=dofile('lib/SaffronCopycatData.lua').hgss_saffron_copycat
local tracked={};local released,uploads=0,0
local modules={SaffronCopycatData={hgss_saffron_copycat=data},BuildBudget={track=function(p)tracked[p]=true end,untrack=function(p)tracked[p]=nil end}}
local registered={};local images=true;local failAt
modules.SceneryModels={info=function(id)return registered[id]end,register=function(id,d)registered[id]=d;return true end,image=function()return images and{}or nil end,releaseBatches=function(parts)for _,p in ipairs(parts)do if p.mesh then p.mesh:release()end end end}
local D=assert(loadfile('lib/Gen3SaffronCopycatDoors.lua'))({require=function(n)return assert(modules[n],n)end,mod={read=function()return nil end}})
local Models=assert(loadfile('lib/SceneryModels.lua'))({require=function(n)return n=='SceneryModelData'and{}or n=='BuildBudget'and{check=function()end}or{}end})
assert(Models.register('body',{parts=data.parts,anchors=data.anchors},{read=function()return nil end}));local fit=assert(Models.fit('body',{width=64,depth=64,padding=.25,groundInset=.05,anchor='door',targetX=24,targetZ=59.25}))
local g={cx=21,cy=10,family='saffron_door_house',pair='general__rom_082d4b9c',width=4,depth=5,groundHeight=0}
assert(D.register());local triangles=0
for _,p in ipairs(data.doorParts)do triangles=triangles+#p.indices/3 end;assert(triangles==16,'all six panel faces must close; original eight triangles retained')
for state=0,2 do
 local parts=assert(D.geometry(g,fit,state));local changed=false
 for i,p in ipairs(parts)do for j,v in ipairs(p.vertices)do
  local native=data.doorParts[i].vertices[j]
  assert(v[1]>=g.cx*16+.25 and v[1]<=g.cx*16+63.75 and v[3]>=(g.cy+1)*16+.25 and v[3]<=(g.cy+1)*16+63.75)
  local sourceZ=(v[3]-(g.cy+1)*16-fit.z)/fit.scale
  assert(sourceZ>=data.anchors.doorHinge[3]-20.511717/60.25-1e-8,'source hinge crosses original interior rear wall')
  assert(v[4]==native[4]and v[5]==native[5]and v[2]==native[2]*fit.scale,'source UV/height changed')
  if state==0 then assert(math.abs(v[1]-(g.cx*16+native[1]*fit.scale+fit.x))<1e-7 and math.abs(v[3]-((g.cy+1)*16+native[3]*fit.scale+fit.z))<1e-7)end
  changed=changed or math.abs(v[3]-((g.cy+1)*16+native[3]*fit.scale+fit.z))>.1
 end end
 assert(state==0 or changed,'door must move inward')
 -- The original broad front remains at85 degrees rather than becoming
 -- coplanar with the source right jamb at90 degrees.
 if state==2 then local a=parts[1].vertices[4];local b=parts[1].vertices[5];assert(math.abs(a[1]-b[1])>.1,'door face coincides with portal wall')end
end
assert(not D.geometry(g,fit,3));local wrong={};for k,v in pairs(fit)do wrong[k]=v end;wrong.width=80;assert(not D.geometry(g,wrong,0))
local function mesh()
 uploads=uploads+1;if uploads==failAt then error('GPU failure')end
 return{setTexture=function()end,release=function()released=released+1 end}
end
images=false;assert(not D.build(g,fit,mesh));assert(not g.importedSaffronCopycatDoors and not next(tracked));images=true
uploads=0;failAt=4;assert(not D.build(g,fit,mesh));assert(released==3 and not g.importedSaffronCopycatDoors and not next(tracked),'partial upload leaks')
failAt=nil;uploads=0;assert(D.build(g,fit,mesh));assert(uploads==6 and D.ownsDoor(g,22,14)and not D.ownsDoor(g,23,14));D.commit(g);assert(not next(tracked))
assert(D.state(g,{x=22,y=14,frame=1})==1 and D.state(g,{x=22,y=14,frame=2})==2 and D.state(g,{x=23,y=14,frame=2})==0)
local n=0;assert(D.draw(g,{x=22,y=14,frame=2},function()n=n+1 end));assert(n==2);D.release(g);assert(not D.ownsDoor(g,22,14)and released==9)
print('PASS Copycat genuine closed panel, original placement/UV, inward noncoplanar native poses and atomic GPU cleanup')
