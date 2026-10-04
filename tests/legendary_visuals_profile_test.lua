-- LEGENDARY VISUALS master profile: effective overlays must never destroy the
-- stored CUSTOM combination.
local checks=0
local function check(v,msg) checks=checks+1; assert(v,msg) end

local Setting={}; Setting.__index=Setting
function Setting.new(key,label,values,labels,default)
  return setmetatable({key=key,label=label,values=values,labels=labels,
    defaultIndex=default or 1,index=nil},Setting)
end
function Setting:read() if not self.index then self.index=self.defaultIndex end; return self.index end
function Setting:get() return self.values[self:read()] end
function Setting:setIndex(i)
  local n=#self.values; self.index=((i-1)%n)+1; return self.values[self.index]
end
function Setting:cycle(_,d) return self:setIndex(self:read()+(d or 1)) end
function Setting:row()
  local s=self
  return {value=function() return s.labels[s:read()] end,
    step=function(game,d) s:cycle(game,d); return true end}
end

local function S(key,values,labels,default) return Setting.new(key,key,values,labels or values,default) end
local C={}
C.casino=S('casino',{'default','n64memory'}); C.prizeRoom=S('prize',{'default','n64memory'})
C.tunnels=S('tunnels',{'default','n64memory'}); C.rocket=S('rocket',{'default','n64memory'}); C.elevator=S('elevator',{'default','n64memory'})
C.pillars=S('pillars',{'default','separate','bottom','top'}); C.masonry=S('masonry',{'granite','red','sandstone','slate'})
C.tower=S('tower',{'default','n64memory'}); C.towerWall=S('towerWall',{'smoke_black','storm_white','pearl_white'})
C.caves=S('caves',{'default','n64memory'}); C.caveDetails=S('caveDetails',{'off','subtle','full'}); C.caveSound=S('caveSound',{'off','low','mid'})
C.trees=S('trees',{'default','n64memory','n64memory_fast'}); C.treeDetail=S('treeDetail',{'full','balanced','handheld'},nil,2)
for _,k in ipairs({'cutTrees','signs','cityGround','grass','roads','walls','courtyards','sky','forest'}) do C[k]=S(k,{'default','n64memory'}) end
C.safari=S('communitySafari',{'default','n64memory'});C.kantoLife=S('communityKantoLife',{'off','natural'})
  C.settings={C.safari,C.kantoLife,C.casino,C.prizeRoom,C.tunnels,C.rocket,C.elevator,C.pillars,C.masonry,
  C.tower,C.towerWall,C.caves,C.caveDetails,C.caveSound,C.trees,C.treeDetail,
  C.cutTrees,C.signs,C.cityGround,C.grass,C.roads,C.walls,C.courtyards,C.sky,C.forest}
C.invalidations=0; function C.invalidate() C.invalidations=C.invalidations+1 end
local T={details=S('details',{'off','subtle','full'},nil,3),enabled=S('fog',{'off','on'},nil,2),thickness=S('thick',{'light','normal','thick','heavy'},nil,2),speed=S('speed',{'slow','normal','fast'},nil,2)}
local F={setting=S('forestFx',{'low','off'})}; function F.invalidate() end
local modules={ModSetting=Setting,CommunityVisuals=C,TowerFogSettings=T,ForestAtmos=F}
local V={mod={id='BATTLE_ART_VOXEL_FORK',options={get=function() return nil end}},
  require=function(name) return assert(modules[name],name) end}
local P=assert(loadfile('lib/LegendaryVisualsPreset.lua'))(V)

check(P.mode()=='off','fresh installs default to OFF')
C.tower:setIndex(2); C.cityGround:setIndex(1); C.trees:setIndex(3); C.treeDetail:setIndex(3)
C.masonry:setIndex(2); C.towerWall:setIndex(3); C.caveSound:setIndex(3)
T.thickness:setIndex(4); T.speed:setIndex(3)
check(C.tower:get()=='default' and C.trees:get()=='default',
  'OFF overlays Battle Art without changing remembered children')
check(C.tower.values[C.tower:read()]=='n64memory'
    and C.trees.values[C.trees:read()]=='n64memory_fast',
  'OFF preserves raw CUSTOM world choices')
check(C.masonry:get()=='red' and C.towerWall:get()=='pearl_white'
    and C.caveSound:get()=='mid' and T.thickness:get()=='heavy' and T.speed:get()=='fast',
  'style and audio choices remain independent under OFF')

P.setting:setIndex(3)
check(C.tower:get()=='n64memory' and C.cityGround:get()=='n64memory'
    and C.grass:get()=='n64memory' and C.trees:get()=='n64memory',
  'AUTO enables complete Legendary world and Tower gates')
check(C.treeDetail:get()=='balanced' and C.caveDetails:get()=='subtle'
    and T.details:get()=='subtle' and T.enabled:get()=='on'
    and F.setting:get()=='low',
  'AUTO uses balanced detail while retaining intended Tower fog and forest FX')
check(C.masonry:get()=='red' and C.towerWall:get()=='pearl_white'
    and C.caveSound:get()=='mid' and T.thickness:get()=='heavy' and T.speed:get()=='fast',
  'AUTO leaves style, sound, fog thickness and fog speed untouched')

P.setting:setIndex(4)
check(C.trees:get()=='n64memory' and C.treeDetail:get()=='full','FULL uses maximum tree detail')
check(C.caveDetails:get()=='full' and T.details:get()=='full' and T.enabled:get()=='on',
  'FULL raises cave and Tower detail to maximum')
check(F.setting:get()=='low' and C.pillars:get()=='separate',
  'FULL keeps the supported forest FX and canonical pillar layout')

P.setting:setIndex(2)
check(C.tower:get()=='n64memory' and C.cityGround:get()=='default'
    and C.trees:get()=='n64memory_fast' and C.treeDetail:get()=='handheld',
  'CUSTOM restores the exact remembered world combination')

-- Editing a child while a preset is active leaves the preset and applies the
-- requested step to the remembered custom combination.
P.setting:setIndex(1)
local row=C.tower:row(); row.step(nil,-1)
check(P.mode()=='custom','manual child edit leaves preset for CUSTOM')
check(C.tower:get()=='default','manual step applies to remembered custom value')
local before=C.invalidations
P.setting:setIndex(1)
P.setting:row().step(nil,1)
check(C.invalidations==before+1,'one master step performs one broad invalidation')
print(checks..' checks passed (Legendary Visuals master profile)')
