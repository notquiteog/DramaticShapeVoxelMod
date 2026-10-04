-- Native battle timing and menus, with its live actor/effect artwork projected
-- into the same scene, depth buffer and shadow map as the field.
local V=...
local M={active=false,rendered=0}
local setting=V.require('ModSetting').new('battles','3D-BTL',
 {true,false},{'ON','OFF'})
local read=setting.read
function setting:read()
 if not self.index and V.mod and V.mod.options then
  local value=V.mod.options:get('battles')
  if value==nil then
   local old=V.mod.options:get('fireredBattleStage')
   if type(old)=='boolean' then
    -- The native options page reads schema defaults through options:get.
    -- Keep its initial label in agreement with the migrated runtime value.
    self.defaultIndex=old and 1 or 2;self:sync(old)
   end
  end
 end
 return read(self)
end
M.setting=setting
function M.enabled()return setting:get()==true end
function M.update()
 if not require('src.core.game3.battle').isActive() or not M.enabled()then
  if M.active or M.frame then V.require('Gen3BattleActors').release()end
  M.active=false;M.frame=nil
  if M.hud then M.hud.reset()end
 end
end
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
 setting:read() -- migrate before the new schema contributes its default
 local Battle=require('src.core.game3.battle')
 local Bg=require('src.core.game3.battle.bg')
 local Display=require('src.core.game3.display')
 local Renderer=require('src.render.Renderer')
 local Scene=V.require('Gen3Scene')
 local Actors=V.require('Gen3BattleActors')
 local original,bg=Battle.draw,Bg.draw
 local Hud=V.require('Gen3BattleHud')
 local uninstallHud=Hud.install(M)
 M.hud=Hud
 local drawing=false
 local recovery=V.require('RenderRecovery').new()
 local camera={level=7,yaw=0,pitch=.38,battle=true}
 local battleState
 Bg.draw=function(...)
  if drawing then M.frame.inWorld=true;return true end
  return bg(...)
 end
 Battle.draw=function(game,w,h)
  M.active=false;M.frame=nil;Hud.reset()
  recovery:update(love.timer.getDelta())
  if not M.enabled() or not Battle.isActive() or not recovery:ready(Battle._st) or Display.planesBroken
     or Scene.nativeRequired(game) then return original(game,w,h)end
  if battleState~=Battle._st then
   local Player=require('src.core.game3.player')
   local Collision=require('src.core.game3.collision')
   local px,py=math.floor((Player.px or 0)/16),math.floor((Player.py or 0)/16)
   camera.center=M.openArea(px,py,Collision.isWalkable)
   camera.yaw=M.openYaw(math.floor(camera.center[1]/16),math.floor(camera.center[2]/16),Collision.isWalkable)
   battleState=Battle._st
   camera.arena={mid=camera.center,cameraSafe=true}
   V.require('BattleCam').reset(camera.arena)
  end
  local Map=require('src.core.game3.map')
  camera.plate=V.require('Gen3BattleBackdrop').frame(Map.current,Map.currentDef(),Battle._st)
  local G=love.graphics
  local ui=G.getCanvas()
  local Ui=require('src.core.game3.battle.ui')
  if Ui._caughtDexScene then return original(game,w,h)end
  M.frame=Actors.new(Battle._st);camera.actors=M.frame
  V.require('BattleCam').update(love.timer.getDelta())
  M.active=true;drawing=true;Hud.begin()
  G.clear(0,0,0,0)
  local drawn,err=pcall(M.frame.capture,M.frame,original,game,w,h)
  drawing=false;Hud.finish()
  if not drawn then M.active=false;M.frame=nil;error(err,0)end
  local ok,ready=pcall(function()
   Renderer:beginWorldPass()
   local vw,vh=Renderer:worldViewSize()
   return Scene.draw(game,vw,vh,camera)
  end)
  Scene.restore()
  Renderer:endWorldPass()
  G.setCanvas(ui)
  if not ok or not ready then
   M.active=false;M.frame=nil;camera.actors=nil;Hud.reset();G.clear(0,0,0,0)
   Renderer.worldActive=false;Renderer:setWorldOverride(nil)
   if not ok then
    recovery:failed(ready);Scene.invalidate();print('[Battle Art FireRed] battle stage fallback: '..tostring(ready))
   end
   return original(game,w,h)
  end
  Renderer.uiOpaque=false
  recovery:succeeded()
  M.active=true;M.rendered=M.rendered+1
 end
 return function()
  uninstallHud();Battle.draw=original;Bg.draw=bg;M.active=false;M.frame=nil;Actors.release()
 end
end
return M
