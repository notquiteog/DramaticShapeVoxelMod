-- Native artwork capture owns no battle state and must unwind every graphics
-- wrapper even when the engine draw fails. UI and intermediary canvases stay UI.
local Mat=dofile('lib/Mat4.lua')
local current='ui';local stack={};local drawn={};local allocated=0
local g={}
function g.getCanvas()return current end
function g.setCanvas(c)current=c end
function g.push()stack[#stack+1]=current end
function g.pop()current=table.remove(stack)end
function g.newCanvas(w,h,opts)
 allocated=allocated+1;assert(w==240 and h==160 and opts.dpiscale==1)
 return {setFilter=function()end,release=function()end}
end
for _,k in ipairs({'setScissor','clear','setDepthMode'})do g[k]=function()end end
for _,k in ipairs({'draw','rectangle','circle','ellipse','line','polygon','points'})do
 g[k]=function(...)drawn[#drawn+1]={kind=k,canvas=current,args={...}}end
end
love={graphics=g}
local light,art={},{}
local placement="auto"
local R={vp=Mat.identity(),draw=function()end,seams=function()end,lighting=function()end}
local modules={NativeGen3SendoutShell={draw=function()return false end,clear=function()end},StandingTrainer={prepare=function()end,draw=function()end,clear=function()end},ShadowMap={snug=function(m)return Mat.mul(Mat.translate(0,.45,0),m)end},Gen3Capture={active=function()return false end,target=function()end,intake=function()end,prepare=function()end,draw=function()end},BattleArt={backPlacementSetting={get=function()return placement end}},Mat4=Mat,Voxel3D=R,Gen3SpriteLight=light,NativeBattleArt=art,
 SpriteHeadBounds={get=function()return {0,0,64,64}end},
 BattleBillboard={mesh=function()return {}end,yawToward=function()return 0 end},
 UiBackplates={spritesUnlit=function()return false end}}
local V={require=function(k)return assert(modules[k],k)end}
modules.Gen3XDActors={prepare=function()end,draw=function()return false end,clear=function()end}
modules.Gen3Battle={enabled=function()return false end}
modules.NativeGen3SendoutShell.owner=function(c)return c.owner end
modules.NativeGen3Release=assert(loadfile('lib/NativeGen3Release.lua'))(V)
modules.NativeGen3CaptureTint=assert(loadfile('lib/NativeGen3CaptureTint.lua'))(V)
package.loaded['src.core.game3.battle.ui']={battlerSpriteCenter=function(id)return id%2==0 and 72 or 176,id%2==0 and 80 or 40 end}
package.loaded['src.core.game3.battle.anim_coords']={battler=function()return {species=6}end,coords=function(_,id)return {y=id%2==0 and 80 or 40}end}
package.loaded['src.core.game3.pokemon']={}
package.loaded['src.core.game3.battle.anim']={vm=function()return nil end}
local M=assert(loadfile('lib/Gen3BattleActors.lua'))(V)
local f=M.new({double=true});local a,b={},{};f:tag(a,0);f:tag(b,1)
local original={};for k,v in pairs(g)do original[k]=v end
f:capture(function()
 f.inWorld=true;g.draw(a,72,80);g.draw(a,72,80);g.draw(b,176,40)
 g.circle('fill',90,60,4)
 g.rectangle('fill',0,0,240,160)
 g.setCanvas('temporary');g.draw(a,0,0);g.setCanvas('ui')
 f.inWorld=false;g.draw(a,10,10)
end)
assert(#f.cards==3 and f.byId[0]and f.byId[1],'mask redraws must share one actor card')
assert(drawn[5].canvas=='ui'and drawn[6].canvas=='temporary'and drawn[7].canvas=='ui','full-screen flash, source fitting and HUD must not become world actors')
assert(allocated==3 and current=='ui'and #stack==0)
for k,v in pairs(original)do assert(g[k]==v,'leaked '..k)end
assert(not light.world and not art.world)
local ok=pcall(function()f:capture(function()f.inWorld=true;error('native failure')end)end)
assert(not ok and not f.inWorld and not light.world and not art.world)
for k,v in pairs(original)do assert(g[k]==v,'error leaked '..k)end
f:prepare({center={100,100},yaw=0},3,{100,30,200});f:draw()
local lit,casters={},{}
R.draw=function(_,_,model,_,sun)lit[#lit+1]={model,sun}end
f:draw();f:draw(function(_,_,model)casters[#casters+1]=model end)
assert(#lit==3 and #casters==2)
for i=1,#casters do
 local pair=lit[i]
 assert(pair[2] and pair[1]~=pair[2],'actor must retain its original visible placement')
 for k=1,16 do assert(math.abs(pair[2][k]-casters[i][k])<1e-9,'lit shadow lookup and caster must agree')end
 assert(math.abs(pair[2][8]-pair[1][8]-.45)<1e-9,'thin actor contact compensation missing')
end
local ball=f:effectPoint(176,64,true)
assert(ball[2]==4.5,'capture ball must settle exactly one radius above the world floor')
assert(f:effectPoint(176,64,true,2)[2]==5,'custom ball radius must retain ground contact')
for id=0,1 do
 local c=f.byId[id];local m=c.model
 local u,v=c.ax/240-.5,1-c.ay/160
 local y=m[5]*u+m[6]*v+m[8]
 assert(math.abs(y-3)<1e-6,'sprite foot must meet world floor')
 assert(m[2]==0 and m[10]==0,'billboards must stay upright')
end
local x=f:head(0,72,48)[1];R.vp=Mat.scale(3,3,3)
assert(f:head(0,72,48)[1]==x,'HUD must retain the actor pass projection')
-- Blink-only suppression must not move a target's card into native screen UI.
local ui=package.loaded['src.core.game3.battle.ui']
ui.targetHidden=function(id)return id==1 end
local hidden=M.new({double=true});hidden:anchor(1,b)
hidden:prepare({center={100,100},yaw=0},3,{100,30,200});hidden:draw()
local retained=hidden:head(1,176,8)
assert(retained and #hidden.cards==0,'hidden target needs projection without duplicate actor')
local prior=f.byId[1];local model=hidden.hiddenHeads[1].model
for i=1,16 do assert(math.abs(model[i]-prior.model[i])<1e-6,'blink projection drift '..i)end
ui.targetHidden=function()return false end
hidden:prepare({center={100,100},yaw=0},3,{100,30,200})
assert(hidden:head(1,176,8)==nil,'do not fabricate cards for unrelated absent actors')
local p=M.placement({center={0,0},yaw=math.pi/2},0,false,0)
assert(math.abs(p[1]+24)<1e-6 and math.abs(p[3])<1e-6,'arena orientation is shared by every actor')
for id=0,3 do
 local ordinary=M.placement({center={0,0},yaw=0},id,true,0)
 local nativePair=M.placement({center={0,0},yaw=0,sceneLayout='gen3-native-pair'},id,true,0)
 assert(ordinary[1]==(id<2 and -32 or 32)and nativePair[1]==(id<2 and -12 or 12),'layout-specific pair span')
 assert(ordinary[2]==nativePair[2]and ordinary[3]==(id%2==0 and 24 or -24)
  and nativePair[3]==(id%2==0 and 40 or -40),'pair arena floor/row distance')
end
local pairBall={ball=true,owner=2,ax=72,ay=104,radius=1.5}
local pairFrame=M.new({double=true});pairFrame.cards={pairBall}
pairFrame:prepare({center={100,100},yaw=0},3,{100,30,200})
local bm=pairBall.model;local u,v=72/240-.5,1-104/160
assert(math.abs(bm[1]*u+bm[2]*v+bm[4]-pairFrame.points[2][1])<1e-6,'partner ball projected onto leading actor')
assert(math.abs(bm[5]*u+bm[6]*v+bm[8]-4.5)<1e-6,'partner ball lost floor/radius')
-- Changing the live option must affect both allied slots, without moving
-- enemies or the trainer and without producing duplicate world cards.
for _,mode in ipairs({'ui','world','auto'})do
 placement=mode
 local nextFrame=M.new({double=true});local images={}
 for id=0,5 do images[id]={};nextFrame:tag(images[id],id)end
 nextFrame:capture(function()
  nextFrame.inWorld=true
  for id=0,5 do g.draw(images[id],72,80)end
 end)
 for id=0,5 do
  local native=mode=='ui'and id<4 and id%2==0
  assert((nextFrame.byId[id]==nil)==native,'wrong placement '..mode..':'..id)
  if native then assert(nextFrame.native[id],'native ally lost attack anchor')end
 end
end
M.release()
print('PASS world battle capture, UI isolation, error unwind, grounded upright cards and retained HUD projection')
