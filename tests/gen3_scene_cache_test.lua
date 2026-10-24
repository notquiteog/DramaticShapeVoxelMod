local K=dofile('lib/Gen3SceneCache.lua')
local l={cells={},overrides={},pair='forest',borderMids={665},width=6,height=6}
local rs={{def={midLayout=l},x=0,y=0,w=6,h=6}};local ts={forest={imageData={}}}
local function key(cam)return K.key(rs,0,0,6,6,ts,cam)end
local a=key();assert(a==key(),'unstable unchanged geometry')
local _,world=K.keys(rs,0,0,6,6,ts)
local _,nextWindow=K.keys(rs,6,0,12,6,ts)
assert(world==nextWindow,'walking changed world context')
l.overrides[3]={mid=1,coll=0,elev=0};local b=key();assert(a~=b,'cut tree would stay stale')
l.overrides[3].mid=2;assert(key()~=b,'in-place override would stay stale')
l.overrides={};assert(key()==a,'cleared override should restore identity')
ts.forest={imageData={}};assert(key()~=a,'replaced atlas not invalidated')
local _,newProvider=K.keys(rs,0,0,6,6,ts)
assert(world==newProvider,'provider readiness forced cold map rebuild')
local layer=key();ts.forest.overImageData={};assert(key()~=layer,'upper atlas replacement ignored')
local c=key();rs[1].x=1;assert(key()~=c,'connected-map placement stale')
assert(key({replay={}})==nil,'replay edits must not reuse layout shortcut')
l.overrides=nil;assert(key()==nil,'unknown provider must retain full scan')
print('PASS scene cache: unchanged reuse, overrides/cuts/reset, atlas, connected maps and replay fallback')
local F=dofile('lib/Gen3Forest.lua');local cells={}
local function add(y,mid)cells['1:'..y]={cx=1,cy=y,mid=mid,pair='forest',shape={kind='tree',spacing=3}}end
add(1,649);add(3,665);add(5,665);add(8,676)
assert(F.prepare(cells)==3,'overlapping crowns lost or bottom tree doubled')
assert(cells['1:1'].shape.anchorZ==56 and not cells['1:8'].shape.root)
cells['1:5']=nil;assert(F.prepare(cells)==3 and cells['1:8'].shape.root,'clipped crown lost exposed trunk')
print('PASS complete and overlapping forest crowns, edge fragments and no duplicate trunks')

-- Exercise the allocation-free shortcut after warming it, then change every
-- mutable input the native renderer permits (including edits in place).
l.overrides={};rs[1].x=0
local function changed(edit,label)
 local before=key();assert(key()==before);edit();assert(key()~=before,label)
end
changed(function()l.borderMids[1]=666 end,'border mutation missed')
changed(function()l.cells={} end,'layout cell replacement missed')
changed(function()rs[1].w=7 end,'connected region dimensions missed')
changed(function()rs[1].mapId='FR_VIRIDIAN_FOREST' end,'connected map identity kept stale optional tree eligibility')
changed(function()l.overrides[4]={mid=2,coll=0,elev=1}end,'added edit missed')
changed(function()l.overrides[4].coll=1 end,'collision edit missed')
changed(function()l.overrides[4].elev=2 end,'elevation edit missed')
changed(function()l.overrides[4]=nil end,'removed edit missed')
changed(function()rs[1].def.voxelWater=false end,'water optout retained lowered cached surface')
changed(function()rs[1].def.voxelWater={bankDepth=3}end,'authored water depth missed')
changed(function()rs[1].def.voxelWater.bankDepth=5 end,'in-place water depth mutation missed')
changed(function()rs[1].def.voxelWater.waterLevel=-7 end,'absolute authored water level missed')
changed(function()rs[1].def.voxelWater.waterline=-4 end,'local authored waterline missed')
changed(function()rs[1].def.voxelWater.preserveWaterLevel=true end,'preserved author water surface missed')
changed(function()rs[1].def.voxelWater.bankMaterial=false end,'native bank material optout missed')
local battle={battle=true,center={10,20},yaw=0}
local bk=key(battle);assert(key(battle)==bk)
battle.center[1]=11;assert(key(battle)~=bk);bk=key(battle)
battle.yaw=.2;assert(key(battle)~=bk);assert(key()~=key(battle),'battle context leaked into field')
local prior,context=K.keys(rs,0,0,6,6,ts)
local window,nextContext=K.keys(rs,6,0,12,6,ts)
assert(window~=prior and context==nextContext,'window movement changed context')
local foreign={{def={midLayout={cells={},pair='foreign'}}}}
assert(K.keys(foreign,0,0,6,6,ts)==nil,'unknown provider cached')
assert(key(),'unknown provider poisoned later native layout')
print('PASS memoized border, cells, region, edit, battle, window and unknown-provider invalidation')

-- Window-only movement must preserve the exact cold fingerprint, including
-- sparse gameplay edits and provider identity, without sorting edits again.
local moving=K.new()
local originalSort=table.sort
moving.keys(rs,0,0,6,6,ts)
local sorts=0
table.sort=function(...)sorts=sorts+1;return originalSort(...)end
for x=1,100 do moving.keys(rs,x,0,x+6,6,ts)end
table.sort=originalSort
assert(sorts==0,'window movement sorted unchanged world edits')
local hot=moving.keys(rs,100,0,106,6,ts)
assert(hot==K.new().keys(rs,100,0,106,6,ts),'window shortcut changed fingerprint')
l.overrides[9]={mid=17,coll=1,elev=3}
assert(moving.keys(rs,101,0,107,6,ts)==K.new().keys(rs,101,0,107,6,ts),'edit during window change missed')
ts.forest.imageData={}
assert(moving.keys(rs,102,0,108,6,ts)==K.new().keys(rs,102,0,108,6,ts),'provider during window change missed')
print('PASS window-only movement reuses content snapshot; concurrent edits/providers invalidate')
