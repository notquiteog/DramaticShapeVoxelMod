-- Presentation-only floor topology. Stair runs constrain whole floor regions;
-- collision layers separate regions but are never interpreted as world pixels.
local M={}
local directions={{1,0},{-1,0},{0,1},{0,-1}}
local function key(x,y)return x..':'..y end
M.key=key
function M.build(w,h,read,compatible,rise,tick)
 local f={width=w,height=h,cells={},groups={},flights={},conflicts={}}
 local cells=f.cells
 for y=0,h-1 do for x=0,w-1 do
  local c=read(x,y);c.x,c.y=x,y;cells[key(x,y)]=c
  if tick then tick()end
 end end
 for y=0,h-1 do for x=0,w-1 do local c=cells[key(x,y)]
  if c.floor and not c.group then
   local g={cells={},edges={}};f.groups[#f.groups+1]=g
   local queue={c};c.group=g;local head=1
   while queue[head]do local a=queue[head];head=head+1;g.cells[#g.cells+1]=a
    for d,dir in ipairs(directions)do local b=cells[key(a.x+dir[1],a.y+dir[2])]
     if b and b.floor and not b.group and (not compatible or compatible(a,b,d))then b.group=g;queue[#queue+1]=b end
    end
   end
  end
 end end
 -- One flight per column; adjacent columns independently prove equal heights.
 for y=0,h-1 do for x=0,w-1 do local c=cells[key(x,y)];local north=cells[key(x,y-1)]
  if c.step and not(north and north.step)then
   local bottom=y+1
   while cells[key(x,bottom)]and cells[key(x,bottom)].step do bottom=bottom+1 end
   local south=cells[key(x,bottom)]
   local flight={x=x,top=y,bottom=bottom,high=north and north.group,low=south and south.group,rise=(bottom-y)*(rise or 6)}
   f.flights[#f.flights+1]=flight
   if flight.high and flight.low and flight.high~=flight.low then
    local high,low=flight.high,flight.low
    high.edges[#high.edges+1]={low,-flight.rise};low.edges[#low.edges+1]={high,flight.rise}
   end
  end
 end end
 -- Jump strips can join separate stair networks. They cannot override a
 -- staircase or impose contradictory levels on a loop you can walk around.
 local function network(root)
  local seen={[root]=true};local todo={root};local head=1
  while todo[head]do local g=todo[head];head=head+1
   for _,e in ipairs(g.edges)do if not seen[e[1]]then seen[e[1]]=true;todo[#todo+1]=e[1]end end
  end
  return seen
 end
 for y=0,h-1 do for x=0,w-1 do local c=cells[key(x,y)]
  if c.drop then local dx,dy=c.drop[1],c.drop[2]
   local a,b=cells[key(x-dx,y-dy)],cells[key(x+dx,y+dy)]
   local high,low=a and a.group,b and b.group
   if high and low and high~=low and #high.edges>0 and #low.edges>0 and not network(high)[low]then
    high.edges[#high.edges+1]={low,-(rise or 6)};low.edges[#low.edges+1]={high,rise or 6}
   end
  end
 end end
 for _,root in ipairs(f.groups)do if root.height==nil then
  root.height=0;local queue={root};local head=1;local minimum=0
  while queue[head]do local a=queue[head];head=head+1
   for _,edge in ipairs(a.edges)do local b,delta=edge[1],edge[2];local target=a.height+delta
    if b.height==nil then b.height=target;minimum=math.min(minimum,target);queue[#queue+1]=b
    elseif b.height~=target then f.conflicts[#f.conflicts+1]={a=a,b=b,delta=delta}end
   end
  end
  local offset=0
  for _,g in ipairs(queue)do for _,c in ipairs(g.cells)do offset=math.max(offset,(c.seed or 0)-(g.height-minimum))end end
  for _,g in ipairs(queue)do
   g.height=g.height-minimum+offset
   for _,c in ipairs(g.cells)do c.height=g.height end
  end
 end end
 for _,s in ipairs(f.flights)do
  local low=s.low and s.low.height or 0
  local high=s.high and s.high.height or low+s.rise
  if not s.low then low=math.max(0,high-s.rise)end
  if high<low then high=low end
  for y=s.top,s.bottom-1 do local c=cells[key(s.x,y)]
   local fraction=(y-s.top)/(s.bottom-s.top)
   c.high=high-(high-low)*fraction;c.low=high-(high-low)*(fraction+1/(s.bottom-s.top));c.height=c.low
  end
 end
 -- Stable, full-map nearest support under props. It cannot change when a
 -- render window moves. Equal-distance ties follow source row order.
 local queue={};for y=0,h-1 do for x=0,w-1 do local c=cells[key(x,y)]
  if c.height~=nil then c.distance=0;c.support=c;queue[#queue+1]=c end
 end end
 local head=1
 while queue[head]do local a=queue[head];head=head+1
  for _,dir in ipairs(directions)do local b=cells[key(a.x+dir[1],a.y+dir[2])]
   if b and b.distance==nil then b.height=a.height;b.distance=a.distance+1;b.support=a.support;queue[#queue+1]=b end
  end
 end
 return f
end
-- Match the actual walkable seam of connected maps. Each map keeps its
-- local terrain data; only its placement datum changes with the world origin.
function M.align(regions)
 for _,r in ipairs(regions)do r.floorOffset=nil end
 if regions[1]then regions[1].floorOffset=0 end
 local function difference(a,b)
  local counts={}
  local function sample(ax,ay,bx,by)
   local u=a.floorField and a.floorField.cells[key(ax,ay)]
   local v=b.floorField and b.floorField.cells[key(bx,by)]
   if u and v and u.floor and v.floor and (u.kind=='water')==(v.kind=='water')then
    local d=(u.height or 0)-(v.height or 0);counts[d]=(counts[d]or 0)+1
   end
  end
  if a.x+a.w==b.x or b.x+b.w==a.x then
   for y=math.max(a.y,b.y),math.min(a.y+a.h,b.y+b.h)-1 do
    sample(a.x<b.x and a.w-1 or 0,y-a.y,a.x<b.x and 0 or b.w-1,y-b.y)
   end
  elseif a.y+a.h==b.y or b.y+b.h==a.y then
   for x=math.max(a.x,b.x),math.min(a.x+a.w,b.x+b.w)-1 do
    sample(x-a.x,a.y<b.y and a.h-1 or 0,x-b.x,a.y<b.y and 0 or b.h-1)
   end
  end
  local best,count
  for d,n in pairs(counts)do if not count or n>count or n==count and math.abs(d)<math.abs(best)then best,count=d,n end end
  return best
 end
 for _=1,#regions do
  local changed=false
  for _,a in ipairs(regions)do if a.floorOffset~=nil then for _,b in ipairs(regions)do if b.floorOffset==nil then
   local d=difference(a,b)
   if d then b.floorOffset=a.floorOffset+d;changed=true end
  end end end end
  if not changed then break end
 end
 for _,r in ipairs(regions)do r.floorOffset=r.floorOffset or 0 end
end
function M.at(f,x,z)
 local c=f and f.cells[key(math.floor(x/16),math.floor(z/16))]
 if not c then return 0 end
 if c.high then return c.high-(c.high-c.low)*math.min(3,math.max(0,math.floor(z%16/4)))/4 end
 return c.height or 0
end
return M
