-- Authored Emerald Centers and Marts. A closed octagonal masonry shell, a rounded
-- metal roof and a flush roof badge; no top-down wall/roof folding.
local V=...
local A=V.require('ArchitecturalDetails')
local M={}
function M.append(g,p,emit)
 local x,z=g.cx*16,g.cy*16
 local function uv(l,t,r,b)return {{l/132,t/64},{r/132,t/64},{r/132,b/64},{l/132,b/64}}end
 local function swatch(u,v)return uv(u+.1,v+.1,u+.2,v+.2)end
 local function face(points,tex,shade)
  local out={};for i,q in ipairs(points)do out[i]={x+q[1],q[2],z+q[3]}end
  emit(out,tex,shade or 1)
 end
 local porcelain=swatch(4,48);local wall=swatch(8,55)
 local metal=swatch(16,49);local base=swatch(12,61)
 local red=swatch(12,30);local edge=swatch(12,38)
 local function box(l,b,n,r,h,f,t)A.box(face,l,b,n,r,h,f,t)end
 -- Native rear roof-art row is walkable. The wall shell starts in row 1.
 local ring={{8,18},{56,18},{62,24},{62,54},{56,60},{8,60},{2,54},{2,24}}
 for i,a in ipairs(ring)do
  local b=ring[i%#ring+1]
  if i~=5 then
   face({{a[1],23,a[2]},{b[1],23,b[2]},{b[1],0,b[2]},{a[1],0,a[2]}},i%2==0 and porcelain or wall,({.82,.88,.9,.94,1,.9,.82,.85})[i])
  end
 end
 -- Original front panel: split at the real glass door, recessed by one pixel.
 -- Cropping the native projected corner strips avoids double perspective.
 local door={17,45,31,61}
 local xs={8,17,31,56};local ys={40,45,61,63}
 for iy=1,3 do for ix=1,3 do
  local l,r,t,b=xs[ix],xs[ix+1],ys[iy],ys[iy+1]
  if not(ix==2 and iy==2)then
   face({{l,63-t,60},{r,63-t,60},{r,63-b,60},{l,63-b,60}},uv(l,t,r,b))
  end
 end end
 face({{17,18,59},{31,18,59},{31,2,59},{17,2,59}},uv(17,45,31,61))
 box(16,1,59,17,19,60.3,metal);box(31,1,59,32,19,60.3,metal)
 box(16,18,59,32,19,60.3,metal)
 -- Shallow lintel, threshold and separate porcelain P.C. panel.
 box(8,20,59.8,56,22,60.3,porcelain)
 box(17,0,59.5,31,2,60.4,base)
 box(40,2,59.9,56,17,60.4,porcelain)
 face({{40,17,60.42},{56,17,60.42},{56,2,60.42},{40,2,60.42}},uv(40,46,56,61))
 -- Closed corner/piers and recessed panel joints on the unseen elevations.
 -- These are deliberately shallower than a pixel and never widen the shell.
 for _,sx in ipairs({2,62})do
  local outward=sx==2 and -.15 or .15
  for _,zz in ipairs({24,39,53})do
   box(sx+math.min(0,outward),1,zz,sx+math.max(0,outward),22,zz+.45,porcelain)
  end
  face({{sx+outward,2,24},{sx+outward,2,54},{sx+outward,1.5,54},{sx+outward,1.5,24}},base,.85)
 end
 for _,xx in ipairs({8,24,40,55.5})do box(xx,1,17.85,xx+.45,22,18,porcelain)end
 face({{8,2,17.84},{56,2,17.84},{56,1.5,17.84},{8,1.5,17.84}},base,.82)
 -- Rounded barrel shell. Longitudinal native stripes belong to the metal
 -- surface, while the rounded front fascia and emblem have separate geometry.
 -- Native silhouette: two lower shoulders, then a distinct raised central
 -- hump. It is not a single barrel/semicircle across the whole building.
 local rise={[0]=0,[4]=4,[8]=7,[12]=7,[16]=7,[20]=11,[24]=15,
  [28]=17,[32]=17.5,[36]=17,[40]=15,[44]=11,[48]=7,[52]=7,[56]=7,[60]=4,[64]=0}
 if g.kind=='mart' then
  -- The Mart has a broad low plateau with rolled side edges, not the
  -- Center's raised central hump or a house's pitched gable.
  rise={[0]=0,[4]=7,[8]=12,[12]=12,[16]=12,[20]=12,[24]=12,
   [28]=12,[32]=12,[36]=12,[40]=12,[44]=12,[48]=12,[52]=12,[56]=12,[60]=7,[64]=0}
 end
 local function height(xx)return 25+assert(rise[xx])end
 for xx=0,60,4 do
  local r=xx+4;local a,b=height(xx),height(r)
  local dx,dy=4,b-a;local len=math.sqrt(dx*dx+dy*dy)
  local shade=.8+.18*dx/len-.08*dy/len
  face({{xx,a,14},{r,b,14},{r,b,59},{xx,a,59}},uv(64+xx,3,64+r,24),shade)
  -- Two-pixel rounded front edge, solid red fascia, dark lower eave band.
  face({{xx,a,59},{r,b,59},{r,b-.6,61},{xx,a-.6,61}},uv(64+xx,24,64+r,30),shade*.95)
  face({{xx,a-.6,61},{r,b-.6,61},{r,25,61},{xx,25,61}},red,.95)
  face({{xx,25,61},{r,25,61},{r,23,61},{xx,23,61}},edge,.9)
  face({{r,b,14},{xx,a,14},{xx,23,14},{r,23,14}},red,.78)
  face({{xx,23,61},{r,23,61},{r,23,14},{xx,23,14}},edge,.68)
 end
 for _,sx in ipairs({0,64})do face({{sx,25,14},{sx,25,61},{sx,23,61},{sx,23,14}},red,.84)end
 -- Flush circular badge. The source's top/bottom horizontal roof bands are
 -- outside this crop; only the actual emblem is mapped onto its raised rim.
 local function tex(u,v)return uv(u,v,u,v)[1]end
 local tc=tex(31.5,31.5)
 for i=0,31 do
  local a,b=i*math.pi/16,(i+1)*math.pi/16
  local ax,ay=32+math.cos(a)*8.5,31.5+math.sin(a)*8.5
  local bx,by=32+math.cos(b)*8.5,31.5+math.sin(b)*8.5
  local ta=tex(31.5+math.cos(a)*9.5,31.5-math.sin(a)*7.5)
  local tb=tex(31.5+math.cos(b)*9.5,31.5-math.sin(b)*7.5)
  face({{32,31.5,61.46},{ax,ay,61.46},{bx,by,61.46},{32,31.5,61.46}},{tc,ta,tb,tc})
  face({{ax,ay,61},{ax,ay,61.46},{bx,by,61.46},{bx,by,61}},edge,.85)
 end
end
return M
