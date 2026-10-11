-- Optional shared Vermilion kit with native warp-owned entrances.
local V=...
local M={}
local families={vermilion_shed='bluehouse',vermilion_shed_wide='cottage',vermilion_club='club'}
function M.spec(g,def,cells)
 if not(def and def.id=='FR_VERMILION_CITY'and V.require('CommunityVisuals').referenceBuildings())then return end
 local style=families[g.family]
 if not style then return end
 local p=V.require('Gen3Civic').profile(g);local back=math.max(p.back,g.bodyBack or 0)
 local doors,warps={},{}
 for _,w in ipairs(def.warps or{})do
  if w.x>=g.cx and w.x<g.cx+g.width and w.y>=g.cy and w.y<g.cy+g.depth then
   doors[#doors+1]={x=(w.x-g.cx)*16+8,w=14,tx=w.x,ty=w.y};warps[w.x..':'..w.y]=true
  end
 end
 if #doors==0 or #doors>2 then return end
 -- Only a solid rectangular body is supported. Unusual public/custom layouts
 -- keep their original model rather than walling off walkable artwork.
 for y=math.floor(back/16),g.depth-1 do for x=0,g.width-1 do
  local key=(g.cx+x)..':'..(g.cy+y);local c=cells[key]
  if not c or(c.collision~=7 and not warps[key])then return end
 end end
 table.sort(doors,function(a,b)return a.x<b.x end)
 return{x0=3,x1=p.w-3,z0=back+3,z1=p.front-4,doors=doors,style=style},p
end
function M.geometry(g,def,cells)
 local spec,p=M.spec(g,def,cells);if not spec then return end
 local colors=V.require('ReferencePalette');local names={};for name in pairs(colors)do names[#names+1]=name end;table.sort(names)
 local slots={};for i,name in ipairs(names)do slots[name]=(i-.5)/#names end
 local vs,ix={},{}
 for _,q in ipairs(V.require('ReferenceBuildings').model(spec))do
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
 local d=love.image.newImageData(#names,1);local colors=V.require('ReferencePalette')
 for i,name in ipairs(names)do local c=colors[name];d:setPixel(i-1,0,c[3],c[4],c[5],1)end
 local image=love.graphics.newImage(d);image:setFilter('nearest','nearest');d:release()
 return{mesh=V.require('Voxel3D').newMesh(vs,ix),image=image,placement=g,legendaryBuilding=spec}
end
function M.doorSurface(part,tx,ty)
 local spec=part.legendaryBuilding;if not spec then return end
 local g=part.placement
 for _,d in ipairs(spec.doors)do if d.tx==tx and d.ty==ty then
  local x,z=g.cx*16+d.x,g.cy*16+spec.z1+.25
  return{w=16,h=16,sourceX=tx*16,sourceY=ty*16,base=g.groundHeight or 0,
   vertices={{x-7,25,z},{x+7,25,z},{x+7,0,z},{x-7,0,z}}}
 end end
end
return M
