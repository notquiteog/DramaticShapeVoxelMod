local count=0
local function check(ok,message)count=count+1;assert(ok,message)end
local color={1,1,1,1};local calls={};local failure=false
local G={getColor=function()return unpack(color)end,setColor=function(...)color={...}end}
G.draw=function(image,x,y)
 calls[#calls+1]={image=image,x=x,y=y,color={unpack(color)}}
 if failure then error('render failure')end
end
love={graphics=G}
local draw=G.draw
local Screen={pic=function(_,species)return 'native-'..species,false end}
function Screen:drawPic()
 local species=self.showNew and self.newSpecies or self.oldSpecies
 local image=self:pic(species)
 if self.picAnim then image=self.picAnim:frame()end
 G.setColor(1,1,1,1);G.draw(image,56,16)
 return 'native-layout'
end
local original=Screen.drawPic
package.loaded['src.ui.gen2.EvolutionAnim']=Screen
local enabled=true;local requests={}
local V={require=function(name)
 if name=='Gen2PictureScope'then return dofile('lib/Gen2PictureScope.lua')end
 assert(name=='NativeInterfaceArt')
 return {picture=function(mon,size,side)
  requests[#requests+1]={mon=mon,size=size,side=side}
  return enabled and ('selected-'..mon.species)or nil
 end}
end}
local undo=assert(loadfile('lib/Gen2EvolutionArt.lua'))(V).install()
local mon={species='PIKACHU',shiny=true,dvs={attack=2,defense=10,speed=10,special=10}}
local animation={frame=function()return 'native-frame'end}
local screen=setmetatable({mon=mon,oldSpecies='PIKACHU',newSpecies='RAICHU',picAnim=animation,timer=15},{__index=Screen})
check(screen:drawPic()=='native-layout','native layout return preserved')
check(calls[#calls].image=='selected-PIKACHU' and calls[#calls].x==56,'selected current species reaches original layout')
check(requests[#requests].mon==mon and requests[#requests].size==56 and requests[#requests].side=='front','original identity and native block')
check(screen.picAnim==animation and rawget(screen,'pic')==nil and screen.timer==15,'native state restored without stepping timer')
screen.showNew=true;screen:drawPic()
local request=requests[#requests].mon
check(request.species=='RAICHU' and request.shiny and request.dvs==mon.dvs and mon.species=='PIKACHU','target species retains DVs without party mutation')
screen.blackout=true;screen:drawPic()
check(calls[#calls].image=='selected-RAICHU' and calls[#calls].color[1]==0 and calls[#calls].color[4]==1,'blackout uses full selected alpha silhouette')
check(G.draw==draw and color[1]==1,'draw and tint restored after blackout')
screen.blackout=false;screen:drawPic()
check(calls[#calls].color[1]==1,'reveal restores selected color')
enabled=false;screen:drawPic()
check(calls[#calls].image=='native-frame','OFF or missing picture retains native animation')
enabled=true;V.crystalSpritesActive=true;screen:drawPic()
check(calls[#calls].image=='native-frame','Crystal remains native owner')
V.crystalSpritesActive=false;screen.blackout=true;failure=true
check(not pcall(screen.drawPic,screen),'native render error propagated')
check(G.draw==draw and screen.picAnim==animation and rawget(screen,'pic')==nil and color[1]==1,'error restores readers animation and drawing scope')
failure=false;screen.oldSpecies='UNOWN';screen.showNew=false;screen:drawPic()
check(calls[#calls].image=='native-frame','unsupported form retains native art')
undo();check(Screen.drawPic==original,'unload restores original public method')
print('PASS '..count..' Gen2 evolution selected-art contracts')
