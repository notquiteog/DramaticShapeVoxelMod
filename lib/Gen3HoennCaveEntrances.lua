-- Reviewed two-row Hoenn outdoor mouths. Local native-art rock reveal only;
-- native collision, warp, elevations and the compact distant cliffs stay intact.
local V=...
local M={}
local common={EVER_GRANDE_CITY={{18,41},{18,27}},ROUTE105={{9,20}},ROUTE106={{48,16}},
 ROUTE110={{35,24}},ROUTE111={{29,87}},ROUTE116={{47,8},{65,10}},
 ROUTE120={{7,55}},ROUTE125={{22,19}},SKY_PILLAR_OUTSIDE={{17,13}},VERDANTURF_TOWN={{8,1}}}
local emerald={BATTLE_FRONTIER_OUTSIDE_EAST={{28,7}},BATTLE_FRONTIER_OUTSIDE_WEST={{39,55}}}
local pairs={EVER_GRANDE_CITY='ever_grande',ROUTE105='dewford',ROUTE106='dewford',ROUTE110='mauville',ROUTE111='mauville',ROUTE116='rustboro',ROUTE120='fortree',ROUTE125='mossdeep',SKY_PILLAR_OUTSIDE='pacifidlog',VERDANTURF_TOWN='mauville',BATTLE_FRONTIER_OUTSIDE_EAST='battle_frontier_outside_east',BATTLE_FRONTIER_OUTSIDE_WEST='battle_frontier_outside_west'}
local destinations={EVER_GRANDE_CITY='VICTORY_ROAD_1F',ROUTE105='ISLAND_CAVE',ROUTE106='GRANITE_CAVE_1F',ROUTE110='NEW_MAUVILLE_ENTRANCE',ROUTE111='DESERT_RUINS',ROUTE116='RUSTURF_TUNNEL',ROUTE120='ANCIENT_TOMB',ROUTE125='SHOAL_CAVE_LOW_TIDE_ENTRANCE_ROOM',SKY_PILLAR_OUTSIDE='SKY_PILLAR_ENTRANCE',VERDANTURF_TOWN='RUSTURF_TUNNEL',BATTLE_FRONTIER_OUTSIDE_EAST='ARTISAN_CAVE_1F',BATTLE_FRONTIER_OUTSIDE_WEST='ARTISAN_CAVE_B1F'}
M.locations=common;M.emeraldLocations=emerald
local function free(c)return c and not(c.civic or c.prop or c.stairs or c.column or c.caveEntrance or c.boundary)end
function M.prepare(cells,regions)
 local version=V.require('Generation').version()
 local pre=({emerald='EM_',ruby='RU_',sapphire='SA_'})[version];if not pre then return 0 end
 local Terrain=V.require('Gen3Terrain');local count=0
 for _,r in ipairs(regions or{})do local def=r.def;local name=def.id:sub(#pre+1)
  for _,p in ipairs(def.id:sub(1,#pre)==pre and(common[name]or(version=='emerald'and emerald[name]))or{})do
   local x,y=r.x+p[1],r.y+p[2];local c=cells[x..':'..y];local n=cells[x..':'..(y-1)]
   local w,e,s=cells[(x-1)..':'..y],cells[(x+1)..':'..y],cells[x..':'..(y+1)]
   local nw,ne=cells[(x-1)..':'..(y-1)],cells[(x+1)..':'..(y-1)]
   local warp;for _,q in ipairs(def.warps or{})do if q.x==p[1]and q.y==p[2]then warp=q;break end end
   if free(c)and free(n)and c.primary=='general'and c.mid==0xa7 and c.collision==113
    and c.pair=='general__'..pairs[name] and warp and warp.destMap==pre..destinations[name]
    and(n.mid==0x9f or n.mid==0x64)and n.collision==7 and c.pair==n.pair and warp
    and free(w)and free(e)and free(nw)and free(ne)and w.collision==7 and e.collision==7
    and nw.collision==7 and ne.collision==7 and s and s.collision~=7
    and(c.base or 0)==(s.base or 0)and(n.base or 0)==(c.base or 0)then
    local h=w.shape.height or e.shape.height or 8
    local profile={owner=c,header=n,height=h,warp=warp,append=M.append,boundary={}}
    c.caveEntrance=profile;n.caveEntrance=profile
    -- Sample the existing native mass after marking its two support cells.
    -- The perimeter is copied exactly; only the interior rock hood rises.
    for _,z in ipairs{-16,-12,-8,-4,0,4,8,12,16}do
     profile.boundary[z]={}
     for _,xx in ipairs{0,2,4,12,14,16}do
      profile.boundary[z][xx]=Terrain.height(cells,x*16+xx,y*16+z,h)-(c.base or 0)
     end
    end
    count=count+1
   end
  end
 end
 return count
end
function M.append(c,emit,uvFor)
 local p=assert(c.caveEntrance);if p.owner~=c then return end
 local x,z=c.cx*16,c.cy*16;local cap=assert(uvFor(c.ts,0x6c));local side=assert(uvFor(c.ts,0x71));local native=assert(uvFor(c.ts,c.mid))
 local function crop(uv,l,t,r,b)
  local function at(a,b)return{uv[1][1]+(uv[2][1]-uv[1][1])*a/16,uv[1][2]+(uv[3][2]-uv[1][2])*b/16}end
  return{at(l,t),at(r,t),at(r,b),at(l,b)}
 end
 local function q(points,uv,shade)
  local a={};for i,v in ipairs(points)do a[i]={x+v[1],v[2],z+v[3]}end;emit(a,uv or side,shade or 1)
 end
 local function sample(u,v)return crop(native,u,v,u,v)end
 -- The native threshold row owns the passage floor; its dark drawing moves
 -- exclusively to the recessed rear, never across the walkable floor.
 q({{0,0,-16},{16,0,-16},{16,0,16},{0,0,16}},sample(8.5,15.5))
 local xs={0,2,4,12,14,16};local ridge={[0]=0,[2]=20,[4]=25,[12]=25,[14]=20,[16]=0}
 local function top(xx,zz)
  local old=p.boundary[zz][xx]
  if xx==0 or xx==16 or zz==-16 then return old end
  local t=(zz+16)/24
  return old+(math.max(old,ridge[xx])-old)*t
 end
 for zz=-16,4,4 do for i=1,#xs-1 do local a,b=xs[i],xs[i+1]
  q({{a,top(a,zz),zz},{b,top(b,zz),zz},{b,top(b,zz+4),zz+4},{a,top(a,zz+4),zz+4}},crop(cap,a,(zz+16)%16,b,(zz+16)%16+4))
 end end
 -- Outside strips meet the original cliff perimeter, including the four-
 -- pixel front bevel. Only the native opening's own two cells are replaced.
 for _,a in ipairs{0,14}do local b=a+2;local inner=a==0 and b or a
  for zz=8,12,4 do
   local function edge(xx,zz)
    if xx==inner then return zz==8 and ridge[xx]or zz==12 and 16 or 0 end
    return p.boundary[zz][xx]
   end
   q({{a,edge(a,zz),zz},{b,edge(b,zz),zz},{b,edge(b,zz+4),zz+4},{a,edge(a,zz+4),zz+4}},side)
  end
 end
 local arch={{2,16},{4,21},{12,21},{14,16}};local rear=-10;local front=12
 for i=1,#arch-1 do local a,b=arch[i],arch[i+1]
  q({{a[1],ridge[a[1]],8},{b[1],ridge[b[1]],8},{b[1],b[2],front},{a[1],a[2],front}},side)
  q({{a[1],a[2]*.5,rear},{a[1],a[2],front},{b[1],b[2],front},{b[1],b[2]*.5,rear}},side,.84)
  q({{a[1],0,rear},{b[1],0,rear},{b[1],b[2]*.5,rear},{a[1],a[2]*.5,rear}},sample(8.5,6.5))
 end
 for _,xx in ipairs{2,14}do q({{xx,0,rear},{xx,8,rear},{xx,16,front},{xx,0,16}},side,.86)end
end
return M
