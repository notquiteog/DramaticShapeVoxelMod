local S=assert(loadfile('lib/Gen3TileShape.lua'))()
local O=assert(loadfile('lib/Gen3Outdoor.lua'))()
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
  if mid==4 or mid==5 or mid==0xD then
   assert(anchor and anchor[1]==56 and anchor[2]==72 and anchor[3]>0,'native plant has no rooted camera anchor')
   for _,p in ipairs(v)do assert(p[3]==72,'native plant was inflated into a lump')end
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
for _,mid in ipairs({4,5,0xD})do assert(#geometry(mid)==1,"one native drawing became multiple cards")end
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
