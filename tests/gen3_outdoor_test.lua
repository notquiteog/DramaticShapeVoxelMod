-- These two are loaded with the mod's own dependency-injection argument. In a
-- running game the loader passes the mod namespace, so `V.require` resolves;
-- loaded bare, every V.require() inside them raised with V nil.
--
-- The local has to be declared BEFORE the table literal that closes over it:
-- writing `local V = { require = function() ... V ... end }` makes the inner V a
-- separate (nil) local, because the outer one is not in scope until the
-- constructor returns. That mistake reproduces the exact nil-V error the guard
-- was added to remove, which is why this is worth stating rather than leaving
-- to a future reader.
local V
local loaded = {}
V = { require = function(name)
  if loaded[name] ~= nil then return loaded[name] end
  local value = assert(loadfile('lib/' .. name .. '.lua'))(V)
  loaded[name] = value
  return value
end }
-- Some siblings read V.mod at load time: ModSetting stores it as its owner and
-- TreePresentation builds its settings rows on require, so a bare log table is
-- the minimum a module loaded off disk will accept.
V.mod = { log = { warn = function() end, info = function() end } }
V.data = function(name)
  local value = assert(loadfile('data/' .. name .. '.lua'))(V)
  loaded[name] = value
  return value
end
local S = assert(loadfile('lib/Gen3TileShape.lua'))(V)
local O = assert(loadfile('lib/Gen3Outdoor.lua'))(V)
local uv={{0,0},{1,0},{1,1},{0,1}}
local function geometry(mid)
 local faces={}
 O.append({cx=3,cy=4,mid=mid,ts={cols=256,midToSlot=setmetatable({},{__index=function(_,id)return id end}),imageData={getPixel=function(_,x,y)
 local px=x%16;local solid=x>=32 and px>=2 and px<=13 and y>=2 and y<=13
 return solid and .2 or .6,.7,.4,1 end}},shape=S.of('general','pallet_town',mid)},function(v,t,shade,anchor)
  for i,p in ipairs(v)do
   assert(p[1]>=48 and p[1]<=64 and p[3]>=64 and p[3]<=80,'prop escaped its native cell')
   assert(p[2]>=0 and p[2]<=16,'prop became an oversized block')
   for _,n in ipairs(t[i])do assert(n>=0 and n<=1,'UV escaped native drawing')end
  end
  -- The three plant drawings are three different things and must not share one
  -- expectation. In the shape table (lib/Gen3TileShape.lua:73):
  --   [4]  flowers  one upright card, 16px, anchored
  --   [5]  shrub    the modelled ROCKS & PLANTS hull: many un-anchored faces,
  --                carved by VoxelHull from the native drawing
  --   [0xD] grass   since 1.27.1 (cae8ee7) TWO meshes: the flat native ground
  --                plate at y=.025 with no anchor, then the upright tuft
  -- This test once read a missing anchor as a lost root for all three, which
  -- is right for none of them. Note the emit callback fires once per MESH, so
  -- for grass it runs twice and `v` is one mesh's worth of geometry each time.
  if mid==4 then
   assert(anchor~=nil,'flower has no rooted camera anchor')
   assert(anchor[1]==56 and anchor[2]==72 and anchor[3]>0,
    'the camera anchor is not rooted in the native cell')
   for _,p in ipairs(v)do assert(p[3]==72,'flower was inflated into a lump')end
   assert(v[1][2]==16,'a flower must keep its complete upright source drawing')
  elseif mid==0xD then
   if anchor then
    -- the upright tuft: rooted, and it must not be the flat ground plate
    assert(anchor[3]>0,'the grass tuft has no rooted camera anchor')
    assert(v[1][2]> .025,'the anchored mesh must be the tuft, not the ground plate')
   else
    for _,p in ipairs(v)do assert(p[2]==.025,'grass ground layer was raised')end
   end
  end
  faces[#faces+1]=v
 end,function()return uv end)
 return faces
end
for _,mid in ipairs({0xE6,0xE7,0xE8,0xE9,0xEC,0xED,0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xFC,0xFD})do
 assert(#geometry(mid)>=20,'fence has no posts and rails')
 assert(S.of('building','lab',mid).kind~='fence','outdoor fence leaked into an interior')
end
for _,mid in ipairs({0x87,0x97,0xB0,0xB1,0xC0,0xC1,0xC8,0xC9})do
 local max=0;for _,face in ipairs(geometry(mid))do for _,p in ipairs(face)do max=math.max(max,p[2])end end
 assert(max==2.5,'ledge is no longer a low mound')
end
for _,mid in ipairs({2,3})do assert(#geometry(mid)>0)end
-- [4] flowers is still ONE card. [5] is a shrub and is no longer: it is
-- carved as a solid voxel hull from the native drawing whenever ROCKS &
-- PLANTS is on `modeled` (the default), so it correctly emits many faces.
-- Asserting one card for both is what turned a real geometry change into a
-- permanent failure. The shrub's own contract is that it is a closed hull
-- standing on its cell, low enough to see over and not a tall block.
assert(#geometry(4)==1,"one native flower drawing became multiple cards")
local shrubFaces,shrubTop,shrubLow=0,-math.huge,math.huge
for _,face in ipairs(geometry(5))do
  shrubFaces=shrubFaces+1
  for _,p in ipairs(face)do
    shrubTop=math.max(shrubTop,p[2]);shrubLow=math.min(shrubLow,p[2])
  end
end
assert(shrubFaces>1,"a modelled shrub must be carved from more than one face")
assert(shrubLow==0,"a modelled shrub must stand on the ground plane")
assert(shrubTop<=16,"a shrub must not stand taller than its source drawing")
assert(#geometry(0xD)==2,'grass requires its complete ground art and one low upright tuft')
assert(S.of('general','pallet_town',1).reviewedSurface)
assert(not S.of('general','unreviewed',0x333).reviewedSurface,'unknown drawing reported as reviewed ground')
print('PASS outdoor scope, fence geometry, low ledge bounds and surface coverage distinction')

assert(S.of('general','city',0xFC).turn=='north' and S.of('general','city',0xFC).axis==4)
assert(S.of('general','city',0xFD).turn=='north' and S.of('general','city',0xFD).axis==12)
assert(S.of('general','city',0xF0).wood and S.of('general','city',0xF0).axis==4)
assert(S.of('general','city',0xF5).axis==12 and not S.of('general','city',0xF5).wood)
assert(S.of('general','city',0xF2).stop and S.of('general','city',0xF2).wood)

for _,mid in ipairs({0xC0,0xC1,0xC8,0xC9})do
 local sides={}
 for _,face in ipairs(geometry(mid))do for _,v in ipairs(face)do
  if v[3]==80 and (v[1]==48 or v[1]==64)then sides[v[1]]=math.max(sides[v[1]]or 0,v[2])end
 end end
 assert(sides[48]==2.5 and sides[64]==2.5,'sand/grass transition was tapered into a false end')
end
print('PASS sand/grass ledge joins retain continuous height and native caps')

-- Pallet's two shade variants are straight paired pickets, not corners.
for _,mid in ipairs{0x284,0x287}do
 local shape=S.of('general','pallet_town',mid)
 assert(shape.kind=='fence' and not shape.turn and not shape.axis)
 local count=0
 O.append({cx=0,cy=0,mid=mid,ts={},shape=shape},function(vs)
  for _,v in ipairs(vs)do assert(v[1]>=0 and v[1]<=16 and v[3]>=6.4 and v[3]<=9.6,'straight fence grew a perpendicular spur')end
  count=count+1
 end,function(_,id)assert(id==mid,'borrowed unrelated fence material');return uv end)
 assert(count>0)
end
assert(S.of('general','viridian_outdoor',0xEC).turn=='south','real general corner lost its turn')
print('PASS native Pallet straight pickets, source material and true-corner isolation')
for _,case in ipairs{{0xEE,12,8,16},{0xF6,12,0,8},{0x1F0,4,8,16}}do
 local shape=S.of('general','viridian_outdoor',case[1]);assert(shape.kind=='fence' and shape.axis==case[2])
 local rails=0
 O.append({cx=0,cy=0,mid=case[1],ts={},shape=shape},function(vs)
  local lo,hi=16,0
  for _,p in ipairs(vs)do assert(p[1]>=0 and p[1]<=16 and p[3]>=0 and p[3]<=16);lo=math.min(lo,p[3]);hi=math.max(hi,p[3])end
  if hi-lo==8 then assert(lo==case[3] and hi==case[4],'endpoint rail points into the wrong neighbor');rails=rails+1 end
 end,function()return uv end)
 assert(rails>0)
end
for _,case in ipairs{{0x336,nil},{0x337,'south'},{0x33F,nil}}do
 local s=S.of('general','rom_082d4b54',case[1]);assert(s.kind=='fence' and s.turn==case[2])
 assert(S.of('general','pallet_town',case[1]).kind~='fence','Fuchsia alias escaped its tileset')
end
for _,mid in ipairs{0xD6,0xD7}do
 local ts={cols=2,midToSlot={[mid]=0,[0xE7]=1},imageData={}}
 function ts.imageData:getPixel(x,y)if x<8 then return 0,1,0,1 end;return .5,.5,.5,1 end
 local planes=0
 O.append({cx=0,cy=0,mid=mid,ts=ts,shape=S.of('general','viridian_outdoor',mid)},function(vs)
  if vs[1][2]==.015 then
   planes=planes+1;for _,v in ipairs(vs)do assert(v[1]<=8,'metal fence leaked into flat foliage layer')end
  end
 end,function()return uv end)
 assert(planes==16,'native foliage missing from covered fence')
end
print('PASS endpoint direction, Fuchsia scope and covered-fence foliage separation')

local T=V.require('Gen3Tilesets')
T.bind({FR_FUCHSIA_CITY={pair='general__rom_082d4b34'}})
local spec=T.resolve('general__rom_082d4b34',{})
assert(spec.secondary=='rom_082d4b54')
assert(S.of(spec.primary,spec.secondary,0x336).kind=='fence','LeafGreen imported alias lost Fuchsia model')
T.bind(nil)
