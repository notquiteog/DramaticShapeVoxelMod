local M=assert(loadfile('lib/Gen3Civic.lua'))()
for _,kind in ipairs({'gym','center','mart'})do
 local g={kind=kind,cx=3,cy=5,width=kind=='gym' and 7 or kind=='center' and 5 or 4}
 local p=M.profile(g);local faces={}
 M.append(g,function(v,uv)
  faces[#faces+1]={v,uv}
  for i,a in ipairs(v)do
   assert(a[1]>=47 and a[1]<=49+p.w and a[3]>=80+p.back-1.5 and a[3]<=80+p.front+p.projection,'building escaped its reviewed footprint')
   assert(a[2]>=0 and a[2]<=math.max(p.wall+p.bevel,p.doorHeight)+.05,'building grew a ridge or underground wall')
   assert(uv[i][1]>0 and uv[i][1]<1 and uv[i][2]>0 and uv[i][2]<1,'material samples an adjacent source rectangle')
  end
 end)
 -- Facade ground rows stop at the wall base; openings may subdivide faces.
 assert(faces[1][2][3][2]<p.wallBottom/p.h)
 local entrance=false;for _,f in ipairs(faces)do for _,v in ipairs(f[1])do entrance=entrance or (v[1]==48+p.doorLeft and v[3]==80+p.front+p.projection)end end;assert(entrance,'projected entrance lost')
 local plateau=false
 for _,f in ipairs(faces)do
  local high=true;for _,a in ipairs(f[1])do high=high and a[2]==p.wall+p.bevel end
  if high then plateau=true end
 end
 assert(plateau,'roof has no flat plateau')
 local soffit=false
 for _,f in ipairs(faces)do
  local flat=true;local corners={}
  for _,v in ipairs(f[1])do
   flat=flat and v[2]==p.wall
   corners[(v[1]-48)..':'..(v[3]-80)]=true
  end
  soffit=soffit or (flat and corners['0:'..p.back] and corners[p.w..':'..p.back]
   and corners['0:'..p.front] and corners[p.w..':'..p.front])
 end
 assert(soffit,'roof overhang is open from underneath')
 if kind=='center' then
  assert(p.roofEnd==53,'window band folded onto roof')
  local corner=false;local recess=false
  for _,f in ipairs(faces)do for _,v in ipairs(f[1])do
   corner=corner or (v[1]==48 and v[2]==0 and v[3]==80+p.front-8)
   recess=recess or (v[1]==48+33 and v[3]==80+p.front+p.projection-1)
  end end
  assert(corner,'native rounded facade still represented by flat rectangle')
  assert(recess,'native doorway no longer recessed')
 end
end
local rows={{0x28,0x29,0x2A,0x2B},{0x30,0x31,0x32,0x33},{0x38,0x39,0x3A,0x3B},{0x40,0x41,0x62,0x63}}
local cells={}
for y,row in ipairs(rows)do for x,mid in ipairs(row)do cells[x..':'..y]={cx=x,cy=y,mid=mid,primary='general',pair='city'}end end
assert(#M.prepare(cells,{})==1)
for _,c in pairs(cells)do c.civic=nil end
cells['3:3'].mid=1
assert(#M.prepare(cells,{})==0,'partial building consumed unrelated map art')
print('PASS flat civic roofs, bounded bevels, cropped facade ground, aligned complete entrances and whole drawing matches')

-- A shared tower is claimed only when its connected-map continuation is exact.
local family={name='tower_fixture',pair='city',header=1,geometry='tower',northRows={{81,82},{83,84}},rows={{91,92},{93,94}}}
local connected={}
for y,row in ipairs({{81,82},{83,84},{91,92},{93,94}})do for x,mid in ipairs(row)do
 connected[x..':'..(y-3)]={cx=x,cy=y-3,mid=mid,primary='general',pair='city'}
end end
local built=M.prepare(connected,{},{family})
assert(#built==1 and built[1].cy==-2 and built[1].northRows==2 and #built[1].rows==4)
for _,c in pairs(connected)do assert(c.civic==built[1]);c.civic=nil end
connected['1:-2'].pair='other'
built=M.prepare(connected,{},{family})
assert(#built==1 and built[1].cy==0 and built[1].northRows==0)
assert(not connected['1:-2'].civic,'unrelated connected map was consumed')
local Tower=dofile('lib/Gen3TowerExterior.lua')
local g={cx=2,cy=-8,width=7,depth=15,northRows=8,custom={geometry='tower'}}
local p=M.profile(g);local cap,antenna=0,0;local corners={}
Tower.append(g,p,function(vertices,tex)
 for i,v in ipairs(vertices)do
  assert(v[1]>=32 and v[1]<=144 and v[2]>=0 and v[2]<=193 and v[3]>=-.1 and v[3]<=111.1)
  assert(tex[i][1]>0 and tex[i][1]<1 and tex[i][2]>0 and tex[i][2]<1)
  if v[2]==48 and (v[1]==32 or v[1]==144) and (v[3]==0 or v[3]==111)then corners[v[1]..":"..v[3]]=true end
  if v[2]>143 then cap=cap+1 end
  if v[2]==193 then antenna=antenna+1 end
 end
end)
assert(cap>0 and antenna>0,'connected native dome or antenna missing')
local cornerCount=0;for _ in pairs(corners)do cornerCount=cornerCount+1 end
assert(cornerCount==4,'tower podium did not fill all four square corners')
print('PASS complete connected tower claim, mismatch isolation, closed dome and bounded source UVs')

-- Roof opacity must not inherit the separate facade cutout, even for holes
-- inside a row. A tiny image implementation exercises the real material path.
local function imageData(w,h)
 local pixels={}
 return {getPixel=function(_,x,y)return unpack(pixels[y*w+x]or{0,0,0,0})end,
 setPixel=function(_,x,y,...)pixels[y*w+x]={...}end,release=function()end}
end
love={image={newImageData=imageData},graphics={newImage=function(data)
 data.setFilter=function()end;return data
end}}
local source=imageData(80,80)
for y=0,79 do for x=0,79 do source:setPixel(x,y,.7,.2,.1,1)end end
source:setPixel(0,20,.1,.8,.2,1)
source:setPixel(10,20,0,0,0,0)
local rows,slots={},{}
for y=0,4 do rows[y+1]={};for x=0,4 do local n=y*5+x;rows[y+1][x+1]=n;slots[n]=n end end
local mat=M.material({kind='center',width=5,depth=5,rows=rows,ts={cols=5,midToSlot=slots,imageData=source}})
local _,_,_,facade=mat:getPixel(0,20)
local _,_,_,edge=mat:getPixel(80,20)
local _,_,_,hole=mat:getPixel(90,20)
assert(facade==0 and edge==1 and hole==1,'facade mask leaked into solid roof')
print('PASS opaque roof material preserves independent facade cutout')

for y=0,63 do for x=0,63 do source:setPixel(x,y,.3,.45,.7,1)end end
for y=2,5 do for x=0,63 do source:setPixel(x,y,.1,.8,.2,1)end end
for y=37,41 do for x=0,63 do source:setPixel(x,y,.39,.39,.48,1)end end
for y=30,41 do for _,x in ipairs({0,1,2,3,60,61,62,63})do source:setPixel(x,y,.85,.9,1,1)end end
local hoenn={kind='mart',width=4,depth=4,rows=rows,ts={cols=5,midToSlot=slots,imageData=source},
 custom={family='rse',back=2,roofEnd=42,wallBottom=63,bevel=3}}
local hm=M.material(hoenn)
local topR,topG,topB=hm:getPixel(80,3);assert(topB>topG and topB>topR,'rear roof contains surrounding grass')
local r=hm:getPixel(64,32);assert(r<.55,'pale wall pixels remain on blue roof corners')
r=hm:getPixel(64,40);assert(r==.39,'neutral roof outline retains facade corner')
r=hm:getPixel(0,40);assert(r==.85,'roof cleanup changed original facade')
print('PASS Hoenn roof corners exclude pale facade and retain neutral eave trim')
hoenn.custom.wallSample={5,58};hoenn.custom.trimSample={1,40}
source:setPixel(5,58,.65,.76,.92,1)
source:setPixel(1,40,.28,.31,.40,1)
local reviewed=M.material(hoenn)
local rr,gg,bb=reviewed:getPixel(128,0)
assert(rr==.65 and gg==.76 and bb==.92,'reviewed siding replaced by dominant trim color')
rr,gg,bb=reviewed:getPixel(130,0)
assert(rr==.28 and gg==.31 and bb==.40,'native structural trim recolored')
assert(M.window({custom={openings={{17,45,31,62,door=true},{33,45,47,54}}}})[1]==33,
 'side window sampled door glass rather than reviewed window')
hoenn.kind='center';hoenn.custom.centerRoof=true
for yy=16,22 do for xx=0,63 do source:setPixel(xx,yy,.8,.2,.2,1)end end
source:setPixel(20,16,1,.65,.4,1)
source:setPixel(30,2,1,.65,.4,1)
source:setPixel(8,2,.6,.35,.2,1) -- regional cliff behind the native roof
local centerMat=M.material(hoenn)
local cr,cg,cb=centerMat:getPixel(64+8,5)
assert(cr==.8 and cg==.2 and cb==.2,'regional cliff color contaminated roof')
cr,cg,cb=centerMat:getPixel(64+30,5)
assert(cr==1 and cg==.65 and cb==.4,'raised middle stripe lost its original color')

local door=M.doorSurface({kind='center',cx=24,cy=22,width=5,depth=5},26,26)
assert(door and door.w==14 and door.h==15 and door.sourceX==417 and door.sourceY==416)
assert(door.vertices[1][3]==22*16+78+2-.95,'door animation detached from facade recess')
assert(door.vertices[1][2]<16 and door.vertices[3][2]==0,'door became giant freestanding overlay')
assert(not M.doorSurface({kind='center',cx=24,cy=22,width=5,depth=5},25,26),'animation claimed neighboring wall')
local house={kind='house',cx=2,cy=4,width=5,depth=5,custom={back=2,roofEnd=54,wallBottom=79,bevel=3,openings={{48,57,65,78,door=true}}}}
local hd=M.doorSurface(house,5,8)
assert(hd and hd.w==17 and hd.h==21 and hd.vertices[1][2]==22 and hd.vertices[3][2]==1)
print('PASS native door animation matches authored entrance dimensions and recess')
