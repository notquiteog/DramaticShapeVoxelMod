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
local Stairs=V.require('Gen3Stairs')
local SpriteAnchor=V.require('Gen3SpriteAnchor')
local Roof=V.require('Gen3RoofDetails')
local Buildings=V.require('Gen3Buildings')
local Civic=V.require('Gen3Civic')
local Outdoor=V.require('Gen3Outdoor')
local Terrain=V.require('Gen3Terrain')
local BattleClear=V.require('Gen3BattleClear')
local Distance=V.require('RenderDistance')
local Boundary=V.require('Gen3Boundary')
local BoundarySelect=V.require('BoundaryScenery')
local SceneCache=V.require('Gen3SceneCache')
local Forest=V.require('Gen3Forest')
local Cladding=V.require('HouseCladding')
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
function M.context()return Map.currentDef()end
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
local function swatch(ts,u,v)
 -- A constant UV exactly BETWEEN texels interpolates to either side by a
 -- rounding ULP across a triangle. At nearest filtering that becomes noisy
 -- siding even with shadows disabled. Always sample the texel centre.
 u=(math.floor(u*ts.cols*16)+.5)/(ts.cols*16)
 v=(math.floor(v*ts.rows*16)+.5)/(ts.rows*16)
 return {{u,v},{u,v},{u,v},{u,v}}
end
local function materials()
 if not foliage then
  foliage=V.require('TreeIllustrations').image(V)
  local data=love.image.newImageData(2,2)
  for y=0,1 do for x=0,1 do data:setPixel(x,y,.29+x*.03,.18+y*.03,.10,1) end end
  bark=love.graphics.newImage(data);data:release()
 end
end
-- Landing dust uses the native effect painter on a small world-space card.
-- Unsupported full-screen effects still retain their native presentation.
function M.nativeEffects(anims)
 for _,a in ipairs(anims or {})do if type(a)~='table' or a.kind~='dust' then return true end end
 return false
end
function M.nativeRequired(game)
 -- Door and healing frames are projected into the scene below. Other special
 -- field presentations retain their native renderer.
 Pairs.bind(game and game.data and game.data.maps)
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
 local Warp=require('src.core.game3.warp')
 local escalator=Warp.isEscalatorActive and Warp.isEscalatorActive()
 return (Transition and Transition.isActive and Transition.isActive())
  or (Special.isActive and Special.isActive() and not (escalator or Special.isEscalatorMoving and Special.isEscalatorMoving())) or M.nativeEffects(Fx._anims)
  or (Shop.isShopCamera and Shop.isShopCamera()) or (def.cave==1 and (game.session.flashLevel or 0)>0)
end
local function releaseGeometry()
 for _,part in ipairs(cache.parts or {})do
  if part.under then part.under:release() end
  if part.roof then part.roof:release() end
  if part.plants then part.plants:release() end
  if part.water then part.water:release() end
 end
 for _,part in ipairs(cache.civics or {})do part.mesh:release();part.image:release()end
 for _,name in ipairs({'wood','leaves'})do if cache[name] then cache[name]:release() end end
 cache={}
end
local function prepare(game,vw,vh,cam)
 local replay=cam and cam.replay
 local def=replay and replay.def or Map.currentDef();if not def or not def.midLayout then return false end
 M.sceneDef=def
 local px,pz=replay and replay.frame.x or Player.px or 0,replay and replay.frame.y or Player.py or 0
 local bx,bz=math.floor(px/96)*6,math.floor(pz/96)*6
 local budget=Distance.radius()
 local radius=budget and math.ceil(budget/16)or 64
 -- FULL keeps at least FAR's connected-map frontier, then draws each
 -- loaded rectangle completely rather than shrinking back to two hops.
 if not replay then Map.refreshWorld(game,radius*2+12,radius*2+12,Map.current)end
 local regions=replay and {{def=def,x=0,y=0,w=def.midLayout.width,h=def.midLayout.height}} or Boundary.regions(def,Map.world)
 local x0,z0,x1,z1=bx-radius,bz-radius,bx+radius+6,bz+radius+6
 if not budget then x0,z0,x1,z1=BoundarySelect.bounds(regions,16)end
 local key=SceneCache.key(regions,x0,z0,x1,z1,Tiles._pairs,cam)
 if key and key==cache.terrainKey then M.cacheHits=(M.cacheHits or 0)+1;return true end
 M.prepares=(M.prepares or 0)+1
 M.distance={radius=radius,full=not budget,regions=#regions,bounds={x0,z0,x1,z1}}
 M.fadeExtent=budget or math.max(math.abs(x0*16-px),math.abs(x1*16-px),math.abs(z0*16-pz),math.abs(z1*16-pz))
 local cells,groups,signature={}, {}, {replay and replay.scene.map or Map.current,x0,z0,x1,z1}
 M.fillCounts={forest=0,water=0,mountain=0,ground=0}
 for cy=z0,z1 do for cx=x0,x1 do
  local mid,pair,isVoid
  if replay then
   local tile=replay.scene.tiles and replay.scene.tiles[cx..','..cy]
   isVoid=cx<0 or cy<0 or cx>=def.midLayout.width or cy>=def.midLayout.height
   if tile then mid,pair,isVoid=tile[1],tile[2],false
   elseif not isVoid then mid,pair=def.midLayout:midAt(cx,cy),def.midLayout.pair end
  else mid,pair,isVoid=Map.worldMidAt(cx,cy,def)end
  local fillShape,biome
  if isVoid and Pairs.outdoor(def) then
   local m,p,shape,kind=Boundary.resolve(regions,cx,cy)
   if m then mid,pair,fillShape,biome=m,p,shape,kind;M.fillCounts[kind]=M.fillCounts[kind]+1 end
  end
  if mid and pair and not (isVoid and not Pairs.outdoor(def)) then
   local ts=groups[pair]
   if not ts then
    -- get() also rebinds the native animation clock. Reuse the provider's
    -- current objects so connected-map scenery cannot reset water every draw.
    ts=Tiles._pairs[pair] or Tiles.get(pair);groups[pair]=ts
   end
   if ts and ts.midToSlot[mid] then
    local spec=Pairs.resolve(pair,Versions.TILESET_PAIRS)
    local collision
    for _,region in ipairs(regions)do
     local lx,ly=cx-region.x,cy-region.y
     if lx>=0 and ly>=0 and lx<region.w and ly<region.h then collision=region.def.midLayout:collAt(lx,ly);break end
    end
    local c={mid=mid,behavior=(require('src.core.game3.scripting.interaction_scripts').behaviors[pair] or {})[mid],collision=collision,pair=Pairs.canonical(pair),nativePair=pair,cx=cx,cy=cy,ts=ts,primary=spec.primary,secondary=spec.secondary,
     shape=fillShape or Shapes.of(spec.primary,spec.secondary,mid,
      (require('src.core.game3.scripting.interaction_scripts').behaviors[pair] or {})[mid],collision),boundary=biome}
    cells[cx..':'..cy]=c
    signature[#signature+1]=pair..'/'..mid..'/'..tostring(collision)..(biome or '')
   else signature[#signature+1]='?' end
  else signature[#signature+1]='-' end
 end end
 Tiles.get(def.midLayout.pair)
 -- Provider replacement (palette reload) invalidates meshes even if IDs match.
 for pair,ts in pairs(groups)do signature[#signature+1]=pair..tostring(ts) end
 if cam and cam.battle then signature[#signature+1]=table.concat({'battle',cam.center[1],cam.center[2],cam.yaw},':')end
 local sig=table.concat(signature,';')
 if cache.signature==sig then cache.terrainKey=key;return true end
 releaseGeometry();M.builds=(M.builds or 0)+1;cache.signature=sig;cache.parts={};cache.cells=cells
 M.forestTrees=Forest.prepare(cells)
 local gyms=Buildings.prepare(cells);M.gymCount=#gyms
 local civics=Civic.prepare(cells,gyms,V.data("gen3_exteriors"));M.civicCount=#civics
 M.stairCount=Stairs.prepare(cells)
 local props=Furniture.extract(cells)
 cache.openings={}
 for _,p in ipairs(props)do if p.recipe.noGround and p.recipe.down then
  cache.openings[#cache.openings+1]={p.cx*16,p.cy*16,(p.cx*16)+p.w,(p.cy*16)+p.d}
 end end
 for _,c in pairs(cells)do if c.stairs and c.stairs.owner==c and c.stairs.r.down then
  local s=c.stairs;cache.openings[#cache.openings+1]={s.cx*16,s.cy*16,(s.cx+2)*16,(s.cy+#s.r.rows)*16}
 end end
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
  if not b then b={pair=c.nativePair,secondary=c.secondary,v={},i={},rv={},ri={},pv={},pi={},wv={},wi={},roofMids={}};batches[c.pair]=b end
  local uv=uvFor(ts,c.mid)
  local column=c.column
  if c.stairs or shape.kind=='steps' or shape.kind=='ladder' then
   if shape.kind=='ladder' and not shape.down then plane(b.v,b.i,x,z,uvFor(ts,shape.ground) or uv)end
   Stairs.append(c,function(p,t,shade)quad(b.v,b.i,p,t,shade)end,uvFor)
  elseif c.civic then
   plane(b.v,b.i,x,z,uvFor(ts,c.civic.variant=='saffron' and 0x2E5 or 1) or uv)
  elseif shape.kind=='water' then
   plane(b.wv,b.wi,x,z,uv,.05)
  elseif shape.kind=='interiorFloor' then
   plane(b.v,b.i,x,z,uvFor(ts,shape.ground) or uv)
  elseif shape.kind=='caveWall' then
   plane(b.v,b.i,x,z,uvFor(ts,shape.ground) or uv)
   if not c.stageHidden then V.require('Gen3Cave').wall(cells,c,function(v,t,shade)quad(b.v,b.i,v,t,shade)end,uvFor)end
  elseif shape.kind=='rock' then
   plane(b.v,b.i,x,z,uvFor(ts,shape.ground) or uv)
   if not c.stageHidden then V.require('Gen3Cave').rock(c,function(v,t,shade)quad(b.v,b.i,v,t,shade)end,uvFor)end
  elseif shape.kind=='cliff' then
   M.cliffCount=M.cliffCount+1
   plane(b.v,b.i,x,z,uvFor(ts,shape.ground) or uv)
   Terrain.append(cells,c,function(v,t,shade)quad(b.v,b.i,v,t,shade)end,uvFor)
  elseif c.prop then
   if not c.prop.recipe.noGround then
    plane(b.v,b.i,x,z,uvFor(ts,c.prop.recipe.ground) or uvFor(ts,1) or uv)
   end
  elseif shape.kind=='tree' then
   plane(b.v,b.i,x,z,uvFor(ts,shape.ground) or uv)
   if shape.root and not c.stageHidden then
    if TreeStyle.original() then
     local native=V.require('NativeTreeArt')
     local tx,tz=x+(shape.anchorX or 16),z+(shape.anchorZ or 12)
     if TreeStyle.voxel() then native.appendModel(native.gen3(c),leaf,li,0,tx,0,tz)
     else native.append(native.gen3(c),leaf,li,0,tx,0,tz,TreeStyle.flat()) end
     if not TreeStyle.voxel() and not TreeStyle.flat() then Trees.appendTrunk(wood,wi,0,tx,0,tz,4,c.cx*73+c.cy*139) end
    else
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
   end
  elseif column and column.indoor and c.secondary=='lab' then
   plane(b.v,b.i,x,z,uvFor(ts,0x289) or uv)
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
     local trim=swatch(ts,u,t)
     if row==0 then quad(b.v,b.i,{{x,top,column.front},{x+16,top,column.front},{x+16,top,front},{x,top,front}},trim,.9)end
     local side=c.cx==c.gym.cx+3 and x or x+16
     quad(b.v,b.i,{{side,top,column.front},{side,top,front},{side,top-step,front},{side,top-step,column.front}},trim,.8)
    end
    if column.indoor then
     local u,t=(uv[1][1]+uv[2][1])*.5,uv[1][2]
     local solid=swatch(ts,u,t)
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
     local function eave(A,B,dx,dz)
      V.require('RoofEaves').edge(A,B,dx,dz,q,function(v,t,shade)quad(b.rv,b.ri,v,t,shade)end)
     end
     if Roof.sideVisible(cells,c,-1)then eave({x,roofY(bz),bz},{x,roofY(a),a},-2,0)end
     if Roof.sideVisible(cells,c,1)then eave({x+16,roofY(a),a},{x+16,roofY(bz),bz},2,0)end
     if row==0 and j==math.floor((column.roofInset or 0)/4)then eave({x,roofY(a),a},{x+16,roofY(a),a},0,-2)end
     if row==column.roofs-1 and j==3 then eave({x+16,roofY(bz),bz},{x,roofY(bz),bz},0,2)end
     local north=row==0 and j==math.floor((column.roofInset or 0)/4)
     local south=row==column.roofs-1 and j==3
     for _,side in ipairs({-1,1})do if Roof.sideVisible(cells,c,side)then
      local xx=side<0 and x or x+16
      for _,endcap in ipairs({{north,a,-2},{south,bz,2}})do if endcap[1]then
       V.require('RoofEaves').corner({xx,roofY(endcap[2]),endcap[2]},side*2,endcap[3],q,
        function(v,t,shade)quad(b.rv,b.ri,v,t,shade)end)
      end end
     end end
     -- Close the exposed shell, including gables, without internal dividers.
     local wallCell=cells[c.cx..':'..column.last]
     local sideMid=wallCell.mid
     if c.secondary=='pallet_town' then sideMid=column.roofType=='flat' and 0x2C2 or 0x2A0 end
     local side=uvFor(ts,sideMid) or uvFor(ts,wallCell.mid)
     -- Sample the facade trim for closed siding rather than stretch the roof
     -- artwork down the building's entire side.
     local u=(side[1][1]+side[2][1])*.5
     local t=side[1][2]+(side[3][2]-side[1][2])*.2
     local solid=swatch(ts,u,t)
     for _,dx in ipairs({-1,1})do
      if Roof.sideVisible(cells,c,dx) then
       local sx=dx<0 and x or x+16
       quad(b.v,b.i,{{sx,roofY(a),a},{sx,roofY(bz),bz},{sx,0,bz},{sx,0,a}},solid,.82)
       if c.secondary=='pallet_town' then
        Cladding.side(sx,a,bz,roofY(a),roofY(bz),dx,solid,function(v,t,shade)quad(b.v,b.i,v,t,shade)end)
       end
      end
     end
     if row==0 and j==math.floor((column.roofInset or 0)/4) then
      quad(b.v,b.i,{{x+16,roofY(a),a},{x,roofY(a),a},{x,0,a},{x+16,0,a}},solid,.74)
      if c.secondary=='pallet_town' then Cladding.back(x,x+16,a,roofY(a),solid,function(v,t,shade)quad(b.v,b.i,v,t,shade)end)end
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
 local labWall={}
 for _,c in pairs(cells)do if c.secondary=='lab' and c.cy==0 and c.mid~=0 then
  local b=batches[c.pair];local uv=uvFor(c.ts,0x69)
  if uv and not labWall[c.cx] then
   labWall[c.cx]=true;local x=c.cx*16
   quad(b.v,b.i,{{x,32,32},{x+16,32,32},{x+16,16,32},{x,16,32}},uv)
   local u,t=(uv[1][1]+uv[2][1])*.5,uv[1][2]+(uv[3][2]-uv[1][2])*.8
   quad(b.v,b.i,{{x,16,32},{x+16,16,32},{x+16,0,32},{x,0,32}},swatch(c.ts,u,t))
  end
 end end
 -- Complete native wallpaper behind claimed furniture. The drawing's
 -- window/poster faces remain just in front; object claims must not leave
 -- rectangular holes in the wall finish.
 for _,c in pairs(cells)do if c.cy==0 and c.mid~=0 and c.mid~=8 then
  local house=c.pair=='player_house'
  local shop=c.pair=='building__rom_082d4bcc'
  if house or shop then
   local b=batches[c.pair];local x=c.cx*16;local f=31.92
   local upper=uvFor(c.ts,house and 0x20 or 0x285)
   local lower=uvFor(c.ts,house and 0x28 or 0x285)
   if upper and lower then
    quad(b.v,b.i,{{x,32,f},{x+16,32,f},{x+16,16,f},{x,16,f}},upper)
    if shop then local u,v=lower[1][1],lower[3][2]-.001;lower=swatch(c.ts,u,v)end
    quad(b.v,b.i,{{x,16,f},{x+16,16,f},{x+16,0,f},{x,0,f}},lower)
   end
  end
 end end
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
  under=assert(R.newMesh(b.v,b.i),'field mesh creation failed'),roof=R.newMesh(b.rv,b.ri),plants=R.newMesh(b.pv,b.pi,R.TREE_FORMAT),water=R.newMesh(b.wv,b.wi)} end
 cache.wood=R.newMesh(wood,wi);cache.leaves=R.newMesh(leaf,li)
 cache.terrainKey=SceneCache.key(regions,x0,z0,x1,z1,Tiles._pairs,cam)
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
 draw(cache.wood,bark);draw(cache.leaves,TreeStyle.original() and V.require('NativeTreeArt').image() or foliage)
end
local function waterMeshes()
 local out={}
 for _,p in ipairs(cache.parts)do
  local ts=Tiles._pairs[p.pair]
  if p.water and ts then out[#out+1]={p.water,ts.image}end
 end
 return out
end
local reflectPlane
local dustMesh,dustImage
local function rideDust(game,cam)
 local exports=game and game.mods and game.mods.exports
 local ride=exports and exports.DRAMATIC_SKY_RIDE
 if not (ride and type(ride.groundParticles)=='function')then return end
 local ok,particles=pcall(ride.groundParticles)
 if not ok or type(particles)~='table' or #particles==0 then return end
 if not dustMesh then
  local v,i={},{}
  quad(v,i,{{-1,2,0},{1,2,0},{1,0,0},{-1,0,0}},{{0,0},{1,0},{1,1},{0,1}})
  dustMesh=R.newMesh(v,i)
  local data=love.image.newImageData(1,1);data:setPixel(0,0,.72,.62,.43,1)
  dustImage=love.graphics.newImage(data)
 end
 if not dustMesh then return end
 for _,p in ipairs(particles)do
  if type(p.x)=='number' and type(p.z)=='number' then
   local t=math.max(0,math.min(1,(tonumber(p.age)or 0)/math.max(.001,tonumber(p.life)or .4)))
   local model=Mat.mul(Mat.translate(p.x,.3+t*3,p.z),
    Mat.mul(Mat.rotateY(cam.level>=6 and -cam.yaw or 0),Mat.scale(1-t,1-t,1)))
   R.draw(dustMesh,dustImage,model)
  end
 end
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
 local padding=SpriteAnchor.framePadding(spr,frame)
 local key=tostring(spr)..':'..tostring(spr.image)..':'..frame..':'..tostring(mirror)..':'..padding
 local mesh=spriteMeshes[key]
 if not mesh then
  local qx,qy,qw,qh=q:getViewport();local iw,ih=spr.image:getDimensions()
  local l,r=qx/iw,(qx+qw)/iw;if mirror then l,r=r,l end
  local v,i={},{}
  -- Shift in local card space so lean, free-camera yaw and reflection all
  -- share the same visible baseline. Transparent padding belongs to this displayed frame.
  quad(v,i,{{-qw/2,qh-padding,0},{qw/2,qh-padding,0},{qw/2,-padding,0},{-qw/2,-padding,0}},{{l,qy/ih},{r,qy/ih},{r,(qy+qh)/ih},{l,(qy+qh)/ih}})
  mesh=R.newMesh(v,i);spriteMeshes[key]=mesh
 end
 local yaw=cam.level>=6 and -cam.yaw or 0
 local height=opts.lift or 0
 if draw~=Shadow.draw and not reflectPlane and (opts.depthOffset or 0)==0 then
  V.require("ActorContact").draw(x+8,z+16,0,height,spr.width)
 end
 local pose=Mat.rotateY(yaw)
 local base=Mat.mul(Mat.translate(x+8,height,z+16+(opts.depthOffset or 0)),pose)
 -- Use the shared GB actor contact correction. Terrain retains its full
 -- acne margin; the visible lookup must use the identical snugged caster.
 local caster=Shadow.snug(base)
 if reflectPlane then height=2*reflectPlane-height+V.require('Water').CAST_RAISE end
 local model=reflectPlane and Mat.mul(Mat.translate(x+8,height,z+16+(opts.depthOffset or 0)),pose) or base
 if reflectPlane then model=Mat.mul(model,Mat.scale(1,-1,1))end
 if draw==Shadow.draw then draw(mesh,spr.image,caster)
 else draw(mesh,spr.image,model,nil,caster) end
end
local function actors(game,cam,draw)
 if cam.replay then
  local frame=cam.replay.frame
  for _,a in ipairs(frame.actors or {})do
   if a.graphicsId and not (a.id==255 and cam.level==6) then
    local support,offset=Furniture.support(cache.cells,a.graphicsId,a.x,a.y)
    local z=a.id==255 and frame.y or a.y
    actor(a.graphicsId,a.x,z,a.facing,a.walkPhase,a.stepFlip,
     {frame=a.frame,bow=a.bow,fieldMove=a.fieldMove,depthOffset=offset or 0,lift=support+(z-a.y)},cam,draw)
   end
  end
  return
 end
 local space=package.loaded['src.core.game3.scripting.space']
 for _,eo in ipairs(Objects.forDraw())do
  local gid=eo.graphicsId or (eo.def and (eo.def.graphicsId or eo.def.graphics))
  if space and space.resolveObjectGraphicsId and eo.def then gid=space.resolveObjectGraphicsId(eo.def) or gid end
  local support,depthOffset=Furniture.support(cache.cells,gid,eo.px or eo.cellX*16,eo.py or eo.cellY*16)
  actor(gid,(eo.px or eo.cellX*16)+(eo.raiseX or 0),eo.py or eo.cellY*16,
   eo.facing or 'down',Objects.walkPhase(eo),eo.stepFlip,
   {bow=(eo.bowFrames or 0)>0 or eo.raiseHand,frame=eo.customFrame,upright=tonumber(gid)==92 or tonumber(gid)==94,depthOffset=depthOffset or 0,lift=support-(eo.raiseY or 0)},cam,draw)
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
   {fieldMove=(Player.fieldMoveAnim or 0)>0,lift=-(Player.spriteYOffset or 0)-(Player.jumpSpriteY and Player.jumpSpriteY()or 0)},cam,draw)
 end
end
-- Project the engine-owned door/healing frames into the existing 3D room.
-- Reading/drawing these effects never advances their timers or script state.
local effectCanvases={}
local function fieldEffects(draw,cam)
 local g=love.graphics
 local function effect(name,w,h,paint,verts)
  local c=effectCanvases[name]
  if not c then c=g.newCanvas(w,h);c:setFilter('nearest','nearest');effectCanvases[name]=c end
  g.push('all');g.setCanvas(c);g.origin();g.setShader();g.setScissor();g.setDepthMode();g.setBlendMode('alpha');g.clear(0,0,0,0);g.setColor(1,1,1,1)
  local ok,err=pcall(paint);g.pop();if not ok then error(err,0)end
  local v,i={},{};quad(v,i,verts,{{0,0},{1,0},{1,1},{0,1}})
  local mesh=R.newMesh(v,i);draw(mesh,c);mesh:release()
 end
 local fx=require('src.core.game3.field_effects')
 for i,a in ipairs(fx._anims or {})do if a.kind=='dust' then
  local x,z=a.cx*16,a.cy*16
  local yaw=cam and cam.level>=6 and cam.yaw or 0
  local dx,dz=8*math.cos(yaw),8*math.sin(yaw)
  effect('landing-dust-'..i,16,8,function()fx.drawFront(x,z+8,nil)end,
   {{x+8-dx,8,z+16-dz},{x+8+dx,8,z+16+dz},{x+8+dx,0,z+16+dz},{x+8-dx,0,z+16-dz}})
 end end
 local doors=require('src.core.game3.doors');local a=doors._activeAnim
 if a then
  local x,z=a.x*16,a.y*16+16.15
  effect('door',32,48,function()doors.draw(x,a.y*16-32,32,48)end,
   {{x,48,z},{x+32,48,z},{x+32,0,z},{x,0,z}})
 end
 local heal=require('src.core.game3.pokecenter_heal')
 if heal.isActive()then
  local prop,screen
  for _,c in pairs(cache.cells or {})do if c.prop then
   if c.prop.recipe.name=='center_healer'then prop=c.prop end
   if c.prop.recipe.name=='center_screen'then screen=c.prop end
  end end
  if prop then
   local x,z,h=prop.cx*16,prop.cy*16,prop.recipe.h+.18
   effect('heal-balls',32,24,function()g.translate(-80,-28);heal.drawBalls()end,
    {{x+3,h,z+12},{x+29,h,z+12},{x+29,h,z+28},{x+3,h,z+28}})
   if screen then
    local sx,sz=screen.cx*16,screen.cy*16+(screen.recipe.frontOffset or 32.2)+.04
    effect('heal-monitor',32,16,function()g.translate(-112,-16);heal.drawMonitor()end,
     {{sx+2,28,sz},{sx+30,28,sz},{sx+30,12,sz},{sx+2,12,sz}})
   end
  end
 end
end
function M.restore()
 R.battleOcclusion(nil)
 R.fog=nil
 R.interior=nil
 R.tint={1,1,1}
 reflectPlane=nil
 if saved then
  pcall(R.endScene);love.graphics.pop();love.graphics.setCanvas(savedCanvas)
  saved,savedCanvas=false,nil
 end
end
function M.draw(game,vw,vh,cam)
 if not prepare(game,vw,vh,cam) then return false end
 materials()
 -- Script camera panning belongs to the flat renderer. It must not move the
 -- first-person eye or pull the user's orbit away during dialogue/replays.
 local focus=cam.replay and cam.replay.frame or Player
 local cx,cz=(focus.px or focus.x or 0)+8,(focus.py or focus.y or 0)+8
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
 local Options=V.require('Gen3SceneOptions')
 local renderWidth,renderHeight=Options.expand(width,height)
 local def=M.sceneDef
 local indoor
 if Pairs.outdoor then indoor=not Pairs.outdoor(def)
 else indoor=def.environment=='INDOOR' or def.mapType==8 or def.mapType==4 end
 local nativeBackground=def.mapType==4 and {.045,.030,.034,1} or Interior.background
 local background=Options.environment(indoor,indoor and nativeBackground or {.60,.79,.82,1})
 local plate=cam.battle and cam.plate
 if plate then background=plate.color end
 local S=V.require('VoxelState')
 S.level=cam.level;S.angle=math.rad(S.ANGLES_DEG[cam.level+1] or 35)
 R.canopyFacing=cam.battle or cam.level>=6
 if cam.level>=6 then
  local dist=cam.level==6 and 0 or 75
  local dx,dz=math.sin(cam.yaw),-math.cos(cam.yaw)
  local ey=cam.level==6 and (23-(Player.jumpSpriteY and Player.jumpSpriteY()or 0)) or 48
  local exports=game and game.mods and game.mods.exports
  local ride=exports and exports.DRAMATIC_SKY_RIDE
  if not cam.battle and not cam.replay and ride and type(ride.currentAltitude)=='function' then
   local ok,height=pcall(ride.currentAltitude)
   if ok and type(height)=='number' then ey=ey+math.max(0,math.min(512,height))end
  end
  R.camera={eye={cx-dx*dist,ey,cz-dz*dist},focus={cx+dx*70,ey-70*math.tan(cam.pitch),cz+dz*70},fov=math.rad(62)}
  if cam.battle then
   R.camera={eye={cx-dx*75,32,cz-dz*75},focus={cx+dx*16,0,cz+dz*16},fov=math.rad(50)}
  end
 else
  R.camera=Interior.camera(Interior.forMap(M.sceneDef,3),S.angle,vw/vh)
  if R.camera then cx,cz=R.camera.focus[1],R.camera.focus[3]end
 end
 R.viewProjection(cx,cz,vw,vh)
 savedCanvas=love.graphics.getCanvas();love.graphics.push('all');saved=true
 if not plate and Shadow.begin(cx,cz,vw,vh) then
  local room=not cam.battle and Interior.forMap(M.sceneDef,3) or nil
  Shadow.roomClip(room and room.bounds)
  terrain(Shadow.draw)
  for _,d in ipairs(waterMeshes())do Shadow.draw(d[1],d[2])end
  if not cam.battle then
   Shadow.sprites(true);actors(game,cam,Shadow.draw);Shadow.sprites(false)
  end
  Shadow.finish('firered')
 end
 local room=not cam.battle and Interior.forMap(M.sceneDef,3) or nil
 Interior.setOpenings(room,cache.openings)
 Interior.configure(room)
 local bounds=M.distance.bounds
 R.fog=not indoor and Distance.haze(background,M.fadeExtent,{cx,0,cz},
  {bounds[1]*16,bounds[2]*16,(bounds[3]+1)*16,(bounds[4]+1)*16})or nil
 if not R.beginScene(renderWidth,renderHeight,cx,cz,vw,vh,background,'firered') then M.restore();return false end
 R.battleOcclusion(nil)
 if plate then
  if plate.image then R.backdrop(plate.image,plate.offset)end
 else
  Options.underlay(indoor,cx,cz,background)
  Interior.draw(room)
  terrain(R.draw)
 end
 local water=not plate and waterMeshes()or {}
 if cam.battle then
  for _,d in ipairs(water)do R.draw(d[1],d[2])end
 else
  V.require('WaterSurfacePass').draw(water,function()actors(game,cam,R.draw)end,function()
   reflectPlane=.05 -- native water surface authored by prepare()
   local ok,err=pcall(actors,game,cam,R.draw)
   reflectPlane=nil
   if not ok then error(err,0)end
  end)
  actors(game,cam,R.draw)
  if not cam.replay then rideDust(game,cam);fieldEffects(R.draw,cam)end
 end
 R.battleOcclusion(nil)
 local canvas=Options.finish(R.endScene(),width,height)
 R.fog=nil
 R.tint={1,1,1}
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
 if dustMesh then dustMesh:release();dustMesh=nil end
 if dustImage then dustImage:release();dustImage=nil end
 for _,c in pairs(effectCanvases)do c:release()end;effectCanvases={}
 releaseGeometry()
 for _,mesh in pairs(spriteMeshes)do if mesh then mesh:release() end end
 spriteMeshes={}
 if foliage then foliage:release();foliage=nil end
 if bark then bark:release();bark=nil end
 Roof.release();Outdoor.release()
 R.invalidate();Shadow.invalidate()
 V.require('Gen3SceneOptions').release()
end
return M
