-- Native constants/map identities and optional backdrop fallback; no synthetic artwork.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local version=require('src.core.GameVersion').get();local rs=version=='ruby'or version=='sapphire'
 love.window.setMode(480,320,{vsync=0})
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local map=({ruby='RU_LITTLEROOT_TOWN',sapphire='SA_LITTLEROOT_TOWN',emerald='EM_LITTLEROOT_TOWN',leafgreen='LG_PALLET_TOWN',firered='FR_PALLET_TOWN'})[version]or'FR_PALLET_TOWN'
 game:_handleBootAction({action='new_game',start={map=map,x=7,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end
 require('src.ui.game3.message').reset();require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;V.require('Gen3Integration').setLevel(0,game)
 V.require('NativeCrystalArt').pack:sync('crystal')
 local Interface=V.require('InterfaceSprites');Interface.setting:sync('battle_art');Interface.scalingSetting:sync('fit')
 local B=V.require('Gen3BattleBackdrop');local UI=V.require('UiBackplates')
 local terrain=require('src.core.game3.battle.bg').TERRAIN
 local prefix=({firered='FR_',leafgreen='LG_',ruby='RU_',sapphire='SA_',emerald='EM_'})[version]
 local function def(id)return assert(game.data.maps[id]or game.data.maps[id:gsub('^LG_','FR_')],id)end
 local Map=require('src.core.game3.map');local outdoorId=Map.current
 local outdoor=assert(Map.currentDef());local count=0
 for _,case in ipairs({{'WATER','ocean.jpg'},{'POND','shore.jpg'},{'MOUNTAIN','rockypathday.jpg'}, {'UNDERWATER',false},{'SAND',false}})do
  local st={wild=true,terrain=assert(terrain[case[1]])}
  -- Unknown-map identity isolates native terrain fallback without borrowing a
  -- location plate; public map definition remains this edition's real outdoor map.
  local file=B.files(prefix..'QA_UNMAPPED_ROUTE',outdoor,st)
  assert(case[1]=='MOUNTAIN'and file and file:match('^rockypath')or (case[2]and file==case[2]or not case[2]and not file),case[1]..': '..tostring(file));count=count+1
  assert(st.terrain==terrain[case[1]]and st.wild,'native encounter state mutated')
 end
 if version=='firered'or version=='leafgreen'then
  local gym=prefix..'PEWTER_CITY_GYM'
  local a,b=B.files(gym,def(gym),{trainerClassName='LEADER',trainerName='BROCK'})
  assert(a=='pewtergym.jpg'and b=='pewtergym.jpg','native edition boss/location alias');count=count+1
 end
 local before=UI.arenaFill:get();UI.arenaFill:sync('GEN6')
 -- This fixture has no optional illustration collection: native world remains.
 local st={wild=true,terrain=terrain.WATER}
 assert(B.frame(outdoorId,outdoor,st)==nil,'missing optional image did not retain world')
 UI.arenaFill:sync('OFF');assert(B.frame(outdoorId,outdoor,st)==nil)
 UI.arenaFill:sync('WHITE');assert(B.frame(outdoorId,outdoor,st).color[1]==1)
 UI.arenaFill:sync(before)
 U.wait(2);game.update=update
 print('[PASS native backdrop routing]',version,count,'native terrain/map cases; missing art/OFF/WHITE, unchanged native state')
 love.event.quit()
end
