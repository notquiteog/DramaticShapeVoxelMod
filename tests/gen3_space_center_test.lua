local Space=dofile('lib/Gen3SpaceCenter.lua')
local recipe
for _,r in ipairs(dofile('data/gen3_hoenn_exteriors.lua'))do if r.geometry=='space_center' then recipe=r end end
assert(recipe and #recipe.rows==8 and #recipe.rows[1]==9)
local function fixture()
 local cells={};local rows={{0x371,0x372,0x373,0x374,0x375,0x376},{0x379,0x37a,0x37b,0x37c,0x37d,0x37e},
  {0x381,0x382,0x383,0x384,0x385,0x386},{0x389,0x38a,0x38b,0x38c,0x170,0x38e},
  {0x391,0x392,0x393,0x394,0x395,0x396},{0x399,0x39a,0x39b,0x39c,0x39d,0x39e}}
 local g={cx=60,cy=8,pair=recipe.pair,custom=recipe,width=9,depth=8,rows=recipe.rows}
 for iy,row in ipairs(rows)do for ix,mid in ipairs(row)do
  local x,y=g.cx+ix,g.cy-7+iy
  cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=recipe.pair,collision=0,shape={kind='flat'}}
 end end
 return cells,g
end
local cells,g=fixture();Space.prepare(cells,g);assert(g.launchDisplay)
for _,c in pairs(cells)do
 assert(c.collision==0,'presentation changed collision')
 if c.mid~=0x170 then
  assert(c.shape.ground==(c.cy<=5 and 0x170 or c.cy==6 and 2 or 1),'wrong native underlay')
  assert(c.shape.kind==(c.cy<=5 and 'water' or 'interiorFloor'))
 end
end
for _,mode in ipairs({'missing','wrong_pair','wrong_mid'})do
 local cs,gg=fixture()
 if mode=='missing'then cs['62:3']=nil elseif mode=='wrong_pair'then cs['62:3'].pair='general__petalburg' else cs['62:3'].mid=1 end
 Space.prepare(cs,gg);assert(not gg.launchDisplay)
 for _,c in pairs(cs)do assert(c.shape.kind=='flat','partial drawing was consumed')end
end
local Civic=assert(loadfile('lib/Gen3Civic.lua'))({require=function(n)
 if n=='BuildBudget'then return {tick=function()end,check=function()end}end
 if n=='ArchitecturalDetails'then return dofile('lib/ArchitecturalDetails.lua')end
 if n=='Gen3SpaceCenter'then return Space end
 error(n)
end})
local p=Civic.profile(g);local faces,highest=0,0
Civic.append(g,function(v,uv)
 faces=faces+1
 for i,q in ipairs(v)do
  assert(q[1]>=960 and q[1]<=1104 and q[3]>=128 and q[3]<=256,'model intrudes outside blocked building footprint')
  assert(q[2]>=0 and q[2]<=174)
  highest=math.max(highest,q[2])
  assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1)
 end
end)
assert(faces>500 and highest==174,'launch equipment missing')
local door=assert(Civic.doorSurface(g,64,15));assert(door.w==16 and door.h==16)
assert(door.vertices[1][1]==1024 and door.vertices[1][2]==24 and door.vertices[1][3]==254.05)
assert(not Civic.doorSurface(g,63,15))
print('Space Center complete source matching, underlay, bounds, volumes and native door: PASS')
