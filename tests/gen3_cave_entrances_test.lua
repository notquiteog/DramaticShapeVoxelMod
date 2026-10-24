local T=dofile('lib/Gen3Terrain.lua');local version='firered';local delegated=0
local V={require=function(name)
 if name=='Generation'then return{version=function()return version end}end
 if name=='Gen3Terrain'then return T end
 if name=='Gen3HoennCaveEntrances'then error('optional absent')end
 error(name)
end}
local E=assert(loadfile('lib/Gen3CaveEntrances.lua'))(V)
local function fixture(h,ox,oy)
 local cells={};ox,oy=ox or 0,oy or 0
 for yy=2,7 do for xx=16,22 do
  local y,x=yy+oy,xx+ox
  local stone=yy<=5
  cells[x..':'..y]={cx=x,cy=y,base=0,mid=stone and(yy==4 and 124 or 121)or 217,
   primary='general',pair='general__rom_082d4af4',collision=stone and 7 or 0,
   shape={kind=stone and'cliff'or'flat',height=h}}
 end end
 local c=cells[(19+ox)..':'..(5+oy)];c.mid=169;c.collision=113;c.shape={kind='flat'}
 return cells,c,{{x=ox,y=oy,def={id='FR_ROUTE_4',warps={{x=19,y=5,destMap='FR_MT_MOON_1F'}}}}}
end
local uv={{.1,.2},{.3,.2},{.3,.4},{.1,.4}};local meshes={}
for _,h in ipairs{12,16,32}do
 local cells,c,regions=fixture(h,10,-2);local before={}
 for k,q in pairs(cells)do before[k]={q.mid,q.collision,q.base,q.shape.kind}end
 assert(E.prepare(cells,regions)==1 and c.caveEntrance.height==h)
 for k,q in pairs(cells)do local b=before[k];assert(q.mid==b[1]and q.collision==b[2]and q.base==b[3]and q.shape.kind==b[4])end
 local mesh={};local floor=0;local minZ,maxZ=math.huge,-math.huge
 E.append(c,function(points,tex)
  assert((#points==3 or#points==4)and#tex==#points)
  local allFloor=true
  for i,p in ipairs(points)do
   assert(p[1]>=c.cx*16 and p[1]<=(c.cx+1)*16 and p[3]>=c.cy*16 and p[3]<=(c.cy+1)*16)
   assert(p[2]>=0 and p[2]<=h);allFloor=allFloor and p[2]==0
   assert(tex[i][1]>=.1-1e-8 and tex[i][1]<=.3+1e-8 and tex[i][2]>=.2-1e-8 and tex[i][2]<=.4+1e-8)
  end
  if allFloor then floor=floor+1 end
  for _,ii in ipairs(#points==3 and{{1,2,3}}or{{1,2,3},{1,3,4}})do
   local tri={points[ii[1]],points[ii[2]],points[ii[3]]};local a,b,d=unpack(tri)
   local u,v={b[1]-a[1],b[2]-a[2],b[3]-a[3]},{d[1]-a[1],d[2]-a[2],d[3]-a[3]}
   local area=(u[2]*v[3]-u[3]*v[2])^2+(u[3]*v[1]-u[1]*v[3])^2+(u[1]*v[2]-u[2]*v[1])^2
   assert(area>1e-8,'degenerate reveal face');mesh[#mesh+1]=tri
  end
 end,function()return uv end)
 assert(floor==1,'duplicate floor owner')
 -- The cap at either outside X seam follows exactly the unchanged adjacent
 -- terrain sampler; the ten-pixel tunnel and its dark back are truly deep.
 assert(T.height(cells,c.cx*16,c.cy*16+12,h)==h)
 assert(T.height(cells,c.cx*16,c.cy*16+16,h)==0)
 local backs=0;local ceilings=0
 for _,tri in ipairs(mesh)do
  if tri[1][3]==c.cy*16+4 and tri[2][3]==c.cy*16+4 and tri[3][3]==c.cy*16+4 then backs=backs+1 end
  if tri[1][2]>0 and tri[1][2]<=14 and tri[2][2]>0 and tri[2][2]<=14 and tri[3][2]>0 and tri[3][2]<=14 then ceilings=ceilings+1 end
 end
 assert(backs==6 and ceilings>=6,'recess lacks closed backing/arched underside')
 meshes[#meshes+1]=mesh
end
-- Actual rendered terrain edges interpolate their4px grid, rather than
-- querying a discontinuous cell support profile at arbitrary subgrid points.
do
 local cells={};for yy=6,9 do for xx=8,10 do cells[xx..':'..yy]={cx=xx,cy=yy,base=6,mid=yy==7 and 860 or 857,primary='general',pair='sevii_outdoor',collision=7,shape={kind='cliff',height=32}}end end
 local c=cells['9:8'];c.mid=838;c.collision=113;c.shape={kind='flat'}
 cells['9:9'].mid=217;cells['9:9'].collision=0;cells['9:9'].shape={kind='flat'}
 local r={{x=0,y=0,def={id='FR_NAVEL_ROCK_EXTERIOR',warps={{x=9,y=8,destMap='FR_NAVEL_ROCK_1F'}}}}}
 local old=T.height;T.height=function(_,x,z)return z>=9*16 and 6 or x>=10*16 and 38 or 6 end
 assert(E.prepare(cells,r)==1 and c.caveEntrance.boundary)
 assert(c.caveEntrance.boundary[0][13]==8,'hood broke interpolated native cliff edge')
 assert(c.base==6 and cells['9:9'].base==6,'hood moved authoritative native floors')
 T.height=old
end
-- Navel's irregular native perimeter includes zero-height corners. The local
-- hood copies that edge, emits real triangles and leaves ground solely floor.
do
 local boundary={};for _,z in ipairs{0,4,8,12,16}do boundary[z]={};for _,x in ipairs{0,3,5,11,13,16}do boundary[z][x]=x==16 and(z==16 and 0 or 32)or x==13 and z==0 and 8 or 0 end end
 local c={cx=0,cy=0,mid=838,ts={},caveEntrance={height=16,boundary=boundary}};local mesh={}
 E.append(c,function(points,tex)
  for _,is in ipairs(#points==3 and{{1,2,3}}or{{1,2,3},{1,3,4}})do
   mesh[#mesh+1]={points[is[1]],points[is[2]],points[is[3]]}
  end
 end,function()return uv end)
 meshes[#meshes+1]=mesh;assert(#mesh>40,'irregular native hood omitted')
end
for _,change in ipairs{
 function(c,r)c.mid=170 end,function(c,r)c.collision=0 end,
 function(c,r)c.pair='general__wrong' end,function(c,r)c.civic={}end,
 function(c,r)r[1].def.id='FR_CUSTOM_MAP'end,
 function(c,r)r[1].def.warps[1].destMap='FR_CUSTOM_DESTINATION'end,
}do local cells,c,regions=fixture(16);change(c,regions);assert(E.prepare(cells,regions)==0 and not c.caveEntrance,'unreviewed art/portal claimed')end
do local cells,c,r=fixture(8);assert(E.prepare(cells,r)==0 and not c.caveEntrance,'unreviewed low enclosure gained a tunnel')end
for _,bad in ipairs{'gold','emerald','ruby','sapphire'}do
 version=bad;local cells,c,r=fixture(16);assert(E.prepare(cells,r)==0 and not c.caveEntrance)
end
version='emerald';V.require=function(n)if n=='Generation'then return{version=function()return version end}elseif n=='Gen3HoennCaveEntrances'then return{prepare=function()return 7 end}else error(n)end end
assert(E.prepare({}, {})==7,'optional Hoenn adapter not dispatched')
local seen=false;E.append({caveEntrance={append=function()seen=true end}},function()end,function()end);assert(seen,'source-specific append callback absent')
if arg[1]then local f=assert(io.open(arg[1],'w'));for mi,mesh in ipairs(meshes)do for _,tri in ipairs(mesh)do f:write(mi);for _,p in ipairs(tri)do for _,n in ipairs(p)do f:write(' ',n)end end;f:write('\n')end end;f:close()end
print('PASS bounded recessed cave meshes, real arch/side/back depth, single floor, unchanged native cells/terrain seams, exact art/portal guards and optional Hoenn dispatch')
