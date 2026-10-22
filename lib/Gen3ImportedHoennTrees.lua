-- Exact repeated Hoenn evergreen crowns. A packed 1x2 native owner contains
-- two whole 16x16 crowns, not a single mature tree with a 32px ground depth.
-- Keep all source proportions and never borrow the projected walking caps.
local V=...
local Models=V.require('SceneryModels')
local M={model='oras_evergreen_tree'}
local crowns={[0xe]=true,[0xf]=true,[0xc6]=true,[0xc7]=true}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
local function hoenn(c,options)
 local def=c and(c.def or c.region and c.region.def)
 local id=def and def.id or options and options.mapId or''
 return options and options.region=='hoenn'or id:match('^EM_')or id:match('^RU_')or id:match('^SA_')
end
function M.register()
 if Models.info(M.model)then return true end
 local ok,data=pcall(V.require,'ImportedPineTreeData')
 if not ok or type(data)~='table'or not data[M.model]then return nil,'ORAS evergreen source unavailable'end
 return Models.register(M.model,data[M.model],{read=function(path)return V.mod:read(path)end})
end
function M.select(c,options)
 local s=c and c.shape
 -- 03E/03F are white rails; 0CF is a staircase; 01E/01F/02E/02F/0CE
 -- contain clipped tree edges. None is a complete source evergreen crown.
 if not(s and s.kind=='tree'and s.root and s.treeFamily=='conifer'and not s.treePalette
  and c.primary=='general'and c.pair=='general__'..(c.secondary or'')and hoenn(c,options)and crowns[c.mid])then return end
 return M.model
end
function M.policy(id)
 if id==M.model then return{minWidth=15.9,minDepth=15.9,minHeight=18}end
end
function M.placements(c,cells,options)
 if not M.select(c,options)or type(cells)~='table'then return end
 local b=c.shape.treeBounds
 if type(b)~='table'or #b~=4 then return end
 for _,n in ipairs(b)do if not finite(n)or n%16~=0 then return end end
 if b[3]-b[1]~=16 or(b[4]-b[2]~=16 and b[4]-b[2]~=32)or not finite(c.base or 0)then return end
 for y=b[2]/16,b[4]/16-1 do
  local q=cells[(b[1]/16)..':'..y];local s=q and q.shape
  if not(q and q.primary=='general'and q.pair==c.pair and q.secondary==c.secondary and crowns[q.mid]
   and q.collision==7 and not(q.boundary or q.prop or q.civic or q.stageHidden)
   and s and s.kind=='tree'and s.treeFamily=='conifer'and not s.treePalette and s.treeBounds==b
   and finite(q.base or 0)and math.abs((q.base or 0)-(c.base or 0))<.01)then return end
 end
 if not M.register()then return end
 local list={};local union={math.huge,math.huge,-math.huge,-math.huge}
 local info={height=0,bounds=union}
 for y=b[2]/16,b[4]/16-1 do
  local x=b[1]/16
  local fit={width=16,depth=16,padding=.25,rotation=(x*17+y*29)%4}
  local f=Models.fit(M.model,fit)
  if not f or f.bounds[5]<18 then return end
  local wx,wz=x*16,y*16
  union[1],union[2]=math.min(union[1],wx+f.bounds[1]),math.min(union[2],wz+f.bounds[3])
  union[3],union[4]=math.max(union[3],wx+f.bounds[4]),math.max(union[4],wz+f.bounds[6])
  info.height=math.max(info.height,f.bounds[5]);info.canopyBottom=f.anchors.canopyBottom and f.anchors.canopyBottom[2]or nil
  list[#list+1]={model=M.model,x=wx,y=c.base or 0,z=wz,fit=fit,source=c,treeInfo=info}
 end
 return list
end
return M
