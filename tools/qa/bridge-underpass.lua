-- Isolated Emerald geometry fixture; does not test native bridge traversal.
return function(game)
 assert(love.filesystem.getIdentity():match("%-qa$"),"use an isolated QA profile")
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 game:_handleBootAction({action='new_game',start={map='EM_LITTLEROOT_TOWN',x=7,y=8,facing='down'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local E=V.require('Gen3Elevation');local Map=require('src.core.game3.map');local P=require('src.core.game3.player')
 local d=game.data.maps.EM_ROUTE119;Map.ensureMidLayout(game,'EM_ROUTE119',d);local f=E.field(d)
 local rows={};for _,c in pairs(f.cells)do if c.layer==15 then rows[#rows+1]=c end end;table.sort(rows,function(a,b)return a.y==b.y and a.x<b.x or a.y<b.y end)
 for _,c in ipairs(rows)do print('[bridge]',c.x,c.y,c.mid,c.behavior,c.height,c.underpass and c.underpass.layer,c.underpass and c.underpass.height)end
 local c;for _,q in ipairs(rows)do if q.underpass and q.x==18 and q.y==34 then c=q;break end end;assert(c,'no layered crossings')
 assert(Map.load(nil,game,'EM_ROUTE119',{x=c.x,y=c.y,facing='up'}));U.wait(25)
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end
 P.reset(c.x,c.y,'up');P.setVisible(true);V.require('VoxelGrid').set(false,game)
 local C=V.require('Gen3Integration');C.setLevel(3,game);P.currentElevation=c.underpass.layer;U.wait(240)
 local S=V.require('Gen3Scene');assert(S.groundAt(c.x*16+8,c.y*16+8,c.underpass.layer)==c.underpass.height)
 U.shot(game,dir..'/bridge-under-overview.png')
 C.setLevel(6,game);C.yaw=math.pi/2;C.pitch=0;U.wait(15);U.shot(game,dir..'/bridge-under-first.png')
 P.currentElevation=4;U.wait(15);U.shot(game,dir..'/bridge-deck-first.png')
 assert(not C.lastError,tostring(C.lastError));print('[bridge review PASS]');love.event.quit()
end
