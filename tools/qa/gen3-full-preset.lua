return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'isolated QA profile required')
 local U=dofile('tests/drivers/util.lua');local version=require('src.core.GameVersion').get()
 local update=game.update;game.update=function(self,dt)self.input:reset();return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=version=='emerald'and'EM_LITTLEROOT_TOWN'or'FR_PALLET_TOWN',x=7,y=8,facing='down'}})
 require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local C=V.require('Gen3Integration');local before=C.level
 local settings={V.require('Gen3SceneOptions').tilt,V.require('WorldCurve').setting,V.require('Water').setting,
  V.require('Gen3Battle').setting,V.require('BattleArt').viewSetting,V.require('DayNight').setting}
 local saved={};for i,s in ipairs(settings)do saved[i]=s:read()end
 C.setLevel(3,game);U.wait(2)
 settings[1]:setIndex(1,game);settings[4]:setIndex(2,game);settings[6]:setIndex(3,game)
 C.setLevel(1,game);U.wait(100)
 assert(settings[1]:get()==3 and settings[4]:get()==true and settings[6]:get()=='sync','FULL did not apply native preset')
 assert(settings[2]:read()==1 and settings[3]:read()==1 and settings[5]:read()==2)
 U.shot(game,os.getenv('SHOT_DIR')..'/full-preset.png')
 settings[4]:setIndex(2,game);U.wait(3);assert(settings[4]:get()==false,'FULL clobbered battle edit')
 C.setLevel(3,game);settings[6]:setIndex(3,game);U.wait(3);assert(settings[6]:get()=='night','FULL clock held after exit')
 C.setLevel(before,game);U.wait(2)
 for i,s in ipairs(settings)do s:setIndex(saved[i],game)end
 assert(not C.lastError,tostring(C.lastError))
 print('[PASS FULL]',version,'entry, setting consumers, edit retention, exit and preference restore');love.event.quit()
end
