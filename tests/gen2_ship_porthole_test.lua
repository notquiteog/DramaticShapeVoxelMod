local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local t=dofile('data/gen2_furniture.lua').TILESET_LIGHTHOUSE[3];assert(t.id=='crystal_ship_porthole')
local q=V.require('Gen2DesignedFurniture').build(t,nil,16,128,128)
local art,base,cap=0,false,false
for _,f in ipairs(q)do for _,p in ipairs(f)do
 assert(p[1]>=0 and p[1]<=16 and p[3]>=0 and p[3]<=15.990001 and p[2]>=0 and p[2]<=16,'porthole leaves blocked native wall cell')
 if p[2]==0 then base=true end;if p[2]==16 then cap=true end
end
 if math.abs(f[1][3]-15.99)<1e-6 and math.abs(f[2][3]-15.99)<1e-6 and f[1][2]>=8 and f[2][2]>=8 and f[3][2]>=8 then art=art+1;for _,p in ipairs(f)do assert(p[2]>=8 and p[2]<=16)end end
end
assert(art==52 and base and cap,'native stepped rim mask or closed wall lost')
print('PASS ship porthole:52 native rim/glass pixels, closed wall and no walking-cell extrusion')
