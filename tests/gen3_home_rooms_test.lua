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
