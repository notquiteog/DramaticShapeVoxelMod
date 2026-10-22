-- Optional locally imported XD pack. All editions use this same consumer.
-- Game data is never distributed by the mod; absent/invalid packs keep sprites.
local V=...
local M={apiVersion=2}
M.setting=V.require('ModSetting').new('xdModels','XD POKEMON MODELS',
 {false,true},{'OFF','ON'})
local ROOT='assets/generated/xd/'
local manifest,failed
local Json
local function json(bytes)
 Json=Json or require('src.link.Json')
 return assert(Json.decode(bytes,64*1024*1024))
end
local function read(path)
 if type(path)~='string'or path:find('..',1,true)or path:sub(1,1)=='/'then return end
 return V.mod:read(ROOT..path)
end
function M.available()
 if failed then return false end
 if manifest then return true end
 local ok,data=pcall(function()
  local bytes=read('manifest.json');if not bytes then return end
  local value=json(bytes)
  if value.format~='xd-converted-pack'or value.version~=1 or value.renderReady~=true
   or type(value.models)~='table'then return end
  return value
 end)
 if not ok or not data then failed=true;return false end
 manifest=data;return true
end
function M.active()return V.require('VisualStyles').modern('pokemon') and M.setting:get()==true and M.available()end
function M.formFor(battler,dex,presentation)return V.require('XDIdentity').form(dex,battler,presentation)end
function M.reset()manifest=nil;failed=nil end
function M.newInstance(dex,variant,options)
 if not M.active()then return nil,'XD pack unavailable or disabled'end
 dex=tonumber(dex);if not dex or dex<1 or dex>386 or dex%1~=0 then return nil,'Invalid XD species'end
 variant=variant or'normal'
 local form=options and options.form and tostring(options.form)or'default'
 local selected
 for _,row in ipairs(manifest.models)do
  if row.dex==dex and row.variant==variant and row.form==form then selected=row;break end
 end
 -- Do not silently use a normal texture for a shiny or the wrong form.
 if not selected then return nil,'Requested XD variant unavailable'end
 local hash=selected.sha256
 if type(hash)~='string'or #hash~=64 or hash:find('[^0-9a-f]')then return nil,'Invalid XD pack record'end
 local images,white={},nil
 local function cleanup()
  -- SDK images are shared, including on construction failure.
  images={}
  if white then pcall(white.release,white);white=nil end
 end
 local ok,instance,err=pcall(function()
  local bytes=assert(read(hash..'/model.json.z'),'Missing XD model')
  local data=json(love.data.decompress('string','zlib',bytes))
  return V.require('XDModelInstance').new(data,{
   read=function(path)return read(hash..'/'..path)end,
   image=function(path)
    if path:find('..',1,true)or path:find('/')then return end
    if not images[path]then
     images[path]=V.mod.assets:image(ROOT..hash..'/'..path)
    end
    return images[path]
   end,
   white=function()
    if not white then
     local pixels=love.image.newImageData(1,1);pixels:setPixel(0,0,1,1,1,1)
     white=love.graphics.newImage(pixels);pixels:release()
    end
    return white
   end,
  })
 end)
 if not ok or not instance then cleanup();return nil,ok and err or instance end
 -- Mod assets may cache images; release only objects this instance created.
 -- The SDK owns assets:image resources, so keep them out of cleanup.
 local original=instance.release
 instance.release=function(self)original(self);cleanup()end
 return instance
end
M.exports={models=M,modelsEnabled=function()return M.active()end,
 battleEnabled=function()return M.active()end}
return M
