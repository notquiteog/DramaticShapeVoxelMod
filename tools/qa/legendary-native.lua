return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua')
 game:_handleBootAction({action='new_game',start={map='EM_OLDALE_TOWN',x=7,y=8,facing='down'}})
 require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local P=V.require('LegendaryVisualsPreset');local C=V.require('CommunityVisuals')
 U.wait(30)
 local mode,child=P.setting:read(),C.caves:read()
 local rows={}
 for _,r in ipairs(require('src.ui.game3.option_rows').build({game=game,session=game.session}))do rows[r.id]=r end
 local master=assert(rows['BATTLE_ART_VOXEL_FORK:legendaryVisualsMode'])
 local cave=assert(rows['BATTLE_ART_VOXEL_FORK:communityCaves'])
 for i=1,4 do if P.mode()=='full'then break end;master.step({game=game},1)end
 assert(P.mode()=='full' and C.caves:get()=='n64memory')
 assert(C.caves:read()==child,'preset overwrote custom choice')
 assert(cave.value()=='LEGENDARY VISUALS','native row reports raw value instead of effective preset: '..tostring(cave.value()))
 cave.step({game=game},1)
 assert(P.mode()=='custom','child edit did not leave preset')
 assert(game.options.modOptions.BATTLE_ART_VOXEL_FORK.legendaryVisualsMode=='custom','CUSTOM not persisted')
 C.caves:setIndex(child,game);P.setting:setIndex(mode,game);P.invalidate()
 print('[Legendary native PASS] master overlay, effective row, CUSTOM edit, persistence, restore')
 love.event.quit()
end
