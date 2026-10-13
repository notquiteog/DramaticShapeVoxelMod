local C=dofile('lib/Gen3Civic.lua')
local g={kind='mart',cx=0,cy=0,width=4,depth=4}
local sign=false
C.append(g,function(v,t)
 local l,r=math.huge,-math.huge;local top,bottom=math.huge,-math.huge
 for i,q in ipairs(t)do l=math.min(l,q[1]*132);r=math.max(r,q[1]*132);top=math.min(top,q[2]*64);bottom=math.max(bottom,q[2]*64)end
 if l<9 and r>24 and top<50 and bottom>55 then
  sign=true;for _,q in ipairs(v)do assert(q[3]==64,'MART letters split across front planes')end
 end
end)
assert(sign,'complete native MART label must fit one facade face')
local door=C.doorSurface(g,2,3)
assert(door and math.abs(door.vertices[1][2]-20*16/19)<.001,'animation must match revised lower facade')
local rows={{0x28,0x29,0x2A,0x2B},{0x30,0x31,0x32,0x33},{0x38,0x39,0x3A,0x3B},{0x40,0x41,0x62,0x63}}
local cells={}
for y,row in ipairs(rows)do for x,mid in ipairs(row)do cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,primary='general',pair='city',collision=7}end end
cells['0:4']={cx=0,cy=4,mid=1,pair='city',collision=0,shape={kind='flat',reviewedSurface=true}}
cells['2:5']={cx=2,cy=5,mid=0x16E,pair='city',collision=0,shape={kind='flat'}}
assert(#C.prepare(cells,{})==1)
assert(C.ground(cells['0:0'])==0x16E,'nearby native city paving must replace grass under service building')
print('PASS complete MART sign plane, aligned door and native city paving')
