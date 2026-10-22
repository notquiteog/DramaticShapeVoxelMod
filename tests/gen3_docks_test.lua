local D=dofile('lib/Gen3Docks.lua')
local B=dofile('lib/Gen3Bridges.lua')
local S=dofile('lib/ShoreBanks.lua')
local uv={{0,0},{1,0},{1,1},{0,1}}
local function fixture(name,prefix)
 local route=name=='ROUTE104'
 local rows=route and{{0x33d,0x26e,0x26e,0x32e},{0x345,0x26d,0x26d,0x336},{0x335,0x276,0x276,0x277}}or{{0x228,0x229,0x229},{0x230,0x231,0x231}}
 local coll=route and{{7,0,0,0},{7,0,0,0},{41,41,41,7}}or{{0,0,0},{7,7,7}}
 local layers=route and{{0,4,4,4},{0,4,4,4},{1,1,1,0}}or{{3,3,3},{0,0,0}}
 local cells={};local region={def={id=prefix..'_'..name}};local ts={};local pair=route and'general__rustboro'or'general__dewford'
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do
  local c={cx=x-1,cy=y-1,mid=mid,primary='general',pair=pair,region=region,ts=ts,
   collision=coll[y][x],floor={layer=layers[y][x]},base=route and(coll[y][x]==0 and 6 or 0)or 0,
   shape={kind=route and(x==1 or y==3 and x<4)and'water'or'flat'}}
  cells[c.cx..':'..c.cy]=c
 end end
 cells['-1:0']={cx=-1,cy=0,mid=0x170,primary='general',pair=pair,region=region,ts=ts,
  collision=41,floor={layer=1},base=0,waterSurface=-4,shape={kind='water'}}
 return cells,route and 12 or 6
end
for _,prefix in ipairs{'RU','SA','EM'}do for _,name in ipairs{'ROUTE104','DEWFORD_TOWN'}do
 local cells,count=fixture(name,prefix);local snapshot={}
 for k,c in pairs(cells)do snapshot[k]={c.mid,c.collision,c.floor.layer,c.base,c.shape}end
 assert(B.prepareDocks(cells)==count)
 assert(B.prepareDocks(cells)==0,'claimed twice')
 local donor=cells['-1:0'];local n=0
 for k,c in pairs(cells)do if c~=donor then
  if c.dockShore then
   assert(not B.replacesTop(c)and not c.bridge and c.shape.kind=='cliff'and c.shape.cap==0x6c,'native land attachment consumed as ocean')
  else
  assert(B.replacesTop(c));local ts,mid,h=B.water(c,function(w)return w.waterSurface end)
  assert(ts==donor.ts and mid==0x170 and h==-4,'water did not use genuine planned ocean')
  assert(#S.edges(cells,c,function()return -4 end)==0,'soil bank remains on dock')
  local faces={};B.append(cells,c,function(v,t,shade)
   faces[#faces+1]={v=v,t=t,shade=shade}
   for _,p in ipairs(v)do
    assert(p[1]>=c.cx*16 and p[1]<=c.cx*16+16 and p[3]>=c.cy*16 and p[3]<=c.cy*16+16,'board escaped source ownership')
    assert(p[2]<=c.bridge.group.height and p[2]>=c.bridge.group.height-2,'wrong board datum/thickness')
   end
  end,function()return uv end)
  local boards=name=='ROUTE104'and(c.bridge.y==3 and 0 or c.bridge.x==1 and 1 or 2)or 2
  assert(#faces>=boards*6)
  for i=1,boards*6,6 do
   local top,under=faces[i].v,faces[i+1].v
   assert(top[1][2]-under[1][2]==2,'board not physically thick')
   assert(top[2][1]-top[1][1]==6,'source board width/gap changed')
   for j=1,4 do assert(under[j][2]==under[1][2])end
   -- Closed source board: each undirected edge occurs on exactly two faces.
   local edges={}
   local function point(p)return table.concat(p,',')end
   for f=i,i+5 do for j=1,4 do local a,b=point(faces[f].v[j]),point(faces[f].v[j%4+1]);if a>b then a,b=b,a end
    local edge=a..'/'..b;edges[edge]=(edges[edge]or 0)+1
   end end
   for _,v in pairs(edges)do assert(v==2,'open board edge')end
  end
  end
  n=n+1
 end
 local old=snapshot[k];assert(c.mid==old[1]and c.collision==old[2]and c.floor.layer==old[3]and c.base==old[4]and(c.dockShore or c.shape==old[5]),'native data mutated')
 end
 assert(n==count)
end end
for _,mutation in ipairs{
 function(c)c['0:0'].collision=0 end,
 function(c)c['1:1'].floor.layer=3 end,
 function(c)c['1:1'].base=7 end,
 function(c)c['1:0'].mid=1 end,
 function(c)c['2:0'].region={}end,
 function(c)c['1:1'].prop={}end,
 function(c)c['1:1']=nil end,
 function(c)c['-1:0']=nil end,
 function(c)for _,n in pairs(c)do n.region.def.id='EM_ROUTE103'end end,
}do
 local c=fixture('ROUTE104','EM');mutation(c);assert(D.prepare(c)==0,'unreviewed dock pattern accepted')
 for _,n in pairs(c)do assert(not n.bridge,'partial group claimed')end
end
-- Before native region/elevation binding the early generic bridge pass is safe.
local c=fixture('ROUTE104','EM');for _,n in pairs(c)do n.region=nil;n.floor=nil;n.base=nil end
assert(B.prepare(c)==0)
print('PASS exact RSE dock groups; immutable native permissions/layers; closed wooden boards/open gaps; adjacent planned animated-water donor; no soil banks; atomic fallback')
-- Clear rays through the actual inter-board space from above and below. A
-- whole-tile underside or old opaque source plane would fail these probes.
local cells=fixture('ROUTE104','EM');assert(D.prepare(cells)==12)
for _,c in pairs(cells)do if D.replacesTop(c)then
 D.append(cells,c,function(v)
  local horizontal=true;for _,p in ipairs(v)do if p[2]~=v[1][2]then horizontal=false end end
  if horizontal then
   local lo,hi=math.huge,-math.huge;for _,p in ipairs(v)do lo=math.min(lo,p[1]);hi=math.max(hi,p[1])end
   for _,offset in ipairs{7,15}do local ray=c.cx*16+offset;assert(not(lo<ray and ray<hi),'board gap sealed by cap/underside')end
  end
 end,function()return uv end)
end end
-- Donor is sampled after planning, never cached at preparation height.
local c=cells['1:0'];cells['-1:0'].waterSurface=-9
local _,_,h=D.water(c,function(n)return n.waterSurface end);assert(h==-9)
cells['-1:0'].waterSurface=6;assert(D.water(c,function(n)return n.waterSurface end)==nil,'water emitted above underside')
print('PASS open top/bottom gap rays and final planned-water datum refresh')

-- Land beside the ocean under a deck keeps a closed physical bank. This is
-- independent of the timber geometry and does not turn bridges into soil.
local water={cx=2,cy=0,shape={kind='water'},waterSurface=-4}
local land={cx=0,cy=0,base=6,shape={kind='flat'},mid=1}
local deck={cx=1,cy=0,base=6,shape={kind='flat'},bridge={kind='dock',group={height=6,waterCandidates={water}}}}
local sea={['0:0']=land,['1:0']=deck,['2:0']=water}
local edges=S.edges(sea,land,function(c)return c.waterSurface end)
assert(#edges==1 and edges[1].top==6 and edges[1].bottom==-4 and edges[1].bankDepth==10,'land floats beside dock')
for _,p in ipairs(edges[1].vertices)do assert(p[1]==16 and(p[2]==6 or p[2]==-4))end
assert(S.skipRiser(land,deck)and#S.edges(sea,deck,function(c)return c.waterSurface end)==0)
deck.bridge.kind=nil
assert(#S.edges(sea,land,function(c)return c.waterSurface end)==0,'ordinary bridge received dock shore policy')
print('PASS exact land attachment above dock ocean, closed bank and ordinary bridge isolation')
