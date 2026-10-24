-- Native Dotted Hole stone slabs and paired white columns. Exact source art,
-- permissions and native story state; all solid geometry stays in blocked cells.
local V=...
local M={}
local function free(c)return c and not(c.civic or c.prop or c.stairs or c.column or c.caveEntrance or c.boundary)end
function M.prepare(cells,regions)
 local version=V.require('Generation').version();if version~='firered'and version~='leafgreen'then return 0 end
 for _,r in ipairs(regions)do if r.def.id=='FR_SIX_ISLAND_RUIN_VALLEY'then
  local x,y=r.x+24,r.y+24;local c=cells[x..':'..y]
  local warp;for _,w in ipairs(r.def.warps or{})do if w.x==24 and w.y==24 and w.destMap=='FR_SIX_ISLAND_DOTTED_HOLE_1F'then warp=w end end
  local rows={{814,false,871},{822,198,879}};local parts={};local good=warp and free(c)and c.pair=='general__rom_082d507c'and(c.mid==855 and c.collision==7 or c.mid==856 and c.collision==113)
  for yy,row in ipairs(rows)do for xx,mid in ipairs(row)do
   local a=cells[(x+xx-2)..':'..(y+yy-1)];local collision=yy==1 and 7 or 0
   if not free(a)or a.pair~='general__rom_082d507c'or(mid and a.mid~=mid)or(mid and a.collision~=collision)or(a.base or 0)~=(c and c.base or 0)then good=false end
   if mid and not(yy==2 and xx==2)then parts[#parts+1]={cell=a,support=yy==1}end
  end end
  for dx=-1,1 do local n=cells[(x+dx)..':'..(y-1)]
   if not n or n.pair~='general__rom_082d507c'or n.mid~=({123,124,125})[dx+2]or n.collision~=7 or n.shape.kind~='cliff'then good=false end
  end
  if good then
   local group={owner=c,open=c.mid==856,height=16,parts=parts};parts[#parts+1]={cell=c,support=true}
   for _,a in ipairs(parts)do a.cell.caveEntrance={group=group,terrainSupport=a.support,append=M.append}end
   local T=V.require('Gen3Terrain');local base=c.base or 0
   for dx=-1,1 do for _,xx in ipairs{0,4,8,12,16}do for _,zz in ipairs{0,4,8,12,16}do
    local h=T.height(cells,(x+dx)*16+xx,y*16+zz,16)-base
    if math.abs(h-16*math.min(1,(16-zz)/4))>1e-7 then good=false end
   end end end
   if good then return 1 end
   for _,a in ipairs(parts)do a.cell.caveEntrance=nil end
  end
 end end
 return 0
end
function M.append(c,emit,uvFor)
 local g=assert(c.caveEntrance).group;if g.owner~=c then return end
 local x,z=c.cx*16,c.cy*16;local H=16
 local stone=assert(uvFor(c.ts,124));local cap=assert(uvFor(c.ts,113));local door=assert(uvFor(c.ts,c.mid));local court=assert(uvFor(c.ts,198))
 local function at(uv,u,v)return{uv[1][1]+(uv[2][1]-uv[1][1])*u/16,uv[1][2]+(uv[3][2]-uv[1][2])*v/16}end
 local function crop(uv,l,t,r,b)return{at(uv,l,t),at(uv,r,t),at(uv,r,b),at(uv,l,b)}end
 local function sample(mid,u,v)local uv=assert(uvFor(c.ts,mid));local t=at(uv,u,v);return{t,t,t,t}end
 local function stoneUV(points,axis,offset,texture)
  local out={};for i,p in ipairs(points)do
   local u=axis=='depth'and p[3]or p[1]-(offset or 0)
   out[i]=at(texture or stone,u,16-p[2])
  end;return out
 end
 local function q(p,t,shade)
  local out={};for i,a in ipairs(p)do out[i]={x+a[1],a[2],z+a[3]}end;emit(out,t or stone,shade or 1)
 end
 local function rock(points,axis,offset,shade)q(points,stoneUV(points,axis,offset),shade)end
 local function floor(l,n,r,b,uv)q({{l,0,n},{r,0,n},{r,0,b},{l,0,b}},uv)end
 -- Remove only the two complete original projection drawings; their exact
 -- native198 court floor and walkability remain. Every floor has one owner.
 floor(-16,0,0,16,court);floor(16,0,32,16,court)
 floor(-16,16,0,32,court);floor(16,16,32,32,court)
 floor(0,0,16,16,sample(c.mid,8.5,15.5))
 -- Column niches are open toward the path, with a closed native-rock rear
 -- and narrow sides meeting adjacent cliff cap edges. The independent column
 -- never intersects that rock volume, including its flared cap.
 for _,ox in ipairs{-16,16}do
  local a,b=ox+1.5,ox+14.5
  q({{ox,H,0},{ox+16,H,0},{ox+16,H,1.5},{ox,H,1.5}},crop(cap,0,0,16,1.5))
  rock({{a,0,1.5},{b,0,1.5},{b,H,1.5},{a,H,1.5}},'front',ox)
  for _,band in ipairs{{ox,a},{b,ox+16}}do
   local l,r=band[1],band[2]
   q({{l,H,1.5},{r,H,1.5},{r,H,12},{l,H,12}},crop(cap,l-ox,1.5,r-ox,12))
   rock({{l,H,12},{r,H,12},{r,0,16},{l,0,16}},'front',ox)
  end
  for _,sx in ipairs{a,b}do
   rock({{sx,0,1.5},{sx,H,1.5},{sx,H,12},{sx,0,12}},'depth')
   rock({{sx,0,12},{sx,H,12},{sx,0,16}},'depth')
  end
  local center=ox+8;local rings={{-.05,6.5},{3,5.5},{16,5.5},{18,7.5},{20,7.5}}
  local paints={sample(814,8.5,14.5),sample(814,8.5,12.5),sample(814,8.5,7.5),sample(814,8.5,6.5)}
  for ri=1,#rings-1 do local lo,hi=rings[ri],rings[ri+1]
   for i=0,11 do local a,b=2*math.pi*i/12,2*math.pi*(i+1)/12
    q({{center+lo[2]*math.cos(a),lo[1],8+lo[2]*math.sin(a)},
       {center+lo[2]*math.cos(b),lo[1],8+lo[2]*math.sin(b)},
       {center+hi[2]*math.cos(b),hi[1],8+hi[2]*math.sin(b)},
       {center+hi[2]*math.cos(a),hi[1],8+hi[2]*math.sin(a)}},paints[ri])
   end
  end
  for i=0,11 do local a,b=2*math.pi*i/12,2*math.pi*(i+1)/12
   local uv=sample(814,8.5,3.5)
   q({{center,20,8},{center+7.5*math.cos(a),20,8+7.5*math.sin(a)},{center+7.5*math.cos(b),20,8+7.5*math.sin(b)}},{uv[1],uv[2],uv[3]})
   q({{center,-.05,8},{center+6.5*math.cos(b),-.05,8+6.5*math.sin(b)},{center+6.5*math.cos(a),-.05,8+6.5*math.sin(a)}},{uv[1],uv[2],uv[3]})
  end
 end
 -- One stone roof and two outside bevels; the center has real reveal depth.
 q({{0,H,0},{16,H,0},{16,H,12},{0,H,12}},crop(cap,0,0,16,12))
 for _,ab in ipairs{{0,2},{14,16}}do local a,b=ab[1],ab[2]
  rock({{a,H,12},{b,H,12},{b,0,16},{a,0,16}})
 end
 for _,sx in ipairs{2,14}do rock({{sx,0,12},{sx,16,12},{sx,0,16}},'depth')end
 if not g.open then
  -- Original braille remains together on its exact twelve-pixel slab crop.
  q({{2,16,12},{14,16,12},{14,0,12},{2,0,12}},crop(door,2,0,14,16))
 else
  local arch={{2,12},{3,14},{13,14},{14,12}}
  for i=1,#arch-1 do local a,b=arch[i],arch[i+1]
   local front={{a[1],16,12},{b[1],16,12},{b[1],b[2],12},{a[1],a[2],12}}
   q(front,stoneUV(front,'front',0,door))
   local roof={{a[1],a[2],4},{a[1],a[2],12},{b[1],b[2],12},{b[1],b[2],4}};local tex={}
   for j,p in ipairs(roof)do tex[j]=at(stone,p[1],p[3])end
   q(roof,tex,.86)
   q({{a[1],0,4},{b[1],0,4},{b[1],b[2],4},{a[1],a[2],4}},sample(856,8.5,6.5))
  end
  for _,sx in ipairs{2,14}do rock({{sx,0,4},{sx,12,4},{sx,12,12},{sx,0,12}},'depth',0,.86)end
 end
end
return M
