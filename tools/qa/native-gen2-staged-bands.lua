-- Original imported move scripts with lifted-row effects on both sides.
return function(game)
 local U=dofile('tests/drivers/util.lua');assert(love.filesystem.getIdentity():match('%-qa$'))
 local mixedFaint=os.getenv('QA_FAINT_COMBINED')=='1'
 local dir=assert(os.getenv('SHOT_DIR'));local version=require('src.core.GameVersion').get()
 love.window.setMode(480,432,{vsync=0})
 local actualFocus=love.window.hasFocus;love.window.hasFocus=function()return true end
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ROUTE_29',10,6,'down'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 V.require('UiBackplates').arenaFill:sync('OFF');require('src.render.Pipelines').setLevel('voxel',4)
 V.require('Shadows').setting:sync('off');V.require('RenderDistance').setting:sync(16)
 local Stage=V.require('OverworldBattle');Stage.setting:setIndex(1,game)
 local settings=V.require('PokeballSettings');settings.enabled:sync(false);settings.audio:sync('ORIGINAL');V.require('BattleArt').setting:sync('rom');V.require('BattleArt').backPlacementSetting:sync('world')
 local Mon=require('src.battle.gen2.Mon')
 game.save.party={Mon.new(game.data,'CYNDAQUIL',30),Mon.new(game.data,'TOTODILE',30)}
 game.save.party[2].dvs={attack=10,defense=10,speed=10,special=10};game.save.party[2].shiny=true
 local Staged=V.require('Gen2Staged');local sideTexture=Staged.sideTexture
 local counts={bands=0,frames=0,raster=0,crops=0};local observed;local caseKey='intro'
 local Bands=V.require('NativeGen2PictureBands');local draw,rasterDraw,crop=Bands.draw,Bands.drawRaster,Bands.crop
 local cropShots={}
 Bands.crop=function(...)
  counts.crops=counts.crops+1
  if Stage.setting:get()and not cropShots[caseKey]then game.capturePath=dir..'/faint-'..caseKey..'.png';cropShots[caseKey]=true end
  return crop(...)
 end
 Bands.drawRaster=function(...)counts.raster=counts.raster+1;observed='raster';return rasterDraw(...)end
 Bands.draw=function(...)counts.bands=counts.bands+1;observed='band';return draw(...)end
 Staged.sideTexture=function(g,side)
  local result=sideTexture(g,side);local screen=Staged.screenFor(g)
  local pose=screen and screen:animPicState(side)
  if pose and pose.lifted and not screen:picBoxCleared(side)then
   assert(result and Staged.drawn[side]==screen:activeMon(side),'lifted rows returned to flat slot')
   counts.frames=counts.frames+1
  end
  return result
 end
 U.wait(90);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 game.world:startBattle({wild=Mon.new(game.data,'SENTRET',3)})
 local screen;local shots={}
 local function snapshot()
  if observed and not shots[observed]then shots[observed]=true;assert(U.shot(game,dir..'/'..observed..'-'..caseKey..'.png'))end
 end
 for i=1,700 do
  screen=Staged.screenFor(game);snapshot()
  if screen and screen.phase=='menu'then break end
  U.tap(game,'a');U.wait(2)
 end
 assert(screen and screen.phase=='menu');assert(U.shot(game,dir..'/native-color.png'))
 local party,enemy=game.save.party,screen.battle.enemy
 if os.getenv('QA_SUBSTITUTE')=='1'then
  for _,mon in ipairs({screen.battle.player,enemy})do mon.volatile=mon.volatile or{};mon.volatile.substitute=10 end
 end
 local function finishAnimation(side)
  local runner=screen.anim;local injected=false
  for i=1,1000 do
   U.wait(1);snapshot()
   if mixedFaint and not injected then
    for _,affected in ipairs({'player','enemy'})do
     local pose=screen:animPicState(affected)
     if pose and pose.lifted then
      screen.faintSlide={side=affected,frames=0};injected=true -- explicit presentation combination, not a gameplay KO
      break
     end
    end
   end
   if not screen.anim then if mixedFaint then assert(injected)end;return runner.frames end
  end
  error('original animation did not finish')
 end
 local function hasBand(key,seen)
  seen=seen or{};if seen[key]then return end;seen[key]=true
  for _,row in ipairs(screen.anims.scripts[key]or{})do
   if row[1]=='bgeffect'then
    local effect=type(row[2])=='number'and screen.animConstants.battleBgEffectOrder[row[2]+1]or row[2]
    if type(effect)=='string'and effect:find('BATTLE_BG_EFFECT_BATTLEROBJ_',1,true)then
     return effect:find('_1ROW',1,true)and 1 or 2
    end
   end
   for _,value in ipairs(row)do
    if screen.anims.scripts[value]then local kind=hasBand(value,seen);if kind then return kind end end
   end
  end
 end
 local candidates={}
 for name,key in pairs(screen.anims.moves or{})do if hasBand(key)then candidates[#candidates+1]=name end end
 table.sort(candidates)
 local names,seen={},{}
 for _,name in ipairs(candidates)do local kind=hasBand(screen.anims.moves[name]);if not seen[kind]then seen[kind]=true;names[#names+1]=name end end
 assert(seen[1]and seen[2],'original one/two-row move scripts missing')
 print('[native band moves]',table.concat(names,','))
 local hpPlayer,hpEnemy=screen.battle.player.hp,enemy.hp
 for i=1,math.min(2,#names)do
  for _,side in ipairs({'player','enemy'})do
   caseKey=names[i]..'-'..side
   Stage.setting:sync(false);U.wait(3)
   screen.picHidden.player=false;screen.picHidden.enemy=false;assert(screen:animForMove(names[i],side,0));local nativeFrames=finishAnimation(side)
   Stage.setting:sync(true);U.wait(5);shots.band=nil;shots.raster=nil;observed=nil
   screen.picHidden.player=false;screen.picHidden.enemy=false;assert(screen:animForMove(names[i],side,0));local stagedFrames=finishAnimation(side)
   assert(nativeFrames==stagedFrames,'original script clock changed')
   print('[native/staged script frames]',caseKey,nativeFrames,stagedFrames)
   assert(U.shot(game,dir..'/restored-'..i..'-'..side..'.png'))
  end
 end
 assert(counts.bands>0 and counts.frames>0 and counts.raster>0,'original bands not observed')
 assert(game.save.party==party and screen.battle.enemy==enemy,'native combat identity changed')
 assert(screen.battle.player.hp==hpPlayer and enemy.hp==hpEnemy,'script reader changed HP')
 if mixedFaint then assert(counts.crops>0,'combined faint crop absent')end
 Staged.sideTexture=sideTexture;Bands.draw=draw;Bands.drawRaster=rasterDraw;Bands.crop=crop;game.update=update;love.window.hasFocus=actualFocus
 print('[PASS native GSC world bands]',version,counts.bands,counts.frames,counts.raster,'original scripts/timers/pictures','faint crops',counts.crops)
 love.event.quit()
end
