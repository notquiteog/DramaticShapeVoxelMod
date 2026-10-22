-- Upright native-art scenery, retaining live provider UVs and image ownership.
-- No copied atlas, generated game asset, gameplay or cell-ownership mutation.
local V=...
local Mask=V and V.require('SceneryMask')or dofile('lib/SceneryMask.lua')
local Budget=V and V.require('BuildBudget')or{check=function()end}
local M={limits={pixels=65536,rectangles=16384}}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
local function key(r,g,b,a)return math.floor(r*255+.5)..':'..math.floor(g*255+.5)..':'..math.floor(b*255+.5)..':'..math.floor((a or 1)*255+.5)end
local function pixel(ts,mid,x,y,size)
 local slot=ts.midToSlot[mid];if slot==nil then return end
 local px,py=slot%ts.cols*size+x,math.floor(slot/ts.cols)*size+y
 local r,g,b,a=ts.imageData:getPixel(px,py)
 if ts.overImageData then local rr,gg,bb,aa=ts.overImageData:getPixel(px,py)
  local alpha=aa+a*(1-aa)
  if alpha>0 then r,g,b=(rr*aa+r*a*(1-aa))/alpha,(gg*aa+g*a*(1-aa))/alpha,(bb*aa+b*a*(1-aa))/alpha end;a=alpha
 end
 return r,g,b,a
end
-- spec: rows, ts, cx/cy (native cells), owner, owns(cell), groundAt(cell).
-- options: cellSize, mask(x,y,cell), background(r,g,b,a,x,y,cell),
-- backgroundMids, base. Explicit mask is useful for wall-mounted/mixed art.
local function prepare(spec,cells,options)
 options=options or{};local size=options.cellSize or 16
 if not(finite(size)and size>=1 and size<=64 and size%1==0 and spec and type(spec.owner)=='table'and type(spec.rows)=='table'and type(spec.rows[1])=='table'and #spec.rows>0)then return nil,'invalid native card specification'end
 local rows,ts=spec.rows,spec.ts;local width=#rows[1];local w,h=width*size,#rows*size
 if width==0 or w*h>M.limits.pixels or not(ts and ts.imageData and ts.midToSlot and ts.cols and ts.rows)then return nil,'native card source unavailable'end
 if not(finite(spec.cx)and finite(spec.cy)and type(spec.owns)=='function')then return nil,'native card ownership unavailable'end
 local owned,fronts,palettes={}, {},{};local level,count
 local function palette(mid)
  if mid==nil or ts.midToSlot[mid]==nil then return end
  if palettes[mid]then return palettes[mid]end
  local out={};for y=0,size-1 do for x=0,size-1 do local r,g,b,a=pixel(ts,mid,x,y,size);out[key(r,g,b,a)]=true end end
  palettes[mid]=out;return out
 end
 local extra={};for _,mid in ipairs(options.backgroundMids or{})do local p=palette(mid);if not p then return nil,'native card background unavailable'end;for k in pairs(p)do extra[k]=true end end
 for y,row in ipairs(rows)do
  if #row~=width then return nil,'ragged native card rows'end
  for x,mid in ipairs(row)do
   if ts.midToSlot[mid]==nil then return nil,'native card source tile unavailable'end
   local c=cells[(spec.cx+x-1)..':'..(spec.cy+y-1)]
   if not c or c.ts~=ts or c.mid~=mid then return nil,'native card source drawing changed'end
   if spec.owns(c)then
    if c.stageHidden or c.boundary then return nil,'native card source hidden or boundary'end
    local base=c.base or 0;if not finite(base)then return nil,'native card elevation unavailable'end
    if level==nil then level=base elseif math.abs(level-base)>.001 then return nil,'native card spans different elevations'end
    local p=spec.groundAt and palette(spec.groundAt(c))
    if not(p or options.mask or options.background)then return nil,'native card local ground unavailable'end
    owned[(y-1)*width+x-1]={cell=c,palette=p or{}};fronts[x]=(y*size);count=(count or 0)+1
   end
  end;Budget.check()
 end
 if not count then return nil,'native card has no owned source'end
 local function owner(x,y)return owned[math.floor(y/size)*width+math.floor(x/size)]end
 local function sample(x,y)return pixel(ts,rows[math.floor(y/size)+1][math.floor(x/size)+1],x%size,y%size,size)end
 local mask
 if options.mask then
  mask={};for y=0,h-1 do for x=0,w-1 do local o=owner(x,y);mask[y*w+x]=o and not not options.mask(x,y,o.cell)or false end end
 else
  mask=Mask.mask(w,function(x,y)
   local o=owner(x,y);if not o then return true end
   local r,g,b,a=sample(x,y);if a<=0 then return true end
   if options.background then return options.background(r,g,b,a,x,y,o.cell)end
   local k=key(r,g,b,a);return o.palette[k]or extra[k]or false
  end,h)
 end
 local card={owner=spec.owner,ts=ts,cx=spec.cx,cy=spec.cy,cellSize=size,w=w,h=h,rows=rows,rects={},segments={},
  base=options.base or spec.base or level or 0,owned=owned,fronts=fronts,sourceCells=cells}
 if not finite(card.base)then return nil,'invalid native card base'end
 -- Separate depth baselines for a projecting arch, side wing or recessed
 -- cabinet. Each segment remains inside actual source-owned ground cells.
 for x=1,width do if fronts[x]then
  local last=card.segments[#card.segments]
  if last and last.right==(x-1)*size and last.bottom==fronts[x]then last.right=x*size
  else card.segments[#card.segments+1]={left=(x-1)*size,right=x*size,bottom=fronts[x]}end
 end end
 local used={};local visible=0
 for ty,row in ipairs(rows)do for tx,mid in ipairs(row)do
  local bottom=fronts[tx]
  if bottom then
   for yy=0,size-1 do for xx=0,size-1 do
    local x,y=(tx-1)*size+xx,(ty-1)*size+yy;local k=y*w+x
    if owner(x,y)and mask[k]and not used[k]then
     local right=x+1;while right<tx*size and mask[y*w+right]and not used[y*w+right]do right=right+1 end
     local down=y+1;local more=true
     while down<ty*size and more do
      for q=x,right-1 do if not mask[down*w+q]or used[down*w+q]then more=false;break end end
      if more then down=down+1 end
     end
     for qy=y,down-1 do for qx=x,right-1 do used[qy*w+qx]=true;visible=visible+1 end end
     card.rects[#card.rects+1]={mid=mid,left=x,top=y,right=right,bottom=down,front=bottom}
     if #card.rects>M.limits.rectangles then return nil,'native card rectangle budget exceeded'end
    end
   end end
  end
 end;Budget.check()end
 if visible==0 then return nil,'native card silhouette empty'end
 card.pixels=visible;return card
end
function M.prepare(spec,cells,options)
 local ok,card,err=pcall(prepare,spec,cells,options)
 if not ok then return nil,'native card source read failed: '..tostring(card)end
 return card,err
end
function M.prepareCivic(g,cells,options)
 if not g or g.stageHidden then return nil,'native civic hidden'end
 local Civic=V and V.require('Gen3Civic')or dofile('lib/Gen3Civic.lua')
 return M.prepare({owner=g,rows=g.rows,ts=g.ts,cx=g.cx,cy=g.cy,base=g.groundHeight,
  owns=function(c)return c.civic==g end,groundAt=Civic.ground},cells,options)
end
function M.prepareFurniture(p,cells,options)
 if not p or p.stageHidden or not p.recipe or p.recipe.noGround then return nil,'native furniture card unsupported'end
 local Furniture=V and V.require('Gen3Furniture')or dofile('lib/Gen3Furniture.lua')
 return M.prepare({owner=p,rows=p.recipe.rows,ts=p.ts,cx=p.cx,cy=p.cy,base=p.groundHeight,
  owns=function(c)return c.prop==p end,groundAt=Furniture.groundAt},cells,options)
end
function M.prepareCell(c,cells,options)
 if not c or c.prop or c.civic or not c.shape then return nil,'native cell already owned'end
 return M.prepare({owner=c,rows={{c.mid}},ts=c.ts,cx=c.cx,cy=c.cy,base=c.base,
  owns=function(q)return q==c end,groundAt=function()return c.shape.ground end},cells,options)
end
-- The parent emitter receives ordinary native-atlas UVs. It can batch these
-- with its existing under/over images, preserving the native animation clock.
function M.append(card,emit,uvFor)
 if not(card and type(emit)=='function'and type(uvFor)=='function')then return false,'invalid native card emitter'end
 local faces={};local size=card.cellSize
 for _,r in ipairs(card.rects)do
  local uv=uvFor(card.ts,r.mid);if not uv then return false,'native card UV unavailable'end
  local tx,ty=math.floor(r.left/size)*size,math.floor(r.top/size)*size
  local function tex(x,y)return{uv[1][1]+(uv[2][1]-uv[1][1])*(x-tx)/size,uv[1][2]+(uv[3][2]-uv[1][2])*(y-ty)/size}end
  local l,t,rr,b=r.left,r.top,r.right,r.bottom;local x,z=card.cx*size,card.cy*size+r.front-.25
  faces[#faces+1]={{{x+l,r.front-t,z},{x+rr,r.front-t,z},{x+rr,r.front-b,z},{x+l,r.front-b,z}},
   {tex(l,t),tex(rr,t),tex(rr,b),tex(l,b)}}
 end
 -- Validate every UV before emitting anything: missing source keeps the
 -- caller's original geometry intact instead of leaving a partial card.
 for _,f in ipairs(faces)do emit(f[1],f[2],1)end;return true
end
function M.build(card,newMesh,parts,uvFor)
 if not(card and type(newMesh)=='function'and type(parts)=='table')then return nil,'invalid native card upload'end
 if not card.ts.image or card.ts.overImageData and not card.ts.overImage then return nil,'native card atlas image unavailable'end
 local vertices,indices={},{}
 local ok,err=M.append(card,function(points,uv,shade)
  local base=#vertices;for i,p in ipairs(points)do vertices[#vertices+1]={p[1],p[2]+card.base,p[3],uv[i][1],uv[i][2],shade}end
  for _,i in ipairs{1,2,3,1,3,4}do indices[#indices+1]=base+i end
 end,uvFor)
 if not ok then return nil,err end
 local uploaded,mesh=pcall(newMesh,vertices,indices)
 if not uploaded or not mesh then return nil,uploaded and'native card upload failed'or tostring(mesh)end
 local part={mesh=mesh,card=card,placement=card.owner};parts[#parts+1]=part
 card.owner.nativeSceneryCard=card;return part
end
function M.draw(part,draw)
 local ts=part.card.ts
 if not ts.image then return false,'native card atlas image unavailable'end
 draw(part.mesh,ts.image);if ts.overImage then draw(part.mesh,ts.overImage)end;return true
end
function M.release(part)
 if part and part.mesh then part.mesh:release();part.mesh=nil end
 if part and part.card and part.card.owner.nativeSceneryCard==part.card then part.card.owner.nativeSceneryCard=nil end
end
function M.doorSurface(card,tx,ty,options)
 if not card then return end;options=options or{};local s=card.cellSize
 local x,y=tx-card.cx,ty-card.cy;local owned=card.owned[y*(card.w/s)+x]
 if not(owned and owned.cell.collision==0x71 and card.fronts[x+1]==(y+1)*s)then return end
 local w,h=options.width or s,options.height or s*2
 local l,t=x*s,y*s-(h-s);local r,b=l+w,t+h
 if l<0 or t<0 or r>card.w or b>card.h then return end
 for xx=math.floor(l/s),math.ceil(r/s)-1 do if card.fronts[xx+1]~=b then return end end
 local z=card.cy*s+b-.24;local world=card.cx*s
 return{w=w,h=h,sourceX=world+l,sourceY=card.cy*s+t,base=card.base,
  vertices={{world+l,b-t,z},{world+r,b-t,z},{world+r,0,z},{world+l,0,z}}}
end
return M
