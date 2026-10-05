-- Capture the native battle's artwork, not its UI or simulation. Native draw
-- calls bake flashes, sprite transforms and masks into reusable transparent
-- cards; those cards then share the world's depth, projection and shadow pass.
local V=...
local R=V.require('Voxel3D')
local Mat=V.require('Mat4')
local Billboard=V.require('BattleBillboard')
local Bounds=V.require('SpriteHeadBounds')
local M={PIXEL=.25,W=240,H=160}
local pool={}
local function slot(id)return id=='player'and 0 or id=='enemy'and 1 or tonumber(id)end
function M.project(vp,x,y,z)
 local w=vp[13]*x+vp[14]*y+vp[15]*z+vp[16]
 if w<=0 then return nil end
 return {(vp[1]*x+vp[2]*y+vp[3]*z+vp[4])/w*.5+.5,
  (vp[5]*x+vp[6]*y+vp[7]*z+vp[8])/w*.5+.5}
end
function M.placement(camera,id,double,ground)
 local dx,dz=math.sin(camera.yaw),-math.cos(camera.yaw)
 local rx,rz=math.cos(camera.yaw),math.sin(camera.yaw)
 local back=id%2==0;local lateral=double and (id<2 and -32 or 32)or 0
 local depth=back and -24 or 24
 if id>=4 then depth=depth+(back and -10 or 10)end
 return {camera.center[1]+dx*depth+rx*lateral,ground,camera.center[2]+dz*depth+rz*lateral}
end
function M.new(st)
 local self={st=st,tags=setmetatable({},{__mode='k'}),cards={},byId={},native={},inWorld=false,used=0}
 return setmetatable(self,{__index=M})
end
function M:tag(image,id)
 id=slot(id);if image and id then self.tags[image]=id end
end
function M:anchor(id,image)
 local Ui=require('src.core.game3.battle.ui')
 local Coords=require('src.core.game3.battle.anim_coords')
 local P=require('src.core.game3.pokemon')
 if id>=4 then return id%2==0 and 80 or 176,id%2==0 and 112 or 72 end
 local b=Coords.battler(self.st,id)
 local sp=b and (b.species or b.mon and P.speciesOf(b.mon))
 local x,y=Ui.battlerSpriteCenter(id,sp,Coords.coords(self.st,id))
 local bounds=Bounds.get(image)
 self.native[id]={x=x,y=y,foot=y-32+bounds[4]}
 return x,y-32+bounds[4]
end
function M:canvas()
 self.used=self.used+1
 local c=pool[self.used]
 if not c then c=love.graphics.newCanvas(M.W,M.H,{dpiscale=1});c:setFilter('nearest','nearest');pool[self.used]=c end
 return c
end
local function drawOrigin(args)
 local n=type(args[1])=='number'and 1 or 2 -- optional Quad
 return tonumber(args[n])or 120,tonumber(args[n+1])or 60
end
function M:record(draw,image,args,primitive)
 local id=not primitive and self.tags[image]
 -- Match Gen1/2: OG UI leaves both allied Pokemon in their native slots.
 -- Trainers and opposing Pokemon still use world placement. Record the
 -- native anchor for attack paths even though this draw stays on the UI.
 if id and id<4 and id%2==0 and V.require('BattleArt').backPlacementSetting:get()=='ui' then
  self:anchor(id,image)
  return draw(image,unpack(args))
 end
 local card=id and self.byId[id]
 if not card then
  card={id=id,tex=self:canvas(),ball=not primitive and image==self.ballImage}
  if id then card.ax,card.ay=self:anchor(id,image);self.byId[id]=card
  else card.ax,card.ay=drawOrigin(args)end
  self.cards[#self.cards+1]=card
  local G=love.graphics;G.push('all');G.setCanvas(card.tex);G.setScissor();G.clear(0,0,0,0);G.pop()
 end
 local G=love.graphics;G.push('all');G.setCanvas(card.tex);G.setDepthMode()
 local ok,err=pcall(draw,image,unpack(args));G.pop()
 if not ok then error(err,0)end
end
function M:capture(fn,...)
 local G=love.graphics;local Light=V.require('Gen3SpriteLight');local Art=V.require('NativeBattleArt')
 local oldDraw,oldWorld,oldArt=G.draw,Light.world,Art.world
 local Ui=require('src.core.game3.battle.ui')
 self.ballImage=Ui.ballSheet and Ui.ballSheet()
 Light.world,Art.world=self,true
 G.draw=function(image,...)
  if self.inWorld and G.getCanvas()==self.ui then return self:record(oldDraw,image,{...})end
  return oldDraw(image,...)
 end
 local primitives={}
 for _,name in ipairs({'rectangle','circle','ellipse','line','polygon','points'})do
  local original=G[name];primitives[name]=original
  G[name]=function(...)
   local args={...}
   -- Full-screen fades belong above the complete scene, including its sky.
   local full=name=='rectangle' and args[1]=='fill' and (args[2]or 1)<=0 and (args[3]or 1)<=0 and (args[4]or 0)>=M.W and (args[5]or 0)>=M.H
   if self.inWorld and G.getCanvas()==self.ui and not full then
    return self:record(function(_,...)return original(...)end,false,args,true)
   end
   return original(...)
  end
 end
 self.ui=G.getCanvas()
 local result={pcall(fn,...)}
 for name,original in pairs(primitives)do G[name]=original end
 G.draw,Light.world,Art.world=oldDraw,oldWorld,oldArt;self.inWorld=false
 if not result[1]then error(result[2],0)end
 return unpack(result,2)
end
-- Interpolate attack travel along the selected native attacker/target pair.
-- The residual is a billboard-space offset, so a rising bolt remains vertical
-- rather than being flattened into terrain. No particle state is changed.
function M:effectPoint(x,y,ball)
 local Anim=require('src.core.game3.battle.anim');local vm=Anim.vm and Anim.vm()
 local a=vm and vm.attackerId and vm:attackerId()or 0
 local b=vm and vm.targetId and vm:targetId()or 1
 local na,nb=self.native[a],self.native[b]
 local wa,wb=self.points[a],self.points[b]
 if not(na and nb and wa and wb)then return self.points[1]or self.points[0],0,0 end
 local dx,dy=nb.x-na.x,nb.y-na.y;local d=dx*dx+dy*dy
 if ball then
  local Coords=require('src.core.game3.battle.anim_coords')
  local ca,cb=Coords.coords(self.st,a),Coords.coords(self.st,b)
  local t=math.abs(dx)>1e-6 and math.max(0,math.min(1,(x-na.x)/dx))or 0
  -- Native balls settle 24px below their battler row, independently of the
  -- selected sprite's crop/foot padding. Preserve the arc above that floor.
  local baseline=(ca.y or na.y)+24+((cb.y or nb.y)-(ca.y or na.y))*t
  return {wa[1]+(wb[1]-wa[1])*t,wa[2]+2+math.max(0,baseline-y)*M.PIXEL,wa[3]+(wb[3]-wa[3])*t},x-(na.x+dx*t),0
 end
 local t=d>0 and math.max(0,math.min(1,((x-na.x)*dx+(y-na.y)*dy)/d))or 0
 return {wa[1]+(wb[1]-wa[1])*t,wa[2]+(wb[2]-wa[2])*t+8,wa[3]+(wb[3]-wa[3])*t},
  x-(na.x+dx*t),y-(na.y+dy*t)
end
function M:prepare(camera,ground,eye)
 self.points={}
 for id=0,5 do self.points[id]=M.placement(camera,id,self.st.double,ground)end
 -- Hidden actors still anchor native send-out/capture particle paths.
 for id=0,3 do if not self.native[id]then self:anchor(id)end end
 for _,c in ipairs(self.cards)do
  local point,ox,oy=self.points[c.id],0,0
  if not c.id then point,ox,oy=self:effectPoint(c.ax,c.ay,c.ball)end
  local yaw=Billboard.yawToward(point[1],point[3],eye)
  local offset=Mat.translate((M.W/2-c.ax+ox)*M.PIXEL,(c.ay-M.H-oy)*M.PIXEL,0)
  c.model=Mat.mul(Mat.mul(Mat.mul(Mat.translate(unpack(point)),Mat.rotateY(yaw)),offset),Mat.scale(M.W*M.PIXEL,M.H*M.PIXEL,1))
 end
end
function M:draw(shadow)
 local draw=shadow or R.draw
 if not shadow then self.vp=R.vp end
 if not shadow then R.seams(false);R.lighting(not V.require('UiBackplates').spritesUnlit())end
 local mesh=Billboard.mesh()
 for _,c in ipairs(self.cards)do
  if not shadow or c.id or c.ball then draw(mesh,c.tex,c.model,0)end
 end
 if not shadow then R.lighting(true);R.seams(true)end
end
function M:head(id,x,y)
 local c=self.byId[id];if not(c and c.model)then return end
 local m=c.model;local u,v=x/M.W-.5,1-y/M.H
 return M.project(self.vp or R.vp,m[1]*u+m[2]*v+m[4],m[5]*u+m[6]*v+m[8],m[9]*u+m[10]*v+m[12])
end
function M.release()
 for _,c in ipairs(pool)do c:release()end;pool={}
end
return M
