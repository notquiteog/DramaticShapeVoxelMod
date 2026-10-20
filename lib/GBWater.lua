-- HGSS Pallet's 16px walking grid has land Y16 and water Y8. Apply that
-- reviewed eight-pixel bank only to native outdoor water formerly at -2.
-- Source collision, tile data, authored pools/bridges and elevation are read-only.
local V=...;local M={BANK_DEPTH=8}
local copies=setmetatable({},{__mode='k'})
local directions={{-1,0},{1,0},{0,-1},{0,1}}
local planes=setmetatable({},{__mode='k'})
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
function M.outdoor(map)
 local d=map and map.def;if not d then return false end
 if d.outdoor~=nil then return d.outdoor==true end
 return d.tileset=='OVERWORLD'or d.environment=='TOWN'or d.environment=='ROUTE'
  or(map.tileset and map.tileset.id=='TILESET_FOREST')or false
end
-- Cache the policy itself, not only its answer for the ordinary -2 class:
-- default preserves an authored -20 pool whereas explicit waterline=-8 moves it.
function M.policyKey(map)
 local config=map and map.def and map.def.voxelWater
 local state=type(config)..':'..tostring(config)
 if type(config)=='table'then
  state='table:preserve='..tostring(not not config.preserveWaterLevel)
   ..':waterline='..(finite(config.waterline)and string.format('%.17g',config.waterline)or '-')
   ..':bankDepth='..(finite(config.bankDepth)and string.format('%.17g',config.bankDepth)or '-')
 end
 return 'gb-water-bank-2:outdoor='..tostring(M.outdoor(map))..':'..state
end
function M.relative(map,height,shape)
 if not finite(height)then return height end
 local config=map and map.def and map.def.voxelWater
 if config==false or shape and shape.preserveWaterLevel then return height end
 config=type(config)=='table'and config or{}
 if config.preserveWaterLevel then return height end
 -- Explicit extension waterlines take precedence, including indoor pools.
 if shape and finite(shape.waterline)then return shape.waterline end
 if finite(config.waterline)then return config.waterline end
 local depth=shape and shape.bankDepth or config.bankDepth
 if finite(depth)then return depth>0 and math.min(height,-depth)or height end
 -- Do not flatten a source-authored recessed pond or raised fountain.
 if height~=-2 or not M.outdoor(map)then return height end
 return -M.BANK_DEPTH
end
function M.shape(map,shape)
 if not(shape and shape.class=='water')then return shape end
 local h=M.relative(map,shape.h,shape);if h==shape.h then return shape end
 local variants=copies[shape];if not variants then variants={};copies[shape]=variants end
 if not variants[h]then local out={};for k,v in pairs(shape)do out[k]=v end;out.h=h;variants[h]=out end
 return variants[h]
end
function M.base(map,x,z)
 return type(map.cellCollision)=='function'and V.require('Gen2Elevation').at(map,x,z)or 0
end
function M.surfaceAt(map,x,z)
 if not(map and type(map.isWaterCell)=='function'and type(map.tileAt)=='function')then return end
 local cx,cy=math.floor(x/16),math.floor(z/16)
 if not map:isWaterCell(cx,cy)then return end
 local T=V.require('TileShape');local shapes=T.forMap(map);local tx,ty=cx*2,cy*2+1
 local shape=T.at(map,shapes,map:tileAt(tx,ty),tx,ty)
 -- Native water permission alone cannot sink a reviewed bridge or deck.
 if shape and shape.class=='water'then return M.base(map,x,z)+shape.h end
end
function M.plane(map)
 local T=V.require('TileShape');local fallback=M.relative(map,(T.heights()or{}).water or -2)
 local policy=M.policyKey(map)..':fallback='..tostring(fallback)
 local old=planes[map];if old and old.policy==policy then return old.height end
 local counts,best,height={},0,fallback
 if map and map.def and map.def.width and map.def.height then
  for y=0,map.def.height*2-1 do for x=0,map.def.width*2-1 do
   local h=M.surfaceAt(map,x*16+8,y*16+8)
   if h then counts[h]=(counts[h]or 0)+1;if counts[h]>best then best,height=counts[h],h end end
  end end
 end
 if map then planes[map]={policy=policy,height=height} end
 return height
end
-- Bank sidecars cover only the below-floor strip on a native land/water edge.
-- Existing terrain also closes the edge, so failed texture/GPU upload keeps a
-- closed native-art fallback. The 0.002px inset lies wholly over water and
-- prevents a coplanar fight without expanding any walkable object footprint.
function M.invalidate(id)
 for map in pairs(planes)do if not id or map.id==id then planes[map]=nil end end
end
function M.bankGeometry(map)
 if not M.outdoor(map)or M.relative(map,-2)==-2 or not(map.def and map.def.width and map.def.height)then return{},{}end
 local T=V.require('TileShape');local shapes=T.forMap(map)
 local B=V.require('BankMaterials');local uv=B.uv('kanto');if not uv then return{},{}end
 local vertices,indices={},{};local w,h=map.def.width*4,map.def.height*4
 local resolved={}
 local function shape(x,y)
  local k=y*w+x+1;local s=resolved[k]
  if s==nil then s=T.at(map,shapes,map:tileAt(x,y),x,y)or false;resolved[k]=s end
  return s or nil
 end
 local function wet(x,y)
  if x<0 or y<0 or x>=w or y>=h then return end
  local s=shape(x,y);if s and s.class=='water'then return M.base(map,x*8+4,y*8+4)+s.h end
 end
 for y=0,h-1 do for x=0,w-1 do
  local s=shape(x,y)
  -- Wall/tree trunks retain their above-ground art; only their soil foot is
  -- extended. Steps, wood decks, voids and authored shore meshes own theirs.
  local tile=map:tileAt(x,y)
  if s and s.class~='water'and s.class~='void'and s.art~='stair'
   and not(s.bridge or s.bankMaterial==false or s.preserveWaterLevel)
   and not(map.def.tileset=='OVERWORLD'and tile==60)then
   local top=M.base(map,x*8+4,y*8+4)
   for _,d in ipairs(directions)do
    local bottom=wet(x+d[1],y+d[2])
    if bottom and bottom<top-.001 then
     local x0,z0=x*8,y*8;local p
     if d[1]<0 then local a=x0-.002;p={{a,bottom,z0},{a,bottom,z0+8},{a,top,z0+8},{a,top,z0}}
     elseif d[1]>0 then local a=x0+8+.002;p={{a,bottom,z0+8},{a,bottom,z0},{a,top,z0},{a,top,z0+8}}
     elseif d[2]<0 then local a=z0-.002;p={{x0+8,bottom,a},{x0,bottom,a},{x0,top,a},{x0+8,top,a}}
     else local a=z0+8+.002;p={{x0,bottom,a},{x0+8,bottom,a},{x0+8,top,a},{x0,top,a}}end
     local n=#vertices
     for i,v in ipairs(p)do vertices[#vertices+1]={v[1],v[2],v[3],uv[i][1],uv[i][2],.8}end
     for _,i in ipairs{1,2,3,1,3,4}do indices[#indices+1]=n+i end
    end
   end
  end
 end end
 return vertices,indices
end
return M
