return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local hoenn=require('src.core.GameVersion').get()=='emerald'
 game:_handleBootAction({action='new_game',start={map=hoenn and 'EM_MOSSDEEP_CITY'or'FR_LAVENDER_TOWN',x=hoenn and 22 or 18,y=hoenn and 18 or 16,facing='up'}})
 require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end
 V.require('Gen3Integration').setLevel(7,game);V.require('LegendaryVisualsPreset').setting:setIndex(2,game)
 local C=V.require('CommunityVisuals');C.walls:setIndex(2,game)
 local M=V.require('NativeMasonry');local append=M.append;local target;local count=0
 M.append=function(record,c,d,low,high)
  local yes=append(record,c,d,low,high)
  if yes then count=count+1;if not target and high-low>=8 then target={c.cx*16+8+d[1]*8,(low+high)/2,c.cy*16+8+d[2]*8,d[1],d[2]}end end
  return yes
 end
 V.require('Gen3Scene').invalidate();U.wait(220);if not target then print('[SKIP native masonry] map has no qualifying raised retaining faces');M.append=append;love.event.quit();return end
 local R=V.require('Voxel3D');local project=R.viewProjection
 R.viewProjection=function(cx,cz,w,h)
  R.camera={eye={target[1]+target[4]*58,target[2]+10,target[3]+target[5]*58},focus={target[1],target[2],target[3]},up={0,1,0},fov=math.rad(55),curve=0}
  return project(target[1],target[3],w,h)
 end
 for index=1,4 do C.masonry:setIndex(index,game);V.require('TreePresentation').changed('communityMasonry');U.wait(180)
  assert(V.require('Gen3Integration').active);U.shot(game,dir..'/masonry-'..index..'.png')
 end
 C.walls:setIndex(1,game);V.require('TreePresentation').changed('communityWalls');U.wait(180);U.shot(game,dir..'/native.png')
 R.viewProjection=project;M.append=append;print('[PASS native wall and four masonry palettes]',count,unpack(target));love.event.quit()
end
