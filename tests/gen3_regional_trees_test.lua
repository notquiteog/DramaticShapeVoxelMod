local T=dofile('lib/Gen3RegionalTrees.lua')
local function fixture(secondary,rows,collision)
 local cells={}
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do
  cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,primary='general',secondary=secondary,pair='general__'..secondary,
   mid=mid,collision=collision or 7,shape={kind='flat'}}
 end end
 return cells
end
local function verify(cells,edition,expected)
 local original={};for k,c in pairs(cells)do original[k]=c.collision end
 assert(T.prepare(cells,edition)==expected,'unexpected tree count '..edition)
 local roots=0
 for k,c in pairs(cells)do
  assert(c.collision==original[k],'native permissions changed')
  if c.regionalTree then
   assert(c.collision==7 and c.shape.kind=='tree','tree consumed walking/foreign cell')
   if c.shape.root then
    roots=roots+1
    local s=c.shape;local b=s.treeBounds
    local x,z=c.cx*16+s.anchorX,c.cy*16+s.anchorZ
    assert(x-s.modelWidth/2>b[1] and x+s.modelWidth/2<b[3])
    assert(z-s.modelDepth/2>b[2] and z+s.modelDepth/2<b[4])
    for yy=b[2]/16,b[4]/16-1 do for xx=b[1]/16,b[3]/16-1 do
     assert(cells[xx..':'..yy].regionalTree==c,'tree crossed another owner or walking cell')
    end end
   end
  end
 end
 assert(roots==expected)
end
local berry={{0x288,0x289,0x28a},{0x290,0x291,0x292},{0x2a0,0x2a1,0x2a2}}
for _,edition in ipairs{'firered','leafgreen'}do
 local c=fixture('rom_082d5004',berry);verify(c,edition,1)
 assert(c['1:0'].shape.modelDepth>47)
 c=fixture('rom_082d5004',{{0x298,0x299,0x29a},{0x290,0x291,0x292},{0x298,0x299,0x29a},{0x290,0x291,0x292}})
 verify(c,edition,2)
 for _,collision in ipairs{0,0x18,0xa1,0x29}do
  c=fixture('rom_082d5004',berry);c['0:0'].collision=collision;verify(c,edition,0)
 end
 c=fixture('rom_082d5004',berry);c['0:0']=nil;verify(c,edition,0)
 c=fixture('rom_082d5004',berry);c['1:0'].boundary='forest';verify(c,edition,0)
 c=fixture('rom_082d5004',berry);c['0:0'].pair='foreign';verify(c,edition,0)
 c=fixture('rom_082d4b54',{{0x318,0x319,0x31a},{0x320,0x321,0x322}});verify(c,edition,1)
 c=fixture('rom_082d4b54',{{0x318,0x319,0x31b},{0x320,0x321,0x322}});verify(c,edition,0)
end
for _,edition in ipairs{'emerald','ruby','sapphire'}do
 local c=fixture('fallarbor',{{0x26b,0x26c},{0x26d,0x26e}});verify(c,edition,1)
 c=fixture('fallarbor',{{0x204,0x205},{0x20c,0x20d}});c['0:0'].collision=0;verify(c,edition,1)
 assert(c['0:1'].shape.modelDepth<16,'walkable projected crown gained geometry')
 c=fixture('lavaridge',{{0x2c4},{0x2cc}});c['0:0'].collision=0;verify(c,edition,1)
 assert(c['0:0'].shape.kind=='tree' and not c['0:0'].shape.root)
 c=fixture('lavaridge',{{0x2c8,0x2c9,0x2ca}});verify(c,edition,1)
 c=fixture('lavaridge',{{0x2c8,0x2c9,0x2ca}});c['0:0'].collision=0;verify(c,edition,0)
 c=fixture('rom_082d5004',berry);verify(c,edition,0)
end
for _,edition in ipairs{'red','crystal','unknown'}do verify(fixture('rom_082d5004',berry),edition,0)end
verify(fixture('unrelated',berry),'firered',0)
verify(fixture('fallarbor',{{4,4},{4,4}}),'emerald',0)
verify(fixture('rom_082d5004',{{0x281,0x282},{0x283,0x284}}),'firered',0)
print('PASS regional tree families in five editions, blocked rectangles, native permissions, partial/foreign/flower exclusions')
