-- Render-only materials: source pixels used to recognize silhouettes are never
-- modified. Normalized atlas UVs stay valid when the atlas is enlarged.
local V=...
local M={}
local cache={}
local woodSlots=setmetatable({},{__mode="k"})
function M.woodTile(map)
  local ts=map and map.tileset
  if not (ts and ts.blocks) then return nil end
  if woodSlots[ts]~=nil then return woodSlots[ts] or nil end
  local used={}
  for _,block in pairs(ts.blocks) do for _,tile in ipairs(block) do used[tile]=true end end
  for tile=96,127 do if not used[tile] then woodSlots[ts]=tile;return tile end end
  woodSlots[ts]=false
end
local function noise(x,y,s)
  local n=math.sin(x*127.1+y*311.7+s*74.7)*43758.5453
  return n-math.floor(n)
end
function M.color(kind,x,y,r,g,b,light)
  local grain=noise(x,y,19)-.5
  if kind=="grass" then
    local field=math.sin(x*math.pi/16)*math.cos(y*math.pi/16)*.026
      +math.cos((x+y)*math.pi/8)*.018+grain*.026
    local blade=(noise(math.floor(x/2),math.floor(y/3),7)>.84) and .024 or 0
    return (.37+field+blade)*light,(.56+field+blade)*light,(.24+field*.65)*light
  elseif kind=="path" then
    local speck=noise(x,y,37)>.976 and -.09 or 0
    local v=grain*.035+speck
    return (.69+v)*light,(.65+v)*light,(.51+v)*light
  elseif kind=="wood" then
    local strand=math.sin(x*2.4+math.sin(y*.18)*.6)*.035
    local knot=math.sin(math.sqrt((x-19)^2+(y-15)^2)*1.5)*.016
    local v=strand+knot+grain*.025
    return (.40+v)*light,(.285+v*.8)*light,(.17+v*.55)*light
  elseif kind=="stone" then
    local v=.38+(r+g+b)/3*.25+grain*.065
    return v*.99,v,v*.96
  end
  return r,g,b
end
local function release(e)
  if e then e.image:release();e.data:release() end
end
function M.apply(map,base,source)
  if not V.require("CommunityVisuals").crystalHD(map) or not source then return base,source end
  local old=cache[map.id]
  if old and old.base==base then return old.image,old.data end
  local w,h=source:getDimensions()
  local scale=4
  local data=love.image.newImageData(w*scale,h*scale)
  local attrs=require("src.world.gen2.TileAttrs")
  local johto=map.tileset.id=="TILESET_JOHTO" or map.tileset.id=="TILESET_JOHTO_MODERN"
  local woodTile=M.woodTile(map)
  local pr=map.tileset.tilesPerRow or 16
  for ty=0,h/8-1 do for tx=0,w/8-1 do
    local tile=ty*pr+tx
    local attr=attrs.forTile(map.tileset,tile)
    local kind=tile==woodTile and "wood" or johto and ((tile==5 and "grass") or (tile==6 and "path")
      or ((tile==60 or tile==88) and "stone")) or nil
    local light=0
    for sy=0,7 do for sx=0,7 do
      local r,g,b=source:getPixel(tx*8+sx,ty*8+sy)
      light=light+math.max(r,g,b)
    end end
    light=kind=="wood" and 1 or math.max(.35,math.min(1,light/64/.83))
    for y=0,31 do for x=0,31 do
      local r,g,b,a=source:getPixel(tx*8+math.floor(x/4),ty*8+math.floor(y/4))
      if kind then r,g,b=M.color(kind,x,y,r,g,b,light)
      elseif attr.palette==3 then
        -- Preserve the drawn leaf/flower silhouette while taking fluorescent
        -- yellow out of the grass palette. This includes mixed edge tiles.
        r,g,b=r*.64,g*.76,b*.72
      elseif attr.palette==7 then
        local grain=(noise(x,y,tile)-.5)*.023
        r,g,b=math.max(0,r*.78+grain),math.max(0,g*.78+grain),math.max(0,b*.78+grain)
      end
      data:setPixel(tx*32+x,ty*32+y,r,g,b,a)
    end end
  end end
  local image=love.graphics.newImage(data);image:setFilter("nearest","nearest")
  release(old)
  cache[map.id]={base=base,image=image,data=data}
  return image,data
end
function M.setLive(live)
  for id,e in pairs(cache) do if not live[id] then release(e);cache[id]=nil end end
end
function M.invalidate()
  for _,e in pairs(cache) do release(e) end
  cache={}
end
return M
