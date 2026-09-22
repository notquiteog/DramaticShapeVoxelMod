return function(game)
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'));local ver=require('src.core.GameVersion').get()
 assert(love.filesystem.getIdentity()=='source-art-'..ver..'-030-qa')
 assert(require('src.core.Version').engine=='0.3.0')
 game:_handleBootAction({action='new_game',start={map='FR_OAKS_LAB',x=6,y=6,facing='up'}})
 local Menu=require('src.ui.game3.option_menu')
 local checks={{'BATTLE_ART_VOXEL_FORK','treeArtwork'},{'overworld_wild_spawns','gen3_follower'},{'double_battles','online_doubles'}}
 for _,check in ipairs(checks)do
  local id,key=check[1],check[2];assert(game.mods.exports[id],'mod not loaded '..id)
  Menu.show({game=game,session=game.session});U.wait(8)
  local root=Menu._pages[1];local found
  for i,r in ipairs(root.rows)do if r.id==id..':settings'then found=i end end
  assert(found,'missing mod options page '..id)
  root.index=found;Menu.confirm();U.wait(8)
  local page=Menu._pages[2];assert(page,'mod page did not open')
  local row
  for i,r in ipairs(page.rows)do if r.id==id..':'..key then page.index=i;row=r end end
  assert(row,'missing mod setting '..key)
  local before=row.value();Menu.adjust(1);U.wait(5);assert(row.value()~=before,'setting failed to change')
  local selected=row.value();assert(game.options.modOptions[id][key]~=nil,'option not persisted to engine options')
  if key=='treeArtwork'then assert(game.mods.exports[id].lib.require('TreePresentation').art:get()==game.options.modOptions[id][key],'renderer did not adopt setting')end
  assert(U.shot(game,dir..'/'..id..'.png'))
  Menu.close();Menu.show({game=game,session=game.session});Menu._pages[1].index=found;Menu.confirm()
  for i,r in ipairs(Menu._pages[2].rows)do if r.id==id..':'..key then
   Menu._pages[2].index=i;assert(r.value()==selected,'setting lost on reopening');Menu.adjust(-1)
  end end
  Menu.close()
 end
 print('[native options] PASS '..ver..' independent mod pages, real adjust/persist/events/reopen')
 love.event.quit()
end
