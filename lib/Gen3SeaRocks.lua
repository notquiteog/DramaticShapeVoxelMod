-- Hoenn open-sea rocks: complete 2x2 native drawings become one closed stone.
-- Two primary-tileset families (hash-identical in Emerald, Ruby, Sapphire):
--   boulder 150/151/158/159 - grey boulder inside a dark water/ripple ring
--   peak    175/176/17D/17E - brown sea stack rising from open water
-- Only complete groups whose four cells are native solid (0x07) are claimed; the
-- hull is carved from the drawing's own rock pixels (water/ripple colours and
-- thin foam lines are excluded) so it stays inside the blocked 2x2 footprint.
-- The cells beneath take the adjacent native water drawing. Presentation only.
local V=...
local M={}
local sides={{1,0},{-1,0},{0,1},{0,-1}}
local around={{1,0},{-1,0},{0,1},{0,-1},{1,1},{-1,-1},{1,-1},{-1,1}}
M.families={
 {name='sea_boulder',rows={{0x150,0x151},{0x158,0x159}},height=13,style='rock'},
 -- The stack keeps its pointed silhouette: a row hull, not rounded masses.
 {name='sea_peak',rows={{0x175,0x176},{0x17d,0x17e}},height=30,trimOutline=true},
}
local member={}
for _,f in ipairs(M.families)do for iy,row in ipairs(f.rows)do for ix,mid in ipairs(row)do member[mid]={f,ix-1,iy-1}end end end
M.member=member
local function hoenn()
 local ok,GV=pcall(require,'src.core.GameVersion');local v=ok and GV.get()
 return v=='emerald' or v=='ruby' or v=='sapphire'
end
function M.prepare(cells)
 if not hoenn() then return 0 end
 local count=0
 local templates={} -- owned by this build; never shared across provider reloads
 for _,c in pairs(cells)do
  local m=c.primary=='general' and member[c.mid]
  if m and m[2]==0 and m[3]==0 and not c.seaRock then
   local f=m[1];local parts,ok={},true
   for iy,row in ipairs(f.rows)do for ix,mid in ipairs(row)do
    local n=cells[(c.cx+ix-1)..':'..(c.cy+iy-1)]
    if not n or n.pair~=c.pair or n.mid~=mid or n.seaRock or n.civic or n.prop
     or n.collision~=7 then ok=false else parts[#parts+1]=n end
   end end
   if ok then
    -- Underlay: the most common adjacent native water drawing.
    local votes,ground,best={},0x170,0
    for y=c.cy-1,c.cy+#f.rows do for x=c.cx-1,c.cx+#f.rows[1] do
     local n=cells[x..':'..y]
     if n and n.pair==c.pair and not member[n.mid] and n.shape and n.shape.kind=='water' then
      votes[n.mid]=(votes[n.mid] or 0)+1
      if votes[n.mid]>best then best,ground=votes[n.mid],n.mid end
     end
    end end
    local byTiles=templates[c.ts or c.pair or c];if not byTiles then byTiles={};templates[c.ts or c.pair or c]=byTiles end
    local byFamily=byTiles[f];if not byFamily then byFamily={};byTiles[f]=byFamily end
    local template=byFamily[ground];if not template then template={};byFamily[ground]=template end
    local g={family=f,root=c,cx=c.cx,cy=c.cy,ground=ground,template=template}
    for _,n in ipairs(parts)do
     n.seaRock=g;n.shape={kind='rock',ground=ground,seaRock=g,root=n==c}
    end
    count=count+1
   end
  end
 end
 return count
end
local function pixel(ts,x,y)
 local r,g,b,a=ts.imageData:getPixel(x,y)
 if ts.overImageData then local rr,gg,bb,aa=ts.overImageData:getPixel(x,y)
  r,g,b,a=rr*aa+r*(1-aa),gg*aa+g*(1-aa),bb*aa+b*(1-aa),aa+a*(1-aa)
 end
 return r,g,b,a
end
-- Rock pixels: not part of the water underlay palette and not a saturated
-- blue (deep water shadow, ripple ring). Grey stone and brown stacks pass.
function M.isRock(r,g,b,water)
 if water[math.floor(r*255+.5)*65536+math.floor(g*255+.5)*256+math.floor(b*255+.5)]then return false end
 local blue=b-math.max(r,g)
 return blue<.26
end
-- Mask over the whole drawing: erode once to cut 1px foam lines, keep the
-- component nearest the centre, then grow back within the raw mask.
function M.mask(w,h,sample,water)
 local raw={}
 for y=0,h-1 do for x=0,w-1 do local r,g,b,a=sample(x,y);raw[y*w+x]=a>.5 and M.isRock(r,g,b,water) or nil end end
 local core={}
 for y=0,h-1 do for x=0,w-1 do
  local k=y*w+x
  if raw[k] and x>0 and x<w-1 and y>0 and y<h-1 and raw[k-1] and raw[k+1] and raw[k-w] and raw[k+w] then core[k]=true end
 end end
 local best,bestScore
 local seen={}
 for k in pairs(core)do if not seen[k]then
  local comp,q,at={}, {k},1;seen[k]=true
  while q[at]do local p=q[at];at=at+1;comp[#comp+1]=p
   local x,y=p%w,math.floor(p/w)
   for _,d in ipairs(sides)do
    local nx,ny=x+d[1],y+d[2];local nk=ny*w+nx
    if nx>=0 and ny>=0 and nx<w and ny<h and core[nk] and not seen[nk]then seen[nk]=true;q[#q+1]=nk end
   end
  end
  local sx,sy=0,0;for _,p in ipairs(comp)do sx=sx+p%w;sy=sy+math.floor(p/w)end
  local dx,dy=sx/#comp-w/2,sy/#comp-h/2
  local score=#comp/(1+(dx*dx+dy*dy)/64)
  if not bestScore or score>bestScore then best,bestScore=comp,score end
 end end
 local out={}
 if not best then return out end
 for _,p in ipairs(best)do out[p]=true end
 for _,p in ipairs(best)do
  local x,y=p%w,math.floor(p/w)
  for _,d in ipairs(around)do
   local nx,ny=x+d[1],y+d[2];local nk=ny*w+nx
   if nx>=0 and ny>=0 and nx<w and ny<h and raw[nk]then out[nk]=true end
  end
 end
 return out
end
local function geometry(c,uvFor)
 local g=c.shape.seaRock
 local ts=c.ts;local f=g.family;local cols,rowsN=#f.rows[1],#f.rows;local w,h=cols*16,rowsN*16
 local water={}
 local ws=ts.midToSlot[g.ground]
 if ws then for y=0,15 do for x=0,15 do
  local r,gg,b=pixel(ts,ws%ts.cols*16+x,math.floor(ws/ts.cols)*16+y)
  water[math.floor(r*255+.5)*65536+math.floor(gg*255+.5)*256+math.floor(b*255+.5)]=true
 end end end
 local function at(x,y)
  local mid=f.rows[math.floor(y/16)+1][math.floor(x/16)+1];local slot=ts.midToSlot[mid]
  if not slot then return 0,0,0,0 end
  return pixel(ts,slot%ts.cols*16+x%16,math.floor(slot/ts.cols)*16+y%16)
 end
 local mask=M.mask(w,h,at,water)
 -- The stack's waterline outline is cool grey ink; extruded through the
 -- row hull it would become a flat grey band. Its brown body carries the form.
 if f.trimOutline then for k in pairs(mask)do
  local r,gg,b=at(k%w,math.floor(k/w))
  if b>=r and b>=gg then mask[k]=nil end
 end end
 local minX,minY,maxX,maxY=w,h,-1,-1
 for k in pairs(mask)do local x,y=k%w,math.floor(k/w)
  minX,minY,maxX,maxY=math.min(minX,x),math.min(minY,y),math.max(maxX,x+1),math.max(maxY,y+1)
 end
 if maxX<minX then return {} end
 local hw,hh=maxX-minX,maxY-minY
 local function uvOf(sx,sy)
  local mid=f.rows[math.floor(sy/16)+1][math.floor(sx/16)+1];local uv=uvFor(ts,mid)
  local lx,ly=sx%16+.5,sy%16+.5
  return uv[1][1]+(uv[2][1]-uv[1][1])*lx/16,uv[1][2]+(uv[3][2]-uv[1][2])*ly/16
 end
 local sample=function(x,y)
  local sx,sy=minX+x,minY+y
  local r,gg,b,a=at(sx,sy);local u,v=uvOf(sx,sy)
  return r,gg,b,mask[sy*w+sx] and a or 0,u,v
 end
 local H=V.require('VoxelHull')
 local hull=H.build(hw,hh,sample,1,0,nil,f.style)
 -- VoxelHull depth equals the hull width; clamp it to the drawing's own
 -- vertical extent so a wide stack never reaches past its blocked rows.
 local ox,oz=minX+hw/2,minY+hh/2
 local scaleY=f.height/math.max(1,hh)
 local depthScale=math.min(1,hh/math.max(1,hw))
 local low,high=math.huge,-math.huge
 for _,q in ipairs(hull)do for _,p in ipairs(q)do
  local y=p[2]*scaleY;low=math.min(low,y);high=math.max(high,y)
 end end
 -- Keep the complete closed hull. Its actual vertical midpoint, rather than
 -- a guessed source-padding row, belongs on the surrounding water plane.
 local centerY=high>=low and(low+high)*.5 or 0
 return {hull=hull,ox=ox,oz=oz,scaleY=scaleY,depthScale=depthScale,centerY=centerY}
end
-- Local to the native terrain elevation; the scene adds c.base separately.
function M.waterline(c)
 local y=c.shape.waterline
 return type(y)=='number'and y==y and math.abs(y)<math.huge and y or .05
end
-- A small CPU-only cache survives connected-scene construction. GPU batches
-- remain scene-owned. Keep exact source identities and UV/layout dependencies;
-- explicit renderer invalidation also clears this cache for in-place edits.
local models,totalQuads,clock={},0,0
local function sourceKey(c)
 local ts,g=c.ts,c.shape.seaRock;local f=g.family
 local key={ts.cols,ts.rows,g.ground,tostring(f.height),tostring(f.style),tostring(f.trimOutline)}
 local function tile(mid)key[#key+1]=tostring(mid)..'/'..tostring(ts.midToSlot[mid])end
 tile(g.ground)
 for _,row in ipairs(f.rows)do key[#key+1]='row';for _,mid in ipairs(row)do tile(mid)end end
 return table.concat(key,':')
end
function M.clearGeometry()models={};totalQuads=0 end
local function sharedGeometry(c,uvFor,key)
 local ts=c.ts;clock=clock+1
 for _,r in ipairs(models)do
  if r.image==ts.imageData and r.over==ts.overImageData and r.uvFor==uvFor and r.key==key then
   r.used=clock;return r.model
  end
 end
 local result=geometry(c,uvFor);local count=#(result.hull or {})
 -- Oversized extension models retain the ordinary build-local fallback.
 if count<=16384 then
  while #models>=8 or totalQuads+count>16384 do
   local oldest=1;for i=2,#models do if models[i].used<models[oldest].used then oldest=i end end
   totalQuads=totalQuads-models[oldest].count;table.remove(models,oldest)
  end
  models[#models+1]={image=ts.imageData,over=ts.overImageData,uvFor=uvFor,key=key,model=result,count=count,used=clock}
  totalQuads=totalQuads+count
 end
 return result
end
function M.append(c,emit,uvFor)
 local g=c.shape.seaRock;if not(g and c.shape.root)then return end
 local template=g.template or {}
 -- Identical native art can reuse its carved volume between scene builds.
 -- Only emitted copies get world placement/elevation; templates stay immutable.
 local ts=c.ts;local key=sourceKey(c)
 if template.key~=key or not template.quads or template.image~=ts.imageData or template.over~=ts.overImageData or template.uvFor~=uvFor then
  template.key=key;template.quads=sharedGeometry(c,uvFor,key);template.image=ts.imageData;template.over=ts.overImageData;template.uvFor=uvFor
 end
 local x,z=c.cx*16,c.cy*16
 local model=template.quads;local waterline=M.waterline(c)
 for _,q in ipairs(model.hull or {})do
  local points={}
  for _,p in ipairs(q)do points[#points+1]={x+model.ox+p[1],p[2]*model.scaleY-model.centerY+waterline,z+model.oz+p[3]*model.depthScale}end
  local t={q.u,q.v}
  emit(points,{t,t,t,t},q.shade)
 end
end
-- Scene-owned batches share the exact carved hull; native atlas layers and
-- terrain heights stay separate from the immutable local model.
function M.queue(c,groups)
 if not c.shape.seaRock or not V.require('ModelInstances').available()then return false end
 if not c.shape.root then return true end
 local template=c.shape.seaRock.template
 if not template then return false end
 local group=groups[template]
 if not group then group={cells={},ts=c.ts};groups[template]=group end
 group.cells[#group.cells+1]=c
 return true
end
function M.buildInstances(groups,uvFor,newMesh,quad,out)
 local Instances=V.require('ModelInstances');local Budget=V.require('BuildBudget')
 for _,group in pairs(groups)do
  local v,i={},{};local c=group.cells[1]
  local localCell={shape={seaRock=c.shape.seaRock,root=true,waterline=0},ts=c.ts,cx=0,cy=0}
  M.append(localCell,function(p,t,s)quad(v,i,p,t,s)end,uvFor)
  if #v>0 then
   -- Transfer ownership before any yielding work, including fallback assembly.
   local part={ts=group.ts,pair=c.nativePair};out[#out+1]=part
   part.model=assert(newMesh(v,i));Budget.check()
   local positions={}
   for _,cell in ipairs(group.cells)do positions[#positions+1]={cell.cx*16,(cell.base or 0)+M.waterline(cell),cell.cy*16}end
   part.mesh=Instances.new(part.model,positions)
   if not part.mesh then
    -- Drivers without attribute instancing retain the identical merged hull.
    part.model:release();part.model=nil;v,i={},{}
    for _,cell in ipairs(group.cells)do
     M.append(cell,function(p,t,s)
      for _,vertex in ipairs(p)do vertex[2]=vertex[2]+(cell.base or 0)end
      quad(v,i,p,t,s)
     end,uvFor)
     Budget.check()
    end
    part.mesh=assert(newMesh(v,i))
   end
   Budget.check()
  end
 end
end
function M.releaseInstances(parts)
 for _,p in ipairs(parts or {})do
  if p.mesh then p.mesh:release()end
  if p.model then p.model:release()end
 end
end
return M
