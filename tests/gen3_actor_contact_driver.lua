-- Exact-archive rendered fixture for ground anchors and actor shadow contact.
-- The wrapper discards external controller input. This is not an input test.
return function(game)
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 assert(love.filesystem.getIdentity():match('%-qa$'),'isolated QA profile required')
 assert(require('src.core.Version').engine=='0.3.1')
 love.window.setMode(1600,900,{resizable=true})
 game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=9,facing='down'}})
 local ex=game.mods.exports;local V=assert(ex.BATTLE_ART_VOXEL_FORK).lib
 local C=V.require('Gen3Integration');local Day=V.require('DayNight');local Shadow=V.require('ShadowMap')
 local P=require('src.core.game3.player');local Map=require('src.core.game3.map');local Collision=require('src.core.game3.collision')
 local Sprites=require('src.core.game3.ow_sprites')
 local Wilds=assert(ex.overworld_wild_spawns,'published Wilds companion needed for HGSS follower art')
 U.wait(120)
 assert(Collision.isWalkable(10,9)and Collision.isWalkable(11,9))
 local gid=assert(Wilds.resolveGen3Sprite(1,nil,false),'native Bulbasaur art unavailable')
 -- Use the provider's exported actor registry and real public sprite getter.
 -- This stationary fixture has no party or scripted follower progression.
 local row=Wilds.gen3Actors.add(-99001,Map.current,11,9,gid)
 row.facing='down';row.customFrame=0;row.raiseY=0
 local spr=assert(Sprites.getDraw(gid))
 print('[actor fixture] Bulbasaur',gid,spr.width,spr.height,spr.frameCount,'provider groundPadding',spr.groundPadding)
 for _,phase in ipairs({{'noon',300},{'low_moon',720}})do
  Day.setting:setIndex(6,game);Day.update(0);Day.clock=phase[2]
  for _,view in ipairs({{'static',3,0,.12},{'close',7,0,.5}})do
   P.reset(10,9,'down');C.setLevel(view[2],game);C.yaw=view[3];C.pitch=view[4]
   U.wait(20)
   assert(C.active and(P.spriteYOffset or 0)==0 and row.raiseY==0,'ground fixture unexpectedly lifted')
   print('[actor fixture]',phase[1],view[1],'player gid',Sprites.playerGraphicsId(game),'offset',P.spriteYOffset or 0,'shadow slack',Shadow.slack,'sun',Shadow.KX,Shadow.KZ)
   assert(U.shot(game,dir..'/'..phase[1]..'_'..view[1]..'.png'))
  end
 end
 -- Explicit native height remains additive to the shared sprite baseline.
 row.raiseY=-12;U.wait(8);assert(row.raiseY==-12)
 assert(U.shot(game,dir..'/follower_lift12.png'))
 print('[actor contact] CAPTURED idle native player/HGSS follower noon, low moon, explicit lift; inspect PNGs')
 love.event.quit()
end
