local K=dofile('lib/Gen3SceneCache.lua')
local l={cells={},overrides={},pair='forest',borderMids={665},width=6,height=6}
local rs={{def={midLayout=l},x=0,y=0,w=6,h=6}};local ts={forest={imageData={}}}
local function key(cam)return K.key(rs,0,0,6,6,ts,cam)end
local a=key();assert(a==key(),'unstable unchanged geometry')
l.overrides[3]={mid=1,coll=0,elev=0};local b=key();assert(a~=b,'cut tree would stay stale')
l.overrides[3].mid=2;assert(key()~=b,'in-place override would stay stale')
l.overrides={};assert(key()==a,'cleared override should restore identity')
ts.forest={imageData={}};assert(key()~=a,'replaced atlas not invalidated')
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
