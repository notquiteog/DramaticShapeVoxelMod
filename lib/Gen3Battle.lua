-- Presentation seam for the native FRLG battle engine. Keep its complete UI,
-- sprite/particle ordering, intro, hit sequencer and end-of-battle lifecycle.
-- Only the static background is replaced, on the engine's separate world plane.
local V=...
local M={active=false,rendered=0}
local setting=V.require('ModSetting').new('fireredBattleStage','3D BATTLE STAGE',
 {true,false},{'ON','OFF'})
M.setting=setting
function M.enabled()return setting:get()==true end
-- Face the clearest nearby ground without moving a player or changing a map.
function M.openYaw(x,y,walkable)
 local best,yaw=-math.huge,0
 for i,d in ipairs({{0,-1},{1,0},{0,1},{-1,0}})do
  local score=0
  for n=1,9 do for lateral=-2,2 do
   if walkable(x+d[1]*n+d[2]*lateral,y+d[2]*n-d[1]*lateral)then score=score+10-n end
  end end
  if score>best then best,yaw=score,(i-1)*math.pi/2 end
 end
 return yaw
end
function M.openArea(x,y,walkable)
 local best,center=-math.huge,{x*16+8,y*16+8}
 for oy=-5,5 do for ox=-5,5 do
  local cx,cy=x+ox,y+oy
  if walkable(cx,cy)then
   local score=-(ox*ox+oy*oy)*.7
   for dy=-3,3 do for dx=-3,3 do
    if walkable(cx+dx,cy+dy)then score=score+1 end
   end end
   if score>best then best,center=score,{cx*16+8,cy*16+8}end
  end
 end end
 return center
end
function M.install()
 local Battle=require('src.core.game3.battle')
 local Bg=require('src.core.game3.battle.bg')
 local Display=require('src.core.game3.display')
 local Renderer=require('src.render.Renderer')
 local Scene=V.require('Gen3Scene')
 local original,bg=Battle.draw,Bg.draw
 local Hud=V.require('Gen3BattleHud')
 local uninstallHud=Hud.install(M)
 M.hud=Hud
 local drawing,failed=false,false
 local camera={level=7,yaw=0,pitch=.38,battle=true}
 local battleState
 Bg.draw=function(...)
  if drawing then return true end
  return bg(...)
 end
 Battle.draw=function(game,w,h)
  M.active=false;Hud.reset()
  if failed or not M.enabled() or not Battle.isActive() or Display.planesBroken
     or Scene.nativeRequired(game) then return original(game,w,h)end
  if battleState~=Battle._st then
   local Player=require('src.core.game3.player')
   local Collision=require('src.core.game3.collision')
   local px,py=math.floor((Player.px or 0)/16),math.floor((Player.py or 0)/16)
   camera.center=M.openArea(px,py,Collision.isWalkable)
   camera.yaw=M.openYaw(math.floor(camera.center[1]/16),math.floor(camera.center[2]/16),Collision.isWalkable)
   battleState=Battle._st
  end
  local G=love.graphics
  local ui=G.getCanvas()
  local ok,ready=pcall(function()
   Renderer:beginWorldPass()
   local vw,vh=Renderer:worldViewSize()
   return Scene.draw(game,vw,vh,camera)
  end)
  Scene.restore()
  Renderer:endWorldPass()
  G.setCanvas(ui)
  if not ok or not ready then
   Renderer.worldActive=false;Renderer:setWorldOverride(nil)
   if not ok then
    failed=true;print('[Battle Art FireRed] battle stage fallback: '..tostring(ready))
   end
   return original(game,w,h)
  end
  Renderer.uiOpaque=false
  G.clear(0,0,0,0)
  M.active=true;M.rendered=M.rendered+1
  drawing=true;Hud.begin()
  local drawn,err=pcall(original,game,w,h)
  drawing=false;Hud.finish()
  if not drawn then error(err,0)end
 end
 return function()
  uninstallHud();Battle.draw=original;Bg.draw=bg;M.active=false
 end
end
return M
