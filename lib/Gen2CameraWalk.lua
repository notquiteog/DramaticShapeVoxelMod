-- Camera-relative native grid intent, plus opt-in continuous walking through
-- the same native move/arrival transactions. Specials retain native timing.
local V=...
local M={}
function M.available()
  local ok,World=pcall(require,"src.world.gen2.World")
  return ok and type(World.pollInput)=="function"
end
function M.direction(x,z)
  if x*x+z*z<.01 then return nil end
  if math.abs(x)>math.abs(z) then return x>0 and "right" or "left" end
  return z>0 and "down" or "up"
end
function M.install()
  local World=require("src.world.gen2.World")
  if World.battleArtCameraWalk then return end
  local inner=World.pollInput
  if type(inner)~="function" then return end
  World.battleArtCameraWalk=true
  local FP=V.require("FirstPerson")
  function World:pollInput(input)
    if not FP.driving() or self:busy() then return inner(self,input) end
    local mx,mz=FP.moveVector()
    local x,z=FP.moveWorld(mx,mz)
    local dir=M.direction(x,z)
    -- Only the d-pad reads in pollInput are transformed. The actual input
    -- object (A/B, menus, held-source bookkeeping) is never modified.
    local proxy={isDown=function(_,key)
      if key=="up" or key=="down" or key=="left" or key=="right" then return key==dir end
      return input and input:isDown(key) or false
    end}
    return inner(self,proxy)
  end
  if type(World.movePlayer)~='function'or type(World.stepBody)~='function'then return end
  local Free=V.require('NativeFreeMove');local Mode=V.require('MovementMode')
  local Permissions=require('src.world.gen2.Permissions')
  local FieldMoves=require('src.world.gen2.FieldMoves')
  local Bike=require('src.world.gen2.Bike')
  local Runtime=require('src.mods.Runtime')
  local Player=require('src.world.gen2.Player')
  local move,body=World.movePlayer,World.stepBody
  local currentPlayer
  local function enabled(world)
    return Mode.free()and FP.driving()and not world:busy()
  end
  function World:movePlayer(dir)
    local p=self.player
    local mx,mz=FP.moveVector();local wx,wz=FP.moveWorld(mx,mz)
    local coll=self:playerCollision()
    local forced=Permissions.currentDirection(coll)or Permissions.doorForcedDirection(coll)
      or Permissions.isIce(coll)or Permissions.isWhirlpool(coll)or self:downhill()
    if not enabled(self)or forced or FieldMoves.isBiking(self.playerState)
      or dir~=M.direction(wx,wz)or p.jumping then
      Free.drop(p,false);return move(self,dir)
    end
    local b=Free.sync(p,self.map);if not b then return move(self,dir)end
    p.facing=FP.pointBody(wx,wz);p.turnArmed=false
    local frames=Bike.stepFrames(self.playerState,dir,false,Player.STEP_FRAMES)
    if Runtime.wantsHook('movement.speed')then
      frames=Runtime.call('movement.speed',function(value)return value end,frames,{
        onBike=false,surfing=FieldMoves.isSurfing(self.playerState),downhill=false,
        playerState=self.playerState,player=p,input=self.game and self.game.input,
        save=self.game and self.game.save})
    end
    local function blocked(x,z)
      return Free.probe(p,x,z,function(ax,az,bx,bz,direction)
        local map=self.map
        if not map:inBounds(bx,bz)then return false,'bounds'end
        if not Permissions.stepPermitted(function(cx,cz)return self:cellCollisionAcross(map,cx,cz)end,ax,az,direction)then return false,'tile'end
        local walkable=FieldMoves.isSurfing(self.playerState)and Permissions.surfable(map:cellCollision(bx,bz))~=nil or map:isWalkable(bx,bz)
        if not walkable then return false,'tile'end
        local npc=self:npcAt(bx,bz)
        if npc and npc~=p and not npc.passable then return false,'entity'end
        for _,e in ipairs(self.entities or{})do
          if e~=p and not e.passable and(e.cellX==bx and e.cellY==bz or e.moving and e.targetX==bx and e.targetY==bz)then return false,'entity'end
        end
        return true
      end)
    end
    local result=Free.advance(b,p,wx,wz,16/math.max(1,tonumber(frames)or 16),blocked,function(direction)
      local state=self.playerState
      local native=move(self,direction)
      if native=='moved'and p.moving and not p.jumping and self.playerState==state
        and math.abs(p.targetX-p.cellX)+math.abs(p.targetY-p.cellY)==1 then return 'ordinary',native end
      if native and native~='blocked'and native~='turned'then return 'special',native end
      return nil,native
    end)
    if Free.body(p)and b.moving then p.bumpFrames=2 end
    return result or 'free'
  end
  function World:stepBody()
    local p=self.player;currentPlayer=p;local b=p and Free.body(p)
    if b then b.moving=false end
    if p and(not Mode.free()or not FP.driving())then Free.drop(p,true)end
    local result=body(self)
    -- Run after the native arrival/event chain, before World:step updates its
    -- follower. A warp/script/battle owns its new position and is never undone.
    if p and p==self.player and Free.body(p)then
      if enabled(self)then
        local restored=Free.sync(p,self.map)
        if restored and restored.moving then p.bumpFrames=2 end
      elseif p.moving and not Free.body(p).pending then Free.drop(p,false)end
    end
    return result
  end
  if V.mod and V.mod.hooks then V.mod.hooks:wrap('core.quit_to_launcher',function(next,...)
    if currentPlayer then Free.drop(currentPlayer,true)end
    World.pollInput,World.movePlayer,World.stepBody=inner,move,body
    World.battleArtCameraWalk=nil
    return next(...)
  end)end
end
return M
