local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local s=dofile('data/gen2_depth_furniture.lua').TILESET_GATE[2]
assert(s.design=='gb_gate_terminal' and s.block==44)
local t={design=s.design,tiles={{92,93},{72,73},{74,75},{78,79}}}
local q=V.require('Gen2DesignedFurniture').build(t,nil,16,128,128)
local header,keyboard,monitor,inset=false,false,false,false
for _,f in ipairs(q)do for _,p in ipairs(f)do
 assert(p[1]>=0 and p[1]<=16 and p[3]>=0 and p[3]<=32 and p[2]>=0 and p[2]<=19,'outside two blocked source cells')
 header=header or(p[3]<16 and p[2]==16)
 inset=inset or(p[1]==15.95 and p[3]==.05 and p[2]==16)
 keyboard=keyboard or(p[3]>=25 and p[2]>6.6 and p[2]<8)
 monitor=monitor or(p[3]>=17 and p[2]==19)
end end
assert(header and keyboard and monitor and inset)
print('PASS gate PC native header, raised keyboard, closed CRT and blocked footprint')
