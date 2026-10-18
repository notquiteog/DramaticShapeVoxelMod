-- Supported native send-out shells follow the original projected ball card.
-- Native paths, visibility, lid frames, cries, particles and timers stay native.
local V=...
local M={}
local names={[0]='POKE_BALL',[1]='GREAT_BALL',[2]='SAFARI_BALL',[3]='ULTRA_BALL',[4]='MASTER_BALL'}
local entries=setmetatable({},{__mode='k'})
function M.clear()entries=setmetatable({},{__mode='k'})end
function M.nativeBall(card)
 if not(card and card.ball)then return end
 local Anim=require('src.core.game3.battle.anim')
 if Anim._headless then return end
 local stage=Anim.stage();local selected
 local function match(ball)
  if not(ball and ball.visible)then return true end
  local x,y=(ball.x or 0)+(ball.ox or 0),(ball.y or 0)+(ball.oy or 0)
  if math.abs(x-(card.ax or 0))>.01 or math.abs(y-(card.ay or 0))>.01 then return true end
  if selected then return false end
  selected=ball;return true
 end
 if not match(stage.ball)then return end
 for _,ball in pairs(stage.balls or{})do if not match(ball)then return end end
 return selected
end
function M.owner(card)
 local b=M.nativeBall(card);local id=b and b.battler
 local balls=require('src.core.game3.battle.anim').stage().balls
 if type(id)=='number'and id>=0 and id<=3 and id%1==0
  and balls and balls[id]==b then return id end
end
function M.shell(st,card)
 if not(st and card and card.ball and card.model)
  or not V.require('PokeballSettings').active()or not V.require('Gen3Battle').enabled()then return end
 if require('src.core.game3.battle.catch_seq').busy()then return end
 local b=M.nativeBall(card);local name=b and names[b.ballId or 0]
 if st.double and M.owner(card)==nil then return end
 if not name or (b.darken or 0)~=0 or (b.flash or 0)~=0
  or (b.alpha or 1)~=1 or b.blend then return end
 local entry=entries[b]
 if not entry or entry.owner~=st or entry.name~=name then
  entry={owner=st,name=name,shell=V.require('Pokeball').new(name)};entries[b]=entry
 end
 local shell,m=entry.shell,card.model
 local u,v=(card.ax or 0)/240-.5,1-(card.ay or 0)/160
 shell.scale=V.require('PokeballSettings').scale()
 local radius=V.require('Pokeball').R*shell.scale
 shell.pos={m[1]*u+m[2]*v+m[4],m[5]*u+m[6]*v+m[8]+radius-(card.radius or 1.5),m[9]*u+m[10]*v+m[12]}
 -- Matrix X axis gives the native card's facing, independent of camera orbit.
 shell.yaw=math.atan2(-m[9],m[1]);shell.rollAngle=-(tonumber(b.rot)or 0)
 shell.lid=math.max(0,math.min(2,tonumber(b.frame)or 0))/2
 shell.lidTarget=shell.lid;shell.visible=true
 return shell,b
end
function M.draw(st,card,shadow)
 local ok,shell=pcall(M.shell,st,card)
 if not ok or not shell then return false end
 if shadow then
  local cast=pcall(shell.cast,shell,shadow);return cast
 end
 local drawn,result=pcall(shell.drawShell,shell,0)
 return drawn and result==true
end
return M
