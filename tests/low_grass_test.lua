-- Low native sprite grass must stay below a character's knees, while
-- flowers retain their complete upright source drawing.
local O=assert(loadfile('lib/Gen3Outdoor.lua'))()
for _,kind in ipairs({'grass','flowers'})do
 local count=0
 O.plant({cx=2,cy=3,mid=kind=='grass' and 13 or 4,shape={kind=kind}},function(v,uv,shade,anchor)
  count=count+1
  if not anchor then
   assert(kind=='grass');for _,p in ipairs(v)do assert(p[2]==.025)end
   return
  end
  assert(v[1][2]==(kind=='grass' and 4 or 16))
  for _,p in ipairs(v)do assert(p[2]>=0 and p[3]==56)end
  assert(anchor[1]==40 and anchor[2]==56,'sprite grass lost upright camera root')
 end,{{0,0},{1,0},{1,1},{0,1}})
 assert(count==(kind=='grass' and 2 or 1),'plant lost its ground drawing or became duplicated clumps')
end
local G=dofile('lib/Gen2DepthGrass.lua');local q={}
local ts={id='TILESET_JOHTO',tilesPerRow=1,imageWidth=8,imageHeight=8}
assert(G.append(q,{tileset=ts},0,0,{getPixel=function(_,x,y)return .1,.5,.1,1 end},0,{}))
assert(#q>0);local top=0
for _,f in ipairs(q)do for i=1,4 do assert(f[i][2]>=0 and f[i][2]<=4);top=math.max(top,f[i][2])end end
assert(top==4,'Crystal grass lost its low sprite silhouette')
print('PASS low rooted native grass and unchanged upright flower silhouette')
