local n=0;local function check(v,m)n=n+1;assert(v,m)end
local active,color,covered=true,true,false
local Options={drawing=true,scale={get=function()return'scaled'end},covered=function()return covered end,
 ui={hudUsesColor=function()return color end}}
local stage={active=true};local st={};local Battle={_st=st};local boxes={}
local palette={0,1,2,3};local frame={Ux=2,Uy=2};local calls=0;local layers={}
package.loaded['src.core.game3.battle']=Battle
package.loaded['src.core.game3.battle.anim']={stage=function()return{healthbox=boxes}end}
package.loaded['src.core.game3.battle.healthbox']={center=function(state,id)return{y=state.double and 20+id*20 or id%2==0 and 88 or 30}end}
package.loaded['src.ui.game3.battle_chrome']={manifest=function()return{healthboxPal=palette}end}
package.loaded['src.render.Renderer']={frameRects=function()return frame end}
package.loaded['src.core.GameVersion']={get=function()return'firered'end}
local V={require=function(name)
 if name=='Gen3BattleOptions'then return Options end
 if name=='ModernBattleUI'then return{providerEnabled=function()return active end}end
 assert(name=='NativeHudLayer');return{scale=function(mode,r)check(mode=='scaled'and r==frame,'uses shared option and frame scale');return .5 end,
 draw=function(owner,w,h,s,x,y,pal,fn,...)layers[#layers+1]={w=w,h=h,s=s,x=x,y=y,pal=pal};return fn(...)end}
end}
local M=assert(loadfile('lib/NativeGen3Hud.lua'))(V)
local mon={};local options={ox=12,oy=8}
local function native(side,b,opts)calls=calls+1;check(b==mon and opts==options,'native mon/options identity preserved');return side end
check(M.draw(native,stage,'player',mon,options)=='player','original return preserved')
check(layers[1].x==240 and layers[1].y==72 and not layers[1].pal,'native player scale anchor and COLOR unchanged')
color=false;M.draw(native,stage,1,mon,options)
check(layers[2].x==0 and layers[2].y==14 and layers[2].pal==palette,'INVERTED uses public original palette')
boxes.player={levelUpBlend={}};M.draw(native,stage,0,mon,options)
check(not layers[3].pal,'level-up flash retains native palette feedback');boxes={}
options.st={double=true};M.draw(native,stage,2,mon,options)
check(layers[4].x==240 and layers[4].y==44,'doubles use native per-slot center');options.st=nil
st.safari=true;M.draw(native,stage,'player',mon,options);check(#layers==5,'native Safari healthbox consumes scale and palette');st.safari=nil
local expectedLayers=#layers
package.loaded['src.ui.game3.battle_chrome'].manifest=function()return{}end
M.draw(native,stage,1,mon,options);check(layers[#layers].pal and layers[#layers].pal[2]==8456,'FRLG fixed native text palette fallback')
package.loaded['src.core.GameVersion'].get=function()return'emerald'end
M.draw(native,stage,1,mon,options);check(not layers[#layers].pal,'unavailable Hoenn palette retains original colors')
local before=#layers
for _,mode in ipairs({'covered','outside','disabled','provider'})do
 covered=mode=='covered';Options.drawing=mode~='outside';stage.active=mode~='disabled';active=mode~='provider'
 M.draw(native,stage,'enemy',mon,options)
end
check(#layers==before,'covering menus/outside stage/independent provider keep original drawing')
check(calls==11,'native methods draw exactly once')
print('PASS '..n..' native Gen3 HUD contracts')
