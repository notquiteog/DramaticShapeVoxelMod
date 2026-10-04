local checks = 0
local function ok(value, message)
  checks = checks + 1
  if not value then error("FAIL " .. message, 0) end
end

local function identity()
  return {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1}
end

local Mat4 = assert(loadfile("lib/Mat4.lua"))()
local BattleArt = {
  speciesFor=function(battler) return battler and battler.mon.species end,
  isShiny=function(battler) return battler and battler.shiny == true end,
}

local created, released, drawCalls, shadowCalls = {}, 0, {}, {}
local function newFakeInstance(species, variant, options)
  if species == 99 then return nil, "deliberate missing pack" end
  local instance = {
    species=species,variant=variant,options=options,finished=false,
    contexts={},moves={},updates={},
  }
  function instance:playContext(name, loop)
    self.contexts[#self.contexts+1]={name=name,loop=loop}; return true
  end
  function instance:playMove(move, loop)
    self.moves[#self.moves+1]={move=move,loop=loop}; return true
  end
  function instance:update(dt, runtime)
    self.updates[#self.updates+1]={dt=dt,runtime=runtime}; return true
  end
  function instance:isFinished() return self.finished end
  function instance:metrics()
    return {height=52.25,floor=-2,radius=10,rootScale=1,
      bounds={minY=-2,maxY=50.25}}
  end
  function instance:draw(options)
    drawCalls[#drawCalls+1]={instance=self,options=options}
    return self.drawFails ~= true, self.drawFails and "draw failed" or nil
  end
  function instance:drawShadow(options)
    shadowCalls[#shadowCalls+1]={instance=self,options=options}
    return self.shadowFails ~= true,
      self.shadowFails and "shadow failed" or nil
  end
  function instance:release()
    released=released+1; self.released=true; return true
  end
  created[#created+1]=instance
  return instance
end

local providerEnabled = true
local providerBattleEnabled = false
local provider = {exports={
  modelsEnabled=function() return providerEnabled end,
  battleEnabled=function() return providerBattleEnabled end,
  models={apiVersion=2,newInstance=newFakeInstance},
}}
local logger = {warnings={}}
function logger:warn(_, message) self.warnings[#self.warnings+1]=message end
local V = {mod={
  find=function(id) return id=="STADIUM2_IMPORTER" and provider or nil end,
  log=logger,
}}
function V.require(name)
  if name == 'SafariFooting' then return assert(loadfile('lib/SafariFooting.lua'))(V)end
  if name == 'WaterFooting' then return assert(loadfile('lib/WaterFooting.lua'))(V)end
  if name == 'BattleRaft' then return assert(loadfile('lib/BattleRaft.lua'))(V)end
  if name == 'Voxel3D' then return {}end
  if name == 'CommunityVisuals' then return {customRoads=function()return false end}end
  if name == 'SafariBattleFX' then return assert(loadfile('lib/SafariBattleFX.lua'))(V)end
  if name == 'FlyMotion' then return assert(loadfile('lib/FlyMotion.lua'))() end
  return assert(({Mat4=Mat4,BattleArt=BattleArt})[name],name)
end

local StadiumModels = assert(loadfile("lib/StadiumModels.lua"))(V)
ok(StadiumModels.installed(),"detects Stadium model API v2")
ok(not StadiumModels.active(),"Battle Art sprites remain while Stadium battle is off")

providerBattleEnabled=true
local battle={
  data={pokemon={EEVEE={dex=133}},moves={THUNDERBOLT={index=85}}},
  player={mon={species=25},shiny=true},
  enemy={mon={species="EEVEE"}},
  picFx={},
}
function battle:growInScale() return 1 end
function battle:fxFaintActive() return false end

ok(StadiumModels.update(battle,0.1),"opt-in bridge updates independently")
ok(#created==2 and created[1].species==25 and created[1].variant=="shiny"
  and created[2].species==133,"loads both host battlers through public API")
ok(created[1].options.flipY==false and created[1].options.anchorTravel,
  "uses scene renderer options without private importer access")

local arena={player={8,0,56},enemy={8,0,8}}
local textures={player={canvas=true},enemy={canvas=true,trainer=true}}
local placements=StadiumModels.placements(arena,3,textures,battle)
ok(placements.player and not placements.enemy,
  "trainer portraits stay on Battle Art's card path")
local placed=placements.player.modelMatrix
ok(math.abs(placed[6]*-2+placed[8]-3)<1e-9,
  "model floor is planted on voxel ground")

local context={view=identity(),viewProjection=identity(),tint={0.8,0.7,0.6},
  light={direction={0,1,0}},shadowMap="map",shadowVP=identity(),
  shadowDark=0.5,shadowBias=0.01,shadowTexel={1/512,1/512}}
ok(StadiumModels.draw(placements.player,context,"opaque"),
  "draws into caller scene through stable model instance")
ok(drawCalls[1].options.camera.viewProjection==context.viewProjection
  and drawCalls[1].options.shadow.map=="map"
  and drawCalls[1].options.pass=="opaque","forwards voxel scene contract")

ok(StadiumModels.drawShadow(placements.player,identity()),
  "casts through public model shadow API")
local light=shadowCalls[1].options.lightViewProjection
ok(light[11]==2 and light[12]==-1,
  "adapts Battle Art unit-depth projection to Stadium clip depth")

battle.animName="THUNDERBOLT"
battle.animAttackerIsPlayer=true
battle.animPlaying=true
StadiumModels.update(battle,0.1)
ok(created[1].moves[#created[1].moves].move==85,
  "routes host move timing without owning battle mechanics")

local oldPlayer=created[1]
battle.player={mon={species=1}}
battle.animPlaying=false
StadiumModels.update(battle,0.1)
ok(oldPlayer.released and #created==3 and created[3].species==1,
  "switches release and replace only the changed side")

battle.enemy={mon={species=99}}
StadiumModels.update(battle,0.1)
textures.enemy={canvas=true}
placements=StadiumModels.placements(arena,3,textures,battle)
ok(not placements.enemy,"missing model leaves its card as per-side fallback")

created[3].drawFails=true
placements=StadiumModels.placements(arena,3,textures,battle)
ok(not StadiumModels.draw(placements.player,context,"opaque"),
  "draw failure is reported for same-frame card fallback")

providerEnabled=false
ok(not StadiumModels.update(battle,0.1),"disabled provider fails open")
local status=StadiumModels.status()
ok(not status.active and not status.sides.player and not status.sides.enemy,
  "disabled provider releases owned instances")

providerEnabled=true
providerBattleEnabled=false
ok(not StadiumModels.active(),
  "turning Stadium battle off restores Battle Art sprites")

print(("%d checks passed (Battle Art Stadium model bridge)"):format(checks))
