-- Closed structural parts shared by native-art buildings. UVs supply palette
-- swatches and glazing; the profile, frames, sills and reveals are geometry.
local V=...
local Eaves=V and V.require('RoofEaves') or dofile('lib/RoofEaves.lua')
local M={}
function M.box(emit,l,b,n,r,h,f,material)
 local v={{{l,h,n},{r,h,n},{r,h,f},{l,h,f}},{{l,b,f},{r,b,f},{r,b,n},{l,b,n}},
  {{l,h,f},{r,h,f},{r,b,f},{l,b,f}},{{r,h,n},{l,h,n},{l,b,n},{r,b,n}},
  {{l,h,n},{l,h,f},{l,b,f},{l,b,n}},{{r,h,f},{r,h,n},{r,b,n},{r,b,f}}}
 for i,q in ipairs(v)do emit(q,material,({1,.6,.96,.78,.84,.9})[i])end
end
-- Local x = width, y = elevation, z = outward depth. Glass is set behind
-- the frame, with a sloping sill and closed jambs on every viewing side.
function M.opening(emit,l,b,r,h,depth,frame,glass,door,details)
 local t=door and 1.3 or .9
 local back,front=depth-.65,depth+.9
 M.box(emit,l-t,b,back,l,h+t,front,frame)
 M.box(emit,r,b,back,r+t,h+t,front,frame)
 M.box(emit,l,b,back,r,b+t,front+.6,frame)
 M.box(emit,l,h,back,r,h+t,front,frame)
 emit({{l,h,depth},{r,h,depth},{r,b,depth},{l,b,depth}},glass,1)
 -- Native panes already draw their own sash/handle. Do not superimpose a
 -- second divider or put an invented handle on the opposite door edge.
 if details=='native' then return end
 if not door then
  local mid=(l+r)/2
  M.box(emit,mid-.3,b,depth+.1,mid+.3,h,depth+.5,frame)
 else
  M.box(emit,r-1.6,(h+b)*.46,depth+.1,r-.8,(h+b)*.46+1.4,depth+.75,frame)
 end
end
-- Source-colored circular aperture. Corner fans close the rectangular wall
-- cut; a continuous annular frame joins a genuinely recessed glass disk.
-- tex(x,y) samples the unchanged native drawing in normalized coordinates.
function M.roundOpening(emit,l,b,r,h,depth,tex)
 local cx,cy=(l+r)/2,(b+h)/2;local rx,ry=(r-l)/2,(h-b)/2
 local function point(a,radius,z,square)
  local x,y=math.cos(a),math.sin(a)
  if square then radius=1/math.max(math.abs(x),math.abs(y))end
  return {cx+rx*x*radius,cy+ry*y*radius,depth+z}
 end
 local function uv(p)return tex((p[1]-l)/(r-l),1-(p[2]-b)/(h-b))end
 local function face(a,bb,c,d,shade)emit({a,bb,c,d},{uv(a),uv(bb),uv(c),uv(d)},shade or 1)end
 for i=0,31 do
  local a,bb=i*math.pi/16,(i+1)*math.pi/16
  face(point(a,1,0,true),point(bb,1,0,true),point(bb,1,0),point(a,1,0))
  face(point(a,1,0),point(bb,1,0),point(bb,1,.25),point(a,1,.25),.9)
  face(point(a,1,.25),point(bb,1,.25),point(bb,.76,.25),point(a,.76,.25))
  face(point(a,.76,.25),point(bb,.76,.25),point(bb,.76,-.85),point(a,.76,-.85),.8)
  face(point(0,0,-.85),point(a,.76,-.85),point(bb,.76,-.85),point(0,0,-.85))
 end
end
-- An authored pitched or barrel profile. Every roof bay is a prism: the
-- gables, underside and eave thickness are closed, not stretched wall cards.
function M.roof(p,style,rise,uv,emit,trim)
 local w,n,f=p.w,p.roofBack or p.back,p.front
 local h=p.wall;local t=1.2
 if style=='flat_panel' then
  -- Keep the RS green sheet continuous and inside the original footprint.
  -- The raised yellow edge in its source is a fascia, not a pitched ridge.
  local l,r=.02,w-.02;local back,front=math.max(16,n),f-.02
  local top=h+1.2
  emit({{l,top,back},{r,top,back},{r,top,front},{l,top,front}},uv(w+.05,p.back+.05,w+w-.05,p.roofEnd-.05),1)
  local paint=uv(w+w*.5,p.back+4,w+w*.5,p.back+4)
  for _,q in ipairs{{{l,top,front},{r,top,front},{r,h-t,front},{l,h-t,front}},
   {{r,top,back},{l,top,back},{l,h-t,back},{r,h-t,back}},
   {{l,top,back},{l,top,front},{l,h-t,front},{l,h-t,back}},
   {{r,top,front},{r,top,back},{r,h-t,back},{r,h-t,front}}}do emit(q,paint,.9)end
  emit({{l,h-t,front},{r,h-t,front},{r,h-t,back},{l,h-t,back}},trim,.65)
  return
 end
 local roofPaint=uv(p.w+w*.25,p.back+12,p.w+w*.25,p.back+12)
 local axis=(style=='barrel' or style=='hipped_barrel') and 'x' or 'z'
 local profile=axis=='x' and {{0,0},{8,rise*.65},{18,rise},{w-18,rise},{w-8,rise*.65},{w,0}}
  or {{n,0},{n+(f-n)*.22,rise},{f,0}}
 for i=1,#profile-1 do
  local a,b=profile[i],profile[i+1]
  local al,bl=a[1],b[1];local ah,bh=h+a[2],h+b[2]
  if axis=='x' then
   if style=='hipped_barrel' then
    -- Hoenn Centers have a rounded raised rear crown but a straight low
    -- front eave. Carry the roof down over the entrance, not a giant solid
    -- semicircular gable replacing the native lower roof band.
    local shoulder=f-math.min(18,(f-n)*.36)
    local sourceShoulder=p.roofEnd-math.min(p.roofEnd-p.back-1,math.sqrt((f-shoulder)^2+rise^2))
    emit({{al,ah,n},{bl,bh,n},{bl,bh,shoulder},{al,ah,shoulder}},uv(p.w+al,p.back,p.w+bl,sourceShoulder),1)
    emit({{al,ah,shoulder},{bl,bh,shoulder},{bl,h,f},{al,h,f}},uv(p.w+al,sourceShoulder,p.w+bl,p.roofEnd),.94)
    emit({{al,ah,n},{bl,bh,n},{bl,h-t,n},{al,h-t,n}},roofPaint,.75)
    Eaves.edge({al,ah,n},{bl,bh,n},0,-1.5,roofPaint,emit)
    Eaves.edge({al,h,f},{bl,h,f},0,1.5,roofPaint,emit)
   else
    emit({{al,ah,n},{bl,bh,n},{bl,bh,f},{al,ah,f}},uv(p.w+al,p.back,p.w+bl,p.roofEnd),1)
    for _,z in ipairs({n,f})do
     emit({{al,ah,z},{bl,bh,z},{bl,h-t,z},{al,h-t,z}},roofPaint,z==n and .75 or .94)
     Eaves.edge({al,ah,z},{bl,bh,z},0,z==n and -1.5 or 1.5,roofPaint,emit)
    end
   end
  else
   local sy=i==1 and p.back or p.back+8;local ey=i==1 and p.back+8 or p.roofEnd
   emit({{0,ah,al},{w,ah,al},{w,bh,bl},{0,bh,bl}},uv(p.w+.05,sy+.05,p.w+w-.05,ey-.05),i==1 and .85 or 1)
   for _,x in ipairs({0,w})do
    emit({{x,ah,al},{x,bh,bl},{x,h-t,bl},{x,h-t,al}},trim,x==0 and .82 or .9)
    Eaves.edge({x,ah,al},{x,bh,bl},x==0 and -1 or 1,0,trim,emit)
   end
  end
 end
 for _,x in ipairs({0,w})do for _,z in ipairs({n,f})do Eaves.corner({x,h,z},x==0 and -1 or 1,z==n and -1.5 or 1.5,trim,emit)end end
 if axis=='z' then
  Eaves.edge({0,h,n},{w,h,n},0,-1.5,trim,emit);Eaves.edge({0,h,f},{w,h,f},0,1.5,trim,emit)
 else
  Eaves.edge({0,h,n},{0,h,f},-1,0,roofPaint,emit);Eaves.edge({w,h,n},{w,h,f},1,0,roofPaint,emit)
 end
 M.box(emit,0,h-t,n,w,h,n+1.1,trim);M.box(emit,0,h-t,f-1.1,w,h,f,trim)
 M.box(emit,0,h-t,n,1,h,f,trim);M.box(emit,w-1,h-t,n,w,h,f,trim)
 emit({{0,h-t,f},{w,h-t,f},{w,h-t,n},{0,h-t,n}},trim,.65)
 if axis=='z' then
  local ridge=profile[2][1]
  M.box(emit,-.4,h+rise-.4,ridge-.8,w+.4,h+rise+.8,ridge+.8,trim)
 end
end
return M
