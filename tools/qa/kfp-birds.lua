return function(game)
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'));local Ver=require('src.core.GameVersion');local gen=Ver.generation()
 assert(love.filesystem.getIdentity():match('%-qa$'))
 if gen==3 then
  game:_handleBootAction({action='new_game',start={map='EM_OLDALE_TOWN',x=10,y=9,facing='down'}})
 elseif gen==2 then game.world.trySceneScript=function()return false end;game.stack:clear();assert(game.world:setMap('NEW_BARK_TOWN',7,8,'down'))
 else U.teleport(game,'PALLET_TOWN',9,8,'down')end
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK.lib);local K=V.require('KantoFirstPerson');local R=V.require('Voxel3D')
 if gen==3 then V.require('Gen3Integration').setLevel(6,game)else
  local P=require('src.render.Pipelines');for i=0,P.maxLevel('voxel')do if P.levelLabel('voxel',i)=='1ST'then P.setLevel('voxel',i)end end
 end
 local project=R.viewProjection
 R.viewProjection=function(cx,cy,w,h)R.camera={eye={cx,22,cy},focus={cx,170,cy-150},fov=math.rad(68),up={0,1,0},curve=0};return project(cx,cy,w,h)end
 K.bindGame(game);K.birds:sync(true);K.sky:sync(false);K.aircraft:sync(false);V.require('DayNight').setting:sync('day')
 for i=1,180 do U.wait(1);if (K.status().__ds_sky_status or ''):match('[1-9]%d* birds')then break end end;assert(U.shot(game,dir..'/birds.png'))
 assert((K.status().__ds_sky_status or ''):match('[1-9]%d* birds'),'no airborne native birds: '..tostring(K.status().__ds_sky_status))
 assert(next(K.status()),'KFP never drew');for k,v in pairs(K.status())do print('KFP',k,v)end
 K.birds:sync(false);K.horizon:sync('off');K.sky:sync(false);K.aircraft:sync(false);U.wait(10);R.viewProjection=project
 print('PASS KFP backgrounds',Ver.get());love.event.quit()
end
