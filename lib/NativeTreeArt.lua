-- Original, palette-baked game art on grounded cards. One padded atlas keeps
-- batching and the existing free-camera billboard/shadow pass intact.
local V=...
local M={}
local size,cell=2048,128
local data,image,dirty
local entries,content,count={},{},0
local function background(w,h,pixel)
 local counts={};local best,n=nil,0
 for y=0,h-1 do for x=0,w-1 do
  local r,g,b=pixel(x,y)
  local k=math.floor(r*255+.5)*65536+math.floor(g*255+.5)*256+math.floor(b*255+.5)
  counts[k]=(counts[k] or 0)+1
  if counts[k]>n then best,n=k,counts[k]end
 end end
 return best and {[best]=true} or {}
end
local function key(r,g,b)return math.floor(r*255+.5)*65536+math.floor(g*255+.5)*256+math.floor(b*255+.5)end
function M.image()
 if not data then data=love.image.newImageData(size,size) end
 if not image then image=love.graphics.newImage(data);image:setFilter('nearest','nearest');dirty=false
 elseif dirty then image:replacePixels(data);dirty=false end
 return image
end
local function card(id,w,h,pixel,ground,shadowRows)
 if entries[id] then return entries[id]end
 if w>cell-2 or h>cell-2 then return end
 local bytes={}
 for y=0,h-1 do for x=0,w-1 do
  local r,g,b,a=pixel(x,y)
  bytes[#bytes+1]=string.char(math.floor(r*255+.5),math.floor(g*255+.5),math.floor(b*255+.5),math.floor(a*255+.5))
 end end
 local fingerprint=w..':'..h..':'..tostring(shadowRows)..':'..table.concat(bytes)
 for k in pairs(ground)do fingerprint=fingerprint..':'..k end
 if content[fingerprint] then entries[id]=content[fingerprint];return entries[id]end
 if count>=(size/cell)^2 then return end
 if not data then data=love.image.newImageData(size,size)end
 local mask=V.require('SceneryMask').mask(w,function(x,y)
  local r,g,b,a=pixel(x,y);return a==0 or ground[key(r,g,b)] or (shadowRows and b>r*1.25 and g>b)
 end,h)
 local x0,y0=count%(size/cell)*cell+1,math.floor(count/(size/cell))*cell+1
 count=count+1
 local lastOpaque=-1
 for y=0,h-1 do for x=0,w-1 do
  local r,g,b,a=pixel(x,y)
  -- Viridian Forest's last source row is a baked green ground shadow
  -- around a brown trunk. Keep the trunk upright; the renderer casts
  -- its own ground shadow instead of standing the oval on end.
  if shadowRows and y>=h-shadowRows and g>r*1.08 and g>b*1.08 then a=0 end
  a=mask[y*w+x] and a or 0
  if a>0 then lastOpaque=math.max(lastOpaque,y)end
  data:setPixel(x0+x,y0+y,r,g,b,a)
 end end
 local c={w=w,h=h,bottom=math.max(0,h-lastOpaque-1),u0=x0/size,u1=(x0+w)/size,v0=y0/size,v1=(y0+h)/size}
 entries[id]=c;content[fingerprint]=c;dirty=true;return c
end
function M.append(c,v,i,q,x,y,z,flat)
 if not c then return q end
 -- Ground the lowest opaque pixel. Modeled stems replace the first four
 -- visible pixels; the flat default retains the whole native silhouette.
 local bottom=c.bottom or 0
 local cut=flat and 0 or math.min(c.h-1,bottom+4)
 local base=#v
 for _,p in ipairs({{-1,0},{1,0},{1,1},{-1,1}})do
  local t=p[2]
  v[#v+1]={x+p[1]*c.w/2,y-bottom+cut+(c.h-cut)*t,z,
   p[1]<0 and c.u0 or c.u1,c.v1-(c.v1-c.v0)*(cut+(c.h-cut)*t)/c.h,1,x,z,y+.001}
 end
 for _,n in ipairs({1,2,3,1,3,4})do i[#i+1]=base+n end
 return q+1
end
function M.gen2(map,cx,cy,lift,donor)
 local pixels=V.require('TerrainAtlas').originalPixels(map);if not pixels then return end
 local wide=lift==20;local short=lift<=4 or map.tileset.id=='TILESET_KANTO'
 local w,h=wide and 32 or 16,short and 16 or 32
 local tx,ty=cx*2,(cy-(short and 0 or 1))*2
 if donor and not short and not wide then
  cx,cy=V.require('Gen2TileShape').treeRootCell(map,cx,cy);tx,ty=cx*2,(cy-1)*2
 end
 local ids={}
 for yy=0,h/8-1 do for xx=0,w/8-1 do ids[#ids+1]=map:tileAt(tx+xx,ty+yy) end end
 if wide then ids={12,13,14,15,28,29,30,31,44,45,46,47,60,61,62,63} end
 local pr=map.tileset.tilesPerRow or 16
 local function sample(tile,x,y)return pixels:getPixel(tile%pr*8+x,math.floor(tile/pr)*8+y)end
 local gt=V.require('Gen2DepthGrass').groundTile(map) or 5
 local ground=background(8,8,function(x,y)return sample(gt,x,y)end)
 return card(tostring(pixels)..':'..table.concat(ids,','),w,h,function(x,y)
  return sample(ids[math.floor(y/8)*(w/8)+math.floor(x/8)+1],x%8,y%8)
 end,ground)
end
function M.gen3(c)
 local ts=c.ts;local forest=c.shape.spacing==3
 -- Complete General drawings, not cropped root tiles. Forest has its own
 -- three-column family. Source IDs are scoped by the resolved tileset.
 -- Dense map borders use cropped overlap cells (20/22, 664, etc.).
 -- Those are not standalone trees. Reconstruct the complete original family
 -- from its cap, middle, rounded lower foliage and, in the forest, trunk.
 local rows=forest and {{1,641,1},{648,649,650},{656,657,658},{672,673,674},{675,676,677}}
   or {{14,15},{28,29},{36,37}}
 local function pixel(mid,x,y)
  local slot=ts.midToSlot[mid];if not slot then return 0,0,0,0 end
  local px,py=slot%ts.cols*16+x,math.floor(slot/ts.cols)*16+y
  local r,g,b,a=ts.imageData:getPixel(px,py)
  if ts.overImageData then local rr,gg,bb,aa=ts.overImageData:getPixel(px,py)
   r,g,b,a=rr*aa+r*(1-aa),gg*aa+g*(1-aa),bb*aa+b*(1-aa),aa+a*(1-aa)
  end
  return r,g,b,a
 end
 local ground=background(16,16,function(x,y)return pixel(c.shape.ground or 1,x,y)end)
 local signature={};for _,row in ipairs(rows)do signature[#signature+1]=table.concat(row,',')end
 return card(tostring(ts.imageData)..':'..table.concat(signature,';'),#rows[1]*16,#rows*16,function(x,y)
  return pixel(rows[math.floor(y/16)+1][math.floor(x/16)+1],x%16,y%16)
 end,ground,forest and 16 or 8)
end
return M
