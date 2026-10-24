local H=dofile('lib/Gen3HomeRooms.lua')
local function room(pair,header,north)
 local d={width=#header,height=8};local cells={}
 for x,m in ipairs(header)do cells[(x-1)..':0']=m end
 d.midLayout={midAt=function(_,x,y)return cells[x..':'..y]or(pair=='building__generic_building'and 0x223 or 0x201)end,collAt=function(_,x,y)return y==0 and 7 or 0 end}
 local p=assert(H.profile(d,pair));assert(p.north==north and p.north<32)
 cells['0:0']=0x3ff;assert(not H.profile(d,pair),'unrecognized third-party header claimed')
 cells['0:0']=header[1];d.midLayout.collAt=function()return 0 end
 assert(not H.profile(d,pair),'changed native walking header acquired a wall')
 return p
end
room('building__generic_building',{0x286,0x287,0x230,0x205,0x205,0x206,0x205,0x205,0x205,0x205,0x278},15.8)
room('building__brendans_mays_house',{0x26e,0x26e,0x21e,0x26e,0x26e,0x21e,0x21e,0x20f,0x21f,0x21f,0x21f},27.8)
room('building__brendans_mays_house',{0x252,0x254,0x250,0x254,0x256,0x227,0x20b,0x20c,0x20d},15.8)
local v={{0,20,16.2},{16,20,16.2},{16,8,16.2},{0,8,16.2}}
H.attach({cx=0,cy=0,homeWall=27.84,recipe={design='em_start_picture'}},v)
assert(math.abs(v[1][3]-28.16)<1e-7,'picture stayed behind the forward wall')
local f={{0,0,20}};H.attach({cy=1,homeWall=27.84,recipe={design='em_start_picture'}},f);assert(f[1][3]==20)
print('PASS native home header stand-down, wall fronts and independent attached fixtures')
package.loaded['src.core.GameVersion']={get=function()return'ruby'end}
local F=dofile('lib/Gen3Furniture.lua');local cells={}
for y,row in ipairs{{0x21a,0x21b},{0x222,0x223},{0x22a,0x22b}}do for x,m in ipairs(row)do cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=m,collision=y<3 and 7 or 0,pair='building__brendans_mays_house',primary='building',ts={}}end end
local a=F.extract(cells);assert(#a==1 and a[1].recipe.name=='hoenn_start_dining_table')
for _,c in pairs(cells)do c.prop=nil end;cells['0:0'].collision=0
for _,p in ipairs(F.extract(cells))do assert(p.recipe.name~='hoenn_start_dining_table','third-party walking cell gained a solid table')end
print('PASS changed native furniture permission rejects the complete solid')
local Stairs=dofile('lib/Gen3HoennStairs.lua')
for _,down in ipairs{false,true}do
 local plane=down and 15.84 or 27.84
 local origin=down and 0 or 16
 local tread=false
 Stairs.append({cx=0,cy=origin/16,homeWall=plane,ts={},r={rows={{0x208,0x209,0x20d},{0x210,0x211,0x215}},down=down}},function(q)
  local high=-1e9;for _,v in ipairs(q)do high=math.max(high,v[2])end
  for _,v in ipairs(q)do
   if high>18 then assert(v[3]<=plane+.11,'stair surround projects beyond the flat wall')end
   assert(v[3]<=origin+32,'stairs cross the original native flight rows')
   if v[2]>0 and v[2]<16 and v[3]>plane+1 then tread=true end
  end
 end,function()return{{0,0},{1,0},{1,1},{0,1}}end)
 assert(down or tread,'ascending flight did not project beyond the wall')
end
print('PASS flush staircase surrounds and independently projecting native treads')
package.loaded['src.import.gba.versions']={TILESET_PAIRS={}}
local header={0x26e,0x26e,0x21e,0x26e,0x26e,0x21e,0x21e,0x20f,0x21f,0x21f,0x21f}
local d={id='QA_HOME',mapType=8,width=11,height=9,warps={{x=8,y=2}},midLayout={pair='building__brendans_mays_house',midAt=function(_,x,y)return y==0 and header[x+1]or 0x201 end,collAt=function(_,x,y)return y==0 and 7 or 0 end}}
local I=assert(loadfile('lib/InteriorDiorama.lua'))({require=function(n)
 if n=='Gen3HomeRooms'then return H end
 if n=='Gen3Tilesets'then return{canonical=function(p)return p end,resolve=function()return{primary='building',secondary='brendans_mays_house'}end}end
 error(n)
end})
local p=assert(I.forMap(d,3));assert(p.homeFinish and p.doorways[1][1][1]==124 and p.doorways[1][1][2]==148)
I.setRecesses(p,{{0,176,0}});assert(p.bounds[2]==27.8 and not p.northRecesses,'furniture folded the flat wall')
local vs=I.geometry(p,1,false)
for i=1,#vs,4 do
 local x,y=0,0;for j=i,i+3 do x=x+vs[j][1]/4;y=y+vs[j][2]/4 end
 assert(not(x>124.01 and x<147.99 and y>0 and y<27.99),'wall backing sealed the stair opening')
end
print('PASS integrated flat wall with a real native stair aperture')
-- Joined native frame/flight surfaces must have no overlapping planes. The
-- native floor veneers are separate open surfaces and excluded from solid QA.
for _,down in ipairs{false,true}do
 local attachment=down and 15.84 or 27.84;local plane=attachment-.04
 local faces,edges={},{}
 Stairs.append({cx=0,cy=down and 0 or 1,homeWall=attachment,ts={},r={rows={{0x208,0x209,0x20d},{0x210,0x211,0x215}},down=down}},function(q,uv)
  local solid=true;for i=2,4 do if uv[i][1]~=uv[1][1]or uv[i][2]~=uv[1][2]then solid=false end end
  if not solid then return end
  local lo,hi={math.huge,math.huge,math.huge},{-math.huge,-math.huge,-math.huge}
  local high=-math.huge
  for _,v in ipairs(q)do for k=1,3 do lo[k]=math.min(lo[k],v[k]);hi[k]=math.max(hi[k],v[k])end;high=math.max(high,v[2])end
  if high>18 then assert(hi[3]<=plane+1e-7,'integrated doorway projects in front of flat native wall')end
  local axis;for k=1,3 do if hi[k]-lo[k]<1e-7 then assert(not axis);axis=k end end;assert(axis,'nonplanar native stair face')
  local other={};for k=1,3 do if k~=axis then other[#other+1]=k end end
  local key=axis..':'..string.format('%.7f',lo[axis]);local rows=faces[key]or{};faces[key]=rows
  for _,r in ipairs(rows)do
   local a,b=other[1],other[2]
   assert(math.min(hi[a],r.hi[a])-math.max(lo[a],r.lo[a])<=1e-7 or math.min(hi[b],r.hi[b])-math.max(lo[b],r.lo[b])<=1e-7,'overlapping frame/riser/nose planes')
  end
  rows[#rows+1]={lo=lo,hi=hi}
  local ps={};for _,v in ipairs(q)do ps[#ps+1]=string.format('%.7f/%.7f/%.7f',v[1],v[2],v[3])end
  for i=1,4 do local a,b=ps[i],ps[i%4+1];local edge=a<b and a..':'..b or b..':'..a;edges[edge]=(edges[edge]or 0)+1 end
 end,function()return{{0,0},{1,0},{1,1},{0,1}}end)
 local count=0;for _,n in pairs(edges)do assert(n==2,'joined stair solid has an open or nonmanifold edge');count=count+1 end
 assert(count>0 and count<5000,'joined stair mesh budget exceeded')
end
print('PASS coplanar flat doorway frame, closed joined flight and zero overlapping stair surfaces')
-- A full native header face can hide a flush frame even when the separate
-- room shell has an aperture. Clip every orientation and retain source UVs.
local aperture={height=32,homeFinish={stairs=true},doorways={{{12,36}}}}
local source={{0,32,27.84},{48,32,27.84},{48,0,27.84},{0,0,27.84}}
local tex={{0,0},{1,0},{1,1},{0,1}};local area=0
H.stairWallFace(aperture,source,tex,-1,function(q,uv,shade)
 assert(shade==-1)
 local l,r,b,t=math.huge,-math.huge,math.huge,-math.huge
 for k,v in ipairs(q)do l=math.min(l,v[1]);r=math.max(r,v[1]);b=math.min(b,v[2]);t=math.max(t,v[2]);assert(math.abs(uv[k][1]-v[1]/48)<1e-9 and math.abs(uv[k][2]-(1-v[2]/32))<1e-9,'clipped wallpaper changed native UVs')end
 assert(r<=12 or l>=36 or b>=28,'wall face overlaps flat stair frame/opening')
 area=area+(r-l)*(t-b)
end)
assert(area==48*32-24*28,'native wall clipping lost non-aperture pixels')
for _,q in ipairs{
 {{24,0,0},{24,0,27.84},{24,32,27.84},{24,32,0}},
 {{0,0,0},{48,0,0},{48,0,27.84},{0,0,27.84}},
 {{48,32,0},{0,32,0},{0,0,0},{48,0,0}},
}do H.stairWallFace(aperture,q,tex,1,function(v)
 local x,y=0,0;for _,p in ipairs(v)do x=x+p[1]/4;y=y+p[2]/4 end
 assert(not(x>12 and x<36 and y<28),'native column side/back/cap seals stair aperture')
end)end
local untouched=0;H.stairWallFace({height=32,homeFinish={},doorways=aperture.doorways},source,tex,1,function(q,uv)assert(q==source and uv==tex);untouched=untouched+1 end);assert(untouched==1)
print('PASS native wall column aperture clipping, original UVs and non-stair stand-down')
-- The wall shell itself must not leave coplanar return faces buried in the
-- jamb sides. Test the combined mesh, not only either component in isolation.
local function rect(q)
 local lo,hi={math.huge,math.huge,math.huge},{-math.huge,-math.huge,-math.huge};local axis
 for _,v in ipairs(q)do for k=1,3 do lo[k]=math.min(lo[k],v[k]);hi[k]=math.max(hi[k],v[k])end end
 for k=1,3 do if hi[k]-lo[k]<1e-7 then axis=k end end
 return{lo=lo,hi=hi,axis=axis}
end
local shell={};local v=I.geometry(p,1,false)
for i=1,#v,4 do shell[#shell+1]=rect{v[i],v[i+1],v[i+2],v[i+3]}end
Stairs.append({cx=7,cy=1,homeWall=27.84,homeWallPlane=27.8,ts={},r={rows={{0x208,0x209,0x20d},{0x210,0x211,0x215}}}},function(q)
 local a=rect(q)
 for _,b in ipairs(shell)do if a.axis==b.axis and math.abs(a.lo[a.axis]-b.lo[b.axis])<1e-7 then
  local overlap=true
  for k=1,3 do if k~=a.axis and math.min(a.hi[k],b.hi[k])-math.max(a.lo[k],b.lo[k])<=1e-7 then overlap=false end end
  assert(not overlap,'stair frame overlaps coplanar wallpaper front/return face')
 end end
end,function()return tex end)
print('PASS combined wallpaper and stair frame have no overlapping coplanar faces')
for _,down in ipairs{false,true}do
 local north=down and 15.8 or 11.8;local floorFaces={}
 Stairs.append({cx=0,cy=0,homeWall=north+.04,homeWallPlane=north,ts={},r={rows={{0x208,0x209,0x20d},{0x210,0x211,0x215}},down=down}},function(q)
  local a=rect(q);if a.axis==2 and math.abs(a.lo[2])<1e-7 then floorFaces[#floorFaces+1]=a end
 end,function()return tex end)
 for _,x in ipairs{12.5,13.5,14.5,33.5,34.5,35.5}do for z=north+.5,31.5,1 do
  local count=0;for _,q in ipairs(floorFaces)do if x>q.lo[1]and x<q.hi[1]and z>q.lo[3]and z<q.hi[3]then count=count+1 end end
  assert(count==1,'stair margin has a floor gap or overlapping floor/cap planes')
 end end
end
print('PASS ascending/descending floor margins cover once with closed well sides')
