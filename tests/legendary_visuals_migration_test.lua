-- Existing per-setting Legendary saves must enter CUSTOM once; fresh installs
-- and profiles with an explicit master choice keep the master value they own.
local checks=0
local function check(v,msg) checks=checks+1; assert(v,msg) end

local function fixture(stored)
  local Setting={}; Setting.__index=Setting
  local function indexOf(self,value)
    for i,v in ipairs(self.values) do if v==value then return i end end
    return self.defaultIndex
  end
  function Setting.new(key,label,values,labels,default)
    return setmetatable({key=key,label=label,values=values,labels=labels,
      defaultIndex=default or 1,index=nil},Setting)
  end
  function Setting:read()
    if not self.index then self.index=indexOf(self,stored[self.key]) end
    return self.index
  end
  function Setting:get() return self.values[self:read()] end
  function Setting:setIndex(i)
    self.index=((i-1)%#self.values)+1
    return self.values[self.index]
  end
  function Setting:sync(value) self.index=indexOf(self,value) end
  function Setting:row()
    local s=self
    return {value=function() return s.labels[s:read()] end,
      step=function(_,dir) s:setIndex(s:read()+(dir or 1)); return true end}
  end

  local function S(key,values,labels,default)
    return Setting.new(key,key,values,labels or values,default)
  end
  local C={}
  C.casino=S('communityCasino',{'default','n64memory'})
  C.prizeRoom=S('communityPrizeRoom',{'default','n64memory'})
  C.tunnels=S('communityTunnels',{'default','n64memory'})
  C.rocket=S('communityRocket',{'default','n64memory'})
  C.elevator=S('communityElevator',{'default','n64memory'})
  C.pillars=S('communityPillars',{'default','separate','bottom','top'})
  C.masonry=S('communityMasonry',{'granite','red','sandstone','slate'})
  C.tower=S('communityTower',{'default','n64memory'})
  C.towerWall=S('communityTowerWall',{'smoke_black','storm_white','pearl_white'})
  C.caves=S('communityCaves',{'default','n64memory'})
  C.caveDetails=S('communityCaveDetails',{'off','subtle','full'})
  C.caveSound=S('communityCaveSound',{'off','low','mid'})
  C.trees=S('communityTrees',{'default','n64memory','n64memory_fast'})
  C.treeDetail=S('communityTreeDetail',{'full','balanced','handheld'},nil,2)
  for _,entry in ipairs({
    {'cutTrees','communityCutTrees'},{'signs','communitySigns'},
    {'cityGround','communityCityGround'},{'grass','communityGrass'},
    {'roads','communityRoads'},{'walls','communityWalls'},
    {'courtyards','communityCourtyards'},{'sky','communitySky'},
    {'forest','communityForest'},
  }) do C[entry[1]]=S(entry[2],{'default','n64memory'}) end
  C.safari=S('communitySafari',{'default','n64memory'});C.kantoLife=S('communityKantoLife',{'off','natural'})
  C.settings={C.safari,C.kantoLife,C.casino,C.prizeRoom,C.tunnels,C.rocket,C.elevator,C.pillars,
    C.masonry,C.tower,C.towerWall,C.caves,C.caveDetails,C.caveSound,C.trees,
    C.treeDetail,C.cutTrees,C.signs,C.cityGround,C.grass,C.roads,C.walls,
    C.courtyards,C.sky,C.forest}
  C.invalidations=0
  function C.invalidate() C.invalidations=C.invalidations+1 end

  local T={
    details=S('towerDetails',{'off','subtle','full'},nil,3),
    enabled=S('towerFog',{'off','on'},nil,2),
    thickness=S('towerFogThickness',{'light','normal','thick','heavy'},nil,2),
    speed=S('towerFogSpeed',{'slow','normal','fast'},nil,2),
  }
  local F={setting=S('atmos',{'low','off'})}
  local modules={ModSetting=Setting,CommunityVisuals=C,TowerFogSettings=T,ForestAtmos=F}
  local V={mod={id='BATTLE_ART_VOXEL_FORK',options={
    get=function(_,key) return stored[key] end,
  }},require=function(name) return assert(modules[name],name) end}
  local P=assert(loadfile('lib/LegendaryVisualsPreset.lua'))(V)
  return P,C
end

local P=fixture({communityTower='n64memory'})
check(P.mode()=='custom','legacy child settings select CUSTOM before persistence migration')
local writes=0
local save={options={modOptions={}}}
local game={save=save,mods={modOptions={}},writeOptions=function() writes=writes+1 end}
check(P.migrate(game,save),'legacy profile migrates once')
check(save.options.modOptions.BATTLE_ART_VOXEL_FORK.legendaryVisualsMode=='custom',
  'migration persists CUSTOM into save options')
check(game.mods.modOptions.BATTLE_ART_VOXEL_FORK.legendaryVisualsMode=='custom',
  'migration mirrors CUSTOM into live loader options')
check(P.mode()=='custom' and writes==1,'migration keeps CUSTOM effective and writes once')
check(not P.migrate(game,save) and writes==1,'migration is idempotent')

local explicit=fixture({legendaryVisualsMode='off',communityTower='n64memory'})
check(explicit.mode()=='off','explicit master OFF wins over legacy child values')

local fresh=fixture({})
check(fresh.mode()=='off','fresh profile remains OFF')

print(checks..' checks passed (Legendary Visuals migration)')
