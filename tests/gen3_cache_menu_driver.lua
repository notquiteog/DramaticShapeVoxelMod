-- Native SAVE/DROP/controller-route smoke plus actual compressed codec checks.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local U=dofile('tests/drivers/util.lua');local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local version=require('src.core.GameVersion').get()
 local start=version=='emerald'and'EM_OLDALE_TOWN'or version=='ruby'and'RU_OLDALE_TOWN'or version=='sapphire'and'SA_OLDALE_TOWN'or'FR_PALLET_TOWN'
 game:_handleBootAction({action='new_game',start={map=start,x=10,y=10,facing='up'}})
 local sp=require('src.core.game3.scripting.space');sp.runOnFrame=function()end
 local vm=sp.getVm();if vm then vm:halt(true)end
 local Msg=require('src.ui.game3.message');Msg.reset();require('src.ui.game3.map_preview_screen').reset()
 V.require('Gen3Integration').setLevel(3,game);U.wait(120)
 local Start=require('src.ui.game3.start_menu');local Choice=require('src.ui.game3.choice')
 Start.show({game=game,session=game.session});U.wait(2)
 local cursor;for i,e in ipairs(Start.ENTRIES)do if e.label=='CACHE'then cursor=i end end;assert(cursor,'no native CACHE')
 Start.cursor=cursor;U.tap(game,'a');U.wait(3);assert(Choice.active and Choice.options[1]=='SAVE','CACHE did not open native choice')
 U.shot(game,os.getenv('SHOT_DIR')..'/cache.png')
 U.tap(game,'a');U.wait(2);assert(Msg.isOpen(),'save result missing');assert(V.require('NativeGeometryCache').ramStats().dirty==0,'save left dirty records')
 for i=1,120 do if Choice.active then break end;U.tap(game,'a');U.wait(2)end
 assert(Choice.active);U.tap(game,'down');assert(Choice.cursor==2,'native directional input failed');U.tap(game,'a');U.wait(2)
 assert(Msg.isOpen() and V.require('NativeGeometryCache').ramStats().files==0,'DROP failed')
 for i=1,120 do if Choice.active then break end;U.tap(game,'a');U.wait(2)end
 U.tap(game,'b');U.wait(2);assert(Start.open and Start.cursor==cursor,'cancel did not restore start menu')
 Start.close(true);print('[PASS native CACHE]',version,'save, drop, directional/A/B and parent restoration')
 local codec=assert(loadstring(assert(V.mod:read('tools/qa/native-geometry-cache.lua'))));codec()(game)
end
