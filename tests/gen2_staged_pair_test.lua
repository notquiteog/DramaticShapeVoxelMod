local releaseStaged
package.loaded['src.render.Assets']={register=function(owner)releaseStaged=owner.release end}
local shadeCalls=0
local paletteCalls=0;local Palette={mode='gbc',available=function()return true end,with=function(colors,fn)paletteCalls=paletteCalls+1;assert(colors[1]==1);return fn()end}
Palette.remap=function(colors,byte)assert(byte==0xe4);shadeCalls=shadeCalls+1;return colors end
package.loaded['src.render.GbcPalette']=Palette
local draws={}
local function pic(w,h)return {getDimensions=function()return w,h end} end
local first,second={hp=10},{hp=10}
local screen={battle={doubles={},enemy2=second}}
local shownPartner
function screen:activeMon(side)
 if side=='player2'or side=='enemy2'then return shownPartner or self.battle[side]end
 return first
end
function screen:pic(mon)return mon==first and pic(56,56) or pic(64,48) end
local target
local captureOwned=false
local placement='world'
local selected=false
local front=false
local flip=true
local mapped,anchorFailure=false,false
local actorEffects,releaseCue=false,nil;local effectPaints=0
love={graphics={
 newCanvas=function(w,h)return {canvas=true,getWidth=function()return w end,getHeight=function()return h end,setFilter=function()end} end,
 getCanvas=function()return target end,setCanvas=function(v)target=v end,
 getColor=function()return 1,1,1,1 end,setColor=function()end,clear=function()end,
 draw=function(img,x,y)if img.canvas then return end;local w,h=img:getDimensions();draws[#draws+1]={x=x,y=y,w=w,h=h} end,
}}
local M=assert(loadfile('lib/Gen2Staged.lua'))({require=function(name)
 if name=='NativeGen2MoveProjection'then return{
  background=function(s)return s.anim and s.anim.bg end,actors=function()return mapped and{}or nil end,
  back=function(s,slot,fallback)return fallback end,
  anchor=function()if anchorFailure=='error'then error('native pic unavailable')end;return not anchorFailure and{80,100}or nil end,
  begin=function()end}end
 if name=='NativeGen2ActorEffects'then return{owner=function()return actorEffects end,begin=function()end,paint=function()effectPaints=effectPaints+1 end}end
 if name=='NativeGen2Sendout'then return{paired=function()return releaseCue end}end
 if name=='BattleSpriteFooting'then return {bounds=function(image,quad)local w,h=image:getDimensions();if quad and quad.getViewport then local x,y;x,y,w,h=quad:getViewport()end;return {0,0,w,h-7}end}end
 if name=='NativeGen2PictureBands'then return assert(loadfile('lib/NativeGen2PictureBands.lua'))()end
 if name=='NativeGen2PairPicture'then return assert(loadfile('lib/NativeGen2PairPicture.lua'))()end
 if name=='Gen2Capture'then return {active=function()return captureOwned end}end
 if name=='Generation' then return {isGen2=function()return true end} end
 if name=='BattleScene' then return {GB_W=160,GB_H=144} end
 if name=='NativeBattleArt'then return {image=function()return selected and pic(56,56) or nil end}end
 if name=='BattleArt'then return {backPlacementSetting={get=function()return placement end},
  playerSide=function()return front and 'front' or 'back'end,flipsPlayerFront=function()return flip end}end
 error(name)
end})
local game={stack={states={screen}}}
mapped=true
for _,failure in ipairs({true,'error'})do
 anchorFailure=failure
 assert(not M.sideTexture(game,'enemy')and not M.drawn.enemy and not M.drawn.enemy2,
  'missing native projection claimed a paired body')
end
anchorFailure=false;assert(M.sideTexture(game,'enemy').hudAnchors['enemy2:effect'])
mapped=false
assert(M.textures(game).sceneLayout==nil,'standalone acquired a companion layout')
screen.nativeSceneLayout=function()return 'gen2-native-pair'end
assert(M.textures(game).sceneLayout=='gen2-native-pair','public native layout hint lost')
screen.nativeSceneLayout=function()error('layout unavailable')end
assert(M.textures(game).sceneLayout==nil,'failed layout reader retained stale metadata')
screen.nativeSceneLayout=function()return {}end
assert(M.textures(game).sceneLayout==nil,'invalid layout metadata accepted')
screen.nativeSceneLayout=nil;draws={}
local texture=assert(M.sideTexture(game,'enemy'))
assert(#draws==2,'both complete partner images must draw')
assert(texture.contentWidth==draws[1].w+draws[2].w,'pair composition lost separate source widths')
assert(draws[1].y+draws[1].h==draws[2].y+draws[2].h,'feet not aligned')
assert(M.drawn.enemy==first and M.drawn.enemy2==second,'flat replay must skip both rendered bodies')
assert(draws[1].y+draws[1].h-7==texture.ay,'transparent image padding raised visible feet')
assert(target==nil,'previous render target not restored')
-- Queue-owned shown partners can differ from the already-advanced core slot.
local nextPartner={hp=10};screen.battle.enemy2=nextPartner;shownPartner=second
assert(M.sideTexture(game,'enemy')and M.drawn.enemy2==second,'core replacement stole the outgoing native picture')
shownPartner=nil;screen.battle.enemy2=second
local pairPic=screen.pic;screen.pic=function(self,mon,back)if mon~=second then return pairPic(self,mon,back)end end
assert(M.sideTexture(game,'enemy')==nil and M.drawn.enemy==nil and M.drawn.enemy2==nil,'missing partner art must release the whole native side')
screen.pic=pairPic
local pairIdentity=screen.activeMon;screen.activeMon=function(self,side)if side=='enemy2'then error('provider unavailable')end;return pairIdentity(self,side)end
assert(M.sideTexture(game,'enemy')==nil and M.drawn.enemy==nil,'failed partner reader claimed native side')
screen.activeMon=pairIdentity
print('PASS public shown-partner identity and unavailable-pair native ownership')

local back=assert(M.sideTexture(game,'player'))
assert(back.noMirror==true,'native back sprites must not receive the Gen 1 front-pic mirror')
assert(back.modernFraming,'Crystal enables wider scene framing')
placement='ui';assert(M.sideTexture(game,'player')==nil,'OG UI must release the native back slot')
placement='world';selected=true;front=true
assert(M.sideTexture(game,'player').noMirror==false,'selected player fronts honor front flip')
flip=false;assert(M.sideTexture(game,'player').noMirror==true,'DEFAULT retains player-front orientation')
screen.showPlayerTrainer=true;assert(M.sideTexture(game,'player')==nil,'intro trainer owns the native slot before sending out')
print('staged pair dimensions, separation, ground line and ownership passed')
-- A public animation-wide foot row preserves a raised frame instead of
-- snapping each frame independently onto the floor.
screen.showPlayerTrainer=false;selected=false;front=false
local animated=pic(56,56)
game.mods={exports={crystal_animated_sprites_with_shiny_visuals={
 stagedPokemonSprite=function()return {image=animated,width=56,height=56,groundY=52}end}}}
local moving=assert(M.sideTexture(game,'player'))
local last=draws[#draws]
assert(last.y+49==moving.ay-3,'authored three-pixel hop was flattened')
print('PASS provider animation foot row retains raised poses')

-- Public native visibility/resize state must also govern the world card.
screen.battle.doubles=nil;screen.battle.enemy2=nil;game.mods=nil
local hidden,underground,sink=false,false,0;local pose
screen.picBoxCleared=function()return hidden end
screen.isUnderground=function()return underground end
screen.faintSink=function()return sink end
screen.animPicState=function()return pose end
hidden=true;assert(M.sideTexture(game,'enemy')==nil and M.drawn.enemy==nil)
hidden=false;underground=true;assert(M.sideTexture(game,'enemy')==nil)
screen.anim={};screen.vanishAnim=screen.anim;assert(M.sideTexture(game,'enemy'),'native reveal owns underground reappearance')
underground=false;screen.vanishAnim=nil
for _,p in ipairs({{lifted={1,2}},{pic='substitute'}})do
 pose=p;assert(M.sideTexture(game,'enemy')==nil and M.drawn.enemy==nil,'native composite owns its fallback')
end
pose=nil;first.volatile={substitute=10};assert(M.sideTexture(game,'enemy')==nil)
pose={pic='mon'};assert(M.sideTexture(game,'enemy'),'native explicit mon overrides substitute')
first.volatile=nil;sink=8;assert(M.sideTexture(game,'enemy')==nil);sink=0
local scaled;love.graphics.draw=function(img,x,y,angle,sx,sy)scaled={x=x,y=y,sx=sx,sy=sy}end
pose={size=2,slide=8};local small=assert(M.sideTexture(game,'enemy'))
assert(scaled.sx==2/7 and scaled.sy==2/7,'native resize square')
assert(math.abs(scaled.x-(small.ax-8+8))<1e-9 and math.abs(scaled.y-(small.ay-49*2/7))<1e-9,'native slide and fixed foot')
screen.battle.doubles=true;assert(M.sideTexture(game,'enemy')==nil,'paired animation keeps native identity')
print('PASS native GSC hidden/underground/reveal/resize/slide and composite/faint/substitute fallback ownership')

screen.battle.doubles=nil;hidden=true;captureOwned=true
assert(M.sideTexture(game,'enemy'),'supported 3D capture keeps its own intake card')
captureOwned=false;assert(M.sideTexture(game,'enemy')==nil,'native hidden state resumes after capture')
print('PASS supported capture keeps exclusive enemy-card visibility ownership')

hidden=false;pose=nil;screen.palettes={};first.species='SENTRET'
first.shiny=true
screen.cachedMonColors=function(_,species,shiny)assert(species=='SENTRET'and shiny==true);return{1,2,3,4}end
assert(M.sideTexture(game,'enemy')and paletteCalls==1,'native indexed species palette')
selected=true;assert(M.sideTexture(game,'enemy')and paletteCalls==1,'selected RGBA retains provider colors');selected=false
pose={size=2,shade=0xe4};assert(M.sideTexture(game,'enemy')and shadeCalls==1,'native shade remap preserves resized world actor');pose=nil
local sheet,quad=pic(112,56),{}
screen.frontAnimFrame=function(mon)return sheet,quad,56 end
local img,w,h,q=M.picFor(game,screen,first,false)
assert(img==sheet and w==56 and h==56 and q==quad,'native Crystal front animation frame')
print('PASS native indexed/shiny palette ownership and original Crystal frame reader')

-- Native faint rows remain on the world card, with full graphics restoration.
screen.frontAnimFrame=nil;pose=nil;screen.anim=nil
local scissor={2,3,40,50};local seenClip;local failDraw=false
love.graphics.getScissor=function()return unpack(scissor)end
love.graphics.setScissor=function(...)scissor={...}end
love.graphics.draw=function(img,...)if failDraw then error('fixture draw failed')end;seenClip={unpack(scissor)};scaled={...}end
sink=8;local faint=assert(M.sideTexture(game,'enemy'))
assert(scaled[2]==faint.ay-49+8 and seenClip[4]==faint.ay,'native sink clipped at fixed world ground')
assert(scissor[1]==2 and scissor[4]==50 and target==nil,'scissor/canvas restored')
local originalPic=screen.pic
screen.pic=function()return pic(48,48),true end;selected=true
local fitted=assert(M.sideTexture(game,'player'))
assert(math.abs(scaled[2]-(fitted.ay-49+8*56/48))<1e-9,'larger selected frame follows native fitted-slot faint progress')
screen.pic=originalPic;selected=false
sink=64;assert(M.sideTexture(game,'enemy')and M.drawn.enemy==first,'fully sunk card keeps flat slot suppressed')
failDraw=true;assert(M.sideTexture(game,'enemy')==nil and M.drawn.enemy==nil,'failed crop returns native ownership')
assert(scissor[1]==2 and scissor[4]==50 and target==nil,'failed crop restores graphics');failDraw=false;sink=0

-- The native doll stays small and uses native facing/mon palette even with
-- selected RGBA Pokemon art; no species-sized substitute is invented.
local doll=pic(16,32);local dq={getViewport=function()return 0,16,16,16 end}
screen.substituteDoll=function(_,back)assert(back==true);return doll,dq end
first.volatile={substitute=10};selected=true
local usedImage,usedQuad;love.graphics.draw=function(img,q,x,y)usedImage,usedQuad=img,q;scaled={x,y}end
local before=paletteCalls;local sub=assert(M.sideTexture(game,'player'))
assert(usedImage==doll and usedQuad==dq and scaled[1]==sub.ax-8 and scaled[2]==sub.ay-9,'original doll art/facing/16px width')
assert(sub.contentWidth==56 and paletteCalls==before+1,'doll retains actor metrics and indexed palette')
pose={pic='mon'};assert(M.sideTexture(game,'player')and usedImage~=doll,'native explicit mon restores selected body')
pose=nil;screen.battle.doubles=true;assert(M.sideTexture(game,'player'),'idle doubles substitute uses the original doll')
first.volatile=nil;second.volatile={substitute=10};second.species='SENTRET';second.shiny=true;screen.battle.player2=second
local bodies={};love.graphics.draw=function(img,...)if not img.canvas then bodies[#bodies+1]=img end end
local pairedDoll=assert(M.sideTexture(game,'player'))
assert(#bodies==2 and bodies[1]~=doll and bodies[2]==doll,'partner doll replaced wrong actor')
assert(M.drawn.player==first and M.drawn.player2==second and pairedDoll.hudAnchors.player2,'independent partner ownership')
second.volatile=nil
local nativeFaint=screen.faintSink;screen.faintSink=function(_,slot)return slot=='player2'and 8 or 0 end
screen.faintSlide={side='player2',frames=2};second.hp=0
assert(M.sideTexture(game,'player')and M.drawn.player2==second,'fainting zero-HP partner vanished before its native crop')
screen.faintSink=nativeFaint;screen.faintSlide=nil;second.hp=10
local visibility=screen.picBoxCleared;screen.picBoxCleared=function(_,slot)return slot=='player2'end
bodies={};assert(M.sideTexture(game,'player')and #bodies==1 and M.drawn.player2==second,'hidden partner painted or released native identity')
screen.picBoxCleared=visibility;screen.battle.player2=nil
print('PASS native faint crop/empty ownership/error restoration and substitute identity/size/palette')

-- Original lifted rows compose inside the same world card without changing
-- runner state, and the native BGP mapping restores even after an error.
first.volatile=nil;screen.battle.doubles=nil;selected=false;pose={lifted={2,1},slide=8}
package.loaded['src.ui.gen2.BattleAnimView']={scanlines=function()local t={};for row=0,143 do t[#t+1]={src=row,dest=row,dx=0}end;return t end}
screen.anim={bg={bgp=0x1b}}
local bgp=0xe4;Palette.setBgp=function(byte)local old=bgp;bgp=byte;return old end
local passes={};love.graphics.draw=function(img,x,y)passes[#passes+1]={x,y,bgp}end
local lifted=assert(M.sideTexture(game,'enemy'))
assert(#passes==3 and passes[1][1]==passes[3][1]+8 and passes[3][3]==0x1b,'native split band and BGP')
assert(bgp==0xe4 and scissor[1]==2,'native palette/scissor restored')
love.graphics.draw=function()error('band fixture failure')end
assert(M.sideTexture(game,'enemy')==nil and bgp==0xe4 and scissor[1]==2,'failed band restores palette and native ownership')
print('PASS native lifted rows and scoped BGP in staged pictures')

local available=Palette.available;Palette.available=function()return false end
screen.anim.bg.lcdc='BGP'
assert(M.sideTexture(game,'enemy')==nil and M.drawn.enemy==nil,'shaderless BGP keeps native veil ownership')
Palette.available=available
print('PASS shaderless native BGP fallback')

-- Substitute pictures ignore mon resize, stay16px, and keep their slide even
-- in the final lifted pass (the native doll placement overrides that X).
screen.anim.bg={scx=4,bgp=0xe4};pose={size=2,lifted={4,1},slide=8}
first.volatile={substitute=10};selected=true
local dollPasses={};love.graphics.draw=function(img,q,x,y,rotation,sx)
 assert(img==doll and q==dq,'combined effect retains native doll image')
 dollPasses[#dollPasses+1]={x=x,y=y,scale=sx}
end
local mixed=assert(M.sideTexture(game,'player'))
assert(M.drawn.player==first and mixed.contentWidth==56,'doll LCD retains original actor metrics')
assert(#dollPasses>=2,'both raster base and lifted doll band drawn')
local shifted,fixed=false,false
for _,p in ipairs(dollPasses)do
 assert((p.scale or 1)==1,'native doll ignores Pokemon resize')
 shifted=shifted or p.x==mixed.ax-8+8-4
 fixed=fixed or p.x==mixed.ax-8+8
end
assert(shifted and fixed,'doll raster scroll and original lifted slide compose')
assert(scissor[1]==2 and bgp==0xe4,'combined doll restores render state')
love.graphics.draw=function()error('combined doll failure')end
assert(M.sideTexture(game,'player')==nil and M.drawn.player==nil,'failed combined doll restores native ownership')
assert(scissor[1]==2 and bgp==0xe4,'failed combined doll restores state')
print('PASS substitute LCD/lifted combination preserves native16px slide/palette and cleanup')
first.volatile=nil;selected=false;pose={lifted={4,1},slide=8};screen.anim.bg={scx=4,bgp=0xe4}
local faintPasses={};love.graphics.draw=function(img,x,y)faintPasses[#faintPasses+1]={x=x,y=y,clip={unpack(scissor)}}end
sink=0;local base=assert(M.sideTexture(game,'player'));local baseY=faintPasses[1].y
faintPasses={};sink=8;local faintMixed=assert(M.sideTexture(game,'player'))
assert(M.drawn.player==first and #faintPasses>0,'combined faint/LCD lost native actor ownership')
for _,p in ipairs(faintPasses)do
 assert(p.y==baseY+8,'native faint progress lost inside picture band')
 assert(p.clip[2]+p.clip[4]<=faintMixed.ay,'band crop escaped fixed source ground')
end
assert(scissor[1]==2 and bgp==0xe4 and target==nil and sink==8,'combined faint mutated clock or leaked graphics')
love.graphics.draw=function()error('combined faint failure')end
assert(M.sideTexture(game,'player')==nil and M.drawn.player==nil)
assert(scissor[1]==2 and bgp==0xe4 and target==nil,'failed combined faint crop leaked state')
print('PASS combined faint/LCD/lifted source progress, clip intersection and native/error fallback')

-- The independent native companion may identify one original sendout owner.
screen.battle.doubles=true;screen.battle.player2=second;screen.anim={bg={}}
screen.nativeAnimationSlot=function()return 'player2'end
local oldPose=screen.animPicState;screen.animPicState=function(_,slot)return slot=='player2'and{size=2}or nil end
hidden=false;pose=nil;sink=0;second.hp=10;love.graphics.draw=function()end
assert(M.sideTexture(game,'player')and M.drawn.player==first and M.drawn.player2==second,'declared partner sendout did not compose independent cards')
screen.nativeAnimationSlot=function()error('provider failed')end
assert(not M.sideTexture(game,'player'),'failed slot provider claimed paired animation')
screen.nativeAnimationSlot=nil;screen.animPicState=oldPose
print('PASS public native sendout slot enables paired composition and preserves provider-error fallback')

-- A failed body-only copy must keep the native particle canvas and graphics state.
actorEffects=true;releaseCue={};screen.nativeAnimationSlot=function()return 'player2'end
screen.animPicState=function()return nil end
local blend,alpha='alpha','alphamultiply'
love.graphics.getBlendMode=function()return blend,alpha end
love.graphics.setBlendMode=function(b,a)blend,alpha=b,a end
local failCopy=false
love.graphics.draw=function(image)
 if failCopy and image.canvas and alpha=='premultiplied'then failCopy=false;error('copy unavailable')end
end
local separate=assert(M.sideTexture(game,'player'))
assert(separate.actors[1].card.releaseCanvas and separate.actors[2].card.releaseCanvas)
assert(effectPaints==2 and target==nil and blend=='alpha'and alpha=='alphamultiply')
failCopy=true;effectPaints=0
local fallback=assert(M.sideTexture(game,'player'))
assert(not fallback.actors[1].card.releaseCanvas and fallback.actors[2].card.releaseCanvas)
assert(effectPaints==2 and target==nil and blend=='alpha'and alpha=='alphamultiply',
 'failed release copy lost native effects or graphics restoration')
print('PASS separate release body and failed-copy native particle/state fallback')

-- Mobile-sized render targets remain logical pixels and release replaced GPU
-- storage promptly; a failed size must not allocate again on every frame.
assert(type(releaseStaged)=='function','native assets cleanup not registered')
releaseStaged();screen.battle.doubles=nil;screen.battle.player2=nil
screen.nativeAnimationSlot=nil;screen.anim=nil;actorEffects=false
local spriteWidth=56;screen.pic=function()return pic(spriteWidth,56),true end
local allocations,releases=0,0;local unavailable=false
love.graphics.newCanvas=function(w,h,options)
 allocations=allocations+1;assert(options and options.dpiscale==1,'canvas scaled with display DPI')
 if unavailable then error('GPU allocation unavailable')end
 return{canvas=true,getWidth=function()return w end,getHeight=function()return h end,setFilter=function()end,
 release=function()releases=releases+1 end}
end
assert(M.sideTexture(game,'enemy'));spriteWidth=200;assert(M.sideTexture(game,'enemy'))
assert(allocations==2 and releases==1,'grown actor canvas retained old GPU allocation')
spriteWidth=400;unavailable=true
assert(not M.sideTexture(game,'enemy')and not M.sideTexture(game,'enemy'))
assert(allocations==3 and not M.drawn.enemy,'failed size retried or claimed native actor')
spriteWidth=56;assert(M.sideTexture(game,'enemy')and allocations==3,'smaller viable art lost held canvas')
M.release();assert(releases==2);spriteWidth=400;unavailable=false
assert(M.sideTexture(game,'enemy')and allocations==4,'cleanup did not permit resource retry')
M.release();assert(releases==3)
print('PASS DPI1 native canvases, prompt resize release, bounded failed allocation and cleanup retry')
