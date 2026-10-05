-- Standalone TEST56 menu, live settings, room scope and geometry checks.
local checks = 0
local function check(v, msg) checks = checks + 1; assert(v, msg) end
local invalidated = {}
local Setting = {}
function Setting.new(key, label, values, labels, default)
  local s = {key=key,label=label,values=values,index=default or 1}
  function s:get() return self.values[self.index] end
  function s:row() return {step=function(_, dir)
    self.index = (self.index - 1 + dir) % #self.values + 1
  end} end
  return s
end
local modules, V = {}, {}
function V.require(name)
  if name == 'ModSetting' then return Setting end
  if modules[name] then return modules[name] end
  return {invalidate=function() invalidated[name]=(invalidated[name] or 0)+1 end}
end
local C = assert(loadfile('lib/CommunityVisuals.lua'))(V)
modules.CommunityVisuals = C
modules.TowerGarden = assert(loadfile('lib/TowerGarden.lua'))(V)
for _, name in ipairs({'GameCorner','PrizeRoom','UndergroundRoom','RocketRoom','LegendaryGarden'}) do
  modules[name] = assert(loadfile('lib/'..name..'.lua'))(V)
end
local f=assert(io.open('main.lua','rb'));local main=f:read('*a');f:close()
local start=assert(main:find('local LEGENDARY_ROOT =',1,true))
local finish=assert(main:find('-- Categorized OPTIONS first shipped',start,true))
local masterSetting={key='legendaryVisualsMode'}
local legendaryMode='off'
local managed={}
for _,setting in ipairs(C.settings)do managed[setting]=true end
local preset={setting=masterSetting,mode=function()return legendaryMode end,
  isMember=function(setting)return managed[setting]==true end}
local env=setmetatable({V=V,CommunityVisuals=C,LegendaryVisualsPreset=preset},{__index=function(t,k)
  if _G[k]~=nil then return _G[k] end
  local proxy=setmetatable({},{__index=function(p,n)local value={};rawset(p,n,value);return value end})
  rawset(t,k,proxy);return proxy
end})
local fn=assert(loadstring(main:sub(start,finish-1)
  ..'\nreturn LEGENDARY_ROOT, LEGENDARY_CATEGORIES, OPTION_CATEGORIES, ALL_OPTION_CATEGORIES, OPTION_CATEGORY'))
setfenv(fn,env)
local root,categories,ordinary,allCategories,mapping=fn()
local expected={casino='legendary_game_corner',prizeRoom='legendary_game_corner',
  cityGround='legendary_lavender',tunnels='legendary_interiors',rocket='legendary_interiors',
  elevator='legendary_interiors',treeDetail='legendary_nature'}
local seen={}
for _,group in ipairs(categories)do for _,setting in ipairs(group.settings)do
  check(not seen[setting], 'a setting must not be stolen by a second submenu')
  seen[setting]=group.id
end end
for name,id in pairs(expected)do check(mapping[C[name]].id==id,'submenu placement: '..name)end

-- The master selector is always the first Legendary row. Preset-owned child
-- pages disappear outside CUSTOM, while independent style/audio pages remain.
local rowsStart=assert(main:find('local function categorizedRows(rows)',finish,true))
local rowsEnd=assert(main:find('-- GBC FX',rowsStart,true))
local rowsEnv=setmetatable({LEGENDARY_ROOT=root,LEGENDARY_CATEGORIES=categories,
  OPTION_CATEGORIES=ordinary,ALL_OPTION_CATEGORIES=allCategories,
  OPTION_CATEGORY=mapping,LegendaryVisualsPreset=preset,
  require=function(name)if name=='src.ui.OptionsMenu'then return {} end return require(name)end,
},{__index=_G})
local rowsFn=assert(loadstring(main:sub(rowsStart,rowsEnd-1)..'\nreturn categorizedRows'))
setfenv(rowsFn,rowsEnv)
local categorize=rowsFn()
local function group(rows,id)
  for _,row in ipairs(rows or {})do
    if row.id=='BATTLE_ART_VOXEL_FORK:group:'..id then return row end
  end
end
local masterRow={id='master',optionSetting=masterSetting}
local cityRow={id='city',optionSetting=C.cityGround}
local towerStyleRow={id='tower-style',optionSetting=env.CommunityVisuals.towerWall}
managed[env.CommunityVisuals.towerWall]=false
local offRoot=assert(group(categorize({masterRow,cityRow,towerStyleRow}),'legendary_visuals'))
check(offRoot.members[1]==masterRow and offRoot.value()=='OFF',
  'Legendary root exposes the OFF/CUSTOM/AUTO/FULL master first')
check(not group(offRoot.members,'legendary_lavender'),
  'OFF hides preset-owned Lavender child page')
check(group(offRoot.members,'legendary_tower')~=nil,
  'OFF keeps independent Tower style page available')
legendaryMode='custom'
local customRoot=assert(group(categorize({masterRow,cityRow,towerStyleRow}),'legendary_visuals'))
check(customRoot.value()=='CUSTOM' and group(customRoot.members,'legendary_lavender')~=nil,
  'CUSTOM restores remembered individual Legendary pages')
legendaryMode='off'
local gateStart=assert(main:find('local function categorizedOptionsAvailable()',1,true))
local gateEnd=assert(main:find('local function findOptionGroup',gateStart,true))
local gate=assert(loadstring(main:sub(gateStart,gateEnd-1)..'\nreturn categorizedOptionsAvailable'))()
package.loaded['src.core.Version']={engine='0.2.53'}
check(gate(),'0.2.53 gets the nested menu')
package.loaded['src.core.Version']={engine='0.2.36'}
check(not gate(),'older engines retain the flat menu')

-- Route 10's new Tower garden belongs to CITY GROUND, not the broad GRASS
-- switch. A player may opt into Legendary route grass while deliberately
-- retaining the protected Battle Art Lavender/Route 10 city-ground baseline.
C.cityGround.index=1;C.grass.index=2
check(not modules.TowerGarden.enabled(),
  'Legendary GRASS alone does not enable the Route 10 Tower garden')
C.cityGround.index=2;C.grass.index=1
check(modules.TowerGarden.enabled(),
  'Legendary CITY GROUND enables the Route 10 Tower garden')
C.cityGround.index=1;C.grass.index=1

for _,name in ipairs({'casino','prizeRoom','tunnels','rocket','elevator'})do
  local s=C[name]
  check(s:get()=='default','Battle Art first-use default: '..name)
  local before=invalidated.ChunkMesher or 0
  s:row().step(nil,1)
  check(s:get()=='n64memory','saved option enables: '..name)
  check((invalidated.ChunkMesher or 0)==before+1 and invalidated.TerrainAtlas,
    'live switch invalidates derived geometry and atlas: '..name)
end
local function map(id,tileset,w,h,grid,fill)
  return {id=id,tileset={id=tileset},def={width=w,height=h},tileAt=function(_,x,y)
    return grid[x..':'..y] or fill or 0
  end}
end
local casino=map('GAME_CORNER','LOBBY',10,8,
  {['4:4']=7,['5:4']=8,['4:5']=23,['5:5']=24,['6:4']=54},55)
local prizeGrid={}
for _,x in ipairs({4,8,12})do prizeGrid[x..':3']=10;prizeGrid[(x+1)..':3']=11 end
for x=0,19 do prizeGrid[x..':4']=39;prizeGrid[x..':5']=21 end
local prize=map('GAME_CORNER_PRIZE_ROOM','LOBBY',5,4,prizeGrid)
local tunnel=map('UNDERGROUND_PATH_NORTH_SOUTH','UNDERGROUND',2,4,{},11)
local rocket=map('ROCKET_HIDEOUT_B2F','FACILITY',4,4,{},1)
local elevator=map('ROCKET_HIDEOUT_ELEVATOR','LOBBY',3,4,{})
local cases={{'casino','GameCorner',casino},{'prizeRoom','PrizeRoom',prize},
  {'tunnels','UndergroundRoom',tunnel},{'rocket','RocketRoom',rocket},
  {'elevator','RocketRoom',elevator}}
for _,case in ipairs(cases)do
  local setting,room,m=C[case[1]],modules[case[2]],case[3]
  setting.index=2
  local layout=room.layout(m)
  check(layout~=nil,'enabled original layout recognized: '..case[1])
  do
    local vertices,indices=room.geometry(layout)
    local valid=#vertices>0 and #indices>0
    for _,v in ipairs(vertices)do for i=1,6 do valid=valid and type(v[i])=='number' and v[i]==v[i] and math.abs(v[i])<1e8 end end
    for _,i in ipairs(indices)do valid=valid and i>=1 and i<=#vertices and i==math.floor(i) end
    check(valid,'finite geometry and valid indices: '..case[1])
  end
  local original=m.id;m.id='UNRELATED'
  check(not room.layout(m),'unrelated map excluded: '..case[1]);m.id=original
  setting.index=1
  check(not room.layout(m),'Battle Art declines all new claims: '..case[1])
  setting.index=2
end
prizeGrid['4:3']=0
check(not modules.PrizeRoom.layout(prize),'modified source pattern retains native prize-room art')
elevator.def.width=4
check(not modules.RocketRoom.layout(elevator),'modified elevator dimensions retain native cabin')
C.rocket.index=1
check(modules.RocketRoom.accepts({id='ROCKET_HIDEOUT_ELEVATOR',tileset={id='LOBBY'}}),
  'elevator switch is independent of basement switch')
C.elevator.index=1;C.rocket.index=2
check(modules.RocketRoom.accepts(rocket),'basement switch is independent of elevator switch')

-- A capability query must never draw a world item or require entity context.
local renderer=assert(loadfile('lib/CharacterRenderers.lua'))({require=function(name)
  if name=='ItemPokeballs' then error('capability query tried to draw an item')end
  return {}
end})
check(pcall(renderer.has,'drawEntity'),'renderer capability lookup stays read-only')
print(checks..' checks passed (TEST56 interiors and submenu integration)')
