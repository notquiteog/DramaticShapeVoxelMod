local recipes=assert(loadfile('data/gen2_furniture.lua'))()
local bed,bin
for _,r in ipairs(recipes.TILESET_LAB) do if r.id=='crystal_healing_machine' then bed=r elseif r.id=='crystal_lab_bin' then bin=r end end
assert(bed.support==6 and bed.parts[1].depth==32 and bed.parts[1].top[2]==27,'healing bed must be horizontal at six-pixel height')
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
