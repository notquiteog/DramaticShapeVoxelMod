local M=dofile('lib/ArchitecturalDetails.lua')
local uv={{0,0},{1,0},{1,1},{0,1}}
local vertices={}
M.box(function(v)vertices[#vertices+1]=v end,0,0,0,3,4,5,uv)
assert(#vertices==6,'structural box must close every side')
local edges={}
for _,v in ipairs(vertices)do for i=1,4 do
 local a,b=table.concat(v[i],','),table.concat(v[i%4+1],',');local k=a<b and a..'/'..b or b..'/'..a
 edges[k]=(edges[k]or 0)+1
end end
for _,n in pairs(edges)do assert(n==2,'open structural edge')end
local minz,maxz=100,-100
M.opening(function(v)for _,p in ipairs(v)do minz=math.min(minz,p[3]);maxz=math.max(maxz,p[3])end end,0,3,12,17,0,uv,uv)
assert(minz<0 and maxz>1,'window needs a reveal and sill, not coincident cards')
for _,style in ipairs({'gable','barrel'})do
 local top,faces=0,0
 M.roof({w=64,back=2,front=63,roofEnd=33,wall=30},style,13,function()return uv end,function(v)
  faces=faces+1;for _,p in ipairs(v)do assert(p[2]>=28.8);top=math.max(top,p[2])end
 end,uv)
 assert(top>=43 and faces>25,'authored roof missing rise or closed perimeter')
end
print('PASS closed structural solids, recessed window profile and separate pitched/barrel roofs')
