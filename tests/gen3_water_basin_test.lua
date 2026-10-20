local W=assert(loadfile('lib/Gen3Water.lua'))()
local Banks=assert(loadfile('lib/ShoreBanks.lua'))()
local function cell(x,y,kind,base,behavior)
 return{cx=x,cy=y,mid=kind=='water'and 0x170 or 2,collision=kind=='water'and 0x29 or 0,elevation=3,
  base=base or 0,behavior=behavior,pair='general__test',shape={kind=kind,ground=kind=='water'and 0x170 or 2}}
end
local function near(a,b)assert(math.abs(a-b)<1e-8,tostring(a)..' != '..tostring(b))end
local function names(b)return({[16]='POND_WATER',[21]='OCEAN_WATER',[18]='DEEP_WATER',[19]='WATERFALL'})[b]end
local hoenn={region='hoenn',outdoor=true,behaviorName=names}
local a,b=cell(0,0,'water',0,16),cell(1,0,'water',0,21)
local land=cell(0,-1,'ground',0)
local cells={['0:0']=a,['1:0']=b,['0:-1']=land}
local count,field=W.bind(cells,hoenn)
assert(count==0 and #field.components==1)
near(W.surface(a),-4);near(W.surface(b),-4)
assert(a.base==0 and b.mid==0x170 and a.collision==0x29 and a.elevation==3 and land.base==0)
near(W.support(a),-4);assert(W.support(land)==nil,'land actor support changed')
local alone=cell(8,8,'water',10,16)
W.bind({['8:8']=alone},hoenn);near(W.surface(alone),10-20/9)
local pool=cell(0,0,'water',0,16);local deck=cell(1,0,'ground',6)
W.bind({['0:0']=pool,['1:0']=deck},{region='kanto',outdoor=true})
near(W.surface(pool),.05);assert(deck.base==6,'existing deck changed')
local high,low=cell(0,0,'water',12,16),cell(1,0,'water',0,16)
local _,gradient=W.bind({['0:0']=high,['1:0']=low},hoenn)
assert(#gradient.components==2);near(W.surface(high),12-20/9);near(W.surface(low),-20/9)
local authored=cell(0,0,'water',3,16);authored.shape.waterLevel=1.25
W.bind({['0:0']=authored},hoenn);near(W.surface(authored),1.25)
authored.shape.waterLevel=nil;authored.shape.waterline=.75
W.bind({['0:0']=authored},hoenn);near(W.surface(authored),3.75)
authored.shape.waterline=nil;authored.shape.bankDepth=0
W.bind({['0:0']=authored},hoenn);near(W.surface(authored),3.05)
authored.shape.bankDepth=nil
W.bind({['0:0']=authored},{region='kanto',outdoor=function()return false end});near(W.surface(authored),3.05)
authored.shape.bankDepth=2
W.bind({['0:0']=authored},{outdoor=false});near(W.surface(authored),1)
local waterfall=cell(0,0,'water',0,19)
W.bind({['0:0']=waterfall},hoenn);near(W.surface(waterfall),.05)
-- Complete native fields retain the same physical sea even when the bank is
-- outside one moving window. Their native objects/height/collision stay intact.
local r={x=0,y=0,w=5,h=1,floorOffset=0,def={id='EM_TEST',midLayout={pair='general__test'}},floorField={cells={}}}
for x=0,4 do r.floorField.cells[x..':0']={x=x,y=0,kind=x==4 and'ground'or'water',height=x==4 and 6 or 0,mid=x==4 and 2 or 0x170,behavior=21,layer=3}end
local opt={region='hoenn',outdoor=true,behaviorName=names,regions={r}}
local left,right=cell(0,0,'water',0,21),cell(3,0,'water',0,21)
local _,f1=W.bind({['0:0']=left},opt);local _,f2=W.bind({['3:0']=right},opt)
near(W.surface(left),.05);near(W.surface(left),W.surface(right));near(W.at(f1,56,8),W.at(f2,8,8))
assert(r.floorField.cells['4:0'].height==6 and r.floorField.cells['0:0'].height==0)
r.floorField.cells['4:0'].height=0
W.bind({['0:0']=left},opt);near(W.surface(left),-4)
r.def.voxelWater=false
W.bind({['0:0']=left},opt);near(W.surface(left),.05)
r.def.voxelWater={waterLevel=-1.75};r.floorOffset=10
W.bind({['0:0']=left},opt);near(W.surface(left),8.25)
r.def.voxelWater={waterline=-1.25}
W.bind({['0:0']=left},opt);near(W.surface(left),8.75)
local late=cell(0,0,'water',0,21)
W.bind({['0:0']=late},{regions={{x=0,y=0,w=1,h=1,def={}}},outdoor=function(def)return def~=nil end,region='hoenn',behaviorName=names})
near(W.surface(late),-4)
-- Small wet rocks straddle the lowered real sheet even if their blocked cell
-- owns an unrelated native datum. They never become actor standing support.
local rock=cell(1,0,'rock',7);rock.collision=7;rock.shape={kind='rock',ground=0x2d,wetRock=true}
local water=cell(0,0,'water',0,21)
local nativeMid,nativeCollision,nativeBase=rock.mid,rock.collision,rock.base
W.bind({['0:0']=water,['1:0']=rock},hoenn)
near(rock.shape.waterline,-11);near(W.surface(rock),-4);assert(W.support(rock)==nil)
assert(rock.mid==nativeMid and rock.collision==nativeCollision and rock.base==nativeBase)
-- The same reviewed source IDs occur on dry Mossdeep/town ground. Never turn
-- them into ponds or use a synthesized ocean boundary as permission evidence.
for _,mid in ipairs{0xc5,0x18c,0x194}do
 local dry=cell(0,0,'rock',0);dry.mid=mid;dry.collision=7
 dry.shape={kind='rock',ground=0x2d,height=6,wetRock=true,waterline=.05}
 local path=cell(1,0,'flat',0);path.mid=0x101;path.shape.ground=nil
 local fake=cell(-1,0,'water',0,21);fake.boundary='water'
 local n=W.bind({['0:0']=dry,['1:0']=path,['-1:0']=fake},hoenn)
 assert(n==0 and not W.underlay(dry)and not dry.shape.wetRock and not dry.shape.waterline and not dry.shape.waterGround)
 assert(dry.shape.ground==0x101 and dry.mid==mid and dry.collision==7 and dry.base==0 and dry.shape.height==6)
end
local edgeRock=cell(0,0,'rock',0);edgeRock.shape={kind='rock',ground=0x2d,height=6,wetRock=true}
local nativeField={cells={['0:0']={x=0,y=0,kind='rock',height=0,mid=0x194,layer=0},
 ['1:0']={x=1,y=0,kind='water',height=0,mid=0x170,behavior=21,layer=1}}}
local validRegion={x=0,y=0,w=2,h=1,floorOffset=0,def={midLayout={pair='general__test'}},floorField=nativeField}
local n=W.bind({['0:0']=edgeRock},{regions={validRegion},region='hoenn',outdoor=true,behaviorName=names})
assert(n==1 and edgeRock.shape.wetRock,'native full-field water outside the mesh window was ignored')
near(edgeRock.shape.waterline,-4)
-- Exact layer support underneath a bridge; its upper walking deck remains32.
local floor={x=0,y=0,kind='ground',height=32,mid=2,layer=15,behavior=21,underpass={kind='water',height=0,mid=0x170,layer=1}}
local bridge=cell(0,0,'ground',32);bridge.floor=floor
local region={x=0,y=0,w=1,h=1,floorOffset=0,def={},floorField={cells={['0:0']=floor}}}
local _,under=W.bind({['0:0']=bridge},{regions={region},region='hoenn',outdoor=true,behaviorName=names})
near(W.support(bridge,1),-4);assert(W.support(bridge,15)==nil and W.at(under,8,8,15)==nil)
near(W.at(under,8,8,1),-4);assert(bridge.base==32 and floor.height==32)
-- Four bank sides meet their neighbors exactly, including concave corners,
-- and occupy zero width in both the walkable top and adjacent water cell.
local center=cell(0,0,'ground',0)
local surround={['0:0']=center}
for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}}do local n=cell(d[1],d[2],'water',0,16);n.waterSurface=-8;surround[n.cx..':'..n.cy]=n end
local edges=Banks.edges(surround,center,W.surface);assert(#edges==4)
for _,edge in ipairs(edges)do
 assert(edge.top==0 and edge.bottom==-8)
 local dx,dz=edge.direction[1],edge.direction[2]
 for _,p in ipairs(edge.vertices)do
  assert(p[1]>=0 and p[1]<=16 and p[3]>=0 and p[3]<=16 and p[2]>=-8 and p[2]<=0)
  if dx~=0 then assert(p[1]==(dx>0 and 16 or 0))else assert(p[3]==(dz>0 and 16 or 0))end
 end
end
local emitted=0
assert(Banks.append(surround,center,function()emitted=emitted+1 end,function(_,mid)assert(mid==2,'water art used on vertical bank');return{{0,0},{1,0},{1,1},{0,1}}end,W.surface)==4 and emitted==4)
center.wasCut=true;assert(#Banks.edges(surround,center,W.surface)==4,'grass Cut removed physical bank')
center.bridge={};assert(#Banks.edges(surround,center,W.surface)==0);center.bridge=nil
center.floor={underpass={kind='ground',height=-16}};assert(#Banks.edges(surround,center,W.surface)==0)
assert(Banks.skipRiser(center,water)and not Banks.skipRiser(center,land))
print('PASS reviewed river/coast/Kanto basins, gradient datums, preserved pools and authored optouts, full-map stability, native immutability, wet rocks, layer-specific bridge support, closed exact banks, Cut/land standdown')
