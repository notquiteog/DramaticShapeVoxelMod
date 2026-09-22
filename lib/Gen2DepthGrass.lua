-- One flat, native blade illustration per encounter-grass tile.
local V=...
local M={}
local Mask=V and V.require("SceneryMask") or assert(loadfile("lib/SceneryMask.lua"))()
local donors={TILESET_JOHTO=5,TILESET_JOHTO_MODERN=5,TILESET_FOREST=5,
  TILESET_PARK=1,TILESET_KANTO=44,TILESET_BATTLE_TOWER_OUTSIDE=5}
function M.groundTile(map)
  return donors[map.tileset.id]
end
function M.append(out,map,tx,ty,data,tileId,templates)
  local ts=map.tileset
  if not donors[ts.id] or not data or not tileId then return false end
  local tpl=templates[tileId]
  if not tpl then
    local pr=ts.tilesPerRow or 16
    local ox,oy=tileId%pr*8,math.floor(tileId/pr)*8
    local mask=Mask.mask(8,function(x,y)
      local r,g,b,a=data:getPixel(ox+x,oy+y)
      return a==0 or math.min(r,g,b)>.83
    end)
    tpl={}
    -- Cut the geometry into coplanar source-pixel runs because this same
    -- atlas tile may also be used by unraised decorative floor art.
    for y=0,7 do
      local x=0
      while x<8 do
        if mask[y*8+x] then
          local right=x+1
          while right<8 and mask[y*8+right] do right=right+1 end
          local function uv(px,py)return {(ox+px)/(ts.imageWidth or 128),(oy+py)/(ts.imageHeight or 128)}end
          tpl[#tpl+1]={{x,8-y,4},{right,8-y,4},{right,7-y+.001,4},{x,7-y+.001,4},
            uv={uv(x,y),uv(right,y),uv(right,y+1),uv(x,y+1)},shade=1}
          x=right
        else x=x+1 end
      end
    end
    templates[tileId]=tpl
  end
  for _,q in ipairs(tpl)do
    local f={uv=q.uv,shade=q.shade,canopy={tx*8+4,ty*8+4,.001}}
    for i=1,4 do f[i]={q[i][1]+tx*8,q[i][2],q[i][3]+ty*8}end
    out[#out+1]=f
  end
  return true
end
return M
