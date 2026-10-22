local B=dofile('lib/Gen3SecretBases.lua')
local families={'red_cave','blue_cave','brown_cave','yellow_cave','shrub','tree'}
for _,name in ipairs(families)do
 local secondary='secret_base_'..name;local spec={primary='secret_base',secondary=secondary}
 assert(B.supports({mapType=9},spec));assert(not B.supports({mapType=8},spec))
 local p=B.profile({mapType=9,width=11,height=9},spec)
 assert(p.secretBase and p.cave and p.height==32 and p.bounds[3]==176)
 for _,mid in ipairs{0x201,0x202,0x203,0x205,0x207,0x209,0x20b,0x20d,0x20f,0x210,0x211,0x212,0x213}do
  local s=B.shape('secret_base',secondary,mid,nil,7)
  assert(s.kind=='caveWall'and s.height==32 and s.cap==0x210 and s.side==0x202 and s.ground==0x20a)
  assert(B.shape('secret_base',secondary,mid,nil,0).kind=='flat','walkable wall copy raised')
 end
 assert(B.shape('secret_base',secondary,0x204,nil,0x72).reviewedSurface)
 assert(B.shape('secret_base',secondary,0x220,nil,7).secretBase=='pc')
 assert(B.shape('secret_base',secondary,0x20c,nil,7).secretBase=='door')
 assert(B.shape('secret_base',secondary,0x222,nil,7).secretBase=='pit')
 for _,mid in ipairs{0x20e,0x214,0x230,0x280,0x102}do
  assert(B.shape('secret_base',secondary,mid,nil,0).kind=='flat','native decoration/clearance changed')
 end
end
assert(not B.shape('building','secret_base_tree',0x201,nil,7))
assert(not B.supports({mapType=9},{primary='secret_base',secondary='unknown'}))
local uv={{0,0},{1,0},{1,1},{0,1}};local function uvFor()return uv end
local function fixture(mid,sub)
 return{cx=3,cy=4,mid=mid,ts={midToSlot={[mid]=0},cols=1,
  imageData={getPixel=function(_,x,y)if x>=4 and x<12 and y>=2 then return .1,.1,.1,1 end;return .5,.3,.2,1 end}},
  shape={kind='secretBaseProp',secretBase=sub}}
end
local function mesh(c,cells)
 local out={};assert(B.append(cells or{},c,function(p,t,shade)out[#out+1]=p;assert(#t==4)end,uvFor))
 for _,face in ipairs(out)do for _,v in ipairs(face)do assert(v[1]>=48 and v[1]<=64 and v[3]>=64 and v[3]<=80,'native footprint escaped')end end
 return out
end
local pc=fixture(0x220,'pc');local faces=mesh(pc);assert(#faces>12)
local door=fixture(0x20c,'door');faces=mesh(door)
for _,f in ipairs(faces)do local y=0;for _,v in ipairs(f)do y=math.max(y,v[2])end
 if y>0 then
  local left,right,low,high=math.huge,-math.huge,math.huge,-math.huge
  for _,v in ipairs(f)do left=math.min(left,v[1]-48);right=math.max(right,v[1]-48);low=math.min(low,v[2]);high=math.max(high,v[2])end
  assert(right<=2 or left>=14 or low>=24,'entry opening obstructed')
 end
end
for _,mid in ipairs{0x221,0x224}do assert(B.shape('secret_base','secret_base_red_cave',mid,0,7).secretBase=='pc','native PC power/registration state lost its model')end
local pit=fixture(0x222,'pit');faces=mesh(pit,{['3:4']=pit});local negative,vertical=false,false
for _,f in ipairs(faces)do for _,v in ipairs(f)do negative=negative or v[2]==-8 end;vertical=vertical or(f[1][2]~=f[3][2])end
assert(negative and vertical,'pit stayed flat')
local openings=B.openings({a=pc,b=door,c=pit});assert(#openings==1 and openings[1][1]==48 and openings[1][3]==64)
local D=assert(loadfile('lib/InteriorDiorama.lua'))({require=function(n)assert(n=='Gen3SecretBases');return B end})
for side=1,4 do local v,i=D.geometry({secretBase=true},side,false);assert(#v==0 and #i==0,'rectangular shell cuts irregular base')end
local v=D.geometry({bounds={0,0,32,32},height=32,theme='cave',gen=3,nativeWallFinish=true,secretBase=true},6,false)
assert(#v==4 and v[1][2]==32.05)
print('PASS six native base families, collision/decoration guards, continuous wall profile, bounded closed PC, real entry clearance and recessed pit')
