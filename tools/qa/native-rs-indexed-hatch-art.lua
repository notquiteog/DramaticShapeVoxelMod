-- Original RS indexed PPU hatch; normal/shiny art and actual palette-transfer timing.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local version=require('src.core.GameVersion').get();local rs=version=='ruby'or version=='sapphire'
 love.window.setMode(480,320,{vsync=0})
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local map=({ruby='RU_LITTLEROOT_TOWN',sapphire='SA_LITTLEROOT_TOWN',emerald='EM_LITTLEROOT_TOWN'})[version]or'FR_PALLET_TOWN'
 game:_handleBootAction({action='new_game',start={map=map,x=7,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end
 require('src.ui.game3.message').reset();require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;V.require('Gen3Integration').setLevel(0,game)
 V.require('NativeCrystalArt').pack:sync('crystal')
 local Interface=V.require('InterfaceSprites');Interface.setting:sync('battle_art');Interface.scalingSetting:sync('fit')
 assert(rs,'RS indexed hatch only')
 local Native=V.require('NativeInterfaceArt');local picture=Native.picture;local identities={}
 Native.picture=function(mon,...)identities[mon.personality]=mon.isShiny;return picture(mon,...)end
 local P=require('src.core.game3.pokemon');local Breeding=require('src.core.game3.breeding')
 local Hatch=require('src.ui.game3.rs.egg_hatch');local hits=0;local checked=0
 local function shot(name,want)
  hits=0;U.wait(2);assert(U.shot(game,dir..'/'..name..'.png'));assert((hits>0)==want,name..': indexed ownership')
 end
 local drawScene=Hatch.Scene.draw
 Hatch.Scene.draw=function(self,...)
  local p=self.m.ppu.palette;local saved={};for i=0,511 do saved[i]=p.pltt[i]end
  local sheets={};for _,entry in ipairs(self.m.ppu.sprites.oamShown)do sheets[entry]=entry.sheet end
  local result={drawScene(self,...)}
  for i=0,511 do assert(p.pltt[i]==saved[i],'draw leaked palette slot '..i)end
  for entry,sheet in pairs(sheets)do assert(entry.sheet==sheet,'draw leaked indexed sheet')end
  checked=checked+1;return unpack(result)
 end
 local tid=tonumber(game.session.trainerId or game.session.id or game.session.playerId)or 0
 local sid=tonumber(game.session.secretId)or math.floor(tid/65536)
 local shinyPid=17*65536+require('bit').bxor(tid%65536,sid%65536,17)
 U.wait(75)
 for _,case in ipairs({{name='normal',species=25,pid=require('bit').bxor(shinyPid,8),shiny=false},{name='shiny',species=155,pid=shinyPid,shiny=true}})do
  Interface.setting:sync('battle_art');Interface.scalingSetting:sync('fit')
  local egg=assert(Breeding.createEgg(game.session,case.species,false));egg.personality=case.pid;egg.isShiny=nil
  game.session.party={egg};local party=game.session.party;local done=0
  assert(P.isEgg(egg));assert(Hatch.start(egg,{session=game.session,onDone=function(status)assert(status=='hatched');done=done+1 end}))
  local scene,ppuDraw,seen,fade,shell=false,nil,false,false,false
  for i=1,2200 do
   U.wait(1)
   if not scene and Hatch.active()then
    scene=Hatch.active();ppuDraw=scene.m.ppu.draw
    scene.m.ppu.draw=function(ppu,...)
     local front=scene.front
     if front then
      for _,entry in ipairs(ppu.sprites.oamShown)do
       if entry.paletteNum==front.oam.paletteNum and entry.sheet~=scene.frontSheet then hits=hits+1 end
      end
     end
     return ppuDraw(ppu,...)
    end
   end
   if scene and scene.state==2 and not shell then
    shell=true;shot(case.name..'-shell',false)
   end
   local fx=scene and scene.front and scene.displayFx[16+scene.front.oam.paletteNum]
   if not fade and scene and scene.front and not scene.front.invisible and fx and fx.y>0 and fx.y<16 then
    fade=true;shot(case.name..'-reveal',true)
   end
   if not seen and scene and scene.front and not scene.front.invisible and fx and fx.y==0 and scene.state>=4 then
    seen=true;shot(case.name..'-fit',true)
    Interface.scalingSetting:sync('full');shot(case.name..'-full',true)
    Interface.setting:sync('off');shot(case.name..'-native',false);Interface.setting:sync('battle_art')
   end
   if scene and scene.state==8 and i%8==0 then U.tap(game,'a')end
   if scene and scene.state==9 then U.tap(game,'b')end
   if not Hatch.isOpen()then break end
  end
  assert(not Hatch.isOpen()and done==1 and seen and fade,'native RS hatch sequence incomplete')
  assert(not P.isEgg(egg)and P.isShiny(egg)==case.shiny and identities[case.pid]==case.shiny,'native hatch identity')
  assert(game.session.party==party and party[1]==egg and #party==1,'party ownership changed')
  scene.m.ppu.draw=ppuDraw
 end
 local egg=assert(Breeding.createEgg(game.session,25,false));local calls=0
 assert(Hatch.start(egg,{session=game.session,onDone=function()calls=calls+1 end}));U.wait(2);Hatch.reset();U.wait(2)
 assert(not Hatch.isOpen()and calls==0,'pending/reset lifecycle')
 Hatch.Scene.draw=drawScene;Native.picture=picture;game.update=update
 print('[PASS native indexed RS hatch art]',version,'normal/shiny shell/reveal/FIT/FULL/OFF, original hatch/nickname-decline/results, reset; clean draws',checked)
 love.event.quit()
end
