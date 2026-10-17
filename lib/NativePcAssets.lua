-- RS manifest bar paths are already rooted; the native storage loader adds
-- the storage prefix again. Resolve only that missing native asset, within
-- public ensure/image calls, retaining supplied images and native ownership.
local M={}
local function pack(...)return {n=select('#',...),...}end
function M.install(Pc)
 local ok,Assets=pcall(require,'src.render.Assets')
 if not(ok and type(Assets.image)=='function'and type(Pc.ensure)=='function')then return function()end end
 local ensure=Pc.ensure
 local native='data/generated/gba/pokemon/storage/pc_screen_bar.png'
 Pc.ensure=function(...)
  local image=Assets.image
  Assets.image=function(path,...)
   if path=='pokemon/storage/'..native or path=='data/generated/gba/pokemon/storage/'..native then
    local result=pack(pcall(image,path,...))
    if result[1]and result[2]then return unpack(result,2,result.n)end
    return image(native,...)
   end
   return image(path,...)
  end
  local result=pack(pcall(ensure,...));Assets.image=image
  if not result[1]then error(result[2],0)end
  return unpack(result,2,result.n)
 end
 return function()Pc.ensure=ensure end
end
return M
