-- A shallow wet-sand slope follows the actual beach/water boundary. Stable
-- world-coordinate curves join neighbouring tiles; collision stays native.
local V=...
local M={}
local cache=setmetatable({},{__mode='k'})
local beaches={TILESET_JOHTO=6,TILESET_JOHTO_MODERN=6,TILESET_BATTLE_TOWER_OUTSIDE=6}
local function key(x,y)return (y+64)*4096+x+64 end
function M.forTileset(ts)
 if cache[ts]~=nil then return cache[ts] or nil end
 local tile=beaches[ts.id]
 if not tile then cache[ts]=false;return nil end
 local used={[3]=true,[20]=true}
 for _,b in pairs(ts.blocks or {}) do for _,t in ipairs(b) do used[t]=true end end
 for _,f in ipairs(ts.anim and ts.anim.frames or {}) do if f.tile then used[f.tile]=true end end
 local flower=V.require('Gen2Flowers').forTileset(ts)
 if flower and flower.slot then used[flower.slot]=true end
 local capacity=(ts.tilesPerRow or 16)*math.floor((ts.imageHeight or 128)/8)
 for t=128,capacity-1 do if not used[t] then
  local p={tile=tile,slot=t};cache[ts]=p;return p
 end end
 cache[ts]=false
end
function M.color(x,y,r,g,b)
 local wet=(y/31)^1.4
 return r*(1-wet*.36),g*(1-wet*.29),b*(1-wet*.18)
end
local function width(x,z)
 return 1.1+.35*math.sin(x*.35+z*.29)+.18*math.sin(x*.77-z*.53)
end
function M.patch(tx,ty,edges,waterHeight,uv)
 local out={}
 local function point(u,v)
  local x,z=tx*8+u,ty*8+v
  local d=8
  if edges.w then d=math.min(d,u) end
  if edges.e then d=math.min(d,8-u) end
  if edges.n then d=math.min(d,v) end
  if edges.s then d=math.min(d,8-v) end
  local wet=math.max(0,1-d/3)
  if edges.w and u<3 then x=x-width(tx*8,z)*(1-u/3)^2 end
  if edges.e and u>5 then x=x+width(tx*8+8,z)*((u-5)/3)^2 end
  if edges.n and v<3 then z=z-width(tx*8+u,ty*8)*(1-v/3)^2 end
  if edges.s and v>5 then z=z+width(tx*8+u,ty*8+8)*((v-5)/3)^2 end
  return {x,(waterHeight+.02)*wet*wet,z},uv(u,v,wet)
 end
 for v=0,7 do for u=0,7 do
  local a,ua=point(u,v);local b,ub=point(u+1,v)
  local c,uc=point(u+1,v+1);local d,ud=point(u,v+1)
  out[#out+1]={a,b,c,d,uv={ua,ub,uc,ud},shade=1,shore=true}
 end end
 return out
end
function M.build(S,map)
 if not V.require('CommunityVisuals').crystalDepth(map) then return end
 local ts=map.tileset
 local profile=M.forTileset(ts)
 if not profile then return end
 local function wet(tx,ty)
  local k=key(tx,ty);local s=S.shapeAt[k]
  if S.skip[k] then return S.waterGround and S.waterGround[k] or false end
  return s and s.class=='water'
 end
 local pr=ts.tilesPerRow or 16
 local aw,ah=ts.imageWidth or 128,ts.imageHeight or 128
 local function uv(u,v,w)
  -- A quad must never interpolate between two atlas slots. Its dry edge
  -- uses the dry row of the same wet-sand swatch as the entire slope.
  local tile=profile.slot
  local px=math.min(7.875,u)
  local py=.125+w*7.75
  return {(tile%pr*8+px)/aw,(math.floor(tile/pr)*8+py)/ah}
 end
 S.shore={}
 for ty=0,map.def.height*4-1 do for tx=0,map.def.width*4-1 do
  local k=key(tx,ty);local s=S.shapeAt[k]
  local tile=S.skip[k] and S.ground[k] or S.tileAt[k]
  if s and tile==profile.tile and not (S.waterGround and S.waterGround[k])
   and (S.skip[k] or s.class=='ground') then
   local edges={w=wet(tx-1,ty),e=wet(tx+1,ty),n=wet(tx,ty-1),s=wet(tx,ty+1)}
   if edges.w or edges.e or edges.n or edges.s then
    S.shore[k],S.skip[k],S.ground[k]=true,true,profile.tile
    for _,q in ipairs(M.patch(tx,ty,edges,S.gen2WaterHeight or -2,uv)) do
     S.objectQuads[#S.objectQuads+1]=q
    end
   end
  end
 end end
end
return M
