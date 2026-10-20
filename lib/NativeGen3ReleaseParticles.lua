-- Original BallOpen particles have no per-particle owner. Only an exclusive
-- public start epoch proves ownership; overlapping or anonymous starts retain
-- the existing native projection until the original subsystem becomes idle.
local V=...
local M={}
local drawOwner,epoch
local function pack(...)return{n=select('#',...),...}end
function M.clear()drawOwner,epoch=nil,nil end
function M.owner(st)
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
  local previous=drawOwner;drawOwner=safeValid(epoch)and epoch or nil
  local result=pack(pcall(original,...));drawOwner=previous
  if not result[1]then error(result[2],0)end
  return unpack(result,2,result.n)
 end)
 return function()
  M.clear()
  for key,original in pairs(originals)do if Ball[key]==wrappers[key]then Ball[key]=original end end
 end
end
return M
