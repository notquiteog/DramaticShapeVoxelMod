local recipes=assert(loadfile('data/gen2_furniture.lua'))()
local bed,bin
for _,r in ipairs(recipes.TILESET_LAB) do if r.id=='crystal_healing_machine' then bed=r elseif r.id=='crystal_lab_bin' then bin=r end end
local center
for _,r in ipairs(recipes.TILESET_POKECENTER) do if r.id=='crystal_center_healer' then center=r end end
local geometry=dofile('lib/InteriorFurniture.lua')
local V={require=function(n)assert(n=='InteriorFurniture');return geometry end}
local builder=assert(loadfile('lib/Gen2DesignedFurniture.lua'))(V)
for _,r in ipairs({bed,center})do
 assert(r.support==6,'healing balls must retain tray support')
 local trayArea,maxHeight=0,0
 for _,q in ipairs(builder.build(r,{},16,128,128))do
  for i=1,4 do maxHeight=math.max(maxHeight,q[i][2])end
  if q[1][2]>6 and q[1][2]<6.1 and q[1][2]==q[2][2] and q[1][2]==q[3][2]then
   trayArea=trayArea+math.abs((q[2][1]-q[1][1])*(q[3][3]-q[1][3]))
  end
 end
 assert(trayArea>500 and maxHeight<=12,'healer needs a broad horizontal tray, not an upright slab')
end
local data={getPixel=function(_,x,y)local c=(x+y)%4/3;return c,c,c,1 end}
local q=assert(loadfile('lib/Gen2Bin.lua'))().build(bin,data,16,128,128)
assert(#q==50,'bin must include all outer, rim, inner and base faces')
local high,low=0,100
for _,face in ipairs(q) do for i=1,4 do
 assert(face.uv[i][1] and face.uv[i][2],'bin UVs must survive Buildings.stamp')
 local p=face[i];high=math.max(high,p[2]);low=math.min(low,p[2])
 assert(p[1]>2 and p[1]<14 and p[3]>2 and p[3]<14,'bin exceeds its small footprint')
end end
assert(high==10 and low==0,'bin height/ground changed')
for i=1,#q,5 do
 assert(q[i+1][1][2]==10 and q[i+2][3][2]==2,'rim must surround a deep open interior')
end
print('healing bed orientation and open tapered bin geometry passed')
