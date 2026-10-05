-- Isolated Emerald geometry fixture; does not test native bridge traversal.
return function(game)
 assert(love.filesystem.getIdentity():match("%-qa$"),"use an isolated QA profile")
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
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

 local Party=require('src.core.game3.party');game.session.party={};assert(Party.giveMon(game.session,6,35))
 V.require('Gen3Battle').setting:sync(true)
 local B=require('src.core.game3.battle')
 local layer=tonumber(os.getenv('BRIDGE_LAYER'))or c.underpass.layer
 P.currentElevation=layer;C.setLevel(3,game);U.wait(5)
 local BC=V.require('BattleCam');local rig=BC.rig;local cameraGround
 BC.rig=function(arena,ground,...)cameraGround=ground;return rig(arena,ground,...)end
 local expected=S.groundAt(c.x*16+8,c.y*16+8,layer)
 assert(B.start({playerParty=game.session.party,foe={species=6,level=35},wild=true,session=game.session}))
 for i=1,500 do if B._phase=='command'then break end;U.tap(game,'a');U.wait(2)end
 U.wait(20)
 local stage=V.require('Gen3Battle');local R=V.require('Voxel3D')
 assert(stage.active and stage.frame and stage.frame.points,'battle stage missing')
 assert(cameraGround==expected,'battle camera layer: expected '..tostring(expected)..' actual '..tostring(cameraGround))
 for id=0,1 do assert(stage.frame.points[id][2]==expected,'battle actor snapped to wrong layer')end
 U.shot(game,dir..'/bridge-battle.png')
 BC.rig=rig;print('[bridge battle PASS]',layer,expected,cameraGround);love.event.quit()
end
