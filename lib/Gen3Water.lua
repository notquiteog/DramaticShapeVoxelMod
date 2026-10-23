-- One physical sheet for native water and reviewed wet-rock underlays.
-- Native permissions/elevations and source drawings remain authoritative.
local M={LEVEL=.05}
-- Reviewed source dimensions, not collision-layer-to-height guesses.
-- ORAS Route104: walking grid36; riverbank Y0 -> -5; near-sea terrace
-- -18 -> -27. HGSS Pallet: grid16; land16 -> upper water8.
M.BANK_DEPTH={kanto=8,hoennRiver=20/9,hoennSea=4}
local directions={{1,0},{-1,0},{0,1},{0,-1}}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
local function ck(x,y)return x..':'..y end
local function isWater(c)return c and c.shape and c.shape.kind=='water'end
local function behaviorName(c,options)
 if options.behaviorName then return options.behaviorName(c.behavior)end
 local ok,MB=pcall(require,'src.core.game3.mb')
 return ok and MB.nameOf(c.behavior)or nil
end
local seaNames={OCEAN_WATER=true,DEEP_WATER=true,SOOTOPOLIS_DEEP_WATER=true,
 SEAWEED=true,SEAWEED_NO_SURFACING=true,NO_SURFACING=true,UNDERWATER_BLOCKED_ABOVE=true}
-- Third-party scenery can set shape.bankDepth / shape.waterLevel (absolute
-- world Y), shape.waterline (local offset), or preserveWaterLevel=true.
-- A region's def.voxelWater supports the same settings; false opts out.
function M.policy(c,options)
 options=options or{};local s=c.shape or{}
 local config=c.region and c.region.def and c.region.def.voxelWater
 if config==false then return{preserve=true}end
 config=type(config)=='table'and config or{}
 local authored=s.waterLevel
 if not finite(authored)and finite(config.waterLevel)then authored=config.waterLevel+(c.region.floorOffset or 0)end
 if finite(authored)then return{level=authored}end
 if finite(s.waterline)then return{level=(c.base or 0)+s.waterline}end
 if finite(config.waterline)then return{level=(c.base or 0)+config.waterline}end
 if s.preserveWaterLevel or config.preserveWaterLevel then return{preserve=true}end
 local depth=s.bankDepth
 if not finite(depth)then depth=config.bankDepth end
 if not finite(depth)then
  depth=type(options.bankDepth)=='function'and options.bankDepth(c)or options.bankDepth
 end
 if finite(depth)then return depth>0 and{depth=depth}or{preserve=true}end
 local outdoor=options.outdoor
 if type(outdoor)=='function'then outdoor=outdoor(c.region and c.region.def,c)end
 if not outdoor then return{preserve=true}end
 local region=type(options.region)=='function'and options.region(c)or options.region
 if region=='kanto'then return{depth=M.BANK_DEPTH.kanto}end
 if region=='hoenn'then
  local name=behaviorName(c,options)
  -- Native waterfall/underwater traversal already owns its distinct surface.
  if name=='WATERFALL'or name=='INTERIOR_DEEP_WATER'then return{preserve=true}end
  return{depth=(seaNames[name]or s.seaRock or s.wetRock)and M.BANK_DEPTH.hoennSea or M.BANK_DEPTH.hoennRiver}
 end
 return{preserve=true}
end
local function bank(c)
 local s=c and c.shape
 return s and s.kind~='water'and not(s.kind=='rock'and(s.seaRock or s.wetRock))
  and not c.bridge and not(c.floor and c.floor.underpass)and not c.underpass
  and s.kind~='steps'and s.kind~='ladder'and s.kind~='cliff'and s.kind~='caveWall'
end
-- Blocked surfable border art is not a physical floor anchor. TerrainLevels
-- gives such cells nearest support, which can be a raised dock or land terrace
-- instead of the surrounding ocean. Propagate actual native water-floor datums
-- through those cells only, before splitting water into height components.
local function nativeDatums(order,field,tick)
 local queue={}
 for _,n in ipairs(order)do
  local c=n.source;local f=c.floor
  if n.token=='auto'and not n.underpass and not c.boundary and f and f.kind=='water'then
   if f.floor==true then n.datumAnchor=n;queue[#queue+1]=n
   elseif f.floor==false then n.needsWaterDatum=true end
  end
 end
 -- Sources are already in native row order. Breadth first ownership preserves
 -- separate real water heights and deterministic ties between equal distances.
 local head=1
 while queue[head]do
  local n=queue[head];head=head+1
  for _,d in ipairs(directions)do
   local near=field[ck(n.cx+d[1],n.cy+d[2])]
   if near and near.needsWaterDatum and not near.datumAnchor
    and (near.layer==n.layer or near.layer==0 or n.layer==0)then
    near.datumAnchor=n.datumAnchor;near.base=n.datumAnchor.base
    queue[#queue+1]=near
   end
  end
  if tick then tick()end
 end
end
-- Build from complete native floor fields when available, so ocean level
-- never depends on whether a moving render window currently contains a bank.
function M.plan(cells,options)
 options=options or{}
 local source=cells
 if options.regions then
  source={}
  for _,r in ipairs(options.regions)do for _,f in pairs(r.floorField and r.floorField.cells or{})do
   local u=f.underpass and f.underpass.kind=='water'and f.underpass
   local c={cx=r.x+f.x,cy=r.y+f.y,mid=u and u.mid or f.mid,behavior=f.behavior,
    base=(u and u.height or f.height or 0)+(r.floorOffset or 0),floor=f,region=r,pair=r.def and r.def.midLayout and r.def.midLayout.pair,
    shape={kind=u and'water'or f.kind},underpass=u and true or nil,layer=u and u.layer or f.layer}
   local loaded=cells[ck(c.cx,c.cy)]
   -- Preserve extension recipes/overrides while the native full-map field
   -- continues to supply the stable water topology and datum outside view.
   if loaded and not u then c.shape=loaded.shape;c.bridge=loaded.bridge end
   source[ck(c.cx,c.cy)]=c
   if options.tick then options.tick()end
  end end
  -- Boundary-fill cells and a late/missing floor-field provider still use the
  -- same reviewed component profile. They cannot leave a raised water apron
  -- outside the original map or disable the entire safe presentation fallback.
  for k,c in pairs(cells)do if not source[k]then
   local nearest,distance
   for _,r in ipairs(options.regions)do
    local dx=math.max(r.x-c.cx,0,c.cx-(r.x+r.w-1))
    local dy=math.max(r.y-c.cy,0,c.cy-(r.y+r.h-1));local d=dx*dx+dy*dy
    if not distance or d<distance then nearest,distance=r,d end
   end
   source[k]={cx=c.cx,cy=c.cy,mid=c.mid,behavior=c.behavior,base=c.base,
    floor=c.floor,shape=c.shape,pair=c.pair,bridge=c.bridge,region=nearest,boundary=c.boundary}
  end end
 end
 local result={cells={},components={},source=source};local order={}
 for _,c in pairs(source)do if isWater(c)then
  local p=M.policy(c,options);local datum=c.base or 0
  local token=p.level and('level:'..p.level)or p.preserve and'preserve'or'auto'
  local n={cx=c.cx,cy=c.cy,base=datum,mid=c.shape.ground or c.mid,source=c,policy=p,
   token=token,underpass=c.underpass,layer=c.layer or(c.floor and c.floor.layer)}
  result.cells[ck(c.cx,c.cy)]=n;order[#order+1]=n
 end end
 table.sort(order,function(a,b)return a.cy==b.cy and a.cx<b.cx or a.cy<b.cy end)
 nativeDatums(order,result.cells,options.tick)
 for _,start in ipairs(order)do if not start.component then
  local g={cells={},depth=0,base=start.base};result.components[#result.components+1]=g
  local queue,head={start},1;start.component=g
  while queue[head]do
   local n=queue[head];head=head+1;g.cells[#g.cells+1]=n
   g.depth=math.max(g.depth,n.policy.depth or 0)
   for _,d in ipairs(directions)do
    local k=ck(n.cx+d[1],n.cy+d[2]);local near=result.cells[k]
    if near and not near.component and near.token==n.token and math.abs(near.base-n.base)<1e-6 then
     near.component=g;queue[#queue+1]=near
    elseif not near then
     local land=source[k]
     if bank(land)then g.bank=math.min(g.bank or math.huge,land.base or 0)end
    end
   end
   if options.tick then options.tick()end
  end
  -- Existing visibly recessed pools/decks retain their complete drawn level.
  -- A higher cliff beside one shore never deepens an already lower body.
  local recessed=g.bank and g.bank-g.base>.15
  g.surface=start.policy.level or g.base+M.LEVEL
  if not start.policy.preserve and not start.policy.level and not recessed and g.depth>0 then
   g.surface=g.base-g.depth
  end
  g.preserved=recessed or start.policy.preserve or start.policy.level~=nil
  for _,n in ipairs(g.cells)do n.surface=g.surface end
 end end
 return result
end
function M.surface(c,layer)
 if not c then return end
 if isWater(c)then return c.waterSurface or(c.base or 0)+M.LEVEL end
 if c.floor and c.floor.underpass and c.floor.underpass.kind=='water'and layer==c.floor.underpass.layer then
  return c.underWaterSurface or c.floor.underpass.height+(c.base or 0)-(c.floor.height or 0)+M.LEVEL
 end
 if c.shape and c.shape.kind=='rock'and(c.shape.seaRock or c.shape.wetRock)then
  return(c.base or 0)+(c.shape.waterline or M.LEVEL)
 end
end
function M.localLevel(c,layer)local level=M.surface(c,layer);return level and level-(c.base or 0)end
-- This support query excludes blocked wet-rock cells. Land actors remain on
-- the ordinary native terrain; underpass water requires its exact native layer.
function M.support(c,layer)
 if c and(isWater(c)or c.floor and c.floor.underpass and c.floor.underpass.kind=='water'and layer==c.floor.underpass.layer)then
  return M.surface(c,layer)
 end
end
function M.at(field,x,z,layer)
 local n=field and field.cells[ck(math.floor(x/16),math.floor(z/16))]
 if n and(not n.underpass or layer==n.layer)then return n.surface end
end
local palettes=setmetatable({},{__mode='k'})
-- Derive body color from a real native water drawing once per live atlas.
-- Only blue water pixels contribute; banks, white foam and transparent art
-- keep their original material. Failed/late providers are retried.
function M.tint(ts,mid)
 local source=ts and ts.imageData
 local slot=ts and ts.midToSlot and ts.midToSlot[mid]
 if not(source and slot and ts.cols)then return end
 local old=palettes[ts]
 if not old or old.source~=source then old={source=source};palettes[ts]=old end
 local entry=old[mid]
 if entry then
  local same=true
  -- Native palette edits may repaint ImageData in place. Recheck one source
  -- pixel per native color, rather than rescanning the whole tile on
  -- every frame or retaining a stale palette until the provider is replaced.
  for _,p in ipairs(entry.probes)do
   local rr,gg,bb,aa=source:getPixel(p[1],p[2])
   if rr~=p[3]or gg~=p[4]or bb~=p[5]or aa~=p[6]then same=false;break end
  end
  if same then return entry.tint or nil end
 end
 local r,g,b,n=0,0,0,0
 local probes,colors={},{}
 local sx,sy=slot%ts.cols*16,math.floor(slot/ts.cols)*16
 for y=0,15 do for x=0,15 do
  local rr,gg,bb,aa=source:getPixel(sx+x,sy+y)
  local key=rr..':'..gg..':'..bb..':'..aa
  if not colors[key]then colors[key]=true;probes[#probes+1]={sx+x,sy+y,rr,gg,bb,aa}end
  if aa>=.5 and bb>gg+.065 and bb>rr+.12 then
   r,g,b,n=r+rr,g+gg,b+bb,n+1
  end
 end end
 if n<16 then old[mid]={tint=false,probes=probes};return end
 local tint={r/n,g/n,b/n,.88};old[mid]={tint=tint,probes=probes};return tint
end
function M.note(batch,mid)
 batch.waterMids=batch.waterMids or{}
 batch.waterMids[mid]=(batch.waterMids[mid]or 0)+1
end
function M.dominant(mids)
 local chosen,count
 for mid,n in pairs(mids or{})do
  if not count or n>count or n==count and mid<chosen then chosen,count=mid,n end
 end
 return chosen
end
function M.complete(cells,members,fetch)
 local roots,seen={},{}
 for _,c in pairs(cells)do
  local m=c.primary=='general'and not c.boundary and members[c.mid]
  if m then
   local x,y=c.cx-m[2],c.cy-m[3];local k=x..':'..y
   if not seen[k]then seen[k]=true;roots[#roots+1]={x,y}end
  end
 end
 -- Load only the missing cells of a recognized 2x2 source drawing. The
 -- normal recipe still validates every metatile and native permission;
 -- a window edge cannot turn a known rock back into a painted water patch.
 for _,r in ipairs(roots)do for y=r[2],r[2]+1 do for x=r[1],r[1]+1 do
  if not cells[x..':'..y]then fetch(x,y)end
 end end end
end
local function wet(c)
 local s=c and c.shape
 return s and s.kind=='rock'and(s.seaRock or s.wetRock)
end
function M.underlay(c)
 if wet(c)then return c.shape.waterGround or c.shape.ground,c.shape.waterline or M.LEVEL end
end
function M.bind(cells,options)
 local field=M.plan(cells,options)
 -- The small-rock metatiles are also reused on dry native town floors.
 -- An ID/permission alone never proves a water underlay. Require an actual
 -- neighboring native water cell, including the complete field outside a
 -- streamed window; synthesized biome water is not evidence.
 for _,c in pairs(cells)do if c.shape.wetRock and not c.shape.seaRock then
  local proven=false;local votes={}
  for y=c.cy-1,c.cy+1 do for x=c.cx-1,c.cx+1 do if x~=c.cx or y~=c.cy then
   local k=ck(x,y);local n=cells[k];local full=field.cells[k]
   if full and not full.underpass then
    local source=full.source
    if source and not source.boundary and(source.floor and source.floor.kind=='water'
     or n and not n.boundary and n.collision~=nil and isWater(n))then proven=true end
   end
   local donor=n or field.source[k]
   if donor and not donor.boundary and(donor.pair==c.pair or donor.pair==c.nativePair)then
    local s=donor.shape;local mid
    if s and not donor.prop and not donor.civic and not donor.column then
     if s.kind=='flat'or s.kind=='ground'or s.kind=='interiorFloor'then mid=s.ground or donor.mid
     elseif s.kind=='tree'or s.kind=='grass'or s.kind=='flowers'or s.kind=='shrub'then mid=s.ground end
    end
    if mid and(not c.ts or not c.ts.midToSlot or c.ts.midToSlot[mid]~=nil)then votes[mid]=(votes[mid]or 0)+1 end
   end
  end end end
  if not proven then
   local ground,best=1,0
   for mid,n in pairs(votes)do if n>best or n==best and mid<ground then ground,best=mid,n end end
   c.shape.wetRock,c.shape.waterline,c.shape.waterGround=nil,nil,nil
   c.shape.ground=ground
  end
 end end
 for k,c in pairs(cells)do
  local n=field.cells[k]
  c.waterSurface=n and not n.underpass and n.surface or nil
  c.underWaterSurface=n and n.underpass and n.surface or nil
 end
 local count,seen=0,{}
 for _,c in pairs(cells)do if wet(c)then
  count=count+1
  local g=c.shape.seaRock or c
  if not seen[g]then
   seen[g]=true
   local root=g.root or c;local w=g.family and #g.family.rows[1]or 1;local h=g.family and #g.family.rows or 1
   local votes,best,chosen={},0,nil
   -- Use the immediate body's actual drawn level and source water, rather
   -- than a blocked cell's unrelated collision-layer number or land height.
   for y=root.cy-1,root.cy+h do for x=root.cx-1,root.cx+w do
    local n=cells[x..':'..y];local full=field.cells[x..':'..y]
    if (n and n.shape.kind=='water')or full and not full.underpass then
     local level=full and full.surface or M.surface(n)
     local mid=full and full.mid or n.shape.ground or n.mid
     -- A connected neighboring tileset can prove the plane without donating
     -- an incompatible metatile number to this rock's own atlas.
     local own=n and n.pair==c.pair or c.ts and c.ts.midToSlot and c.ts.midToSlot[mid]~=nil
     if not own then mid=root.shape.ground or g.ground or mid end
     local k=string.format('%.6f:%s',level,mid)
     votes[k]=(votes[k]or 0)+1
     if votes[k]>best then best=votes[k];chosen={level,mid}end
    end
   end end
   local level=chosen and chosen[1]or(root.base or 0)+M.LEVEL
   if not chosen and options then
    -- A complete rock at a window edge may have no emitted water neighbor.
    -- Retain the reviewed body's datum without treating our previous generated
    -- rock waterline as an author override on the next scene build.
    local s=root.shape
    local proxy={base=root.base,behavior=root.behavior,region=root.region,
     shape={kind='water',seaRock=s.seaRock,wetRock=s.wetRock,bankDepth=s.bankDepth,
      waterLevel=s.waterLevel,preserveWaterLevel=s.preserveWaterLevel}}
    local p=M.policy(proxy,options)
    level=p.level or(p.depth and(root.base or 0)-p.depth)or level
   end
   local ground=chosen and chosen[2]or root.shape.ground
   for y=root.cy,root.cy+h-1 do for x=root.cx,root.cx+w-1 do
    local n=cells[x..':'..y]
    if n and wet(n)and(n.shape.seaRock or n)==g then
     n.shape.waterline=level-(n.base or 0);n.shape.waterGround=ground
    end
   end end
  end
 end end
 return count,field
end
-- Water geometry and height groups do not change between scene rebuilds.
-- Keep these lists stable, but refresh the provider image after palette reloads.
function M.draws(parts)
 local out,byHeight,levels={},{},{}
 for _,p in ipairs(parts)do for _,water in ipairs(p.waters or{})do
  local d={water.mesh,nil,nil,water.height,mesh=water.mesh,pair=p.pair,waterMid=p.waterMid,bounds=water.bounds}
  out[#out+1]=d
  local group=byHeight[water.height]
  if not group then group={height=water.height};byHeight[water.height]=group;levels[#levels+1]=group end
  group[#group+1]=d
  -- A level can use several tilesets. Union every physical sheet; missing
  -- metadata fails open rather than accidentally hiding a provider's water.
  if water.bounds and not group.unbounded then
   local b=group.bounds
   if not b then b={unpack(water.bounds)};group.bounds=b else
    for k=1,3 do b[k]=math.min(b[k],water.bounds[k]);b[k+3]=math.max(b[k+3],water.bounds[k+3])end
   end
  else group.bounds=nil;group.unbounded=true end
 end end
 table.sort(levels,function(a,b)return a.height<b.height end)
 return out,levels
end
function M.sync(draws,providers)
 for _,d in ipairs(draws)do
  local ts=providers[d.pair];d[1],d[2]=ts and d.mesh or nil,ts and ts.image or nil
  d[5]=d.waterMid and M.tint(ts,d.waterMid)or nil
 end
 return draws
end
return M
