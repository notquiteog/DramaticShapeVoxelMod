-- Ground ownership for recognized native trees. Sprite portrait height and
-- projected cap rows are not ground depth. Native permissions stay unchanged.
local M={}
local function copy(t)local out={};for k,v in pairs(t)do out[k]=v end;return out end
local function profile(c)
 local s=c.shape
 local forest=s.spacing==3
 local w=s.treeRows and #s.treeRows[1]or(forest and 3 or 2)
 local d=forest and 2 or math.min(2,s.treeRows and #s.treeRows or 2)
 local family=s.treeFamily or(forest and 'tiered'or'conifer')
 return {w=w,d=d,forest=forest,family=family,key=c.pair..':'..family..':'..w..':'..d,source=s}
end
local function solid(c)return c and(c.collision==7 or(c.collision==nil and c.boundary=='forest'))end
function M.prepare(cells,edition)
 if edition~='firered'and edition~='leafgreen'and edition~='emerald'and edition~='ruby'and edition~='sapphire'then return {models=0,cells=0,projected=0,fragments=0}end
 local list,stats={}, {models=0,cells=0,projected=0,fragments=0}
 for _,c in pairs(cells)do
  if c.primary=='general'and c.shape.kind=='tree'and not c.civic and not c.prop then
   list[#list+1]=c
   if not solid(c)then
    local s=copy(c.shape);s.root=false
    -- Native grass permissions remain walking/encounter cells beneath the
    -- projected crown; don't replace their grass with plain route lawn.
    if c.collision==24 then s.ground=0xd end
    c.shape=s;stats.projected=stats.projected+1
   elseif not c.regionalTree and not c.shape.treeBounds then c.treeProfile=profile(c)end
  end
 end
 table.sort(list,function(a,b)if a.cy~=b.cy then return a.cy<b.cy end;return a.cx<b.cx end)
 local function eligible(c,p)
  return c and c.treeProfile and c.treeProfile.key==p.key and solid(c)and not c.treeOwner
 end
 local function rectangle(root,x,y,w,d)
  local p=root.treeProfile
  if not p then return false end
  for yy=y,y+d-1 do for xx=x,x+w-1 do if not eligible(cells[xx..':'..yy],p)then return false end end end
  local bounds={x*16,y*16,(x+w)*16,(y+d)*16}
  for yy=y,y+d-1 do for xx=x,x+w-1 do
   local c=cells[xx..':'..yy];local s=copy(p.source)
   s.root=c==root;s.anchorX=(x+w/2-c.cx)*16;s.anchorZ=(y+d/2-c.cy)*16
   s.modelWidth=w*16-.04;s.modelDepth=d*16-.04;s.treeBounds=bounds
   c.shape=s;c.treeOwner=root;stats.cells=stats.cells+1
  end end
  stats.models=stats.models+1;return true
 end
 -- Preserve source-defined crowns first. General roots are the bottom of
 -- their blocked two-row footprint, not its centre plus a forward offset.
 for _,c in ipairs(list)do if c.treeProfile and c.shape.root and not c.treeOwner then
  local p=c.treeProfile;local x=c.cx-(p.forest and 1 or 0)
  local y=c.boundary and c.cy or p.forest and c.cy or c.cy-p.d+1
  local d=p.d
  if p.forest then
   local base=cells[c.cx..':'..(y+2)]
   if base and base.mid==676 then d=3 end
  end
  if not rectangle(c,x,y,p.w,d)and d~=p.d then rectangle(c,x,y,p.w,p.d)end
 end end
 -- Cropped forest borders and odd turns still contain blocked tree art.
 -- Pack its remaining cells, never a walking/foreign/missing cell. Source
 -- family and palette stay shared; only the bounded ground fit changes.
 for _,c in ipairs(list)do if c.treeProfile and not c.treeOwner then
  local p=c.treeProfile;local best,area
  for d=1,p.d do for w=1,p.w do
   local valid=true
   for yy=c.cy,c.cy+d-1 do for xx=c.cx,c.cx+w-1 do if not eligible(cells[xx..':'..yy],p)then valid=false end end end
   if valid and(not area or w*d>area)then best,area={w,d},w*d end
  end end
  if best then rectangle(c,c.cx,c.cy,best[1],best[2]);stats.fragments=stats.fragments+1 end
 end end
 return stats
end
return M
