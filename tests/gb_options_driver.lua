return function(game)
 local U=dofile('tests/drivers/util.lua');local GV=require('src.core.GameVersion');local ver=GV.get();local gen=GV.generation();local dir=assert(os.getenv('SHOT_DIR'))
 assert(love.filesystem.getIdentity()=='source-art-'..ver..'-030-qa');assert(require('src.core.Version').engine=='0.3.0')
 if gen==2 then game.world.trySceneScript=function()return false end;game.stack:clear();assert(game.world:setMap('NEW_BARK_TOWN',7,8,'down'))
 else U.teleport(game,'PALLET_TOWN',9,8,'down')end
 local Menu=require(gen==2 and 'src.ui.gen2.OptionsMenu' or 'src.ui.OptionsMenu')
 local menu=Menu.new(game,{options=game.options or game.save.options});game.stack:push(menu)
 local ids={};for _,r in ipairs(menu.rows)do ids[r.id]=r end
 local report=assert(io.open(dir..'/rows.txt','w'));for _,r in ipairs(menu.rows)do report:write(tostring(r.id)..' '..tostring(r.label)..'\n')end;report:close()
 for _,id in ipairs({'BATTLE_ART_VOXEL_FORK','overworld_wild_spawns','double_battles','DRAMATIC_SKY_RIDE'})do
  assert(game.mods.exports[id],'missing mod '..id)
  local found=false;for key in pairs(ids)do if type(key)=='string' and key:sub(1,#id+1)==id..':'then found=true end end
  assert(found,'no in-game settings for '..id)
 end
 local row=assert(ids['double_battles:wild_doubles']);local before=row.value(game);row.step(game,1);assert(row.value(game)~=before)
 local fresh=Menu.new(game,{options=game.options or game.save.options});local after
 for _,r in ipairs(fresh.rows)do if r.id==row.id then after=r end end
 assert(after and after.value(game)==row.value(game));row.step(game,-1)
 if menu.focusRow then menu:focusRow(row.id)end
 U.wait(20);assert(U.shot(game,dir..'/options.png'))
 print('[GB options] PASS '..ver..' Battle Art/Wilds/Double/Ride rows, persisted change/reopen')
 love.event.quit()
end
