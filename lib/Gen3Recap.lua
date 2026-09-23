-- Render recorded Quest Log scenery through the selected camera without moving
-- the live player, replaying scripts, or advancing any recorded actor twice.
local V=...
local M={}
function M.install(camera)
 local UI=require('src.ui.game3.quest_log')
 local Display=require('src.core.game3.display')
 local Renderer=require('src.render.Renderer')
 local Tilt=require('src.render.Tilt')
 local Scene=V.require('Gen3Scene')
 local Map=require('src.core.game3.map')
 local Font=require('src.ui.game3.frlg_font')
 local Strings=require('src.core.Strings')
 local Chrome=require('src.ui.game3.pokedex_chrome')
 local draw,presentUi=UI.draw,Display.presentUi
 local current
 Display.presentUi=function(game,w,h,kind,...)
  if kind~='quest' or camera.level==0 then return presentUi(game,w,h,kind,...)end
  current=game
  local level,angle=Tilt.level,Tilt.angle;Tilt.level,Tilt.angle=0,0
  local ok,result=pcall(presentUi,game,w,h,kind,...)
  current=nil;Tilt.level,Tilt.angle=level,angle
  if not ok then error(result,0)end
  return result
 end
 UI.draw=function(playback,session)
  local game=current
  local scene=playback:current();local frame=playback:frame()
  local def=game and scene and game.data.maps[scene.map]
  if not (game and camera.level>0 and frame and def)then return draw(playback,session)end
  Map.ensureMidLayout(game,scene.map,def)
  if not def.midLayout then return draw(playback,session)end
  local cam={level=camera.level,yaw=camera.yaw,pitch=camera.pitch,replay={def=def,scene=scene,frame=frame}}
  love.graphics.clear(0,0,0,0);Renderer.uiOpaque=false
  Renderer:beginWorldPass()
  local vw,vh=Renderer:worldViewSize()
  local ok,result=pcall(Scene.draw,game,vw,vh,cam)
  if not ok then Scene.restore()end
  Renderer:endWorldPass()
  if not ok or not result then
   Renderer.uiOpaque=true;Renderer.worldOverride=nil
   if not ok then print('[Battle Art recap] '..tostring(result))end
   return draw(playback,session)
  end
  camera.active=true;M.lastMap=scene.map;M.frames=(M.frames or 0)+1
  -- Preserve the native title, recorded-event text and NEXT/SKIP controls on
  -- the crisp UI plane. Playback/input remain entirely engine-owned.
  love.graphics.setShader();love.graphics.setColor(.12,.16,.18,.94)
  love.graphics.rectangle('fill',0,0,240,18);love.graphics.rectangle('fill',0,144,240,16)
  local title=UI.text('PreviouslyOnYourQuest',{},session)
  if not playback:isFinal()then title=title..' '..playback:number()end
  Font.draw(title,2,2,{colors=Font.COLOR.WHITE})
  local e=playback:event()
  if e then
   local text=Font.wrap(UI.text(e.key,e.args,session):gsub('\n',' '),232,{})
   local lines=1;for _ in text:gmatch('\n')do lines=lines+1 end
   local y=144-math.max(32,lines*16)
   love.graphics.setColor(.12,.16,.18,.94);love.graphics.rectangle('fill',0,y,240,144-y)
   Font.draw(text,4,y,{colors=Font.COLOR.WHITE})
  end
  Chrome.drawControlInfoLeft(Strings('{A_BUTTON}NEXT   {B_BUTTON}SKIP'),4,146)
 end
 return function()UI.draw=draw;Display.presentUi=presentUi;current=nil end
end
return M
