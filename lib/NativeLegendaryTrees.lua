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
function M.add(card,c,cells,groups,x,y,z)
 if not(card and M.enabled()and blocked(c))then return false end
 -- Dedicated forest/Safari overrides keep their own shared Gen1 families.
 if card.legendaryForest or card.legendarySafari then return false end
 local t=template(card,(c.cx*17+c.cy*29)%4);if not t then return false end
 local b=t.low
 for cy=math.floor((z+b[2]) /16),math.floor((z+b[4]-.001)/16)do
  for cx=math.floor((x+b[1])/16),math.floor((x+b[3]-.001)/16)do
   local cell=cells[cx..':'..cy];if not blocked(cell)then return false end
  end
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
