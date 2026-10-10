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
 game.mods.modOptions.DRAMATIC_SKY_RIDE=game.mods.modOptions.DRAMATIC_SKY_RIDE or{}
 game.mods.modOptions.DRAMATIC_SKY_RIDE.settings_view='advanced';game.mods.modOptions.DRAMATIC_SKY_RIDE.size_overrides='edit'
 local seen={}
 local wildLabels={CONTROL='follow_control',TRAIL='trainer_trail',FOLLOWERS='follower_count',
 ['SHOW WILD MONS']='enabled',['SPAWN AMT']='spawn_density',['RANDOM ENC']='random_encounters',
 ['WATER MONS']='water_spawns',CAVE='cave_spawns',['GFX STYLE']='sprite_style',
 ['SPRITE FADE']='sprite_fade',['TOWN POKEMON']='town_pokemon',GRASS='pokemon_grass_render_mode',
 SILHOUETTE='wild_silhouettes',['OW CATCH']='overworld_catching',['CATCH KEY']='catch_throw_key',
 ['BALL SWITCH']='catch_cycle_key',['CATCH COMBO']='catch_throw_combo',['SWITCH COMBO']='catch_cycle_combo',
 ['CATCH HUD']='catch_hud_size',['IDLE MONS']='enable_idle',['ROAM MONS']='enable_wander',
 ['CHASE MONS']='enable_aggressive',['HIDDEN MONS']='enable_hidden',['DEV OVERLAY']='dev_overlay'}
 local function collect(rows,ctx)
  for _,r in ipairs(type(rows)=="table" and rows or{})do if r.id then seen[r.id]=true end end
 end
 if gen==3 then
  local Menu=require((ver=='ruby'or ver=='sapphire')and'src.ui.game3.rs.option_menu'or ver=='emerald'and'src.ui.game3.rse.option_menu'or'src.ui.game3.option_menu')
  Menu.show({game=game,session=game.session});U.wait(40)
  local function pages()return Menu._pages or Menu._st.pages end
  local function visit(depth)
   assert(depth<6,'settings recursion')
   local pp=pages();local page=pp[#pp];collect(page.rows)
   for i,r in ipairs(page.rows)do
    if r.group and r.activate and type(r.id)=='string'and r.id:find(':',1,true)then
     page.index=i;local n=#pp;r.activate();if #pp>n then visit(depth+1);while #pp>n do table.remove(pp)end end
    end
   end
  end
  visit(0)
 else
  local Menu=require(gen==2 and 'src.ui.gen2.OptionsMenu'or'src.ui.OptionsMenu')
  local menu=Menu.new(game,{options=game.save and game.save.options or game.options});game.stack:push(menu)
  local function visit(page,depth)
   assert(depth<6,'settings recursion');local rows=page.view or page.rows;collect(page.rows);collect(rows)
   for _,item in ipairs(page.items or{})do
    local key=wildLabels[item.label]
    if key and type(item.apply)=='function' and item.choices then
     seen['overworld_wild_spawns:'..key]=true
          local original=item.current
     local other
     for _,choice in ipairs(item.choices)do if choice.value~=original then other=choice.value;break end end
     if other~=nil then
      item.apply(other)
      assert(game.mods.modOptions.overworld_wild_spawns[key]==other,'native Wilds apply '..key)
      item.apply(original)
      assert(game.mods.modOptions.overworld_wild_spawns[key]==original,'native Wilds restore '..key)
      print('[native Wilds change/restore]',key)
      while game.stack:top()~=page do assert(game.stack:top(),'lost native menu');game.stack:pop()end
     end
    end
   end
   for _,r in ipairs(type(rows)=="table" and rows or{})do
    if r.activate and type(r.id)=='string'and (r.id:find(':group:',1,true) or r.id:match('^overworld_wild_spawns:.*_open$'))then
     r.activate(game);local child=game.stack:top();if child~=page then visit(child,depth+1);game.stack:pop()end
    end
   end
  end
  visit(menu,0)
 end
 local count,missing=0,{}
 for id,schema in pairs(game.mods.optionSchemas)do
  for _,r in ipairs(schema)do
   if r.type=='toggle'or r.type=='choice'or r.type=='number'then
    count=count+1;if not seen[id..':'..r.key]then missing[#missing+1]=id..':'..r.key end
   end
  end
 end
 assert(#missing==0,'native settings schema rows missing: '..table.concat(missing,','))
 print('[settings row inventory]',ver,count,#missing)
 for _,id in ipairs(missing)do print('[missing native row]',id)end
 U.wait(2);assert(U.shot(game,os.getenv('SHOT_DIR')..'/all-settings.png'))
 love.event.quit()
end
