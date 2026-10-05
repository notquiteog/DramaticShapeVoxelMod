return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map='FR_ROUTE_1',x=7,y=8,facing='down'}})
 require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local C=V.require('Gen3Integration');C.setLevel(3,game)
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end
 local Art=V.require('BattleArt');local Native=V.require('NativeBattleArt');local Full=V.require('NativeFullBody')
 local Crystal=V.require('NativeCrystalArt')
 local saved={};local settings={Art.setting,Art.viewSetting,Art.duplicateSetting,Full.setting,Art.backPlacementSetting,Crystal.pack}
 for i,s in ipairs(settings)do saved[i]=s:read()end
 Art.setting:setIndex(2,game);Art.viewSetting:setIndex(2,game);Art.duplicateSetting:setIndex(1,game);Full.setting:setIndex(1,game);Crystal.pack:setIndex(1,game);Art.backPlacementSetting:setIndex(2,game)
 local P=require('src.core.game3.party');game.session.party={};assert(P.giveMon(game.session,6,35))
 V.require('Gen3Battle').setting:sync(true)
 local B=require('src.core.game3.battle')
 local bodyDraws,frames=0,{};local image=Native.image
 Native.image=function(mon,back)local img,full,reference=image(mon,back);if reference==56 and not back then bodyDraws=bodyDraws+1;frames[img]=true end;return img,full,reference end
 assert(B.start({playerParty=game.session.party,foe={species=6,level=35},wild=true,session=game.session}))
 for i=1,500 do if B._phase=='command'then break end;U.tap(game,'a');U.wait(2)end
 U.wait(100);assert(bodyDraws>0,'no staged full-body draws')
 local n=0;for _ in pairs(frames)do n=n+1 end;assert(n>1,'full-body animation frozen')
 local stage=V.require('Gen3Battle');assert(stage.active and stage.frame,'stage absent');assert(stage.frame.byId[0] and stage.frame.byId[1],'actor absent '..tostring(B._phase))
 U.shot(game,dir..'/crystal-pack.png')
 Crystal.pack:setIndex(2,game);local before=bodyDraws;U.wait(30);assert(bodyDraws==before,'SELECTED ART did not relinquish consumer');U.shot(game,dir..'/selected-pack.png')
 Crystal.pack:setIndex(1,game)
 local normal=assert(Crystal.image({species=6,isShiny=false},'front'));local shiny=assert(Crystal.image({species=6,isShiny=true},'front'));assert(normal~=shiny)
 assert(not Crystal.image({species=386},'front'))
 Native.image=image;for i,s in ipairs(settings)do s:setIndex(saved[i],game)end
 print('[PASS native Crystal pack]',bodyDraws,n,'frames, OFF, single actor per side')
 love.event.quit()
end
