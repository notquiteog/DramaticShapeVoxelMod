local B=dofile('lib/Gen3Bridges.lua');local uv={{0,0},{1,0},{1,1},{0,1}}
local cells={};local row={0x2ee,0x2ce,0x2e5,0x2e6,0x2ef}
for i,mid in ipairs(row)do cells[(i-1)..':0']={cx=i-1,cy=0,mid=mid,primary='general',pair='general__rom_082d4af4',collision=(i==1 or i==5)and 7 or 0,base=12,ts={}}end
assert(B.prepare(cells)==5)
for i=0,4 do local c=cells[i..':0'];local underside,faces=0,0
 B.append(cells,c,function(v)
  faces=faces+1;local under=true
  for _,p in ipairs(v)do
   assert(p[1]>=i*16 and p[1]<=(i+1)*16 and p[3]>=0 and p[3]<=16)
   assert(p[2]>=9 and p[2]<=20);if p[2]~=9 then under=false end
   if i>0 and i<4 then assert(p[2]<=12,'solid obstructs a walking deck')end
  end
  if under then underside=underside+1 end
 end,function()return uv end)
 assert(underside==1 and faces>=3,'bridge missing its underside or exposed fascia')
end
cells['0:0'].collision=0;for _,c in pairs(cells)do c.bridge=nil end
assert(B.prepare(cells)==0,'changed rail permission still claims bridge row')
cells['0:0'].collision=7;cells['1:0'].mid=1;assert(B.prepare(cells)==0,'partial bridge artwork claimed')
local fortree={cx=2,cy=3,mid=0x256,primary='general',secondary='fortree',behavior=0x178,collision=0,base=32,ts={}}
assert(B.prepare({['2:3']=fortree})==1)
local min,max=1e9,-1e9;B.append({},fortree,function(v)for _,p in ipairs(v)do min=math.min(min,p[2]);max=math.max(max,p[2])end end,function()return uv end)
assert(min==29.5 and max==32,'Fortree deck thickness changed walking support')
fortree.bridge=nil;fortree.behavior=0x170;assert(B.prepare({fortree})==0,'ocean warp behavior mistaken for Fortree bridge')
fortree.behavior=0x178;fortree.collision=7;assert(B.prepare({fortree})==0,'blocked copy became a bridge')
print('PASS closed deck undersides/fascia, bounded native rails, exact row/permission ownership and correct Fortree semantic ID')
local ts={cols=1,midToSlot={[0x256]=0},imageData={getPixel=function(_,x,y)
 if x==6 and y==8 then return .9,.85,.7,1 end
 return .1,1,.1,1
end}}
local c={ts=ts,bridge={material=0x256}};local t=B.material(c,uv)[1]
assert(t[1]==6.5/16 and t[2]==8.5/16,'bright grass sampled instead of native planks')
local old=ts.imageData;ts.imageData={getPixel=function(_,x,y)if x==9 and y==8 then return .95,.95,.95,1 end;return .1,1,.1,1 end}
t=B.material(c,uv)[1];assert(t[1]==9.5/16 and t[2]==8.5/16,'provider reload retained stale plank swatch')
print('PASS composited native plank sampling excludes green gaps and refreshes with the provider')
