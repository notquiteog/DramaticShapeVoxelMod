local time=0;local selected='selected';local options={crystalAnimations='loop'}
local images={};local loaded=0
package.loaded['src.render.Assets']={image=function(path)
 if path:find('/252/')then error('absent')end
 loaded=loaded+1;images[path]=images[path]or{path=path,setFilter=function()end};return images[path]
end,register=function()end}
love={timer={getTime=function()return time end}}
local settings={setting={get=function()return selected end},schemas=function()return{{key='crystalFront'},{key='crystalAnimations'},{key='crystalTrainers'}}end}
local V={mod={path='mod',options={get=function(_,key)return options[key]end}},require=function(n)
 return ({CrystalSprites=settings,['Crystal/animation_data']={normal={['6']={100,200,300}},shiny={['6']={150,150,200}}},
 BattleArt={isShiny=function(b)return b.mon.isShiny end}})[n]
end}
local C=assert(loadfile('lib/NativeCrystalArt.lua'))(V)
assert(settings.setting.defaultIndex==2 and not C.active()and not C.image({species=6},'front')and loaded==0)
selected='crystal';assert(C.active());local first,frames=C.image({species=6},'front');assert(#frames==3)
time=.12;assert(C.image({species=6},'front')==frames[2]);time=.4;assert(C.image({species=6},'front')==frames[3])
time=.62;assert(C.image({species=6},'front')==first,'LOOP timing incorrect')
options.crystalAnimations='once';time=1.5;assert(C.image({species=6},'front')==frames[3],'PLAY ONCE did not hold')
C.begin({});assert(C.image({species=6},'front')==first,'new battle did not reset once animation')
assert(C.image({species=6,isShiny=true},'front')~=first,'shiny identity mixed')
assert(not C.image({species=252},'front'),'unavailable species replaced')
assert(C.image({species=6},'back').path:find('/back/normal/6.png'))
options.crystalFront=true;assert(C.front());selected='selected';assert(not C.front())
assert(#C.schemas()==3)
selected='crystal';options.crystalTrainers='none';assert(not C.player()and not C.opponent('brock'))
options.crystalTrainers='both';options.crystalPlayerSprite='gold_flip.png';local p,flip=C.player();assert(p.path:find('gold_flip.png')and flip)
options.crystalBattlePic='back';p,flip=C.player();assert(p.path:find('/back/gold.png')and not flip)
assert(C.opponent('bug-catcher').path:find('bugcatcher.png'))
options.crystalTrainers='overworld';assert(not C.player()and not C.opponent('brock'))
print('PASS native Crystal pack opt-in/default, LOOP/ONCE authentic timing, session reset, shiny/back/fallback and preference scope')
