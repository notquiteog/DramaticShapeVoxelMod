-- Exact outdoor FRLG native cave mouths. Carve a recessed opening from the
-- local cliff mass; presentation only, never mutate native permissions/warps.
local V=...
local M={}
local locations={
 FR_ROUTE_4={{19,5},{32,5}},FR_ROUTE_10={{8,19},{8,57}},FR_ROUTE_11={{6,7}},
 FR_ROUTE_2={{17,11}},FR_ROUTE_20={{60,8},{72,14}},FR_ROUTE_23={{5,28},{18,28}},
 FR_CERULEAN_CITY={{1,12}},FR_FOUR_ISLAND={{38,12}},
 FR_FIVE_ISLAND_RESORT_GORGEOUS={{64,13}},FR_SIX_ISLAND_OUTCAST_ISLAND={{7,21}},
 FR_THREE_ISLAND_PORT={{16,4},{38,5}},FR_SEVEN_ISLAND_SEVAULT_CANYON={{7,17}},
 SEVII_ONE_ISLAND_KINDLE_ROAD={{15,58}},FR_MT_EMBER_EXTERIOR={{14,24},{39,19}},
 FR_NAVEL_ROCK_EXTERIOR={{9,8}},
}
M.locations=locations
-- The original script opens this seal as MID838. The public native map
-- normalizes its live warp to collision113; follow that authoritative cell.
M.storyLocations={FR_MT_EMBER_EXTERIOR={{42,39,terrainHood=true}}}
local expectedPairs={
 ["FR_CERULEAN_CITY"]="general__rom_082d4af4",
 ["FR_FIVE_ISLAND_RESORT_GORGEOUS"]="general__rom_082d5064",
 ["FR_FOUR_ISLAND"]="general__rom_082d5064",
 ["FR_MT_EMBER_EXTERIOR"]="sevii_outdoor",
 ["FR_NAVEL_ROCK_EXTERIOR"]="sevii_outdoor",
 ["FR_ROUTE_10"]="general__rom_082d4b0c",
 ["FR_ROUTE_11"]="general__rom_082d4b24",
 ["FR_ROUTE_2"]="viridian_outdoor",
 ["FR_ROUTE_20"]="general__rom_082d4b6c",
 ["FR_ROUTE_23"]="general__rom_082d4b84",
 ["FR_ROUTE_4"]="general__rom_082d4af4",
 ["FR_SEVEN_ISLAND_SEVAULT_CANYON"]="general__rom_082d507c",
 ["FR_SIX_ISLAND_OUTCAST_ISLAND"]="general__rom_082d507c",
 ["FR_THREE_ISLAND_PORT"]="sevii_outdoor",
 ["SEVII_ONE_ISLAND_KINDLE_ROAD"]="sevii_outdoor"
}
local destinations={
 ["FR_CERULEAN_CITY:1:12"]="FR_CERULEAN_CAVE_1F",
 ["FR_FIVE_ISLAND_RESORT_GORGEOUS:64:13"]="FR_FIVE_ISLAND_LOST_CAVE_ENTRANCE",
 ["FR_FOUR_ISLAND:38:12"]="FR_FOUR_ISLAND_ICEFALL_CAVE_ENTRANCE",
 ["FR_MT_EMBER_EXTERIOR:14:24"]="FR_MT_EMBER_SUMMIT_PATH_1F",
 ["FR_MT_EMBER_EXTERIOR:39:19"]="FR_MT_EMBER_SUMMIT_PATH_3F",
 ["FR_MT_EMBER_EXTERIOR:42:39"]="FR_MT_EMBER_RUBY_PATH_1F",
 ["FR_NAVEL_ROCK_EXTERIOR:9:8"]="FR_NAVEL_ROCK_1F",
 ["FR_ROUTE_10:8:19"]="FR_ROCK_TUNNEL_1F",
 ["FR_ROUTE_10:8:57"]="FR_ROCK_TUNNEL_1F",
 ["FR_ROUTE_11:6:7"]="FR_DIGLETTS_CAVE_SOUTH_ENTRANCE",
 ["FR_ROUTE_20:60:8"]="FR_SEAFOAM_ISLANDS_1F",
 ["FR_ROUTE_20:72:14"]="FR_SEAFOAM_ISLANDS_1F",
 ["FR_ROUTE_23:18:28"]="FR_VICTORY_ROAD_2F",
 ["FR_ROUTE_23:5:28"]="FR_VICTORY_ROAD_1F",
 ["FR_ROUTE_2:17:11"]="FR_DIGLETTS_CAVE_NORTH_ENTRANCE",
 ["FR_ROUTE_4:19:5"]="FR_MT_MOON_1F",
 ["FR_ROUTE_4:32:5"]="FR_MT_MOON_B1F",
 ["FR_SEVEN_ISLAND_SEVAULT_CANYON:7:17"]="FR_SEVEN_ISLAND_SEVAULT_CANYON_TANOBY_KEY",
 ["FR_SIX_ISLAND_OUTCAST_ISLAND:7:21"]="FR_SIX_ISLAND_ALTERING_CAVE",
 ["FR_THREE_ISLAND_PORT:16:4"]="FR_THREE_ISLAND_DUNSPARCE_TUNNEL",
 ["FR_THREE_ISLAND_PORT:38:5"]="FR_THREE_ISLAND_DUNSPARCE_TUNNEL",
 ["SEVII_ONE_ISLAND_KINDLE_ROAD:15:58"]="FR_ONE_ISLAND_KINDLE_ROAD_EMBER_SPA"
}
local function cliff(c)return c and c.shape and c.shape.kind=='cliff'and not(c.civic or c.prop or c.stairs)end
function M.prepare(cells,regions)
 local version=V.require('Generation').version()
 if version=='emerald'or version=='ruby'or version=='sapphire'then
  local ok,adapter=pcall(V.require,'Gen3HoennCaveEntrances')
  return ok and adapter and adapter.prepare(cells,regions)or 0
 end
 if version~='firered'and version~='leafgreen'then return 0 end
 local count=0
 for _,r in ipairs(regions)do
  local def=r.def
  local points={}
  for _,p in ipairs(locations[def.id]or{})do points[#points+1]=p end
  for _,p in ipairs(M.storyLocations[def.id]or{})do points[#points+1]=p end
  for _,p in ipairs(points)do
   local x,y=r.x+p[1],r.y+p[2];local c=cells[x..':'..y]
   local n,w,e,s=cells[x..':'..(y-1)],cells[(x-1)..':'..y],cells[(x+1)..':'..y],cells[x..':'..(y+1)]
   local mid=def.id=='FR_MT_EMBER_EXTERIOR'or def.id=='FR_NAVEL_ROCK_EXTERIOR'
   mid=mid and 838 or 169
   local warp
   for _,q in ipairs(def.warps or{})do if q.x==p[1]and q.y==p[2]then warp=q end end
   if c and c.mid==mid and c.primary=='general'and c.collision==113 and c.shape.kind=='flat'
    and c.pair==expectedPairs[def.id]
    and not(c.civic or c.prop or c.column or c.stairs)and warp
    and warp.destMap==destinations[def.id..':'..p[1]..':'..p[2]]and cliff(n)and cliff(w)and cliff(e)
    and n.mid==(mid==838 and 860 or 124)and s and s.collision~=7 and s.shape.kind~='cliff'
    and(c.base or 0)==(s.base or 0)then
    local h=n.shape.height or 16
    if(w.shape.height or 16)==h and(e.shape.height or 16)==h then
     c.caveEntrance={height=h,warp=warp}
     -- The entrance supports only its own cliff mass. Verify its continuous
     -- shared boundary before claiming art; refuse unusual slopes/terraces.
     local Terrain=V.require('Gen3Terrain');local base=c.base or 0
     local available=Terrain.height(cells,x*16+8,y*16+8,h)-base
     local valid=available>=10;local boundary={}
     for _,zz in ipairs{0,4,8,12,16}do boundary[zz]={}
      for _,xx in ipairs{0,3,5,11,13,16}do
       -- Copy the rendered four-pixel terrain edge, including interpolation
       -- between its grid vertices; raw subgrid sampling is not that edge.
       local lo=math.floor(xx/4)*4;local hi=math.min(16,lo+4);local t=(xx-lo)/4
       local a=Terrain.height(cells,x*16+lo,y*16+zz,h)
       local b=Terrain.height(cells,x*16+hi,y*16+zz,h)
       local old=a+(b-a)*t-base
       boundary[zz][xx]=old
       if math.abs(old-available*math.min(1,(16-zz)/4))>1e-7 then valid=false end
      end
     end
     if valid then c.caveEntrance.height=available
     elseif def.id=='FR_NAVEL_ROCK_EXTERIOR'or p.terrainHood then
      -- Its native mixed coastal elevations flatten part of the old mass.
      -- A local one-cell rock hood retains that entire outer perimeter;
      -- neither the outside ground nor surrounding cliffs are raised.
      local ridge=16
      for zz,row in pairs(boundary)do if zz~=0 and zz~=16 then for xx,v in pairs(row)do if xx~=0 and xx~=16 then ridge=math.max(ridge,v)end end end end
      c.caveEntrance.height=ridge;c.caveEntrance.boundary=boundary
     else c.caveEntrance=nil end
     if c.caveEntrance then count=count+1 end
    end
   end
  end
 end
 return count
end
function M.append(c,emit,uvFor)
 local p=assert(c.caveEntrance)
 if p.append then return p.append(c,emit,uvFor)end
 local x,z=c.cx*16,c.cy*16;local h=p.height
 local cap=assert(uvFor(c.ts,c.mid==838 and 849 or 113))
 local side=assert(uvFor(c.ts,c.mid==838 and 857 or 124));local mouth=assert(uvFor(c.ts,c.mid))
 local function crop(uv,a,b)
  local function t(u,v)return{uv[1][1]+(uv[2][1]-uv[1][1])*u,uv[1][2]+(uv[3][2]-uv[1][2])*v}end
  return{t(a[1],a[2]),t(b[1],a[2]),t(b[1],b[2]),t(a[1],b[2])}
 end
 local function swatch(u,v)return crop(mouth,{u,v},{u,v})end
 local function rock(points,alongDepth)
  local out={}
  for i,a in ipairs(points)do
   local u=alongDepth and a[3]/16 or a[1]/16
   out[i]={side[1][1]+(side[2][1]-side[1][1])*u,side[1][2]+(side[3][2]-side[1][2])*(1-a[2]/h)}
  end
  return out
 end
 local function q(points,uv,shade,floor)
  uv=uv or side
  local function point(a)return{x+a[1],a[2],z+a[3]}end
  if floor then local out={};for i,a in ipairs(points)do out[i]=point(a)end;return emit(out,uv,shade or 1)end
  for _,is in ipairs{{1,2,3},{1,3,4}}do
   local a,b,d=points[is[1]],points[is[2]],points[is[3]]
   local ux,uy,uz=b[1]-a[1],b[2]-a[2],b[3]-a[3]
   local vx,vy,vz=d[1]-a[1],d[2]-a[2],d[3]-a[3]
   local area=(uy*vz-uz*vy)^2+(uz*vx-ux*vz)^2+(ux*vy-uy*vx)^2
   -- A native zero-height outside corner belongs to the floor already.
   if area>1e-12 and not(a[2]==0 and b[2]==0 and d[2]==0)then
    emit({point(a),point(b),point(d)},{uv[is[1]],uv[is[2]],uv[is[3]]},shade or 1)
   end
  end
 end
 -- Native bottom-row earth is the sole floor owner. The source dark field
 -- becomes the back of the tunnel instead of lying across the ground.
 q({{0,0,0},{16,0,0},{16,0,16},{0,0,16}},swatch(8.5/16,15.5/16),1,true)
 local xs={0,3,5,11,13,16}
 local function top(xx,zz)
  if not p.boundary then return h*math.min(1,(16-zz)/4)end
  local old=p.boundary[zz][xx]
  if xx==0 or xx==16 or zz==0 then return old end
  return math.max(old,h)
 end
 for i=1,#xs-1 do local a,b=xs[i],xs[i+1]
  for zz=0,8,4 do
   q({{a,top(a,zz),zz},{b,top(b,zz),zz},{b,top(b,zz+4),zz+4},{a,top(a,zz+4),zz+4}},crop(cap,{a/16,zz/16},{b/16,(zz+4)/16}))
  end
 end
 -- Match the existing four-pixel cliff bevel exactly at both outside seams.
 for _,ab in ipairs{{0,3},{13,16}}do local a,b=ab[1],ab[2]
  local points={{a,top(a,12),12},{b,top(b,12),12},{b,0,16},{a,0,16}}
  q(points,rock(points))
 end
 local apex=math.min(14,h-2);local shoulder=apex-4
 local arch={{3,shoulder},{5,apex},{11,apex},{13,shoulder}}
 -- Ceiling and sloping cap meet on one exposed lip; no extra front card or
 -- duplicate cap covers the recess. The reveal stays in the native16px cell.
 for i=1,#arch-1 do local a,b=arch[i],arch[i+1]
  local za,zb=16-4*a[2]/h,16-4*b[2]/h
  local lip={{a[1],h,12},{b[1],h,12},{b[1],b[2],zb},{a[1],a[2],za}}
  q(lip,rock(lip))
  q({{a[1],a[2],4},{a[1],a[2],za},{b[1],b[2],zb},{b[1],b[2],4}},side,.84)
  q({{a[1],0,4},{b[1],0,4},{b[1],b[2],4},{a[1],a[2],4}},swatch(8.5/16,6.5/16))
 end
 for _,xx in ipairs{3,13}do
  local zz=16-4*shoulder/h
  local wall={{xx,0,4},{xx,shoulder,4},{xx,shoulder,zz},{xx,0,16}}
  q(wall,rock(wall,true),.86)
 end
end
return M
