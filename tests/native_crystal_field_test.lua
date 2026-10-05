local active,mode,version=true,'all','leafgreen';local hooks={};local avatar='NORMAL'
local original={};local custom={};local overridden=false
local Sprites={get=function()return original end,getDraw=function()return overridden and custom or original end,
 getReflectionDraw=function()return original end,pose=function()return 99,false end,
 playerGraphicsId=function()return 0 end,avatarState=function()return avatar end}
package.loaded['src.core.game3.ow_sprites']=Sprites;package.loaded['src.core.game3.player']={}
package.loaded['src.core.GameVersion']={get=function()return version end}
package.loaded['src.render.Assets']={register=function()end,image=function()return{getDimensions=function()return 16,96 end,setFilter=function()end}end}
love={graphics={newQuad=function()return{release=function()end}end}}
local opts={crystalPlayerSprite='gold_flip.png'}
local V={mod={path='mod',options={get=function(_,k)return k=='crystalTrainers'and mode or opts[k]end},
 hooks={wrap=function(_,name,fn)hooks[name]=fn end}},require=function()return{active=function()return active end}end}
local M=assert(loadfile('lib/NativeCrystalField.lua'))(V);local undo=M.install()
hooks['core.update'](function()end,{})
local hero=Sprites.getDraw(0);assert(hero.crystalNative and hero.width==16 and hero.frameCount==6)
local f,flip=Sprites.pose(hero,'down',1,true);assert(f==3 and flip)
f,flip=Sprites.pose(hero,'right',1,false);assert(f==5 and flip)
assert(Sprites.pose(hero,'down',0,false,{frame=4})==4)
assert(Sprites.pose(hero,'down',0,false,{frame=99})==5)
assert(Sprites.getReflectionDraw(0)==hero)
assert(Sprites.getDraw(80).crystalNative and Sprites.getDraw(120)==original,'NPC or Pokemon ownership')
version='emerald';assert(Sprites.getDraw(80)==original,'FRLG id leaked to Hoenn');version='leafgreen'
overridden=true;assert(Sprites.getDraw(0)==custom,'provider skin stolen');overridden=false
avatar='FISHING';assert(Sprites.getDraw(0)==original);avatar='MACH_BIKE';assert(Sprites.getDraw(0).crystalNative)
mode='both';assert(Sprites.getDraw(0)==original and Sprites.getDraw(80)==original)
mode='all';active=false;assert(Sprites.getDraw(0)==original)
undo();assert(Sprites.pose(original,'down',0,false)==99)
print('PASS native Crystal field mode, six-frame poses, reflections, avatar actions, FRLG NPC scope and provider precedence')
