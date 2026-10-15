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
 local seen={};local changed=false
 local inversion=V.require('CameraSettings').invertY
 local before=inversion:get()
 local function verifyStep(row,ctx)
  if row.id~='BATTLE_ART_VOXEL_FORK:invertY' or changed then return end
  assert(row.step,'native inversion row has no consumer')
  row.step(ctx,1);assert(inversion:get()~=before,'native inversion did not change')
  row.step(ctx,-1);assert(inversion:get()==before,'native inversion did not restore')
  changed=true
 end
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
    verifyStep(r,{game=game,session=game.session})
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
   for _,r in ipairs(type(rows)=="table" and rows or{})do
    verifyStep(r,game)
    if r.activate and type(r.id)=='string'and (r.id:find(':group:',1,true))then
     r.activate(game);local child=game.stack:top();if child~=page then visit(child,depth+1);game.stack:pop()end
    end
   end
  end
  visit(menu,0)
 end
 local count,missing=0,{}
 for id,schema in pairs(game.mods.optionSchemas)do
  if id=='BATTLE_ART_VOXEL_FORK'then
  for _,r in ipairs(schema)do
   if r.type=='toggle'or r.type=='choice'or r.type=='number'then
    count=count+1;if not seen[id..':'..r.key]then missing[#missing+1]=id..':'..r.key end
   end
  end
 end
 end
 assert(count>0,'no voxel setting schema')
 assert(changed and inversion:get()==before,'native inversion row not exercised')
 assert(#missing==0,'native settings schema rows missing: '..table.concat(missing,','))
 print('[voxel settings row inventory]',ver,count,#missing,'inversion changed/restored')
 for _,id in ipairs(missing)do print('[missing native row]',id)end
 U.wait(2);assert(U.shot(game,os.getenv('SHOT_DIR')..'/all-settings.png'))
 love.event.quit()
end
