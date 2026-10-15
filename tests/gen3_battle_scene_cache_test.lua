-- Exercise the production request policy with real scene keys and streaming.
-- Battle frames must hit the same snapshot, while changed clearing geometry
-- and native edits must complete before that frame is drawn.
local source=assert(io.open('lib/Gen3Scene.lua')):read('*a')
local requestSource=assert(source:match('(local function request%(game,cam%).-)\nlocal function build'))
local K=dofile('lib/Gen3SceneCache.lua')
local layout={cells={},overrides={},borderMids={},pair='outdoor',width=20,height=20}
local def={midLayout=layout};local ts={outdoor={imageData={}}}
local regions={{def=def,x=0,y=0,w=20,h=20}}
local env=setmetatable({Map={currentDef=function()return def end,refreshWorld=function()end},
 Player={px=80,py=80},Distance={radius=function()return 128 end},
 Boundary={regions=function()return regions end},SceneCache=K,Tiles={_pairs=ts}}, {__index=_G})
local request=setfenv(assert(loadstring(requestSource..'\nreturn request')),env)()
local B=dofile('lib/BuildBudget.lua')
local Stream=assert(loadfile('lib/SceneStream.lua'))({require=function()return B end})
local s=Stream.new(function()end);local built=0
local camera={battle=true,center={88,88},yaw=0}
local function frame()
 local r=request({},camera)
 return s:update(r.key,r.context,function(c)
  built=built+1
  c.terrainKey,c.terrainContext=K.keys(r.regions,r.x0,r.z0,r.x1,r.z1,ts,camera)
  c.serial=built;return c
 end,.002)
end
local original=frame()
for _=1,120 do assert(frame()==original)end
assert(built==1 and s.stats.hits==120,'stationary battle rescanned terrain')
camera.yaw=math.pi/2;local turned=frame()
assert(turned~=original and not s.pending,'new clearing deferred or stale')
layout.overrides[1]={mid=4,coll=7,elev=0};local edited=frame()
assert(edited~=turned and not s.pending,'native edit stale')
camera.battle=false;local world=frame()
assert(world~=edited and not s.pending,'world kept battle clearing')
assert(frame()==world and built==4)
print('PASS battle cache reuse, immediate orientation/edit/overworld transitions')
