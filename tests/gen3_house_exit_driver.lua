-- Isolated real door warp regression at the user's FAR/AA/curve settings.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local U=dofile('tests/drivers/util.lua');love.window.setMode(1280,720)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C,S,R=V.require('Gen3Integration'),V.require('Gen3Scene'),V.require('Voxel3D')
 local Map=require('src.core.game3.map')
 game:_handleBootAction({action='new_game',start={map='FR_PLAYERS_HOUSE_1F',x=4,y=7,facing='down'}})
 V.require('RenderDistance').setting:sync(64);V.require('AntiAlias').setting:sync(2)
 V.require('SpatialUpscale').setting:sync(1);V.require('WorldCurve').setting:sync(1);V.require('Water').setting:sync('full');S.invalidate()
 for _,level in ipairs({3,7,6})do
  game.input:reset();assert(Map.load(nil,game,'FR_PLAYERS_HOUSE_1F',{x=4,y=7,facing='down'}))
  C.setLevel(level,game);C.yaw=0;C.pitch=0;U.wait(90)
  U.hold(game,'down',34);U.wait(180)
  assert(Map.current=='FR_PALLET_TOWN','house door did not reach Pallet')
  assert(C.active and C.level==level and C.recovery.failures==0,'selected camera lost after actual door warp')
  print('[house exit]',level,Map.current,C.active,C.recovery.failures)
  U.shot(game,os.getenv('SHOT_DIR')..'/pallet-'..level..'.png')
 end
 V.require('RenderDistance').setting:sync(false);S.invalidate();U.wait(90)
 assert(C.active and C.recovery.failures==0,'FULL distance lost camera')
 assert(math.abs(R.camera.eye[2]-9.5)<.01 and R.curveK==0,'first person above native eyes or curved ground')
 local _,y=R.project(unpack(R.camera.focus));local _,height=R.size();assert(math.abs(y/height-.5)<.01,'level eye not centered on horizon')
 -- Real GPU validation: a failed index upload must not leak a corrupt mesh.
 local mesh=assert(R.newMesh({{0,0,0,0,0,1},{1,0,0,1,0,1},{0,1,0,0,1,1}},{1,2,3}));mesh:release()
 local bad,err=R.newMesh({{0,0,0,0,0,1}},{1,2,3});assert(not bad and err,'invalid index buffer silently accepted')
 print('[house exit] PASS FAR/FULL, three cameras, native eye height, level horizon, real GPU upload error')
 love.event.quit()
end
