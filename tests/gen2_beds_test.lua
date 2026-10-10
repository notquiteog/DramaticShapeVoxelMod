local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local specs=dofile('data/gen2_depth_furniture.lua')
for _,variant in ipairs{'mansion','crystal','gold_silver'}do
 local cabin=variant~='mansion'
 local spec=cabin and specs.TILESET_LIGHTHOUSE[1]or specs.TILESET_MANSION[5]
 assert(spec.design==(cabin and 'gb_cabin_bed'or'gb_mansion_bed'))
 local q=V.require('Gen2DesignedFurniture').build({design=spec.design,tiles=cabin and(variant=='crystal' and{{70,71},{86,87},{131,132},{133,134}}or{{70,71},{86,87},{86,87},{59,60}})or{{6,7},{22,23},{22,23},{38,39}}},nil,16,128,128)
 local blanket,pillow,foot,head=0,0,false,false
 for _,f in ipairs(q)do for _,p in ipairs(f)do
  assert(p[1]>=1 and p[1]<=15 and p[3]>=1 and p[3]<=30.020001 and p[2]>=0 and p[2]<=10.5,'bed exceeds native blocked pair')
  if p[2]==10.5 then head=true end;if p[2]==0 then foot=true end
 end
 if math.abs(f[1][2]-6.02)<1e-6 and math.abs(f[2][2]-6.02)<1e-6 then blanket=blanket+1 end
 if math.abs(f[1][2]-6.52)<1e-6 and math.abs(f[2][2]-6.52)<1e-6 then pillow=pillow+1 end
 end
 assert(head and foot and blanket==(cabin and 120 or 160)and pillow==(variant=='crystal' and 16 or 6),'native bedding surfaces or closed supports lost')
end
print('PASS Mansion and cabin beds: native bedding/boards, closed supports and blocked footprint bounds')
