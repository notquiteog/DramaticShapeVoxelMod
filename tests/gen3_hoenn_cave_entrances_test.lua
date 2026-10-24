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
version='firered';local a,r=fixture();assert(C.prepare(a,r)==0,'Hoenn profile claimed Kanto')
print('PASS Hoenn exact cave permissions/warps/blocked reveals, unchanged perimeter, one floor owner, recessed arch/ceiling/back and fail-closed contexts')
