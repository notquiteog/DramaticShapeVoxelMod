-- Legendary retaining masonry uses the shared Gen1 courses and palettes, inset
-- into the high cell. It cannot extend into the lower native walkable lane.
local V=...
local M={}
local names={'dark','shadow','body','light'}
local function noise(a,b,s)return ((a*73856093+b*19349663+s*83492791)%104729)/104729 end
local function point(d,x,z,a,y,out)
 local inset=.68-out
 if d==5 then return {a,y,z+8-inset}end
 if d==6 then return {a,y,z+inset}end
 if d==1 then return {x+8-inset,y,a}end
 return {x+inset,y,a}
end
function M.new(def)
 -- These raised surfaces are timber docks, not stone retaining architecture.
 if def.id=='FR_SSANNE_EXTERIOR'or def.id=='FR_THREE_ISLAND_PORT'then return end
 if not V.require('Gen3Tilesets').outdoor(def)or not V.require('CommunityVisuals').customWalls()then return end
 return {vertices={},indices={},count=0}
end
function M.append(record,c,d,low,high)
 if not record or c.stageHidden or c.floor and (c.floor.underpass or c.floor.behavior==0x170) or high<=low then return false end
 local opts={noise=noise,point=point,custom=true,dark=1,shadow=2,body=3,light=4}
 opts.emit=function(poly,swatch,shade,tone)
  local first=#record.vertices
  for _,p in ipairs(poly)do record.vertices[#record.vertices+1]={p[1],p[2],p[3],(swatch-.5)/4,.5,shade*tone}end
  for _,i in ipairs{1,2,3,1,3,4}do record.indices[#record.indices+1]=first+i end
 end
 local x,z=c.cx*16,c.cy*16
 local direction=d[1]>0 and 1 or d[1]<0 and 2 or d[2]>0 and 5 or 6
 local G=V.require('RetainingMasonry')
 for offset=0,8,8 do
  local ox=d[1]>0 and 8 or d[1]<0 and 0 or offset
  local oz=d[2]>0 and 8 or d[2]<0 and 0 or offset
  G.build(direction,x+ox,z+oz,low,high,.78,opts)
 end
 record.count=record.count+1;return true
end
function M.finish(record)
 if not record or record.count==0 then return end
 local palette=V.require('MasonryPalette')[V.require('CommunityVisuals').wallColor()]
 local data=love.image.newImageData(4,1)
 for i,name in ipairs(names)do data:setPixel(i-1,0,unpack(palette[name]))end
 record.image=love.graphics.newImage(data);record.image:setFilter('nearest','nearest');data:release()
 record.mesh=V.require('Voxel3D').newMesh(record.vertices,record.indices)
 record.vertices,record.indices=nil,nil
 return record
end
return M
