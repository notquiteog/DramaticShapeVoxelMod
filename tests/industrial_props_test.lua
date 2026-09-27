local F=dofile('lib/Gen3Furniture.lua')
local function recipe(name)
 for _,r in ipairs(F.recipes)do if r.name==name then return r end end
 error(name)
end
local function cellsFor(r,pair)
 local c={}
 for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
  local cx,cy=x-1,y-1
  c[cx..':'..cy]={cx=cx,cy=cy,mid=mid,pair=pair or r.pair,primary='building',ts={}}
 end end
 return c
end
local G=dofile('lib/InteriorFurniture.lua')
for _,cap in ipairs({0x2d0,0x2d1})do for middle=0,2 do
 local r=recipe('power_plant_drums_'..cap..'_'..middle)
 local cells=cellsFor(r);local p=F.extract(cells)
 assert(#p==1 and p[1].recipe==r,'column not claimed as one complete drawing')
 for _,c in pairs(cells)do assert(c.prop==p[1],'drum slice left on floor')end
 local lids,bases={},{}
 G.draw(r.design,{width=16,height=#r.rows*16,
  sample=function(x,y)assert(x>=0 and x<16 and y>=0 and y<#r.rows*16);return {}end,
  source=function(x,y,w,h)assert(x>=0 and x+w<=16 and y>=0 and y+h<=#r.rows*16)end,
  box=function(l,b,n,rr,h,s)
   assert(l>=0 and rr<=16 and n>=0 and s<=#r.rows*16 and h<=14,'unbounded drum')
   if h==13.4 then lids[math.floor((n+s)/32+.5)]=true end
   if b==0 then bases[math.floor((n+s)/32+.5)]=true end
  end})
 local n=0;for _ in pairs(lids)do n=n+1 end
 assert(n==middle+1,'stretched or duplicated drums')
 n=0;for _ in pairs(bases)do n=n+1 end
 assert(n==middle+1,'drum not grounded separately')
 cells=cellsFor(r);cells['0:'..(#r.rows-1)].mid=0x29f
 assert(#F.extract(cells)==0,'partial column consumed floor')
 assert(#F.extract(cellsFor(r,'unrelated'))==0,'drums matched another tileset')
end end
local r=recipe('power_plant_rubble');local faces=0
G.draw(r.design,{width=16,height=16,sample=function()return {}end,
 box=function()error('rubble returned to rectangular pedestals')end,
 face=function(vertices)
  faces=faces+1
  for _,p in ipairs(vertices)do assert(p[2]>=0 and p[2]<=4.1,'rubble too tall')
   assert(p[1]>=1 and p[1]<=15 and p[3]>=1 and p[3]<=14,'rubble outside native footprint')end
 end})
assert(faces>=45 and r.spriteAlternative=='rock' and r.cutout,'missing closed rubble or sprite option')
local P=dofile('lib/Gen3AdditionalInteriors.lua').rom_082d4e9c
assert(not P.walls[0x2d8] and not P.walls[0x2d9],'drum fragments still classified as walls')
-- The shared ROCKS & PLANTS choice must reach the existing native-card path.
local calls=0
local V={require=function(name)
 if name=='TreePresentation'then return {props={get=function()return 'cards'end}}end
 if name=='Gen3Cave'then return {rock=function(c,emit)
  assert(c.mid==0x2b6 and c.shape.ground==0x29f and c.shape.height==7)
  calls=calls+1
 end}end
 return assert(loadfile('lib/'..name..'.lua'))()
end}
local CardF=assert(loadfile('lib/Gen3Furniture.lua'))(V)
local cells=cellsFor(r);cells['0:0'].ts.imageData={}
local p=CardF.extract(cells)[1]
CardF.append(p,function()error('card selection emitted the solid pile')end,
 function()return{{0,0},{1,0},{1,1},{0,1}}end)
assert(calls==1,'rubble ignored sprite setting')
print('PASS six complete drum columns, individual lids/feet, source scope, low rubble and native-card selection')
