-- Native Hoenn starter flow; actual fallback and explicit ROM-derived test provider.
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
 local Native=V.require('NativeInterfaceArt');local picture=Native.picture
 local images=setmetatable({},{__mode='k'});local hits,identities=0,{}
 Native.picture=function(mon,...)
  local image=picture(mon,...)
  if image then local w,h=image:getDimensions();assert(w>=64 and h>=64,'interface dimensions');images[image]=true;identities[mon.personality or 0]=V.require('BattleArt').isShiny(mon) end
  return image
 end
 local g=love.graphics;local draw=g.draw
 g.draw=function(image,...)if images[image]then hits=hits+1 end;return draw(image,...)end
 local function shot(name,want)
  hits=0;U.wait(2);assert(U.shot(game,dir..'/'..name..'.png'))
  assert((hits>0)==want,name..': selected image ownership')
 end
 assert(rs or version=='emerald')
 local Starter=require('src.ui.game3.rse.starter_choose');local Kit=require('src.ui.game3.rse.scene_kit')
 local originalFade=Kit.drawFade;local P=require('src.core.game3.pokemon')
 local party=game.session.party;local calls,result=0,nil
 local function open()return Starter.open({onDone=function(r)calls=calls+1;result=r end})end
 local function phase(st,want)
  for i=1,600 do if st.state==want then U.wait(2);return end;U.wait(1)end
  error('starter phase '..tostring(st.state)..' expected '..want)
 end
 local function tap(btn)U.tap(game,btn);U.wait(3)end
 U.wait(75)
 local st=open();phase(st,'input');tap('a');phase(st,'confirm')
 shot('starter-missing-native',false);tap('b');phase(st,'input')
 assert(calls==0 and not st.mon,'native decline preview lifecycle')
 -- Explicit test provider: original ROM starter pixels enlarged 2x on CPU.
 -- No synthetic species, production provider, art file or gameplay data changes.
 local provider=Native.crystal;local frames,dataByImage={},{}
 local cache=require('src.core.game3.dataset').cache()
 local root=require('src.core.game3.cache_paths').CACHE_ROOT
 for _,national in ipairs({252,255,258})do
  local species=P.speciesFromNational(national)
  local rgba=assert(cache:read(root..'/pokemon/front/'..species..'.rgba'))
  local source=love.image.newImageData(64,64,'rgba8',rgba)
  local data=love.image.newImageData(128,128)
  for y=0,127 do for x=0,127 do data:setPixel(x,y,source:getPixel(math.floor(x/2),math.floor(y/2)))end end
  local image=g.newImage(data);image:setFilter('nearest','nearest');dataByImage[image]=data;frames[national]={image}
 end
 Native.crystal={active=function()return true end,image=function(mon)local f=frames[mon.species];return f and f[1],f end,
  imageData=function(image)return dataByImage[image]end}
 tap('a');phase(st,'confirm');local preview=st.mon;local affine=preview.affine
 shot('starter-provider-fit',true)
 Interface.scalingSetting:sync('full');local full=Native.picture({species=P.national(preview.species)})
 local fw,fh=full:getDimensions();assert(fw>64 or fh>64,'test provider must exercise oversized FULL')
 shot('starter-provider-full',true)
 Interface.setting:sync('off');shot('starter-off-native',false);Interface.setting:sync('battle_art')
 assert(st.mon==preview and st.mon.affine==affine and Kit.drawFade==originalFade,'starter draw owner leaked')
 tap('b');phase(st,'input');assert(calls==0 and not st.mon,'selected preview decline lifecycle')
 tap('left');phase(st,'input');tap('a');phase(st,'confirm');shot('starter-other-provider',true)
 local expected=st.selection;tap('a');U.wait(4)
 assert(not Starter.isOpen()and calls==1 and result==expected,'native starter confirmation result')
 assert(game.session.party==party and #party==0,'presentation changed party')
 st=open();phase(st,'input');Starter.reset();U.wait(2)
 assert(not Starter.isOpen()and calls==1 and Kit.drawFade==originalFade,'native reset lifecycle')
 Native.crystal=provider;Native.picture=picture;g.draw=draw;game.update=update
 print('[PASS native starter art]',version,'missing/default native; test-provider FIT/FULL/OFF, decline/confirm/reset; oversized',fw,fh)
 love.event.quit()
end
