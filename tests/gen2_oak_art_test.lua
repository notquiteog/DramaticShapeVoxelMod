local n=0;local function check(v,m)n=n+1;assert(v,m)end
local drawn;local failure=false
local Screen={resolvePic=function(_,desc)return desc.image,desc.colors end}
function Screen:drawPic()
 drawn={image=self.pic,colors=self.picColors,reveal=self.picReveal,flip=self.picFlip}
 if failure then error('draw failed')end
 return 'native-layout'
end
local draw,resolve=Screen.drawPic,Screen.resolvePic
package.loaded['src.ui.gen2.OakSpeech']=Screen
local paletteMode={mode='gbc'};package.loaded['src.render.GbcPalette']=paletteMode
local enabled=true;local requested
local V={require=function(name)
 assert(name=='NativeInterfaceArt')
 return {picture=function(mon,size,side)requested={mon=mon,size=size,side=side};return enabled and 'selected-'..mon.species or nil end}
end}
local undo=assert(loadfile('lib/Gen2OakArt.lua'))(V).install()
local colors={1,2,3};local reveal={kind='wipe',t=10,dur=32}
local s=setmetatable({pic='native-demo',marillPic='native-demo',demoSpecies='MARILL',picColors=colors,picReveal=reveal,picFlip=true},{__index=Screen})
check(s:drawPic()=='native-layout'and drawn.image=='selected-MARILL'and drawn.colors==nil,'selected truecolor demo uses native layout')
check(drawn.reveal==reveal and drawn.flip and reveal.t==10,'native wipe/flip/timer retained')
check(s.pic=='native-demo'and s.picColors==colors,'picture and palette restored')
paletteMode.mode='dmg';s:drawPic();check(drawn.colors==colors,'non-GBC mode retains native palette');paletteMode.mode='gbc'
check(requested.size==56 and requested.side=='front','native block and front picture')
s.pic='trainer';s:drawPic();check(drawn.image=='trainer','trainer art unchanged')
local image,palette=s:resolvePic({type='pokemon',id='CYNDAQUIL',image='custom-mon',colors=colors})
s.pic,s.picColors=image,palette;s:drawPic();check(drawn.image=='selected-CYNDAQUIL','public custom Pokemon description tracked')
enabled=false;s:drawPic();check(drawn.image=='custom-mon'and drawn.colors==colors,'OFF/missing art retains native palette')
enabled=true;s.picReveal={kind='rotate',t=10};s:drawPic();check(drawn.image=='custom-mon'and drawn.colors==colors,'indexed palette rotation stays native')
s.picReveal=nil;V.crystalSpritesActive=true;s:drawPic();check(drawn.image=='custom-mon','Crystal owns demo')
V.crystalSpritesActive=false;failure=true;check(not pcall(s.drawPic,s),'draw error propagates')
check(s.pic=='custom-mon'and s.picColors==colors,'error restores native image and palette')
undo();check(Screen.drawPic==draw and Screen.resolvePic==resolve,'unload restores public seams')
print('PASS '..n..' Gen2 Oak selected-art contracts')
