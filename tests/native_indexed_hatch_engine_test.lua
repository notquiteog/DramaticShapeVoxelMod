local engine=assert(os.getenv('ASTRA_ENGINE'),'ASTRA_ENGINE required')
local Vram=assert(loadfile(engine..'/src/ui/game3/rse/contest_vram.lua'))()
local Palette=assert(loadfile(engine..'/src/core/game3/gba_palette.lua'))()
local indexed=Vram.indexedPic;local selectedPalette;local selectedBytes
Vram.indexedPic=function(rgba)
 selectedBytes=rgba
 local colors={}
 for i=1,#rgba,4 do local r,g,b,a=rgba:byte(i,i+3);if a~=0 then colors[r..","..g..","..b]=true end end
 local count=0;for _ in pairs(colors)do count=count+1 end;assert(count<=15,"quantization exceeded native palette")
 local sheet,pal=indexed(rgba,true);selectedPalette=pal;return sheet,pal
end
package.loaded['src.ui.game3.rse.contest_vram']=Vram
local image={};local nativeSheet={};local p=Palette.new()
local e={sheet=nativeSheet,paletteNum=1};local coeff,color=0,0;local checks=0
local H={Scene={draw=function(self)
 assert(e.sheet~=nativeSheet,'native sheet was not replaced')
 local expected=Palette.new();expected:load(selectedPalette,272,16);expected:blend(272,16,coeff,color)
 for i=0,15 do assert(p.pltt[272+i]==expected.faded[272+i],'native palette blend differs at index '..i)end
 checks=checks+1
end}}
package.loaded['src.ui.game3.rs.egg_hatch']=H
local data={getDimensions=function()return 64,64 end,getPixel=function(_,x)
 if x%3==0 then return 1,0,0,1 elseif x%3==1 then return 0,1,0,1 else return 0,0,1,1 end
end}
local Art={picture=function()return image end,imageData=function()return data end}
local P={speciesOf=function(m)return m.species end,isEgg=function()return false end,
 monPicSpecies=function(m)return m.species end,national=function(s)return s end,isShiny=function()return false end}
local self={mon={species=25},front={},frontSheet=nativeSheet,m={ppu={sprites={oamShown={e}},palette=p}},displayFx={}}
local undo=dofile('lib/NativeIndexedHatchArt.lua').install(Art,P)
for _,target in ipairs({0,32767,31+15*32+7*1024})do
 color=target
 for y=0,16 do
  coeff=y;self.displayFx[17]={y=y,color=target};H.Scene.draw(self)
  assert(e.sheet==nativeSheet,'native sheet restore')
  for i=0,511 do assert(p.pltt[i]==0 and p.faded[i]==0 and p.unfaded[i]==0,'native palette mutation')end
 end
end
assert(selectedPalette[2]==31 and selectedPalette[3]==31*32 and selectedPalette[4]==31*1024,'real decoder preserved distinct opaque colors')
image={}
data.getPixel=function(_,x,y)if x==0 then return 0,0,0,0 end;return (x%32)/31,(y%32)/31,((x+y)%32)/31,1 end
H.Scene.draw(self)
assert(selectedBytes:byte(4)==0 and selectedBytes:byte(8)==255,'rich frame preserves transparent footprint')
local first=selectedBytes;image={};H.Scene.draw(self)
assert(selectedBytes==first,'rich frame palette reduction must be deterministic')
undo()
print('PASS '..checks..' actual indexed-decoder/native-palette combinations')
