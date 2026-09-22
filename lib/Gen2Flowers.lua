-- Flat native flower illustrations; no invented petals or inflated surface.
-- The engine owns their animation; geometry never invents replacement flowers.
local V=...
local M={}
local Mask=V and V.require("SceneryMask") or assert(loadfile("lib/SceneryMask.lua"))()
local grounds={TILESET_JOHTO=5,TILESET_JOHTO_MODERN=5,TILESET_FOREST=5,
 TILESET_PARK=1,TILESET_KANTO=44,TILESET_BATTLE_TOWER_OUTSIDE=5}
local cache=setmetatable({},{__mode='k'})
local bedCache=setmetatable({},{__mode='k'})
-- Exact Park flowerbed metatiles: only their shallow timber rim is raised.
-- A continuous blocked border must not fold the entire flowerbed into walls.
function M.bedAt(map,tx,ty)
 if map.tileset.id~='TILESET_PARK' then return false end
 local x,y=math.floor(tx/4)*4,math.floor(ty/4)*4
 local cells=bedCache[map];if not cells then cells={};bedCache[map]=cells end
 local key=x..':'..y
 if cells[key]==nil then
  cells[key]=false
  for _,id in ipairs({28,29,30,32,33,34,36,37,38,60,61,62}) do
   local b=map.tileset.blocks[id+1]
   if b then
    local match=true
    for v=0,3 do for u=0,3 do
     if map:tileAt(x+u,y+v)~=b[v*4+u+1] then match=false end
    end end
    if match then cells[key]=true;break end
   end
  end
 end
 return cells[key]
end
function M.forTileset(ts)
 if cache[ts]~=nil then return cache[ts] or nil end
 local ground=grounds[ts.id]
 local declared=false
 for _,frame in ipairs(ts.anim and ts.anim.frames or {}) do
  if frame.func=='AnimateFlowerTile' then declared=true end
 end
 if not ground or not declared then cache[ts]=false;return nil end
 local p={ground=ground};cache[ts]=p;return p
end
function M.mask(data,ox,oy)
 return Mask.mask(8,function(x,y)
  local r,g,b,a=data:getPixel(ox+x,oy+y)
  return a==0 or math.min(r,g,b)>.5
 end)
end
-- A full native frame on a flat card keeps every animation silhouette intact.
-- Alpha in the live atlas removes only the background, not pale petal centres.
function M.template(map,data)
 local ts=map.tileset;local pr=ts.tilesPerRow or 16
 local ox,oy=3%pr*8,math.floor(3/pr)*8
 local aw,ah=ts.imageWidth or 128,ts.imageHeight or 128
 return {{{0,8,4},{8,8,4},{8,.001,4},{0,.001,4},
  uv={{ox/aw,oy/ah},{(ox+8)/aw,oy/ah},{(ox+8)/aw,(oy+8)/ah},{ox/aw,(oy+8)/ah}},
  shade=1,canopy={4,4,.001}}}
end
function M.append(out,map,tx,ty,data,template)
 if not M.forTileset(map.tileset) or not data then return false end
 for _,q in ipairs(template or M.template(map,data))do
  local f={uv=q.uv,shade=q.shade,canopy={tx*8+4,ty*8+4,.001}}
  for i=1,4 do f[i]={q[i][1]+tx*8,q[i][2],q[i][3]+ty*8}end
  out[#out+1]=f
 end
 return true
end
return M
