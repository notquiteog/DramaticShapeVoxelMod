-- Physical support from native stair topology and reviewed source surfaces.
-- Native cell elevation is a collision layer, not a uniform height scale.
local V=...
local Levels=V.require('TerrainLevels')
local Pairs=V.require('Gen3Tilesets')
local cache=setmetatable({},{__mode='k'})
local M={}
local blocked={{[0x30]=true,[0x34]=true,[0x36]=true},{[0x31]=true,[0x35]=true,[0x37]=true},
 {[0x33]=true,[0x36]=true,[0x37]=true},{[0x32]=true,[0x34]=true,[0x35]=true}}
local opposite={2,1,4,3}
function M.field(def)
 local l=def and def.midLayout;if not l then return end
 local keys={};for k in pairs(l.overrides or {})do keys[#keys+1]=k end;table.sort(keys)
 local edits={tostring(l.cells)};for _,k in ipairs(keys)do local c=l.overrides[k];edits[#edits+1]=table.concat({k,c.mid or 0,c.coll or 255,c.elev or 0},',')end
 local signature=table.concat(edits,';');local old=cache[l]
 if old and old.signature==signature then return old end
 local behaviors=require('src.core.game3.scripting.interaction_scripts').behaviors[l.pair]or{}
 local spec=Pairs.resolve(l.pair,require('src.import.gba.versions').TILESET_PAIRS)
 local shapes=V.require('Gen3TileShape')
 local drop={[0x38]={1,0},[0x39]={-1,0},[0x3A]={0,-1},[0x3B]={0,1}}
 local outdoor=Pairs.outdoor(def)
 local cave=def.mapType==4
 local deck=def.id=="FR_CERULEAN_CITY_GYM" or def.id=="FR_SSANNE_EXTERIOR" or def.id=="FR_THREE_ISLAND_PORT"
 local f=Levels.build(l.width,l.height,function(x,y)
  local raw=l:cellAt(x,y);local beh=behaviors[raw.mid]
  local shape=shapes.of(spec.primary,spec.secondary,raw.mid,beh,raw.coll)
  local step=shape.kind=='steps';local jump=beh and beh>=0x38 and beh<=0x3F
  return {floor=raw.coll~=7 and not step and not jump,step=step,drop=drop[beh],layer=raw.elev,behavior=beh,
   kind=shape.kind,stairUpper=def.id and def.id:sub(1,3)=='EM_' and beh==0xc,seed=shape.kind~='water' and (deck or (outdoor or cave)and raw.elev==4)and 6 or 0}
 end,function(a,b,d)
  local layer=a.layer==b.layer or a.layer==0 or b.layer==0 or a.layer==15 or b.layer==15
  -- A variable-layer bridge is a deck, not a doorway joining both the
  -- upper path and the ground passing underneath it. Native Hoenn bridge
  -- crossings connect their banks east/west; their side edges stay separate.
  if spec.secondary=='fortree' and (a.layer==15 or b.layer==15) then
   layer=a.layer==b.layer or d<=2
  end
  return layer and (a.kind=='water')==(b.kind=='water') and not blocked[d][a.behavior] and not blocked[opposite[d]][b.behavior]
 end,6,V.require('BuildBudget').tick)
 f.signature=signature
 cache[l]=f;return f
end
function M.cell(def,x,y)
 local f=M.field(def);return f and f.cells[Levels.key(x,y)]
end
function M.at(def,x,z)return Levels.at(M.field(def),x,z)end
function M.bind(cells,regions)
 for _,region in ipairs(regions)do region.floorField=M.field(region.def)end
 Levels.align(regions)
 for _,c in pairs(cells)do
  for _,r in ipairs(regions)do local x,y=c.cx-r.x,c.cy-r.y
   if x>=0 and y>=0 and x<r.w and y<r.h then
    local floor=r.floorField and r.floorField.cells[Levels.key(x,y)]
    c.floor=floor;c.base=(floor and floor.height or 0)+r.floorOffset
    c.floorHigh=floor and floor.high and floor.high+r.floorOffset;break
   end
  end
  if c.base==nil then
   local distance,donor
   for _,r in ipairs(regions)do
    local x=math.max(0,math.min(r.w-1,c.cx-r.x));local y=math.max(0,math.min(r.h-1,c.cy-r.y))
    local d=(c.cx-r.x-x)^2+(c.cy-r.y-y)^2
    if not distance or d<distance then
     local q=r.floorField and r.floorField.cells[Levels.key(x,y)]
     distance,donor=d,(q and q.height or 0)+r.floorOffset
    end
   end
   c.base=donor or 0
  end
 end
 -- Complete assemblies use a single foundation, sampled at their entrance.
 for _,c in pairs(cells)do
  local g=c.column and c.column.group or c.civic or c.prop
  if g then
   if g.groundHeight==nil then
    local x=g.cx or c.cx;local y=g.cy or c.cy
    if g.front then x=math.floor((g.left+g.right)/32);y=math.floor(g.front/16)
    else x=x+math.floor((g.width or (g.w or 16)/16)/2);y=y+(g.depth or (g.d or 16)/16)end
    local below=cells[x..':'..y]or c;g.groundHeight=below.base or 0
   end
   c.base=g.groundHeight
  end
 end
end
function M.lift(vertices,start,height)
 if height==0 then return end
 for i=(start or 0)+1,#vertices do local v=vertices[i];v[2]=v[2]+height
  if v[9]then v[9]=v[9]+height end
 end
end
function M.invalidate()cache=setmetatable({},{__mode='k'})end
return M
