-- Reviewed native floor drawings. These are physical surfaces, independent
-- of furniture height, palette brightness and collision permissions.
local V=...
local M={}
local Levels=V.require('TerrainLevels')
local fields=setmetatable({},{__mode='k'})
local function source(map,x,y)
 return map:tileAt(x*2,y*2),map:tileAt(x*2+1,y*2),map:tileAt(x*2,y*2+1),map:tileAt(x*2+1,y*2+1)
end
local function family(map)
 local name=map and (map.id or map.def and map.def.id)
 if name=='DANCE_THEATER' then return 'stage' end
 if name=='VIOLET_GYM' or name=='BLACKTHORN_GYM_1F' or name=='BLACKTHORN_GYM_2F' then return 'gym' end
 if name=='GOLDENROD_MAGNET_TRAIN_STATION' or name=='SAFFRON_MAGNET_TRAIN_STATION' then return 'station' end
 if name=='DRAGONS_DEN_B1F' then return 'den' end
 local id=map and map.tileset and map.tileset.id
 if id=='TILESET_CAVE' or id=='TILESET_DARK_CAVE' then return 'cave' end
 if id=='TILESET_JOHTO' or id=='TILESET_JOHTO_MODERN' then return 'mountain' end
 if id=='TILESET_PORT' then return 'pier' end
 if id=='TILESET_ICE_PATH' then return 'ice' end
end
function M.field(map)
 local kind=family(map)
 if not kind or type(map.cellCollision)~='function' then return end
 -- The field is built over the map's full extent, so it needs those
 -- dimensions. A real Map always carries them, but a stub map -- the Gen 2
 -- shape test's fake map, a Gen 1 map reached through a path that did not
 -- gate -- does not, and reading them anyway raised inside
 -- TileShape.at's pcall. That pcall then returned no shape, the generic cell
 -- rules answered instead, and every Gen 2 class silently resolved to
 -- unauthored ground: the exact regression this module's siblings
 -- (Gen2TileShape.supports) already guard against. A map that cannot say how
 -- big it is has no floor field to contribute.
 if type(map.width)~='number' or type(map.height)~='number' then return end
 if fields[map]then return fields[map]end
 local Permissions=require('src.world.gen2.Permissions')
 local f=Levels.build(map.width*2,map.height*2,function(x,y)
  local a,b,c,d=source(map,x,y);local coll=map:cellCollision(x,y)
  local perm=Permissions.of(coll);local walk=perm~=Permissions.WALL and perm~=Permissions.WATER
  local stair=(kind=='cave' and a==54 and b==55 and c==54 and d==55
    or kind=='stage' and a==80 and b==80 and c==95 and d==95)and not map:warpAtCell(x,y)
  local flat=kind=='gym' and (a==0 and b==0 and c==0 and d==0
    or (a==2 or a==56 or a==91 or a==57)and(b==2 or b==56 or b==91 or b==57)and(c==2 or c==56 or c==91)and(d==2 or d==56 or d==91))
    or kind=='station' and a==49 and b==49 and c==49 and d==49
  local edge=kind=='stage' and a==80 and b==80 and c==15 and d==15
    or kind=='gym' and a==19 and b==19 and c==18 and d==18
  local seed=0
  if kind=='cave' and c==22 and d==22 then seed=6 end
  if kind=='mountain' and c==60 and d==60 then seed=6 end
  if kind=='pier' and walk then seed=6 end
  if kind=='ice' and walk and coll~=35 then seed=6 end
  if kind=='stage' and a==80 and b==80 and c==80 and d==80 then seed=6 end
  if kind=='gym' and walk then seed=6 end
  if kind=='station' and walk then seed=6 end
  if kind=='den' and walk then seed=c==60 and d==60 and 12 or 6 end
  -- Deliberately keep upper/lower artwork apart even where a one-way lip
  -- allows travel. Otherwise a flood fill would flatten the shelf again.
  return {floor=not stair and (walk or perm==Permissions.WATER or flat),step=stair,flat=flat,edge=edge,seed=seed,band=seed,
   water=perm==Permissions.WATER,tiles={a,b,c,d}}
 end,function(a,b)return a.band==b.band and a.water==b.water end,6)
 fields[map]=f;return f
end
function M.shape(map,x,y)
 local f=M.field(map);local c=f and f.cells[Levels.key(x,y)]
 if c and c.floor and not c.water and (c.seed or 0)>0 and c.tiles[1]==c.tiles[2] and c.tiles[2]==c.tiles[3] and c.tiles[3]==c.tiles[4] then
  return {class='ground',art='top',h=0,authored=true,derived=true}
 end
 if c and c.flat then return {class='ground',art='top',h=0,authored=true,derived=true}end
 if c and c.step then return {class='stair_n',art='stair',h=6,authored=true,derived=true}end
 if c and c.edge then return {class='ground',art='top',h=0,authored=true,derived=true}end
end
function M.at(map,x,z)return Levels.at(M.field(map),x,z)end
function M.step(map,x,y)
 local f=M.field(map);local c=f and f.cells[Levels.key(x,y)]
 return c and c.step and c or nil
end
-- The cave shelf's repeated side/front drawings are retaining faces, not
-- full-height room walls. Build their shared corners at the two real floors.
function M.buildEdges(S,map)
 local kind=family(map)
 if kind~='cave' and kind~='stage' and kind~='gym' then return end
 local f=M.field(map);local allowed={[1]=true,[6]=true,[7]=true,[21]=true,[22]=true,[23]=true,[37]=true,[38]=true,[39]=true}
 local function key(x,y)return(y+64)*4096+x+64 end
 local function range(x,y)
  local low,high=math.huge,-math.huge
  for dy=-2,2 do for dx=-2,2 do local n=f.cells[Levels.key(x+dx,y+dy)]
   if n and n.floor then low=math.min(low,n.height);high=math.max(high,n.height)end
  end end
  if high==-math.huge then local c=f.cells[Levels.key(x,y)];high=c and c.height or 0;low=high end
  return low,high
 end
 local function height(x,z)
  local cx,cy=math.floor(x/16),math.floor(z/16);local low,high=range(cx,cy)
  local distance,edge=4,high
  for dy=-1,1 do for dx=-1,1 do local n=f.cells[Levels.key(cx+dx,cy+dy)]
   if n and (n.floor or n.step)then
    local d=math.sqrt(math.max(n.x*16-x,0,x-(n.x+1)*16)^2+math.max(n.y*16-z,0,z-(n.y+1)*16)^2)
    local h=n.high and n.high-(n.high-n.low)*math.max(0,math.min(1,(z-n.y*16)/16))or n.height
    if d<distance then distance,edge=d,h elseif d==distance then edge=math.max(edge,h)end
   end
  end end
  return edge+(high-edge)*math.min(1,distance/4)
 end
 local aw,ah=map.tileset.imageWidth or 128,map.tileset.imageHeight or 128
 local cols=map.tileset.tilesPerRow or 16
 for _,c in pairs(f.cells)do if not c.floor and not c.step then
  local compatible=kind=="cave";for _,tile in ipairs(c.tiles)do compatible=compatible and allowed[tile]end
  compatible=compatible or c.edge
  local low,high=range(c.x,c.y)
  if compatible and high>low and high>0 then
   for ty=c.y*2,c.y*2+1 do for tx=c.x*2,c.x*2+1 do local k=key(tx,ty)
    if S.shapeAt[k] and not S.skip[k]then
     S.skip[k]=true;S.ground[k]=false
     local tile=S.tileAt[k];local u,v=(tile%cols)*8,math.floor(tile/cols)*8
     for dz=0,4,4 do for dx=0,4,4 do
      local x,z=tx*8+dx,ty*8+dz
      local q={{x,height(x,z),z},{x+4,height(x+4,z),z},{x+4,height(x+4,z+4),z+4},{x,height(x,z+4),z+4},
       shade=.88,terrainAbsolute=true,uv={{(u+dx+.02)/aw,(v+dz+.02)/ah},{(u+dx+3.98)/aw,(v+dz+.02)/ah},{(u+dx+3.98)/aw,(v+dz+3.98)/ah},{(u+dx+.02)/aw,(v+dz+3.98)/ah}}}
      S.objectQuads[#S.objectQuads+1]=q
     end end
    end
   end end
  end
 end end
end
function M.invalidate()fields=setmetatable({},{__mode='k'})end
return M
