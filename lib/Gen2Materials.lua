-- Render-only materials: source pixels used to recognize silhouettes are never
-- modified. Normalized atlas UVs stay valid when the atlas is enlarged.
local V=...
local M={}
local cache={}
local floorKinds={
  TILESET_JOHTO={[5]="grass",[6]="path",[20]="water",[47]="paving",[60]="stone",[88]="stone"},
  TILESET_JOHTO_MODERN={[5]="grass",[6]="path",[20]="water",[47]="paving",[60]="stone",[88]="stone"},
  TILESET_FOREST={[5]="grass",[20]="water"},
  TILESET_PARK={[1]="grass"},
  TILESET_KANTO={[44]="grass",[20]="water",[42]="stone",[43]="stone",[58]="stone",[59]="stone"},
  TILESET_BATTLE_TOWER_OUTSIDE={[5]="grass",[6]="path"},
  TILESET_HOUSE={[1]="floor"},TILESET_PLAYERS_HOUSE={[1]="floor"},
  TILESET_LAB={[16]="floor"},TILESET_MART={[72]="floor"},
  TILESET_POKECENTER={[17]="floor"},
  TILESET_DARK_CAVE={[1]="caveFloor",[22]="caveFloor",[16]="caveRock",[20]="water"},
}
local woodSlots=setmetatable({},{__mode="k"})
local labWood={[3]=true,[4]=true,[5]=true,[6]=true,[7]=true,
  [19]=true,[20]=true,[21]=true,[22]=true,[23]=true,[37]=true,[38]=true,[39]=true}
function M.roofTile(id)
  if id=="TILESET_JOHTO" or id=="TILESET_JOHTO_MODERN" then return 14 end
  if id=="TILESET_KANTO" then return 5 end
end
function M.architectureKind(id,tile)
  if id=="TILESET_JOHTO" or id=="TILESET_JOHTO_MODERN" then
    if tile>=13 and tile<=18 then return "roof" end
    if tile==27 then return "plaster" end
    if tile==7 then return "brick" end
    if tile==2 then return "wallBase" end
    if tile==38 then return "window" end
    if tile==1 or tile==22 or tile==26 or tile==28 or (tile>=55 and tile<=58) then
      return "timberTrim"
    end
  elseif id=="TILESET_KANTO" and tile==5 then return "roof"
  elseif id=="TILESET_LAB" and labWood[tile] then return "furnitureWood" end
end
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
local function meadow(x,y)
  -- Periodic value noise gives irregular patches without diagonal waves or
  -- seams between repeated tiles. Fine grain stays below the broad variation.
  local gx,gy=x/8,y/8
  local ix,iy=math.floor(gx),math.floor(gy)
  local u,v=gx-ix,gy-iy
  u=u*u*(3-2*u);v=v*v*(3-2*v)
  local function n(dx,dy)return noise((ix+dx)%4,(iy+dy)%4,53) end
  return (n(0,0)*(1-u)+n(1,0)*u)*(1-v)+(n(0,1)*(1-u)+n(1,1)*u)*v
end
function M.color(kind,x,y,r,g,b,light,depth)
  local grain=noise(x,y,19)-.5
  if kind=="grass" or kind=="path" or kind=="water" or kind=="stone"
    or kind=="caveFloor" or kind=="caveRock" or kind=="paving" then
    -- Keep native palette, markings and light/dark relationships. Fine grain
    -- adds surface detail without repainting routes, water or cave geology.
    local tone=1+grain*.035
    return math.min(1,r*tone),math.min(1,g*tone),math.min(1,b*tone)
  elseif kind=="floor" then
    local grout=(x==0 or y==0) and .86 or 1
    local tone=(r+g+b)/3
    local v=grain*.012
    return (r*.35+tone*.65+v)*grout,(g*.35+tone*.65+v)*grout,(b*.35+tone*.65+v)*grout
  elseif kind=="wood" then
    local strand=math.sin(x*2.4+math.sin(y*.18)*.6)*.035
    local knot=math.sin(math.sqrt((x-19)^2+(y-15)^2)*1.5)*.016
    local v=strand+knot+grain*.025
    return (.40+v)*light,(.285+v*.8)*light,(.17+v*.55)*light
  elseif kind=="paving" or kind=="brick" then
    local row=math.floor(y/8)
    local stagger=(x+(row%2)*8)%16
    local mortar=y%8==0 or stagger==0
    if mortar then return .45,.43,.38 end
    local variation=(noise(math.floor((x+(row%2)*8)/16),row,71)-.5)*.06+grain*.025
    if kind=="paving" then
      return (.62+variation)*light,(.51+variation)*light,(.44+variation)*light
    end
    local gray=(r+g+b)/3
    return (r*.78+gray*.22)+variation,(g*.78+gray*.22)+variation,(b*.78+gray*.22)+variation
  elseif kind=="roof" then
    local row=math.floor(y/8)
    local joint=(x+(row%2)*4)%8
    local variation=(noise(math.floor((x+(row%2)*4)/8),row,3)-.5)*.045
    local tone=.94+variation
    if y%8==7 then tone=tone-.12
    elseif joint==0 then tone=tone-.07
    elseif y%8==0 then tone=tone+.025 end
    local gray=(r+g+b)/3
    -- Small, defined tile joints and restrained highlights; no sinusoidal
    -- rolls, horizontal dark waves or noisy all-over mineral texture.
    return (r*.78+gray*.22)*tone,(g*.78+gray*.22)*tone,(b*.78+gray*.22)*tone
  elseif kind=="plaster" then
    local v=grain*.024
    return .76+v,.73+v,.64+v
  elseif kind=="wallBase" then
    if y<12 then return M.color("plaster",x,y,r,g,b,light) end
    local v=(y==12 or y==27) and -.06 or grain*.016
    return .34+v,.29+v,.21+v
  elseif kind=="window" then
    local edge=math.min(x,y,31-x,31-y)
    if edge<3 then return .18,.16,.12 end
    if edge<5 or (x>=14 and x<=17) then return .43,.33,.22 end
    local glow=(1-y/31)*.08
    local reflection=(x+y)%27<3 and .09 or 0
    return .30+glow+reflection,.46+glow+reflection,.49+glow+reflection
  elseif kind=="timberTrim" then
    if r>b*1.25 and g>b*1.15 then
      local v=math.sin(x*1.1+math.sin(y*.3))*.02+grain*.012
      return .39+v,.29+v,.18+v
    end
  elseif kind=="furnitureWood" then
    -- Recolour only the wood's ochre fill. Books, machine components and
    -- the source trim remain readable and retain their original outlines.
    if r>b*1.25 and g>b*1.15 then
      local v=math.sin(y*.6+math.sin(x*.18))*.018+grain*.012
      return .42+v,.30+v*.8,.19+v*.5
    end
  end
  return r,g,b
end
local function release(e)
  if e then e.image:release();e.data:release() end
end
function M.apply(map,base,source)
  if not V.require("CommunityVisuals").crystalHD(map) or not source then return base,source end
  local depth=V.require("CommunityVisuals").crystalDepth(map)
  local old=cache[map.id]
  if old and old.base==base and old.depth==depth then return old.image,old.data end
  local w,h=source:getDimensions()
  local scale=4
  local data=love.image.newImageData(w*scale,h*scale)
  local attrs=require("src.world.gen2.TileAttrs")
  local kinds=floorKinds[map.tileset.id] or {}
  local woodTile=M.woodTile(map)
  local floorModule=depth and V.require("Gen2FloorFinish")
  local floorFinish=floorModule and floorModule.forTileset(map.tileset)
  local flowers=V.require("Gen2Flowers")
  local flowerMaterial=flowers.forTileset(map.tileset)
  local flowerMask
  if flowerMaterial then
    local raw=require('src.render.Assets').imageData(map.tileset.image)
    flowerMask=flowers.mask(raw,3%(map.tileset.tilesPerRow or 16)*8,math.floor(3/(map.tileset.tilesPerRow or 16))*8)
  end
  local shore=depth and V.require("Gen2Shoreline")
  local shoreMaterial=shore and shore.forTileset(map.tileset)
  local sandLight=1
  local sandR,sandG,sandB=0,0,0
  if shoreMaterial then
    local tile=shoreMaterial.tile;local n=0
    local pr=map.tileset.tilesPerRow or 16
    for y=0,7 do for x=0,7 do
      local r,g,b=source:getPixel(tile%pr*8+x,math.floor(tile/pr)*8+y)
      n=n+math.max(r,g,b);sandR,sandG,sandB=sandR+r,sandG+g,sandB+b
    end end
    sandLight=math.max(.35,math.min(1,n/64/.83))
    sandR,sandG,sandB=sandR/64,sandG/64,sandB/64
  end
  local pr=map.tileset.tilesPerRow or 16
  -- All roof drawings share one glaze. Sampling only the light ceramic
  -- pixels avoids baking the old black ridge/eave stripes into the new
  -- sloping surface; geometry now supplies those edges and their shadows.
  local roofR,roofG,roofB,roofN=0,0,0,0
  local roofTile=M.roofTile(map.tileset.id)
  if roofTile then
    local first,last=roofTile==14 and 13 or 5,roofTile==14 and 18 or 9
    for tile=first,last do for sy=0,7 do for sx=0,7 do
      local r,g,b=source:getPixel(tile%pr*8+sx,math.floor(tile/pr)*8+sy)
      if math.max(r,g,b)>.20 then
        roofR,roofG,roofB,roofN=roofR+r,roofG+g,roofB+b,roofN+1
      end
    end end end
    if roofN>0 then roofR,roofG,roofB=roofR/roofN,roofG/roofN,roofB/roofN end
  end
  for ty=0,h/8-1 do for tx=0,w/8-1 do
    local tile=ty*pr+tx
    local attr=attrs.forTile(map.tileset,tile)
    local kind=tile==woodTile and "wood" or kinds[tile]
    local architecture=M.architectureKind(map.tileset.id,tile)
    local light,ar,ag,ab=0,0,0,0
    for sy=0,7 do for sx=0,7 do
      local r,g,b=source:getPixel(tx*8+sx,ty*8+sy)
      light=light+math.max(r,g,b);ar,ag,ab=ar+r,ag+g,ab+b
    end end
    light=kind=="wood" and 1 or math.max(.35,math.min(1,light/64/.83))
    for y=0,31 do for x=0,31 do
      local r,g,b,a=source:getPixel(tx*8+math.floor(x/4),ty*8+math.floor(y/4))
      if shoreMaterial and tile==shoreMaterial.slot then
        r,g,b=M.color("path",x,0,sandR,sandG,sandB,sandLight,true)
        r,g,b=shore.color(x,y,r,g,b);a=1
      elseif flowerMask and tile==3 then
        if not flowerMask[math.floor(y/4)*8+math.floor(x/4)] then a=0 end
      elseif floorFinish and floorFinish.quadrants[tile]~=nil then
        r,g,b=floorModule.color(floorFinish,floorFinish.quadrants[tile],x,y)
        a=1
      elseif kind=="floor" then r,g,b=M.color(kind,x,y,ar/64,ag/64,ab/64,light)
      elseif kind then r,g,b=M.color(kind,x,y,r,g,b,light,depth)
      elseif architecture=="roof" then
        r,g,b=M.color("roof",x,y,roofR,roofG,roofB,1)
      elseif architecture then r,g,b=M.color(architecture,x,y,architecture=="brick" and ar/64 or r,architecture=="brick" and ag/64 or g,architecture=="brick" and ab/64 or b,1)

      end
      data:setPixel(tx*32+x,ty*32+y,r,g,b,a)
    end end
  end end
  local image=love.graphics.newImage(data);image:setFilter("nearest","nearest")
  release(old)
  cache[map.id]={base=base,image=image,data=data,depth=depth}
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
