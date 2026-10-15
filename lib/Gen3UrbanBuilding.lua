-- Authored Rustboro masonry buildings. Native facade pixels describe openings,
-- not a second perspective pasted around a box. Window bays are recessed;
-- cornices, sills, jambs and parapets are closed solids on every elevation.
local M={}
function M.append(g,p,emit)
 local W,D,H=g.width*16,g.depth*16,p.wall;local r=g.custom
 local x,z=g.cx*16,g.cy*16;local atlasW=W*2+4
 local function uv(a,b,c,d)return {{a/atlasW,b/D},{c/atlasW,b/D},{c/atlasW,d/D},{a/atlasW,d/D}}end
 local function sw(a,b)return uv(a+.5,b+.5,a+.5,b+.5)end
 local wall,trim=sw(W*2,0),sw(W*2+2,0)
 local function face(v,t,s)local q={};for i,a in ipairs(v)do
  local xx,zz=a[1],a[3]
  if r.blockedStart then xx=math.max(.02,math.min(W-.02,xx));zz=math.max(r.blockedStart*16+.02,math.min(D-.02,zz))end
  q[i]={x+xx,a[2],z+zz}
 end;emit(q,t,s or 1)end
 local function solid(draw,l,b,n,rr,h,f,t)
  draw({{l,h,n},{rr,h,n},{rr,h,f},{l,h,f}},t,1)
  draw({{l,b,f},{rr,b,f},{rr,b,n},{l,b,n}},t,.65)
  draw({{l,h,f},{rr,h,f},{rr,b,f},{l,b,f}},t,1)
  draw({{rr,h,n},{l,h,n},{l,b,n},{rr,b,n}},t,.78)
  draw({{l,h,n},{l,h,f},{l,b,f},{l,b,n}},t,.84)
  draw({{rr,h,f},{rr,h,n},{rr,b,n},{rr,b,f}},t,.9)
 end
 local function box(l,b,n,rr,h,f,t)solid(face,l,b,n,rr,h,f,t)end
 local back=math.max(18,g.bodyBack or 18);local front=D-1;local roofBack=back-2
 local white=r.name:find('white',1,true)~=nil
 local a,b,c,d=unpack(r.window)
 local stone=sw(a+5,b+(white and 2 or 1))
 local edge=sw(a+2,b+(white and 5 or 4))
 local sill=sw(a+6,b+(white and 15 or 13))
 local glass=uv(a+4.05,b+4.05,a+11.95,b+12.95)
 local inset=r.windowInset
 if r.squareWindows then
  stone=sw(a+(white and 12 or 0),b+(white and 6 or 0))
  edge=sw(a+(white and 3 or 1),b+5);sill=sw(a+6,b+14)
  glass=uv(a+inset[1]+.05,b+inset[2]+.05,a+inset[3]-.05,b+inset[4]-.05)
 end
 local bays,levels={},{}
 -- The two known native window drawings are used only inside exact recipes.
 for iy,row in ipairs(g.rows)do if iy>=4 then for ix,mid in ipairs(row)do
  if mid==0x23a or mid==0x242 then
   local y=D-iy*16
   bays[#bays+1]=inset and {l=(ix-1)*16+inset[1],r=(ix-1)*16+inset[3],b=y+16-inset[4],t=y+16-inset[2]}
    or {l=(ix-1)*16+2,r=(ix-1)*16+14,b=y,t=y+16}
   levels[y]=true
  end
 end end end
 local doors={}
 for _,o in ipairs(r.openings or{})do if o.door then
  doors[#doors+1]={l=o[1],r=o[3],b=D-o[4],t=D-o[2],source=o,door=true}
 end end
 local function elevation(ox,oz,ax,az,nx,nz,left,right,holes,native)
  local function draw(v,t,s)
   local q={};for i,v in ipairs(v)do q[i]={ox+ax*v[1]+nx*v[3],v[2],oz+az*v[1]+nz*v[3]}end;face(q,t,s)
  end
  local function block(l,b,n,r,h,f,t)solid(draw,l,b,n,r,h,f,t)end
  -- Cut the wall surface around real apertures; there is no wall card behind
  -- the glass or door that can cover native opening animations.
  local xs,ys={left,right},{0,H}
  for u=16,right-1,16 do if u>left then xs[#xs+1]=u end end
  for y=16,H-1,16 do ys[#ys+1]=y end
  for _,o in ipairs(holes)do xs[#xs+1]=o.l;xs[#xs+1]=o.r;ys[#ys+1]=o.b;ys[#ys+1]=o.t end
  table.sort(xs);table.sort(ys)
  for j=1,#ys-1 do for i=1,#xs-1 do
   local l,rr,lo,hi=xs[i],xs[i+1],ys[j],ys[j+1]
   if rr>l and hi>lo then
    local hidden=false
    for _,o in ipairs(holes)do if l>=o.l and rr<=o.r and lo>=o.b and hi<=o.t then hidden=true;break end end
    if not hidden then
     local tex
     if native then tex=uv(l+.05,D-hi+.05,rr-.05,D-lo-.05)
     else local u=l%16;local v=(H-hi)%16;tex=uv(W+u+.05,48+v+.05,W+u+rr-l-.05,48+v+hi-lo-.05)end
     draw({{l,hi,0},{rr,hi,0},{rr,lo,0},{l,lo,0}},tex,1)
    end
   end
  end end
  for _,o in ipairs(holes)do
   local l,rr,lo,hi=o.l,o.r,o.b,o.t
   -- Closed jambs and soffit join wall to the inset surface.
   block(l,lo,-1.1,l+.7,hi,.35,edge);block(rr-.7,lo,-1.1,rr,hi,.35,edge)
   block(l,hi-.7,-1.1,rr,hi,.35,stone)
   if o.door then
    local src=o.source
    draw({{l,hi,-.95},{rr,hi,-.95},{rr,lo,-.95},{l,lo,-.95}},uv(src[1]+.05,src[2]+.05,src[3]-.05,src[4]-.05),1)
   elseif r.squareWindows then
    -- RS uses an uninterrupted dark rectangular pane and low horizontal
    -- reflection bands. Preserve the full native sash, without an arch or
    -- Emerald mullion; closed reveals give it depth on every elevation.
    draw({{l,hi,-1.08},{rr,hi,-1.08},{rr,lo,-1.08},{l,lo,-1.08}},glass,64.92)
    block(l,lo,-1.1,rr,lo+.35,.35,sill)
   else
    -- Window glass remains the original native sash/reflection artwork.
    draw({{l+.8,hi-3,-1.08},{rr-.8,hi-3,-1.08},{rr-.8,lo+2,-1.08},{l+.8,lo+2,-1.08}},glass,64.92)
    block(l+.7,lo+1,-1.1,l+1.7,hi-3,.6,stone)
    block(rr-1.7,lo+1,-1.1,rr-.7,hi-3,.6,stone)
    block(l+.7,lo+1,-1.1,rr-.7,lo+2,.65,stone)
    -- Native stepped arch/coped lintel, with top and side faces instead of
    -- stretching its top-down shading onto a flat window card.
    for k=0,2 do block(l+k,hi-3+k,-1.1,rr-k,hi-2+k,.7,stone)end
    block(l+3,hi-.1,-1.1,rr-3,hi,.7,stone)
    block(l-.25,lo,-.2,rr+.25,lo+1,.85,sill)
    if white then block((l+rr)/2-.55,lo+2,-.9,(l+rr)/2+.55,hi-3,.3,edge)end
   end
  end
  -- Continuous stone base, interrupted at doorways; upper courses are
  -- aligned to the source rather than arbitrary extra storeys.
  local cursor=left
  for _,o in ipairs(holes)do if o.door then
   if o.l>cursor then block(cursor,0,0,o.l,1.5,.7,trim)end;cursor=o.r
  end end
  if cursor<right then block(cursor,0,0,right,1.5,.7,trim)end
 end
 local facade={};for _,v in ipairs(bays)do facade[#facade+1]=v end;for _,v in ipairs(doors)do facade[#facade+1]=v end
 table.sort(facade,function(a,b)return a.l<b.l end)
 elevation(0,front,1,0,0,1,2,W-2,facade,true)
 -- Unseen elevations use the original masonry and exact front window
 -- shapes/heights. Their placement is an architectural interpretation.
 local side={}
 for y in pairs(levels)do for u=8,front-back-18,24 do
  side[#side+1]=inset and {l=u,r=u+inset[3]-inset[1],b=y+16-inset[4],t=y+16-inset[2]}
   or {l=u,r=u+12,b=y,t=y+16}
 end end
 elevation(2,back,0,1,-1,0,0,front-back,side,false)
 elevation(W-2,front,0,-1,1,0,0,front-back,side,false)
 local rear={};for _,o in ipairs(bays)do rear[#rear+1]={l=W-o.r,r=W-o.l,b=o.b,t=o.t}end
 elevation(W,back,-1,0,0,-1,2,W-2,rear,false)
 -- Tied corner piers have thickness on both adjoining elevations.
 for _,xx in ipairs({2,W-3.4})do for _,zz in ipairs({back,front-1.4})do
  box(xx,1.5,zz,xx+1.4,H,zz+1.4,stone)
 end end
 -- A closed cornice slab with a recessed deck and continuous coping. The
 -- overhead rear edge clears the native walking row; no wall fills that row.
 box(0,H,roofBack,W,H+1.2,front+1,trim)
 box(.7,H+1.2,roofBack+.7,W-.7,H+2.2,front+.3,stone)
 for zz=roofBack+2,front-2,16 do for xx=2,W-2,16 do
  local rr,ff=math.min(xx+16,W-2),math.min(zz+16,front-2)
  if rr>xx and ff>zz then face({{xx,H+2.23,zz},{rr,H+2.23,zz},{rr,H+2.23,ff},{xx,H+2.23,ff}},uv(W+16.05,16.05,W+16+rr-xx-.05,16+ff-zz-.05))end
 end end
 for _,q in ipairs({{1,roofBack+1,W-1,roofBack+3},{1,front-3,W-1,front-1},{1,roofBack+3,3,front-3},{W-3,roofBack+3,W-1,front-3}})do
  box(q[1],H+2.2,q[2],q[3],H+4.4,q[4],wall)
  box(q[1]-.4,H+4.4,q[2]-.4,q[3]+.4,H+5.1,q[4]+.4,stone)
 end
 if r.chimney then
  -- The square dark inset in the native drawing is on TOP of the vent.
  -- Keep its original cabinet silhouette, with a real recessed upper well.
  local l,rr,n,f=W-22,W-4,back+3,back+17;local h=H+13
  box(l,H+2.2,n,rr,h-1,f,wall)
  box(l-.5,h-1,n-.5,rr+.5,h,f+.5,stone)
  face({{l+1,h+.03,n+1},{rr-1,h+.03,n+1},{rr-1,h+.03,f-1},{l+1,h+.03,f-1}},uv(W-20.95,1.05,W-5.05,14.95))
  for _,q in ipairs({{l-.5,n-.5,rr+.5,n+1},{l-.5,f-1,rr+.5,f+.5},{l-.5,n+1,l+1,f-1},{rr-1,n+1,rr+.5,f-1}})do box(q[1],h,q[2],q[3],h+1.2,q[4],edge)end
 end
 -- Close the underside of the shell without creating an outdoor floor slab.
 face({{2,0,front},{W-2,0,front},{W-2,0,back},{2,0,back}},wall,.65)
end
return M
