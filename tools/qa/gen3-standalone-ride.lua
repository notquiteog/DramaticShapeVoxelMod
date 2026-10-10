return function(game)
 local U=dofile('tests/drivers/util.lua');local role=assert(os.getenv('QA_ROLE'));local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local version=require('src.core.GameVersion').get();local prefix=version=='ruby'and'RU_'or version=='sapphire'and'SA_'or'EM_'
 local map=(version=='firered'or version=='leafgreen')and'FR_PALLET_TOWN'or prefix..'OLDALE_TOWN'
 local gbaKanto=version=='firered'or version=='leafgreen'
 local hx,gx,ypos=gbaKanto and 9 or 7,gbaKanto and 8 or 6,gbaKanto and 12 or 8
 game:_handleBootAction({action='new_game',start={map=map,x=role=='host'and hx or gx,y=ypos,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local Party=require('src.core.game3.party');game.session.party={};assert(Party.giveMon(game.session,gbaKanto and 6 or require('src.core.game3.pokemon').speciesFromName('SWELLOW'),50))
 game.session.party[1].nickname=role=='host'and'HOSTMON'or'GUESTMON'
 game.session.party[1].moves={19,57,33};game.session.party[1].pp={15,15,35}
 local flags=require('src.core.game3.scripting.flags');local moves=require('src.core.game3.field_moves')
 flags.setFlag(space.store,nil,moves.badgeFlag('FLY'),true)

 for _,m in ipairs(game.mods.loaded)do assert(m.manifest.id=='DRAMATIC_SKY_RIDE','companion enabled')end
 local ex=assert(game.mods.exports.DRAMATIC_SKY_RIDE);local S=assert(ex.gen3)
 local P=require('src.core.game3.player');U.wait(180)
 local original=P.graphicsId
 game:keypressed('g','g',false);U.wait(30)
 local pose=ex.gen3Pose();assert(pose.mounted and pose.mode=='ground')
 assert(U.shot(game,dir..'/ground.png'));game:keypressed('g','g',false);assert(not ex.isMounted(),'ground shortcut failed to dismount')
 P.reset(hx,ypos,'down');U.wait(2)
 game:keypressed('h','h',false);U.wait(30)
 pose=ex.gen3Pose();assert(pose.mounted and pose.mode=='fly'and pose.height>0)
 local height=pose.height;game:keypressed('pageup','pageup',false);U.wait(20);game:keyreleased('pageup','pageup');assert(ex.currentAltitude()>height,'altitude key inactive')
 assert(U.shot(game,dir..'/flight.png'));game:keypressed('h','h',false);U.wait(5)
 assert(not ex.isMounted()and not P.freeFlying and (P.spriteYOffset or 0)==0)
 print('[PASS standalone GBA mount flight landing]',version)
 love.event.quit()
end
