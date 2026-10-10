return function(game)
 local U=dofile('tests/drivers/util.lua');local role=assert(os.getenv('QA_ROLE'));local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local version=require('src.core.GameVersion').get();local prefix=version=='ruby'and'RU_'or version=='sapphire'and'SA_'or'EM_'
 local map=(version=='firered'or version=='leafgreen')and'FR_ROUTE_1'or prefix..'ROUTE101'
 local gbaKanto=version=='firered'or version=='leafgreen'
 local hx,gx,ypos=gbaKanto and 9 or 7,gbaKanto and 8 or 6,gbaKanto and 12 or 8
 game:_handleBootAction({action='new_game',start={map=map,x=role=='host'and hx or gx,y=ypos,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()

 for _,m in ipairs(game.mods.loaded)do assert(m.manifest.id=='double_battles','companion enabled')end
 local Party=require('src.core.game3.party');local PK=require('src.core.game3.pokemon')
 game.session.party={};for i=1,2 do assert(Party.giveMon(game.session,PK.speciesFromName('PIKACHU'),40));game.session.party[i].moves={84};game.session.party[i].pp={30};game.session.party[i].maxPp={30} end
 local o=game.mods.modOptions.double_battles or{};game.mods.modOptions.double_battles=o;o.wild_doubles='always';o.your_side='pair'
 local Enc=require('src.core.game3.encounters');local Map=require('src.core.game3.map')
 U.wait(90)
 local foe
 for i=1,1000 do foe=Enc.onStep(Map.current,gbaKanto and'grass'or'land');if foe then break end end
 assert(foe,'native encounter roll unavailable')
 assert(require('src.core.game3.battle_bridge').startWild(require('src.core.game3.runtime')._mod,game,foe))
 local B=require('src.core.game3.battle');local Ui=require('src.core.game3.battle.ui')
 local seen=false;local damaged=false;local initial={}
 for i=1,6000 do
  local st=B.getState()
  if st and st.double then
   seen=true
   for _,id in ipairs({1,3})do local m=st.battlers and st.battlers[id]and st.battlers[id].mon
    if m then if not initial[id]then initial[id]=m.hp elseif m.hp<initial[id]then damaged=true end end
   end
  end
  if seen and game.phase=='field'and not B._phase then break end
  if seen and Ui._mode=='menu'and not initial.shot then initial.shot=true;U.shot(game,dir..'/double.png')end
  U.tap(game,'a');U.wait(1)
 end
 assert(seen and initial[1]and initial[3],'native four-battler double missing')
 assert(damaged,'enemy never lost HP')
 assert(game.phase=='field'and not B._phase,'native wild double did not return')
 assert(U.shot(game,dir..'/returned.png'));print('[PASS standalone native organic double]',version)
 love.event.quit()
end
