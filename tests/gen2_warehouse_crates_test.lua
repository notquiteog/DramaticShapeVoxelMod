local V,cache={},{}
function V.require(n)
 if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end
 return cache[n]
end
local r=assert(loadfile('data/gen2_furniture.lua'))().TILESET_UNDERGROUND[1]
assert(r.maps.GOLDENROD_UNDERGROUND_WAREHOUSE and r.tiles[1][1]==67 and r.tiles[2][2]==84)
local q=V.require('Gen2DesignedFurniture').build(r,nil,16,128,128)
local lid,side,back=false,false,false
for _,f in ipairs(q)do
 for _,p in ipairs(f)do
  assert(p[1]>=1-1e-6 and p[1]<=15+1e-6 and p[3]>=1-1e-6 and p[3]<=15+1e-6,'crate crosses native cell boundary')
  assert(p[2]>=0 and p[2]<=12.021,'native front drawing extruded into oversized wall')
 end
 if f[1][2]==12.02 then lid=true end
 if math.abs(f[1][1]-1.4)<1e-6 and math.abs(f[2][1]-1.4)<1e-6 then side=true end
 if math.abs(f[1][3]-1.4)<1e-6 and math.abs(f[2][3]-1.4)<1e-6 then back=true end
end
assert(lid and side and back,'crate lacks lid or rear/side bracing')
print('PASS native warehouse crates: bounded volume, lid and rear/side brace geometry')
