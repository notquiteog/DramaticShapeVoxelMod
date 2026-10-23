-- The exact native flower-planter drawings remain flat HD2D, including all
-- petals/leaves and original planter paint. No source flower geometry is added.
local V=...
local Models,Budget=V.require('SceneryModels'),V.require('BuildBudget')
local M={FORMAT={{'VertexPosition','float',3},{'VertexTexCoord','float',2},{'VertexShade','float',1},{'VertexColor','float',4},{'VertexCanopy','float',3}}}
local function pixel(ts,x,y)
 local mid=({{664,665,666,667,668},{672,206,674,675,676}})[math.floor((y-48)/16)+1][math.floor(x/16)+1]
 local at=assert(ts.midToSlot[mid],'native planter tile missing');local px,py=at%ts.cols*16+x%16,math.floor(at/ts.cols)*16+y%16
 local r,g,b,a=ts.imageData:getPixel(px,py)
 if ts.overImageData then local rr,gg,bb,aa=ts.overImageData:getPixel(px,py);r,g,b,a=rr*aa+r*(1-aa),gg*aa+g*(1-aa),bb*aa+b*(1-aa),aa+a*(1-aa)end
 return r,g,b,a
end
function M.imageData(ts)
 if not(ts and ts.imageData and ts.midToSlot)then return nil,'native flower atlas unavailable'end
 local data=love.image.newImageData(64,16);local counts={0,0}
 local ok,err=pcall(function()
  for group,rect in ipairs{{0,16,0},{32,80,16}}do for y=56,71 do for x=rect[1],rect[2]-1 do
   local r,g,b,a=pixel(ts,x,y);local ri,gi,bi=math.floor(r*255+.5),math.floor(g*255+.5),math.floor(b*255+.5)
   -- Exact reviewed native facade gray and surrounding lawn, not foliage.
   local background=(ri==74 and gi==74 and bi==90)or(ri==123 and gi==123 and bi==132)or(ri==115 and gi==206 and bi==165)
   if background then a=0 else counts[group]=counts[group]+1 end
   data:setPixel(rect[3]+x-rect[1],y-56,r,g,b,a)
  end end end
  assert(counts[1]==205 and counts[2]==656,'unreviewed native planter pixels')
 end)
 if not ok then data:release();return nil,tostring(err)end
 return data
end
function M.geometry(g,fit)
 -- Original flowers use one uniform pixel scale for both planter drawings.
 -- Fit to the source wall bays around its original left portal; do not put a
 -- detached original-width bed beyond the smaller regional source facade.
 local door=fit.anchors.door;local base=g.groundHeight or 0
 local wallLeft=door[1]-22/74*fit.scale;local wallRight=door[1]+38/74*fit.scale
 local doorRight=door[1]+10/74*fit.scale
 local cards={{x=wallLeft,w=8,u0=0,u1=.25},{x=math.min(wallRight-24,doorRight+.5),w=24,u0=.25,u1=1}}
 local vertices,indices={},{};local z=(g.cy+1)*16+door[3]+7
 for _,c in ipairs(cards)do
  assert(c.x>=.25 and c.x+c.w<=79.75 and z>=g.cy*16+16 and z<=g.cy*16+80,'native flower card outside its original group')
  local ax=g.cx*16+c.x+c.w/2;local first=#vertices
  for _,p in ipairs{{0,8,c.u0,0},{c.w,8,c.u1,0},{c.w,0,c.u1,1},{0,0,c.u0,1}}do vertices[#vertices+1]={g.cx*16+c.x+p[1],base+p[2],z,p[3],p[4],1,1,1,1,1,ax,z,base}end
  for _,i in ipairs{1,2,3,1,3,4}do indices[#indices+1]=first+i end
 end
 return vertices,indices
end
function M.release(g)
 if g._viridianFlowerOwner and Budget.untrack then Budget.untrack(g._viridianFlowerOwner)end
 local image=g.importedViridianFlowerImage or g._viridianFlowerPendingImage;if image then image:release()end
 g.importedViridianFlowerImage,g._viridianFlowerPendingImage,g._viridianFlowerOwner=nil,nil,nil
end
function M.build(g,fit,newMesh,parts)
 local part={modelId='hgss_viridian_flower_house',role='hd2d_flower_cards',alphaMode='cutout',opacity=1,count=2};parts[#parts+1]=part
 g._viridianFlowerOwner={release=function()M.release(g)end};if Budget.track then Budget.track(g._viridianFlowerOwner)end
 local data
 local ok,err=pcall(function()
  local why;data,why=M.imageData(g.ts);assert(data,why)
  g.importedViridianFlowerPixelHash=love.data.encode('string','hex',love.data.hash('sha256',data:getString()))
  local image=love.graphics.newImage(data);g._viridianFlowerPendingImage=image;image:setFilter('nearest','nearest');image:setWrap('clamp','clamp');part.image=image
  local vertices,indices=M.geometry(g,fit);part.mesh=assert(newMesh(vertices,indices,M.FORMAT),'native HD2D planter upload failed');part.mesh:setTexture(image)
 end)
 if data then data:release()end
 if not ok then Models.releaseBatches({part});parts[#parts]=nil;M.release(g);return false,tostring(err)end
 g.importedViridianFlowerImage=g._viridianFlowerPendingImage;g._viridianFlowerPendingImage=nil;return true
end
function M.commit(g)if g._viridianFlowerOwner and Budget.untrack then Budget.untrack(g._viridianFlowerOwner)end end
return M
