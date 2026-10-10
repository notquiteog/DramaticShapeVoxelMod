local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local specs=dofile('data/gen2_depth_furniture.lua').TILESET_MANSION
local spec=specs[2];assert(spec.design=='gb_mansion_clock')
local r={design=spec.design,tiles={{54,56},{36,37},{52,53},{50,51}}}
local q=V.require('Gen2DesignedFurniture').build(r,nil,16,128,128)
local back,top,recess=false,false,0
for _,f in ipairs(q)do for _,p in ipairs(f)do
 assert(p[1]>=.499999 and p[1]<=15.500001 and p[3]>=19.499999 and p[3]<=30.500001 and p[2]>=0 and p[2]<=25.520001,'clock escapes its native blocked lower cell')
 if p[3]==20 then back=true end;if p[2]==25.52 then top=true end
end
 if f[1][3]==29.47 and f[2][3]==29.47 then recess=recess+1 end
 for _,uv in ipairs(f.uv)do assert(uv[1]>=0 and uv[1]<1 and uv[2]>=0 and uv[2]<1)end
end
assert(back and top and recess==96,'closed case, separate crown or whole native recessed dial lost')
print('PASS native mansion clock: closed case, projected crown, complete recessed dial and blocked-cell bounds')
local books=specs[1];assert(books.design=='gb_mansion_books')
local b=V.require('Gen2DesignedFurniture').build({design=books.design,tiles={{3,3},{54,56},{34,35},{50,51}}},nil,16,128,128)
local spines,cap=0,false
for _,f in ipairs(b)do
 for _,p in ipairs(f)do assert(p[1]>=.499999 and p[1]<=15.500001 and p[3]>=19.499999 and p[3]<=30.500001 and p[2]>=0 and p[2]<=16.520001,'rack escapes blocked lower cell or retains blank wall as extra height');if math.abs(p[2]-16.52)<1e-6 then cap=true end end
 if math.abs(f[1][3]-29.62)<1e-6 and math.abs(f[2][3]-29.62)<1e-6 then spines=spines+1 end
end
assert(cap and spines==42,'native four book spines or projected lid lost')
print('PASS Mansion low book racks: four native spines and closed correctly proportioned case')
