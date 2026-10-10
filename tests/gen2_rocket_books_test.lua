local V,cache={},{}
function V.require(n)
 if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end
 return cache[n]
end
local r=assert(loadfile('data/gen2_furniture.lua'))().TILESET_UNDERGROUND[3]
assert(r.maps.TEAM_ROCKET_BASE_B1F and not r.maps.SAFFRON_GYM)
local q=V.require('Gen2DesignedFurniture').build(r,nil,16,128,128)
local top,back=false,false
for _,f in ipairs(q)do for _,p in ipairs(f)do
 assert(p[1]>=1-1e-6 and p[1]<=15+1e-6 and p[3]>=20 and p[3]<=30.31,'bookcase crosses its blocked cell')
 assert(p[2]>=0 and p[2]<=26.021)
 if p[2]==26.02 then top=true end
 if p[3]==20 then back=true end
end end
assert(top and back and #q>100,'native shelves lost complete cap, back or separate contents')
print('PASS Rocket bookcases: closed back/cap, separate books and bounded blocked-cell footprint')
