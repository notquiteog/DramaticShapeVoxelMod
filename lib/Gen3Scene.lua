-- Native FireRed art in Battle Art's existing depth/shadow renderer.
-- All imported pixels come from the engine's live asset providers; no cache
-- paths, ROM reads, companion-private assets or emulated gameplay live here.
local V=...
local R=V.require('Voxel3D')
local Shadow=V.require('ShadowMap')
local Mat=V.require('Mat4')
local Shapes=V.require('Gen3TileShape')
local Trees=V.require('Gen2Trees')
local Leaves=V.require('Gen2DepthTrees')
local Map=require('src.core.game3.map')
local Tiles=require('src.core.game3.tileset_native')
local Sprites=require('src.core.game3.ow_sprites')
local Player=require('src.core.game3.player')
local Objects=require('src.core.game3.objects')
local Versions=require('src.import.gba.versions')
local M={builds=0}
local cache,foliage,bark,spriteMeshes={ },nil,nil,{}
local savedCanvas,saved=false,false
local function quad(v,i,p,uv,shade)
 local base=#v
 for k,a in ipairs(p)do v[#v+1]={a[1],a[2],a[3],uv[k][1],uv[k][2],shade or 1} end
 for _,k in ipairs({1,2,3,1,3,4})do i[#i+1]=base+k end
end
local function uvFor(ts,mid)
 local slot=ts.midToSlot[mid];if not slot then return end
 local x,y=slot%ts.cols,math.floor(slot/ts.cols)
 local l,r=(x+.005)/ts.cols,(x+.995)/ts.cols
 local t,b=(y+.005)/ts.rows,(y+.995)/ts.rows
 return {{l,t},{r,t},{r,b},{l,b}}
end
local function plane(v,i,x,z,uv,h)
 quad(v,i,{{x,h or 0,z},{x+16,h or 0,z},{x+16,h or 0,z+16},{x,h or 0,z+16}},uv)
end
local function materials()
 if not foliage then
  local file=love.filesystem.newFileData(assert(V.mod:read('assets/crystal/depth-crowns-v2.png')),'depth-crowns-v2.png')
  foliage=love.graphics.newImage(file,{mipmaps=true});file:release()
  foliage:setFilter('nearest','nearest');foliage:setMipmapFilter('linear')
  local data=love.image.newImageData(2,2)
  for y=0,1 do for x=0,1 do data:setPixel(x,y,.29+x*.03,.18+y*.03,.10,1) end end
  bark=love.graphics.newImage(data);data:release()
 end
end
function M.nativeRequired(game)
 -- Keep native healing balls, door animation, darkness and shop framing until
 -- those owners expose depth-aware effects. Do not hide their presentations.
 local def=Map.currentDef()
 if not (def and def.midLayout) then return true end
 local spec=Versions.TILESET_PAIRS[def.midLayout.pair] or {}
 if spec.primary~='general' then return true end
 local Heal=require('src.core.game3.pokecenter_heal')
 local Doors=require('src.core.game3.doors')
 local Shop=require('src.ui.game3.shop_menu')
 local Fx=require('src.core.game3.field_effects')
 local Special=require('src.core.game3.special_field_anim')
 return (Heal.isActive and Heal.isActive()) or (Doors.isBusy and Doors.isBusy())
  or (Special.isActive and Special.isActive()) or #(Fx._anims or {})>0
  or (Shop.isShopCamera and Shop.isShopCamera()) or (def.cave==1 and (game.session.flashLevel or 0)>0)
end
local function releaseGeometry()
 for _,part in ipairs(cache.parts or {})do
  if part.under then part.under:release() end
 end
 for _,name in ipairs({'wood','leaves'})do if cache[name] then cache[name]:release() end end
 cache={}
end
local function prepare(game,vw,vh)
 local def=Map.currentDef();if not def or not def.midLayout then return false end
 local px,pz=Player.px or 0,Player.py or 0
 local bx,bz=math.floor(px/96)*6,math.floor(pz/96)*6
 local radius=math.min(36,math.max(18,math.ceil(math.max(vw,vh)/32)+10))
 Map.refreshWorld(game,radius*2+12,radius*2+12,Map.current)
 local cells,groups,signature={}, {}, {Map.current,bx,bz,radius}
 for cy=bz-radius,bz+radius+6 do for cx=bx-radius,bx+radius+6 do
  local mid,pair=Map.worldMidAt(cx,cy,def)
  if mid and pair then
   local ts=groups[pair]
   if not ts then
    -- get() also rebinds the native animation clock. Reuse the provider's
    -- current objects so connected-map scenery cannot reset water every draw.
    ts=Tiles._pairs[pair] or Tiles.get(pair);groups[pair]=ts
   end
   if ts and ts.midToSlot[mid] then
    local spec=Versions.TILESET_PAIRS[pair] or {}
    local c={mid=mid,pair=pair,cx=cx,cy=cy,ts=ts,shape=Shapes.of(spec.primary,spec.secondary,mid)}
    cells[cx..':'..cy]=c
    signature[#signature+1]=pair..'/'..mid
   else signature[#signature+1]='?' end
  else signature[#signature+1]='-' end
 end end
 Tiles.get(def.midLayout.pair)
 -- Provider replacement (palette reload) invalidates meshes even if IDs match.
 for pair,ts in pairs(groups)do signature[#signature+1]=pair..tostring(ts) end
 local sig=table.concat(signature,';')
 if cache.signature==sig then return true end
 releaseGeometry();cache.signature=sig;cache.parts={}
 local batches={};local wood,wi,leaf,li={},{},{},{}
 for _,c in pairs(cells)do
  local ts,x,z,shape=c.ts,c.cx*16,c.cy*16,c.shape
  local b=batches[c.pair]
  if not b then b={pair=c.pair,v={},i={}};batches[c.pair]=b end
  local uv=uvFor(ts,c.mid)
  local column=Shapes.column(cells,c.cx..':'..c.cy)
  if shape.kind=='tree' then
   plane(b.v,b.i,x,z,uvFor(ts,shape.ground) or uv)
   if shape.root then
    local seed=c.cx*73+c.cy*139
    Trees.appendTrunk(wood,wi,0,x+16,0,z+12,20,seed)
    Leaves.append(leaf,li,0,x+16,0,z+12,20,seed,Trees.family(seed,20))
   end
  elseif column then
   plane(b.v,b.i,x,z,uvFor(ts,shape.ground) or uv)
   if shape.kind=='wall' then
    local row=c.cy-(column.first+column.roofs)
    local top=column.height-row*16
    quad(b.v,b.i,{{x,top,column.front},{x+16,top,column.front},{x+16,top-16,column.front},{x,top-16,column.front}},uv)
   else
    local row=c.cy-column.first
    local z0=column.back+(column.front-column.back)*row/column.roofs
    local z1=column.back+(column.front-column.back)*(row+1)/column.roofs
    local function roofY(a)return column.height+13*math.sin(math.pi*(a-column.back)/(column.front-column.back)) end
    -- Subdivide the curved roof without spreading one tile over a whole house.
    for j=0,3 do
     local a,bz=z0+(z1-z0)*j/4,z0+(z1-z0)*(j+1)/4
     local t0,t1=uv[1][2]+(uv[3][2]-uv[1][2])*j/4,uv[1][2]+(uv[3][2]-uv[1][2])*(j+1)/4
     local q={{uv[1][1],t0},{uv[2][1],t0},{uv[3][1],t1},{uv[4][1],t1}}
     quad(b.v,b.i,{{x,roofY(a),a},{x+16,roofY(a),a},{x+16,roofY(bz),bz},{x,roofY(bz),bz}},q)
     -- Close each end, including the gable; internal faces are harmless.
     local wallCell=cells[c.cx..':'..column.last]
     local side=uvFor(ts,wallCell.mid)
     -- Sample the facade trim for closed siding rather than stretch the roof
     -- artwork down the building's entire side.
     local u=(side[1][1]+side[2][1])*.5
     local t=side[1][2]+(side[3][2]-side[1][2])*.2
     local solid={{u,t},{u,t},{u,t},{u,t}}
     for _,sx in ipairs({x,x+16})do
      quad(b.v,b.i,{{sx,roofY(a),a},{sx,roofY(bz),bz},{sx,0,bz},{sx,0,a}},solid,.82)
     end
    end
   end
  elseif shape.kind=='sign' then
   plane(b.v,b.i,x,z,uvFor(ts,shape.ground) or uv)
   quad(b.v,b.i,{{x,shape.height,z+12},{x+16,shape.height,z+12},{x+16,0,z+12},{x,0,z+12}},uv)
  else
   plane(b.v,b.i,x,z,uv)
  end
 end
 for _,b in pairs(batches)do cache.parts[#cache.parts+1]={pair=b.pair,under=R.newMesh(b.v,b.i)} end
 cache.wood=R.newMesh(wood,wi);cache.leaves=R.newMesh(leaf,li)
 M.builds=M.builds+1
 return true
end
local function terrain(draw)
 for _,p in ipairs(cache.parts)do
  -- Always bind the current native image: animations and palette updates stay live.
  local ts=Tiles._pairs[p.pair]
  if ts then
   draw(p.under,ts.image)
   -- A metatile's visible roof/sign artwork may live entirely in BG2.
   -- Apply both native layers to the SAME shaped surface, not just the floor.
   if ts.overImage then draw(p.under,ts.overImage) end
  end
 end
 draw(cache.wood,bark);draw(cache.leaves,foliage)
end
local function actor(gid,x,z,facing,phase,flip,opts,cam,draw)
 local spr=Sprites.getDraw(gid);if not spr then return end
 -- View-relative artwork keeps the actor facing its world heading while the
 -- camera turns; this changes the sampled frame, never the entity direction.
 facing=V.require('Gen3Integration').worldDirection(facing,-(cam.level>=6 and cam.yaw or 0))
 local frame,mirror=Sprites.pose(spr,facing,phase,flip,opts)
 local q=spr.quads[frame];if not q then return end
 local key=tostring(spr)..':'..frame..':'..tostring(mirror)
 local mesh=spriteMeshes[key]
 if not mesh then
  local qx,qy,qw,qh=q:getViewport();local iw,ih=spr.image:getDimensions()
  local l,r=qx/iw,(qx+qw)/iw;if mirror then l,r=r,l end
  local v,i={},{}
  quad(v,i,{{-qw/2,qh,0},{qw/2,qh,0},{qw/2,0,0},{-qw/2,0,0}},{{l,qy/ih},{r,qy/ih},{r,(qy+qh)/ih},{l,(qy+qh)/ih}})
  mesh=R.newMesh(v,i);spriteMeshes[key]=mesh
 end
 local yaw=cam.level>=6 and -cam.yaw or 0
 local lean=cam.level>=6 and 0 or -.4
 local model=Mat.mul(Mat.translate(x+8,opts.lift or 0,z+16),Mat.mul(Mat.rotateY(yaw),Mat.rotateX(lean)))
 draw(mesh,spr.image,model)
end
local function actors(game,cam,draw)
 local space=package.loaded['src.core.game3.scripting.space']
 for _,eo in ipairs(Objects.forDraw())do
  local gid=eo.graphicsId or (eo.def and (eo.def.graphicsId or eo.def.graphics))
  if space and space.resolveObjectGraphicsId and eo.def then gid=space.resolveObjectGraphicsId(eo.def) or gid end
  actor(gid,(eo.px or eo.cellX*16)+(eo.raiseX or 0),eo.py or eo.cellY*16,
   eo.facing or 'down',Objects.walkPhase(eo),eo.stepFlip,
   {bow=(eo.bowFrames or 0)>0 or eo.raiseHand,frame=eo.customFrame,lift=-(eo.raiseY or 0)},cam,draw)
 end
 -- Connected maps use the engine's ghost snapshots; never advance those
 -- actors here (doing that per render would reintroduce fast wandering NPCs).
 local Ghosts=require('src.core.game3.ghosts')
 for _,entry in ipairs(Map.world or {})do
  if entry.id~=Map.current then
   local live=Ghosts.forDraw(entry.id)
   if live then
    for _,eo in ipairs(live)do
     actor(eo.graphicsId or (eo.def and (eo.def.graphicsId or eo.def.graphics)),
      (eo.px or eo.cellX*16)+entry.ox*16,(eo.py or eo.cellY*16)+entry.oy*16,
      eo.facing or 'down',Objects.walkPhase(eo),eo.stepFlip,{},cam,draw)
    end
   else
    local event=space and space.bundle and space.bundle.events and space.bundle.events[entry.id]
    local defs=event and (event.objects or event.objectEvents) or entry.def.objects or {}
    local bounds=Objects.layoutBounds(entry.def)
    for _,obj in ipairs(defs)do
     local x,y=tonumber(obj.x) or 0,tonumber(obj.y) or 0
     local visible=not obj.flag or obj.flag==0 or (space and space.objectVisible and space.objectVisible(obj))
     if visible and (not bounds or (x>=0 and y>=0 and x<bounds.w and y<bounds.h)) then
      actor(obj.graphicsId or obj.graphics,(entry.ox+x)*16,(entry.oy+y)*16,
       tostring(obj.facing or 'down'):lower(),0,false,{},cam,draw)
     end
    end
   end
  end
 end
 if cam.level~=6 and Player.isVisible() then
  actor(Sprites.playerGraphicsId(game),(Player.px or 0)+(Player.spriteXOffset or 0),Player.py or 0,
   Player.facing,Player.walkPhase(),Player.drawFlip(),
   {fieldMove=(Player.fieldMoveAnim or 0)>0,lift=-(Player.spriteYOffset or 0)},cam,draw)
 end
end
function M.restore()
 if saved then
  pcall(R.endScene);love.graphics.pop();love.graphics.setCanvas(savedCanvas)
  saved,savedCanvas=false,nil
 end
end
function M.draw(game,vw,vh,cam)
 if not prepare(game,vw,vh) then return false end
 materials()
 local view=require('src.core.game3.field_view')
 local cx,cz=(Player.px or 0)+8+(view.cameraPanX or 0),(Player.py or 0)+8+(view.cameraPanY or 0)
 local width,height=love.graphics.getCanvas():getDimensions()
 local S=V.require('VoxelState')
 S.level=cam.level;S.angle=math.rad(S.ANGLES_DEG[cam.level+1] or 35)
 R.canopyFacing=cam.level>=6
 if cam.level>=6 then
  local dist=cam.level==6 and 0 or 75
  local dx,dz=math.sin(cam.yaw),-math.cos(cam.yaw)
  local ey=cam.level==6 and 23 or 48
  R.camera={eye={cx-dx*dist,ey,cz-dz*dist},focus={cx+dx*70,ey-70*math.tan(cam.pitch),cz+dz*70},fov=math.rad(62)}
 else R.camera=nil end
 R.viewProjection(cx,cz,vw,vh)
 savedCanvas=love.graphics.getCanvas();love.graphics.push('all');saved=true
 if Shadow.begin(cx,cz,vw,vh) then
  terrain(Shadow.draw);actors(game,cam,Shadow.draw);Shadow.finish('firered')
 end
 if not R.beginScene(width,height,cx,cz,vw,vh,{.60,.79,.82,1},'firered') then M.restore();return false end
 terrain(R.draw);actors(game,cam,R.draw)
 local canvas=R.endScene()
 love.graphics.pop();love.graphics.setCanvas(savedCanvas);saved=false;savedCanvas=nil
 love.graphics.push('all');love.graphics.origin();love.graphics.setShader();love.graphics.setColor(1,1,1,1)
 love.graphics.setBlendMode('alpha','premultiplied');love.graphics.draw(canvas,0,0,0,vw/width,vh/height)
 love.graphics.pop()
 return true
end
function M.release()
 releaseGeometry()
 for _,mesh in pairs(spriteMeshes)do if mesh then mesh:release() end end
 spriteMeshes={}
 if foliage then foliage:release();foliage=nil end
 if bark then bark:release();bark=nil end
 R.invalidate();Shadow.invalidate()
end
return M
