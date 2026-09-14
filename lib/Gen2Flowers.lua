-- Small flowers with separate stems, leaves and cupped petals. The native
-- animation program identifies the drawing; no Gen 1 frames are substituted.
local M={}
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
local colors={{.94,.50,.66},{.80,.30,.48},{.97,.94,.81},{.88,.81,.64},
 {.98,.73,.22},{.40,.56,.19},{.24,.42,.12},{.18,.32,.09}}
function M.forTileset(ts)
 if cache[ts]~=nil then return cache[ts] or nil end
 local ground=grounds[ts.id]
 local declared=false
 for _,frame in ipairs(ts.anim and ts.anim.frames or {}) do
  if frame.func=='AnimateFlowerTile' then declared=true end
 end
 if not ground or not declared then cache[ts]=false;return nil end
 local used={[3]=true,[20]=true}
 for _,b in pairs(ts.blocks or {}) do for _,tile in ipairs(b) do used[tile]=true end end
 for _,frame in ipairs(ts.anim.frames) do if frame.tile then used[frame.tile]=true end end
 local capacity=(ts.tilesPerRow or 16)*math.floor((ts.imageHeight or 128)/8)
 for tile=128,capacity-1 do if not used[tile] then
  local p={slot=tile,ground=ground};cache[ts]=p;return p
 end end
 cache[ts]=false
end
function M.color(x,y)
 return unpack(colors[math.floor(y/16)*4+math.floor(x/8)+1])
end
function M.append(out,map,tx,ty)
 local ts=map.tileset
 local profile=M.forTileset(ts)
 if not profile then return false end
 local pr=ts.tilesPerRow or 16
 local aw,ah=ts.imageWidth or 128,ts.imageHeight or 128
 local function uv(color)
  return {(profile.slot%pr*8+((color-1)%4)*2+1)/aw,
   (math.floor(profile.slot/pr)*8+math.floor((color-1)/4)*4+2)/ah}
 end
 local function face(a,b,c,d,color,shade)
  local tex=uv(color)
  out[#out+1]={a,b,c,d,uv={tex,tex,tex,tex},shade=shade or 1}
 end
 local function rand(i)return (math.sin(tx*12.9898+ty*78.233+i*31.7)*43758.5453)%1 end
 -- Two small heads per source tile, staggered in both axes, with clear space
 -- between their leaves. All geometry stays inside the eight-pixel footprint.
 for i=1,2 do
  local x=tx*8+(i==1 and 2 or 5.8)+(rand(i)-.5)*.7
  local z=ty*8+(i==1 and 2.1 or 5.5)+(rand(i+2)-.5)*.8
  local h=3.0+rand(i+4)*2.0
  local lean=(rand(i+6)-.5)*.5
  local top={x+lean,h,z+.15}
  face({x-.12,0,z},{x+.12,0,z},{top[1]+.12,h,z+.15},{top[1]-.12,h,z+.15},8,.92)
  face({x,0,z-.12},{x,0,z+.12},{top[1],h,z+.27},{top[1],h,z+.03},8,.88)
  for side=-1,1,2 do
   local y=h*.42
   face({x,y,z},{x+side*.65,y+.45,z+.35},{x+side*1.35,y+.8,z-.1},
    {x+side*.55,y+.22,z-.36},side==1 and 6 or 7,.97)
  end
  local white=rand(i+10)>.55
  local petal=white and 3 or 1
  local a0=rand(i+12)*math.pi*2
  local radius=.92+rand(i+14)*.24
  for j=0,4 do
   local a=a0+j*math.pi*2/5
   local dx,dz=math.cos(a),math.sin(a)
   local function p(r,w,y)return {top[1]+dx*r-dz*w,h+y,top[3]+dz*r+dx*w} end
   -- A broad six-sided petal: narrow at the pollen disc, flared shoulders,
   -- and a gently cupped rim. Real top depth, not an upright square card.
   local left,right=p(.18,-.12,0),p(.18,.12,0)
   local shoulderL,shoulderR=p(radius*.72,-.39,.17),p(radius*.72,.39,.17)
   local tipL,tipR=p(radius,-.21,.27),p(radius,.21,.27)
   face(left,right,shoulderR,shoulderL,petal,.95)
   face(shoulderL,shoulderR,tipR,tipL,petal,1.03)
  end
  local r=.24
  face({top[1]-r,h+.10,top[3]},{top[1],h+.10,top[3]+r},
   {top[1]+r,h+.10,top[3]},{top[1],h+.10,top[3]-r},5,1)
 end
 return true
end
return M
