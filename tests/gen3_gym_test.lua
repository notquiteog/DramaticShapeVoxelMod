local Buildings=assert(loadfile('lib/Gen3Buildings.lua'))()
local function drawing(w,variant)
 local rows={{0x139},{0x141},{0x149},{0x150,0x151,0x152,0x153,0x154},{0x158,0x159,0x15A,0x15B,0x15C}}
 for i=2,w-1 do rows[1][i]=0x13A;rows[2][i]=0x142;rows[3][i]=0x14A end
 rows[1][w]=0x13B;rows[2][w]=0x143;rows[3][w]=0x14B
 for i=6,w-1 do rows[4][i]=0x155;rows[5][i]=0x15D end
 rows[4][w]=0x156;rows[5][w]=0x15E
 if variant=='viridian' then rows[1]={0x2AD,0x2AE,0x2AE,0x2AE,0x2AE,0x2AF}
 elseif variant=='fuchsia' then rows[1]={0x285,0x286,0x286,0x286,0x286,0x286,0x287}
 elseif variant=='saffron' then rows[1]={0x300,0x301,0x302,0x301,0x302,0x301,0x303};rows[4][1]=0x305;rows[5]={0x310,0x311,0x312,0x15B,0x313,0x314,0x315}
 elseif variant=='cinnabar' then rows[1]={0x281,0x282,0x283,0x283,0x283,0x284};rows[5][w]=0x2BF end
 local cells={}
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do cells[x..':'..y]={cx=x,cy=y,mid=mid,pair='general',primary='general',shape={kind='flat'}}end end
 return cells
end
for _,case in ipairs({{7,'standard'},{8,'standard'},{6,'viridian'},{7,'fuchsia'},{7,'saffron'},{6,'cinnabar'}})do
 local cells=drawing(case[1],case[2]);local gyms=Buildings.prepare(cells)
 assert(#gyms==1 and gyms[1].variant==case[2])
 local count=0
 for _,c in pairs(cells)do
  assert(c.gym==gyms[1],'gym left a flat facade or roof strip')
  local col=Buildings.column(c.gym);assert(col.height==32 and col.roofs==3 and col.walls==2 and col.roofInset==12)
  assert(c.shape.kind==(c.cy<=3 and 'roof' or 'wall'));count=count+1
 end
 assert(count==case[1]*5)
 cells=drawing(case[1],case[2]);cells['2:4'].mid=1
 assert(#Buildings.prepare(cells)==0,'incomplete gym consumed unrelated scenery')
 cells=drawing(case[1],case[2]);cells['2:4'].pair='different'
 assert(#Buildings.prepare(cells)==0,'gym crossed a tileset boundary')
 cells=drawing(case[1],case[2]);for _,c in pairs(cells)do c.primary='building'end
 assert(#Buildings.prepare(cells)==0,'gym exterior leaked indoors')
end
print('PASS complete variable-width gym shells, all trim variants, partial-match and tileset isolation')
local g=Buildings.prepare(drawing(7,'standard'))[1]
local n=0
Buildings.appendSiding(g,function(vertices,uv)
 n=n+1
 for i,p in ipairs(vertices)do
  assert(p[1]>=g.cx*16-.61 and p[1]<=(g.cx+g.width)*16+.61,'gym siding protrudes into neighboring cells')
  assert(p[2]>=0 and p[2]<=32,'siding rises through roof')
  assert(p[3]>=35.39 and p[3]<=96,'rear trim left roof footprint')
  assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1)
 end
end,function()return {{0,0},{1,0},{1,1},{0,1}}end)
assert(n>25,'side/rear detailing absent')
