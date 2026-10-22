-- Exact Hoenn tree art/owner variants. Walking projected caps never acquire
-- geometry. Ambiguous exposed trunks below blocked dense crowns stand down.
local V=...
local Models=V.require('SceneryModels')
local M={model='oras_evergreen_tree',shallowModel='oras_route104_broadleaf_shallow',foregroundModel='oras_evergreen_foreground'}
local crowns={[0xe]=true,[0xf]=true,[0xc6]=true,[0xc7]=true,[0xce]=true}
local trunks={[0x16]=true,[0x17]=true}
local round={};for _,mid in ipairs{0x1ce,0x1cf,0x1d4,0x1d5,0x1d6,0x1d7,0x1dc,0x1dd,0x1e4,0x1e5,0x1e6,0x1e7}do round[mid]=true end
M.shallowSource={model='oras_route104_broadleaf',scale={1,1,.5},rotations={0,2}}
M.foregroundSource={model=M.model,scale={1,1,2},rotations={0,2}}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
local function hoenn(c,options)
 local def=c and(c.def or c.region and c.region.def)
 local id=def and def.id or c and c.region and c.region.mapId or options and options.mapId or''
 return options and options.region=='hoenn'or id:match('^EM_')or id:match('^RU_')or id:match('^SA_')
end
local function clone(t)
 if type(t)~='table'then return t end;local q={};for k,v in pairs(t)do q[k]=clone(v)end;return q
end
function M.register(id)
 id=id or M.model
 if Models.info(id)then return true end
 if id==M.foregroundModel then
  local ok,data=pcall(V.require,'ImportedPineTreeData')
  if not ok or type(data)~='table'or not data[M.model]then return nil,'ORAS evergreen source unavailable'end
  local source=clone(data[M.model])
  for _,p in ipairs(source.parts)do
   for _,v in ipairs(p.vertices)do v[3]=v[3]*2 end
   if p.bounds then p.bounds[3],p.bounds[6]=p.bounds[3]*2,p.bounds[6]*2 end
  end
  for _,p in pairs(source.anchors or{})do p[3]=p[3]*2 end
  if source.bounds then source.bounds[3],source.bounds[6]=source.bounds[3]*2,source.bounds[6]*2 end
  return Models.register(id,source,{read=function(path)return V.mod:read(path)end})
 end
 if id==M.shallowModel then
  local ok,data=pcall(V.require,'ImportedTreeData')
  if not ok or type(data)~='table'or not data[M.shallowSource.model]then return nil,'ORAS broadleaf source unavailable'end
  local source=clone(data[M.shallowSource.model])
  -- Explicit native-depth adaptation: retain X/Y, all original UV/RGBA,
  -- materials and closure topology. Quarter-turns would undo this fit.
  for _,p in ipairs(source.parts)do
   for _,v in ipairs(p.vertices)do v[3]=v[3]*.5 end
   if p.bounds then p.bounds[3],p.bounds[6]=p.bounds[3]*.5,p.bounds[6]*.5 end
  end
  for _,p in pairs(source.anchors or{})do p[3]=p[3]*.5 end
  if source.bounds then source.bounds[3],source.bounds[6]=source.bounds[3]*.5,source.bounds[6]*.5 end
  return Models.register(id,source,{read=function(path)return V.mod:read(path)end})
 end
 if id~=M.model then return nil,'unknown Hoenn tree source'end
 local ok,data=pcall(V.require,'ImportedPineTreeData')
 if not ok or type(data)~='table'or not data[M.model]then return nil,'ORAS evergreen source unavailable'end
 return Models.register(M.model,data[M.model],{read=function(path)return V.mod:read(path)end})
end
function M.select(c,options)
 local s=c and c.shape
 -- 03E/03F are white rails; 0CF is a staircase; 01E/01F/02E/02F
 -- contain side-clipped tree edges. CE is the same evergreen's short cap
 -- against the cliff, completed with the genuine source canopy.
 if not(s and s.kind=='tree'and s.root and not(s.treePalette or s.importedTreeModel)
  and c.primary=='general'and c.pair=='general__'..(c.secondary or'')and hoenn(c,options))then return end
 if s.treeFamily=='conifer'and crowns[c.mid]then return M.model end
 local b=s.treeBounds
 if not(s.treeFamily=='round'and type(b)=='table'and #b==4)then return end
 for _,n in ipairs(b)do if not finite(n)then return end end
 local w,d=b[3]-b[1],b[4]-b[2]
 if trunks[c.mid]and w==16 and d==16 then return M.model end
 if round[c.mid]and w==32 and d==16 then return M.shallowModel end
end
function M.policy(id)
 if id==M.model then return{minWidth=15.9,minDepth=15.9,minHeight=18}end
 if id==M.shallowModel then return{minWidth=31.9,minDepth=15.9,minHeight=27.5}end
 if id==M.foregroundModel then return{minWidth=15.9,minDepth=31.9,minHeight=18}end
end
-- A native blocked crown can straddle one authored six-pixel terrace step.
-- This is still one complete 2x2 tree, not four independent ground owners.
-- Only the reviewed round-tree drawing is accepted; native floor heights stay
-- intact and the original trunk/root remains the source model's ground datum.
function M.wholeRoundSlope(c,cells,options)
 local s=c and c.shape;local b=s and s.treeBounds
 if not(s and s.kind=='tree'and s.root and s.treeFamily=='round'and not(s.treePalette or s.importedTreeModel)
  and c.primary=='general'and c.pair=='general__'..(c.secondary or'')and hoenn(c,options)
  and type(b)=='table'and #b==4 and finite(c.base))then return false end
 for _,n in ipairs(b)do if not finite(n)or n%16~=0 then return false end end
 if b[3]-b[1]~=32 or b[4]-b[2]~=32 or c.cx~=b[1]/16 or c.cy~=b[4]/16-1 then return false end
 local x,y=b[1]/16,b[2]/16
 local a,ar,base,br=cells[x..':'..y],cells[(x+1)..':'..y],cells[x..':'..(y+1)],cells[(x+1)..':'..(y+1)]
 if not(a and ar and base==c and br and(a.mid==0x1d4 or a.mid==0x1d6)
  and(ar.mid==0x1d5 or ar.mid==0x1d7)
  and(c.mid==0x1dc and br.mid==0x1dd or c.mid==0x1e6 and br.mid==0x1e7))then return false end
 local low,high=math.huge,-math.huge
 for _,q in ipairs{a,ar,base,br}do local shape=q.shape
  if not(q.primary=='general'and q.pair==c.pair and q.secondary==c.secondary and q.region==c.region
   and q.collision==7 and not(q.boundary or q.prop or q.civic or q.stageHidden)
   and q.floor and q.floor.layer==0 and shape and shape.kind=='tree'and shape.treeFamily=='round'
   and shape.treeBounds==b and shape.root==(q==c)and not(shape.treePalette or shape.importedTreeModel)and finite(q.base))then return false end
  low,high=math.min(low,q.base),math.max(high,q.base)
 end
 for _,q in ipairs{a,ar,base,br}do
  if math.abs(q.base-low)>.01 and math.abs(q.base-high)>.01 then return false end
 end
 return high-low>0.01 and math.abs(high-low-6)<.01
end
local function bounds(c,w,d)
 local b=c and c.shape and c.shape.treeBounds
 if type(b)~='table'or #b~=4 then return end
 for _,n in ipairs(b)do if not finite(n)or n%16~=0 then return end end
 if b[3]-b[1]~=w or d and b[4]-b[2]~=d then return end
 return b
end
local function validOwner(c,cells,b,accepted,family,allowForest)
 if not finite(c.base or 0)then return end
 local forest=allowForest and c.boundary=='forest'and c.collision==nil
 for y=b[2]/16,b[4]/16-1 do for x=b[1]/16,b[3]/16-1 do
  local q=cells[x..':'..y];local s=q and q.shape
  if not(q and q.primary=='general'and q.pair==c.pair and q.secondary==c.secondary and accepted[q.mid]
   and((not forest and q.collision==7 and not q.boundary)or(forest and q.collision==nil and q.boundary=='forest'and q.region==c.region))
   and not(q.prop or q.civic or q.stageHidden)
   and s and s.kind=='tree'and s.treeFamily==family and not(s.treePalette or s.importedTreeModel)and s.treeBounds==b
   and finite(q.base or 0)and math.abs((q.base or 0)-(c.base or 0))<.01)then return end
 end end;return true
end
local function ownerRoot(q,cells)
 local b=q and q.shape and q.shape.treeBounds;if not b then return end
 local root
 for y=b[2]/16,b[4]/16-1 do for x=b[1]/16,b[3]/16-1 do
  local c=cells[x..':'..y]
  if c and c.shape and c.shape.treeBounds==b and c.shape.root then if root then return end;root=c end
 end end;return root
end
local function foreground(c,cells,options)
 local b=bounds(c,16)
 if not(b and (b[4]-b[2]==16 or b[4]-b[2]==32)and c.shape.treeFamily=='conifer'and M.select(c,options)
  and validOwner(c,cells,b,crowns,'conifer'))then return end
 local q=cells[(b[1]/16)..':'..(b[4]/16)];local root=ownerRoot(q,cells);local tb=bounds(root,16,16)
 if not(tb and tb[1]==b[1]and tb[2]==b[4]and trunks[root.mid]and root.shape.treeFamily=='round'
  and M.select(root,options)and root.pair==c.pair and root.secondary==c.secondary
  and math.abs((root.base or 0)-(c.base or 0))<.01 and validOwner(root,cells,tb,trunks,'round'))then return end
 return root,b[4]/16-1
end
function M.placements(c,cells,options)
 local model=M.select(c,options)
 if not model or type(cells)~='table'then return end
 local b=c.shape.treeBounds
 if type(b)~='table'or #b~=4 then return end
 for _,n in ipairs(b)do if not finite(n)or n%16~=0 then return end end
 local shallow=model==M.shallowModel;local trunk=not shallow and trunks[c.mid]
 if not finite(c.base or 0)then return end
 if shallow then
  if b[3]-b[1]~=32 or b[4]-b[2]~=16 then return end
 elseif b[3]-b[1]~=16 or(b[4]-b[2]~=16 and b[4]-b[2]~=32)then return end
 if trunk then
  -- 016/017 is this tree's lower foliage/trunk only when its original
  -- projected 00E/00F cap is walkable. A blocked crown above may already
  -- represent the same front tree: never append a duplicate there.
  local above=cells[(b[1]/16)..':'..(b[2]/16-1)]
  -- A verified blocked canopy owner emits the merged front tree. Return no
  -- duplicate from its lower trunk owner; upload success marks both sources.
  local master=ownerRoot(above,cells)
  if master and foreground(master,cells,options)==c then return{}end
  if not(above and above.pair==c.pair and above.primary=='general'and above.secondary==c.secondary
   and (above.mid==0xe or above.mid==0xf)and above.collision==0 and not(above.boundary or above.prop or above.civic or above.stageHidden)
   and above.shape and above.shape.kind=='tree'and not above.shape.root and not above.shape.treeBounds)then return end
 end
 local accepted=shallow and round or trunk and trunks or crowns
 if not validOwner(c,cells,b,accepted,c.shape.treeFamily,shallow)then return end
 if not M.register(model)then return end
 local lower,frontY
 if not(shallow or trunk)then lower,frontY=foreground(c,cells,options)end
 if lower and not M.register(M.foregroundModel)then return end
 local list={};local union={math.huge,math.huge,-math.huge,-math.huge}
 local info={height=0,bounds=union}
 for y=b[2]/16,b[4]/16-1 do
  local x=b[1]/16
  local merged=lower and y==frontY;local entryModel=merged and M.foregroundModel or model
  local fit={width=shallow and 32 or 16,depth=merged and 32 or 16,padding=.25,rotation=(shallow or merged)and((x+y)%2)*2 or(x*17+y*29)%4}
  local f=Models.fit(entryModel,fit)
  if not f or f.bounds[5]<(shallow and 27.5 or 18)then return end
  if shallow and(f.bounds[4]-f.bounds[1]<30.9 or f.bounds[6]-f.bounds[3]<15.4)then return end
  local wx,wz=x*16,y*16
  union[1],union[2]=math.min(union[1],wx+f.bounds[1]),math.min(union[2],wz+f.bounds[3])
  union[3],union[4]=math.max(union[3],wx+f.bounds[4]),math.max(union[4],wz+f.bounds[6])
  info.height=math.max(info.height,f.bounds[5]);info.canopyBottom=f.anchors.canopyBottom and f.anchors.canopyBottom[2]or nil
  local trunkInfo=merged and{height=f.bounds[5],canopyBottom=f.anchors.canopyBottom and f.anchors.canopyBottom[2]or nil,
   bounds={wx+f.bounds[1],wz+f.bounds[3],wx+f.bounds[4],wz+f.bounds[6]}}or nil
  list[#list+1]={model=entryModel,x=wx,y=c.base or 0,z=wz,fit=fit,source=c,treeInfo=info,
   sources=merged and{c,lower}or nil,sourceTreeInfos=merged and{[c]=info,[lower]=trunkInfo}or nil}
 end
 return list
end
return M
