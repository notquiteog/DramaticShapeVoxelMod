local F=dofile('lib/Gen3TreeFootprints.lua')
local function field(w,h,forest)
 local cells={}
 for y=0,h-1 do for x=0,w-1 do
  cells[x..':'..y]={cx=x,cy=y,mid=36,collision=7,elevation=0,
   primary='general',pair='general__test',shape={kind='tree',ground=1,
   root=not forest and x==0 and y==h-1 or forest and x==1 and y==0,
   spacing=forest and 3 or nil,anchorX=16,anchorZ=12}}
 end end
 return cells
end
for _,ed in ipairs{'firered','leafgreen','emerald','ruby','sapphire'}do
 local cells=field(2,2);local originals={}
 for k,c in pairs(cells)do originals[k]={c.mid,c.collision,c.elevation,c.shape}end
 local s=F.prepare(cells,ed);assert(s.models==1 and s.cells==4 and s.fragments==0)
 local r=cells['0:1'];assert(r.shape.root and r.shape.anchorX==16 and r.shape.anchorZ==0)
 assert(r.shape.modelWidth==31.96 and r.shape.modelDepth==31.96)
 for k,c in pairs(cells)do
  assert(c.treeOwner==r and c.shape.treeBounds[1]==0 and c.shape.treeBounds[4]==32)
  assert(c.mid==originals[k][1]and c.collision==originals[k][2]and c.elevation==originals[k][3])
  assert(originals[k][4].anchorZ==12 and originals[k][4].modelWidth==nil,'shared source shape mutated')
 end
end
-- Walking crown projections (including encounter grass) cannot acquire a
-- trunk. Remaining blocked pieces still receive bounded physical crowns.
local cells=field(2,2);cells['0:0'].collision=24;cells['1:0'].collision=0
local s=F.prepare(cells,'emerald');assert(s.projected==2 and s.cells==2 and s.models==1)
assert(not cells['0:0'].shape.root and cells['0:0'].shape.ground==0xd)
assert(not cells['1:0'].shape.root and cells['1:0'].shape.ground==1)
assert(cells['0:1'].shape.treeBounds[2]==16,'canopy occupies projected walking row')
-- Forest portraits are taller than their ordinary two-row ground ribbon.
cells=field(3,3,true);cells['1:2'].mid=676
s=F.prepare(cells,'firered');assert(s.models==1 and s.cells==9)
assert(cells['1:0'].shape.modelDepth==47.96 and cells['1:0'].shape.anchorZ==24)
cells=field(3,2,true);s=F.prepare(cells,'leafgreen')
assert(s.models==1 and cells['1:0'].shape.modelDepth==31.96)
-- Do not group mismatched source providers, civic/prop drawings or an
-- independently authored regional tree. Unknown editions stand down.
cells=field(2,2);cells['1:0'].pair='general__third_party'
cells['0:0'].civic={};cells['0:1'].prop={}
cells['1:1'].regionalTree=true
s=F.prepare(cells,'ruby');assert(s.cells==1 and cells['1:0'].shape.modelWidth==15.96)
assert(not cells['0:0'].treeOwner and not cells['0:1'].treeOwner and not cells['1:1'].treeOwner)
cells=field(2,2);s=F.prepare(cells,'custom');assert(s.models==0 and not cells['0:0'].treeOwner)
-- Generated forest boundaries have no native collision value; a foreign
-- missing/flat cell still prevents rectangle ownership across that gap.
cells=field(2,2);for _,c in pairs(cells)do c.collision=nil;c.boundary='forest'end
cells['1:1'].shape={kind='flat'};s=F.prepare(cells,'sapphire');assert(s.cells==3)
assert(not cells['1:1'].treeOwner)
print('PASS five-edition native tree ownership, walking projections, forest ribbons, source immutability and third-party standdown')
