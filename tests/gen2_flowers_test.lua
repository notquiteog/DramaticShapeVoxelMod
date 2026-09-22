local M=assert(loadfile('lib/Gen2Flowers.lua'))()
local ts={id='TILESET_JOHTO',tilesPerRow=16,imageWidth=128,imageHeight=128,
 blocks={{5,3,5,3}},anim={frames={{func='AnimateFlowerTile'}}}}
assert(M.forTileset(ts).ground==5)
assert(M.forTileset(ts).slot==nil,'flowers still use invented palette swatches')
local data={getPixel=function(_,x,y)
 local px=x%8
 local dark=px>=2 and px<=5 and y>=2 and y<=5 and not(px==3 and y==3)
 local v=dark and .2 or 1
 return v,v,v,1
end}
local mask=M.mask(data,24,0)
assert(mask[3*8+3],'enclosed pale petal was erased')
assert(not mask[0],'ground survives flower mask')
local q={};assert(M.append(q,{tileset=ts},3,4,data))
assert(#q==1,"native flower must be one flat card")
for _,f in ipairs(q)do for i=1,4 do local v=f[i]
 assert(v[1]>=24 and v[1]<=32 and v[3]==36,'flower card is curved or escaped the tile')
 assert(v[2]>=0 and v[2]<=8,'flower card changed native proportions')
 assert(f.canopy[1]==28 and f.canopy[2]==36 and f.canopy[3]>0,'missing grounded camera anchor')
 assert(f.uv[i][1]>=24/128 and f.uv[i][1]<=32/128,'not sampling native flower')
end end
assert(not M.forTileset({id='TILESET_JOHTO',blocks={},anim={frames={}}}))
assert(not M.forTileset({id='TILESET_LAB',blocks={},anim=ts.anim}))
print('PASS native flower silhouette, enclosed highlights, source UVs, flat camera-anchored cards and scope')
