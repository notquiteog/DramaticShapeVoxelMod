-- Native maps feed the shared depth-aware atmosphere without changing engine
-- map tables. World-pixel dimensions preserve deterministic particle positions.
local V=...
local M={}
local F=V.require('ForestAtmos')
local C=V.require('CommunityVisuals')
local T=V.require('TowerFogSettings')
M.settings={F.setting,C.forest,C.caves,C.caveDetails,C.tower,T.enabled,T.thickness,T.speed,T.details}
local configured={}
local mistLayouts=setmetatable({},{__mode='k'})
local proxies=setmetatable({},{__mode='k'})
function M.gen3(def,id)
 if not def then return end
 if not proxies[def]then
  local layout=def.midLayout or {}
  proxies[def]={id=def.id or id,def={width=(layout.width or def.width or 16)/2,
   height=(layout.height or def.height or 16)/2,environment=def.environment},nativeType=def.mapType,nativeGeneration=3,nativeDef=def}
 end
 return proxies[def]
end
function M.kind(map)
 if not map then return end
 local id=tostring(map.id or '')
 local native=map.nativeGeneration==3 or type(map.cellCollision)=='function'
 if not native then return end -- existing Gen1 scene ownership is untouched
 if id=='ILEX_FOREST' or id=='FR_VIRIDIAN_FOREST' or id=='FR_THREE_ISLAND_BERRY_FOREST' or id=='FR_SIX_ISLAND_PATTERN_BUSH' or id=='EM_PETALBURG_WOODS'
   or (map.def or {}).environment=='FOREST' then return 'forest' end
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
function M.mistLayout(map)
 if M.kind(map)~='tower'then return end
 if mistLayouts[map]then return mistLayouts[map]end
 local layout={anchors={}}
 local w,h=map.def.width*2,map.def.height*2
 if map.nativeGeneration==3 then
  local def=map.nativeDef;local native=def and def.midLayout
  if not native then return end
  local graves={[0x291]=true,[0x293]=true,[0x2be]=true,[0x2bf]=true,[0x2d8]=true,[0x2d9]=true}
  for y=0,h-1 do for x=0,w-1 do if graves[native:midAt(x,y)]then layout.anchors[#layout.anchors+1]={x,y}end end end
  layout.walk=function(x,y)return x>=0 and y>=0 and x<w and y<h and native:collAt(x,y)~=7 end
  layout.ground=function(x,z)return V.require('Gen3Elevation').at(def,x,z)end
 else
  if not map.isWalkableCell then return end
  layout.walk=function(x,y)return x>=0 and y>=0 and x<w and y<h and map:isWalkableCell(x,y)end
  layout.ground=function(x,z)return V.require('Gen2Elevation').at(map,x,z)end
  -- Crystal towers have timber pillars/ruins instead of grave rows. Seed
  -- banks along those solid boundaries, excluding the blank outer padding.
  for y=1,h-2 do for x=1,w-2 do
   local a,b=map:tileAt(x*2,y*2),map:tileAt(x*2+1,y*2+1)
   if not layout.walk(x,y) and not(a==1 and b==1) and
    (layout.walk(x-1,y)or layout.walk(x+1,y)or layout.walk(x,y-1)or layout.walk(x,y+1))then
    layout.anchors[#layout.anchors+1]={x,y}
   end
  end end
 end
 mistLayouts[map]=layout;return layout
end
function M.draw(map)
 local kind,opt=profile(map);if not opt or opt.level=='off'then return end
 F.draw(map,opt)
 if kind=='tower' and T.active()then V.require('TowerGraveMist').drawNative(map,M.mistLayout(map))end
end
return M
