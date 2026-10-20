-- Native move objects retain their painter and clock. Their plane follows
-- the two exact world actors exposed by the optional paired battle adapter.
local V=...
local M={}
local screen,canvas
local slots={player=true,player2=true,enemy=true,enemy2=true}
function M.actors(s)
 if not(s and s.battle and s.battle.doubles and s.anim and s.nativeAnimationActors)then return end
 local ok,a=pcall(s.nativeAnimationActors,s)
 if not(ok and type(a)=='table'and slots[a.player]and slots[a.enemy]
  and a.player~=a.enemy and a.playerMon and a.enemyMon)then return end
 local models=V.require('StadiumModels')
 local ready,owned=pcall(models.active);if not ready or owned then return end
 return a
end
function M.back(s,slot,fallback)
 local a=M.actors(s)
 if a then
  if a.player==slot then return true end
  if a.enemy==slot then return false end
 end
 return fallback
end
function M.background(s,slot)
 local a=M.actors(s)
 if a and slot~=a.player and slot~=a.enemy then return nil end
 return s and s.anim and s.anim.bg
end
function M.anchor(s,slot,mon,ax,ay,width)
 local facingBack=slot=='player'or slot=='player2'
 local back=M.back(s,slot,facingBack)
 local ok,image,_,path=pcall(s.pic,s,mon,facingBack)
 if not(ok and image)then return end
 local w,h=image:getDimensions()
 local scale=s.picScale and s:picScale(path,mon,facingBack)or 1
 if w<=0 or scale<=0 then return end
 local x=(back and 16 or 96)+(back and math.floor((48-w)/2)or math.max(0,math.floor((56-w)/2)))
 local y=back and 96-h or math.max(0,56-h)
 if scale~=1 then x=x+math.floor(w*(1-scale)/2);y=y+math.floor(h*(1-scale))end
 local foot=y+V.require('BattleSpriteFooting').bounds(image)[4]*scale
 local ratio=width/(w*scale)
 return{ax+((back and 40 or 124)-x-w*scale/2)*ratio,
  ay+((back and 72 or 28)-foot)*ratio}
end
function M.transform(shot,a)
 local heads=shot and shot.heads
 local p=heads and heads[a.player..':effect'];local e=heads and heads[a.enemy..':effect']
 local s=shot and shot.scale
 if not(p and e and type(s)=='number'and s>0
  and type(shot.pw)=='number'and type(shot.ph)=='number'
  and type(shot.lx)=='number'and type(shot.ly)=='number'
  and type(p[1])=='number'and type(p[2])=='number'
  and type(e[1])=='number'and type(e[2])=='number')then return end
 local px,py=(p[1]*shot.pw-shot.lx)/s,(p[2]*shot.ph-shot.ly)/s
 local ex,ey=(e[1]*shot.pw-shot.lx)/s,(e[2]*shot.ph-shot.ly)/s
 local dx,dy=ex-px,ey-py
 local scale=math.sqrt((dx*dx+dy*dy)/(84*84+44*44))
 if scale<.05 or scale>8 or scale~=scale then return end
 return px,py,math.atan2(dy,dx)-math.atan2(-44,84),scale
end
function M.begin(s)
 screen=s
 if M.installed or not M.actors(s)then return end
 local View=require('src.ui.gen2.BattleAnimView')
 local original=View.drawObjects
 function View:drawObjects(runner,battle,...)
  local a=M.actors(screen);local Stage=V.require('Gen2Battle')
  local drawn=V.require('Gen2Staged').drawn
  local shot=V.require('OverworldBattle').shot()
  local x,y,angle,scale
  if a and self==screen.animView and runner==screen.anim and battle==screen.battle
   and drawn[a.player]==a.playerMon and drawn[a.enemy]==a.enemyMon
   and Stage.stagedMon(a.playerMon)and Stage.stagedMon(a.enemyMon)then
   x,y,angle,scale=M.transform(shot,a)
  end
  local g=love.graphics
  if not(x and g.push and g.pop and g.rotate and g.newCanvas and g.setBlendMode)then
   return original(self,runner,battle,...)
  end
  local args={...}
  g.push('all')
  local painted=pcall(function()
   if not canvas then canvas=g.newCanvas(160,144);canvas:setFilter('nearest','nearest')end
   g.origin();g.setCanvas(canvas);g.clear(0,0,0,0);g.setScissor()
   g.setShader();g.setBlendMode('alpha','alphamultiply')
   original(self,runner,battle,unpack(args))
  end)
  g.pop()
  if not painted then return original(self,runner,battle,...)end
  g.push('all')
  local ok,err=pcall(function()
   g.setShader();g.setColor(1,1,1,1);g.setBlendMode('alpha','premultiplied')
   g.translate(x,y);g.rotate(angle);g.scale(scale);g.translate(-40,-72)
   g.draw(canvas,0,0)
  end)
  g.pop()
  if not ok then error(err,0)end
  -- The projected trajectory can cross a status card. Repaint the existing
  -- public native panel above it; this reuses its HUD-clear/text ownership
  -- and skips the already-published world bodies through Gen2Battle.
  if screen.nativeSceneLayout and screen:nativeSceneLayout()=='gen2-native-pair'
   and type(screen.drawPanel)=='function'then screen:drawPanel()end
 end
 M.installed=true
end
return M
