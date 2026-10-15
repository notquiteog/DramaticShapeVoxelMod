-- Museum terrace/stair topology shared by floor support and rendered geometry.
-- Exact whole-source matching, not native elevation numbers, proves the flight.
local V=...
local M={}
local apron={{0x7c,0x79,0x79,0x219,0x21a,0x21b,0x21c,0x79,0x79,0x79},
 {0x89,0x23b,0x23b,0x221,0x222,0x223,0x224,0x22b,0x23b,0x23b}}
local permissions={{7,7,7,7,0,0,7,7,7,7},{7,0,0,7,0,0,7,0,0,0}}
local perimeter={{-2,1,0x68},{11,1,0x6a},{-2,7,0x78},{-1,7,0x7c},{10,7,0x79},{11,7,0x7a}}
for y=2,6 do perimeter[#perimeter+1]={-2,y,0x70};perimeter[#perimeter+1]={11,y,0x72}end
local recipe
local function source()
 if not recipe then
  local rows=V.data and V.data('gen3_hoenn_exteriors')or dofile((os.getenv('DS_MOD_PATH')or'.')..'/data/gen3_hoenn_exteriors.lua')
  for _,r in ipairs(rows)do if r.landmark=='museum'then recipe=r;break end end
 end
 return assert(recipe)
end
function M.match(read,x,y)
 local r=source()
 for iy,row in ipairs(r.rows)do for ix,mid in ipairs(row)do
  local c=read(x+ix-1,y+iy-1)
  if not c or c.mid~=mid or c.coll~=r.permissions[iy][ix]then return end
 end end
 for iy,row in ipairs(apron)do for ix,mid in ipairs(row)do
  local c=read(x+ix-1,y+6+iy)
  if not c or c.mid~=mid or c.coll~=permissions[iy][ix]then return end
 end end
 for dx=4,5 do local c=read(x+dx,y+9);if not c or c.coll~=0 then return end end
 for _,p in ipairs(perimeter)do local c=read(x+p[1],y+p[2]);if not c or c.mid~=p[3]or c.coll~=7 then return end end
 return true
end
function M.steps(layout)
 local out,links={},{}
 for y=0,layout.height-10 do for x=2,layout.width-12 do
  local c=layout:cellAt(x,y)
  if c.mid==source().rows[1][1]and M.match(function(a,b)return layout:cellAt(a,b)end,x,y)then
   for yy=y+7,y+8 do for xx=x+4,x+5 do out[xx..':'..yy]=true end end
   -- The rear garden and entrance landing are one source terrace, separated
   -- by the blocked building footprint. Native walking connectivity alone
   -- cannot join them. Tie their proven floor groups before solving stairs.
   local tag=x..':'..y
   for iy,row in ipairs(source().permissions)do for ix,permission in ipairs(row)do
    if permission~=7 then links[(x+ix-1)..':'..(y+iy-1)]=tag end
   end end
  end
 end end
 return out,links
end
function M.prepare(cells,g)
 if not M.match(function(x,y)
  local c=cells[x..':'..y]
  if c and c.pair==g.pair then return{mid=c.mid,coll=c.collision}end
 end,g.cx,g.cy)then return end
 g.foundationCell={4,6};g.foundationFoot={4,9};g.preserveNativeFloor=true
 for y=g.cy+7,g.cy+8 do
  for x=g.cx+4,g.cx+5 do cells[x..':'..y].shape={kind='steps',museumStep=true}end
  for _,x in ipairs{g.cx+3,g.cx+6}do
   local c=cells[x..':'..y];local step=cells[(x==g.cx+3 and x+1 or x-1)..':'..y]
   c.stairs={owner=c,r={design='museum_apron'},step=step,museum=g,left=x==g.cx+3}
  end
 end
 for _,p in ipairs(perimeter)do local c=cells[(g.cx+p[1])..':'..(g.cy+p[2])]
  if c.shape and c.shape.kind=='cliff'then c.museumTerrace=g end
 end
 for ix,mid in ipairs(apron[1])do if mid==0x79 then
  local c=cells[(g.cx+ix-1)..':'..(g.cy+7)]
  if c.shape and c.shape.kind=='cliff'then c.museumTerrace=g end
 end end
end
local function materials(c,uvFor)
 local function sw(mid,x,y)
  local uv=assert(uvFor(c.ts,mid));local p={uv[1][1]+(uv[2][1]-uv[1][1])*(x+.5)/16,uv[1][2]+(uv[3][2]-uv[1][2])*(y+.5)/16}
  return{p,p,p,p}
 end
 return sw(0x21a,8,0),sw(0x21a,8,2),sw(0x71,8,8)
end
-- Closed sloped prism. A buried face remains explicit so side/rear views
-- cannot expose an open underside at a native elevation boundary.
local function wedge(c,emit,l,r,n,f,b,h1,h2,top,side)
 local x,z=c.cx*16,c.cy*16
 local function face(v,t,s)for _,p in ipairs(v)do p[1]=p[1]+x;p[3]=p[3]+z end;emit(v,t,s or 1)end
 face({{l,h1,n},{r,h1,n},{r,h2,f},{l,h2,f}},top)
 face({{l,b,f},{r,b,f},{r,b,n},{l,b,n}},side,.65)
 face({{l,h2,f},{r,h2,f},{r,b,f},{l,b,f}},side,.85)
 face({{r,h1,n},{l,h1,n},{l,b,n},{r,b,n}},side,.8)
 face({{l,h1,n},{l,h2,f},{l,b,f},{l,b,n}},side,.84)
 face({{r,h2,f},{r,h1,n},{r,b,n},{r,b,f}},side,.9)
end
function M.appendStep(c,emit,uvFor)
 local white,gray=materials(c,uvFor);local rise=c.floor and c.floor.high and c.floor.high-c.floor.low or 6
 for n=0,3 do local h=rise*(1-n/4)
  wedge(c,emit,0,16,n*4,n*4+4,0,h,h,gray,white)
 end
end
function M.appendRail(c,emit,uvFor)
 local white,gray,rock=materials(c,uvFor);local g=c.stairs;local step=g.step
 local base=c.base or 0;local high=(step.floorHigh or (step.base or 0)+6)-base;local low=(step.base or 0)-base
 local bottom=(g.museum.groundHeight or 0)-(g.museum.foundationDepth or 0)-base
 -- Stone cheeks stay entirely in the original blocked flank tiles.
 wedge(c,emit,0,16,0,16,bottom,high,low,rock,rock)
 local l,r=g.left and 13 or .2,g.left and 15.8 or 3
 wedge(c,emit,l,r,0,16,bottom,high+3,low+3,white,gray)
end
return M
