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
local R={vp=Mat.identity(),draw=function()end,seams=function()end,lighting=function()end}
local modules={Mat4=Mat,Voxel3D=R,Gen3SpriteLight=light,NativeBattleArt=art,
 SpriteHeadBounds={get=function()return {0,0,64,64}end},
 BattleBillboard={mesh=function()return {}end,yawToward=function()return 0 end},
 UiBackplates={spritesUnlit=function()return false end}}
local V={require=function(k)return assert(modules[k],k)end}
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
local ball=f:effectPoint(176,64,true)
assert(ball[2]==5,'capture ball must settle exactly one radius above the world floor')
for id=0,1 do
 local c=f.byId[id];local m=c.model
 local u,v=c.ax/240-.5,1-c.ay/160
 local y=m[5]*u+m[6]*v+m[8]
 assert(math.abs(y-3)<1e-6,'sprite foot must meet world floor')
 assert(m[2]==0 and m[10]==0,'billboards must stay upright')
end
local x=f:head(0,72,48)[1];R.vp=Mat.scale(3,3,3)
assert(f:head(0,72,48)[1]==x,'HUD must retain the actor pass projection')
local p=M.placement({center={0,0},yaw=math.pi/2},0,false,0)
assert(math.abs(p[1]+24)<1e-6 and math.abs(p[3])<1e-6,'arena orientation is shared by every actor')
M.release()
print('PASS world battle capture, UI isolation, error unwind, grounded upright cards and retained HUD projection')
