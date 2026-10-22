local checks=0
local function check(v,why)checks=checks+1;assert(v,why)end
local sheet={name='native'};local selectedSheet={name='selected'}
local image={};local decodeCalls,reads=0,0;local mode='normal';local available=true;local seenMon
local data={getDimensions=function()return mode=='large'and 80 or 64,64 end,getPixel=function(_,x,y)
 reads=reads+1
 if mode=='alpha'then return 1,0,0,0.5 end
 if mode=='colors'then return (x%16)/15,0,0,1 end
 if x==0 then return 0,0,0,0 end
 return 1,0,0,1
end}
local Art={imageData=function()return data end,picture=function(mon)seenMon=mon;if available then return image end end}
local Vram={indexedPic=function(rgba,headless)
 check(#rgba==64*64*4 and not headless,'native indexed decoder receives original fixed object footprint')
 decodeCalls=decodeCalls+1;local pal={};for i=1,16 do pal[i]=i==2 and 31 or 0 end
 return selectedSheet,pal
end}
local P={speciesOf=function(m)return m.species end,isEgg=function(m)return m.egg end,
 monPicSpecies=function(m)return m.form and m.species+1 or m.species end,
 national=function(s)return s-1000 end,isShiny=function(m)return m.shiny end,SPECIES_SPINDA=1327,SPECIES_DEOXYS=1386}
local pltt={};for i=0,511 do pltt[i]=i end
local entry={sheet=sheet,paletteNum=2,w=64,h=64,x=120,y=70,a=256,d=256,priority=1}
local nativeShown={entry};local during,fail
local H={Scene={draw=function(self,marker)
 during={effects=self.displayFx,sheet=entry.sheet,color=pltt[289],x=entry.x,a=entry.a,priority=entry.priority}
 if fail then error('native hatch draw error')end
 return nil,marker,false
end}}
local original=H.Scene.draw
package.loaded['src.ui.game3.rs.egg_hatch']=H
package.loaded['src.ui.game3.rse.contest_vram']=Vram
local self={mon={species=1025,personality=91,otId=5,otSecretId=6,shiny=true},front={},frontSheet=sheet,
 m={ppu={sprites={oamShown=nativeShown},palette={pltt=pltt}}},displayFx={}}
local undo=dofile('lib/NativeIndexedHatchArt.lua').install(Art,P)
local a,b,c=H.Scene.draw(self,'hatch')
check(a==nil and b=='hatch'and c==false,'exact native returns')
check(during.sheet==selectedSheet and during.color==31,'selected sheet and palette reach native PPU')
check(entry.sheet==sheet and pltt[289]==289 and self.m.ppu.sprites.oamShown==nativeShown,'original OAM and palette owners restore')
check(seenMon.species==25 and seenMon.personality==91 and seenMon.isShiny and seenMon.otId==5,'hatch identity preserved')
check(during.x==120 and during.a==256 and during.priority==1,'native position/affine/priority untouched')
local count=reads;H.Scene.draw(self);check(decodeCalls==1 and reads==count,'prepared frames decode only once')
self.displayFx[18]={y=8,color=0};H.Scene.draw(self);check(during.color==15,'actual transferred black fade snapshot')
self.displayFx[18]={y=16,color=32767};H.Scene.draw(self);check(during.color==32767,'white reveal remains white')
self.displayFx[18]={y=8,color=32767};H.Scene.draw(self);check(during.color==15871,'partial native white reveal matches RGB5 blend')
fail=true;local ok=pcall(H.Scene.draw,self);check(not ok and entry.sheet==sheet and pltt[289]==289,'native draw error restores temporary palette and sheet');fail=false
available=false;H.Scene.draw(self);check(during.sheet==sheet and during.color==289,'OFF/missing selected art stays native');available=true
for _,m in ipairs({{species=1025,egg=true},{species=1025,form=1},{species=1327},{species=1386}})do
 self.mon=m;H.Scene.draw(self);check(during.sheet==sheet,'special native pictures retain original')
end
self.mon={species=1025,shiny=false}
for _,m in ipairs({'large','alpha'})do
 mode=m;image={};local count=decodeCalls;H.Scene.draw(self)
 check(during.sheet==sheet and decodeCalls==count,'unrepresentable selected frame stays native: '..m)
 local r=reads;H.Scene.draw(self);check(reads==r,'unsupported frame is not rescanned each draw')
end
mode='colors';image={};local count=decodeCalls;H.Scene.draw(self)
check(during.sheet==selectedSheet and decodeCalls==count+1,'rich RGB555 artwork is quantized through native OAM')
local r=reads;H.Scene.draw(self);check(reads==r,'rich frame reduction is cached')
mode='normal';image={};nativeShown[2]={sheet={},paletteNum=2};H.Scene.draw(self)
check(during.sheet==sheet,'shared palette bank cannot recolor other sprites');nativeShown[2]=nil
entry.sheet={};H.Scene.draw(self);check(during.sheet==entry.sheet,'not-yet-visible native front retains reveal timing');entry.sheet=sheet
local decode=Vram.indexedPic;Vram.indexedPic=function()error('optional conversion failed')end;image={}
H.Scene.draw(self);check(during.sheet==sheet,'failed optional conversion retains native renderer');Vram.indexedPic=decode
entry.frame=1;image={};H.Scene.draw(self);check(during.sheet==sheet,'unexpected native frame layout retains native renderer');entry.frame=0
self.headless=true;H.Scene.draw(self);check(during.sheet==sheet,'headless renderer remains native')
self.displayFx[14]={y=8,color=3+7*32+19*1024};local effects=self.displayFx
H.Scene.draw(self)
check(during.effects~=effects and during.effects[14].color[1]==3 and during.effects[14].color[2]==7 and during.effects[14].color[3]==19 and during.effects[14].y==8,'native nickname shader receives RGB5 fade color even with native fallback')
check(self.displayFx==effects and type(effects[14].color)=='number','transferred effect record restored unchanged')
fail=true;local ok=pcall(H.Scene.draw,self);fail=false
check(not ok and self.displayFx==effects,'nickname effect owner restores on native error')
effects[14].color={3,7,19};H.Scene.draw(self)
check(during.effects==effects,'already normalized native effects retain identity')
undo();check(H.Scene.draw==original,'unload restores original class draw')
print('PASS '..checks..' native indexed hatch checks')
