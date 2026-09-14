-- Disposable imported-Crystal profile only; exercise the actual live options
-- row, full scene rebuilding, HUD choice and source-map preservation.
return function(game)
 local U=dofile('tests/drivers/util.lua')
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local P=require('src.render.Pipelines')
 local visual=V.require('CommunityVisuals')
 local mesher=V.require('ChunkMesher')
 local voxel=V.require('VoxelState')
 local structures=V.require('Structures')
 local wild=game.mods.exports.overworld_wild_spawns
 local dir=assert(os.getenv('SHOT_DIR'))
 if os.getenv('QA_2K')=='1' then love.window.setMode(2560,1440,{resizable=true}) end
 game.world.trySceneScript=function()return false end
 game.world.rollEncounter=function()return nil end
 assert(game.world:setMap('ROUTE_29',12,6,'down'))
 local map=game.world.map
 local original={}
 for cy=0,map.heightCells-1 do for cx=0,map.widthCells-1 do
  original[#original+1]=map:cellCollision(cx,cy)
 end end
 if os.getenv('QA_CART_HUD')=='1' then
  assert(game.mods.modOptions.overworld_wild_spawns.catch_hud_size==0,'cart must hide ball HUD')
 else
  game.mods.modOptions.overworld_wild_spawns.catch_hud_size=0
 end
 local config=wild.lib.require('config')
 assert(not config.catchHudEnabled(wild.logic.mod),'ball HUD still enabled')
 P.setLevel('voxel',3);P.setLevel('depth_of_field',0)
 V.require('DayNight').setting:sync('day')
 -- Prevent this visual QA from storing test choices in the disposable profile.
 local write=game.writeOptions;game.writeOptions=function()end
 visual.crystalStyle:sync('hd2d')
 local row=visual.crystalStyle:row()
 for _,style in ipairs({'source','depth','hd2d','source','depth'}) do
  assert(row.step(game,1))
  assert(visual.crystalStyle:get()==style,'live row selected wrong style')
  assert(game.mods.modOptions.BATTLE_ART_VOXEL_FORK.crystalStyle==style,'loader option stale')
  U.wait(5)
  for _=1,2400 do if mesher.pending()==0 and voxel.ready then break end U.wait(1) end
  assert(mesher.pending()==0 and voxel.ready,'style rebuild failed')
  U.wait(20)
  local S=structures.forMap(map)
  local grass=0
  for k,s in pairs(S.shapeAt) do
   if s.art=='grass' then
    if S.skip[k] and S.ground[k]==5 then grass=grass+1 end
   end
  end
  if style=='depth' then assert(grass>0,'raised grass retained flat ROM tuft art') end
  local n=0
  for cy=0,map.heightCells-1 do for cx=0,map.widthCells-1 do
   n=n+1;assert(map:cellCollision(cx,cy)==original[n],'presentation changed collision')
  end end
  assert(U.shot(game,dir..'/'..style..'.png'))
 end
 game.writeOptions=write
 P.setLevel('hd2d_light',2);P.setLevel('depth_of_field',1)
 U.wait(12)
 assert(V.require('SceneFinish').lastApplied,'HD-2D light shader did not run')
 assert(V.require('DepthOfField').lastApplied,'depth-of-field shader did not run')
 assert(U.shot(game,dir..'/depth_optional_shaders.png'))
 P.setLevel('hd2d_light',0);P.setLevel('depth_of_field',0)
 print('[depth styles] PASS: live cycling, scene rebuild, grass underlay, collision and hidden ball HUD')
 love.event.quit()
end
