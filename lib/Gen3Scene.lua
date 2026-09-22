-- Native FireRed art in Battle Art's existing depth/shadow renderer.
-- All imported pixels come from the engine's live asset providers; no cache
-- paths, ROM reads, companion-private assets or emulated gameplay live here.
local V=...
local R=V.require('Voxel3D')
local Shadow=V.require('ShadowMap')
local Mat=V.require('Mat4')
local Shapes=V.require('Gen3TileShape')
local Pairs=V.require('Gen3Tilesets')
local Furniture=V.require('Gen3Furniture')
local Roof=V.require('Gen3RoofDetails')
local Buildings=V.require('Gen3Buildings')
local Civic=V.require('Gen3Civic')
local Outdoor=V.require('Gen3Outdoor')
local Terrain=V.require('Gen3Terrain')
local BattleClear=V.require('Gen3BattleClear')
local Distance=V.require('RenderDistance')
local Boundary=V.require('Gen3Boundary')
local BoundarySelect=V.require('BoundaryScenery')
local Interior=V.require('InteriorDiorama')
local Trees=V.require('Gen2Trees')
local Leaves=V.require('Gen2DepthTrees')
local TreeStyle=V.require('TreePresentation')
local Map=require('src.core.game3.map')
local Tiles=require('src.core.game3.tileset_native')
local Sprites=require('src.core.game3.ow_sprites')
local Player=require('src.core.game3.player')
local Objects=require('src.core.game3.objects')
local Versions=require('src.import.gba.versions')
local M={builds=0}
local cache,foliage,bark,spriteMeshes={ },nil,nil,{}
local savedCanvas,saved=false,false
local function quad(v,i,p,uv,shade,anchor)
 local base=#v
 for k,a in ipairs(p)do
  local vertex={a[1],a[2],a[3],uv[k][1],uv[k][2],shade or 1}
  if anchor then vertex[7],vertex[8],vertex[9]=anchor[1],anchor[2],anchor[3]end
  v[#v+1]=vertex
 end
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
  foliage=V.require('TreeIllustrations').image(V)
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
 local spec=Pairs.resolve(def.midLayout.pair,Versions.TILESET_PAIRS)
 if not Pairs.supports(def,spec) then return true end
 local Heal=require('src.core.game3.pokecenter_heal')
 local Doors=require('src.core.game3.doors')
 local Shop=require('src.ui.game3.shop_menu')
 local Fx=require('src.core.game3.field_effects')
 local Special=require('src.core.game3.special_field_anim')
 local Transition=package.loaded['src.core.game3.battle_transition']
 return (Heal.isActive and Heal.isActive()) or (Doors.isBusy and Doors.isBusy())
  or (Transition and Transition.isActive and Transition.isActive())
  or (Special.isActive and Special.isActive()) or #(Fx._anims or {})>0
  or (Shop.isShopCamera and Shop.isShopCamera()) or (def.cave==1 and (game.session.flashLevel or 0)>0)
end
local function releaseGeometry()
 for _,part in ipairs(cache.parts or {})do
  if part.under then part.under:release() end
  if part.roof then part.roof:release() end
  if part.plants then part.plants:release() end
 end
 for _,part in ipairs(cache.civics or {})do part.mesh:release();part.image:release()end
 for _,name in ipairs({'wood','leaves'})do if cache[name] then cache[name]:release() end end
 cache={}
end
local function prepare(game,vw,vh,cam)
 local def=Map.currentDef();if not def or not def.midLayout then return false end
 local px,pz=Player.px or 0,Player.py or 0
 local bx,bz=math.floor(px/96)*6,math.floor(pz/96)*6
 local budget=Distance.radius()
 local radius=budget and math.ceil(budget/16)or 64
 -- FULL keeps at least FAR's connected-map frontier, then draws each
 -- loaded rectangle completely rather than shrinking back to two hops.
 Map.refreshWorld(game,radius*2+12,radius*2+12,Map.current)
 local regions=Boundary.regions(def,Map.world)
 local x0,z0,x1,z1=bx-radius,bz-radius,bx+radius+6,bz+radius+6
 if not budget then x0,z0,x1,z1=BoundarySelect.bounds(regions,16)end
 M.distance={radius=radius,full=not budget,regions=#regions,bounds={x0,z0,x1,z1}}
 M.fadeExtent=budget or math.max(math.abs(x0*16-px),math.abs(x1*16-px),math.abs(z0*16-pz),math.abs(z1*16-pz))
 local cells,groups,signature={}, {}, {Map.current,x0,z0,x1,z1}
 M.fillCounts={forest=0,water=0,mountain=0,ground=0}
 for cy=z0,z1 do for cx=x0,x1 do
  local mid,pair,isVoid=Map.worldMidAt(cx,cy,def)
  local fillShape,biome
  if isVoid and def.environment~='INDOOR' and def.mapType~=8 then
   local m,p,shape,kind=Boundary.resolve(regions,cx,cy)
   if m then mid,pair,fillShape,biome=m,p,shape,kind;M.fillCounts[kind]=M.fillCounts[kind]+1 end
  end
  if mid and pair and not (isVoid and (def.environment=='INDOOR' or def.mapType==8)) then
   local ts=groups[pair]
   if not ts then
    -- get() also rebinds the native animation clock. Reuse the provider's
    -- current objects so connected-map scenery cannot reset water every draw.
    ts=Tiles._pairs[pair] or Tiles.get(pair);groups[pair]=ts
   end
   if ts and ts.midToSlot[mid] then
    local spec=Pairs.resolve(pair,Versions.TILESET_PAIRS)
    local c={mid=mid,pair=pair,cx=cx,cy=cy,ts=ts,primary=spec.primary,secondary=spec.secondary,
     shape=fillShape or Shapes.of(spec.primary,spec.secondary,mid),boundary=biome}
    cells[cx..':'..cy]=c
    signature[#signature+1]=pair..'/'..mid..(biome or '')
   else signature[#signature+1]='?' end
  else signature[#signature+1]='-' end
 end end
 Tiles.get(def.midLayout.pair)
 -- Provider replacement (palette reload) invalidates meshes even if IDs match.
 for pair,ts in pairs(groups)do signature[#signature+1]=pair..tostring(ts) end
 if cam and cam.battle then signature[#signature+1]=table.concat({'battle',cam.center[1],cam.center[2],cam.yaw},':')end
 local sig=table.concat(signature,';')
 if cache.signature==sig then return true end
 releaseGeometry();M.builds=(M.builds or 0)+1;cache.signature=sig;cache.parts={};cache.cells=cells
 local gyms=Buildings.prepare(cells);M.gymCount=#gyms
 local civics=Civic.prepare(cells,gyms,V.data("gen3_exteriors"));M.civicCount=#civics
 local props=Furniture.extract(cells)
 Shapes.layout(cells)
 for _,c in pairs(cells)do if c.gym then c.column=Buildings.column(c.gym)end end
 local chimneys=Roof.prepare(cells)
 M.chimneyCount=#chimneys
 M.propCount=#props
 for _,g in ipairs(civics)do g.stageHidden=BattleClear.hits(cam,g.cx*16,g.cy*16,(g.cx+g.width)*16,(g.cy+g.depth)*16)end
 for _,p in ipairs(props)do p.stageHidden=BattleClear.hits(cam,p.cx*16,p.cy*16,p.cx*16+p.w,p.cy*16+p.d)end
 for _,c in pairs(cells)do
  local col=c.column;local group=col and col.group
  c.stageHidden=BattleClear.hits(cam,c.cx*16,c.cy*16,c.cx*16+(c.shape.kind=='tree' and 32 or 16),c.cy*16+32)
  if col then col.stageHidden=group and BattleClear.hits(cam,group.left,group.back,group.right,group.front)or c.stageHidden end
 end
 M.cliffCount=0
 local batches={};local wood,wi,leaf,li={},{},{},{}
 for _,c in pairs(cells)do
  local ts,x,z,shape=c.ts,c.cx*16,c.cy*16,c.shape
  local b=batches[c.pair]
  if not b then b={pair=c.pair,secondary=c.secondary,v={},i={},rv={},ri={},pv={},pi={},roofMids={}};batches[c.pair]=b end
  local uv=uvFor(ts,c.mid)
  local column=c.column
  if c.civic then
   plane(b.v,b.i,x,z,uvFor(ts,c.civic.variant=='saffron' and 0x2E5 or 1) or uv)
  elseif shape.kind=='interiorFloor' then
   plane(b.v,b.i,x,z,uvFor(ts,shape.ground) or uv)
  elseif shape.kind=='cliff' then
   M.cliffCount=M.cliffCount+1
   plane(b.v,b.i,x,z,uvFor(ts,shape.ground) or uv)
   Terrain.append(cells,c,function(v,t,shade)quad(b.v,b.i,v,t,shade)end,uvFor)
  elseif c.prop then
   plane(b.v,b.i,x,z,uvFor(ts,c.prop.recipe.ground) or uvFor(ts,1) or uv)
  elseif shape.kind=='tree' then
   plane(b.v,b.i,x,z,uvFor(ts,shape.ground) or uv)
   if shape.root and not c.stageHidden then
    local seed=c.cx*73+c.cy*139
    local append=TreeStyle.flat() and Trees.appendFlatTrunk or Trees.appendTrunk
    local tx,tz=x+(shape.anchorX or 16),z+(shape.anchorZ or 12)
    local ws,ls=#wood,#leaf
    append(wood,wi,0,tx,0,tz,20,seed)
    Leaves.append(leaf,li,0,tx,0,tz,20,seed,Trees.family(seed,20),TreeStyle.flat())
    if shape.treeScale then
     local function resize(vertices,start)
      for j=start+1,#vertices do local v=vertices[j]
       v[1],v[2],v[3]=tx+(v[1]-tx)*shape.treeScale,v[2]*shape.treeScale,tz+(v[3]-tz)*shape.treeScale
       if v[9] then v[9]=v[9]*shape.treeScale end
      end
     end
     resize(wood,ws);resize(leaf,ls)
    end
   end
  elseif column then
   plane(b.v,b.i,x,z,uvFor(ts,shape.ground) or uv)
   if not column.stageHidden then
   if shape.kind=='wall' or shape.kind=='roomWall' then
    local row=c.cy-(column.first+column.roofs)
    local step=column.height/column.walls
    local top=column.height-row*step
    local portal=c.gym and (c.cx==c.gym.cx+3 or c.cx==c.gym.cx+4)
    local front=column.front+(portal and 4 or 0)
    quad(b.v,b.i,{{x,top,front},{x+16,top,front},{x+16,top-step,front},{x,top-step,front}},uv)
    if portal then
     local u,t=uv[1][1]+(uv[2][1]-uv[1][1])*.12,uv[1][2]+(uv[3][2]-uv[1][2])*.12
     local trim={{u,t},{u,t},{u,t},{u,t}}
     if row==0 then quad(b.v,b.i,{{x,top,column.front},{x+16,top,column.front},{x+16,top,front},{x,top,front}},trim,.9)end
     local side=c.cx==c.gym.cx+3 and x or x+16
     quad(b.v,b.i,{{side,top,column.front},{side,top,front},{side,top-step,front},{side,top-step,column.front}},trim,.8)
    end
    if column.indoor then
     local u,t=(uv[1][1]+uv[2][1])*.5,uv[1][2]
     local solid={{u,t},{u,t},{u,t},{u,t}}
     for _,dx in ipairs({-1,1})do
      if Roof.sideVisible(cells,c,dx)then local sx=dx<0 and x or x+16
       quad(b.v,b.i,{{sx,top,column.back},{sx,top,column.front},{sx,top-step,column.front},{sx,top-step,column.back}},solid,.82)
      end
     end
     if row==0 then quad(b.v,b.i,{{x,column.height,column.back},{x+16,column.height,column.back},{x+16,column.height,column.front},{x,column.height,column.front}},solid)end
     quad(b.v,b.i,{{x+16,top,column.back},{x,top,column.back},{x,top-step,column.back},{x+16,top-step,column.back}},solid,.7)
    end
   else
    b.roofMids[c.roofMid or c.mid]=true
    uv=uvFor(ts,c.roofMid or c.mid)
    local row=c.cy-column.first
    local z0=column.back+(column.front-column.back)*row/column.roofs
    local z1=column.back+(column.front-column.back)*(row+1)/column.roofs
    local function roofY(a)return Roof.height(column,a) end
    -- Keep each source cell's own art on the selected flat/gabled profile.
    for j=row==0 and math.floor((column.roofInset or 0)/4) or 0,3 do
     local a,bz=z0+(z1-z0)*j/4,z0+(z1-z0)*(j+1)/4
     local t0,t1=uv[1][2]+(uv[3][2]-uv[1][2])*j/4,uv[1][2]+(uv[3][2]-uv[1][2])*(j+1)/4
     local q={{uv[1][1],t0},{uv[2][1],t0},{uv[3][1],t1},{uv[4][1],t1}}
     quad(b.rv,b.ri,{{x,roofY(a),a},{x+16,roofY(a),a},{x+16,roofY(bz),bz},{x,roofY(bz),bz}},q)
     -- Close the exposed shell, including gables, without internal dividers.
     local wallCell=cells[c.cx..':'..column.last]
     local sideMid=wallCell.mid
     if c.secondary=='pallet_town' then sideMid=column.roofType=='flat' and 0x2C2 or 0x2A0 end
     local side=uvFor(ts,sideMid) or uvFor(ts,wallCell.mid)
     -- Sample the facade trim for closed siding rather than stretch the roof
     -- artwork down the building's entire side.
     local u=(side[1][1]+side[2][1])*.5
     local t=side[1][2]+(side[3][2]-side[1][2])*.2
     local solid={{u,t},{u,t},{u,t},{u,t}}
     for _,dx in ipairs({-1,1})do
      if Roof.sideVisible(cells,c,dx) then
       local sx=dx<0 and x or x+16
       quad(b.v,b.i,{{sx,roofY(a),a},{sx,roofY(bz),bz},{sx,0,bz},{sx,0,a}},solid,.82)
      end
     end
     if row==0 and j==math.floor((column.roofInset or 0)/4) then
      quad(b.v,b.i,{{x+16,roofY(a),a},{x,roofY(a),a},{x,0,a},{x+16,0,a}},solid,.74)
     end
    end
   end
   end
  elseif shape.kind=='sign' or shape.kind=='fence' or shape.kind=='ledge' or shape.kind=='flowers' or shape.kind=='shrub' or shape.kind=='grass' then
   plane(b.v,b.i,x,z,uvFor(ts,shape.ground) or uv)
   local plant=shape.kind=='flowers' or shape.kind=='shrub' or shape.kind=='grass'
   if not c.stageHidden then Outdoor.append(c,function(vertices,tex,shade,anchor)quad(plant and b.pv or b.v,plant and b.pi or b.i,vertices,tex,shade,anchor)end,uvFor)end
  else
   plane(b.v,b.i,x,z,uv)
  end
 end
 for _,p in ipairs(props)do if not p.stageHidden then
  local b=batches[p.pair]
  local cutout=p.recipe.cutout
  Furniture.append(p,function(vertices,uv,shade,anchor)quad(cutout and b.pv or b.v,cutout and b.pi or b.i,vertices,uv,shade,anchor)end,uvFor)
 end end
 cache.civics={}
 for _,g in ipairs(civics)do if not g.stageHidden then
  local vertices,indices={},{}
  Civic.append(g,function(v,t,shade)quad(vertices,indices,v,t,shade)end)
  cache.civics[#cache.civics+1]={mesh=assert(R.newMesh(vertices,indices)),image=Civic.material(g)}
 end end
 for _,p in ipairs(chimneys)do if not BattleClear.hits(cam,p.cx*16,p.cy*16,p.cx*16+16,p.cy*16+16)then
  local b=batches[p.pair]
  Roof.appendChimney(p,function(vertices,uv,shade)quad(b.rv,b.ri,vertices,uv,shade)end,uvFor)
 end end
 for _,b in pairs(batches)do cache.parts[#cache.parts+1]={pair=b.pair,secondary=b.secondary,roofMids=b.roofMids,
  under=assert(R.newMesh(b.v,b.i),'field mesh creation failed'),roof=R.newMesh(b.rv,b.ri),plants=R.newMesh(b.pv,b.pi,R.TREE_FORMAT)} end
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
   if p.plants then draw(p.plants,Outdoor.image(ts,math.floor((require('src.core.game3.tileset_anim').counter or 0)/16)) or ts.image)end
   if p.roof then
    local material=Roof.image(ts,p.secondary,Shapes.of,p.roofMids)
    draw(p.roof,material or ts.image)
    if not material and ts.overImage then draw(p.roof,ts.overImage)end
   end
  end
 end
 for _,part in ipairs(cache.civics or {})do draw(part.mesh,part.image)end
 draw(cache.wood,bark);draw(cache.leaves,foliage)
end
local function actor(gid,x,z,facing,phase,flip,opts,cam,draw)
 -- Neighbor snapshots may cover much farther than the rendered terrain.
 -- Do not leave those actors floating in the sky beyond its visible edge.
 if not (cache.cells and cache.cells[math.floor((x+8)/16)..':'..math.floor((z+8)/16)]) then return end
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
 R.battleOcclusion(nil)
 R.fog=nil
 R.interior=nil
 if saved then
  pcall(R.endScene);love.graphics.pop();love.graphics.setCanvas(savedCanvas)
  saved,savedCanvas=false,nil
 end
end
function M.draw(game,vw,vh,cam)
 if not prepare(game,vw,vh,cam) then return false end
 materials()
 local view=require('src.core.game3.field_view')
 local cx,cz=(Player.px or 0)+8+(view.cameraPanX or 0),(Player.py or 0)+8+(view.cameraPanY or 0)
 if cam.battle and cam.center then cx,cz=cam.center[1],cam.center[2]end
 local width,height=love.graphics.getCanvas():getDimensions()
 local Renderer=require('src.render.Renderer')
 local Display=require('src.core.game3.display')
 local override=Renderer.setWorldOverride and Renderer.frameRects and not Display.planesBroken
 if override then
  local rect=Renderer:frameRects()
  width=math.max(1,math.floor(rect.vuw*rect.dpiX+.5))
  height=math.max(1,math.floor(rect.vuh*rect.dpiY+.5))
 end
 M.renderWidth,M.renderHeight=width,height
 local S=V.require('VoxelState')
 S.level=cam.level;S.angle=math.rad(S.ANGLES_DEG[cam.level+1] or 35)
 R.canopyFacing=cam.battle or cam.level>=6
 if cam.level>=6 then
  local dist=cam.level==6 and 0 or 75
  local dx,dz=math.sin(cam.yaw),-math.cos(cam.yaw)
  local ey=cam.level==6 and 23 or 48
  R.camera={eye={cx-dx*dist,ey,cz-dz*dist},focus={cx+dx*70,ey-70*math.tan(cam.pitch),cz+dz*70},fov=math.rad(62)}
  if cam.battle then
   R.camera={eye={cx-dx*75,32,cz-dz*75},focus={cx+dx*16,0,cz+dz*16},fov=math.rad(50)}
  end
 else
  R.camera=Interior.camera(Interior.forMap(Map.currentDef(),3),S.angle,vw/vh)
  if R.camera then cx,cz=R.camera.focus[1],R.camera.focus[3]end
 end
 R.viewProjection(cx,cz,vw,vh)
 savedCanvas=love.graphics.getCanvas();love.graphics.push('all');saved=true
 if Shadow.begin(cx,cz,vw,vh) then
  local room=not cam.battle and Interior.forMap(Map.currentDef(),3) or nil
  Shadow.roomClip(room and room.bounds)
  terrain(Shadow.draw);if not cam.battle then actors(game,cam,Shadow.draw)end;Shadow.finish('firered')
 end
 local indoor=Map.currentDef().environment=='INDOOR' or Map.currentDef().mapType==8
 local room=not cam.battle and Interior.forMap(Map.currentDef(),3) or nil
 Interior.configure(room)
 local background=indoor and Interior.background or {.60,.79,.82,1}
 local bounds=M.distance.bounds
 R.fog=not indoor and Distance.haze(background,M.fadeExtent,{(Player.px or 0)+8,0,(Player.py or 0)+8},
  {bounds[1]*16,bounds[2]*16,(bounds[3]+1)*16,(bounds[4]+1)*16})or nil
 if not R.beginScene(width,height,cx,cz,vw,vh,background,'firered') then M.restore();return false end
 R.battleOcclusion(nil)
 Interior.draw(room)
 terrain(R.draw);if not cam.battle then actors(game,cam,R.draw)end
 R.battleOcclusion(nil)
 local canvas=R.endScene()
 R.fog=nil
 love.graphics.pop();love.graphics.setCanvas(savedCanvas);saved=false;savedCanvas=nil
 -- Use the same public world-image handoff as Battle Art's Gen1/2 pipeline.
 -- Otherwise an HD scene is squeezed into Game3's low-resolution field
 -- canvas before being enlarged, throwing away foliage/geometry detail.
 -- UI continues through the native, separate pixel-aligned plane.
 if override then Renderer:setWorldOverride(canvas) end
 love.graphics.push('all');love.graphics.origin();love.graphics.setShader();love.graphics.setColor(1,1,1,1)
 love.graphics.setBlendMode('alpha','premultiplied');love.graphics.draw(canvas,0,0,0,vw/width,vh/height)
 love.graphics.pop()
 return true
end
function M.invalidate()Boundary.clear();releaseGeometry()end
function M.release()
 releaseGeometry()
 for _,mesh in pairs(spriteMeshes)do if mesh then mesh:release() end end
 spriteMeshes={}
 if foliage then foliage:release();foliage=nil end
 if bark then bark:release();bark=nil end
 Roof.release();Outdoor.release()
 R.invalidate();Shadow.invalidate()
end
return M
