-- Native Crystal animation programs, sampled at the world's own timer.
-- Immutable atlas frames compose with HD materials; no engine clock writes.
local V=...
local M={}
local cache={}
local function world()
  local ok,g=pcall(require,"src.core.Game")
  return ok and g.world or nil
end
local function release(e)
  local released={}
  for _,image in pairs(e.frames or {}) do
    if not released[image] then image:release();released[image]=true end
  end
end
function M.apply(map,base,pixels)
  local w=world()
  if not (w and w.animLayers and pixels) then return base end
  local layers=w:animLayers(map.tileset)
  if not layers then return base end
  local e=cache[map.id]
  if e and e.base~=base then release(e);e=nil;cache[map.id]=nil end
  if not e then
    local Assets=require("src.render.Assets")
    local Attrs=require("src.world.gen2.TileAttrs")
    local Palettes=require("src.world.gen2.Palettes")
    local Gbc=require("src.render.GbcPalette")
    local Renderer=require("src.render.TileRenderer")
    local bg=Palettes.bgSet(w.palettes,map.def,w.daytime or "DAY")
    local width,height=pixels:getDimensions()
    local pr=map.tileset.tilesPerRow or 16
    local scale=width/(pr*8)
    local hd=V.require("CommunityVisuals").crystalHD(map)
    e={base=base,frames={},layers={}}
    -- Missing imported strips leave only that tile static. Never substitute
    -- another game's flowers, or animate tile $14 on an indoor tileset.
    for tile,layer in pairs(layers) do
      if layer.kind~="scroll" and layer.sheet then
        local ok,data=pcall(Assets.imageData,layer.sheet)
        if ok and data then e.layers[tile]={def=layer,data=data} end
      elseif layer.kind=="scroll" then e.layers[tile]={def=layer} end
    end
    local ok,err=pcall(function()
      local identical={}
      for timer=0,7 do
        local out=love.image.newImageData(width,height)
        out:paste(pixels,0,0,0,0,width,height)
        for tile,rec in pairs(e.layers) do
          local layer=rec.def
          local kind=layer.kind
          local row=timer+1
          if kind=="water" then row=math.floor(timer/2)+1
          elseif kind=="flower" then
            local rows=w.tilesets.flowerCgbFrames or {2,4}
            row=rows[timer%4<2 and 1 or 2]
          elseif kind=="whirlpool" then row=timer%4+1
          elseif kind=="tower" then row=({1,2,3,4,5,4,3,2})[timer+1]
          elseif kind=="lava1" then row=(math.floor(timer/2)+2)%4+1
          elseif kind=="lava2" then row=math.floor(timer/2)+1 end
          local flowerMask
          if kind=="flower" and hd and rec.data then
            flowerMask=V.require("Gen2Flowers").mask(rec.data,0,(row-1)*8)
          end
          local attr=Attrs.forTile(map.tileset,tile)
          local colors=bg and bg[attr.palette]
          local mapped
          if colors then mapped={};for i=1,4 do mapped[i]=Gbc.color(colors,i) end end
          local dx,dy=tile%pr*8*scale,math.floor(tile/pr)*8*scale
          for y=0,8*scale-1 do for x=0,8*scale-1 do
            local r,g,b,a
            if kind=="scroll" then
              local scroll=layer.scroll or {}
              local sx=((scroll.h or 0)>0) and ({0,1,2,3,2,1,0,-1})[timer+1]*scale or 0
              local sy=timer*(scroll.v or 0)*scale
              r,g,b,a=pixels:getPixel(dx+(x-sx)%(8*scale),dy+(y-sy)%(8*scale))
            else
              local px,py=math.floor(x/scale),math.floor(y/scale)
              if attr.xFlip then px=7-px end
              if attr.yFlip then py=7-py end
              r,g,b,a=rec.data:getPixel(px,(row-1)*8+py)
              if mapped then r,g,b,a=Renderer.recolorSample(r,g,b,a,mapped) end
              if hd and kind=="water" then
                -- The native frame's luma breaks up the moving HD ripples.
                local light=.90+(r+g+b)/3*.1
                r,g,b=V.require("Gen2Materials").color("water",(x+(row-1)*scale)%(8*scale),y,r,g,b,light)
              end
              if flowerMask then
                -- Use the same native, flipped source coordinates as the art.
                if not flowerMask[py*8+px] then a=0 end
              end
            end
            out:setPixel(dx+x,dy+y,r,g,b,a)
          end end
        end
        local key=love.data.hash("sha256",out:getString())
        local image=identical[key]
        if not image then
          image=love.graphics.newImage(out);image:setFilter("nearest","nearest")
          identical[key]=image
        end
        out:release();e.frames[timer]=image
      end
    end)
    if not ok then release(e);e.frames={};M.lastError=tostring(err) end
    cache[map.id]=e
  end
  return e.frames[(w.animTimer or 0)%8] or base
end
function M.setLive(live)
  for id,e in pairs(cache) do if not live[id] then release(e);cache[id]=nil end end
end
function M.invalidate()
  for _,e in pairs(cache) do release(e) end
  cache={}
end
return M
