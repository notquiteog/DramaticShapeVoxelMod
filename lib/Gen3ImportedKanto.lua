-- Exact native Pallet drawings, using the newer HGSS Pallet-scene source.
-- Candidate discovery never changes a cell. Failed uploads keep native columns.
local V=...
local Models=V.require('SceneryModels')
local M={recipes={}}
local registered={}
local houses={{0x281,0x282,0x282,0x282,0x283},{0x289,0x28a,0x28a,0x28a,0x28b},
 {0x291,0x293,0x292,0x292,0x294},{0x298,0x299,0x29a,0x29b,0x29c},{0x2a0,0x2a3,0x2a2,0x2a1,0x2a4}}
local lab={{0x2a8,0x2a9,0x2a9,0x2a9,0x2a9,0x2bd,0x2b5},{0x2b0,0x2b1,0x2b1,0x2b1,0x2b1,0x2b3,0x2b4},
 {0x2b8,0x2b9,0x2b9,0x2b9,0x2b9,0x2bb,0x2bc},{0x2c0,0x2c1,0x2d0,0x2c2,0x2c3,0x2c4,0x2c5},
 {0x2c8,0x2c9,0x2d8,0x2ac,0x2cb,0x2cc,0x2cd}}
-- Same native house art describes both homes. Position belongs to the map's
-- own source definition, not the streamed camera coordinates; a connection can
-- translate its cells. The fixed layout identity distinguishes Red and rival.
M.recipes={{model='hgss_pallet_red',rows=houses,width=5,doorX=1,sourceX=5,sourceY=3},
 {model='hgss_pallet_rival',rows=houses,width=5,doorX=1,sourceX=14,sourceY=3},
 {model='hgss_pallet_oak',rows=lab,width=7,doorX=3,sourceX=13,sourceY=9}}
function M.eligible(g,cells)
 local r=g.kantoRecipe;if g.nativeMap~='FR_PALLET_TOWN' or not r or g.stageHidden or g.pair~='pallet_outdoor' or g.width~=r.width or g.depth~=5 then return false end
 local base
 for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
  local c=cells[(g.cx+x-1)..':'..(g.cy+y-1)]
  local permission=y==1 and 0 or(y==5 and x==r.doorX+1 and 0x71 or 7)
  if not c or c.pair~=g.pair or c.secondary~='pallet_town' or c.mid~=mid or c.collision~=permission
   or c.boundary or c.stageHidden or c.prop or(c.civic and c.civic~=g)then return false end
  if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end
 end end
 return true
end
function M.prepare(cells,regions)
 local out={};if type(regions)~='table'then return out end
 for _,c in pairs(cells)do if c.pair=='pallet_outdoor' and c.secondary=='pallet_town' and not c.civic then
  for _,r in ipairs(M.recipes)do if c.mid==r.rows[1][1]then
   local sx,sy,map=c.cx,c.cy,nil
   if regions then
    map=nil
    for _,region in ipairs(regions)do
     local lx,ly=c.cx-region.x,c.cy-region.y
     if lx>=0 and ly>=0 and lx<region.w and ly<region.h then sx,sy,map=lx,ly,region.def.id;break end
    end
   end
   if map=='FR_PALLET_TOWN' and sx==r.sourceX and sy==r.sourceY then
    local g={cx=c.cx,cy=c.cy,width=r.width,depth=5,pair=c.pair,kind=r.width==7 and 'lab' or 'house',
     family=r.model,kantoRecipe=r,nativeMap=map,rows=r.rows,ts=c.ts,custom={ground=0x296,family='frlg'},groundHeight=c.base or 0}
    if M.eligible(g,cells)then out[#out+1]=g end
   end
  end end
 end end
 table.sort(out,function(a,b)return a.cy==b.cy and a.cx<b.cx or a.cy<b.cy end)
 return out
end
function M.register(id)
 if registered[id]then return true end
 local data=V.require('PalletBuildingData')[id];if not data then return nil,'unknown Pallet model'end
 local ok,err=Models.register(id,data,{read=function(path)return V.mod:read(path)end})
 if ok then registered[id]=true end;return ok,err
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local r=g.kantoRecipe;local ok,err=M.register(r.model);if not ok then return false,err end
 local fit={width=g.width*16,depth=64,padding=.25,anchor='door',targetX=r.doorX*16+8,targetZ=49}
 local placement={model=r.model,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}
 local result,why=Models.buildBatches({placement},newMesh,{parts=parts})
 if not result then return false,why end
 g.importedKanto=assert(Models.fit(r.model,fit))
 -- Commit presentation ownership only after every image/mesh is available.
 for y=0,4 do for x=0,g.width-1 do cells[(g.cx+x)..':'..(g.cy+y)].civic=g end end
 return true
end
function M.doorSurface(g,tx,ty)
 local f=g.importedKanto;local r=g.kantoRecipe
 if not f or tx~=g.cx+r.doorX or ty~=g.cy+4 then return end
 local a=f.anchors.door;local x,z=g.cx*16+a[1],(g.cy+1)*16+a[3]+.025
 local half=10*f.scale/(r.width==7 and 116 or 96);local height=26*f.scale/(r.width==7 and 116 or 96)
 return {w=14,h=16,sourceX=(g.cx+r.doorX)*16+1,sourceY=(g.cy+4)*16,base=g.groundHeight or 0,
  vertices={{x-half,a[2]+height,z},{x+half,a[2]+height,z},{x+half,a[2],z},{x-half,a[2],z}}}
end
return M
