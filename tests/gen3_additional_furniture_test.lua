-- Source-design regression. Gameplay and GPU appearance require a later run.
local Furniture=dofile('lib/Gen3Furniture.lua')
local added=dofile('lib/Gen3AdditionalFurniture.lua')
local profiles=dofile('lib/Gen3AdditionalInteriors.lua')
local function cellsFor(r)
 local cells={}
 for dy,row in ipairs(r.rows)do for dx,mid in ipairs(row)do
  local x,y=dx+3,dy+5
  cells[x..':'..y]={cx=x,cy=y,mid=mid,primary='building',pair=r.pair,
   secondary=r.pair:match('building__(.+)'),ts={}}
 end end
 return cells
end
local count=0
for _,r in ipairs(added)do
 local cells=cellsFor(r);local props=Furniture.extract(cells)
 assert(#props==1 and props[1].recipe.name==r.name,'whole drawing not claimed once: '..r.name)
 for _,c in pairs(cells)do assert(c.prop==props[1],'drawing fragment left on floor') end
 local quads=0
 Furniture.append(props[1],function(vertices,uv)
  quads=quads+1
  for i,v in ipairs(vertices)do
   for _,n in ipairs(v)do assert(n==n and math.abs(n)<1000,'invalid mesh coordinate')end
   assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1,'atlas sample outside native tile')
  end
 end,function()return {{0,0},{1,0},{1,1},{0,1}}end)
 assert(quads>0,'empty furniture model')
 cells=cellsFor(r);cells['4:6'].mid=0
 assert(#Furniture.extract(cells)==0,'incomplete object claimed unrelated cell')
 cells=cellsFor(r);cells['4:7'].pair='other'
 assert(#Furniture.extract(cells)==0,'object crossed a native tileset boundary')
 if r.kind=='plant' then
  local cutouts=Furniture.cutouts(r.pair)
  for _,row in ipairs(r.rows)do for _,mid in ipairs(row)do assert(cutouts[mid]==r.ground)end end
 else
  assert(r.facade[2]>0 and r.facade[2]+r.facade[4]<#r.rows*16,
   'cabinet facade contains the wall above or floor below its native drawing')
 end
 count=count+1
end
assert(profiles.rom_082d4c2c.surfaces[0x109] and profiles.rom_082d4c2c.surfaces[0x111],
 'museum wooden floor inherited generic room wall')
for _,p in pairs(profiles)do for mid in pairs(p.surfaces)do assert(not p.walls[mid],'floor is also wall')end end
assert(not profiles.rom_082d4f2c.walls[0x314],'Mansion statue treated as room shell')
print('PASS '..count..' complete interior drawings, partial/pair isolation, native UVs and explicit floor exemptions')
