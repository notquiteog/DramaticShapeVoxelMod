-- Native lifted rows keep their own X while the rest of the picture slides.
-- Convert the original UI band into the source-sized world card; no timer or
-- battler state is changed. The caller retains all picture/palette ownership.
local M={}
function M.range(back,nativeHeight,nativeScale,height,scale,ground,ay,rows)
 if not(type(rows)=='table'and type(rows[1])=='number'and type(rows[2])=='number'
  and rows[1]>=0 and rows[2]>0 and nativeHeight>0 and nativeScale>0)then return end
 local box=back and 48 or 56
 local top=back and(box-nativeHeight)or math.max(0,box-nativeHeight)
 top=top+math.floor(nativeHeight*(1-nativeScale*scale))
 local ratio=height/(nativeHeight*nativeScale)
 local y=ay-ground*scale+(rows[1]*8-top)*ratio
 return {y,y+rows[2]*8*ratio}
end
function M.draw(g,w,h,band,slide,paint)
 local sx,sy,sw,sh=g.getScissor()
 local a=math.max(0,math.min(h,math.floor(band[1])))
 local b=math.max(a,math.min(h,math.floor(band[2])))
 local ok,err=pcall(function()
  if a>0 then g.setScissor(0,0,w,a);paint(slide)end
  if b<h then g.setScissor(0,b,w,h-b);paint(slide)end
  if b>a then g.setScissor(0,a,w,b-a);paint(0,true)end
 end)
 if sx then g.setScissor(sx,sy,sw,sh)else g.setScissor()end
 if not ok then error(err,0)end
end
local function signed(v)v=(tonumber(v)or 0)%256;return v>=128 and v-256 or v end
function M.raster(bg)
 return bg and((bg.scx or 0)~=0 or(bg.scy or 0)~=0 or bg.lcdc~=nil)or false
end
-- Use the engine's public LCD readers; group equal neighboring rows so a
-- uniform shake is one picture draw rather than144 separate submissions.
function M.runs(view,bg,back,lifted)
 local lines={}
 if bg.lcdc=='BGP'then
  for _,band in ipairs(view.bgpBands(bg))do
   for _,row in ipairs(band.rows)do lines[#lines+1]={src=row,dest=row-signed(bg.scy),dx=0,byte=band.byte}end
  end
  table.sort(lines,function(a,b)return a.dest<b.dest end)
 else lines=view.scanlines(bg)end
 local out={};local last
 local first=lifted and((back and 48 or 0)+lifted[1]*8)
 local final=first and(first+lifted[2]*8)
 for _,line in ipairs(lines)do
  local y=line.src;local byte=line.byte or bg.bgp
  if not first or y<first or y>=final then
   local dx=-signed(bg.scx)+(line.dx or 0)
   if last and last.src+last.n==y and last.dest+last.n==line.dest and last.dx==dx and last.byte==byte then
    last.n=last.n+1
   else last={src=y,dest=line.dest,n=1,dx=dx,byte=byte};out[#out+1]=last end
  else last=nil end
 end
 return out
end
function M.viewport(back,nativeWidth,nativeScale,width,scale,ax,slide,nativeLeft)
 local box=back and 48 or 56
 local nativeX=(nativeLeft or((back and 16 or 96)+(back and math.floor((box-nativeWidth)/2)or math.max(0,math.floor((box-nativeWidth)/2)))
  +math.floor(nativeWidth*(1-nativeScale*scale)/2)))+slide
 local ratio=width/(nativeWidth*nativeScale)
 local x=ax-width*scale/2+slide*ratio-nativeX*ratio
 return {x,x+160*ratio}
end
function M.drawRaster(g,w,h,runs,back,nativeHeight,nativeScale,height,scale,ground,ay,paint,clipX)
 local box=back and 48 or 56
 local top=(back and(box-nativeHeight)or math.max(0,box-nativeHeight))
  +math.floor(nativeHeight*(1-nativeScale*scale))+(back and 48 or 0)
 local ratio=height/(nativeHeight*nativeScale)
 local origin=ay-ground*scale
 local left=math.max(0,math.min(w,math.floor(clipX and clipX[1]or 0)))
 local right=math.max(left,math.min(w,math.floor(clipX and clipX[2]or w)))
 local sx,sy,sw,sh=g.getScissor()
 local ok,err=pcall(function()
  for _,run in ipairs(runs)do
   local a=math.max(0,math.min(h,math.floor(origin+(run.dest-top)*ratio)))
   local b=math.max(a,math.min(h,math.floor(origin+(run.dest+run.n-top)*ratio)))
   if b>a and right>left then
    g.setScissor(left,a,right-left,b-a)
    paint(run.dx*ratio,(run.dest-run.src)*ratio,run.byte)
   end
  end
 end)
 if sx then g.setScissor(sx,sy,sw,sh)else g.setScissor()end
 if not ok then error(err,0)end
end
return M
