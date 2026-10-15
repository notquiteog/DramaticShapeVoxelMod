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
for _,style in ipairs({'gable','barrel','hipped_barrel'})do
 local top,faces=0,0
 M.roof({w=64,back=2,front=63,roofEnd=33,wall=30},style,13,function()return uv end,function(v)
  faces=faces+1;for _,p in ipairs(v)do assert(p[2]>=28.8);top=math.max(top,p[2]);if style=='hipped_barrel' and p[3]>=63 then assert(p[2]<=30.05,'Hoenn front eave became a tall arched gable')end end
 end,uv)
 assert(top>=43 and faces>25,'authored roof missing rise or closed perimeter')
end
print('PASS closed structural solids, recessed window profile and separate pitched/barrel roofs')

local depth,ring,glass=0,0,0
M.roundOpening(function(v,tex)
 local lo,hi=math.huge,-math.huge
 for i,p in ipairs(v)do
  assert(p[1]>=2-.00001 and p[1]<=15.00001 and p[2]>=5-.00001 and p[2]<=17.00001,'round aperture escapes wall cut')
  assert(tex[i][1]>=-.00001 and tex[i][1]<=1.00001 and tex[i][2]>=-.00001 and tex[i][2]<=1.00001,'window source was cropped outside native art')
  lo=math.min(lo,p[3]);hi=math.max(hi,p[3]);depth=math.min(depth,p[3])
 end
 if lo==.25 and hi==.25 then ring=ring+1 end
 if lo==-.85 and hi==-.85 then glass=glass+1 end
end,2,5,15,17,0,function(x,y)return{x,y}end)
assert(depth==-.85 and ring==32 and glass==32,'round window needs a closed annular frame and recessed disk')
local roof={}
M.roof({w=64,back=8,roofBack=16,front=63,roofEnd=37,wall=26},'flat_panel',0,function()return uv end,function(v)
 roof[#roof+1]=v
 for _,p in ipairs(v)do assert(p[1]>0 and p[1]<64 and p[3]>=16 and p[3]<64,'RS roof escapes native blocked rows')end
end,uv)
assert(#roof==6,'flat roof is not a closed six-sided panel')
print('PASS native circular aperture, continuous frame/glazing, and closed RS roof footprint')
