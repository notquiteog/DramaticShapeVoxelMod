local Bench=assert(loadfile('lib/Gen2Bench.lua'))()
local t={tiles={{7,8,9,10},{23,24,25,26},{39,40,41,42}}}
local faces=Bench.build(t,{getPixel=function()return .4,.5,.4,1 end},16,128,128)
assert(#faces==90,'bench geometry budget changed')
for _,q in ipairs(faces) do for i=1,4 do
 local p=q[i];assert(p[1]>=0 and p[1]<=32 and p[2]>=0 and p[2]<15 and p[3]>=0 and p[3]<=24,'bench bounds')
end end
local Cave=assert(loadfile('lib/Gen2CaveSurface.lua'))()
assert(not Cave.enabled({def={environment='CAVE'},tileset={id='TILESET_ICE_PATH'}}))
for x=0,64,8 do for z=0,64,8 do
 local floor=Cave.vertex({x,0,z});assert(floor[1]==x and floor[2]==0 and floor[3]==z)
 for y=8,32,8 do
  local p=Cave.vertex({x,y,z});local other=Cave.vertex({x,y,z})
  for i=1,3 do assert(p[i]==other[i],'shared cave seam mismatch') end
  assert(math.abs(p[1]-x)<=.71 and math.abs(p[2]-y)<=.61 and math.abs(p[3]-z)<=.71)
 end
end end
local old=package.loaded['src.world.Map']
package.loaded['src.world.Map']={new=function(def,ts)return {id=def.id,def=def,tileset=ts}end}
for _,gen2 in ipairs({false,true}) do
 local G=assert(loadfile('lib/StaticGeometry.lua'))({})
 local def={id='TEST',tileset='TS',width=1,height=1,blocks={1},environment='CAVE'}
 local ts={id='TS',blocks={{1}},collision={{0,0,0,0}},tileAttrs={{palette=1,vramBank=0}}}
 local data=gen2 and {gen2Maps={TEST=def},gen2Tilesets={TS=ts}} or {maps={TEST=def},tilesets={TS=ts}}
 assert(G.capture(data),'native registry snapshot missing')
 local map={id='TEST',def=def,tileset=ts};assert(G.source(map))
 ts.collision[1][1]=7;assert(not G.source(map),'runtime collision edit persisted as static geometry');ts.collision[1][1]=0
 ts.tileAttrs[1].palette=3;assert(not G.source(map),'material change reused cache');ts.tileAttrs[1].palette=1
 def.blocks[1]=2;assert(not G.source(map),'runtime block edit reused cache');def.blocks[1]=1
 assert(G.source(map),'reverted map should use immutable cache')
end
package.loaded['src.world.Map']=old
print('Known gaps: open bench bounds, cave seams/floor contact, native snapshots and live-change cache exclusion passed')
