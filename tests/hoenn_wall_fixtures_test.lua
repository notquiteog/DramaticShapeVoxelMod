-- Native wall openings must have depth without moving a gameplay doorway.
local Furniture=assert(loadfile('lib/InteriorFurniture.lua'))()
for _,case in ipairs({{'em_home_round_window',16},{'em_home_wallpaper',16},{'em_home_tunnel_entrance',48}})do
 local id,width=case[1],case[2];local depths={};local faces=0
 local function point(p)
  assert(p[1]>=0 and p[1]<=width and p[2]>=0 and p[2]<=32,'wall fixture escaped native bounds')
  assert(p[3]>=26 and p[3]<33,'wall pushed into adjacent furniture')
 end
 local ok=Furniture.draw(id,{sample=function()return{}end,
  box=function(l,b,n,r,h,s)
   assert(r>l and h>b and s>n,'inverted wall component')
   point({l,b,n});point({r,h,s})
  end,
  source=function(x,y,w,h,a,b,c,d)
   assert(x>=0 and y>=0 and x+w<=width and y+h<=32,'floor artwork cropped into wall')
   for _,p in ipairs({a,b,c,d})do point(p);depths[#depths+1]=p[3]end
   faces=faces+1
  end})
 assert(ok~=false and faces>0,'missing native wall treatment')
 if id~='em_home_wallpaper'then
  local near,far=math.huge,-math.huge
  for _,z in ipairs(depths)do near=math.min(near,z);far=math.max(far,z)end
  assert(far-near>=.9,'opening collapsed to a flat picture')
 end
end
print('PASS native wall fixture depth, source crops and footprint bounds')
