local n=0;local function check(v,m)n=n+1;assert(v,m)end
local function image(id,w,h)return{id=id,getDimensions=function()return w or 64,h or 64 end}end
local native,selected,other=image('native'),image('selected'),image('other',32,32)
local draws={};local fail=false
love={graphics={draw=function(tex,x,y)draws[#draws+1]={tex,x,y};if fail then error('draw fail')end end}}
local draw=love.graphics.draw;local session={}
package.loaded['src.core.game3.runtime']={getSession=function()return session end}
local Card={open=true,side='front',_session=session}
Card.draw=function()
 love.graphics.draw(other,165,44);love.graphics.draw(native,0,0)
 love.graphics.draw(native,Card._rse and 152 or 165,Card._rse and 40 or 44)
 return 'native-card'
end
local RS={open=true,side='front',_session=session,_man={pic={x=160,y=40}}}
RS.draw=function()love.graphics.draw(native,160,40)end
local Intro={drawPic=function(self)love.graphics.draw(self.pic.image,88,16);return 'intro'end}
local Birch={drawSprite=function(_,s,w,h)love.graphics.draw(s.img,w,h);return s.frame end}
local RSBirch={drawSprite=Birch.drawSprite}
local Trainer={front=function()return{image=native,w=64,h=64}end}
local originalFront=Trainer.front
local Hall={open=true,_session=session,_player={pic=7,x=192},draw=function()love.graphics.draw(Trainer.front(7).image,160,40)end}
local hallDraw=Hall.draw
package.loaded['src.core.game3.trainer_pic']=Trainer
package.loaded['src.ui.game3.hall_of_fame']=Hall
local originals={Card.draw,RS.draw,Intro.drawPic,Birch.drawSprite,RSBirch.drawSprite}
package.loaded['src.ui.game3.trainer_card']=Card
package.loaded['src.ui.game3.rs.trainer_card']=RS
package.loaded['src.ui.game3.new_game_scene']=Intro
package.loaded['src.ui.game3.rse.birch_speech']=Birch
package.loaded['src.ui.game3.rs.birch_speech']=RSBirch
package.loaded['src.ui.game3.rse.scene_kit']={manifest=function()return{picOffset={0,0}}end}
local active=true;local pose
local V={require=function(name)
 if name=='NativeCrystalArt'then return{player=function(side)pose=side;return active and selected or nil end}end
 assert(name=='NativeBattleArt');return{fit=function(img,size,mirror)assert(size==64 and mirror==false);return img end}
end}
local P=assert(loadfile('lib/NativeCrystalPortraits.lua'))(V);local undo=P.install()
check(Card.draw()=='native-card'and draws[#draws][1]==selected and pose=='front','FRLG local card consumes front portrait')
check(draws[1][1]==other and draws[2][1]==native,'unrelated draw dimensions and position retain native art')
Card._rse=true;Card.draw();check(draws[#draws][1]==selected,'Emerald manifest slot')
RS.draw();check(draws[#draws][1]==selected,'RS manifest slot')
RS._link=true;RS.draw();check(draws[#draws][1]==native,'remote link card retains peer identity');RS._link=false
Card._session={};Card.draw();check(draws[#draws][1]==native,'nonlocal session retains native portrait');Card._session=session
Card.side='back';Card.draw();check(draws[#draws][1]==native,'card back untouched');Card.side='front'
active=false;Card.draw();check(draws[#draws][1]==native,'disabled/default/missing art uses native');active=true
fail=true;check(not pcall(Card.draw)and love.graphics.draw==draw,'card render failure restores graphics draw');fail=false
local pic={image=native,slot=16};local intro=setmetatable({pic=pic,assets={boySprite=native},bg2X=60},{__index=Intro})
check(intro:drawPic()=='intro'and draws[#draws][1]==selected and pic.image==native and intro.bg2X==60,'FRLG intro restores player asset and position')
intro.assets={oakSprite=native};intro:drawPic();check(draws[#draws][1]==native,'professor/rival images untouched')
intro.assets={girlSprite=native};fail=true;check(not pcall(intro.drawPic,intro)and pic.image==native,'intro render error restores picture');fail=false
for _,B in ipairs({Birch,RSBirch})do
 local s={img=native,frame=3,scale=.5,invisible=false};local birch=setmetatable({sprites={brendan=s}},{__index=B})
 check(birch:drawSprite(s,64,64)==0 and draws[#draws][1]==selected,'Hoenn player uses single fitted frame')
 check(s.img==native and s.frame==3 and s.scale==.5 and not s.invisible,'Hoenn animation/fade/geometry state preserved')
 birch.sprites={lotad=s};birch:drawSprite(s,64,64);check(draws[#draws][1]==native,'Hoenn professor/mon art retains native ownership')
 birch.sprites={may=s};fail=true;check(not pcall(birch.drawSprite,birch,s,64,64)and s.img==native and s.frame==3,'Hoenn error restores sheet/frame');fail=false
end
Hall.draw();check(draws[#draws][1]==selected and Trainer.front==originalFront and Hall._player.x==192,'Hall of Fame selected local portrait and restored reader')
Hall._session={};Hall.draw();check(draws[#draws][1]==native,'Hall of Fame remote identity fallback');Hall._session=session
fail=true;check(not pcall(Hall.draw)and Trainer.front==originalFront,'Hall of Fame failure restores reader');fail=false
undo();check(Hall.draw==hallDraw,'Hall of Fame unload restores reader')
check(Card.draw==originals[1]and RS.draw==originals[2]and Intro.drawPic==originals[3]and Birch.drawSprite==originals[4]and RSBirch.drawSprite==originals[5],'all native public draw methods restored')
print('PASS '..n..' native Crystal portrait contracts')
