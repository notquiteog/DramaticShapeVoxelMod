local V={};local modules={}
function V.require(n)if not modules[n]then modules[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return modules[n]end
local version='firered'
package.loaded['src.core.GameVersion']={get=function()return version end}
local F=V.require('Gen3Furniture');local n=0
for _,r in ipairs(F.recipes)do if r.design then
 version=r.family=='rse' and 'emerald' or 'firered'
 local cells={}
 for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,primary=r.primary or 'building',pair=r.pair or 'test',secondary=r.secondary or '',ts={}}end end
 local props=F.extract(cells);assert(#props==1 and props[1].recipe==r,'incomplete match '..r.name)
 local count,hi=0,0
 F.append(props[1],function(q,uv)
  if r.design=='fr_mart_counter' then
   for _,v in ipairs(q)do if v[2]>3 then assert(v[3]>=23,'checkout cabinetry occupies the clerk aisle')end end
  elseif r.design=='fr_mart_cooler' then
   for _,v in ipairs(q)do assert(v[3]>=19 and v[3]<=32,'cabinet pushes through the north wall or into the aisle')end
  end
  count=count+1;for i,p in ipairs(q)do assert(p[1]==p[1] and p[2]>=0);hi=math.max(hi,p[2]);assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1,'UV '..r.name)end
 end,function()return{{0,0},{1,0},{1,1},{0,1}}end)
 if r.design=='em_start_seat_pad' then assert(count>=7 and hi<1,'walkable seating must stay flush')
 elseif r.design=='fr_saffron_telepad' then assert(count>=7 and hi<.5,'teleport pad must stay flush')
 else assert(count>10,r.name) end;if r.design=='fr_bed'then assert(hi<=8,'bed upright')end
 if r.design=='fr_tower_grave'then assert(hi==12,'grave must have an upright headstone')end
 n=n+1
end end
local recipes=dofile('data/gen2_furniture.lua');local GB=V.require('Gen2DesignedFurniture')
for _,list in pairs(recipes)do for _,r in ipairs(list)do if r.design then
 local q=GB.build(r,{},16,128,128);assert(#q>0,r.id)
 for _,p in ipairs(q)do for i=1,4 do assert(p[i][2]>=0 and p[i][2]==p[i][2]);assert(p.uv[i][1]>=0 and p.uv[i][1]<=1 and p.uv[i][2]>=0 and p.uv[i][2]<=1,r.id)end end
 if r.design=='gb_seat'then for _,p in ipairs(q)do for i=1,4 do assert(p[i][2]<2.6)end end end
 n=n+1
end end end
print('PASS '..n..' complete designed objects: atlas bounds, finite geometry, native matches, bed and cushion heights')
