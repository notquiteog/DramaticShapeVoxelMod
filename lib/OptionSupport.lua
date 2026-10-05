-- Auditable source-consumer inventory. "implemented" means an adapter reads
-- the choice on a live render/update path; it does NOT claim device/gameplay QA.
-- "partial" keeps the limitation explicit even when the menu is editable.
local V=...
local M={}
local support={ [1]={},[2]={},[3]={} }
local function set(gen,keys,status,consumer,detail)
 for key in keys:gmatch('%S+')do
  support[gen][key]={status=status,consumer=consumer,detail=detail}
 end
end
for _,row in ipairs(V.require('SettingsCatalog'))do
 support[1][row.key]={status='implemented',consumer='lib/'..row.module..'.lua',detail='Gen1 source consumer; device validation is separate.'}
 for gen=2,3 do
  support[gen][row.key]={status='missing',consumer=false,detail='No complete native generation adapter audited for this option.'}
 end
end
for gen=2,3 do
 set(gen,'sceneryProps','implemented','lib/TreePresentation.lua; lib/NativeTreeArt.lua; lib/Gen2Rocks.lua; lib/Gen2VoxelRock.lua; lib/Gen3Cave.lua; lib/Gen3Outdoor.lua','Native solid rocks/bushes or source-art cutouts. Terrain/collision unchanged; actors, grass and flowers remain sprites.')
end
set(1,'fireredCamera fireredBattleStage','not_applicable',false,'Native Gen3 camera/battle settings; Gen1 uses its voxel pipeline and 3D-BTL.')
set(1,'hdTreeTrunks treeArtwork surfaceArtwork sceneryProps','not_applicable',false,'Native Gen2/3 scenery controls; Gen1 uses the Legendary scenery families.')
set(2,'fireredCamera fireredBattleStage','not_applicable',false,'Native Gen3 settings; Gen2 uses its voxel pipeline and 3D-BTL.')
set(2,'aa curve daytime grid renderDistance shadowQuality water worldFill tiltshift','implemented','lib/VoxelScene.lua; lib/Voxel3D.lua; main.lua','Shared GB render pipeline, including native Gen2 tile atlas.')
set(2,'invertY','implemented','lib/FirstPerson.lua; lib/Gen2CameraWalk.lua','Native Gen2 camera-relative walking and shared look input.')
set(2,'hdTreeTrunks treeArtwork surfaceArtwork','implemented','lib/TreePresentation.lua; lib/ChunkMesher.lua','Native scenery rebuilds on option changes.')
set(2,'battleArt frontAnimatedSet backAnimatedSet playerView duplicateFix frontFlip spriteLight battles','implemented','lib/OverworldBattle.lua; lib/Gen2Staged.lua; lib/BattleScene.lua','Native Gen2 battle side adapter feeds the shared stage and UI path.')
set(2,'arenaFill backdropOffset bossBg','partial','lib/BattleScene.lua; lib/Gen6Backdrop.lua; lib/BossBackdrop.lua','Shared stage consumes the controls; generation-specific location/boss routing is incomplete.')
set(2,'spritePack full_body_backs crystalFront crystalTrainers crystalPlayerSprite crystalBattlePic crystalAnimations','implemented','lib/CrystalSprites.lua; lib/Crystal/main.lua','Integrated native Crystal provider, selected at restart.')
set(2,'modernBattleUI battleUi hudColor textboxFill','implemented','lib/Gen2BattleUI.lua; lib/Gen2Battle.lua','Native singles status/commands, visibility, textbox fill and ink. Native doubles companions retain their renderer and public preference.')
set(2,'hudScale','partial','lib/Gen2BattleUI.lua','Changes the modern HUD scale; original native HUD scale is still engine-owned.')
set(2,'standingTrainer','provider','lib/OverworldBattle.lua','Requires a compatible character renderer; native Gen2 trainer staging still needs a dedicated adapter.')
set(2,'backPlacement','implemented','lib/Gen2Staged.lua; lib/Gen2Battle.lua','OG UI restores the native player slot; AUTO/WORLD keep the player on the stage.')
set(2,'ramPrecacheMb','implemented','lib/RamPrecache.lua; lib/VoxelMeshDisk.lua','Shared GB mesh cache budget and persistence path.')
set(2,'interfaceSprites interfaceScaling','partial','lib/Gen2InterfaceArt.lua; lib/NativeInterfaceArt.lua; lib/Crystal/main.lua','Native Summary/Dex selected frames and FIT/FULL consume these controls. Eggs/Unown keep native art, Crystal retains ownership; other screens need dedicated coverage.')
set(2,'playerArtSet playerAnimatedSet trainerArtSet','implemented','lib/NativeBattleArt.lua; lib/AnimatedBattleArt.lua','Native trainer scenes consume static/animated selected art and real slide progress, with Crystal pack and missing-art fallback retained.')
set(2,'communitySky','implemented','lib/Sky.lua','Shared sky renderer consumes the selected sky style.')
set(2,'legendaryVisualsMode communityTrees communityTreeDetail communityGrass communityCutTrees communitySigns communityCityGround communityRoads communityWalls communityCourtyards communityPillars communityMasonry communityCaves communityCaveDetails communityCaveSound communityTower communityTowerWall communityForest communityCasino communityPrizeRoom communityTunnels communityRocket communityElevator atmos towerDetails towerFog towerFogSpeed towerFogThickness','partial','lib/CommunityVisuals.lua; lib/ChunkMesher.lua','Shared profiles exist, but complete native Gen2 map-family parity is not established.')
set(3,'fireredCamera','implemented','lib/Gen3Integration.lua; lib/Gen3Scene.lua','Native field camera and rotated directional intent.')
set(3,'battles','implemented','lib/Gen3Battle.lua','Shared 3D-BTL control, preserving native actors/attacks/UI and legacy FireRed OFF preferences.')
set(3,'fireredBattleStage','alias','lib/Gen3Battle.lua','Legacy saved key, migrated to the shared 3D-BTL control.')
set(3,'aa daytime worldFill communitySky tiltshift','implemented','lib/Gen3SceneOptions.lua; lib/Gen3Scene.lua','Native scene supersampling, day clock/light/sky, underlay and postprocess.')
set(3,'invertY','implemented','lib/Gen3Integration.lua: look','Shared preference changes mouse and right-stick vertical look.')
set(3,'curve grid shadowQuality','implemented','lib/Voxel3D.lua; lib/ShadowMap.lua','Native scene uses the shared geometry and shadow passes.')
set(3,'renderDistance','implemented','lib/Gen3Scene.lua: prepare','Native world refresh/build budget and horizon fade.')
set(3,'water','implemented','lib/WaterSurfacePass.lua; lib/Gen3Scene.lua','Native surfable cells use shared FULL/SKY/OFF shaders with flat fallback.')
set(3,'hdTreeTrunks treeArtwork','implemented','lib/Gen3Scene.lua; lib/TreePresentation.lua','Native tree material/geometry selection with live rebuild.')
set(3,'battleUi textboxFill','implemented','lib/Gen3BattleOptions.lua; lib/Gen3BattleHud.lua','Staged native HUD/text visibility, panel fill and matching ink; unrelated menus keep native ownership.')
set(3,'hudColor hudScale','partial','lib/Gen3BattleOptions.lua; lib/Gen3BattleHud.lua','Live modern status-card palette/scale; original native HUD art remains engine-owned.')
set(3,'modernBattleUI','implemented','lib/Gen3BattleHud.lua','Native battle status cards and command overlay.')
set(3,'battleArt frontAnimatedSet backAnimatedSet playerView duplicateFix frontFlip','implemented','lib/NativeBattleArt.lua; lib/BattleArt.lua','Native displayed-battler read seam retains PID/OT/shiny identity for all four slots; unusual forms/substitutes/ghosts keep native fallback.')
set(3,'backPlacement','implemented','lib/Gen3BattleActors.lua','AUTO/WORLD project allied Pokemon; OG UI retains both native allied slots without duplicate world cards. Trainers retain world placement.')
set(3,'arenaFill','partial','lib/Gen3BattleBackdrop.lua; lib/Gen3Scene.lua','WHITE/GEN6/PNG and native location routing; missing image fails open. BLUE still needs a compatible Stadium provider.')
set(3,'backdropOffset bossBg','implemented','lib/Gen3BattleBackdrop.lua; lib/Gen3Scene.lua','Native location/boss identity, source-pixel crop and frozen battle day phase, using installed optional art.')
set(3,'spriteLight','implemented','lib/Gen3BattleActors.lua; lib/Gen3Scene.lua','Native actor cards share world lighting, depth and cast shadows; native flashes/fades are baked into their live artwork.')
set(3,'playerArtSet playerAnimatedSet trainerArtSet','implemented','lib/Gen3TrainerArt.lua; lib/AnimatedBattleArt.lua','Selected native opponent fronts and player five-frame send-out sheets. Missing user art and scripted trainer roles retain native pictures.')
set(3,'interfaceSprites interfaceScaling','implemented','lib/NativeInterfaceArt.lua','Native Summary/Pokedex scoped draw; animation-wide FIT/FULL and mon-aware Summary shininess. Other native screens keep their own art.')
set(3,'surfaceArtwork','implemented','lib/Gen3Scene.lua; lib/Voxel3D.lua','Native-palette surface grain on scenery only; camera-stable world coordinates, distance filtering and unchanged actor/UI art.')
set(3,'communityTreeDetail','implemented','lib/NativeTreeArt.lua; lib/VoxelHull.lua','FULL/BALANCED/HANDHELD change native voxel tree resolution, with live geometry rebuild.')
for gen=2,3 do
 set(gen,'atmos communityForest','implemented','lib/NativeAtmosphere.lua; lib/ForestAtmos.lua','Native forest identity, real world dimensions, depth-aware rays and fog; shared atmosphere clock and OFF control.')
 set(gen,'towerFog towerFogSpeed towerFogThickness','implemented','lib/NativeAtmosphere.lua; lib/TowerGraveMist.lua','Native tower fog and rolling ground banks use the shared visibility, thickness and continuously integrated speed controls.')
 set(gen,'communityCaves communityCaveDetails communityTower towerDetails','partial','lib/NativeAtmosphere.lua','Native atmosphere controls are live; complete Gen1 specialty geometry and decorative props remain incomplete.')
end
for gen=1,3 do
 set(gen,'weather','implemented','lib/Weather.lua; lib/VoxelScene.lua; lib/BattleScene.lua; lib/Gen3Scene.lua','Optional deterministic outdoor rain/snow/fog/storms on the world canvas, below UI. Does not change battle weather rules.')
 set(gen,'spatialUpscale','implemented','lib/SpatialUpscale.lua; lib/AntiAlias.lua','Shared full-precision FSR 1 EASU/RCAS postprocess; native resolution UI. Shader availability checked; no temporal/frame generation.')
 set(gen,'stadiumCircle','provider','lib/StadiumBackground.lua','Requires the optional compatible Stadium scene provider; no provider means no consumer.')
end
for gen=1,3 do
 set(gen,'modernBattleUI battleUi hudColor textboxFill','provider','lib/ModernBattleUI.lua; lib/UiBackplates.lua','Saved keys retained. Styling is opt-in through optional Modern Pokemon UI; absent/disabled provider preserves native UI. The world renderer needs no UI companion.')
end
set(2,'weather spatialUpscale','implemented','lib/Weather.lua; lib/SpatialUpscale.lua; lib/AntiAlias.lua; lib/VoxelScene.lua; main.lua','Shared GB world pipeline, update clock and postprocess, including Crystal.')
set(2,'modernBattleUI battleUi hudColor textboxFill','provider','lib/ModernBattleUI.lua; lib/Gen2BattleUI.lua','Like Gen1, optional Modern Pokemon UI owns styling. Without a provider the native UI remains unchanged.')
function M.inventory(gen)
 local out={}
 for _,row in ipairs(V.require('SettingsCatalog'))do
  local state=assert(support[gen] and support[gen][row.key],'unknown option support')
  out[#out+1]={key=row.key,label=row.label,module=row.module,generation=gen,
   status=state.status,consumer=state.consumer,detail=state.detail,verification='source audit'}
 end
 return out
end
function M.rows(schema,gen)
 local out,seen={},{}
 for _,row in ipairs(schema)do out[#out+1]=row;seen[row.key]=true end
 for _,row in ipairs(M.inventory(gen))do
  if not seen[row.key] and row.key=='tiltshift' and gen<3 then
   out[#out+1]={key=row.key,label=row.label,pipeline='tiltshift'}
  elseif not seen[row.key] and row.status~='alias' then
   local labels={implemented='SUPPORTED',partial='PARTIAL',missing='UNAVAILABLE',
    not_applicable='OTHER ENGINE',provider='PROVIDER'}
   local label=row.key=='tiltshift' and gen<3 and 'PIPELINE' or labels[row.status]
   out[#out+1]={key=row.key,label=row.label,type='choice',readOnly=true,
    supportOnly=true,unavailable=label,help=row.detail}
  end
 end
 return out
end
return M
