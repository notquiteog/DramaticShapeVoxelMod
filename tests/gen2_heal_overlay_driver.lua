return function(game)
 local U=dofile('/home/admin/Apps/Gen1Recomp/source/tests/drivers/util.lua')
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local H=V.require('Gen2HealOverlay');local P=require('src.render.Pipelines')
 local Mon=require('src.battle.gen2.Mon');local w=game.world
 local dir=assert(os.getenv('SHOT_DIR'))
 w.trySceneScript=function()return false end;w.noWildEncounters=true
 game.save.party={};for i=1,6 do game.save.party[i]=Mon.new(game.data,'CYNDAQUIL',10) end
 love.window.setMode(2560,1440,{resizable=true})
 for _,r in ipairs({{'CHERRYGROVE_POKECENTER_1F',5,3,0},{'ELMS_LAB',4,5,1}}) do
  assert(w:setMap(r[1],r[2],r[3],'up'));P.setLevel('voxel',3);U.wait(240);game.stack:clear()
  local done=false;w:startHealMachineAnim(r[4],function()done=true end)
  assert(w.healAnim and w.healMachineImage,'native healing sheet missing')
  U.wait(170);local ha=assert(w.healAnim);assert(ha.lit==6,'party balls missing')
  local pts=H.points(w,ha);assert(#pts==8)
  local found=false
  for _,f in ipairs(V.require('Structures').forMap(w.map).furniture) do
   if f.id:find('heal') then
    print('[heal bed]',r[1],f.id,f.x0,f.x1,f.z0,f.z1,f.height)
    for _,p in ipairs(pts) do if p.kind=='ball' then
     print('[heal ball]',p.x,p.h,p.z)
     assert(p.x>=f.x0 and p.x<=f.x1 and p.z>=f.z0 and p.z<=f.z1,'ball outside machine')
     assert(p.h>f.height and p.h<f.height+5,'ball above/below bed');found=true
    end end
   end
  end
  assert(found)
  assert(U.shot(game,dir..'/'..r[1]..'.png'))
  U.wait(160);assert(done and not w.healAnim,'animation never finished')
 end
 print('[heal] PASS native six-ball layout, horizontal bed alignment, completion')
 love.event.quit()
end
