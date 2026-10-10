-- Complete public-service buildings. Roof, facade and entrance are separate
-- source rectangles: ground below the wall is never folded upright.
local V=...
local Budget=V and V.require('BuildBudget') or {tick=function()end,check=function()end}
local M={}
local Architecture=V and V.require('ArchitecturalDetails') or dofile('lib/ArchitecturalDetails.lua')
local function claim(cells,g,rows)
 local parts={}
 for dy,row in ipairs(rows)do for dx,mid in ipairs(row)do
  local c=cells[(g.cx+dx-1)..':'..(g.cy+dy-1)]
  if not c or c.pair~=g.pair or c.mid~=mid or c.prop or c.civic then return end
  parts[#parts+1]=c
 end end
 g.rows=rows;g.width=#rows[1];g.depth=#rows;g.ts=parts[1].ts
 for _,c in ipairs(parts)do
  local ranges=g.custom and g.custom.claimRanges;local row=ranges and ranges[c.cy-g.cy+1]
  if not ranges or row and c.cx-g.cx>=row[1] and c.cx-g.cx<=row[2] then c.civic=g end
 end
 return g
end
function M.prepare(cells,gyms,families)
 local H=V and V.require('Gen3Hoenn');local hoenn=H and H.active()
 if hoenn then families=H.exteriorRecipes and H.exteriorRecipes() or H.exteriors end
 local out={}
 for _,g in ipairs(gyms)do
  local b={cx=g.cx,cy=g.cy-1,pair=g.pair,kind='gym',variant=g.variant}
  local rows={}
  for y=0,4 do rows[y+1]={};for x=0,g.width-1 do rows[y+1][x+1]=cells[(b.cx+x)..':'..(b.cy+y)].mid end end
  if claim(cells,b,rows)then out[#out+1]=b end
 end
 for _,c in pairs(cells)do Budget.tick();if not hoenn and c.primary=='general' and not c.civic then
  local rows,kind,cy
  if c.mid==760 and c.pair=='general__rom_082d4b9c' then
   kind,cy='mart',c.cy
   rows={{760,761,762,763},{48,49,50,51},{56,57,58,59},{758,65,98,759}}
  elseif c.mid==0x28 then
   kind,cy='mart',c.cy
   rows={{0x28,0x29,0x2A,0x2B},{0x30,0x31,0x32,0x33},{0x38,0x39,0x3A,0x3B},{0x40,0x41,0x62,0x63}}
  elseif c.mid==0x48 then
   kind,cy='center',c.cy-1
   local top={};for x=0,4 do local n=cells[(c.cx+x)..':'..cy];top[x+1]=n and n.mid end
   local back=false
   for _,pattern in ipairs({{0x17B,0x17C,0x17D,0x17E,0x17F},{0x2B0,0x2B1,0x2B2,0x2B3,0x2B4},
    {0x282,0x283,0x284,0x285,0x286},{0x280,0x281,0x282,0x283,0x284},{0x2FC,0x2FD,0x2FE,0x306,0x2FF},
    {768,769,770,771,772},{669,670,671,680,383},{862,380,381,382,383},{771,772,773,774,775}})do
    local match=true;for i=1,5 do if top[i]~=pattern[i]then match=false end end
    back=back or match
   end
   if c.cy==0 then
    cy=0;rows={{0x48,0x49,0x4A,0x4B,0x187},{0x50,0x51,0x52,0x53,0x18F},{0x58,0x59,0x5A,0x5B,0x197},{0x60,0x61,0x62,0x186,0x19F}}
   elseif back then
    local saffron=top[1]==0x2FC
    rows={top,{0x48,0x49,0x4A,0x4B,0x187},{0x50,0x51,0x52,0x53,0x18F},
     {0x58,0x59,0x5A,0x5B,0x197},{saffron and 0x2DF or 0x60,0x61,0x62,0x186,saffron and 0x307 or 0x19F}}
   end
  end
  if rows then
   local b=claim(cells,{cx=c.cx,cy=cy,pair=c.pair,kind=kind},rows)
   if b then out[#out+1]=b end
  end
 end end
 -- Complete roof headers plus both wall boundaries support door/window
 -- variants without classifying unrelated secondary metatile IDs globally.
 for _,r in ipairs(families or {})do
  local h,w=#r.rows,#r.rows[1]
  for _,c in pairs(cells)do Budget.tick();if not c.civic and c.pair==r.pair and c.mid==r.rows[1][1] then
   local rows,match={},true
   for dy=1,h do rows[dy]={};for dx=1,w do
    local n=cells[(c.cx+dx-1)..':'..(c.cy+dy-1)]
    if not n or n.pair~=c.pair or n.civic or n.prop then match=false
    else
     rows[dy][dx]=n.mid
     if (dy<=r.header or dx==1 or dx==w) and n.mid~=r.rows[dy][dx] then match=false end
    end
   end end
   if match then
    local cy=c.cy
    -- Lavender's dome belongs to the connected Route 10 map. Match and
    -- consume that native continuation as part of the same exterior.
    local north=0
    if r.northRows then
     local complete=true
     for iy,row in ipairs(r.northRows)do for ix,mid in ipairs(row)do
      local n=cells[(c.cx+ix-1)..':'..(c.cy-#r.northRows+iy-1)]
      if not n or n.pair~=c.pair or n.civic or n.mid~=mid then complete=false end
     end end
     if complete then
      north=#r.northRows;cy=cy-north
      local joined={};for _,row in ipairs(r.northRows)do joined[#joined+1]=row end
      for _,row in ipairs(rows)do joined[#joined+1]=row end;rows=joined
     end
    end
    local g=claim(cells,{cx=c.cx,cy=cy,pair=c.pair,kind=r.kind or 'house',family=r.name,custom=r,northRows=north},rows)
    if g then out[#out+1]=g end
   end
  end end
 end
 -- Source roofs often occupy walkable cells behind the wall.
 for _,g in ipairs(out)do
  if g.custom and g.custom.geometry=='space_center' then V.require('Gen3SpaceCenter').prepare(cells,g)end
 end
 -- Keep the roof overhang, but begin its solid shell inside the first row
 -- that actually blocks movement. Unknown collision data never changes a model.
 for _,g in ipairs(out)do
  local clear=0
  for row=0,g.depth-1 do
   local walkable,known,blocked=false,true,false
   for col=0,g.width-1 do
    local c=cells[(g.cx+col)..':'..(g.cy+row)]
    if not c or c.collision==nil then known=false;break end
    if c.collision==0 then walkable=true else blocked=true end
   end
   if not known or not walkable or (row>0 and blocked)then break end
   clear=clear+1
  end
  if clear>0 and clear<g.depth then g.bodyBack=clear*16+2 end
 end
 -- Continue actual neighboring ground under complete building assemblies.
 -- This also supplies raised foundations: original facade/roof pixels must
 -- never be stretched down the retaining face below a building.
 for _,g in ipairs(out)do
  local candidates={}
  local service=g.custom and (g.custom.centerRoof or g.custom.martRoof)
  for yy=g.cy-2,g.cy+g.depth+1 do for xx=g.cx-2,g.cx+g.width+1 do
   local c=cells[xx..':'..yy]
   if c and c.pair==g.pair and not c.civic and c.collision==0 and c.shape and c.shape.kind=='flat'
    and (service or c.shape.reviewedSurface or c.mid==1) then
    -- Unclassified flat tiles can contain decorative artwork. Only the
    -- previously reviewed service assemblies accept their local floor set.
    candidates[#candidates+1]=c
   end
  end end
  g.grounds={}
  for yy=g.cy,g.cy+g.depth-1 do for xx=g.cx,g.cx+g.width-1 do
   local best,distance
   for _,c in ipairs(candidates)do
    local d=(xx-c.cx)^2+(yy-c.cy)^2
    if not distance or d<distance then best,distance=c,d end
   end
   if best then g.grounds[xx..':'..yy]=best.mid end
  end end
 end
 return out
end
function M.ground(c)
 for _,q in ipairs(c.civic.custom and c.civic.custom.groundPreserve or {})do
  if c.cx==c.civic.cx+q[1] and c.cy==c.civic.cy+q[2] then return c.mid end
 end
 if c.civic.custom and c.civic.custom.ground then return c.civic.custom.ground end
 if c.civic.custom and c.civic.custom.preserveWalkableFloor and c.collision==0 then return c.mid end
 return c.civic.grounds and c.civic.grounds[c.cx..':'..c.cy]
  or (c.civic.variant=='saffron' and 0x2E5 or 1)
end
function M.profile(g)
 local w=g.width*16
 if g.custom then
  local r=g.custom
  if r.geometry=='pewter_museum' then return {w=w,h=112,back=8,front=111,wall=56,roofEnd=64,wallTop=64,wallBottom=112,bevel=0,doorLeft=80,doorRight=96,doorTop=96,doorBottom=112,doorHeight=24,projection=0}end
  if r.geometry=='cinnabar_mansion' then
   return {w=w,h=64,back=0,front=52,wall=72,roofEnd=32,wallTop=32,wallBottom=64,bevel=0,doorLeft=48,doorRight=64,doorTop=54,doorBottom=64,doorHeight=22.5,projection=0}
  end
  if r.geometry=='contest_hall' then
   return {w=w,h=112,back=8,front=111,wall=32,roofEnd=88,wallTop=88,wallBottom=112,bevel=0,doorLeft=48,doorRight=64,doorTop=88,doorBottom=112,doorHeight=32,projection=0}
  end
  if r.geometry=='urban' then
   local h=g.depth*16
   return {w=w,h=h,back=0,front=h-1,wall=h-48,roofEnd=48,wallTop=48,wallBottom=h,bevel=0,doorLeft=0,doorRight=w,doorTop=48,doorBottom=h,doorHeight=h-48,projection=0}
  end
  if r.geometry=='devon' then
   return {w=w,h=144,back=0,front=143,wall=112,roofEnd=32,wallTop=32,wallBottom=144,bevel=0,doorLeft=64,doorRight=96,doorTop=48,doorBottom=144,doorHeight=112,projection=0}
  end
  if r.geometry=='space_center' then
   return {w=w,h=128,back=0,front=127,wall=80,roofEnd=48,wallTop=48,wallBottom=128,bevel=0,doorLeft=64,doorRight=80,doorTop=112,doorBottom=128,doorHeight=24,projection=0}
  end
  if r.centerRoof or r.martRoof then
   return {w=64,h=64,back=14,front=60,wall=23,roofEnd=40,wallTop=40,wallBottom=63,bevel=0,doorLeft=0,doorRight=64,doorTop=40,doorBottom=63,doorHeight=23,projection=0}
  end
  if r.profile=='hoenn_gym' then
   return {w=w,h=80,back=2,front=64,wall=26,roofEnd=42,wallTop=45,wallBottom=71,bevel=2,doorLeft=40,doorRight=72,doorTop=50,doorBottom=79,doorHeight=26,projection=15}
  end
  if r.profile=='one_island_center' then
   return {w=w,h=96,back=8,front=95,wall=31,roofEnd=64,wallTop=64,wallBottom=95,bevel=6,doorLeft=40,doorRight=72,doorTop=48,doorBottom=95,doorHeight=38,projection=2}
  end
  if r.geometry=='tower' then
   local offset=(g.northRows or 0)*16
   return {w=w,h=g.depth*16,back=offset,front=offset+111,wall=143,roofEnd=offset-32,wallTop=offset-32,wallBottom=offset+111,bevel=0}
  end
  return {w=w,h=g.depth*16,back=r.back,front=r.wallBottom,wall=r.wallHeight or r.wallBottom-r.roofEnd,roofEnd=r.roofEnd,wallTop=r.roofEnd,wallBottom=r.wallBottom,bevel=r.bevel,doorLeft=0,doorRight=w,doorTop=r.roofEnd,doorBottom=r.wallBottom,doorHeight=r.wallHeight or r.wallBottom-r.roofEnd,projection=0}
 end
 if g.kind=='gym' then
  return {w=w,h=80,back=12,front=72,wall=28,roofEnd=48,wallTop=48,wallBottom=72,
   doorLeft=40,doorRight=72,doorTop=48,doorBottom=80,doorHeight=28,projection=8,bevel=3}
 elseif g.kind=='center' and g.depth==4 then
  return {w=w,h=64,back=0,front=62,wall=26,roofEnd=37,wallTop=37,wallBottom=63,doorLeft=24,doorRight=56,doorTop=28,doorBottom=63,doorHeight=32,projection=2,bevel=6}
 elseif g.kind=='center' then
  return {w=w,h=80,back=11,front=78,wall=26,roofEnd=53,wallTop=53,wallBottom=79,
   doorLeft=24,doorRight=56,doorTop=44,doorBottom=79,doorHeight=32,projection=2,bevel=6}
 else
  return {w=w,h=64,back=3,front=62,wall=20,roofEnd=44,wallTop=44,wallBottom=63,
   doorLeft=16,doorRight=48,doorTop=28,doorBottom=63,doorHeight=32,projection=2,bevel=6}
 end
end
-- Match an animated native door to its authored facade aperture. Coordinates
-- returned here are shared with the fixed mesh, so animation never grows into
-- a freestanding 32x48 card or floats in front of the entrance.
function M.doorSurface(g,tx,ty)
 if g.custom and g.custom.geometry=='pewter_museum' then return V.require('Gen3PewterMuseum').doorSurface(g,tx,ty)end
 local p=M.profile(g);local openings=g.custom and g.custom.openings
 if not openings then
  if not g.custom and (g.kind=='center' or g.kind=='mart')then
   local offset=g.kind=='center' and g.depth~=4 and 16 or 0
   openings={{33,(g.kind=='center' and 48 or 47)+offset,47,63+offset,door=true}}
  elseif g.custom and g.custom.family=='rse' and p.w==64 and p.h==64
   and (g.kind=='mart' or g.kind=='center') and g.rows[4]
   and g.rows[4][2]==(g.kind=='mart' and 0x41 or 0x61)
   and g.rows[4][3]==(g.kind=='mart' and 0x42 or 0x62)then
   openings={{17,45,31,61,door=true}}
  end
 end
 for _,o in ipairs(openings or {})do if o.door then
  local sx,sy=(tx-g.cx)*16,(ty-g.cy)*16
  if sx<o[3] and sx+16>o[1] and sy<o[4] and sy+16>o[2]then
   local top=p.doorHeight*(p.doorBottom-o[2])/(p.doorBottom-p.doorTop)
   local bottom=p.doorHeight*(p.doorBottom-o[4])/(p.doorBottom-p.doorTop)
   local x,z=g.cx*16,g.cy*16+p.front+p.projection-.95
   return {w=o[3]-o[1],h=o[4]-o[2],sourceX=x+o[1],sourceY=g.cy*16+o[2],base=g.groundHeight or 0,
    vertices={{x+o[1],top,z},{x+o[3],top,z},{x+o[3],bottom,z},{x+o[1],bottom,z}}}
  end
 end end
end
local function sourcePixel(g,x,y,override)
 local mid=override or g.rows[math.floor(y/16)+1][math.floor(x/16)+1]
 local ts=g.ts;local slot=assert(ts.midToSlot[mid]);local px,py=slot%ts.cols*16+x%16,math.floor(slot/ts.cols)*16+y%16
 local r,b,c,a=ts.imageData:getPixel(px,py)
 if ts.overImageData then
  local rr,bb,cc,aa=ts.overImageData:getPixel(px,py)
  r,b,c,a=rr*aa+r*(1-aa),bb*aa+b*(1-aa),cc*aa+c*(1-aa),aa+a*(1-aa)
 end
 return r,b,c,a
end
function M.material(g)
 local p=M.profile(g);local data=love.image.newImageData(p.w*2+4,p.h)
 for y=0,p.h-1 do Budget.check();for x=0,p.w-1 do
  local r,gr,b,a=sourcePixel(g,x,y)
  -- Ground-colour removal is restricted to the outside of this complete
  -- known drawing. Window glass/roof colours inside it remain intact.
  if not(g.custom and g.custom.geometry=='tower') and (x<4 or x>=p.w-4 or y<p.back or y>=p.wallBottom) and gr>r+.035 and gr>b+.02 then a=0 end
  if g.custom and g.custom.geometry=='contest_hall' and y>=88 and y<96 and
    ((x>=16 and x<40) or (x>=72 and x<96))then r,gr,b,a=sourcePixel(g,22,98)end
  data:setPixel(x,y,r,gr,b,a)
  local rr,gg,bb,aa=r,gr,b,a
  if (g.kind=='mart' or g.kind=='center') and x>=p.doorLeft and x<p.doorRight and y>=p.doorTop and y<p.roofEnd then
   rr,gg,bb,aa=sourcePixel(g,12,y)
  end
  local chimney=g.custom and g.custom.chimney
  if chimney and x>=chimney[1] and x<chimney[3] and y>=chimney[2] and y<chimney[4]then
   rr,gg,bb,aa=sourcePixel(g,g.custom.geometry=='urban' and 16+x%16 or 28,y)
  end
  local vent=g.custom and g.custom.roofVent
  if vent and x>=vent[1]and x<vent[3]and y>=vent[2]and y<vent[4]then rr,gg,bb,aa=sourcePixel(g,g.custom.ventShape=='rectangular' and 64+x%16 or 64,y)end
  data:setPixel(x+p.w,y,rr,gg,bb,aa)
  -- Lavaridge's sign overlaps the right wall in the top-down drawing.
  -- Restore the native unoccluded wall; keep the original sign in the
  -- second material half for its separate freestanding model below.
  if g.custom and g.custom.gymSign and x>=80 and y>=48 then
   local mid=y<64 and 0x1c4 or 0x1cc
   if g.ts.midToSlot[mid] then data:setPixel(x,y,sourcePixel(g,x,y,mid))end
  end
 end end
 -- Exterior masking is for the cutout facade, never holes in a solid roof.
 -- Fill masked pixels from the nearest retained roof pixel on the
 -- same native row, preserving stripe alignment and leaving facade alpha alone.
 for yy=p.back,p.roofEnd-1 do
  local valid={}
  for xx=0,p.w-1 do local _,_,_,a=data:getPixel(p.w+xx,yy)
   if a>.9 then valid[#valid+1]=xx end
  end
  for xx=0,p.w-1 do
   local _,_,_,a=data:getPixel(p.w+xx,yy)
   if a<.9 and #valid>0 then
    local nearest=valid[1]
    for _,v in ipairs(valid)do if math.abs(v-xx)<math.abs(nearest-xx)then nearest=v end end
    data:setPixel(p.w+xx,yy,data:getPixel(p.w+nearest,yy))
   end
  end
 end
 -- Hoenn's rounded roof drawings include scenery in their upper corners.
 -- The solid roof prism must use roof paint there, never grass or paving.
 -- Extend the actual red/blue roof stripe on each row into those corners;
 -- facade pixels in the first half of the material remain untouched.
 if g.kind=='center' or g.kind=='mart' then
  local painted,empty={},{}
  for yy=p.back,p.roofEnd-1 do
   local left,right
   for xx=0,p.w-1 do
    local rr,gg,bb,aa=data:getPixel(p.w+xx,yy)
    local paint=g.kind=='center' and rr>gg+.06 and rr>bb+.04
     or g.kind=='mart' and rr<.55 and bb>rr+.18 and bb>gg+.025
    if aa>.9 and paint then left=left or xx;right=xx end
   end
   if left and right then
    painted[#painted+1]=yy
    for xx=0,left-1 do data:setPixel(p.w+xx,yy,data:getPixel(p.w+left,yy))end
    for xx=right+1,p.w-1 do data:setPixel(p.w+xx,yy,data:getPixel(p.w+right,yy))end
   elseif yy>=p.roofEnd-5 then
    -- Neutral eave-outline rows continue the central trim, not white walls.
    for xx=0,7 do data:setPixel(p.w+xx,yy,sourcePixel(g,12,yy))end
    for xx=p.w-8,p.w-1 do data:setPixel(p.w+xx,yy,sourcePixel(g,p.w-13,yy))end
   else empty[#empty+1]=yy end
  end
  -- Rounded native silhouettes can start below the bounding rectangle.
  -- Empty rear rows must continue roof stripes, never the surrounding grass.
  for _,yy in ipairs(empty)do
   local nearest
   for _,row in ipairs(painted)do if not nearest or math.abs(row-yy)<math.abs(nearest-yy)then nearest=row end end
   if nearest then for xx=0,p.w-1 do data:setPixel(p.w+xx,yy,data:getPixel(p.w+xx,nearest))end end
  end
 end
 -- Isolate the raised emblem from the roof surrounding it. Walk inward
 -- from each edge; stop at its neutral outline, preserving the coloured
 -- Pokeball enclosed by that outline.
 if g.kind=='mart' or g.kind=='center' then
  for y=p.doorTop,(g.kind=='mart' and 35 or p.wallTop-1) do
   for _,side in ipairs({1,-1})do
    local x=side==1 and p.doorLeft or p.doorRight-1
    while x>=p.doorLeft and x<p.doorRight do
     local r,gr,b,a=data:getPixel(x,y)
     local roof=g.kind=='center' and r>gr+.08 or g.kind=='mart' and b>r+.08
     roof=roof and math.max(r,gr,b)>.52
     if not roof and a>.1 then break end
     data:setPixel(x,y,0,0,0,0);x=x+side
    end
   end
  end
 end
 -- Stable swatches belong to this material, not coincident under/over
 -- atlas passes. That also removes the speckled double-drawn side walls.
 local wall={.73,.78,.82,1};local trim={.35,.39,.47,1}
 if g.custom then
  -- Reuse a central lower wall swatch for the unseen elevations.
  local colors={};local chosen,count
  for yy=(g.custom.geometry=='tower' and p.wallBottom-30 or math.max(0,p.wallTop)+2),p.wallBottom-3 do for xx=4,p.w-5 do
   local rr,gg,bb,aa=sourcePixel(g,xx,yy)
   if aa>.9 and math.max(rr,gg,bb)>.45 and math.min(rr,gg,bb)>.22 and bb<=rr+.06 then
    local key=math.floor(rr*31)..':'..math.floor(gg*31)..':'..math.floor(bb*31)
    local c=colors[key]or{rr,gg,bb,0};colors[key]=c;c[4]=c[4]+1
    if not count or c[4]>count then chosen,count=c,c[4]end
   end
  end end
  if chosen then local rr,gg,bb=unpack(chosen);wall={rr,gg,bb,1};trim={rr*.65,gg*.65,bb*.65,1}end
  -- Reviewed facades can identify their actual siding and structural trim.
  -- A dominant-color guess otherwise mistakes yellow window frames for the
  -- blue-white walls of Dewford's houses.
  if g.custom.wallSample then wall={sourcePixel(g,unpack(g.custom.wallSample))}end
  if g.custom.trimSample then trim={sourcePixel(g,unpack(g.custom.trimSample))}end
 end
 for y=0,p.h-1 do for x=p.w*2,p.w*2+3 do
  local c=x<p.w*2+2 and wall or trim;data:setPixel(x,y,unpack(c))
 end end
 if g.custom and (g.custom.centerRoof or g.custom.martRoof) then
  -- Build longitudinal roof panels from the actual stripe colors, rather
  -- than draping the original perspective drawing over another perspective.
  -- That double projection bent the stripes and stretched the logo.
  local roofColors={}
  local function rgbKey(r,g,b)return math.floor(r*255+.5)*65536+math.floor(g*255+.5)*256+math.floor(b*255+.5)end
  -- These shared second-row tiles contain roof only. Upper regional tiles
  -- also contain cliffs/ash/grass, whose colors must not become roof panels.
  for yy=16,22 do for xx=4,59 do
   local rr,gg,bb,aa=sourcePixel(g,xx,yy)
   local paint=g.kind=='center' and rr>gg+.08 and rr>bb+.06 or g.kind=='mart' and bb>rr+.15 and bb>gg+.025
   if aa>.9 and paint then roofColors[rgbKey(rr,gg,bb)]=true end
  end end
  for xx=0,p.w-1 do
   local color
   for yy=2,26 do
    local rr,gg,bb,aa=sourcePixel(g,xx,yy)
    if aa>.9 and roofColors[rgbKey(rr,gg,bb)] then color={rr,gg,bb,1};break end
   end
   color=color or {sourcePixel(g,12,30)}
   for yy=0,30 do data:setPixel(p.w+xx,yy,unpack(color))end
   for yy=31,40 do data:setPixel(p.w+xx,yy,sourcePixel(g,12,yy))end
  end
 end
 if g.custom and g.custom.geometry=='cinnabar_mansion' then
  for xx=40,71 do for yy=36,48 do data:setPixel(xx,yy,sourcePixel(g,5,36))end end
 end
 if g.custom and g.custom.geometry=='cinnabar_lab' then
  -- Keep the original projected sign in the second material half for its
  -- raised panel; repair only its overlap with the laboratory front wall.
  for xx=66,94 do for yy=56,63 do
   local sx,sy=xx,52
   if xx>=70 and xx<88 then sx,sy=30,58 end
   data:setPixel(xx,yy,sourcePixel(g,sx,sy))
  end end
 end
 if g.custom and g.custom.harbor then
  for xx=0,p.w-1 do
   local rr,gg,bb,aa=sourcePixel(g,math.max(2,math.min(p.w-3,xx)),24)
   for yy=0,55 do data:setPixel(p.w+xx,yy,rr,gg,bb,aa)end
  end
 end
 if g.launchDisplay then
  -- Native red launch-gantry swatch, without bundling its art.
  local rr,gg,bb,aa=sourcePixel(g,4,4,0x379)
  data:setPixel(p.w*2,2,rr,gg,bb,aa)
 end
 local image=love.graphics.newImage(data);image:setFilter('nearest','nearest');data:release()
 return image
end
-- Reuse one real facade window for unseen elevations, excluding tall door
-- glass and panes that reach the ground. Native source pixels stay private.
function M.window(g)
 if g.custom and g.custom.roundWindows then return end
 if g.custom and g.custom.profile=='hoenn_gym' then return {9,49,23,54}end
 for _,o in ipairs(g.custom and g.custom.openings or {})do
  if not o.door then return {o[1],o[2],o[3],o[4]}end
 end
 if g.kind=='mart' or not(g.ts and g.ts.imageData)then return end
 local p=M.profile(g);local seen={};local best,score
 local function blue(x,y)
  if x<2 or x>=p.w-2 or y<p.wallTop or y>=p.wallBottom-3 then return false end
  local r,gr,b,a=sourcePixel(g,x,y)
  return a>.9 and b>r+.10 and (b+gr)/2>r+.12 and b>.4 and gr>.35
 end
 for y=p.wallTop,p.wallBottom-4 do for x=2,p.w-3 do
  local k=y*p.w+x
  if not seen[k] and blue(x,y)then
   local todo={{x,y}};seen[k]=true;local n,l,r,t,b=0,x,x,y,y
   while #todo>0 do
    local q=table.remove(todo);n=n+1;l=math.min(l,q[1]);r=math.max(r,q[1]);t=math.min(t,q[2]);b=math.max(b,q[2])
    for _,d in ipairs({{-1,0},{1,0},{0,-1},{0,1}})do
     local xx,yy=q[1]+d[1],q[2]+d[2];local kk=yy*p.w+xx
     if not seen[kk] and blue(xx,yy)then seen[kk]=true;todo[#todo+1]={xx,yy}end
    end
   end
   local w,h=r-l+1,b-t+1
   if (l+r)/2>p.w*.52 and w>=4 and h>=3 and h<=16 and w>=h and b<p.wallBottom-7 and (not score or n>score)then
    best={l-1,t-1,r+2,b+2};score=n
   end
  end
 end end
 return best
end
function M.append(g,emit)
 if g.custom and g.custom.geometry=='pewter_museum' then return V.require('Gen3PewterMuseum').append(g,M.profile(g),emit)end
 if g.custom and g.custom.geometry=='cinnabar_mansion' then return V.require('Gen3CinnabarMansion').append(g,M.profile(g),emit)end
 if g.custom and g.custom.geometry=='cinnabar_lab' then return V.require('Gen3CinnabarLab').append(g,M.profile(g),emit)end
 if g.custom and (g.custom.centerRoof or g.custom.martRoof) then return V.require('HoennCivicBuilding').append(g,M.profile(g),emit)end
 if g.custom and g.custom.geometry=='contest_hall' then return V.require('Gen3ContestHall').append(g,M.profile(g),emit)end
 if g.custom and g.custom.geometry=='urban' then return V.require('Gen3UrbanBuilding').append(g,M.profile(g),emit)end
 if g.custom and g.custom.geometry=='devon' then return V.require('Gen3DevonBuilding').append(g,M.profile(g),emit)end
 if g.custom and g.custom.geometry=='space_center' then return V.require('Gen3SpaceCenter').append(g,M.profile(g),emit)end
 if g.custom and g.custom.geometry=='tower' then return V.require('Gen3TowerExterior').append(g,M.profile(g),emit)end
 local p=M.profile(g);local x,z=g.cx*16,g.cy*16
 local function uv(l,t,r,b)return {{l/(p.w*2+4),t/p.h},{r/(p.w*2+4),t/p.h},{r/(p.w*2+4),b/p.h},{l/(p.w*2+4),b/p.h}}end
 local wall,trim=uv(p.w*2+.5,.5,p.w*2+.5,.5),uv(p.w*2+2.5,.5,p.w*2+2.5,.5)
 local function face(v,tex,shade)emit(v,tex,shade or 1)end
 local gymPorch=g.custom and g.custom.profile=='hoenn_gym'
 local kantoGym=g.kind=='gym' and not g.custom
 local civicCorners=(g.kind=='center' or g.kind=='mart') and p.w>=64
 local bodyBack=math.max(g.bodyBack or p.back,g.custom and g.custom.bodyBack or p.back)
 if gymPorch and bodyBack>p.back then bodyBack=bodyBack+2 end -- keep rear trim inside blocked cells
 -- Source roof rows describe projection, not the roof's world footprint.
 -- The rear wall may have moved forward to preserve a native walking row.
 local roofBack=math.max(p.back,bodyBack-2)
 p.roofBack=roofBack
 local wingFront=kantoGym and 64 or p.front
 local sideFront=wingFront-(civicCorners and 6 or 0)
 local function facadeFace(v,tex,shade)
  if gymPorch then
   for _,q in ipairs(v)do local xx=q[1]-x
    if q[3]>z+p.front and xx>=40 and xx<=72 then q[3]=q[3]-math.max(0,48-xx,xx-64)*p.projection/8 end
   end
  end
  if civicCorners then
   for _,q in ipairs(v)do
    local xx=q[1]-x
    q[3]=q[3]-math.max(0,8-xx,xx-(p.w-8))
   end
  end
  face(v,tex,shade)
 end
 local function front(l,r,sy,ey,height,depth)
  local openings=g.custom and g.custom.openings
  -- Hoenn service buildings reuse this exact two-cell sliding-door drawing.
  -- Match its native cells, not a generic opening on every custom facade.
  if not openings and g.custom and g.custom.family=='rse' and p.w==64 and p.h==64
   and g.rows[4] and g.rows[4][2]==(g.kind=='mart' and 0x41 or 0x61)
   and g.rows[4][3]==(g.kind=='mart' and 0x42 or 0x62)
   and (g.kind=='mart' or g.kind=='center')then
   openings={{17,45,31,61,door=true}}
  end
  if not g.custom and (g.kind=='center' or g.kind=='mart')then
   local offset=g.kind=='center' and g.depth~=4 and 16 or 0
   local candidates=g.kind=='center' and {
    {10,37+offset,23,43+offset},{56,37+offset,69,43+offset},
    {33,48+offset,47,63+offset,door=true},
   }or{{33,47,47,63,door=true}}
   openings={}
   for _,o in ipairs(candidates)do
    if o[1]>=l and o[3]<=r and o[2]>=sy and o[4]<=ey then openings[#openings+1]=o end
   end
   if #openings==0 then openings=nil end
  end
  if openings then
   local retained={}
   for _,o in ipairs(openings)do if o[1]>=l and o[3]<=r and o[2]>=sy and o[4]<=ey then retained[#retained+1]=o end end
   openings=#retained>0 and retained or nil
  end
  local xs,ys={l,r},{sy,ey}
  if gymPorch then for _,cut in ipairs({48,64})do if cut>l and cut<r then xs[#xs+1]=cut end end end
  if civicCorners then
   for _,cut in ipairs({8,p.w-8})do if cut>l and cut<r then xs[#xs+1]=cut end end
  end
  for _,o in ipairs(openings or {})do xs[#xs+1]=o[1];xs[#xs+1]=o[3];ys[#ys+1]=o[2];ys[#ys+1]=o[4]end
  table.sort(xs);table.sort(ys)
  local function y(v)
   local value=height*(ey-v)/(ey-sy)
   -- The entrance header meets the canopy soffit, not its roof surface.
   if gymPorch and depth>p.front then value=math.min(value,p.wall-2)end
   return value
  end
  for iy=1,#ys-1 do for ix=1,#xs-1 do
   local a,b,c,d=xs[ix],xs[ix+1],ys[iy],ys[iy+1];local hole=false
   for _,o in ipairs(openings or {})do if a>=o[1] and b<=o[3] and c>=o[2] and d<=o[4]then hole=true end end
   if b>a and d>c and not hole then facadeFace({{x+a,y(c),z+depth},{x+b,y(c),z+depth},{x+b,y(d),z+depth},{x+a,y(d),z+depth}},uv(a+.03,c+.03,b-.03,d-.03))end
  end end
  if not openings then return end
  local function localFace(v,tex,shade)
   local out={};for i,q in ipairs(v)do out[i]={q[1]+x,q[2],q[3]+z+depth}end;face(out,tex,shade)
  end
  for _,o in ipairs(openings)do
   do
    -- The native drawing already contains the door/window surround. Recess
    -- the pane into it; no second grey frame or projecting concrete sill.
    local a,b,top,bottom=o[1],o[3],y(o[2]),y(o[4])
    localFace({{a,top,-1},{b,top,-1},{b,bottom,-1},{a,bottom,-1}},uv(a+.05,o[2]+.05,b-.05,o[4]-.05))
    localFace({{a,top,0},{a,top,-1},{a,bottom,-1},{a,bottom,0}},uv(a-.45,o[2]+.05,a-.05,o[4]-.05),.8)
    localFace({{b,top,-1},{b,top,0},{b,bottom,0},{b,bottom,-1}},uv(b+.05,o[2]+.05,b+.45,o[4]-.05),.8)
    localFace({{a,top,0},{b,top,0},{b,top,-1},{a,top,-1}},uv(a+.05,o[2]-.45,b-.05,o[2]-.05),.85)
    localFace({{a,bottom,-1},{b,bottom,-1},{b,bottom,0},{a,bottom,0}},uv(a+.05,o[4]-.45,b-.05,o[4]-.05))

   end
  end
 end
 if p.doorLeft>0 then front(0,p.doorLeft,p.wallTop,p.wallBottom,p.wall,wingFront)end
 if p.doorRight<p.w then front(p.doorRight,p.w,p.wallTop,p.wallBottom,p.wall,wingFront)end
 if gymPorch then
  -- The diagonal white strips in the top-down drawing depict the SIDE of
  -- the vestibule. Rebuild those surfaces rather than stretching the drawn
  -- perspective (and its stair-stepped outlines) down an upright wall.
  front(48,64,p.doorTop,p.doorBottom,p.doorHeight,p.front+p.projection)
  local porcelain=uv(44.1,68.1,44.2,68.2)
  local joint=uv(46.1,76.1,46.2,76.2)
  local function cheek(a,b,shade)
   for _,band in ipairs({{0,2,joint},{2,22,porcelain},{22,24,trim}})do
    face({{x+a,band[2],z+p.front},{x+b,band[2],z+p.front+p.projection},
      {x+b,band[1],z+p.front+p.projection},{x+a,band[1],z+p.front}},band[3],shade)
   end
  end
  cheek(40,48,.92);cheek(72,64,.80)
 else
  front(p.doorLeft,p.doorRight,p.doorTop,p.doorBottom,p.doorHeight,p.front+p.projection)
 end
 -- Native timber stiles have their own shallow, closed relief. Keep the
 -- original face drawing and stop inside the last blocked tile, rather than
 -- growing generic columns into the path or covering the doorway.
 for _,post in ipairs(g.custom and g.custom.facadePosts or {})do
  local a,t,b,d=unpack(post)
  local top,bottom=p.wallBottom-t,p.wallBottom-d
  local back,front=z+p.front,z+math.min(p.front+.6,g.depth*16-.1)
  face({{x+a,top,front},{x+b,top,front},{x+b,bottom,front},{x+a,bottom,front}},uv(a,t,b,d))
  face({{x+a,top,back},{x+a,top,front},{x+a,bottom,front},{x+a,bottom,back}},uv(a,t,a+.2,d),.8)
  face({{x+b,top,front},{x+b,top,back},{x+b,bottom,back},{x+b,bottom,front}},uv(b-.2,t,b,d),.8)
  face({{x+a,top,back},{x+b,top,back},{x+b,top,front},{x+a,top,front}},uv(a,t,b,t+.2))
  face({{x+a,bottom,front},{x+b,bottom,front},{x+b,bottom,back},{x+a,bottom,back}},uv(a,d-.2,b,d),.7)
 end
 -- Closed recessed body and entrance cheeks, with no upright floor pixels.
 for _,sx in ipairs({2,p.w-2})do
  face({{x+sx,p.wall,z+bodyBack},{x+sx,p.wall,z+sideFront},{x+sx,0,z+sideFront},{x+sx,0,z+bodyBack}},wall,.84)
 end
 face({{x+p.w-2,p.wall,z+bodyBack},{x+2,p.wall,z+bodyBack},{x+2,0,z+bodyBack},{x+p.w-2,0,z+bodyBack}},wall,.8)

 if gymPorch then
  -- Closed shallow canopy: sample an unprojected patch of the native gold
  -- roof, not the diagonal borders already drawn into its top-down facade.
  local gold=uv(p.w+48.05,24.05,p.w+63.95,39.95)
  -- The angled source outline is top-down perspective, not a tapered
  -- footprint. Keep parallel sides and square corners in world space.
  local ring={{40,p.front},{72,p.front},{72,p.front+p.projection},{40,p.front+p.projection}}
  local inner={{41,p.front},{71,p.front},{71,p.front+p.projection-1},{41,p.front+p.projection-1}}
  local top={};for i,q in ipairs(inner)do top[i]={x+q[1],p.wall,z+q[2]}end
  face(top,gold)
  -- Close the overhang beneath its square corners, outside the narrower
  -- entrance cheeks, so eye-level views cannot see through the canopy.
  local soffit={};for i=4,1,-1 do local q=ring[i];soffit[#soffit+1]={x+q[1],p.wall-2,z+q[2]}end
  face(soffit,trim,.7)
  for i,a in ipairs(ring)do
   local j=i%4+1;local b,c,d=ring[j],inner[j],inner[i]
   face({{x+a[1],p.wall-.8,z+a[2]},{x+b[1],p.wall-.8,z+b[2]},
    {x+c[1],p.wall,z+c[2]},{x+d[1],p.wall,z+d[2]}},trim,.95)
   face({{x+a[1],p.wall-.8,z+a[2]},{x+b[1],p.wall-.8,z+b[2]},
    {x+b[1],p.wall-2,z+b[2]},{x+a[1],p.wall-2,z+a[2]}},trim,.8)
  end
 else
 for _,sx in ipairs({p.doorLeft,p.doorRight})do
  face({{x+sx,p.wall,z+wingFront},{x+sx,p.wall,z+p.front+p.projection},{x+sx,0,z+p.front+p.projection},{x+sx,0,z+wingFront}},trim,.9)
 end
 face({{x+p.doorLeft,p.wall,z+p.front},{x+p.doorRight,p.wall,z+p.front},{x+p.doorRight,p.wall,z+p.front+p.projection},{x+p.doorLeft,p.wall,z+p.front+p.projection}},trim)
 end
 -- Flat plateau with a narrow, chamfered perimeter, not a central ridge.
 local function height(xx,zz)
  return p.wall+p.bevel*math.min(1,xx/5,(p.w-xx)/5,(zz-roofBack)/5,(p.front-zz)/7)
 end
 if g.custom and g.custom.roofShape=='littleroot_tiered' then
  V.require('Gen3LittlerootRoof').append(g,p,emit)
 elseif g.custom and g.custom.roofShape=='tiered' then
  V.require('Gen3TieredRoof').append(g,p,emit)
 elseif g.custom and g.custom.roofShape then
  local style=g.kind=='center' and g.custom.family=='rse' and g.custom.roofShape=='barrel' and 'hipped_barrel' or g.custom.roofShape
  Architecture.roof(p,style,g.custom.roofRise,uv,function(v,t,shade)
   local out={};for i,q in ipairs(v)do out[i]={x+q[1],q[2],z+q[3]}end;face(out,t,shade)
  end,trim)
 else
 -- Seal the soffit of the chamfered roof above the recessed wall shell.
 -- Without this face, low side views see sky through the overhang cavity.
 face({{x,p.wall,z+p.front},{x+p.w,p.wall,z+p.front},{x+p.w,p.wall,z+roofBack},{x,p.wall,z+roofBack}},trim,.68)
 local xs={0,5,p.w-5,p.w};local zs={roofBack,roofBack+5,p.front-7,p.front}
 for iz=1,3 do for ix=1,3 do
  local l,r,t,b=xs[ix],xs[ix+1],zs[iz],zs[iz+1]
  local sy=p.back+(t-roofBack)/(p.front-roofBack)*(p.roofEnd-p.back)
  local ey=p.back+(b-roofBack)/(p.front-roofBack)*(p.roofEnd-p.back)
  face({{x+l,height(l,t),z+t},{x+r,height(r,t),z+t},{x+r,height(r,b),z+b},{x+l,height(l,b),z+b}},uv(p.w+l+.05,sy+.05,p.w+r-.05,ey-.05),iz==3 and .92 or 1)
 end end
 end
 -- The native perimeter projects beyond the recessed masonry. Close its
 -- underside and front/back lips as well as both side edges.
 if not (g.custom and (g.custom.geometry=='tower' or g.custom.roofShape)) then
  local Eaves=V and V.require('RoofEaves') or assert(loadfile('lib/RoofEaves.lua'))()
  local eave=g.kind=='center' and uv(p.w+12.1,p.roofEnd-8.1,p.w+12.2,p.roofEnd-8.2) or trim
  local function edge(a,b,dx,dz) Eaves.edge(a,b,dx,dz,eave,face)end
  edge({x,height(0,roofBack),z+roofBack},{x+p.w,height(p.w,roofBack),z+roofBack},0,-1.5)
  edge({x+p.w,height(p.w,p.front),z+p.front},{x,height(0,p.front),z+p.front},0,1.5)
  edge({x,height(0,p.front),z+p.front},{x,height(0,roofBack),z+roofBack},-1,0)
  edge({x+p.w,height(p.w,roofBack),z+roofBack},{x+p.w,height(p.w,p.front),z+p.front},1,0)
  for _,s in ipairs({{0,roofBack,-1,-1.5},{p.w,roofBack,1,-1.5},
    {0,p.front,-1,1.5},{p.w,p.front,1,1.5}})do
   Eaves.corner({x+s[1],height(s[1],s[2]),z+s[2]},s[3],s[4],eave,face)
  end
 end
 local chimney=g.custom and g.custom.chimney
 local vent=g.custom and g.custom.roofVent
 if vent and g.custom.ventShape=='rectangular' then
  V.require('Gen3RectangularVent').append(g,p,face,uv)
 elseif vent then
  -- Birch's circular extractor is a raised drum, not a flat roof decal.
  local cx,cz=x+(vent[1]+vent[3])/2,z+roofBack+18
  local bottom=p.wall+p.bevel;local top=bottom+13
  local metal=uv(vent[1]+5.1,vent[2]+15.1,vent[1]+5.2,vent[2]+15.2)
  local dark=uv(vent[1]+16.1,vent[2]+9.1,vent[1]+16.2,vent[2]+9.2)
  for i=0,15 do
   local a,b=i*math.pi/8,(i+1)*math.pi/8
   local function point(r,y,t)return {cx+r*math.cos(t),y,cz+r*math.sin(t)}end
   face({point(13,top,a),point(13,top,b),point(13,bottom,b),point(13,bottom,a)},metal,.8+.15*math.sin(a))
   face({point(9,top,a),point(9,top,b),point(13,top,b),point(13,top,a)},metal,1)
   face({point(9,top,a),point(9,top,b),point(9,top-3,b),point(9,top-3,a)},dark,.7)
   face({{cx,top-3,cz},point(9,top-3,a),point(9,top-3,b),{cx,top-3,cz}},dark,.8)
  end
  for offset=-6,6,3 do Architecture.box(face,cx-7,top-1,cz+offset,cx+7,top-.3,cz+offset+.7,metal)end
 end
 if chimney then
  local l,r=chimney[1]+2,chimney[3]-2;local back=roofBack+8;local front=back+12
  local bottom=p.wall+p.bevel;local top=bottom+20
  local brick=uv(chimney[1]+2.05,chimney[2]+26.05,chimney[3]-2.05,chimney[4]-2.05)
  face({{x+l,top,z+front},{x+r,top,z+front},{x+r,bottom,z+front},{x+l,bottom,z+front}},brick)
  face({{x+r,top,z+back},{x+l,top,z+back},{x+l,bottom,z+back},{x+r,bottom,z+back}},brick,.8)
  for _,sx in ipairs({l,r})do face({{x+sx,top,z+back},{x+sx,top,z+front},{x+sx,bottom,z+front},{x+sx,bottom,z+back}},brick,.9)end
  face({{x+l,top,z+back},{x+r,top,z+back},{x+r,top,z+front},{x+l,top,z+front}},uv(chimney[1]+2.05,chimney[2]+10.05,chimney[3]-2.05,chimney[2]+24.05),.9)
 end
 if g.custom and g.custom.gymSign then
  local rim=uv(p.w+81.1,59.1,p.w+81.2,59.2)
  local post=uv(p.w+87.1,76.1,p.w+87.2,76.2)
  Architecture.box(face,x+86,0,z+73,x+90,3,z+76,post)
  Architecture.box(face,x+81,2,z+74,x+95,22,z+77,rim)
  face({{x+81,22,z+77.04},{x+95,22,z+77.04},{x+95,2,z+77.04},{x+81,2,z+77.04}},uv(p.w+81.05,57.05,p.w+94.95,76.95))
 end
 -- Continue the facade's horizontal siding and real window art around
 -- the closed shell. The back never repeats the shop sign or doorway.
 local boarded=g.kind=='house' and not(g.custom and g.custom.geometry=='tower')
 if boarded then
  local boards=V and V.require('HouseCladding') or dofile('lib/HouseCladding.lua')
  boards.side(x+2,z+bodyBack,z+p.front,p.wall,p.wall,-1,wall,face)
  boards.side(x+p.w-2,z+bodyBack,z+p.front,p.wall,p.wall,1,wall,face)
  boards.back(x+2,x+p.w-2,z+bodyBack,p.wall,wall,face)
 end
 if g.custom and g.custom.verticalSiding then
  -- Lilycove's blue upright stiles continue around the unseen elevations.
  local blue=uv(9.1,49.1,9.2,49.2)
  for zz=bodyBack+4,sideFront-4,16 do
   Architecture.box(face,x+1.6,0,z+zz,x+2.1,p.wall,z+zz+3,blue)
   Architecture.box(face,x+p.w-2.1,0,z+zz,x+p.w-1.6,p.wall,z+zz+3,blue)
  end
  for xx=6,p.w-8,16 do
   Architecture.box(face,x+xx,0,z+bodyBack-.4,x+xx+3,p.wall,z+bodyBack+.1,blue)
  end
 end
 local window=M.window(g)
 for yy=5,((boarded or g.custom and g.custom.verticalSiding) and 0 or p.wall-3),6 do
  for _,sx in ipairs({1.94,p.w-1.94})do
   face({{x+sx,yy+.22,z+bodyBack},{x+sx,yy+.22,z+sideFront},{x+sx,yy,z+sideFront},{x+sx,yy,z+bodyBack}},wall,.78)
  end
  face({{x+p.w-2,yy+.22,z+bodyBack-.02},{x+2,yy+.22,z+bodyBack-.02},{x+2,yy,z+bodyBack-.02},{x+p.w-2,yy,z+bodyBack-.02}},wall,.74)
 end
 if window then
  local glass=uv(window[1]+.05,window[2]+.05,window[3]-.05,window[4]-.05)
  local wh=math.min(10,p.wall*.4);local ww=math.min(22,(window[3]-window[1])*wh/(window[4]-window[2]))
  local low=math.max(4,(p.wall-wh)*.58)
  if gymPorch then wh,ww,low=5,14,17 end
  local top=low+wh
  local frame=gymPorch and uv(8.1,49.1,8.2,49.2) or trim
  for _,fraction in ipairs({.30,.70})do
   local center=z+bodyBack+(p.front-bodyBack)*fraction
   for _,side in ipairs({-1,1})do
    local sx=x+(side<0 and 2 or p.w-2)
    Architecture.opening(function(v,t,shade)
     local out={};for i,q in ipairs(v)do out[i]={sx+side*q[3],q[2],center+q[1]}end;face(out,t,shade)
    end,-ww/2,low,ww/2,top,boarded and .5 or .05,frame,glass,false,gymPorch and 'native' or nil)
   end
   local centerX=x+p.w*fraction
   Architecture.opening(function(v,t,shade)
    local out={};for i,q in ipairs(v)do out[i]={centerX-q[1],q[2],z+bodyBack-q[3]}end;face(out,t,shade)
   end,-ww/2,low,ww/2,top,boarded and .5 or .05,frame,glass,false,gymPorch and 'native' or nil)
  end
 end
 -- Thin foundation/eave courses and side windows continue the facade.
 for _,sx in ipairs({boarded and 1.72 or 1.95,p.w-(boarded and 1.72 or 1.95)})do
  for _,y in ipairs({1,p.wall-1})do
   face({{x+sx,y+1,z+bodyBack},{x+sx,y+1,z+sideFront},{x+sx,y,z+sideFront},{x+sx,y,z+bodyBack}},trim,.88)
  end
 end
 if g.custom and g.custom.roundWindows then V.require('Gen3HarborDetails').append(g,p,emit)end
end
return M
