-- Actual Gen1 mature tree geometry/materials, shared in native instanced batches.
local V=...
local M={}
local templates=setmetatable({},{__mode="v"})
local names={trunks={'tV','tI'},hoods={'cV','cI'},detail={'dV','dI'}}
function M.enabled()
 local C=V.require('CommunityVisuals');local T=V.require('TreePresentation')
 return C.customTrees()and T.voxel()and T.original()
end
local function template(card,variant)
 local detail=V.require('CommunityVisuals').treeDetailLevel()
 local height=card.h-(card.bottom or 0)
 local key=table.concat({card.w,height,variant,detail},':')
 if templates[key]then return templates[key]end
 local parts,cx,cz=V.require('CommunityFlora').nativeTreeTemplate(variant)
 local radius,top,foot=0,0,0
 for _,p in ipairs(parts)do for _,pair in pairs(names)do for _,v in ipairs(p[pair[1]])do
  radius=math.max(radius,math.abs(v[1]-cx),math.abs(v[3]-cz));top=math.max(top,v[2]);foot=math.min(foot,v[2])
 end end end
 if radius==0 or top<=foot then return end
 local sx,sy=card.w/(2*radius),height/(top-foot)
 local result={groups={},low={1e9,1e9,-1e9,-1e9}}
 for kind,pair in pairs(names)do
  local vs,ix={},{}
  for _,p in ipairs(parts)do local offset=#vs
   for _,v in ipairs(p[pair[1]])do
    local x,y,z=(v[1]-cx)*sx,(v[2]-foot)*sy,(v[3]-cz)*sx
    vs[#vs+1]={x,y,z,v[4],v[5],v[6]}
    if y<24 then local b=result.low;b[1]=math.min(b[1],x);b[2]=math.min(b[2],z);b[3]=math.max(b[3],x);b[4]=math.max(b[4],z)end
   end
   for _,i in ipairs(p[pair[2]])do ix[#ix+1]=offset+i end
  end
  if #ix>0 then result.groups[#result.groups+1]={kind=kind,vertices=vs,indices=ix}end
 end
 templates[key]=result;return result
end
local function blocked(c)
 -- Boundary.resolve labels only scenery outside every real connected map.
 -- Never treat a real walkable cell as solid, even if an extension labels it.
 return c and(c.collision==7 or(c.collision==nil and c.boundary=='forest'))
end
-- A native tree can sit against a path even though the imported prototype
-- has broader roots. Fit that same pack into the connected blocked rectangle
-- instead of silently mixing a native tree into the selected replacement style.
local function fitted(t,cells,x,z)
 local b=t.low
 local cx,cz=math.floor(x/16),math.floor(z/16)
 if not blocked(cells[cx..':'..cz])then return end
 local l,r=math.floor((x+b[1])/16),math.floor((x+b[3]-.001)/16)
 local n,s=math.floor((z+b[2])/16),math.floor((z+b[4]-.001)/16)
 local best,area
 for left=l,cx do for right=cx,r do for back=n,cz do for front=cz,s do
  local valid=true
  for yy=back,front do for xx=left,right do
   if not blocked(cells[xx..':'..yy])then valid=false;break end
  end;if not valid then break end end
  if valid then
   local a=(right-left+1)*(front-back+1)
   if not area or a>area then area=a;best={left*16+.02,back*16+.02,(right+1)*16-.02,(front+1)*16-.02}end
  end
 end end end end
 if not best then return end
 local sx,sz=1,1
 if b[1]<0 then sx=math.min(sx,(x-best[1])/-b[1])end
 if b[3]>0 then sx=math.min(sx,(best[3]-x)/b[3])end
 if b[2]<0 then sz=math.min(sz,(z-best[2])/-b[2])end
 if b[4]>0 then sz=math.min(sz,(best[4]-z)/b[4])end
 if sx<=0 or sz<=0 then return end
 local key=string.format('%.5f:%.5f',sx,sz)
 t.fitted=t.fitted or setmetatable({},{__mode='v'})
 if t.fitted[key]then return t.fitted[key]end
 local result={groups={},low={b[1]*sx,b[2]*sz,b[3]*sx,b[4]*sz}}
 for _,part in ipairs(t.groups)do
  local vertices={}
  for i,v in ipairs(part.vertices)do vertices[i]={v[1]*sx,v[2],v[3]*sz,v[4],v[5],v[6]}end
  result.groups[#result.groups+1]={kind=part.kind,vertices=vertices,indices=part.indices}
 end
 t.fitted[key]=result;return result
end
function M.add(card,c,cells,groups,x,y,z)
 if not(card and M.enabled()and blocked(c))then return false end
 -- Dedicated forest/Safari overrides keep their own shared Gen1 families.
 if card.legendaryForest or card.legendarySafari then return false end
 local t=template(card,(c.cx*17+c.cy*29)%4);if not t then return false end
 local b=t.low;local fits=true
 for cy=math.floor((z+b[2]) /16),math.floor((z+b[4]-.001)/16)do
  for cx=math.floor((x+b[1])/16),math.floor((x+b[3]-.001)/16)do
   if not blocked(cells[cx..':'..cy])then fits=false;break end
  end
 end
 if not fits then
  local fit=fitted(t,cells,x,z)
  if not fit then
   -- Edge metatiles can anchor their projected crown on a cell boundary or
   -- in the next (walkable/missing) cell. Ground the same tree in its known
   -- blocked root cell, never in that projected-art margin.
   local rootX,rootZ=c.cx*16+8,c.cy*16+8
   fit=fitted(t,cells,rootX,rootZ)
   if fit then x,z=rootX,rootZ end
  end
  if not fit then return false end;t=fit
 end
 local row=groups[t];if not row then row={template=t,positions={}};groups[t]=row end
 row.positions[#row.positions+1]={x,y,z};return true
end
function M.build(groups)
 local out={};local R=V.require('Voxel3D');local I=V.require('ModelInstances')
 for _,group in pairs(groups)do for _,part in ipairs(group.template.groups)do
  V.require('BuildBudget').tick()
  part.mesh=part.mesh or R.newMesh(part.vertices,part.indices)
  local batch=I.new(part.mesh,group.positions)
  if batch then out[#out+1]={mesh=batch,kind=part.kind,template=group.template}
  else
   local vs,ix={},{};for _,pos in ipairs(group.positions)do local offset=#vs
    for _,v in ipairs(part.vertices)do vs[#vs+1]={v[1]+pos[1],v[2]+pos[2],v[3]+pos[3],v[4],v[5],v[6]}end
    for _,i in ipairs(part.indices)do ix[#ix+1]=offset+i end
   end
   out[#out+1]={mesh=R.newMesh(vs,ix),kind=part.kind}
  end
 end end
 return out
end
function M.draw(parts,draw)
 for _,p in ipairs(parts or{})do draw(p.mesh,V.require('CommunityFlora').nativeTreeMaterial(p.kind))end
end
function M.release(parts)for _,p in ipairs(parts or{})do if p.mesh then p.mesh:release()end end end
return M
