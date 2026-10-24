-- Exact native eligibility, local perimeter and subtractive passage geometry.
local version='emerald'
local Terrain=assert(loadstring(assert(io.open('lib/Gen3Terrain.lua')):read('*a'):gsub('if not c or c.shape','if not c or c.caveEntrance or c.shape',1)))()
local V={require=function(name)if name=='Generation'then return{version=function()return version end}elseif name=='Gen3Terrain'then return Terrain end;error(name)end}
local C=assert(loadfile('lib/Gen3HoennCaveEntrances.lua'))(V)
local function fixture()
 local cells={}
 for y=-2,2 do for x=-2,2 do
  cells[x..':'..y]={cx=x,cy=y,primary='general',pair='general__rustboro',mid=0x91,collision=y<1 and 7 or 0,
   base=0,shape=y<1 and{kind='cliff',height=8}or{kind='flat'}}
 end end
 local c,n=cells['0:0'],cells['0:-1'];c.mid=0xa7;c.collision=113;c.shape={kind='flat'};n.mid=0x9f;n.shape={kind='flat'}
 local r={x=-47,y=-8,def={id='EM_ROUTE116',warps={{x=47,y=8,destMap='EM_RUSTURF_TUNNEL'}}}}
 return cells,{r},c,n
end
local cells,regions,c,n=fixture();assert(C.prepare(cells,regions)==1 and c.caveEntrance==n.caveEntrance)
local p=c.caveEntrance;assert(p.warp==regions[1].def.warps[1]and p.append==C.append)
-- The old8px cliff perimeter stays unchanged. The local hood has a distinct
--21px arched front, sloped rock ceiling and a22px recessed back.
for z,row in pairs(p.boundary)do
 assert(row[0]==Terrain.height(cells,0,z,8)and row[16]==Terrain.height(cells,16,z,8))
end
local quads={};local uv={{0,0},{1,0},{1,1},{0,1}}
C.append(c,function(v,t,shade)quads[#quads+1]={v=v,t=t,shade=shade}end,function()return uv end)
assert(#quads==46,'unexpected surface count')
local floor,back,ceiling,maxY=0,0,0,0
for _,q in ipairs(quads)do
 assert(#q.v==4 and #q.t==4)
 local ground,rear,roof=true,true,true
 for _,v in ipairs(q.v)do
  assert(v[1]>=0 and v[1]<=16 and v[3]>=-16 and v[3]<=16 and v[2]>=0 and v[2]<=25)
  maxY=math.max(maxY,v[2]);ground=ground and v[2]==0;rear=rear and v[3]==-10
  roof=roof and(v[3]==-10 or v[3]==12)and v[2]>0
 end
 if ground then floor=floor+1 end;if rear then back=back+1 end;if roof then ceiling=ceiling+1 end
end
assert(floor==1 and back==3 and ceiling==3 and maxY==25,'flat/duplicate floor or incomplete recessed tunnel')
local header=0;C.append(n,function()header=header+1 end,function()return uv end);assert(header==0,'header duplicated owner geometry')
-- Route115's native outside corner lowers one cap triangle exactly to floor0.
-- The floor owns that plane; retain every raised half and its original seam.
p.boundary[-16][14]=0;p.boundary[-16][16]=0;p.boundary[-12][16]=0
local groundTriangles=0
C.append(c,function(v)
 for _,t in ipairs{{1,2,3},{1,3,4}}do local a,b,d=v[t[1]],v[t[2]],v[t[3]]
  if a[2]==0 and b[2]==0 and d[2]==0 then
   local area=math.abs((b[1]-a[1])*(d[3]-a[3])-(b[3]-a[3])*(d[1]-a[1]))
   if area>1e-8 then groundTriangles=groundTriangles+1 end
  end
 end
end,function()return uv end)
assert(groundTriangles==2,'zero-height cap still overlaps the native threshold floor')

assert(c.mid==0xa7 and c.collision==113 and n.mid==0x9f and n.collision==7,'native ownership changed gameplay')
for _,mutate in ipairs{
 function(a)a['0:0'].collision=7 end,function(a)a['0:-1'].mid=0x7c end,
 function(a)a['0:-1'].collision=0 end,function(a)a['-1:0'].collision=0 end,
 function(a)a['1:-1'].collision=0 end,function(a)a['0:1'].collision=7 end,
 function(a)a['0:1'].base=6 end,function(a)a['0:-1'].base=6 end,
 function(a)a['0:0'].civic={}end,function(a)a['0:-1'].column={}end,
 function(a)a['0:0'].boundary=true end,
 function(a,r)r[1].def.warps={}end,function(a,r)r[1].def.warps[1].destMap='EM_UNREVIEWED'end,function(a)a['0:0'].pair='general__petalburg'end,function(a,r)r[1].def.id='EM_UNREVIEWED'end,
}do local a,r=fixture();mutate(a,r);assert(C.prepare(a,r)==0 and not a['0:0'].caveEntrance,'unsafe native context accepted')end
for _,e in ipairs{'ruby','sapphire'}do version=e;local a,r,c,n=fixture();local prefix=(e=='ruby'and'RU_'or'SA_');r[1].def.id=prefix..'ROUTE116';r[1].def.warps[1].destMap=prefix..'RUSTURF_TUNNEL';assert(C.prepare(a,r)==1)end
version='emerald'
for _,f in ipairs{{'ROUTE112','lavaridge',11,36,0x25e,0x256,12,0x271,0x274,0,'FIERY_PATH'},
 {'ROUTE114','fallarbor',8,63,0x261,0x259,16,0x241,0x243,7,'METEOR_FALLS_1F_1R'}}do
 local a,r,c,n=fixture();r[1].x=-f[3];r[1].y=-f[4];r[1].def.id='EM_'..f[1];r[1].def.warps={{x=f[3],y=f[4],destMap='EM_'..f[11]}}
 for _,t in pairs(a)do t.pair='general__'..f[2];if t.shape.kind=='cliff'then t.shape.height=f[7]end end
 c.mid=f[5];n.mid=f[6];n.collision=f[10];assert(C.prepare(a,r)==1,'regional opening rejected')
 local sampled={};C.append(c,function()end,function(_,mid)sampled[mid]=true;return uv end)
 assert(sampled[f[8]]and sampled[f[9]]and not sampled[0x6c]and not sampled[0x71],'regional stone borrowed primary cliff paint')
end
version='emerald'
for _,f in ipairs{{'JAGGED_PASS','lavaridge',16,18,0x25e,0x256,0,'MAGMA_HIDEOUT_1F'},
 {'ROUTE103','petalburg',45,6,0xa7,0x9f,7,'ALTERING_CAVE'}}do
 local a,r,c,n=fixture();r[1].x=-f[3];r[1].y=-f[4];r[1].def.id='EM_'..f[1];r[1].def.warps={{x=f[3],y=f[4],destMap='EM_'..f[8]}}
 for _,t in pairs(a)do t.pair='general__'..f[2]end;c.mid=f[5];n.mid=f[6];n.collision=f[7]
 assert(C.prepare(a,r)==1,'reviewed Emerald mouth rejected')
 if f[1]=='ROUTE103'then local high=0;local rearHigh=0
  C.append(c,function(v)for _,p in ipairs(v)do high=math.max(high,p[2]);if p[3]==-10 then rearHigh=math.max(rearHigh,p[2])end end end,function()return uv end)
  assert(high==25 and rearHigh==10.5,'postgame native two-row drawing must retain ordinary cave proportions')
 end
 version='ruby';local b,rr=fixture();rr[1].def.id='RU_'..f[1];assert(C.prepare(b,rr)==0,'Emerald-only mouth leaked to RS');version='emerald'
end
version='firered';local a,r=fixture();assert(C.prepare(a,r)==0,'Hoenn profile claimed Kanto')
print('PASS Hoenn exact cave permissions/warps/blocked reveals, unchanged perimeter, one floor owner, recessed arch/ceiling/back and fail-closed contexts')
