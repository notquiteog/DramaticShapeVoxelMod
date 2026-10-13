local G=dofile('lib/InteriorFurniture.lua')
local recipes=dofile('data/gen2_furniture.lua')
local byId={};for _,list in pairs(recipes)do for _,r in ipairs(list)do byId[r.id]=r end end
assert(byId.crystal_center_terminal.design=='gb_center_pc')
assert(byId.crystal_bedroom_pc.design=='gb_pc','bedroom model changed')
assert(byId.crystal_healing_machine.design=='gb_healer','lab model changed')
local cases={
 {'crystal_center_healer',32,32,12},
 {'crystal_center_terminal',16,24,21},
 {'crystal_center_status',16,32,21},
 {'crystal_mart_display',32,32,24.1},
}
local sourceCount=0
for _,c in ipairs(cases)do
 local recipe=assert(byId[c[1]]);local boxes,sources={},{}
 assert(G.draw(recipe.design,{face=function()end,
  sample=function(x,y)assert(x>=0 and x<c[2] and y>=0 and y<c[3]);return {x,y}end,
  box=function(l,b,n,r,h,s)
   assert(l>=0 and r<=c[2] and n>=0 and s<=c[3] and b>=0 and h<=c[4],c[1]..' bounds')
   assert(r>l and s>n and h>b,'closed positive volume');boxes[#boxes+1]={l,b,n,r,h,s}
  end,
  source=function(x,y,w,h,a,b,d,e)
   assert(x>=0 and y>=0 and x+w<=c[2] and y+h<=c[3],'source crop')
   for _,p in ipairs({a,b,d,e})do assert(p[1]>=0 and p[1]<=c[2] and p[3]>=0 and p[3]<=c[3],'source footprint')end
   sources[#sources+1]={x,y,w,h,a,b,d,e};sourceCount=sourceCount+1
  end,
 }))
 assert(#boxes>=2 and #sources>=2,'authored volume and native surfaces missing')
 if c[1]=='crystal_center_healer' then
  assert(recipe.support==6,'native healing animation height')
  local badge=false;for _,q in ipairs(sources)do if q[1]==10 and q[2]==25 then
   badge=true;for i=5,8 do assert(q[i][3]==31.02,'badge must be on front apron')end
  end end;assert(badge)
 elseif c[1]=='crystal_mart_display' then
  local panel=0;for _,q in ipairs(sources)do if q[1]==16 and q[2]==8 then
   panel=panel+1;assert(q[3]==15 and q[4]==18);for i=5,8 do assert(q[i][3]==28.02,'ball panel split')end
  end end;assert(panel==1,'native ball panel must remain continuous')
 end
end
print('Gen2 clinic: separate room designs, closed volumes, bounded crops, intact front artwork PASS ('..sourceCount..' surfaces)')
local overlay=assert(loadfile('lib/Gen2HealOverlay.lua'))({require=function(n)
 assert(n=='Structures');return {forMap=function()return {furniture={{id='crystal_center_healer',x0=0,x1=32,z0=0,z1=32,height=12,support=6}}}end}
end})
local points=overlay.points({map={}},{px=64,py=64,lit=3,layout={balls={{8,4},{16,4},{8,12}}}})
assert(#points==3);for _,p in ipairs(points)do assert(p.h==8.5,'ball floated at monitor height instead of tray')end
print('Gen2 clinic native healing balls use tray support PASS')
local D=assert(loadfile('lib/InteriorDiorama.lua'))({require=function(n)
 assert(n=='TileShape');return {forMap=function()return {}end,at=function()return {class='ground'}end}
end})
local function room(id,w,h,tileAt)
 return {id=id,def={id=id,tileset='TILESET_POKECENTER',environment='INDOOR',width=w,height=h},
  tileset={id='TILESET_POKECENTER'},widthCells=w*2,heightCells=h*2,tileAt=tileAt}
end
local center=room('CHERRYGROVE_POKECENTER_1F',5,4,function(_,x,y)return y==0 and x<4 and 28+x or 17 end)
local profile=D.forMap(center,2);assert(profile.northFront and profile.bounds[2]<0,'machine screen sealed into north wall')
local indigo=room('INDIGO_PLATEAU_POKECENTER_1F',9,7,function(_,x,y)return y==0 and 61 or y==12 and x==0 and 28 or 17 end)
local p=D.forMap(indigo,2);assert(p.boundarySegments,'irregular lobby fell back to rectangle')
local function walk(x,z)
 return z>=112 and z<224 and x>=32 and x<288
  or z>=128 and z<224 and x>=0 and x<32
  or z>=16 and z<112 and x>=256 and x<288
  or z>=16 and z<64 and x>=224 and x<256
end
for side=1,4 do
 local verts=D.geometry(p,side,false)
 for i=1,#verts,4 do
  local x,z=0,0;for j=0,3 do x=x+verts[i+j][1]/4;z=z+verts[i+j][3]/4 end
  local a,b,c,d=math.huge,-math.huge,math.huge,-math.huge
  for j=0,3 do local q=verts[i+j];a=math.min(a,q[1]);b=math.max(b,q[1]);c=math.min(c,q[3]);d=math.max(d,q[3])end
  if b-a>.001 and d-c>.001 then assert(not walk(x,z),'irregular wall intrudes into native aisle '..side..' '..x..','..z)end
 end
end
assert(not D.profile({id='GOLDENROD_DEPT_STORE_ROOF',tileset='TILESET_MART',environment='INDOOR',width=8,height=4},2),'roof acquired room shell')
local C=assert(loadfile('lib/Gen2InteriorShell.lua'))({})
assert(not C.geometry({def={id='GOLDENROD_DEPT_STORE_ROOF',environment='INDOOR'}}),'roof acquired first-person ceiling')
print('Gen2 clinic bay, irregular lobby walls and open roof PASS')
for _,id in ipairs({'crystal_link_mobile','crystal_link_partition','crystal_link_partition_controls','crystal_roof_lightwell'})do
 local t=assert(byId[id]);local boxes=0
 G.draw(t.design,{recipe=t,sample=function()return {}end,source=function(x,y,w,h,a,b,c,d)
  if id=='crystal_roof_lightwell' then assert(a[2]==b[2] and a[2]==c[2] and a[2]==d[2],'store floor projected onto roof wall')end
 end,box=function(l,b,n,r,h,s)
  boxes=boxes+1;assert(l>=0 and n>=0 and r<=#t.tiles[1]*8 and s<=#t.tiles*8)
  if id=='crystal_link_mobile' then assert(not (l<32 and r>16 and n<48 and s>32),'mobile booth blocks native warp approach')end
  if id=='crystal_roof_lightwell' then assert(s<32 and h<=3,'roof curb occupies native walking apron')end
 end})
 assert(boxes>0)
end
assert(byId.crystal_roof_lightwell.keep[1]==174,'roof walking apron must retain original native floor')
print('Gen2 clinic booth doorway and rooftop walking apron PASS')
