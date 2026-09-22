local M=assert(loadfile('lib/Gen3Civic.lua'))()
for _,kind in ipairs({'gym','center','mart'})do
 local g={kind=kind,cx=3,cy=5,width=kind=='gym' and 7 or kind=='center' and 5 or 4}
 local p=M.profile(g);local faces={}
 M.append(g,function(v,uv)
  faces[#faces+1]={v,uv}
  for i,a in ipairs(v)do
   assert(a[1]>=48 and a[1]<=48+p.w and a[3]>=80+p.back-.061 and a[3]<=80+p.front+p.projection,'building escaped its reviewed footprint')
   assert(a[2]>=0 and a[2]<=math.max(p.wall+p.bevel,p.doorHeight),'building grew a ridge or underground wall')
   assert(uv[i][1]>0 and uv[i][1]<1 and uv[i][2]>0 and uv[i][2]<1,'material samples an adjacent source rectangle')
  end
 end)
 -- The first three faces are the facade: exterior ground rows stop at the
 -- wall base, while the middle rectangle owns the complete recessed door.
 assert(faces[1][2][3][2]<p.wallBottom/p.h)
 assert(faces[3][1][1][1]==48+p.doorLeft)
 assert(faces[3][1][1][3]==80+p.front+p.projection)
 local plateau=false
 for _,f in ipairs(faces)do
  local high=true;for _,a in ipairs(f[1])do high=high and a[2]==p.wall+p.bevel end
  if high then plateau=true end
 end
 assert(plateau,'roof has no flat plateau')
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
