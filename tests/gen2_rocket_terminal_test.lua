local V,cache={},{}
function V.require(n)
 if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end
 return cache[n]
end
local r=assert(loadfile('data/gen2_furniture.lua'))().TILESET_UNDERGROUND[4]
assert(r.backing.tiles[1][1]==4 and r.backing.tiles[2][1]==20 and r.backing.height==16,'desk must restore the native wall')
assert(r.maps.TEAM_ROCKET_BASE_B1F and not r.maps.GOLDENROD_DEPT_STORE_B1F)
local q=V.require('Gen2DesignedFurniture').build(r,nil,16,128,128)
local screen,underside,wall=false,false,false
for _,f in ipairs(q)do
 for _,p in ipairs(f)do
  assert(p[1]>=-1e-6 and p[1]<=32+1e-6 and p[3]>=0 and p[3]<=31,'terminal enters a native walking cell')
  assert(p[2]>=0 and p[2]<=19.01)
 end
 if math.abs(f[1][3]-23.98)<1e-6 then screen=true end
 if f[1][2]==5.8 then underside=true end
 if math.abs(f[1][3]-16.01)<1e-6 then wall=true end
end
assert(screen and underside and wall,'terminal lost recessed screen or closed desk underside')
print('PASS Rocket terminal: monitor volume, underside, wall-strip retention and blocked footprint')
