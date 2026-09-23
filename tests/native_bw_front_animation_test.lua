-- Real release metadata plus native draw-contract doubles. Pixel variance is
-- checked by the importer against every source GIF, not by these synthetic cells.
local checks=0
local function check(value,label)checks=checks+1;assert(value,label)end
local dex=assert(loadfile('data/battle_species_dex_386.lua'))()
local tables={};local function data(name)if not tables[name]then tables[name]=assert(loadfile('data/'..name..'.lua'))()end;return tables[name]end
local mode,front,back,clock,custom='animated','gen5','gen5',0,false
local function setting(get)return{get=get}end
local Art={setting=setting(function()return mode end),frontAnimationSetting=setting(function()return front end),backAnimationSetting=setting(function()return back end),
 speciesAlias=function(s)return type(s)=='number'and dex[s]or s end,ownsSpeciesArt=function()return true end,ownsShinyArt=function()return true end,
 isShiny=function(b)return b and b.mon and b.mon.isShiny==true end,displayMode=function()return'colored'end,shareFrameAnchor=function()end,
 playerSide=function()return'back'end,flipsPlayerFront=function()return false end,bundledImage=function()return nil end}
Art.speciesFor=function(b)return b and b.mon and Art.speciesAlias(b.mon.species)end
local definitions={}
local index=data('bundled_bw_fronts');local total=0
for id,row in pairs(index)do
 definitions['assets/bw-front-animated/'..id..'.png']=row;total=total+1
 check(row.frames>1 and #row.durations==row.frames,'real front frames/timing '..id)
 local f=assert(io.open('assets/bw-front-animated/'..id..'.png','rb'));f:close()
end
check(total==772,'386 normal and shiny front definitions')
for id,row in pairs(data('crystal_full_body'))do definitions['assets/crystal/full_body/'..id..'.png']={width=row.w,height=row.h,columns=row.columns,frames=#row.durations}end
local normalCustom=data('animated_battle_sprites_gen5').RATTATA.front
definitions[normalCustom.image]=normalCustom
local function cell(w,h)
 return{getDimensions=function()return w,h end,paste=function(self,sheet,dx,dy,sx,sy)self.source=sheet.source;self.sx=sx;self.sy=sy end}
end
Art.prepareData=function(c)return{source=c.source,sx=c.sx,sy=c.sy,getDimensions=c.getDimensions}end
love={timer={getTime=function()return clock end},filesystem={getInfo=function(path)
 if custom and path==normalCustom.image then return{}end
 local f=io.open(path,'rb');if f then f:close();return{}end
end},image={newImageData=function(path,h)
 if type(path)=='number'then return cell(path,h)end
 local def=assert(definitions[path],path);local c=cell(def.width*def.columns,def.height*math.ceil(def.frames/def.columns));c.source=path;return c
end}}
local modules={BattleArt=Art,Gen3SpriteLight={scope=function(fn,...)return fn(...)end,tag=function(v)return v end},Gen3TrainerArt={install=function()return function()end end}}
local hooks={}
local V={data=data,require=function(name)return assert(modules[name],name)end,mod={assets={path=function(_,p)return p end},hooks={wrap=function(_,name,fn)hooks[name]=fn end}}}
local Animated=assert(loadfile('lib/AnimatedBattleArt.lua'))(V);modules.AnimatedBattleArt=Animated
local normal={species=19,isShiny=false,personality=1};local shiny={species=19,isShiny=true,personality=2}
check(Animated.definitionFor({mon=normal},'front').image=='assets/bw-front-animated/normal/19.png','absent custom front selects real bundled atlas')
check(Animated.definitionFor({mon=shiny},'front').image=='assets/bw-front-animated/shiny/19.png','shiny retains independent atlas')
local Anim={shownBattler=function(_,b)return b end};local native=function()return'native'end
local P={national=function(n)return n end,frontPic=native,backPic=native};local mons={{mon=normal},{mon=normal},{mon=shiny},{mon=shiny}};local drawn={};local double=false
local UI={battlerPic=function(side,b)return(side=='player'and P.backPic or P.frontPic)(b.mon.species,0)end,draw=function()
 drawn={}
 for id=0,(double and 3 or 1)do Anim.shownBattler(id,mons[id+1]);drawn[id]=(id%2==0 and P.backPic or P.frontPic)(19,0).image end
end}
package.loaded['src.core.GameVersion']={generation=function()return 3 end}
package.loaded['src.core.game3.pokemon']=P;package.loaded['src.core.game3.battle.ui']=UI;package.loaded['src.core.game3.battle.anim']=Anim
local Native=assert(loadfile('lib/NativeBattleArt.lua'))(V);Native.fit=function(image)return image end;Native.install()
UI.draw();local first=drawn[1];clock=.251;UI.draw();check(drawn[1]~=first,'native single enemy advances atlas frame')
double=true;clock=0;UI.draw();local firstNormal,firstShiny=drawn[1],drawn[3];clock=.251;UI.draw()
check(drawn[1]~=firstNormal and drawn[3]~=firstShiny,'both native double enemies advance')
check(drawn[1].source:find('/normal/19.png',1,true)and drawn[3].source:find('/shiny/19.png',1,true),'same-species doubles retain shiny identity while animating')
check(P.frontPic(19,0)=='native','non-battle picture owner unchanged')
custom=true;Animated.invalidate();check(Animated.definitionFor({mon=normal},'front')==normalCustom,'newly installed custom atlas retains precedence')
front='gen2';check(Animated.definitionFor({mon=normal},'front')==data('animated_battle_sprites_gen2').RATTATA.front,'other front generation unchanged')
mode='rom';check(Animated.picture(normal,'front')==nil,'ROM option preserves native image')
hooks['core.quit_to_launcher'](function()end)
print('PASS native BW front animations '..checks..' checks')
