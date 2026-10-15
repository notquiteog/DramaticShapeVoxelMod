-- Production scene review at arbitrary native cells (Gen3 only).
--   POKEPORT_DRIVER=tools/qa/gen3-scene-review.lua SHOT_DIR=<dir>
--   QA_SPOTS="MAP,x,y[,radius][;MAP,x,y...]"  QA_TIME=day|night
--   QA_FOCUS_HEIGHT=42 optionally centers orbit views on a tall building.
--   QA_RENDER_DISTANCE=64 uses the public FAR setting for clear rear views.
-- For each spot: loads the map, parks the player on the nearest native
-- walkable/dry/non-warp cell, then captures four orbit views and one low
-- eye-height view through the production renderer with a QA-only inspection
-- camera. Also logs the active scene's cliff/tree/civic counts. QA identities only.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'refusing a non-QA profile')
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local GV=require('src.core.GameVersion').get()
 local prefix=GV=='ruby' and 'RU_' or GV=='sapphire' and 'SA_' or GV=='emerald' and 'EM_' or 'FR_'
 local update=game.update;game.update=function(self,dt) self.input:reset();return require('src.mods.Runtime').call('core.update',update,self,dt)end
 love.window.setMode(1280,720,{resizable=true})
 game:_handleBootAction({action='new_game',start={map=prefix=='FR_' and 'FR_PALLET_TOWN' or prefix..'OLDALE_TOWN',x=10,y=9,facing='down'}})
 U.wait(10)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 V.require('DayNight').setting:sync(os.getenv('QA_TIME') or 'day');V.require('RenderDistance').setting:sync(tonumber(os.getenv('QA_RENDER_DISTANCE'))or 32)
 local Map=require('src.core.game3.map');local Collision=require('src.core.game3.collision')
 local R=V.require('Voxel3D');local project=R.viewProjection;local inspection
 R.viewProjection=function(cx,cy,w,h)
  if inspection then R.camera=inspection;cx,cy=inspection.focus[1],inspection.focus[3] end
  return project(cx,cy,w,h)
 end
 local spots={}
 for spec in assert(os.getenv('QA_SPOTS')):gmatch('[^;]+')do
  local id,x,y,r=spec:match('^%s*([%w_]+),(%d+),(%d+),?(%d*)')
  spots[#spots+1]={id=id,x=tonumber(x),y=tonumber(y),r=tonumber(r) or 6}
 end
 for _,s in ipairs(spots)do
  inspection=nil
  local def=assert(game.data.maps[s.id],'missing map '..s.id)
  assert(Map.load(nil,game,s.id,{x=s.x,y=s.y,facing='up'}))
  -- Current native engines show a forest/location preview over the field.
  -- These are QA teleports: dismiss through public APIs before judging art.
  local Preview=require('src.ui.game3.map_preview_screen')
  Preview.dismiss()
  require('src.ui.game3.map_name_popup').dismiss()
  local best,pos
  for yy=0,def.height-1 do for xx=0,def.width-1 do
   if Collision.isWalkable(xx,yy) and not Collision.warpAt(xx,yy) and not Collision.isWater(xx,yy)then
    local d=(xx-s.x)^2+(yy-s.y-s.r)^2;if not best or d<best then best,pos=d,{xx,yy}end
   end
  end end
  require('src.core.game3.player').reset(pos[1],pos[2],'up')
  game.mods.exports.BATTLE_ART_VOXEL_FORK.firered.camera.setLevel(7,game);U.wait(tonumber(os.getenv('QA_SETTLE')) or 40)
  for _=1,400 do if game.mods.exports.BATTLE_ART_VOXEL_FORK.firered.camera.active then break end;U.wait(1)end
  U.wait(30)
  -- Moving the inspection fixture across one map can retain the preceding
  -- complete window while its replacement streams. Wait for completion,
  -- including a short provider-readiness settle, rather than capturing it.
  local Scene=V.require('Gen3Scene');local stable,last=0
  for _=1,1800 do
   U.wait(1);local stats=Scene.streaming
   if Scene.sceneDef==def and stats.started==stats.completed+stats.cancelled and stats.started==last then stable=stable+1 else stable=0 end
   last=stats.started;if stable>=8 then break end
  end
  assert(stable>=8,'inspection window still streaming')
  assert(not Preview.isActive(),'location preview obscures scene')
  assert(Map.current==s.id,'scene changed during review')
  assert(game.mods.exports.BATTLE_ART_VOXEL_FORK.firered.camera.active,'voxel camera not active')
  assert(Scene.sceneDef==def,'renderer retained a different map')
  print('[SCENE]',s.id,s.x,s.y,'player',pos[1],pos[2],'cliffs',Scene.cliffCount,'civic',Scene.civicCount,'trees',Scene.legendaryTreeCount)
  local cx,cz=s.x*16+8,s.y*16+8
  local base=Scene.groundAt and Scene.groundAt(cx,cz) or 0
  print('[CAMERA BASE]',s.id,s.x,s.y,base,'player',Scene.groundAt(pos[1]*16+8,pos[2]*16+8),'window',Scene.distance and table.concat(Scene.distance.bounds,','))
  local dist=s.r*16
  local focusHeight=tonumber(os.getenv('QA_FOCUS_HEIGHT'))or 8
  for i,d in ipairs({{0,1},{1,0},{0,-1},{-1,0}})do
   inspection={eye={cx+d[1]*dist,base+dist*.75,cz+d[2]*dist},focus={cx,base+focusHeight,cz},fov=math.rad(65),up={0,1,0},curve=0}
   U.wait(3);assert(U.shot(game,dir..('/%s_%d_%d_%d.png'):format(s.id,s.x,s.y,i)))
  end
  local px,pz=pos[1]*16+8,pos[2]*16+8
  local pb=Scene.groundAt and Scene.groundAt(px,pz) or 0
  -- Step ahead of the player billboard so the sprite never fills the view.
  local dx,dz=cx-px,cz-pz;local len=math.max(1,math.sqrt(dx*dx+dz*dz));local step=math.min(20,len*.4)
  local ex,ez=px+dx/len*step,pz+dz/len*step
  inspection={eye={ex,pb+14,ez},focus={cx,base+14,cz},fov=math.rad(70),up={0,1,0},curve=0}
  U.wait(3);assert(U.shot(game,dir..('/%s_%d_%d_eye.png'):format(s.id,s.x,s.y)))
 end
 R.viewProjection=project
 print('[SCENE REVIEW] PASS',#spots);love.event.quit()
end
