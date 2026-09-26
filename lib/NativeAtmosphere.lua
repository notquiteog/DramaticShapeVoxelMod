-- Native maps feed the shared depth-aware atmosphere without changing engine
-- map tables. World-pixel dimensions preserve deterministic particle positions.
local V=...
local M={}
local F=V.require('ForestAtmos')
local C=V.require('CommunityVisuals')
local T=V.require('TowerFogSettings')
M.settings={F.setting,C.forest,C.caves,C.caveDetails,C.tower,T.enabled,T.thickness,T.speed,T.details}
local configured={}
local proxies=setmetatable({},{__mode='k'})
function M.gen3(def,id)
 if not def then return end
 if not proxies[def]then
  local layout=def.midLayout or {}
  proxies[def]={id=def.id or id,def={width=(layout.width or def.width or 16)/2,
   height=(layout.height or def.height or 16)/2,environment=def.environment},nativeType=def.mapType,nativeGeneration=3}
 end
 return proxies[def]
end
function M.kind(map)
 if not map then return end
 local id=tostring(map.id or '')
 local native=map.nativeGeneration==3 or type(map.cellCollision)=='function'
 if not native then return end -- existing Gen1 scene ownership is untouched
 if id=='ILEX_FOREST' or id=='FR_VIRIDIAN_FOREST' or id=='FR_THREE_ISLAND_BERRY_FOREST' or id=='FR_SIX_ISLAND_PATTERN_BUSH' then return 'forest' end
 if id:match('^TIN_TOWER_') or id:match('^BURNED_TOWER_') or id:match('^FR_POKEMON_TOWER_') then return 'tower' end
 local def=map.def or {}
 if def.environment=='CAVE' or map.nativeType==4 then return 'cave' end
end
local function profile(map)
 local kind=M.kind(map);if not kind then return end
 local key=tostring(map.id)..':'..kind
 if not configured[key]then
  local forest=kind=='forest'
  F.setOverride(map.id,{canopyY=forest and 56 or 32,fadeTo=forest and 28 or 16,
   fog={density=forest and .0025 or .002,start=forest and 112 or 56,heightK=forest and .024 or .06},
   rays={strength=forest and 6.5 or 0,reach=280},motes={count=48},fireflies={count=forest and 32 or 0},seed=0x51D})
  configured[key]=true
 end
 local opt={level='off',speed=1}
 if kind=='forest' and C.customForest()then opt.level=F.setting:get()
 elseif kind=='cave' and C.customCaves()then
  local d=C.caveDetailLevel();opt.level=d=='full' and 'full' or d=='subtle' and 'low' or 'off'
 elseif kind=='tower' and C.customTower()then
  local detail=T.detailsLevel()
  opt.level=detail=='off' and 'low' or 'full';opt.speed=T.speedMultiplier()
  opt.particleLevel=detail=='subtle' and .35 or 1
 end
 return kind,opt
end
function M.fog(map)
 local kind,opt=profile(map);if not opt or opt.level=='off'then return end
 if kind=='tower' and not T.active()then return end
 local f=F.frame(map,nil,opt);if not f then return end
 if kind~='forest'then
  f.fog.color=kind=='tower' and {.32,.30,.40} or {.26,.29,.32}
  if kind=='tower'then local a,h=T.thicknessMultipliers();f.fog.density=f.fog.density*a;f.fog.heightK=f.fog.heightK/h end
 end
 return f.fog
end
function M.draw(map)
 local _,opt=profile(map);if not opt or opt.level=='off'then return end
 F.draw(map,opt)
end
return M
