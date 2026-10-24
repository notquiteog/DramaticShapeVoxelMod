local M=dofile('lib/Gen3DesignedFurniture.lua')
local function geometry(inset)
 local out={};local uv={{0,0},{1,0},{1,1},{0,1}}
 local function emit(v)for _,p in ipairs(v)do out[#out+1]={p[1],p[2],p[3]}end end
 local function box(l,b,n,r,h,s)
  emit{{l,h,n},{r,h,n},{r,h,s},{l,h,s}}
  emit{{l,h,s},{r,h,s},{r,b,s},{l,b,s}}
  emit{{r,h,n},{l,h,n},{l,b,n},{r,b,n}}
  emit{{l,h,n},{l,h,s},{l,b,s},{l,b,n}}
  emit{{r,h,s},{r,h,n},{r,b,n},{r,b,s}}
 end
 local function source(sx,sy,w,h,a,b,c,d)emit{a,b,c,d}end
 assert(M.append({cx=0,cy=0,w=16,d=16,recipe={design='fr_tower_grave',groundInset=inset}},source,box,function()return uv end,emit))
 return out
end
local a,b=geometry(),geometry(.025);assert(#a==#b and #a>0)
local contacts=0
for i,v in ipairs(a)do local q=b[i];assert(q[1]==v[1]and q[3]==v[3])
 if v[2]==0 then assert(q[2]==-.025);contacts=contacts+1 else assert(q[2]==v[2],'native contact opt-in moved an upper vertex')end
end
assert(contacts>0)
local recipes={};M.install(recipes);local count=0
for _,r in ipairs(recipes)do if r.name:match('^tower_grave_')then assert(r.groundInset==.025);count=count+1 end end
assert(count==6)
for _,r in ipairs(dofile('lib/Gen3MemorialFurniture.lua'))do assert(r.groundInset==.025 and r.blockedRows[1]and r.ground==(r.rows[1][1]==0x326 and 0x2e7 or 0x2e6))end
print('PASS native grave fallback recesses only exact bottom contacts, including underside and adjoining side edges')
