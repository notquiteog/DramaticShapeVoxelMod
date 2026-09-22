-- Complete public-service buildings. Roof, facade and entrance are separate
-- source rectangles: ground below the wall is never folded upright.
local V=...
local M={}
local function claim(cells,g,rows)
 local parts={}
 for dy,row in ipairs(rows)do for dx,mid in ipairs(row)do
  local c=cells[(g.cx+dx-1)..':'..(g.cy+dy-1)]
  if not c or c.pair~=g.pair or c.mid~=mid or c.prop or c.civic then return end
  parts[#parts+1]=c
 end end
 g.rows=rows;g.width=#rows[1];g.depth=#rows;g.ts=parts[1].ts
 for _,c in ipairs(parts)do c.civic=g end
 return g
end
function M.prepare(cells,gyms,families)
 local out={}
 for _,g in ipairs(gyms)do
  local b={cx=g.cx,cy=g.cy-1,pair=g.pair,kind='gym',variant=g.variant}
  local rows={}
  for y=0,4 do rows[y+1]={};for x=0,g.width-1 do rows[y+1][x+1]=cells[(b.cx+x)..':'..(b.cy+y)].mid end end
  if claim(cells,b,rows)then out[#out+1]=b end
 end
 for _,c in pairs(cells)do if c.primary=='general' and not c.civic then
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
  for _,c in pairs(cells)do if not c.civic and c.pair==r.pair and c.mid==r.rows[1][1] then
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
 return out
end
function M.profile(g)
 local w=g.width*16
 if g.custom then
  local r=g.custom
  if r.profile=='one_island_center' then
   return {w=w,h=96,back=8,front=95,wall=31,roofEnd=64,wallTop=64,wallBottom=95,bevel=6,doorLeft=40,doorRight=72,doorTop=48,doorBottom=95,doorHeight=38,projection=2}
  end
  if r.geometry=='tower' then
   local offset=(g.northRows or 0)*16
   return {w=w,h=g.depth*16,back=offset,front=offset+111,wall=143,roofEnd=offset-32,wallTop=offset-32,wallBottom=offset+111,bevel=0}
  end
  return {w=w,h=g.depth*16,back=r.back,front=r.wallBottom,wall=r.wallBottom-r.roofEnd,roofEnd=r.roofEnd,wallTop=r.roofEnd,wallBottom=r.wallBottom,bevel=r.bevel,doorLeft=0,doorRight=w,doorTop=r.roofEnd,doorBottom=r.wallBottom,doorHeight=r.wallBottom-r.roofEnd,projection=0}
 end
 if g.kind=='gym' then
  return {w=w,h=80,back=12,front=72,wall=28,roofEnd=48,wallTop=48,wallBottom=72,
   doorLeft=40,doorRight=72,doorTop=48,doorBottom=80,doorHeight=28,projection=8,bevel=3}
 elseif g.kind=='center' and g.depth==4 then
  return {w=w,h=64,back=0,front=62,wall=24,roofEnd=40,wallTop=40,wallBottom=63,doorLeft=24,doorRight=56,doorTop=28,doorBottom=63,doorHeight=32,projection=2,bevel=6}
 elseif g.kind=='center' then
  return {w=w,h=80,back=11,front=78,wall=24,roofEnd=56,wallTop=56,wallBottom=79,
   doorLeft=24,doorRight=56,doorTop=44,doorBottom=79,doorHeight=32,projection=2,bevel=6}
 else
  return {w=w,h=64,back=3,front=62,wall=20,roofEnd=44,wallTop=44,wallBottom=63,
   doorLeft=16,doorRight=48,doorTop=28,doorBottom=63,doorHeight=32,projection=2,bevel=6}
 end
end
local function sourcePixel(g,x,y)
 local mid=g.rows[math.floor(y/16)+1][math.floor(x/16)+1]
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
 for y=0,p.h-1 do for x=0,p.w-1 do
  local r,gr,b,a=sourcePixel(g,x,y)
  -- Ground-colour removal is restricted to the outside of this complete
  -- known drawing. Window glass/roof colours inside it remain intact.
  if not(g.custom and g.custom.geometry=='tower') and (x<4 or x>=p.w-4 or y<p.back or y>=p.wallBottom) and gr>r+.035 and gr>b+.02 then a=0 end
  data:setPixel(x,y,r,gr,b,a)
  local rr,gg,bb,aa=r,gr,b,a
  if (g.kind=='mart' or g.kind=='center') and x>=p.doorLeft and x<p.doorRight and y>=p.doorTop and y<p.roofEnd then
   rr,gg,bb,aa=sourcePixel(g,12,y)
  end
  local chimney=g.custom and g.custom.chimney
  if chimney and x>=chimney[1] and x<chimney[3] and y>=chimney[2] and y<chimney[4]then
   rr,gg,bb,aa=sourcePixel(g,28,y)
  end
  data:setPixel(x+p.w,y,rr,gg,bb,aa)
 end end
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
 end
 for y=0,p.h-1 do for x=p.w*2,p.w*2+3 do
  local c=x<p.w*2+2 and wall or trim;data:setPixel(x,y,unpack(c))
 end end
 local image=love.graphics.newImage(data);image:setFilter('nearest','nearest');data:release()
 return image
end
-- Reuse one real facade window for unseen elevations, excluding tall door
-- glass and panes that reach the ground. Native source pixels stay private.
function M.window(g)
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
 if g.custom and g.custom.geometry=='tower' then return V.require('Gen3TowerExterior').append(g,M.profile(g),emit)end
 local p=M.profile(g);local x,z=g.cx*16,g.cy*16
 local function uv(l,t,r,b)return {{l/(p.w*2+4),t/p.h},{r/(p.w*2+4),t/p.h},{r/(p.w*2+4),b/p.h},{l/(p.w*2+4),b/p.h}}end
 local wall,trim=uv(p.w*2+.5,.5,p.w*2+.5,.5),uv(p.w*2+2.5,.5,p.w*2+2.5,.5)
 local function face(v,tex,shade)emit(v,tex,shade or 1)end
 local function front(l,r,sy,ey,height,depth)
  face({{x+l,height,z+depth},{x+r,height,z+depth},{x+r,0,z+depth},{x+l,0,z+depth}},uv(l+.05,sy+.05,r-.05,ey-.05))
 end
 if p.doorLeft>0 then front(0,p.doorLeft,p.wallTop,p.wallBottom,p.wall,p.front)end
 if p.doorRight<p.w then front(p.doorRight,p.w,p.wallTop,p.wallBottom,p.wall,p.front)end
 front(p.doorLeft,p.doorRight,p.doorTop,p.doorBottom,p.doorHeight,p.front+p.projection)
 -- Closed recessed body and entrance cheeks, with no upright floor pixels.
 for _,sx in ipairs({2,p.w-2})do
  face({{x+sx,p.wall,z+p.back},{x+sx,p.wall,z+p.front},{x+sx,0,z+p.front},{x+sx,0,z+p.back}},wall,.84)
 end
 face({{x+p.w-2,p.wall,z+p.back},{x+2,p.wall,z+p.back},{x+2,0,z+p.back},{x+p.w-2,0,z+p.back}},wall,.8)
 for _,sx in ipairs({p.doorLeft,p.doorRight})do
  face({{x+sx,p.wall,z+p.front},{x+sx,p.wall,z+p.front+p.projection},{x+sx,0,z+p.front+p.projection},{x+sx,0,z+p.front}},trim,.9)
 end
 face({{x+p.doorLeft,p.wall,z+p.front},{x+p.doorRight,p.wall,z+p.front},{x+p.doorRight,p.wall,z+p.front+p.projection},{x+p.doorLeft,p.wall,z+p.front+p.projection}},trim)
 -- Flat plateau with a narrow, chamfered perimeter, not a central ridge.
 local function height(xx,zz)
  return p.wall+p.bevel*math.min(1,xx/5,(p.w-xx)/5,(zz-p.back)/5,(p.front-zz)/7)
 end
 local xs={0,5,p.w-5,p.w};local zs={p.back,p.back+5,p.front-7,p.front}
 for iz=1,3 do for ix=1,3 do
  local l,r,t,b=xs[ix],xs[ix+1],zs[iz],zs[iz+1]
  local sy=p.back+(t-p.back)/(p.front-p.back)*(p.roofEnd-p.back)
  local ey=p.back+(b-p.back)/(p.front-p.back)*(p.roofEnd-p.back)
  face({{x+l,height(l,t),z+t},{x+r,height(r,t),z+t},{x+r,height(r,b),z+b},{x+l,height(l,b),z+b}},uv(p.w+l+.05,sy+.05,p.w+r-.05,ey-.05),iz==3 and .92 or 1)
 end end
 -- The native perimeter projects beyond the recessed masonry. Close its
 -- underside and front/back lips as well as both side edges.
 if not (g.custom and g.custom.geometry=='tower') then
  local Eaves=V and V.require('RoofEaves') or assert(loadfile('lib/RoofEaves.lua'))()
  local function edge(a,b,dx,dz) Eaves.edge(a,b,dx,dz,trim,face)end
  edge({x,height(0,p.back),z+p.back},{x+p.w,height(p.w,p.back),z+p.back},0,-1.5)
  edge({x+p.w,height(p.w,p.front),z+p.front},{x,height(0,p.front),z+p.front},0,1.5)
  edge({x,height(0,p.front),z+p.front},{x,height(0,p.back),z+p.back},-1,0)
  edge({x+p.w,height(p.w,p.back),z+p.back},{x+p.w,height(p.w,p.front),z+p.front},1,0)
 end
 local chimney=g.custom and g.custom.chimney
 if chimney then
  local l,r=chimney[1]+2,chimney[3]-2;local back=p.back+8;local front=back+12
  local bottom=p.wall+p.bevel;local top=bottom+20
  local brick=uv(chimney[1]+2.05,chimney[2]+26.05,chimney[3]-2.05,chimney[4]-2.05)
  face({{x+l,top,z+front},{x+r,top,z+front},{x+r,bottom,z+front},{x+l,bottom,z+front}},brick)
  face({{x+r,top,z+back},{x+l,top,z+back},{x+l,bottom,z+back},{x+r,bottom,z+back}},brick,.8)
  for _,sx in ipairs({l,r})do face({{x+sx,top,z+back},{x+sx,top,z+front},{x+sx,bottom,z+front},{x+sx,bottom,z+back}},brick,.9)end
  face({{x+l,top,z+back},{x+r,top,z+back},{x+r,top,z+front},{x+l,top,z+front}},uv(chimney[1]+2.05,chimney[2]+10.05,chimney[3]-2.05,chimney[2]+24.05),.9)
 end
 -- Continue the facade's horizontal siding and real window art around
 -- the closed shell. The back never repeats the shop sign or doorway.
 local window=M.window(g)
 for yy=5,p.wall-3,6 do
  for _,sx in ipairs({1.94,p.w-1.94})do
   face({{x+sx,yy+.22,z+p.back},{x+sx,yy+.22,z+p.front},{x+sx,yy,z+p.front},{x+sx,yy,z+p.back}},wall,.78)
  end
  face({{x+p.w-2,yy+.22,z+p.back-.02},{x+2,yy+.22,z+p.back-.02},{x+2,yy,z+p.back-.02},{x+p.w-2,yy,z+p.back-.02}},wall,.74)
 end
 if window then
  local glass=uv(window[1]+.05,window[2]+.05,window[3]-.05,window[4]-.05)
  local wh=math.min(10,p.wall*.4);local ww=math.min(22,(window[3]-window[1])*wh/(window[4]-window[2]))
  local low=math.max(4,(p.wall-wh)*.58);local top=low+wh
  for _,fraction in ipairs({.30,.70})do
   local center=z+p.back+(p.front-p.back)*fraction
   for _,sx in ipairs({1.90,p.w-1.90})do
    face({{x+sx,top+.6,center-ww/2-.6},{x+sx,top+.6,center+ww/2+.6},{x+sx,low-.6,center+ww/2+.6},{x+sx,low-.6,center-ww/2-.6}},trim)
    local offset=sx<p.w/2 and -.02 or .02
    face({{x+sx+offset,top,center-ww/2},{x+sx+offset,top,center+ww/2},{x+sx+offset,low,center+ww/2},{x+sx+offset,low,center-ww/2}},glass)
   end
   local centerX=x+p.w*fraction
   face({{centerX+ww/2+.6,top+.6,z+p.back-.04},{centerX-ww/2-.6,top+.6,z+p.back-.04},{centerX-ww/2-.6,low-.6,z+p.back-.04},{centerX+ww/2+.6,low-.6,z+p.back-.04}},trim)
   face({{centerX+ww/2,top,z+p.back-.06},{centerX-ww/2,top,z+p.back-.06},{centerX-ww/2,low,z+p.back-.06},{centerX+ww/2,low,z+p.back-.06}},glass)
  end
 end
 -- Thin foundation/eave courses and side windows continue the facade.
 for _,sx in ipairs({1.95,p.w-1.95})do
  for _,y in ipairs({1,p.wall-1})do
   face({{x+sx,y+1,z+p.back},{x+sx,y+1,z+p.front},{x+sx,y,z+p.front},{x+sx,y,z+p.back}},trim,.88)
  end
 end
end
return M
