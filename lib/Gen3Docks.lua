-- Reviewed R/S/E pier drawings. Presentation only: never rewrite permissions,
-- native floor fields, source atlas pixels, warps or ocean animation ownership.
local M={}
local recipes={
 {name='route104',map='ROUTE104',pair='general__rustboro',rows={
  {0x33d,0x26e,0x26e,0x32e},{0x345,0x26d,0x26d,0x336},{0x335,0x276,0x276,0x277}},
  permissions={{7,0,0,0},{7,0,0,0},{41,41,41,7}},layers={{0,4,4,4},{0,4,4,4},{1,1,1,0}},deck={2,1},shore={4,3}},
 {name='dewford',map='DEWFORD_TOWN',pair='general__dewford',rows={{0x228,0x229,0x229},{0x230,0x231,0x231}},
  permissions={{0,0,0},{7,7,7}},layers={{3,3,3},{0,0,0}},deck={1,1}},
}
local function key(x,y)return x..':'..y end
local function map(c)
 local id=c.region and c.region.def and c.region.def.id or c.mapId
 if type(id)~='string'then return end
 local edition,name=id:match('^(%u%u)_(.+)$')
 if edition=='RU'or edition=='SA'or edition=='EM'then return name end
end
local function occupied(c)
 return c.boundary or c.bridge or c.dockShore or c.civic or c.prop or c.treeBounds or c.column or c.stairs or c.stageHidden
end
function M.prepare(cells)
 local count=0
 for _,root in pairs(cells)do for _,r in ipairs(recipes)do
  if root.mid==r.rows[1][1]and root.primary=='general'and root.pair==r.pair and map(root)==r.map and not occupied(root)then
   local group={cells={},waterCandidates={},recipe=r};local valid=true
   for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
    local c=cells[key(root.cx+x-1,root.cy+y-1)]
    if not c or c.mid~=mid or c.pair~=r.pair or c.primary~='general' or c.region~=root.region
      or map(c)~=r.map or c.collision~=r.permissions[y][x]or not c.floor or c.floor.layer~=r.layers[y][x]
      or occupied(c)then valid=false end
    group.cells[#group.cells+1]=c
   end end
   local deck=cells[key(root.cx+r.deck[1]-1,root.cy+r.deck[2]-1)]
   if not deck or type(deck.base)~='number'then valid=false end
   if valid then
    group.height=deck.base
    for y,row in ipairs(r.rows)do for x in ipairs(row)do
     local c=cells[key(root.cx+x-1,root.cy+y-1)]
     if r.permissions[y][x]==0 and math.abs((c.base or 0)-deck.base)>.001 then valid=false end
    end end
    local seen={}
    -- Only genuine surrounding water is a donor, never a blue pixel baked
    -- into a plank MID. Retain references so the later water planner supplies
    -- its final connected-ocean height rather than guessing from native layers.
    for y=-1,#r.rows do for x=-1,#r.rows[1]do
     local c=cells[key(root.cx+x,root.cy+y)]
     if c and(x<0 or y<0 or x>=#r.rows[1]or y>=#r.rows)and not c.bridge
      and c.shape and c.shape.kind=='water'and c.ts==root.ts and not seen[c]then
      seen[c]=true;group.waterCandidates[#group.waterCandidates+1]=c
     end
    end end
    if #group.waterCandidates==0 then valid=false end
   end
   if valid then
    for y,row in ipairs(r.rows)do for x in ipairs(row)do
     local c=cells[key(root.cx+x-1,root.cy+y-1)]
     if r.shore and x==r.shore[1]and y==r.shore[2]then
      --277 is the blocked land corner, not painted ocean below the deck.
      -- Retain its real shore volume and the untouched native floor datum.
      c.dockShore=group
      local shape={};for k,v in pairs(c.shape)do shape[k]=v end
      shape.kind='cliff';shape.height=8;shape.ground=0x6c;shape.cap=0x6c;shape.side=0x71;c.shape=shape
     else c.bridge={kind='dock',group=group,x=x,y=y,material=c.mid,depth=2}end
     count=count+1
    end end
   end
  end
 end end
 return count
end
function M.replacesTop(c)return c.bridge and c.bridge.kind=='dock'or false end
function M.water(c,surface)
 local b=c.bridge;if not b or b.kind~='dock'then return end
 for _,n in ipairs(b.group.waterCandidates)do
  local h=surface(n)
  if type(h)=='number'and h==h and h<b.group.height-2 then return n.ts,n.shape.ground or n.mid,h end
 end
end
local function crop(uv,x0,y0,x1,y1)
 local u0,v0=uv[1][1],uv[1][2];local du,dv=uv[2][1]-u0,uv[3][2]-v0
 return{{u0+du*x0/16,v0+dv*y0/16},{u0+du*x1/16,v0+dv*y0/16},
  {u0+du*x1/16,v0+dv*y1/16},{u0+du*x0/16,v0+dv*y1/16}}
end
local function box(c,emit,uv,a,n,b,f,top,depth)
 if b<=a or f<=n then return end
 local x,z=c.cx*16,c.cy*16;local bottom=top-depth
 local tex=crop(uv,a,n,b,f)
 -- Source grain/nails stay on top. Narrow real wood strips continue onto
 -- upright faces; no ocean/soil pixels are stretched down a board's side.
 local edge=crop(uv,a+.5,n+.5,math.min(b-.5,a+1.5),math.max(n+1,f-.5))
 local middle=(n+f)/2
 local finish=crop(uv,a+.5,middle-.5,b-.5,middle+.5)
 local l,r,back,front=x+a,x+b,z+n,z+f
 emit({{l,top,back},{r,top,back},{r,top,front},{l,top,front}},tex,1)
 emit({{l,bottom,front},{r,bottom,front},{r,bottom,back},{l,bottom,back}},tex,.62)
 emit({{l,top,back},{l,top,front},{l,bottom,front},{l,bottom,back}},edge,.75)
 emit({{r,top,front},{r,top,back},{r,bottom,back},{r,bottom,front}},edge,.82)
 emit({{r,top,back},{l,top,back},{l,bottom,back},{r,bottom,back}},finish,.72)
 emit({{l,top,front},{r,top,front},{r,bottom,front},{l,bottom,front}},finish,.85)
end
function M.append(cells,c,emit,uvFor)
 local b=c.bridge;if not b or b.kind~='dock'then return end
 local uv=assert(uvFor(c.ts,c.mid),'native dock atlas unavailable')
 local height=b.group.height;local x,y=b.x,b.y
 if b.group.recipe.name=='route104'then
  -- Bottom row is the original projected underside/water fringe, not a
  -- second deck. Its former painted shadow becomes open water below timber.
  if y<=2 then
   local back,front=y==1 and 1 or 0,y==2 and 15 or 16
   if x>1 then box(c,emit,uv,0,back,6,front,height,2)end
   box(c,emit,uv,8,back,14,front,height,2)
  end
 else
  local back,front=y==1 and 2 or 0,y==2 and 8 or 16
  box(c,emit,uv,0,back,6,front,height,2)
  box(c,emit,uv,8,back,14,front,height,2)
  -- The landward half of 228/230 is native sand, not a third board or sea.
  -- Keep only original sand patches, wholly within their source-owned tile.
  if x==1 then
   local function patch(a,n,r,f)
    emit({{c.cx*16+a,height,c.cy*16+n},{c.cx*16+r,height,c.cy*16+n},
     {c.cx*16+r,height,c.cy*16+f},{c.cx*16+a,height,c.cy*16+f}},crop(uv,a,n,r,f),1)
   end
   if y==1 then patch(0,0,8,2);patch(6,2,8,16)
   else patch(0,8,7,16);patch(6,0,8,8)end
  end
 end
 return true
end
return M
