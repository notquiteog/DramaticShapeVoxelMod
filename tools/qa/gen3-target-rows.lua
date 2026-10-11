-- Isolated Gen3 QA profile. Native trainer doubles are supported by the engine;
-- wild doubles remain an optional companion's separate gameplay responsibility.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 -- A user's connected controller must not steer the isolated driver or its camera.
 print('[QA] physical pads excluded',#love.joystick.getJoysticks())
 love.joystick.getJoysticks=function()return {}end;love.joystick.getJoystickCount=function()return 0 end
 for _,event in ipairs({'gamepadpressed','gamepadreleased','gamepadaxis','joystickpressed','joystickreleased','joystickaxis','joystickhat'})do
  love[event]=function()end
 end
 game.input:reset();love.window.setMode(640,480,{resizable=false});print('[QA GPU]',love.graphics.getRendererInfo())
 local R=require('src.mods.Runtime');local update=game.update
 game.update=function(self,dt)return R.call('core.update',update,self,dt)end
 local em=require('src.core.GameVersion').get()=='emerald'
 game:_handleBootAction({action='new_game',start={map=em and 'EM_OLDALE_TOWN' or 'FR_PALLET_TOWN',x=7,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK
 if V then
  V=V.lib;R.emit('mod.options_changed',{mod='BATTLE_ART_VOXEL_FORK',key='battles',value=true})
  V.require('ModernBattleUI').setting:sync(true);V.require('Gen3Integration').setLevel(0,game)
 end
 local Party=require('src.core.game3.party');game.session.name='TESTER';game.session.party={}
 assert(Party.giveMon(game.session,6,35));assert(Party.giveMon(game.session,9,35))
 for _,mon in ipairs(game.session.party)do mon.moves={33,45};mon.pp={35,40};mon.maxPp={35,40}end
 local B=require('src.core.game3.battle');local Ui=require('src.core.game3.battle.ui')
 U.wait(5)
 print("[QA] starting native double")
 assert(B.start({playerParty=game.session.party,foe={party={{species=3,level=35},{species=9,level=35}}},
  trainerClass=1,trainerClassName='TRAINER',trainerName='QA',double=true,wild=false,session=game.session}))
 local function settle(mode)
  for i=1,800 do if i%100==0 then print('[QA intro]',i,B._phase,Ui._mode)end;if B._phase=='command' and Ui._mode==mode then U.wait(3);return end;U.tap(game,'a');U.wait(2)end
  error('command not reached '..tostring(B._phase)..' '..tostring(Ui._mode))
 end
 settle('menu');assert(B._st.double and B._st.battlers[2]and B._st.battlers[3])
 U.tap(game,'a');U.wait(3);U.tap(game,'a');U.wait(3)
 assert(Ui._mode=='target'and Ui.targetCursor()==1)
 for _,step in ipairs({{'right',3},{'left',1},{'right',3},{'down',2},{'right',2},{'up',3}})do
  U.tap(game,step[1]);U.wait(3);assert(Ui.targetCursor()==step[2],step[1]..' selected '..tostring(Ui.targetCursor()))
 end
 local stage=V.require('Gen3Battle');local hud=V.require('Gen3BattleHud');local saw={}
 for i=1,64 do
  U.wait(1)
  local frame=stage.frame;local c=hud.cards[3]
  if frame and c then
   local hidden=Ui.targetHidden(3)
   if not saw[tostring(hidden)]then
    assert(U.shot(game,dir..(hidden and '/target-hidden.png'or'/target-visible.png')))
    frame=stage.frame;c=hud.cards[3]
    local head=frame:head(3,unpack(c.nativeHead));assert(head,'target card lost world projection')
    saw[tostring(hidden)]={head[1],head[2]}
   end
  end
  if saw['true']and saw['false']then break end
 end
 assert(saw['true']and saw['false'],'did not observe both target blink phases')
 assert(math.abs(saw['true'][1]-saw['false'][1])<.01 and math.abs(saw['true'][2]-saw['false'][2])<.01,'target card jumps on sprite blink')
 U.tap(game,'b');U.wait(3);assert(Ui._mode=='moves','native cancel lost')
 U.tap(game,'a');U.wait(3);U.tap(game,'a');U.wait(5)
 for i=1,90 do if Ui._mode=='menu'and Ui.activeBattler()==2 then break end;U.wait(1)end
 assert(Ui.activeBattler()==2,'partner selection missing')
 U.tap(game,'a');U.wait(3);U.tap(game,'a');U.wait(3)
 U.tap(game,'down');U.wait(3);assert(Ui.targetCursor()==0,'partner cannot select teammate')
 U.tap(game,'up');U.wait(3);assert(Ui.targetCursor()%2==1)
 U.tap(game,'a');U.wait(40)
 print('[PASS target rows and stable blink cards]',require('src.core.GameVersion').get())
 love.event.quit()
end
