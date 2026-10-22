-- Actual HGSS Museum, explicitly adapted to both original FR/LG entrances.
local V=...
local Models=V.require('SceneryModels')
local M={id='hgss_pewter_museum'};local registered=false
local rows={
 {0x280,0x281,0x282,0x281,0x282,0x281,0x282,0x281,0x282,0x281,0x286,0x01d,0x01c,0x01d,0x01c,0x01d},
 {0x288,0x289,0x289,0x289,0x289,0x289,0x289,0x289,0x289,0x289,0x28e,0x28c,0x28b,0x28c,0x28b,0x285},
 {0x290,0x291,0x291,0x291,0x291,0x291,0x291,0x291,0x291,0x291,0x296,0x291,0x291,0x291,0x291,0x28d},
 {0x298,0x299,0x299,0x299,0x299,0x299,0x299,0x299,0x299,0x299,0x29e,0x294,0x294,0x293,0x294,0x295},
 {0x2a0,0x2a1,0x2a1,0x2a1,0x2a2,0x2a3,0x2a4,0x2a5,0x2a5,0x2a5,0x2a6,0x29c,0x29b,0x2ce,0x29c,0x29d},
 {0x2a8,0x2a9,0x2a9,0x2a9,0x2aa,0x2ab,0x2ac,0x2ad,0x2ad,0x2ad,0x2ae,0x001,0x009,0x008,0x009,0x001},
 {0x005,0x005,0x005,0x005,0x2b2,0x2b3,0x2b4,0x005,0x005,0x005,0x005,0x001,0x001,0x0e6,0x0e6,0x0e6}}
local function permission(x,y)
 if y==1 and x>=11 and x<=14 then return 0 end
 if y==4 and x==13 or y==6 and x==5 then return 0x71 end
 if y==5 and x>=11 or y==6 and(x==11 or x==12)then return 0 end
 return 7
end
local function owned(x,y)return y==0 and x<=10 or y>=1 and y<=4 or y==5 and x<=10 or y==6 and x>=4 and x<=6 end
function M.eligible(g,cells)
 if g.family~='pewter_museum' or not(g.custom and g.custom.geometry=='pewter_museum')or g.pair~='pewter_outdoor' or g.width~=16 or g.depth~=7 or g.stageHidden then return false end
 local base
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do
  local c=cells[(g.cx+x-1)..':'..(g.cy+y-1)]
  if not c or c.pair~=g.pair or c.mid~=mid or c.collision~=permission(x-1,y-1)or c.boundary or c.stageHidden then return false end
  if owned(x-1,y-1)then
   if c.civic~=g or c.prop then return false end
   if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end
  end
 end end
 return true
end
function M.register()
 if registered then return true end
 local ok,err=Models.register(M.id,V.require('PewterMuseumData')[M.id],{read=function(path)return V.mod:read(path)end})
 if ok then registered=true end;return ok,err
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 local fit={width=256,depth=112,padding=.25,anchor='door',targetX=88,targetZ=110}
 local p={model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=g.cy*16,fit=fit}
 local result,why=Models.buildBatches({p},newMesh,{parts=parts});if not result then return false,why end
 g.importedPewterMuseum=assert(Models.fit(M.id,fit));return true
end
function M.doorSurface(g,tx,ty)
 local f=g.importedPewterMuseum;if not f then return end
 local name,w,h,sourceX,sourceY,height
 if tx==g.cx+5 and ty==g.cy+6 then name,w,h,sourceX,sourceY,height='door',16,16,80,96,24
 elseif tx==g.cx+13 and ty==g.cy+4 then name,w,h,sourceX,sourceY,height='eastDoor',14,16,209,64,24*175.5/182
 else return end
 local a=f.anchors[name];local x,z=g.cx*16+a[1],g.cy*16+a[3]+.025
 return {w=w,h=h,sourceX=g.cx*16+sourceX,sourceY=g.cy*16+sourceY,base=g.groundHeight or 0,
  vertices={{x-w/2,a[2]+height,z},{x+w/2,a[2]+height,z},{x+w/2,a[2],z},{x-w/2,a[2],z}}}
end
M.rows=rows;M.permission=permission;M.owned=owned
return M
