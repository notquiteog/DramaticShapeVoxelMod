-- Persistent model instances for the native GBA battle's four actor slots.
-- Native presentation visibility is authoritative; missing art keeps its card.
local V=...
local M={}
local held={}
local owner
local function enabled()return V.require('VisualStyles').modern('pokemon') and V.require('XDModels').active()end
local function release(id)
 local e=held[id]
 if e and e.instance then pcall(e.instance.release,e.instance)end
 held[id]=nil
end
function M.clear()
 for id in pairs(held)do release(id)end
 owner=nil
end
function M.context(id,name)
 if not enabled()then return end
 local e=held[id]
 if e and e.instance then
  local ok=e.instance:playContext(name,false)
  if ok then e.context=name end
 end
end
function M.install()
 local Anim=require('src.core.game3.battle.anim')
 local move,faint=Anim.launchMove,Anim.faintMon
 local moveHook=function(moveId,opts)
  local result=move(moveId,opts)
  if result~=false and enabled()then
   pcall(function()
    local def=require('src.core.game3.battle.moves').get(moveId)
    local id=opts and(opts.attackerId or Anim.idOf(opts.attackerSide))or 0
    M.context(id or 0,def.category=='physical'and'attack'or'special')
   end)
  end
  return result
 end
 local faintHook=function(id,opts)
  pcall(M.context,Anim.idOf(id or'enemy')or 1,'faint')
  return faint(id,opts)
 end
 Anim.launchMove,Anim.faintMon=moveHook,faintHook
 return function()
  if Anim.launchMove==moveHook then Anim.launchMove=move end
  if Anim.faintMon==faintHook then Anim.faintMon=faint end
  M.clear()
 end
end
function M.prepare(frame)
 frame.xdActors=nil
 local pack=V.require('XDModels')
 if not enabled()then M.clear();return end
 if owner~=frame.st then M.clear();owner=frame.st end
 local Pokemon=require('src.core.game3.pokemon')
 local Coords=require('src.core.game3.battle.anim_coords')
 local Anim=require('src.core.game3.battle.anim')
 local Mat=V.require('Mat4')
 frame.xdActors={}
 for id=0,3 do
  local b=Coords.battler(frame.st,id)
  local mon=b and b.mon
  local dex=b and Pokemon.national(b.species or(mon and Pokemon.speciesOf(mon)))
  local variant=mon and Pokemon.isShiny(mon)and'shiny'or'normal'
  local p=Anim.present(id)
  local form=pack.formFor and pack.formFor(b,dex,p)or nil
  local e=held[id]
  if e and(e.battler~=b or e.dex~=dex or e.variant~=variant or e.form~=form)then release(id);e=nil end
  if not e and b and dex then
   local ok,instance=pcall(pack.newInstance,dex,variant,{form=form})
   if not ok then instance=nil end
   e={battler=b,dex=dex,variant=variant,form=form,instance=instance}
   held[id]=e
  end
  local card=frame.byId[id]
  local Ui=require('src.core.game3.battle.ui')
  local ghost=Ui.showsGhost and Ui.showsGhost(id%2==0 and'player'or'enemy',frame.st)
  if e and e.instance and card and p and p.visible~=false
   and not p.substitute and not p.pendingTransform and not ghost then
   local metric=e.instance:metrics()
   local height=math.max(5,math.min(18,14*math.sqrt(metric.height)))
   local scale=height/metric.height*(p.scale or 1)
   local point=frame.points[id]
   -- A physical model faces the opposite battle row, independent of orbit.
   local target=frame.points[id%2==0 and 1 or 0]
   local yaw=target and math.atan2(target[1]-point[1],target[3]-point[3])or 0
   e.matrix=Mat.mul(Mat.translate(point[1],point[2]-(p.oy or 0)*frame.PIXEL,point[3]),
    Mat.mul(Mat.rotateY(yaw),Mat.mul(Mat.scale(scale,scale,scale),
     Mat.translate(0,-metric.floor,0))))
   -- Time is updated once per prepared frame, never once per shadow/light pass.
   e.instance:update(love.timer.getDelta())
   if e.context and e.context~='faint'and e.instance:isFinished()then
    e.instance:playContext('idle',true);e.context=nil
   elseif not e.context and(tonumber(p.flash)or 0)>0 then M.context(id,'damage')end
   e.height=height
   frame.xdActors[id]=e
  end
 end
end
function M.draw(frame,card,shadow)
 if not enabled()then M.clear();frame.xdActors=nil;return false end
 local e=frame.xdActors and frame.xdActors[card.id]
 if not(e and e.instance)then return false end
 local draw=shadow or V.require('Voxel3D').draw
 local ok,result=pcall(e.instance.drawWith,e.instance,draw,e.matrix)
 if not ok or not result then release(card.id);frame.xdActors[card.id]=nil;return false end
 return true
end
return M
