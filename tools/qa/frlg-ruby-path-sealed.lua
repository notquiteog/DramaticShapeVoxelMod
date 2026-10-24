-- Closed source state only: original rock, native blocked approach, no reveal.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL')));local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C=V.require('Gen3Integration');local Map,P=require('src.core.game3.map'),require('src.core.game3.player')
 game:_handleBootAction({action='new_game',start={map='FR_MT_EMBER_EXTERIOR',x=42,y=41,facing='up'}})
 local F=require('src.core.game3.scripting.flags');local store=assert(require('src.core.game3.scripting.space').store)
 F.setVar(store,nil,0x4076,0);F.setFlag(store,nil,137,true) -- own unoccluded sealed-state QA fixture
 assert(Map.load(nil,game,'FR_MT_EMBER_EXTERIOR',{x=42,y=41,facing='up'}));U.wait(90)
 require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss()
 local def=Map.currentDef();local c=def.midLayout:cellAt(42,39);assert(c.mid==857 and c.coll==7)
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day');C.yaw=0;C.pitch=.12;C.setLevel(3,game);U.wait(180)
 assert(C.active and C.recovery.failures==0);assert(U.shot(game,os.getenv('SHOT_DIR')..'/overview.png'))
 C.setLevel(6,game);U.wait(30);assert(U.shot(game,os.getenv('SHOT_DIR')..'/front.png'))
 C.setLevel(3,game);P.reset(42,40,'up');game.input:reset();U.hold(game,'up',40);game.input:reset();U.wait(25)
 assert(Map.currentDef()==def and P.cellX==42 and P.cellY==40,'native seal was bypassed')
 c=def.midLayout:cellAt(42,39);assert(c.mid==857 and c.coll==7);assert(#game.mods.errors==0)
 print('[RUBY PATH SEALED] PASS',c.mid,c.coll)
end
