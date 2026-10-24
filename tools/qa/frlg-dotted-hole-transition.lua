-- Run the original compiled door script in-place, without a map reload.
return function(game)
 local U=dofile(assert(os.getenv('QA_UTIL')));local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local C,S=V.require('Gen3Integration'),V.require('Gen3Scene')
 local Map=require('src.core.game3.map');local F,Space=require('src.core.game3.scripting.flags'),require('src.core.game3.scripting.space');local D=V.require('Gen3DottedHoleEntrance');local prepare=D.prepare;local closed,opened=false,false
 D.prepare=function(cells,regions)local n=prepare(cells,regions);for _,c in pairs(cells)do local p=c.caveEntrance;if p and p.group and p.group.owner==c then if p.group.open then opened=true else closed=true end end end;return n end
 game:_handleBootAction({action='new_game',start={map='FR_SIX_ISLAND_RUIN_VALLEY',x=24,y=26,facing='up'}})
 F.setFlag(Space.store,nil,F.IDS.HIDE_RUIN_VALLEY_SCIENTIST,true);F.setFlag(Space.store,nil,F.IDS.USED_CUT_ON_RUIN_VALLEY_BRAILLE,false)
 assert(Map.load(nil,game,'FR_SIX_ISLAND_RUIN_VALLEY',{x=24,y=26,facing='up'}));U.wait(90)
 require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day');C.yaw=0;C.pitch=.12;C.setLevel(3,game);U.wait(220)
 local def=Map.currentDef();local native={};for y=0,def.height-1 do for x=0,def.width-1 do local c=def.midLayout:cellAt(x,y);native[y*def.width+x]={c.mid,c.coll,c.elev}end end
 assert(closed and not opened);assert(U.shot(game,os.getenv('SHOT_DIR')..'/closed.png'))
 F.setFlag(Space.store,nil,F.IDS.USED_CUT_ON_RUIN_VALLEY_BRAILLE,true);Space.runOnLoad(def.id)
 U.wait(240);assert(Map.currentDef()==def,'door transition reloaded map');assert(opened and C.active and C.recovery.failures==0,'native edit did not refresh the open mesh')
 for y=0,def.height-1 do for x=0,def.width-1 do local c=def.midLayout:cellAt(x,y);local a=native[y*def.width+x]
  if x==24 and y==24 then assert(c.mid==856 and c.coll==113)else assert(c.mid==a[1]and c.coll==a[2]and c.elev==a[3],'original script changed unrelated native cell')end
 end end
 assert(U.shot(game,os.getenv('SHOT_DIR')..'/native-script-opened.png'));assert(#game.mods.errors==0);print('[DOTTED LIVE NATIVE SCRIPT] PASS original compiled onLoad, same map object, one native door cell, closed→open mesh refresh')
end
