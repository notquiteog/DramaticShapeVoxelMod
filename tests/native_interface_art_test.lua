local checks=0
local function check(v,why)checks=checks+1;assert(v,why)end
local function img(id,w,h)return {id=id,getDimensions=function()return w or 80,h or 80 end}end
local first,second=img('one'),img('two')
local frames={first,second};local current=second
local selected,scale='battle_art','fit'
local fitCalls,lastMon=0
local Interface={setting={get=function()return selected end},scalingSetting={get=function()return scale end}}
local fitImages={}
local Art={fitPreparedFrames=function(input,w,h,full)
 check(input==frames,'fit must retain animation-wide union')
 check(w==64 and h==64,'native interface target is 64 pixels')
 fitCalls=fitCalls+1
 local out={img('fit1',full and 80 or 64),img('fit2',full and 80 or 64)}
 fitImages[full and 'full' or 'fit']=out;return out
end}
local Animated={picture=function(mon,side)lastMon=mon;check(side=='front','interface uses front');return current,frames end}
local original=function()return {image=img('rom')}end
local P={frontPic=original,national=function(id)return id-1000 end,isEgg=function(mon)return mon.isEgg end}
local Summary={_party={{species=1025,personality=456,otId=123,otSecretId=321,isShiny=true}},_cursor=1}
local fail=false;local seen
Summary.draw=function()
 seen=P.frontPic(1025,0)
 if fail then error('native draw failure')end
 return 'summary'
end
local Dex={draw=function()seen=P.frontPic(1025,0);return 'dex'end}
package.loaded['src.core.game3.pokemon']=P
package.loaded['src.ui.game3.summary_menu']=Summary
package.loaded['src.ui.game3.pokedex']=Dex
local monFront=function(mon)return P.frontPic(mon.species,0)end;P.monFrontPic=monFront
local framePic=function()return{image=img('native-evolution')}end
local Anim={framePic=framePic};package.loaded['src.core.game3.mon_anim']=Anim
local Evolution={_mon={species=1025,personality=700,isShiny=true},draw=function()seen=Anim.framePic(1026,0,true)end}
local Hof={draw=function()seen=P.monFrontPic({species=1027,personality=800,isShiny=true})end}
package.loaded['src.ui.game3.evolution_scene']=Evolution
package.loaded['src.ui.game3.hall_of_fame']=Hof
P.SPECIES_EGG,P.SPECIES_SPINDA,P.SPECIES_DEOXYS=1412,1327,1386
P.monFrontPicDontHandleDeoxys=function(mon)return P.monFrontPic(mon)end
local Hatch={_mon={species=1025,personality=900,isShiny=true}}
local eggSeen
Hatch.draw=function()eggSeen=P.frontPic(P.SPECIES_EGG);seen=Anim.framePic(1025,1,true);return nil,'hatch',false end
local offer={species=1025,personality=901,isShiny=false}
local received={species=1025,personality=902,isShiny=true};local tradeMons={}
local Trade={draw=function()
 P.monFrontPic(offer);tradeMons[1]=lastMon
 seen=P.monFrontPicDontHandleDeoxys(received);tradeMons[2]=lastMon
 return nil,'trade',false
end}
package.loaded['src.ui.game3.egg_hatch']=Hatch
package.loaded['src.ui.game3.trade_scene']=Trade
local navs={}
for _,name in ipairs({'rs.pokenav.condition','rs.pokenav.ribbons','rse.pokenav.condition','rse.pokenav.ribbons_summary','rse.factory_select','rse.factory_swap'})do
 local screen={draw=function(self)seen=P.monFrontPic(self.mon);return self.marker,nil,false end}
 package.loaded['src.ui.game3.'..name]=screen;navs[#navs+1]=screen
end
local creditShiny,creditPid=true,1234
local Credits={draw=function()seen=P.frontPic(1025,0,creditShiny,creditPid,'credits');return nil,'credits',false end}
local initialCredits=Credits.draw
package.loaded['src.ui.game3.rse.credits']=Credits
local V={require=function(name)return assert(({InterfaceSprites=Interface,BattleArt=Art,AnimatedBattleArt=Animated,NativeIndexedHatchArt={install=function()return function()end end},NativeStarterArt={install=function()return function()end end},NativeJumpArt={install=function()return function()end end},NativePokeblockArt={install=function()return function()end end},NativeScriptedArt={install=function()return function()end end},NativeCrystalPortraits={install=function()return function()end end}})[name],name)end}
local Native=assert(loadfile('lib/NativeInterfaceArt.lua'))(V)
local initialSummary,initialDex=Summary.draw,Dex.draw
local undo=Native.install()
check(Summary.draw()=='summary' and seen.image==fitImages.fit[2],'correct animated fitted frame')
check(lastMon.species==25 and lastMon.personality==456 and lastMon.isShiny==true,'Summary mon-aware national/shiny context')
check(P.frontPic==original,'front provider restored after scoped draw')
current=first;Summary.draw();check(seen.image==fitImages.fit[1] and fitCalls==1,'frame selection preserves fitted animation union cache')
scale='full';Summary.draw();check(seen.image==fitImages.full[1] and fitCalls==2,'FULL switches live without resetting animation')
Dex.draw();check(lastMon.personality==nil and lastMon.isShiny==nil,'Dex remains regular species preview')
fail=true;local ok=pcall(Summary.draw)
check(not ok and P.frontPic==original,'native error restores sprite provider')
fail=false;selected='off';Summary.draw();check(seen.image.id=='rom','OFF retains native art')
selected='modded';Dex.draw();check(seen.image.id=='rom','MODDED retains provider art')
selected='battle_art';Summary._party[1].isEgg=true;Summary.draw();check(seen.image.id=='rom','eggs retain native species rules')
Evolution.draw();check(lastMon.species==26 and lastMon.personality==700 and seen.image==fitImages.full[1],'evolution native frame path preserves changing species and shiny identity')
check(Anim.framePic==framePic,'native frame provider restored')
Hof.draw();check(lastMon.species==27 and lastMon.personality==800 and lastMon.isShiny,'Hall-of-Fame mon identity retained')
check(P.monFrontPic==monFront,'native mon reader restored')
local a,b,c=Hatch.draw();check(a==nil and b=='hatch'and c==false,'hatch exact native returns')
check(eggSeen.image.id=='rom'and lastMon.personality==900 and lastMon.isShiny,'egg art native and revealed hatch identity retained')
a,b,c=Trade.draw();check(a==nil and b=='trade'and c==false,'trade exact native returns')
check(tradeMons[1].personality==901 and not tradeMons[1].isShiny and tradeMons[2].personality==902 and tradeMons[2].isShiny,'same-species trade partners keep distinct identity')
received.isEgg=true;Trade.draw();check(seen.image.id=='rom','traded egg stays native');received.isEgg=nil
for _,species in ipairs({P.SPECIES_SPINDA,P.SPECIES_DEOXYS})do
 received.species=species;Trade.draw();check(seen.image.id=='rom','PID spots and Deoxys form stay native')
end
received.species=1025
check(P.monFrontPic==monFront and P.frontPic==original and Anim.framePic==framePic,'trade/hatch readers restored')
for _,screen in ipairs(navs)do
 local instance=setmetatable({mon={species=1025,personality=903,isShiny=true},marker='nav'},{__index=screen})
 local a,b,c=instance:draw();check(a=='nav'and b==nil and c==false and lastMon.personality==903 and lastMon.isShiny,'native menu instance/returns/identity retained')
 selected='off';instance:draw();check(seen.image.id=='rom','native menu OFF retains native picture');selected='battle_art'
end
local a,b,c=Credits.draw()
check(a==nil and b=='credits'and c==false and lastMon.personality==1234 and lastMon.isShiny==true,'credits explicit PID/shiny and exact return tuple')
creditShiny=false;Credits.draw();check(lastMon.isShiny==false,'explicit false shiny remains false')
selected='off';Credits.draw();check(seen.image.id=='rom','credits OFF remains native');selected='battle_art'
local picture=Animated.picture
Animated.picture=function(mon,side)if mon.personality==902 then error('missing selected image')end;return picture(mon,side)end
local success=pcall(Trade.draw)
check(not success and P.monFrontPic==monFront and P.frontPic==original and Anim.framePic==framePic,'trade reader error unwinds all temporary providers')
Animated.picture=picture
local raw={img('raw1'),img('raw2')};local preparedFrames={img('prepared1'),img('prepared2')};local reads=0
Native.crystal={active=function()return true end,image=function()return raw[2],raw end,
 imageData=function(image)reads=reads+1;return image end}
Art.prepareData=function(data,mode)check(mode=='color','Crystal pixels retain original palette');return data==raw[1]and preparedFrames[1]or preparedFrames[2]end
Art.fitPreparedFrames=function(input,w,h,full)
 check(input[1]==preparedFrames[1]and input[2]==preparedFrames[2],'CPU-prepared complete Crystal animation')
 check(w==64 and h==64,'Crystal receives native target dimensions')
 return {img(full and 'full1'or'fit1'),img(full and 'full2'or'fit2')}
end
scale='fit';check(Native.picture({species=25}).id=='fit2'and reads==2,'Crystal fitted current frame')
scale='full';check(Native.picture({species=25}).id=='full2'and reads==2,'Crystal FULL reuses source preparation')
raw={img('missing')};check(Native.picture({species=25})==nil,'absent current frame falls back')
Native.crystal.image=function()return raw[1],raw end
Native.crystal.imageData=function()reads=reads+1;return nil end
check(Native.picture({species=25})==nil,'missing CPU data retains native art')
local before=reads;check(Native.picture({species=25})==nil and reads==before,'failed preparation avoids per-frame IO')
undo();check(Summary.draw==initialSummary and Dex.draw==initialDex,'unload restores native owners')
check(Credits.draw==initialCredits,'credits unload restores native draw')
print('PASS '..checks..' native interface art checks')
