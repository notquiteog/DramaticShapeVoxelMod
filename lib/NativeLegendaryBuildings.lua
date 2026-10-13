-- Optional shared Vermilion kit with native warp-owned entrances.
local V=...
local M={}
local function palette()
 local out={}
 for k,c in pairs(V.require('ReferencePalette'))do out[k]=c end
 for k,c in pairs(V.require('ReferenceMaterials').colors)do if not out[k]then out[k]={0,0,c[1],c[2],c[3]}end end
 return out
end
local families={vermilion_shed='bluehouse',vermilion_shed_wide='cottage',vermilion_club='club'}
function M.recipes(def)
 if not(def and def.id=='FR_CELADON_CITY' and V.require('CommunityVisuals').casino:get()=='n64memory')then return{}end
 return{
  {name='celadon_legendary_casino',pair='general__rom_082d4b3c',header=5,back=0,roofEnd=32,wallBottom=79,bevel=0,rows={
   {0x2b0,0x2b1,0x2b1,0x2b1,0x2b1,0x2b1,0x2b2},
   {0x2b8,0x2b3,0x2b3,0x2b9,0x2bb,0x2bb,0x2ba},
   {0x2c0,0x2b3,0x2b4,0x2c1,0x2bc,0x2bb,0x2c2},
   {0x2c8,0x2b7,0x2b5,0x2c9,0x2b6,0x2b7,0x2ca},
   {0x2c3,0x2bf,0x2bd,0x15b,0x2be,0x2bf,0x2c4}}},
  {name='celadon_legendary_prize',pair='general__rom_082d4b3c',header=4,back=0,roofEnd=16,wallBottom=63,bevel=0,rows={
   {0x2b0,0x2b1,0x2b2},{0x2c0,0x2b9,0x2c2},{0x2c8,0x2c7,0x2ca},{0x2c3,0x15b,0x2c4}}}
 }
end
function M.spec(g,def,cells)
 if not def then return end
 local visuals=V.require('CommunityVisuals')
 local casino=def.id=='FR_CELADON_CITY' and visuals.casino:get()=='n64memory' and tostring(g.family):match('^celadon_')
 local style=def.id=='FR_VERMILION_CITY' and visuals.referenceBuildings() and families[g.family]
 if not(style or casino)then return end
 local kind
 local p=V.require('Gen3Civic').profile(g);local back=math.max(p.back,g.bodyBack or 0)
 local doors,warps={},{}
 for _,w in ipairs(def.warps or{})do
  if w.x>=g.cx and w.x<g.cx+g.width and w.y>=g.cy and w.y<g.cy+g.depth then
   doors[#doors+1]={x=(w.x-g.cx)*16+8,w=14,tx=w.x,ty=w.y};warps[w.x..':'..w.y]=true
   local destination=w.map or w.mapId or w.destMap
   if destination=='FR_CELADON_CITY_GAME_CORNER'then kind='arcade'
   elseif destination=='FR_CELADON_CITY_GAME_CORNER_PRIZE_ROOM'then kind='prize_shop' end
  end
 end
 if #doors==0 or #doors>2 or(casino and not kind)then return end
 -- Only a solid rectangular body is supported. Unusual public/custom layouts
 -- keep their original model rather than walling off walkable artwork.
 for y=math.floor(back/16),g.depth-1 do for x=0,g.width-1 do
  local key=(g.cx+x)..':'..(g.cy+y);local c=cells[key]
  if not c or(c.collision~=7 and not warps[key])then return end
 end end
 table.sort(doors,function(a,b)return a.x<b.x end)
 return{x0=3,x1=p.w-3,z0=back+3,z1=p.front-4,doors=doors,style=style,kind=casino and kind or nil,map=casino and 'CELADON_CITY'or'VERMILION_CITY',doorHeight=casino and 22 or 25},p
end
function M.geometry(g,def,cells)
 local spec,p=M.spec(g,def,cells);if not spec then return end
 local colors=palette();local names={};for name in pairs(colors)do names[#names+1]=name end;table.sort(names)
 local slots={};for i,name in ipairs(names)do slots[name]=(i-.5)/#names end
 local vs,ix={},{}
 local source=V.require(spec.kind and 'CityArchitecture' or 'ReferenceBuildings')
 for _,q in ipairs(source.model(spec))do
  local n=#vs;local shade=V.require('ReferenceMaterials').encode(q.referenceMaterial,q.shade or 1)
  for i,point in ipairs(q)do
   local x,y,z=point[1],point[2],point[3]
   if y<24 then x=math.max(0,math.min(p.w,x));z=math.max(spec.z0-3,math.min(p.front,z))end
   vs[#vs+1]={g.cx*16+x,(g.groundHeight or 0)+y,g.cy*16+z,assert(slots[q.referenceMaterial]),.5,type(shade)=='table'and shade[i]or shade}
  end
  for _,i in ipairs{1,2,3,1,3,4}do ix[#ix+1]=n+i end
 end
 return vs,ix,names,spec
end
function M.build(g,def,cells)
 local vs,ix,names,spec=M.geometry(g,def,cells);if not vs then return end
 local d=love.image.newImageData(#names,1);local colors=palette()
 for i,name in ipairs(names)do local c=colors[name];d:setPixel(i-1,0,c[3],c[4],c[5],1)end
 local image=love.graphics.newImage(d);image:setFilter('nearest','nearest');d:release()
 return{mesh=V.require('Voxel3D').newMesh(vs,ix),image=image,placement=g,legendaryBuilding=spec}
end
function M.doorSurface(part,tx,ty)
 local spec=part.legendaryBuilding;if not spec then return end
 local g=part.placement
 for _,d in ipairs(spec.doors)do if d.tx==tx and d.ty==ty then
  local x,z=g.cx*16+d.x,g.cy*16+spec.z1+(spec.kind and 1.05 or .25)
  return{w=16,h=16,sourceX=tx*16,sourceY=ty*16,base=g.groundHeight or 0,
   vertices={{x-7,spec.doorHeight or 25,z},{x+7,spec.doorHeight or 25,z},{x+7,0,z},{x-7,0,z}}}
 end end
end
return M
