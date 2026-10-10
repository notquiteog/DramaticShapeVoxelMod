return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local GV=require('src.core.GameVersion');local gen=GV.generation();local ver=GV.get()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 if gen==3 then
  game:_handleBootAction({action='new_game',start={map=({ruby='RU_LITTLEROOT_TOWN',sapphire='SA_LITTLEROOT_TOWN',emerald='EM_LITTLEROOT_TOWN'})[ver]or'FR_PALLET_TOWN',x=7,y=8,facing='down'}})
  require('src.ui.game3.map_preview_screen').reset()
  local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
  local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 elseif gen==2 then game.world.trySceneScript=function()return false end;game.stack:clear();assert(game.world:setMap('NEW_BARK_TOWN',7,8,'down'));game.world.vm=nil
 else U.teleport(game,'PALLET_TOWN',9,8,'down')end
 local before=V.require('CameraSettings').invertY:get()
 local key='BATTLE_ART_VOXEL_FORK:invertY'
 if gen==3 then
  local Menu=require((ver=='ruby'or ver=='sapphire')and'src.ui.game3.rs.option_menu'or ver=='emerald'and'src.ui.game3.rse.option_menu'or'src.ui.game3.option_menu');Menu.show({game=game,session=game.session});U.wait(40)
  local function pages()return Menu._pages or Menu._st.pages end
  local function confirm()if Menu.confirm then Menu.confirm()else Menu.handleInput({wasPressed=function(_,k)return k=="a"end})end end
  local function adjust(d)if Menu.adjust then Menu.adjust(d)else Menu.handleInput({wasPressed=function(_,k)return k==(d==1 and "right"or"left")end})end end
  local function open(id)
   local p=pages()[#pages()];for i,r in ipairs(p.rows)do if r.id==id then p.index=i;confirm();return end end;error('missing '..id)
  end
  open('BATTLE_ART_VOXEL_FORK:settings');open('BATTLE_ART_VOXEL_FORK:group:world')
  local page=pages()[#pages()];local found
  for i,r in ipairs(page.rows)do if r.id==key then page.index=i;found=r end end;assert(found)
  adjust(1);assert(V.require('CameraSettings').invertY:get()~=before,'live native look ignored option')
  U.wait(8);U.shot(game,os.getenv('SHOT_DIR')..'/world-options.png')
  if ver=='ruby'or ver=='sapphire'then U.wait(120);U.shot(game,os.getenv('SHOT_DIR')..'/world-options-scroll.png')end
  adjust(-1);Menu.close()
 else
  local Menu=require(gen==2 and 'src.ui.gen2.OptionsMenu'or'src.ui.OptionsMenu');local menu=Menu.new(game,{options=game.save and game.save.options or game.options});game.stack:push(menu)
  local group
  for _,r in ipairs(menu.view or menu.rows)do if r.id=='BATTLE_ART_VOXEL_FORK:group:world'then group=r end end
  assert(group,'missing GB WORLD category');group.activate(game)
  local page=game.stack:top();assert(page.sub==true or gen==1,'Crystal category reopened root');assert(#(page.view or page.rows)<20,'submenu contains root rows');local found
  for i,r in ipairs(page.view or page.rows)do if r.id==key then page.index=i;found=r end end;assert(found)
  found.step(game,1);assert(V.require('CameraSettings').invertY:get()~=before,'live GB look ignored option')
  U.wait(8);U.shot(game,os.getenv('SHOT_DIR')..'/world-options.png');found.step(game,-1)
 end
 assert(V.require('CameraSettings').invertY:get()==before)
 print('[parity options PASS]',ver,'WORLD navigation, live inversion, restore');love.event.quit()
end
