-- Adapt the permitted KFP release without its filesystem patcher or globals.
-- Geometry payloads remain vendored for native tile adapters; only audited
-- map-independent background effects are dispatched here.
local V=...
local M={errors={}}
local Setting=V.require('ModSetting')
M.horizon=Setting.new('kfpHorizon','KFP HORIZON',{'off','kanto','fuji','valley','city'},{'BATTLE ART','KANTO','FUJI','VALLEY','CITY'})
M.sky=Setting.new('kfpSky','KFP SKY',{false,true},{'BATTLE ART','LAYERED'})
M.aircraft=Setting.new('kfpAircraft','KFP AIRCRAFT',{false,true},{'OFF','ON'})
M.rainbows=Setting.new('kfpRainbows','RAINBOWS',{false,true},{'OFF','ON'})
M.settings={M.horizon,M.sky,M.aircraft,M.rainbows}
local modules,env={},nil
local root=(V.path or '')..'/vendor/kanto-first-person/'
local pictures={kanto='backdrop.png',fuji='backdrop2.png',valley='backdrop3.png',city='backdrop4.png'}
local function copy(t)local r={};for k,v in pairs(t or {})do r[k]=v end;return setmetatable(r,{__index=t}) end
local function environment()
 if env then return env end
 env=setmetatable({},{__index=_G});env._G={}
 -- Atmospheric randomness must never reseed the game's encounter RNG.
 local rng=love.math.newRandomGenerator(170601)
 env.math=copy(math)
 env.math.random=function(...)return rng:random(...)end
 env.math.randomseed=function(seed)rng:setSeed(seed)end
 -- Installer/orphan cleanup is not allowed to write anything in our host.
 env.love=copy(love);env.love.filesystem=copy(love.filesystem)
 env.love.graphics=copy(love.graphics);env.love.image=copy(love.image)
 local function relative(path)
  if path:sub(1,#root)==root then return 'vendor/kanto-first-person/'..path:sub(#root+1)end
  error('unexpected embedded KFP asset path: '..path)
 end
 env.love.graphics.newImage=function(value,...)
  if type(value)=='string'then
   local rel=relative(value);local data=love.filesystem.newFileData(assert(V.mod:read(rel)),rel)
   local image=love.graphics.newImage(data);data:release();return image
  end
  return love.graphics.newImage(value,...)
 end
 env.love.image.newImageData=function(value,...)
  if type(value)=='string'then
   local rel=relative(value);local bytes=assert(V.mod:read(rel))
   return love.image.newImageData(love.filesystem.newFileData(bytes,rel))
  end
  return love.image.newImageData(value,...)
 end
 for _,name in ipairs({'write','append','remove','createDirectory','mount','unmount','setIdentity'})do
  env.love.filesystem[name]=function()return nil,'KFP embedded assets are read-only'end
 end
 env._G.__ds_ceiling_config=function()
  return {backdrop=M.horizon:get()~='off',clouds=M.sky:get(),stars=M.sky:get(),
   aircraft=M.aircraft:get(),birds=false,groundflock=false,rainbows=M.rainbows:get()}
 end
 return env
end
local function payload(name)
 if modules[name]then return modules[name]end
 local rel='vendor/kanto-first-person/payload_'..name..'.lua'
 local source=assert(V.mod:read(rel),'missing KFP payload '..name)
 local prefix='local __host=select(2,...); local _G,math,love=__host._G,__host.math,__host.love;\n'
 local chunk=assert(loadstring(prefix..source,'@'..rel))
 modules[name]=chunk(V,environment())
 return modules[name]
end
-- Explicit native map classification; a disconnected outdoor town is not a
-- room, and a forest is not a suitable place for a panoramic sky cylinder.
function M.outdoor(map)
 if not map then return false end
 local d=map.def or map
 if map.nativeGeneration==3 or d.mapType~=nil then
  local t=tonumber(map.nativeType or d.mapType)
  return (t==1 or t==2 or t==3 or t==5 or t==6) and V.require('NativeAtmosphere').kind(map)~='forest'
 end
 if d.environment then return d.environment=='TOWN' or d.environment=='ROUTE' end
 local ts=d.tileset
 return ts=='OVERWORLD' or ts=='PLATEAU' or ts=='SHIP_PORT'
end
function M.enabled()return M.horizon:get()~='off' or M.sky:get() or M.aircraft:get() or M.rainbows:get()end
function M.draw(state)
 if not M.enabled() or not state or not M.outdoor(state.map) then return false end
 -- The background needs positions and outdoor eligibility, never Gen1 tile
 -- numbers. Normalize just those facts for all eleven editions.
 local map=state.map;local proxy={def={tileset='OVERWORLD',connections={}},id=map.id}
 local normalized={map=proxy,player=state.player}
 local e=environment();local choice=M.horizon:get()
 local weather=V.require('Weather').mode(map)
 local raining=weather=='rain' or weather=='storm'
 local previous=e._G.__ds_weather or {}
 e._G.__ds_weather={raining=raining,storm=weather=='storm',
  stoppedAt=previous.raining and not raining and love.timer.getTime() or previous.stoppedAt}
 e._G.__ds_backdrop_path=root..(pictures[choice]or pictures.kanto)
 local R=V.require('Voxel3D');local tint=R.tint;local fog=R.fog
 local function draw(name)
  love.graphics.push('all')
  local ok,err=pcall(function()payload(name).draw(normalized)end)
  love.graphics.pop();R.tint=tint;R.fog=fog
  if not ok then M.errors[name]=tostring(err)else M.errors[name]=nil end
 end
 if choice~='off'then
  if M.lastHorizon~=choice and modules.backdrop then
   -- Upstream invalidate preserves its loaded panorama. Reload the payload
   -- on art changes so the next choice takes effect without a game restart.
   modules.backdrop.invalidate();modules.backdrop=nil
  end
  M.lastHorizon=choice;draw('backdrop')
 end
 if M.sky:get()or M.aircraft:get()or M.rainbows:get()then draw('sky')end
 return true
end
function M.status()
 local result={};for k,v in pairs((env and env._G)or{})do
  if k:match('_status$')then result[k]=v end
 end
 return result
end
function M.invalidate()
 for _,p in pairs(modules)do if p.invalidate then p.invalidate()end end
end
return M
