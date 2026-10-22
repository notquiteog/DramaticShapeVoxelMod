-- Prefer explicit public per-particle ownership when an engine supplies it.
-- Older BallOpen versions expose only anonymous particles: an exclusive public
-- start epoch is safe, overlapping/anonymous starts retain native projection.
local V=...
local M={}
local drawOwner,epoch
local explicitOwner,insideDraw
local function pack(...)return{n=select('#',...),...}end
function M.clear()drawOwner,epoch,insideDraw=nil,nil,nil end
function M.owner(st)
 if insideDraw and explicitOwner then
  local owner=explicitOwner()
  if owner~=nil then return owner and owner.state==st and owner.id or nil end
 end
 if drawOwner and drawOwner.state==st then return drawOwner.id end
end
-- Preserve the complete native particle picture around the original actor
-- anchor. The renderer supplies its existing actor ground/world placement.
function M.point(frame,card,providerOwns)
 local id=card.releaseOwner
 if providerOwns or id==nil then return end
 local anchor=frame.native[id];local point=frame.points[id]
 if not(anchor and point)then return end
 return point,card.ax-anchor.x,card.ay-anchor.foot
end
function M.install()
 local Ball=require('src.core.game3.battle.ball_open')
 local Battle=require('src.core.game3.battle')
 local Coords=require('src.core.game3.battle.anim_coords')
 local originals,wrappers={},{}
 local function eligible()
  local stage=V.require('Gen3Battle')
  return Battle._st and Battle.isActive()and stage.active and stage.enabled()
   and V.require('PokeballSettings').active()
 end
 local function valid(e)
  return e and eligible()and e.state==Battle._st and Coords.battler(e.state,e.id)==e.actor
   and e.actor.mon==e.mon
 end
 local function safeValid(e)local ok,value=pcall(valid,e);return ok and value end
 -- Optional engine capability: queried during each particle's graphics draw.
 -- The engine supplies original state/actor/mon identities, not inferred XY.
 -- Absent or anonymous ownership retains the conservative exclusive epoch.
 explicitOwner=function()
  if type(Ball.currentParticleOwner)~='function'then return end
  local ok,e=pcall(Ball.currentParticleOwner)
  if ok and e==nil then return end
  if ok and type(e)=='table'and type(e.id)=='number'and e.id%1==0
   and e.id>=0 and e.id<=3 and safeValid(e)then return e end
  return false -- Invalid explicit ownership must not acquire the epoch owner.
 end
 local function wrap(key,fn)
  local original=Ball[key]
  if type(original)~='function'then return false end
  originals[key]=original;wrappers[key]=function(...)return fn(original,...)end
  Ball[key]=wrappers[key];return true
 end
 -- Install only against the complete public lifecycle; partial versions keep
 -- their original rendering rather than claiming an exclusive epoch.
 for _,key in ipairs({'start','startParticles','spawnSprite','reset','tick','draw','active'})do
  if type(Ball[key])~='function'then return function()end end
 end
 wrap('start',function(original,id,...)
  epoch=nil
  local read,idle,state,key,actor=pcall(function()
   local state=eligible()and Battle._st;local key=Coords.fixedId(id)
   return not Ball.active(),state,key,state and key and Coords.battler(state,key)
  end)
  local result=pack(pcall(original,id,...))
  if result[1]and read and idle and actor and type(key)=='number'and key>=0 and key<=3 and key%1==0 then
   epoch={state=state,id=key,actor=actor,mon=actor.mon}
  end
  if not result[1]then error(result[2],0)end
  return unpack(result,2,result.n)
 end)
 for _,key in ipairs({'startParticles','spawnSprite'})do wrap(key,function(original,...)
  epoch=nil;return original(...)
 end)end
 wrap('reset',function(original,...)M.clear();return original(...)end)
 wrap('tick',function(original,...)
  local result=pack(original(...))
  if not Ball.active()or not safeValid(epoch)then epoch=nil end
  return unpack(result,1,result.n)
 end)
 wrap('draw',function(original,...)
  local previous,previousInside=drawOwner,insideDraw;drawOwner=safeValid(epoch)and epoch or nil
  insideDraw=true
  local result=pack(pcall(original,...));drawOwner,insideDraw=previous,previousInside
  if not result[1]then error(result[2],0)end
  return unpack(result,2,result.n)
 end)
 return function()
  M.clear();explicitOwner=nil
  for key,original in pairs(originals)do if Ball[key]==wrappers[key]then Ball[key]=original end end
 end
end
return M
