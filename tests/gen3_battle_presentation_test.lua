local n=0
local function check(v,msg)n=n+1;assert(v,msg)end
local mode='OFF';local boss=true;local phase='day';local loaded={};local available=true
local U={arenaFill={get=function()return mode end},backdropOffset={},bossBg={},spriteLight={},
 bossEnabled=function()return boss end,backdropOffsetPixels=function()return 140 end}
local Art={trainerImage=function(key)return key=='brock' and {name=key}or nil end}
local images={}
for i=1,5 do images[i]={id=i,getDimensions=function()return 40+i,50 end}end
local progress={};local hasArt=true
local Animated={playerTrainerPicture=function(p)
 progress[#progress+1]=p
 if not hasArt then return nil end
 return images[({[0]=1,[1]=2,[25]=3,[49]=4,[72]=5})[p]]
end}
local V={data=function(name)return dofile('data/'..name..'.lua')end}
local modules={BattleArt=Art,AnimatedBattleArt=Animated,UiBackplates=U,
 DayNight={time=function()return 12 end,mix=function()return {[phase]=1}end},
 BackdropImage={load=function(folder,file)if not file then return nil end;loaded[#loaded+1]=folder..'/'..file;return available and file or nil end},
 Gen3Tilesets={outdoor=function(d)return d and d.mapType==1 end}}
V.require=function(k)return assert(modules[k],k)end
local Trainer=assert(loadfile('lib/Gen3TrainerArt.lua'))(V);modules.Gen3TrainerArt=Trainer
local Backdrop=assert(loadfile('lib/Gen3BattleBackdrop.lua'))(V)
package.loaded['src.core.game3.pokemon']={national=function(s)return s end,speciesOf=function(m)return m.species end}
local st={trainerClassName='LEADER',trainerName='BROCK'}
local map='FR_PEWTER_CITY_GYM';local def={mapType=8}
check(Backdrop.frame(map,def,st)==nil,'OFF retains world arena')
mode='BLUE';check(Backdrop.frame(map,def,st)==nil,'BLUE cannot pretend optional Stadium provider exists')
mode='WHITE';check(Backdrop.frame(map,def,st).color[1]==1,'white arena live')
mode='GEN6';local f=Backdrop.frame(map,def,st)
check(f.image=='pewtergym.jpg' and f.offset==140 and loaded[#loaded]=='bosses/pewtergym.jpg','native leader boss plate/crop')
boss=false;f=Backdrop.frame(map,def,st)
check(loaded[#loaded]=='gen6/pewtergym.jpg','boss off returns ordinary collection')
local battle={wild=true};phase='night';f=Backdrop.frame('FR_ROUTE_1',{mapType=1},battle)
check(f.image=='grassynight.jpg','native location and day phase')
phase='day';check(Backdrop.frame('FR_ROUTE_1',{mapType=1},battle).image=='grassynight.jpg','battle hour does not jump mid-fight')
check(Backdrop.frame('FR_UNKNOWN_ROOM',{mapType=8},{})==nil,'unknown indoor room does not borrow outdoor art')
check(Backdrop.frame('FR_FIVE_ISLAND',{mapType=1},{}).image=='grassyday.jpg','unknown outdoor retains documented grassy fallback')
boss=true;check(Backdrop.frame('FR_MT_EMBER_SUMMIT',{mapType=1},{wild=true,enemy={species=146}}).image=='moltres.jpg','native Moltres location')
mode='PNG';boss=false;check(Backdrop.frame(map,def,st).image=='arena.png','BYO plate remains own source')
available=false;check(Backdrop.frame(map,def,st)==nil,'missing artwork fails open to world')
check(Trainer.key({link=true,trainerClassName='LEADER',trainerName='BROCK'})==nil,'link identity not borrowed from boss')
check(Trainer.key({trainerClassName='RIVAL',earlyRival=true})=='rival1','native rival stage')
check(Trainer.key({}, {className='COOLTRAINER',gender=1})=='cooltrainer-f','native gender-aware trainer key')
local active=false;local nativeFront=function()return 'front'end;local nativeBack=function()return 'back'end
local Pics={front=nativeFront,back=nativeBack};package.loaded['src.core.game3.trainer_pic']=Pics
local Battle={_st={trainerClassName='LEADER',trainerName='BROCK',trainerPicId=80}}
package.loaded['src.core.game3.battle']=Battle
package.loaded['src.core.game3.scripting.trainers']={info=function()return nil end}
local draws={};local color={1,1,1,1};local pushed=0
local G={newCanvas=function(w,h)return {w=w,h=h,setFilter=function()end,release=function(self)self.released=true end}end,
 push=function()pushed=pushed+1 end,pop=function()pushed=pushed-1 end,
 setCanvas=function()end,origin=function()end,setShader=function()end,setScissor=function()end,setDepthMode=function()end,
 setBlendMode=function()end,clear=function()end,setColor=function(r,g,b,a)color={r,g,b,a}end,getColor=function()return unpack(color)end,
 draw=function(image,...)draws[#draws+1]={image=image,args={...},color=color}end}
love={graphics=G}
local undo=Trainer.install(function()return active end,function(image)return image end)
check(Pics.front(80)=='front' and Pics.back(0)=='back','outside native UI retains engine trainer owner')
active=true;check(Pics.front(80).image.name=='brock' and Pics.front(81)=='front','only actual enemy intro slot replaced')
local sheet=Pics.back(0);check(sheet.h==320 and #draws==5 and #progress==5,'five native trainer frames decoded once')
check(Pics.back(0).image==sheet.image and #draws==5,'native trainer frame sheet cached')
for i,d in ipairs(draws)do check(d.args[2]>=((i-1)*64) and d.args[2]<i*64,'animation frame remains in its native row')end
hasArt=false;check(Pics.back(0)=='back','missing selected trainer collection retains native sheet')
Battle._st.pokedude=true;check(Pics.back(0)=='back' and Pics.back(2)=='back','scripted trainers keep native contract')
undo();check(Pics.front==nativeFront and Pics.back==nativeBack and sheet.image.released and pushed==0,'trainer unload and GPU scope restored')
local unlit=false;U.spritesUnlit=function()return unlit end
modules.Gen3Battle={active=true};modules.DayNight.tint=function(outdoor)return outdoor and {.5,.6,.7}or {1,1,1}end
package.loaded['src.core.game3.map']={currentDef=function()return {mapType=1}end}
local Light=assert(loadfile('lib/Gen3SpriteLight.lua'))(V);local originalDraw=G.draw
local mon,other={},{};draws={};G.setColor(.8,.6,.4,.3)
Light.scope(function()Light.tag({image=mon});G.draw(mon,1,2);G.draw(other,3,4)end)
check(draws[1].color[1]==.4 and draws[1].color[4]==.3,'native flash/fade multiplied by world tint')
check(draws[2].color[1]==.8 and G.draw==originalDraw,'HUD colors and draw owner restored')
unlit=true;Light.scope(function()Light.tag({image=mon});G.draw(mon)end)
check(draws[3].color[1]==.8,'UNLIT restores native brightness')
check(not pcall(function()Light.scope(function()error('native error')end)end) and G.draw==originalDraw,'native error restores draw scope')
print('PASS '..n..' native backdrop, trainer-frame and sprite-light checks')
