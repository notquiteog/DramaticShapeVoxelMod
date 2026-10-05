-- Shared presentation-only room framing. Native layouts, furniture, warps and
-- collision remain authoritative. Camera-facing walls open outside the room;
-- an eye inside the room sees all four walls and a ceiling.
local V=...
local M={background={.022,.032,.046,1}}
local cache=setmetatable({},{__mode='k'})
local materials={}
local themes={
 cave={{.38,.34,.30},{.35,.32,.28},{.33,.30,.27},{.42,.38,.34}},
 ice={{.35,.49,.60},{.33,.47,.57},{.31,.44,.54},{.43,.57,.66}},
 ship={{.86,.86,.89},{.52,.52,.60},{.29,.29,.35},{.92,.91,.72}},
 home={{.73,.71,.61},{.37,.35,.28},{.20,.22,.22},{.91,.87,.70}},
 shop={{.67,.76,.73},{.23,.43,.43},{.13,.25,.29},{.84,.94,.88}},
 center={{.79,.77,.70},{.45,.35,.32},{.22,.27,.30},{.97,.88,.72}},
 lab={{.69,.74,.73},{.29,.40,.43},{.17,.24,.28},{.83,.94,.92}},
}
function M.profile(def,gen)
 if not def then return end
 local id=def.id or '';local ts=def.tileset or '';local spec
 local cave=gen==1 and ts=='CAVERN' or gen==2 and def.environment=='CAVE' or gen==3 and tonumber(def.mapType)==4
 if gen==3 then
  if tonumber(def.mapType)~=8 and not cave then return end
  local pair=def.midLayout and def.midLayout.pair
  if not pair then return end
  spec=V.require('Gen3Tilesets').resolve(pair,require('src.import.gba.versions').TILESET_PAIRS)
  -- This tunnel deliberately uses the Route 114 atlas and native INDOOR
  -- header. Its original drawing is a closed rock passage, not a house.
  -- Keep the exception map-scoped: Route 114 shares every one of these tiles.
  if id=='EM_ROUTE114_FOSSIL_MANIACS_TUNNEL' and spec.primary=='general'
    and spec.secondary=='fallarbor' then cave=true end
  -- General-primary room families share their atlas with outdoor maps.
  -- Map type alone is insufficient: event islands and ferry docks may also
  -- be tagged INDOOR to suppress native weather. Keep those open.
  local rooms={facility=true,bike_shop=true,contest=true,inside_ship=true,
   battle_frontier=true,battle_palace=true,inside_of_truck=true,battle_tent=true}
  if not cave and spec.primary~='building' and spec.secondary~='rom_082d4d94'
    and not rooms[spec.secondary] then return end
 elseif gen==2 then
  if def.environment~='INDOOR' and def.environment~='GATE' and not cave then return end
 else
  -- Buildings and caves are enclosed; outdoor maps keep their scenery.
  --
  -- SHIP, CEMETERY and MANSION were missing here and every map that uses them
  -- was getting no room at all, so no ceiling: the S.S. Anne (12 maps), the
  -- Pokemon Tower (8) and the Celadon Mansion (5) all rendered as a black void
  -- in BOTH cameras. Confirmed against the data -- all 25 are interior maps
  -- with connections = {}.
  --
  -- Deliberately NOT a "no connections means a room" rule: 186 of 222 Gen 1
  -- maps have no connections, and that set includes genuinely outdoor
  -- tilesets (SHIP_PORT, PLATEAU, FOREST, UNDERGROUND), which would have put
  -- a lid over open ground.
  local allowed={REDS_HOUSE_1=true,REDS_HOUSE_2=true,HOUSE=true,HOUSE_1=true,
   HOUSE_2=true,MART=true,POKECENTER=true,DOJO=true,GYM=true,CLUB=true,
   LOBBY=true,LAB=true,FACILITY=true,INTERIOR=true,GATE=true,
   FOREST_GATE=true,MUSEUM=true,BEACH_HOUSE=true,
   SHIP=true,CEMETERY=true,MANSION=true}
  if not allowed[ts] and not cave then return end
 end
 local name=(id..' '..ts):upper()
 local theme=name:find('MART') and 'shop' or name:find('CENTER') and 'center' or name:find('LAB') and 'lab' or 'home'
 if spec and spec.secondary=='rom_082d4d94' then theme='ship' end
 if cave then theme=(name:find('ICE') or name:find('SEAFOAM')) and 'ice' or 'cave' end
 local unit=gen==3 and 16 or 32
 local b={0,0,def.width*unit,def.height*unit}
 if gen==3 and not cave then
  -- Native layouts include padded black cells. Do not enclose that padding.
  local x0,z0,x1,z1=def.width,def.height,0,0
  for y=0,def.height-1 do for x=0,def.width-1 do
   local mid=def.midLayout:midAt(x,y)
   if mid and mid~=0 and mid~=8 and mid~=0x1A and mid~=0x1B and mid~=0x1C then
    x0,z0,x1,z1=math.min(x0,x),math.min(z0,y),math.max(x1,x+1),math.max(z1,y+1)
   end
  end end
  if x1<=x0 or z1<=z0 then return end
  b={x0*16,z0*16,x1*16,z1*16}
  local secondary=V.require('Gen3Tilesets').resolve(def.midLayout.pair,require('src.import.gba.versions').TILESET_PAIRS).secondary
  if secondary=='lab' or secondary=='pokemon_center' or def.midLayout.pair=='player_house' or def.midLayout.pair=='house' or theme=='shop' or secondary=='rom_082d4d94' then
   -- The first two rows are the north wall drawing, not extra floor behind
   -- the cabinets. Its continuous backing sits just behind the native facade.
   b[2]=math.min(b[4]-16,(z0+2)*16)-.12
  end
 elseif gen==2 then
  local fronts={TILESET_PLAYERS_HOUSE=16,TILESET_PLAYERS_ROOM=16,TILESET_HOUSE=16,TILESET_LAB=16,TILESET_POKECENTER=16}
  if fronts[ts]then b[2]=fronts[ts]-.3 end
 end
 return {bounds=b,height=cave and 96 or gen==3 and (theme=='lab' or theme=='center') and 32 or 40,theme=theme,gen=gen,cave=cave}
end
local function texture(theme)
 if materials[theme]then return materials[theme]end
 local data=love.image.newImageData(8,1)
 local colors=themes[theme]
 for i=1,8 do local c=colors[(i-1)%4+1];local shade=i>4 and .84 or 1
  data:setPixel(i-1,0,c[1]*shade,c[2]*shade,c[3]*shade,1)
 end
 local image=love.graphics.newImage(data);image:setFilter('nearest','nearest');data:release();materials[theme]=image;return image
end
function M.geometry(p,side,opened)
 local b,h=p.bounds,p.height;local x0,z0,x1,z1=b[1],b[2],b[3],b[4]
 local verts,indices={},{}
 local function face(points,swatch,shade)
  local n=#verts
  -- One material texel per face. Alternating palette indices at corners
  -- interpolates across the quad's triangles; nearest filtering then makes
  -- unrelated dark/light wedges that look like broken cast shadows.
  -- Geometry shading and the renderer's actual shadow pass remain active.
  local u=(swatch-.5)/8
  for _,a in ipairs(points)do
   verts[#verts+1]={a[1],a[2],a[3],u,.5,shade or 1}
  end
  for _,k in ipairs({1,2,3,1,3,4})do indices[#indices+1]=n+k end
 end
 local function box(a,y0,c,d,y1,f,swatch)
  face({{a,y1,c},{d,y1,c},{d,y1,f},{a,y1,f}},swatch,1)
  face({{a,y1,f},{d,y1,f},{d,y0,f},{a,y0,f}},swatch,.9)
  face({{d,y1,c},{a,y1,c},{a,y0,c},{d,y0,c}},swatch,.9)
  face({{a,y1,c},{a,y1,f},{a,y0,f},{a,y0,c}},swatch,.85)
  face({{d,y1,f},{d,y1,c},{d,y0,c},{d,y0,f}},swatch,.85)
 end
 if side==5 then
  -- The diorama plinth must not seal modeled stairs/escalators below floor.
  local xs,zs={x0-3,x1+3},{z0-3,z1+3}
  for _,q in ipairs(p.openings or {})do
   xs[#xs+1]=math.max(x0-3,math.min(x1+3,q[1]));xs[#xs+1]=math.max(x0-3,math.min(x1+3,q[3]))
   zs[#zs+1]=math.max(z0-3,math.min(z1+3,q[2]));zs[#zs+1]=math.max(z0-3,math.min(z1+3,q[4]))
  end
  table.sort(xs);table.sort(zs)
  for i=1,#xs-1 do for j=1,#zs-1 do
   local a,c,d,f=xs[i],zs[j],xs[i+1],zs[j+1];local cut=false
   for _,q in ipairs(p.openings or {})do
    if (a+d)/2>q[1] and (a+d)/2<q[3] and (c+f)/2>q[2] and (c+f)/2<q[4]then cut=true;break end
   end
   if not cut and d>a and f>c then box(a,-4,c,d,-.25,f,3)end
  end end
 elseif side==6 then
  face({{x0,h,z0},{x1,h,z0},{x1,h,z1},{x0,h,z1}},1)
 else
  local horizontal=side==1 or side==3
  local start,finish=horizontal and x0 or z0,horizontal and x1 or z1
  local line=side==1 and z0 or side==3 and z1 or side==2 and x1 or x0
  local outward=(side==1 or side==4)and -1 or 1
  local function part(a,y0,c,y1,swatch,depth)
   local function strip(l,r,at)
    local near,far=at-outward*math.max(0,(depth or 3)-3),at+outward*(depth or 3)
    if horizontal then box(l,y0,math.min(near,far),r,y1,math.max(near,far),swatch)
    else box(math.min(near,far),y0,l,math.max(near,far),y1,r,swatch)end
   end
   if side==1 and p.northFront then
    local cuts={a,c}
    for _,q in ipairs(p.northRecesses)do
     for _,x in ipairs({q[1],q[2]})do if x>a and x<c then cuts[#cuts+1]=x end end
    end
    table.sort(cuts)
    for i=1,#cuts-1 do
     local l,r=cuts[i],cuts[i+1];local at=p.northFront
     for _,q in ipairs(p.northRecesses)do if (l+r)/2>q[1] and (l+r)/2<q[2]then at=q[3]end end
     if r>l then strip(l,r,at)end
    end
   else strip(a,c,line)end
  end
  if side==1 and p.northFront then
   -- Closed returns around the stair bay, with backing behind the flight.
   -- Keeping the original front across this cell hid the entire staircase.
   for _,q in ipairs(p.northRecesses)do for _,x in ipairs({q[1],q[2]})do
    if x>start and x<finish then box(x-.3,opened and -3 or 0,q[3]-3,x+.3,opened and 0 or h,p.northFront,2)end
   end end
  end
  if opened then
   -- A low continuous foundation presents a finished cut edge without
   -- covering sprites, the entry mat, or interaction targets.
   part(start,-3,finish,0,3)
  elseif p.cave then
   -- Continuous stone strata with a closed back, all outside the playable
   -- footprint. Native maze walls stay in front; no house trim or windows.
   for a=start,finish-1,16 do
    local c=math.min(finish,a+16)
    local floor,lintel=-4,-4
    for _,q in ipairs(p.passages and p.passages[side] or {})do
     if a<q[2] and c>q[1]then floor=q[3];lintel=math.max(lintel,floor+32)end
    end
    if lintel>-4 and floor>0 then part(a,-4,c,floor,3)end
    for y=lintel,h-1,12 do
     local band=math.floor(y/12);local swatch=1+(math.floor(a/16)*13+band*7+side*11)%3
     part(a,y,c,math.min(h,y+12),swatch,3+((math.floor(a/16)+band+side)%3)*.4)
    end
   end
  else
   part(start,8,finish,h-3.5,1)
   part(start,0,finish,7,2,3.3)
   part(start,7,finish,8,3,3.6)
   part(start,h-2,finish,h+1.2,3,4)
   part(start,h-3.5,finish,h-2,2,3.5)
   for _,a in ipairs({start,finish-2})do part(a,0,a+2,h,2,3.6)end
   -- Window openings belong to native artwork/model recipes. Do not invent
   -- luminous side-wall panels in every room (including windowless rooms).
  end
 end
 return verts,indices
end
function M.forMap(map,gen)
 local def=map and map.def or map
 if not def then return end
 local entry=cache[def]
 if entry~=nil then return entry or nil end
 local p=M.profile(def,gen)
 if not p then cache[def]=false;return end
 if p.cave then
  local field=gen==2 and V.require('Gen2Elevation').field(map) or gen==3 and V.require('Gen3Elevation').field(def)
  for _,c in pairs(field and field.cells or {})do p.height=math.max(p.height,(c.high or c.height or 0)+64)end
  -- Only native exits/connections open the shell. Several cave boundary
  -- drawings use walkable collision despite being walls. Interior warp
  -- stairs retain their separate floor cut.
  p.passages={{},{},{},{}}
  local w,h=def.width*(gen==3 and 1 or 2),def.height*(gen==3 and 1 or 2)
  local function passage(side,x,y,along)
   local walk
   if gen==3 then local cell=def.midLayout:cellAt(x,y);walk=cell and cell.coll~=7
   else walk=map.isWalkableCell and map:isWalkableCell(x,y) or map.isWaterCell and map:isWaterCell(x,y)end
   local exit=false
   for _,warp in ipairs(def.warps or {})do
    if warp.x==x and warp.y==y then exit=true;break end
   end
   -- Connected cave maps may expose a walkable seam without a warp event.
   local direction=({'north','east','south','west'})[side]
   for key,connection in pairs(def.connections or {})do
    if key==direction or connection.direction==direction then exit=true;break end
   end
   if walk and exit then
    local c=field and field.cells[x..':'..y]
    p.passages[side][#p.passages[side]+1]={along*16,(along+1)*16,c and c.height or 0}
   end
  end
  for x=0,w-1 do passage(1,x,0,x);passage(3,x,h-1,x)end
  for y=0,h-1 do passage(4,0,y,y);passage(2,w-1,y,y)end
 end
 if gen~=3 and type(map.tileAt)=='function' and type(map.tileset)=='table' then
  -- The room's foundation used to seal GB stairwells at y=-.25, hiding
  -- every descending tread. Use the same semantic openings as the mesher.
  local Shapes=V.require('TileShape');local shapes=Shapes.forMap(map)
  p.openings={};p.northRecesses={}
  for y=0,(map.heightCells or def.height*2)-1 do for x=0,(map.widthCells or def.width*2)-1 do
   local s=Shapes.at(map,shapes,map:tileAt(x*2,y*2),x*2,y*2)
   local c=s and s.class or ''
   if c:match('^stair_') and y*16<p.bounds[2]then
    p.northRecesses[#p.northRecesses+1]={x*16,(x+1)*16,y*16-.3}
   end
   if c=='ladder_down' or c:match('^stair_down_')then
    p.openings[#p.openings+1]={x*16,y*16,(x+1)*16,(y+1)*16}
   end
  end end
  if #p.northRecesses>0 then
   p.northFront=p.bounds[2]
   for _,q in ipairs(p.northRecesses)do p.bounds[2]=math.min(p.bounds[2],q[3])end
  end
 end
 p.meshes={};cache[def]=p;return p
end
function M.setOpenings(p,openings)
 if not p then return end
 local keys={};for _,q in ipairs(openings or {})do keys[#keys+1]=table.concat(q,',')end;table.sort(keys)
 local signature=table.concat(keys,';')
 if signature==p.openingSignature then return end
 p.openingSignature=signature;p.openings=openings
 for key,mesh in pairs(p.meshes or {})do if key:match('^5:')then mesh:release();p.meshes[key]=nil end end
end
function M.camera(p,angle,aspect)
 if not p or p.cave then return end
 local b=p.bounds;local w,d=b[3]-b[1],b[4]-b[2]
 -- Compact rooms read as complete dioramas; large halls keep the player's
 -- scrolling camera. Free/first-person cameras never call this helper.
 if w>320 or d>256 then return end
 local a=math.max(.01,math.min(math.rad(75),angle or math.rad(35)))
 local fov=math.rad(48);local h=p.height
 local extent=math.max((w+10)*.5/math.max(.5,aspect or 1.5),(d*math.cos(a)+h*math.sin(a))*.5)
 local distance=extent/math.tan(fov*.5)+(d*math.sin(a)+h*math.cos(a))*.5+10
 local x,z=(b[1]+b[3])*.5,(b[2]+b[4])*.5
 return {eye={x,h*.35+distance*math.cos(a),z+distance*math.sin(a)},focus={x,h*.35,z},fov=fov,curve=0}
end
function M.configure(p)
 V.require('Voxel3D').interior=p
end
function M.draw(p)
 if not p then return end
 local R=V.require('Voxel3D');local eye=R.eye or {0,100,1000};local b=p.bounds
 local inside=eye[1]>b[1] and eye[1]<b[3] and eye[3]>b[2] and eye[3]<b[4] and eye[2]<p.height-.05
 local opened={not inside and eye[3]<b[2],not inside and eye[1]>b[3],not inside and eye[3]>b[4],not inside and eye[1]<b[1]}
 if not inside and not (opened[1] or opened[2] or opened[3] or opened[4])then
  -- Near-overhead cameras can project inside the footprint while still
  -- looking down from outside. Open their near wall too, without a ceiling.
  local dx,dz=(eye[1]-(b[1]+b[3])*.5)/(b[3]-b[1]),(eye[3]-(b[2]+b[4])*.5)/(b[4]-b[2])
  opened[math.abs(dx)>math.abs(dz) and (dx>0 and 2 or 4) or (dz<0 and 1 or 3)]=true
 end
 R.interiorClip(false)
 for side=1,inside and 6 or 5 do
  local key=side..':'..tostring(opened[side] or false)
  if not p.meshes[key]then local v,i=M.geometry(p,side,opened[side]);p.meshes[key]=R.newMesh(v,i)end
  R.draw(p.meshes[key],texture(p.theme))
 end
 R.interiorClip(true)
end
return M
