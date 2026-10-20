local drawCount,seen=0
local playback={current=function()return{map='ROOM'}end,frame=function()return{px=16,py=32}end,
 isFinal=function()return true end,event=function()end}
local UI={draw=function()drawCount=drawCount+1 end,text=function()return'Quest'end}
local Display={presentUi=function()return UI.draw(playback,{})end}
local Renderer={beginWorldPass=function()end,endWorldPass=function()end,worldViewSize=function()return 240,160 end}
local Tilt={level=2,angle=.3}
package.loaded['src.ui.game3.quest_log']=UI
package.loaded['src.core.game3.display']=Display
package.loaded['src.render.Renderer']=Renderer
package.loaded['src.render.Tilt']=Tilt
package.loaded['src.core.game3.map']={ensureMidLayout=function()end}
package.loaded['src.ui.game3.frlg_font']={draw=function()end,COLOR={WHITE=1}}
package.loaded['src.core.Strings']=function(s)return s end
package.loaded['src.ui.game3.pokedex_chrome']={drawControlInfoLeft=function()end}
love={graphics={clear=function()end,setShader=function()end,setColor=function()end,rectangle=function()end}}
local scene={draw=function(_,_,_,cam)seen=cam;return true end}
local camera={level=7,yaw=.6,pitch=.2,angle=.7,boomZoom=1.8,boomBlend=.4}
local mod=assert(loadfile('lib/Gen3Recap.lua'))({require=function(name)assert(name=='Gen3Scene');return scene end})
local restore=mod.install(camera)
local game={data={maps={ROOM={midLayout={}}}}}
Display.presentUi(game,240,160,'quest')
for _,key in ipairs({'level','yaw','pitch','angle','boomZoom','boomBlend'})do
 assert(seen[key]==camera[key],'recap reset camera '..key)
end
assert(seen~=camera and seen.replay.frame.px==16 and Tilt.level==2 and Tilt.angle==.3)
camera.level=0;Display.presentUi(game,240,160,'quest');assert(drawCount==1,'OFF did not preserve native recap')
restore();UI.draw();assert(drawCount==2,'recap adapter did not restore native UI')
print('PASS recorded scenes retain live zoom, angle and mode interpolation; native OFF/cleanup preserved')
