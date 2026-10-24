local T=dofile('lib/Gen3Terrain.lua');local V={require=function(n)if n=='Generation'then return{version=function()return'firered'end}elseif n=='Gen3Terrain'then return T else error(n)end end}
local D=assert(loadfile('lib/Gen3DottedHoleEntrance.lua'))(V)
local uv={{0,0},{1,0},{1,1},{0,1}};local all={}
local function fixture(open)
 local cells={}
 for y=21,26 do for x=21,27 do cells[x..':'..y]={cx=x,cy=y,base=0,mid=124,pair='general__rom_082d507c',collision=y<=24 and 7 or 0,shape={kind=y<=24 and'cliff'or'flat',height=16},ts={}}end end
 local drawing={{814,open and 856 or 855,871},{822,198,879}}
 for yy,row in ipairs(drawing)do for xx,mid in ipairs(row)do local c=cells[(xx+22)..':'..(yy+23)];c.mid=mid;c.shape={kind='flat'};c.collision=yy==2 and 0 or open and xx==2 and 113 or 7 end end
 for i,mid in ipairs{123,124,125}do cells[(i+22)..':23'].mid=mid end
 return cells,{{x=0,y=0,def={id='FR_SIX_ISLAND_RUIN_VALLEY',warps={{x=24,y=24,destMap='FR_SIX_ISLAND_DOTTED_HOLE_1F'}}}}}
end
for _,opened in ipairs{false,true}do
 local cells,r=fixture(opened);local before={};for k,c in pairs(cells)do before[k]={c.mid,c.collision,c.base,c.shape.kind}end
 assert(D.prepare(cells,r)==1,'exact Dotted Hole rejected')
 assert(cells['23:25'].caveEntrance.terrainSupport==false and cells['25:25'].caveEntrance.terrainSupport==false)
 assert(T.height(cells,24*16+8,25*16+8,16)==0,'walkable column projection became terrain support')
 local mesh={};local floors=0
 D.append(cells['24:24'],function(points,tex)
  assert(#points==3 or#points==4);assert(#tex==#points)
  for _,t in ipairs(tex)do assert(t[1]>=0 and t[1]<=1 and t[2]>=0 and t[2]<=1,'source paint left native metatile crop')end
  local floor=true
  for _,p in ipairs(points)do
   assert(p[1]>=23*16 and p[1]<=26*16 and p[3]>=24*16 and p[3]<=26*16)
   if p[2]>0 then assert(p[3]<=25*16,'solid geometry entered original walkable projection row')end
   assert(p[2]>=-.05-1e-8 and p[2]<=20);floor=floor and p[2]==0
  end
  if floor then floors=floors+1 end
  for _,is in ipairs(#points==3 and{{1,2,3}}or{{1,2,3},{1,3,4}})do mesh[#mesh+1]={points[is[1]],points[is[2]],points[is[3]]}end
 end,function()return uv end)
 assert(floors==5,'native floor has duplicate/missing owners')
 local count=0;D.append(cells['23:24'],function()count=count+1 end,function()return uv end);assert(count==0,'column subgroup emitted master twice')
 for k,c in pairs(cells)do local b=before[k];assert(c.mid==b[1]and c.collision==b[2]and c.base==b[3]and c.shape.kind==b[4])end
 all[#all+1]=mesh
end
for _,change in ipairs{
 function(c,r)c['24:24'].mid=857 end,function(c,r)c['23:24'].collision=0 end,
 function(c,r)c['23:25'].mid=823 end,function(c,r)c['25:25'].base=6 end,
 function(c,r)c['24:24'].pair='general__wrong'end,
 function(c,r)r[1].def.warps[1].destMap='FR_FOREIGN'end,
}do local c,r=fixture(false);change(c,r);assert(D.prepare(c,r)==0);for _,a in pairs(c)do assert(not a.caveEntrance,'partial assembly claimed')end end
if arg[1]then local f=assert(io.open(arg[1],'w'));for key,mesh in ipairs(all)do for _,tri in ipairs(mesh)do f:write(key);for _,p in ipairs(tri)do for _,n in ipairs(p)do f:write(' ',n)end end;f:write('\n')end end;f:close()end
print('PASS exact native closed/open braille/columns, bounded closed solids, floor-only projection ownership, original native cells and atomic art/permission/state fallback')
