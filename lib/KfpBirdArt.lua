-- Derive the donor's two airborne silhouettes from the active game's art.
-- Own only our copies: native sprite caches must never be released here.
local V=...
local M={}
local cache={}
function M.clear()
 for _,image in pairs(cache)do image:release()end
 cache={}
end
function M.squeeze(src)
 local w,h=src:getDimensions();local out=love.image.newImageData(w,h)
 local nh=math.max(2,math.floor(h*.62));local top=math.floor((h-nh)/2)
 for y=0,nh-1 do for x=0,w-1 do
  out:setPixel(x,top+y,src:getPixel(x,math.min(h-1,math.floor(y/.62))))
 end end
 return out
end
local function source(game,name)
 if V.require('Generation').number()~=3 then
  local path=require('src.pokemon.Sprites').path(game.data,name:upper(),'front',{kind='overworld'})
  assert(path,'native bird art unavailable: '..name)
  return require('src.render.Assets').imageData(path)
 end
 local P=require('src.core.game3.pokemon');local id=P.speciesFromName(name)
 assert(id and id>0,'unknown native species: '..name)
 local entry=assert(P.frontPic(id,0,false,0));local g=love.graphics
 local canvas=g.newCanvas(entry.w,entry.h);local quad
 g.push('all')
 local ok,err=pcall(function()
  g.setCanvas(canvas);g.origin();g.setShader();g.setScissor();g.setDepthMode()
  g.setColor(1,1,1,1);g.setBlendMode('replace','premultiplied');g.clear(0,0,0,0)
  quad=g.newQuad(0,0,entry.w,entry.h,entry.image:getDimensions())
  g.draw(entry.image,quad)
 end)
 g.pop();if quad then quad:release()end
 if not ok then canvas:release();error(err)end
 local data=canvas:newImageData();canvas:release();return data
end
function M.image(game,name,frame)
 assert(game,'native game not ready')
 local key=name..frame;if cache[key]then return cache[key]end
 local src=source(game,name);local data=frame=='b' and M.squeeze(src) or src
 local image=love.graphics.newImage(data);image:setFilter('nearest','nearest')
 if data~=src then data:release()end;src:release();cache[key]=image
 return image
end
return M
