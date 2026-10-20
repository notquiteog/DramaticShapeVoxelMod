-- Original HGSS/ORAS earthen bank artwork on exact native shoreline faces.
-- Only UV windows change: all bundled PNG bytes are identical to their source.
-- See assets/scenery/shore-banks/provenance.json for source IDs and credits.
local V=...
local M={}
local definitions={
 kanto={path='assets/scenery/shore-banks/hgss-pond-line.png',width=16,height=16,rect={.5,2.5,15.5,13.5}},
 hoennRiver={path='assets/scenery/shore-banks/oras-river-bank.png',width=128,height=256,rect={.5,24.5,127.5,43.5}},
 hoennSea={path='assets/scenery/shore-banks/oras-sea-bank.png',width=128,height=128,rect={.5,25.5,127.5,49.5}},
}
local images,retired={},{}
local sea={OCEAN_WATER=true,DEEP_WATER=true,SOOTOPOLIS_DEEP_WATER=true,SEAWEED=true,
 SEAWEED_NO_SURFACING=true,NO_SURFACING=true,UNDERWATER_BLOCKED_ABOVE=true}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
function M.key(region,edge)
 local shape=edge and edge.land and edge.land.shape
 local authored=shape and shape.bankMaterial
 if authored and definitions[authored]then return authored end
 if definitions[region]then return region end
 if region=='hoenn'then
  local water=edge and edge.water;local name
  if water then
   local ok,MB=pcall(require,'src.core.game3.mb')
   name=ok and MB.nameOf(water.behavior)or nil
  end
  -- A river mouth shares the deeper coastal sheet with its connected sea.
  -- Adapters can supply the exact planned depth; the drawn relative level is
  -- a safe equivalent for ordinary water cells when that field is omitted.
  local depth=edge and edge.bankDepth or water and water.waterBankDepth
  if not depth and water and finite(water.waterSurface)then depth=(water.base or 0)-water.waterSurface end
  local coast=finite(depth)and depth>=4-.001
  return(sea[name]or coast or water and water.shape and(water.shape.seaRock or water.shape.wetRock))and'hoennSea'or'hoennRiver'
 end
end
-- Third-party scenery may register its own reviewed texture/UV window without
-- replacing terrain, collision or another mod. The path belongs to this mod's
-- public reader; no private filesystem or mandatory provider is introduced.
function M.register(key,d)
 if type(key)~='string'or type(d)~='table'or type(d.path)~='string'
  or not(finite(d.width)and d.width>0 and finite(d.height)and d.height>0)or type(d.rect)~='table'then return false end
 local r=d.rect
 for i=1,4 do if not finite(r[i])then return false end end
 if r[1]<0 or r[2]<0 or r[3]<=r[1]or r[4]<=r[2]or r[3]>d.width or r[4]>d.height then return false end
 -- An already-built mixed scene can still own the previous texture. Retire
 -- it until the renderer releases all scenes rather than invalidating a mesh.
 if images[key]then retired[#retired+1]=images[key];images[key]=nil end
 definitions[key]={path=d.path,width=d.width,height=d.height,rect={r[1],r[2],r[3],r[4]}}
 return true
end
function M.uv(region,edge)
 local key=M.key(region,edge);local d=definitions[key];if not d then return end
 local r=d.rect;local u0,u1,v0,v1=r[1]/d.width,r[3]/d.width,r[2]/d.height,r[4]/d.height
 local land=edge and edge.land and edge.land.shape
 -- Native bare cliff/cave retaining faces have no lawn at their feet. The
 -- original sea atlas also supplies opaque stone below its grass-rim rows;
 -- continue that stone down to water rather than inventing a lower green lip.
 if key=='hoennSea'and land and(land.kind=='cliff'or land.kind=='caveWall')then v0=36.5/d.height end
 -- ShoreBanks vertex order: bottom-left, bottom-right, top-right, top-left.
 return{{u0,v1},{u1,v1},{u1,v0},{u0,v0}}
end
function M.image(region,edge)
 local key=M.key(region,edge);local d=definitions[key];if not d then return end
 if images[key]then return images[key]end
 if not(V and V.mod and V.mod.read and love and love.filesystem and love.graphics)then return end
 local file,created
 local ok,value=pcall(function()
  file=love.filesystem.newFileData(assert(V.mod:read(d.path)),d.path)
  created=love.graphics.newImage(file);created:setFilter('nearest','nearest');created:setWrap('clamp','clamp')
  return created
 end)
 if file and file.release then file:release()end
 if not ok then if created and created.release then created:release()end;return nil,tostring(value)end
 images[key]=value;return value
end
function M.release()
 -- Renderer/provider reset only, after all scene-owned bank meshes release.
 for _,image in pairs(images)do image:release()end
 for _,image in ipairs(retired)do image:release()end
 images,retired={},{}
end
return M
