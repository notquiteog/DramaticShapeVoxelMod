local checks=0
local function check(v,why)checks=checks+1;assert(v,why)end
local mons={{species=25,mon={personality=1,isShiny=true}},{species=25,mon={personality=2,isShiny=false}},
 {species=25,mon={personality=3,isShiny=false}},{species=25,mon={personality=4,isShiny=true}}}
local Anim={shownBattler=function(_,mon)return mon end}
local originalShown=Anim.shownBattler
local native=function()return 'native'end
local P={frontPic=native,backPic=native,national=function(s)return s end}
local seen={};local failure=false
local UI={draw=function()
 for id=0,3 do
  Anim.shownBattler(id,mons[id+1])
  local pic=id%2==0 and P.backPic(25,0)or P.frontPic(25,0)
  check(pic.image.mon.personality==id+1,'slot identity before native draw')
 end
 if failure then error('native battle draw error')end
end,battlerPic=function(side,battler,species)
 Anim.shownBattler(side,mons[1]) -- native live lookup must not replace explicit caller mon
 return P.frontPic(species,0)
end}
local originalDraw,originalPic=UI.draw,UI.battlerPic
package.loaded['src.core.GameVersion']={generation=function()return 3 end}
package.loaded['src.core.game3.pokemon']=P
package.loaded['src.core.game3.battle.ui']=UI
package.loaded['src.core.game3.battle.anim']=Anim
local flipped=true;local Art={playerSide=function()return 'front'end,flipsPlayerFront=function()return flipped end}
local Animated={picture=function(mon,side)seen[#seen+1]={mon=mon,side=side};return {mon=mon}end}
local hooks={}
local V={require=function(name)return assert(({BattleArt=Art,AnimatedBattleArt=Animated,Gen3SpriteLight={scope=function(fn,...)return fn(...)end,tag=function(v)return v end},Gen3TrainerArt={install=function()return function()end end}})[name],name)end,
 mod={hooks={wrap=function(_,key,fn)hooks[key]=fn end}}}
local Adapter=assert(loadfile('lib/NativeBattleArt.lua'))(V)
local mirrored={}
Adapter.fit=function(image,size,mirror)mirrored[#mirrored+1]=mirror;return image end
Adapter.install();UI.draw()
check(seen[1].mon.isShiny and not seen[3].mon.isShiny,'same-species allied shiny context remains distinct')
check(not seen[2].mon.isShiny and seen[4].mon.isShiny,'same-species enemy shiny context remains distinct')
check(mirrored[1] and not mirrored[2],'selected player fronts use FLIP FRONT only on allied native back calls')
local pic=UI.battlerPic(2,mons[3],25)
check(pic.image.mon.personality==3,'HUD head bounds use explicit displayed battler')
check(P.frontPic(25,0)=='native','field/interface calls retain native owner')
failure=true;check(not pcall(UI.draw),'native failure is propagated')
check(P.frontPic(25,0)=='native','active scope restored after native error')
hooks['core.quit_to_launcher'](function()end)
check(P.frontPic==native and P.backPic==native and Anim.shownBattler==originalShown,'unload restores image/identity providers')
check(UI.draw==originalDraw and UI.battlerPic==originalPic,'unload restores UI owners')

package.loaded['src.core.GameVersion']={generation=function()return 2 end}
local progress,slug,portraitState
local State={pic=function()return 'native species'end,drawScene=function(self)
 portraitState={self.playerBackImage,self.enemyTrainerImage,self.playerBackTrueColor,self.enemyTrainerTrueColor}
 if failure then error('portrait failure')end
 return 'scene'
end}
package.loaded['src.ui.gen2.BattleState']=State
local art2={playerSide=function()return 'back'end,trainerImage=function(name)slug=name;return 'selected enemy'end}
local animated2={picture=function()return nil end,playerTrainerPicture=function(offset)progress=offset;return 'selected player'end}
local V2={mod={hooks={wrap=function(_,key,fn)hooks[key]=fn end}},require=function(name)return ({BattleArt=art2,AnimatedBattleArt=animated2})[name]end}
local Adapter2=assert(loadfile('lib/NativeBattleArt.lua'))(V2);Adapter2.install()
local screen=setmetatable({showPlayerTrainer=true,showEnemyTrainer=true,enemyTrainerClass='BUG_CATCHER',backpicSlide=8,
 playerBackImage='native player',enemyTrainerImage='native enemy',playerBackTrueColor=false,enemyTrainerTrueColor=false},{__index=State})
failure=false;screen:drawScene()
check(portraitState[1]=='selected player' and portraitState[2]=='selected enemy','native trainer scene receives selected portraits')
check(portraitState[3] and portraitState[4] and progress==32 and slug=='bug-catcher','native slide and trainer key feed shared art')
check(screen.playerBackImage=='native player' and screen.enemyTrainerTrueColor==false,'native fields restored after trainer draw')
failure=true;check(not pcall(screen.drawScene,screen) and screen.enemyTrainerImage=='native enemy','portrait failure restores native owner')
failure=false;V2.crystalSpritesActive=true;screen:drawScene()
check(portraitState[1]=='native player','Crystal trainer ownership retained')
hooks['core.quit_to_launcher'](function()end)
print('PASS '..checks..' native battle identity checks')
